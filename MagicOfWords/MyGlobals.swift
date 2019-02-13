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
import RealmSwift

let exclamationMark = "!"
public let roundSeparator = "/"
let itemSeparator = "°"
let itemInnerSeparator = "^"


enum GameType: Int {
    case WordTris = 1, SearchWords, NoMoreGames
}

enum GameDifficulty: Int {
    case Easy = 0, Medium, Hard, VeryHard
}

let NoValue = -1
var myWidth: CGFloat = 0
var myHeight: CGFloat = 0 


struct GV {
    static var actLanguage: String {
        get {
            return GV.language.getText(.tcAktLanguage)
        }
    }
    static let GameStatusNew = 0
    static let GameStatusPlaying = 1
    static let GameStatusFinished = 2
    static let GameStatusContinued = 3
    static var playingRecord = GameDataModel()
    static var basicDataRecord = BasicDataModel()
    static let frequencyString = ":freq:"

    static let language = Language()
    static let size = 10
    static var maxRecordCount = 0
    static var actRecordCount = 0
    static var EndOfFileReached = false
    static var lastSavedWord = ""
//    static var loadingScene: LoadingScene?
    static var gameNumber = 0
//    static var gameType = 0
    static var connectedToInternet = false
    static let onIpad = UIDevice.current.model.hasSuffix("iPad")
    static let onSimulator = UIDevice.current.modelName.contains(strings: ["Simulator", "i386", "x86_64"])
    static var debug = false
    static let oneGrad:CGFloat = CGFloat(Double.pi) / 180
    static var activated = false
    static var gameArray: [[WTGameboardItem]] = [[WTGameboardItem]]()
    static var notificationToken: NotificationToken?
    static let sizeOfGrid = 10
    static var mandatoryScore = 0
    static var ownScore = 0
    static var bonusScore = 0
    static var totalScore = 0
    static var mandatoryWords = [String]()
    static var myUser: SyncUser? = nil {
        willSet(newValue) {
            for callBack in callBackMyUser {
                callBack.callBackMyUser
            }
        }
    }
    struct CallBackStruct {
        var myCaller:String
        var callBackMyUser: ()
        init(caller: String, callBackFunction: ()) {
            myCaller = caller
            callBackMyUser = callBackFunction
        }
    }
    static var callBackMyUser: Array<CallBackStruct> = []



//    RealmSync Constants
    static let MY_INSTANCE_ADDRESS = "magic-of-words.us1.cloud.realm.io" // <- update this
    
    static let AUTH_URL  = URL(string: "https://\(MY_INSTANCE_ADDRESS)")!
//    static let REALM_URL = URL(string: "realms://\(MY_INSTANCE_ADDRESS)/MagicOfWords")!
    static let REALM_URL = URL(string: "realms://\(MY_INSTANCE_ADDRESS)/MagicOfWordsTest1")!
}




