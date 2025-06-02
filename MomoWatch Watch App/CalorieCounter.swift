//
//  CalorieCounter.swift
//  ADA_C2_MomoRun
//
//  Created by Komang Wikananda on 26/05/25.
//

import HealthKit

class HealthStore: ObservableObject {
    
    private var workoutSession: HKWorkoutSession?
    private var workoutBuilder: HKLiveWorkoutBuilder?
    private var sessionStartDate: Date?
    
    private var activeEnergyQuery: HKObserverQuery?

    let healthStore = HKHealthStore()

    let readTypes: Set = [
        HKQuantityType(.activeEnergyBurned),
        HKQuantityType(.heartRate)
    ]
    public func resumeSession() {
        guard let workoutSession = workoutSession else {
            fatalError("CANNOT RESUME")
        
        }
        self.healthStore.resumeWorkoutSession(workoutSession)
    }
    
    // MARK: WORKOUT SESSION ============================================================
    
    func startWorkout() {
        guard workoutSession == nil else { return }
        let configuration = HKWorkoutConfiguration()
        
        configuration.activityType = .other
        configuration.locationType = .indoor
        
        do {
            workoutSession = try HKWorkoutSession(healthStore: healthStore, configuration: configuration)
            workoutBuilder = workoutSession?.associatedWorkoutBuilder()
            workoutBuilder?.dataSource = HKLiveWorkoutDataSource(healthStore: healthStore, workoutConfiguration: configuration)
            workoutSession?.startActivity(with: Date())
            workoutBuilder?.beginCollection(withStart: Date(), completion: {_,_ in })
            print("Workout session started")
        } catch {
            
            print("Failed to start workout session: \(error.localizedDescription)")
        }
    }
     
    func stopWorkout() {
        workoutSession?.end()
        workoutBuilder?.endCollection(withEnd: Date(), completion: {_,_ in })
        workoutSession = nil
        workoutBuilder = nil        
    }
    
    // MARK: AUTHORIZATION ============================================================
    
    func requestHealthData() async {
        do {
            if HKHealthStore.isHealthDataAvailable() {
                try await healthStore.requestAuthorization(toShare: [], read: readTypes)
            }
            
        } catch {
            print("*** An unexpected error occurred while requesting authorization: \(error.localizedDescription) ***")
        }
    }
    
    // MARK: CALORIE COUNTER ============================================================
    
    func startCalorieSession() {
        sessionStartDate = Date()
    }

    func stopCalorieSession() {
        sessionStartDate = nil
    }
    
    // Fetch one at a time
    func fetchActiveEnergyBurned(completion: @escaping (Double) -> Void) {
        let calories = HKQuantityType(.activeEnergyBurned)
        // let startOfDay = Calendar.current.startOfDay(for: Date())
        let start = sessionStartDate ?? Calendar.current.startOfDay(for: Date())
        let predicate = HKQuery.predicateForSamples(withStart: start, end: Date(), options: .strictStartDate)
        let query = HKStatisticsQuery(quantityType: calories, quantitySamplePredicate: predicate) {
            _, result, error in
            guard let quantity = result?.sumQuantity(), error == nil else {
                print("Error when trying to fetch calorie data: \(error?.localizedDescription)")
                return
            }
            
            let caloriesBurned = quantity.doubleValue(for: HKUnit.kilocalorie())
            DispatchQueue.main.async {
                completion(caloriesBurned)
            }
        }
        healthStore.execute(query)
    }
    
    // Read calorie live
    func startLiveCalorieUpdates(completion: @escaping(Double) -> Void) {
        guard let activeEnergyType = HKObjectType.quantityType(forIdentifier: .activeEnergyBurned) else {
            print("Failed to create active energy type")
                return
        }

        activeEnergyQuery = HKObserverQuery(sampleType: activeEnergyType, predicate: nil) { [weak self] (query, completionHandler, error) in
            guard let self = self else { return }
            if let error = error {
                print("Observer active energy query failed: \(error.localizedDescription)")
                completionHandler()
                return
            }
            
            self.fetchActiveEnergyBurned { calories in
                DispatchQueue.main.async {
                    completion(calories)
                }
                completionHandler()
            }
        }
        
        if let query = activeEnergyQuery {
            healthStore.execute(query)
            fetchActiveEnergyBurned { calories in
                DispatchQueue.main.async {
                    completion(calories)
                }
            }
        }
    }
    
    func stopLiveCalorieUpdates() {
        if let query = activeEnergyQuery {
            healthStore.stop(query)
            activeEnergyQuery = nil
        }
    }
    
    // MARK: HEART RATE TRACKER ============================================================
    
    func fetchMostRecentHeartRate(completion: @escaping (HKQuantitySample?) -> Void) {
        guard let heartRateType = HKObjectType.quantityType(forIdentifier: .heartRate) else {
            completion(nil)
            return
        }
        
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
        let query = HKSampleQuery(sampleType: heartRateType,
                                                 predicate: nil,
                                                 limit: 1,
                                                 sortDescriptors: [sortDescriptor])
        { (query, samples, error) in
            if let error = error {
                print("Error: \(error.localizedDescription)")
                return
            }
            
            DispatchQueue.main.async {
                guard let samples = samples,
                      let mostRecentSample = samples.first as? HKQuantitySample else {
                    completion(nil)
                    return
                }
                completion(mostRecentSample)
            }
        }
        healthStore.execute(query)
    }
    
    func fetchHeartRateLive(completion: @escaping (Double) -> Void) {
        guard let heartRateType = HKObjectType.quantityType(forIdentifier: .heartRate) else {
            print("Failed to fetch heart rate")
            return
        }
        
        let query = HKObserverQuery(sampleType: heartRateType, predicate: nil) { [weak self] (query, completionHandler, error) in
            if let error = error {
                print("Observer heart query failed: \(error.localizedDescription)")
                completionHandler()
                return
            }
            
            self?.fetchMostRecentHeartRate { sample in
                if let sample = sample {
                    let heartRateUnit = HKUnit.count().unitDivided(by: HKUnit.minute())
                    let heartRate = sample.quantity.doubleValue(for: heartRateUnit)
                    DispatchQueue.main.async {
                        completion(heartRate)
                    }
                }
                completionHandler()
            }
        }
        healthStore.execute(query)
    }
}

