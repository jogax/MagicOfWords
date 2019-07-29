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
import GameKit

let actVersion = "0.96" // Build 18
let exclamationMark = "!"
public let roundSeparator = "/"
let itemSeparator = "°"
let itemInnerSeparator = "^"


enum GameType: Int {
    case WordTris = 1, SearchWords, NoMoreGames
}

enum GameDifficulty: Int {
    case Easy = 0, Medium, Hard, VeryHard
    public func description()->String {
        switch self {
        case .Easy: return GV.language.getText(.tcSimpleGame)
        case .Medium: return GV.language.getText(.tcMediumGame)
        case .Hard: return GV.language.getText(.tcHardGame)
        case .VeryHard: return GV.language.getText(.tcVeryHardGame)
        }
    }
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
//    static let ButtonTypeSimple = "S"
//    static let ButtonTypeElite = "E"
    static var minGameNumber = 0
    static var maxGameNumber = 0
    static var origDifficulty = 0
    static let SimpleGame = 0
    static let HardGame = 1
    static let DemoEasyGameNumber = 10000
    static let DemoMediumGameNumber = 11000
//    static let buttonType = ButtonTypeElite
    static let LabelFont = "CourierNewPS-BoldMT"
//    static let LabelFontSimple = "CourierNewPS-BoldMT"
    static let FontType = "TimesNewRomanPS-BoldMT"
//    static let FontTypeSimple = "TimesNewRomanPS-BoldMT"
    static let PieceFont = "HelveticaNeue-Light"//"HelveticaNeue-Thin" //"GillSans-Light"
//    static let PieceFontSimple = "KohinoorBangla-Regular"
    static var actFont: String {
        get {
            return FontType
        }
    }
    static var actLabelFont: String {
        get {
            return LabelFont
        }
    }
    static var actPieceFont: String {
        get {
            return PieceFont
        }
    } 
    static var playing = false
    static var playingRecord = GameDataModel()
    static var basicDataRecord = BasicDataModel()
    static var helpInfoRecords: Results<HelpInfo>?
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
//    static var mandatoryScore = 0
    static var ownScore = 0
//    static var bonusScore = 0
    static var totalScore = 0
    static var generateHelpInfo = false
    static var mandatoryWords = [String]()
    static var blinkingNodes = [WTGameboardItem]()
    static var countBlinkingNodes = 0
    static var nextRoundAnimationFinished = true
    static var scoreTable = [Int]()
    
    static var screenWidth: CGFloat {
        if (UIApplication.shared.statusBarOrientation == UIInterfaceOrientation.portrait) {
            return UIScreen.main.bounds.size.width
        } else {
            return UIScreen.main.bounds.size.height
        }
    }
    static var screenHeight: CGFloat {
        if (UIApplication.shared.statusBarOrientation == UIInterfaceOrientation.portrait) {
            return UIScreen.main.bounds.size.height
        } else {
            return UIScreen.main.bounds.size.width
        }
    }
    static var screenOrientation: UIInterfaceOrientation {
        return UIApplication.shared.statusBarOrientation
    }

    static var myUser: SyncUser? = nil {
        willSet(newValue) {
            for callBack in callBackMyUser {
                callBack.callBackFunc()
            }
        }
    }
//    static var expertUser = false {
//        didSet(newValue) {
//            for callBack in callBackExpertUser {
//                callBack.callBackFunc()
//            }
//        }
//    }
    struct CallBackStruct {
        var myCaller:String
        var callBackFunc: ()->()
        init(caller: String, callBackFunction: @escaping ()->()) {
            myCaller = caller
            callBackFunc = callBackFunction
        }
    }
    static var callBackExpertUser: Array<CallBackStruct> = []
    static var callBackMyUser: Array<CallBackStruct> = []



//    RealmSync Constants
//    static let MY_INSTANCE_ADDRESS = "magic-of-words.us1.cloud.realm.io" // <- update this
//    
//    static let AUTH_URL  = URL(string: "https://\(MY_INSTANCE_ADDRESS)")!
////    static let REALM_URL = URL(string: "realms://\(MY_INSTANCE_ADDRESS)/MagicOfWords")!
//    static let REALM_URL = URL(string: "realms://\(MY_INSTANCE_ADDRESS)/MagicOfWordsTest1")!
//    static let NEW_REALM_URL = URL(string: "realms://\(MY_INSTANCE_ADDRESS)/MagicOfWordsRealm")!

}




