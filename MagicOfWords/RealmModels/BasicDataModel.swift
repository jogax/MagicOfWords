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
//    @objc dynamic var myNickname = ""
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
    @objc dynamic var lastDayPlayed = Date()
    @objc dynamic var playToday = 0
    @objc dynamic var playing = false
    @objc dynamic var GameCenterEnabled = GCEnabledType.AskForGameCenter.rawValue // GCEnabledType: 0 = AskForGameCenter, 1 = GameCenterEnabled, 2 = GameCenterSupressed
    @objc dynamic var startAnimationShown = false
    let scoreInfos = List<ScoreInfoForLanguage>()

    override  class func primaryKey() -> String {
        return "ID"
    }
    public func setBestScore(score: Int, name: String, myRank: Int) {
        let languageIndex = GV.languageToInt[self.actLanguage]
        scoreInfos[languageIndex!].difficultyInfos[self.difficulty].bestScore = score
        scoreInfos[languageIndex!].difficultyInfos[self.difficulty].bestPlayerName = name
        scoreInfos[languageIndex!].difficultyInfos[self.difficulty].myRank = myRank
    }
    public func getBestScore()->(bestScore: Int, bestName: String, myRank: Int, myScore: Int) {
        let languageIndex = GV.languageToInt[self.actLanguage]
        let bestScore = scoreInfos[languageIndex!].difficultyInfos[self.difficulty].bestScore
        let bestName = scoreInfos[languageIndex!].difficultyInfos[self.difficulty].bestPlayerName
        let myRank = scoreInfos[languageIndex!].difficultyInfos[self.difficulty].myRank
        let myScore = scoreInfos[languageIndex!].difficultyInfos[self.difficulty].myScore
        return (bestScore, bestName, myRank, myScore)
    }
    public func getScore()->Int {
        let languageIndex = GV.languageToInt[self.actLanguage]
        return scoreInfos[languageIndex!].difficultyInfos[self.difficulty].myScore
    }
    
    public func setScore(score: Int) {
        try! realm!.safeWrite() {
            let languageIndex = GV.languageToInt[self.actLanguage]
            scoreInfos[languageIndex!].difficultyInfos[self.difficulty].myScore = score
        }
    }

}
