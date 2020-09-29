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
import RealmSwift
import Reachability

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

func + (left: PLPosSize, right: PLPosSize)-> PLPosSize {
    return PLPosSize(PPos: CGPoint(x: left.PPos.x + right.PPos.x, y: left.PPos.y + right.PPos.y),
                     LPos: CGPoint(x: left.LPos.x + right.LPos.x, y: left.LPos.y + right.LPos.y))
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

public func setBackground(to: SKSpriteNode? = bgSprite!) {
    let BackgroundName = "BackgroundName"
    let background = SKSpriteNode(imageNamed: GV.actHeight > GV.actWidth ? "backgroundP" : "backgroundL")
    background.size = UIScreen.main.bounds.size
    background.position = CGPoint(x: UIScreen.main.bounds.midX, y: UIScreen.main.bounds.midY)
    background.zPosition = -50
    background.nodeType = .Background
    background.name = BackgroundName
    removeChildrenWithTypes(from: to!, types: [.Background])
    to!.addChild(background)
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

func printChildren() {
    for child in bgSprite!.children {
        let printLine = (child.name == nil ? "NoName" : child.name!) + ": zPosition: \(child.zPosition)"
        print(printLine)
        if child.children.count > 0 {
            for child1 in child.children {
                let printLine = (child1.name == nil ? "NoName1" : child1.name!) + ": zPosition: \(child1.zPosition)"
                print("   " + printLine)
                if child1.children.count > 0 {
                    for child2 in child1.children {
                        var text = ""
                        if child2.name != nil && child2.name == "°°°GameboardItemLabel°°°" {
                            text = "Letter: " + (child2 as! SKLabelNode).text!
                        }
                        let printLine = (child2.name == nil ? "NoName2" : child2.name!) + ": zPosition: \(child2.zPosition) + \(text)"
                        print("      " + printLine)
                        if child2.children.count > 0 {
                            for child3 in child2.children {
                                let printLine = (child3.name == nil ? "NoName3" : child3.name!) + ": zPosition: \(child3.zPosition)"
                                print("         " + printLine)
                            }
                        }
                    }
                }
            }
        }
    }
}

public  func getRealm(type: RealmType)->Realm {
    let shemaVersion: UInt64 = type == .PlayedGameRealm ? 6 : 4
    let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    let gamesURL = documentsURL.appendingPathComponent(type == .GamesRealm ? "OrigGames.realm" : "PlayedGames.realm")
    let config = Realm.Configuration(
        fileURL: gamesURL,
        schemaVersion: shemaVersion,
        migrationBlock: { migration, oldSchemaVersion in
            switch (type, oldSchemaVersion) {
            case (.PlayedGameRealm, _):
                migration.enumerateObjects(ofType: PlayedGame.className())
                { oldObject, newObject in
//                        newObject!["buttonType"] = GV.ButtonTypeSimple
                }
            case (.GamesRealm, _):
                migration.enumerateObjects(ofType: Games.className())
                { oldObject, newObject in
//                        newObject!["buttonType"] = GV.ButtonTypeSimple
                }
            }
        },
        shouldCompactOnLaunch: { totalBytes, usedBytes in
            // totalBytes refers to the size of the file on disk in bytes (data + free space)
            // usedBytes refers to the number of bytes used by data in the file

            // Compact if the file is over 100MB in size and less than 50% 'used'
            let oneMB = 10 * 1024 * 1024
            return (totalBytes > oneMB) && (Double(usedBytes) / Double(totalBytes)) < 0.8
    },
        objectTypes: [type == .GamesRealm ? Games.self : PlayedGame.self])
    do {
        // Realm is compacted on the first open if the configuration block conditions were met.
        _ = try Realm(configuration: config)
    } catch {
        print("error")
        // handle error compacting or opening Realm
    }

    let realm = try! Realm(configuration: config)
    return realm
}



public func startReachability() {
    if GV.reachability == nil {
        try! GV.reachability = Reachability()
    }
    GV.reachability!.whenReachable = { reachability in
        if reachability.connection == .wifi {
            print("Reachable via WiFi")
        } else {
            print("Reachable via Cellular")
        }
    }
    GV.reachability!.whenUnreachable = { _ in
        print("Not reachable")
    }
    
    do {
        try GV.reachability!.startNotifier()
    } catch {
        print("Unable to start notifier")
    }

}


