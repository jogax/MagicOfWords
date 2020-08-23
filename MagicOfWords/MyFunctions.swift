//
//  MyFunctions.swift
//  Szómágia
//
//  Created by Jozsef Romhanyi on 29/01/2018.
//  Copyright © 2018 Jozsef Romhanyi. All rights reserved.
//

import Foundation
import AVFoundation
import SpriteKit

func + (left: CGSize, right: CGSize) -> CGSize {
    return CGSize(width: left.width + right.width, height: left.height + right.height)
}

func - (left: CGSize, right: CGSize) -> CGSize {
    return CGSize(width: left.width - right.width, height: left.height - right.height)
}

func * (size: CGSize, scalar: CGFloat) -> CGSize {
    return CGSize(width: size.width * scalar, height: size.height * scalar)
}

func * (size: CGSize, multiplier: CGSize) -> CGSize {
    return CGSize(width: size.width * multiplier.width, height: size.height * multiplier.height)
}

func / (point: CGSize, scalar: CGFloat) -> CGSize {
    return CGSize(width: point.width / scalar, height: point.height / scalar)
}



func + (left: CGPoint, right: CGPoint) -> CGPoint {
    return CGPoint(x: left.x + right.x, y: left.y + right.y)
}

func - (left: CGPoint, right: CGPoint) -> CGPoint {
    return CGPoint(x: left.x - right.x, y: left.y - right.y)
}

func * (point: CGPoint, scalar: CGFloat) -> CGPoint {
    return CGPoint(x: point.x * scalar, y: point.y * scalar)
}

func / (point: CGPoint, scalar: CGFloat) -> CGPoint {
    return CGPoint(x: point.x / scalar, y: point.y / scalar)
}

func getLocalDate()->Date {
    let UTCDate = Date()
    return UTCDate + TimeInterval(NSTimeZone.system.secondsFromGMT(for: UTCDate))
}

func removeChildrenExceptTypes(from: SKNode, types: [SKNodeSubclassType]) {
    for child in from.children {
        if child.nodeType != nil {
            if !types.contains(child.nodeType!) {
                child.removeAllStoredPropertys()
                child.removeFromParent()
            }
        }
    }
}

func removeChildrenWithTypes(from: SKNode, types: [SKNodeSubclassType]) {
    for child in from.children {
        if child.nodeType != nil && types.contains(child.nodeType!) {
            child.removeAllStoredPropertys()
            child.removeFromParent()
        }
    }
}




