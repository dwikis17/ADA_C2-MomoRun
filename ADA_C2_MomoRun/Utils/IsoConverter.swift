//
//  IsoConverter.swift
//  ADA_C2_MomoRun
//
//  Created by Dwiki on 16/05/25.
//

import Foundation


struct Vector {
    let x: Int
    let y: Int
    let z: Int
    
    init(x: Int, y: Int, z: Int) {
        self.x = x
        self.y = y
        self.z = z
    }
    
    init(x:Int, y:Int) {
        self.init(x: x, y: y, z: 0)
    }
    
    static func +(lhs: Vector, rhs: Vector) -> Vector {
        Vector(x: lhs.x + rhs.x , y: lhs.y + rhs.y , z: lhs.z + rhs.z)
    }
    
    static func *(scalar: Int, vector: Vector) -> Vector {
        Vector(x: scalar * vector.x, y: scalar * vector.y, z: scalar * vector.z )
    }

}

extension Vector: Equatable { }

func convertWorldToScreen (_ worldSpacePosition: Vector) -> Vector {
    let xOffset = Vector(x: 16, y: 8)
    let yOffset = Vector(x: -16, y: 8)
    let zOffset = Vector(x: 0, y: 8)
    

    return worldSpacePosition.x * xOffset + worldSpacePosition.y * yOffset + worldSpacePosition.z * zOffset
}

    func convertWorldToZPosition(_ worldSpacePosition: Vector) -> Int {
        return -convertWorldToScreen(worldSpacePosition).y + worldSpacePosition.z * 8 * 2
    }
//func convertWorldToScreen(_ worldSpacePosition: Vector3D, direction: Rotation = .defaultRotation) -> Vector2D {
//    let xOffset = Vector2D(x: 16, y: 8)
//    let yOffset = Vector2D(x: -16, y: 8)
//    let zOffset = Vector2D(x: 0, y: 8)
//    
//    let rotatedWorldSpacePosition = rotateCoordinate(worldSpacePosition, direction: direction)
//    
//    return rotatedWorldSpacePosition.x * xOffset + rotatedWorldSpacePosition.y * yOffset + rotatedWorldSpacePosition.z * zOffset
//}


//
//func rotateCoordinate(_ coord: Vector3D, direction: Rotation) -> Vector3D {
//    switch direction {
//    case .degrees45:
//        return coord
//    case .degrees225:
//        return Vector3D(x: -coord.x, y: -coord.y, z: coord.z)
//    case .degrees315:
//        return Vector3D(x: coord.y, y: -coord.x, z: coord.z)
//    case .degrees135:
//        return Vector3D(x: -coord.y, y: coord.x, z: coord.z)
//    }
//}
//
//let spriteAnimationMap = [
//    "Knight": [
//        "Walk": "Walking_B",
//        "MeleeAttack": "2H_Melee_Attack_Chop",
//        "TakeDamage": "Hit_A"
//    ],
//    "Rogue":
//        [
//            "Idle": "2H_Melee_Idle",
//            "Walk": "Walking_C",
//            "TakeDamage": "Hit_B",
//            "RangedAttack": "2H_Ranged_Shoot",
//        ]
//]

//func getIdleAnimationFirstFrameNameForEntity(_ entity: Entity, referenceRotation: Rotation = .defaultRotation) -> String {
//    getAnimationNameForEntity(entity, animation: "Idle", referenceRotation: referenceRotation) + "_0"
//}
//
//func getAnimationNameForEntity(_ entity: Entity, animation: String, referenceRotation: Rotation = .defaultRotation) -> String {
//    let animationName = spriteAnimationMap[entity.sprite]?[animation] ?? "Idle"
//    let viewRotation = entity.rotation.withReferenceRotation(referenceRotation)
//    return "\(entity.sprite)_\(animationName)_\(viewRotation.rawValue)"
//}
//
