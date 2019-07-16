//
//  PlayerScore.swift
//  MagicOfWords
//
//  Created by Jozsef Romhanyi on 16/07/2019.
//  Copyright © 2019 Jozsef Romhanyi. All rights reserved.
//

import Foundation
import RealmSwift

class PlayerScore: Object {
    
    // 1 record pro player and language
    @objc dynamic var combinedPrimary: String = "" // language + playerName
    @objc dynamic var language: String = ""
    @objc dynamic var playerName: String = ""
    @objc dynamic var easyScore: Int = 0
    @objc dynamic var mediumScore: Int = 0
    @objc dynamic var hardScore: Int = 0
    @objc dynamic var veryHardScore: Int = 0
    @objc dynamic var owner: PlayerActivity? // to-one relationships must be optional
    @objc dynamic var timeStamp = Date()
    
    
    override static func primaryKey() -> String? {
        return "combinedPrimary"
    }
    
    public func getScore(difficulty: Int)-> Int {
        switch difficulty {
        case GameDifficulty.Easy.rawValue: return easyScore
        case GameDifficulty.Medium.rawValue: return mediumScore
        case GameDifficulty.Hard.rawValue: return hardScore
        case GameDifficulty.VeryHard.rawValue: return veryHardScore
        default: return 0
        }
    }
    public func setScore(difficulty: Int, score: Int) {
        if score > getScore(difficulty: difficulty) {
            switch difficulty {
            case GameDifficulty.Easy.rawValue: easyScore = score
            case GameDifficulty.Medium.rawValue: mediumScore = score
            case GameDifficulty.Hard.rawValue: hardScore = score
            case GameDifficulty.VeryHard.rawValue: veryHardScore = score
            default: break
            }
        }
    }
    
    public func myFilter(difficulty: Int, score: Int)->Bool {
        switch difficulty {
        case GameDifficulty.Easy.rawValue: return easyScore > score
        case GameDifficulty.Medium.rawValue: return mediumScore > score
        case GameDifficulty.Hard.rawValue: return hardScore > score
        case GameDifficulty.VeryHard.rawValue: return veryHardScore > score
        default: return false
        }
    }
}
