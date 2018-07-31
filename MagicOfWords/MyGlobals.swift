//
//  MyFunctions.swift
//  Szómágia
//
//  Created by Jozsef Romhanyi on 29/01/2018.
//  Copyright © 2018 Jozsef Romhanyi. All rights reserved.
//

import Foundation
import AVFoundation
import UIKit

let exclamationMark = "!"
public let roundSeparator = "/"
let itemSeparator = "°"
let itemInnerSeparator = "^"


enum GameType: Int {
    case WordTris = 1, SearchWords, NoMoreGames
}
let NoValue = -1
var myWidth: CGFloat = 0
var myHeight: CGFloat = 0 

//struct WordToCheck {
//    var word: String = ""
//    var countFounded = 0
//    var score = 0
//    var mandatory = false
//    var creationIndex = 0
//    var founded: Bool {
//        get {
//            return (countFounded > 0)
//        }
//    }
//    init(word: String, countFounded: Int, mandatory: Bool, creationIndex: Int, score: Int) {
//        self.word = word
//        self.countFounded = countFounded
//        self.mandatory = mandatory
//        self.creationIndex = creationIndex
//        self.score = score
//    }
//    init(from: String) {
//        let valueTab = from.components(separatedBy: "-")
//        if valueTab.count == 2 {
//            self.word = valueTab[0]
//            self.creationIndex = 0
//            if let createIndex = Int(valueTab[1]) {
//                self.creationIndex = createIndex
//            }
//        }
//    }
//    func toString()->String {
//        return word + "-" + String(creationIndex)
//    }
//}


struct GV {
    static let gameNumberAdder: [String:Int] = ["en": 0, "de": 10000, "hu":20000, "ru": 30000]
    static var aktLanguage: String {
        get {
            return GV.language.getText(.tcAktLanguage)
        }
    }
    static let GameStatusNew = 0
    static let GameStatusPlaying = 1
    static let GameStatusFinished = 2
    static var playingRecord = GameDataModel()
    static var basicDataRecord = BasicDataModel()

    static let language = Language()
    static var maxRecordCount = 0
    static var actRecordCount = 0
    static var EndOfFileReached = false
    static var lastSavedWord = ""
//    static var loadingScene: LoadingScene?
    static var gameNumber = 0
//    static var gameType = 0
    static let onIpad = UIDevice.current.model.hasSuffix("iPad")
    static let oneGrad:CGFloat = CGFloat(Double.pi) / 180
    static var activated = false
    static var gameArray: [[WTGameboardItem]] = [[WTGameboardItem]]()

//    static var countMandatoryWords = 0
//    static var allWordsX = [WordToCheck]()
//    static func countWords(mandatory: Bool, countAll: Bool = false)->Int {
//        var count = 0
//        for actWord in GV.allWordsX {
//            count += actWord.mandatory == mandatory && actWord.countFounded > 0 ? (countAll ? actWord.countFounded : 1) : 0
//        }
//        return count
//    }
//    static func allMandatoryWordsFounded()->Bool {
//        return GV.countMandatoryWords == countWords(mandatory: true)
//    }
    
//    static func getScore()->Int {
//        var score = 0
//        for actWord in GV.allWordsX {
//            score += actWord.score
//        }
//        return score
//    }
    
//    RealmSync Constants
    static let MY_INSTANCE_ADDRESS = "magic-of-words.us1.cloud.realm.io" // <- update this
    
    static let AUTH_URL  = URL(string: "https://\(MY_INSTANCE_ADDRESS)")!
    static let REALM_URL = URL(string: "realms://\(MY_INSTANCE_ADDRESS)/MagicOfWords")!
}




