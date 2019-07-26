//
//  BasicDataModel.swift
//  MagicOfWords
//
//  Created by Jozsef Romhanyi on 13/02/2018.
//Copyright © 2018 Jozsef Romhanyi. All rights reserved.
//

import Foundation
import RealmSwift

enum GCEnabledType: Int {
    case AskForGameCenter = 0, GameCenterEnabled, GameCenterSupressed
}


class BasicDataModel: Object {
    @objc dynamic var ID = 0
    @objc dynamic var actLanguage = ""
    @objc dynamic var myName = ""
    @objc dynamic var myNickname = ""
    @objc dynamic var keyWord = ""
    @objc dynamic var difficulty = 0
    @objc dynamic var creationTime = Date()
    @objc dynamic var searchPhrase = ""
    @objc dynamic var showingRow = 0
    @objc dynamic var showingRows = ""
//    @objc dynamic var buttonType = GV.ButtonTypeElite
    @objc dynamic var onlineTime = 0
    @objc dynamic var playingTime = 0
    @objc dynamic var playingTimeToday = 0
    @objc dynamic var today = Date()
    @objc dynamic var playing = false

    @objc dynamic var easyBestScore = 0
    @objc dynamic var mediumBestScore = 0
    @objc dynamic var hardBestScore = 0
    @objc dynamic var veryHardBestScore = 0

    @objc dynamic var easyBestPlayer = ""
    @objc dynamic var mediumBestPlayer = ""
    @objc dynamic var hardBestPlayer = ""
    @objc dynamic var veryHardBestPlayer = ""
    
    @objc dynamic var easyMyPlace = 0
    @objc dynamic var mediumMyPlace = 0
    @objc dynamic var hardMyPlace = 0
    @objc dynamic var veryHardMyPlace = 0
    
    @objc dynamic var easyScore = 0
    @objc dynamic var mediumScore = 0
    @objc dynamic var hardScore = 0
    @objc dynamic var veryHardScore = 0
    @objc dynamic var GameCenterEnabled = GCEnabledType.AskForGameCenter.rawValue
    @objc dynamic var startAnimationShown = false
    
    @objc dynamic var GCEnabled = 0 // GCEnabledType: 0 = AskForGameCenter, 1 = GameCenterEnabled, 2 = GameCenterSupressed
    override  class func primaryKey() -> String {
        return "ID"
    }
    
    public func setBestScore(difficulty: Int, score: Int, name: String, myPlace: Int) {
        switch difficulty {
        case GameDifficulty.Easy.rawValue:
            easyBestScore = score
            easyBestPlayer = name
            easyMyPlace = myPlace
        case GameDifficulty.Medium.rawValue:
            mediumBestScore = score
            mediumBestPlayer = name
            mediumMyPlace = myPlace
        default: break
        }
    }
    
    public func getBestPlayerName()->String {
        switch self.difficulty {
        case GameDifficulty.Easy.rawValue: return easyBestPlayer
        case GameDifficulty.Medium.rawValue: return mediumBestPlayer
        default: return "nobody"
        }
    }
    
    public func getBestScore()->Int {
        switch self.difficulty {
        case GameDifficulty.Easy.rawValue: return easyBestScore
        case GameDifficulty.Medium.rawValue: return mediumBestScore
        default: return 0
        }
    }
    
    public func getMyPlace()->Int {
        switch self.difficulty {
        case GameDifficulty.Easy.rawValue: return easyMyPlace
        case GameDifficulty.Medium.rawValue: return mediumMyPlace
        default: return 0
        }
    }
    
    public func getScore(difficulty: Int = -1)->Int {
        let myDifficulty = difficulty < 0 ? self.difficulty : difficulty
        switch myDifficulty {
        case GameDifficulty.Easy.rawValue: return easyScore
        case GameDifficulty.Medium.rawValue: return mediumScore
//        case GameDifficulty.Hard.rawValue: return hardScore
//        case GameDifficulty.Medium.rawValue: return veryHardScore
        default: return 0
        }
    }
    
    public func setScore(score: Int, difficulty: Int = -1) {
        let myDifficulty = difficulty < 0 ? self.difficulty : difficulty
        try! realm!.safeWrite() {
            switch myDifficulty {
            case GameDifficulty.Easy.rawValue:
                if score > easyScore {
                    easyScore = score
                }
            case GameDifficulty.Medium.rawValue:
                if score > mediumScore {
                    mediumScore = score
                }
//            case GameDifficulty.Hard.rawValue:
//                if score > hardScore {
//                    hardScore = score
//                }
//            case GameDifficulty.Medium.rawValue:
//                if score > veryHardScore {
//                    veryHardScore = score
//                }
            default:
                break
            }
        }
    }
}
