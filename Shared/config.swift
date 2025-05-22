//
//  config.swift
//  ADA_C2_MomoRun
//
//  Created by Rafie Amandio F on 22/05/25.
//

import Foundation

struct Config {
    // Game Scene Configurations
    static let gameMoveSpeed: Double = 5.0 // tiles per second
    static let obstacleSpawnInterval: TimeInterval = 1.0 // seconds
    
    // Motion Detector Configurations
    static let motionUpdateInterval: TimeInterval = 1.0 / 60.0 // Hz
    static let motionStillThreshold: Double = 0.05
    static let motionJumpThreshold: Double = -0.25 // velZ threshold
    static let motionCrouchThreshold: Double = 0.25 // velZ threshold
    static let motionLeftThreshold: Double = 0.1 // velX threshold
    static let motionRightThreshold: Double = -0.1 // velX threshold
    static let motionDebounceTime: TimeInterval = 0.75 // seconds between movements
}

