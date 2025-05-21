//
//  MotionDetector.swift
//  ADA_C2_MomoRun
//
//  Created by Komang Wikananda on 21/05/25.
//
import CoreMotion
import Foundation

class SensorModel: ObservableObject {
    @Published var isMoving: Bool = false
    @Published var directionX: String = ""
    @Published var directionZ: String = ""

    @Published var accelerationValue: String = ""
    @Published var gravityValue: String = ""

    @Published var accelX: Double = 0.0
    @Published var accelY: Double = 0.0
    @Published var accelZ: Double = 0.0
    
    @Published var filteredAccelX: Double = 0.0
    @Published var filteredAccelY: Double = 0.0
    @Published var filteredAccelZ: Double = 0.0
    
    @Published var velocityX: Double = 0.0
    @Published var velocityY: Double = 0.0
    @Published var velocityZ: Double = 0.0
    
    @Published var isFetching: Bool = false
    
    var getDirection: Bool = true
    
//    @Published var rotationValue: String = ""
    
    // Instance of CMMotionManager responsible for handling sensor updates
    let motionManager: CMMotionManager = .init()
    
    // Properties to hold sensor values
    private var userAcceleration: CMAcceleration = CMAcceleration()
    private var gravity: CMAcceleration = CMAcceleration()
//    private var rotationRate: CMRotationRate = CMRotationRate()
    
    private var lastTimestamp: TimeInterval?
    private var lastMovementTimestamp: TimeInterval?
    
    // Kalman Filter
    private var kalmanFilterX: KalmanFilter<Double>!
    private var kalmanFilterY: KalmanFilter<Double>!
    private var kalmanFilterZ: KalmanFilter<Double>!
    
    // Kalman Filter parameters
    private let processNoiseCovariance: Double = 0.05 // Q_k
    private let measurementNoiseCovariance: Double = 0.5 // R_k
    private let stateTransitionModel: Double = 1.0 // F_k
    private let observationModel: Double = 1.0 // H_k
    private let controlInputModel: Double = 0.0 // B_k
    private let controlVector: Double = 0.0 // u_k
    
    func startFetchingSensorData() {
        // Check if motion and accelerometer data available
        if motionManager.isDeviceMotionAvailable && motionManager.isAccelerometerAvailable {
            isFetching = true
            
            velocityX = 0.0
            velocityY = 0.0
            velocityZ = 0.0
            
            kalmanFilterX = KalmanFilter(stateEstimatePrior: 0.0, errorCovariancePrior: 1.0)
            kalmanFilterY = KalmanFilter(stateEstimatePrior: 0.0, errorCovariancePrior: 1.0)
            kalmanFilterZ = KalmanFilter(stateEstimatePrior: 0.0, errorCovariancePrior: 1.0)
            
            lastTimestamp = nil
            
            motionManager.deviceMotionUpdateInterval = 1.0 / 60.0 // 10 Hz
            motionManager.startDeviceMotionUpdates(to: .main) {
                [weak self] (motion, error) in
                guard let self = self else { return } // prevents memory leaks
                if let error = error {
                    print("Error: \(error.localizedDescription)")
                    self.isFetching = false
                    return
                }
                self.getMotionAndGravity(motion: motion)
            }
        }
    }
    
