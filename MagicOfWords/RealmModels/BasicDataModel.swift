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
    @objc dynamic var difficulty = 0
    @objc dynamic var sizeOfGrid = 10
    @objc dynamic var creationTime = Date()
    @objc dynamic var searchPhrase = ""
    @objc dynamic var showingRow = 0
    @objc dynamic var showingRows = ""
    @objc dynamic var playingTime = 0
    @objc dynamic var playingTimeToday = 0
    @objc dynamic var countPlaysToday = 0
    @objc dynamic var lastPlayingDay = 0
    @objc dynamic var deviceType = 0
    @objc dynamic var setMoveModusDuration = 0.5
    @objc dynamic var land = 0
    @objc dynamic var version = 0
    @objc dynamic var countPlays = 0
    @objc dynamic var musicOn = false
    @objc dynamic var prefill = 0
    @objc dynamic var GameCenterEnabled = GCEnabledType.AskForGameCenter.rawValue
    @objc dynamic var startAnimationShown = false
    @objc dynamic var showingScoreType = 0 // ScoreType
    @objc dynamic var showingTimeScope = 0 // TimeScope
    @objc dynamic var deviceRecordInCloudID = ""
    let scoreInfos = List<ScoreInfoForDifficulty>()

    override  class func primaryKey() -> String {
        return "ID"
    }
    
    public func setBestScore(score: Int, name: String, myRank: Int) {
        scoreInfos[self.difficulty].bestScore = score
        scoreInfos[self.difficulty].bestPlayerName = name
        scoreInfos[self.difficulty].myRank = myRank
    }
    public func getBestScore()->(bestScore: Int, bestName: String, myRank: Int, myScore: Int) {
        let bestScore = scoreInfos[self.difficulty].bestScore
        let bestName = scoreInfos[self.difficulty].bestPlayerName
        let myRank = scoreInfos[self.difficulty].myRank
        let myScore = scoreInfos[self.difficulty].myScore
        return (bestScore, bestName, myRank, myScore)
    }
//    public func getScore()->Int {
//        return scoreInfos[self.difficulty].myScore
//    }
    
//    public func setScore(score: Int) {
//        try! realm!.safeWrite() {
//            scoreInfos[self.difficulty].myScore = score
//        }
//    }
    


}