    func stopFetchingSensorData() {
        if motionManager.isDeviceMotionAvailable {
            motionManager.stopDeviceMotionUpdates()
            isFetching = false
        }
    }
    
    
    private func getMotionAndGravity(motion: CMDeviceMotion?) {
        if let motion = motion {
            self.userAcceleration = motion.userAcceleration
            let rawUserAcceleration = motion.userAcceleration
            self.gravity = motion.gravity
            
            self.accelerationValue = String(format: "%.2f, %.2f, %.2f", rawUserAcceleration.x, rawUserAcceleration.y, rawUserAcceleration.z)
            self.gravityValue = String(format: "%.2f, %.2f, %.2f", gravity.x, gravity.y, gravity.z)
            
            // Update sensor value
            let R = motion.attitude.rotationMatrix
            
            let worldAccelX = R.m11 * rawUserAcceleration.x + R.m21 * rawUserAcceleration.y + R.m31 * rawUserAcceleration.z
            let worldAccelY = R.m12 * rawUserAcceleration.x + R.m22 * rawUserAcceleration.y + R.m32 * rawUserAcceleration.z
            let worldAccelZ = R.m13 * rawUserAcceleration.x + R.m23 * rawUserAcceleration.y + R.m33 * rawUserAcceleration.z
            
            //            self.accelX = userAcceleration.x
            //            self.accelY = userAcceleration.y
            //            self.accelZ = userAcceleration.z
            
            self.accelX = worldAccelX
            self.accelY = worldAccelY
            self.accelZ = worldAccelZ
            
            // Kalman Filtering
            kalmanFilterX = kalmanFilterX.predict(stateTransitionModel: stateTransitionModel, controlInputModel: controlInputModel, controlVector: controlVector, covarianceOfProcessNoise: processNoiseCovariance)
            kalmanFilterY = kalmanFilterY.predict(stateTransitionModel: stateTransitionModel, controlInputModel: controlInputModel, controlVector: controlVector, covarianceOfProcessNoise: processNoiseCovariance)
            kalmanFilterZ = kalmanFilterZ.predict(stateTransitionModel: stateTransitionModel, controlInputModel: controlInputModel, controlVector: controlVector, covarianceOfProcessNoise: processNoiseCovariance)
            
            // Update step
            kalmanFilterX = kalmanFilterX.update(measurement: self.accelX, observationModel: observationModel, covarienceOfObservationNoise: measurementNoiseCovariance)
            kalmanFilterY = kalmanFilterY.update(measurement: self.accelY, observationModel: observationModel, covarienceOfObservationNoise: measurementNoiseCovariance)
            kalmanFilterZ = kalmanFilterZ.update(measurement: self.accelZ, observationModel: observationModel, covarienceOfObservationNoise: measurementNoiseCovariance)
            
            self.filteredAccelX = kalmanFilterX.stateEstimatePrior
            self.filteredAccelY = kalmanFilterY.stateEstimatePrior
            self.filteredAccelZ = kalmanFilterZ.stateEstimatePrior
            
            let currentTimestamp = motion.timestamp
            if (!getDirection) {
                if let lastMovementTimestamp = self.lastMovementTimestamp {
                    let deltaLastMove = currentTimestamp - lastMovementTimestamp
                    if (deltaLastMove > 0.75) {
                        getDirection = true
                        print("getDirection: \(self.getDirection)")
                        self.directionX = ""
                        self.directionZ = ""
                    }
                } else {
                    getDirection = true
                }
            }
            
            if let lastTimestamp = self.lastTimestamp {
                let deltaTime = currentTimestamp - lastTimestamp
                
                // Using filtered data
                self.velocityX += self.filteredAccelX * Double(deltaTime)
                self.velocityY += self.filteredAccelY * Double(deltaTime)
                self.velocityZ += self.filteredAccelZ * Double(deltaTime)
                
                // Using raw accel
                //                self.velocityX += userAcceleration.x * Double(deltaTime)
                //                self.velocityY += userAcceleration.y * Double(deltaTime)
                //                self.velocityZ += userAcceleration.z * Double(deltaTime)
            }
            //            if (self.velocityX > 0.1 || self.velocityY > 0.1 || self.velocityZ > 0.1) {
            //                isMoving = true
            //            }
            
            // Threshold for ZUPT
            let stillThreshold = 0.05
            
            if (abs(self.filteredAccelX) < stillThreshold &&
                abs(self.filteredAccelY) < stillThreshold &&
                abs(self.filteredAccelZ) < stillThreshold) {
                isMoving = false
            }
            else {
                isMoving = true
            }
            
            // Zero Velocity Potential Update
            if !self.isMoving {
                self.velocityX = 0.0
                self.velocityY = 0.0
                self.velocityZ = 0.0
            }
            
            if (getDirection) {
                let velX = self.velocityX
                let velZ = self.velocityZ
                
                var isJump = false
                var isCrouch = false
                var isLeft = false
                var isRight = false
                
                if velZ < -0.25 {
                    isJump = true
                } else if velZ > 0.25 {
                    isCrouch = true
                }
                
                if velX > 0.1 {
                    isLeft = true
                } else if velX < -0.1 {
                    isRight = true
                }
                
                var finalDirectionX = ""
                var finalDirectionZ = ""
                var movementWasDetected = false
                
                if isJump {
                    finalDirectionZ = "jump"
                    movementWasDetected = true
                } else if isCrouch {
                    finalDirectionZ = "crouch"
                    movementWasDetected = true
                }
                
                if isLeft {
                    finalDirectionX = "left"
                    movementWasDetected = true
                } else if isRight {
                    finalDirectionX = "right"
                    movementWasDetected = true
                }
                
                if movementWasDetected {
                    self.directionX = finalDirectionX
                    self.directionZ = finalDirectionZ
                    
                    if !finalDirectionZ.isEmpty {
                        print(finalDirectionZ)
                    }
                    if !finalDirectionX.isEmpty {
                        print(finalDirectionX)
                    }
                    
                    self.getDirection = false
                    self.lastMovementTimestamp = currentTimestamp
                } else {
                    if self.isMoving {
                        self.directionX = ""
                        self.directionZ = ""
                    }
                }
            }
            
            self.lastTimestamp = currentTimestamp // timestep for kalman filter
        }
    }
}
