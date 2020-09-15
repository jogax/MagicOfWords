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

//let actVersion = "0.991" // Build 23, Version 1.23
//let actVersion = "1.0" // Build 25, Version 1.25
let actVersion = "1.1" // Build 27, Version 1.27
let exclamationMark = "!"
public let roundSeparator = "/" 
let itemSeparator = "°"
let itemInnerSeparator = "^"
let itemExternSeparator = "|"


//enum GameType: Int {
//    case GameNotSelected = 0, CollectWords, FixLetter, SearchWords
//}
enum LettersColor: String {
    case NoColor = "NoColor", Red = "Red", Green = "Green"
}

typealias GameType = GameDifficulty

enum GameDifficulty: Int {
    case Easy = 0, Medium, Hard, VeryHard, GameNotSelected = -1
    public func description()->String {
        switch self {
        case .Easy: return "easy"
        case .Medium: return "medium"
        case .Hard: return "hard"
        case .VeryHard: return "veryHard"
        case .GameNotSelected: return "not selected"
        }
    }
    static let CollectWords = GameType.Easy
    static let FixLetter = GameType.Medium
    static let SearchWords = GameType.Hard
}




func == (left: MyDate, right: MyDate) -> Bool {
    return left.year == right.year &&
        left.month == right.month &&
        left.day == right.day &&
        left.hour == right.hour &&
        abs(left.minute - right.minute) < 11
}

struct MyDate {
    let year: Int
    let month: Int
    let day: Int
    let hour: Int
    let minute: Int
    let second: Int
    init(date: Date) {
        let calendar = Calendar.current
        let actComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date)
        year = actComponents.year!
        month = actComponents.month!
        day = actComponents.day!
        hour = actComponents.hour!
        minute = actComponents.minute!
        second = actComponents.second!
    }
    func datum()->Int {
        return year * 10000 + month * 100 + day
    }
}

enum ScoreType: Int {
    case Easy = 0, Medium, Hard, VeryHard, WordCount
}
enum TimeScope: Int {
    case All = 0, Week, Today
}
struct ScoreForShow {
    var scoreType: ScoreType = ScoreType.WordCount
    var timeScope: TimeScope = TimeScope.Today
    var place = 0
    var player = ""
    var score = 0
    var me = false
    init (scoreType: ScoreType, timeScope: TimeScope, place: Int, player: String, score: Int, me: Bool) {
        self.scoreType = scoreType
        self.timeScope = timeScope
        self.place = place
        self.player = player
        self.score = score
        self.me = me
    }
}
let NoValue = -1
//var myWidth: CGFloat = 0
//var myHeight: CGFloat = 0

var codeTableToString: [Int: String]  = [65: "A", 66: "B", 67: "C", 68: "D", 69: "E", 70: "F", 71: "G", 72: "H", 73: "I", 74: "J",
                                         75: "K", 76: "L", 77: "M", 78: "N", 79: "O", 80: "P", 81: "Q", 82: "R", 83: "S", 84: "T",
                                         85: "U", 86: "V", 87: "W", 88: "X", 89: "Y", 90: "Z"]
var codeTableToInt: [String: Int]  = ["A": 65, "B": 66, "C": 67, "D": 68, "E": 69, "F": 70, "G": 71, "H": 72, "I": 73, "J": 74,
                                      "K": 75, "L": 76, "M": 77, "N": 78, "O": 79, "P": 80, "Q": 81, "R": 82, "S": 83, "T": 84,
                                      "U": 85, "V": 86, "W": 87, "X": 88, "Y": 89, "Z": 90]
// for GameCenter GlobalData
struct PlayerData {
    var alias = ""
    var isOnline = false
    var allTime = 0
    var lastDay = 0
    var lastTime = 0
    var device = ""
    var version = ""
    var land = ""
    var easyBestScore: Int64 = 0
    var mediumBestScore: Int64 = 0
    var easyActScore = ""
    var mediumActScore = ""
    var countPlays = ""
}

enum HintType: Int {
    case WithFixLetter = 0, WithGreenLetter, WithRedLetter
    public func description()->String {
        switch self {
            case .WithFixLetter: return "F"
            case .WithGreenLetter: return "G"
            case .WithRedLetter: return "R"
        }
    }
    init?(string: String) {
        switch string {
        case "F":
            self = .WithFixLetter
        case "G":
            self = .WithGreenLetter
        case "R":
            self = .WithRedLetter
        default:
            return nil
        }
    }
}
struct HintTableStruct {
    var hint: String = ""
    var search: String = ""
    var type: HintType = .WithRedLetter
    var count: Int = 0
    init(hint: String, search: String, type: HintType, count: Int) {
        self.hint = hint
        self.search = search
        self.type = type
        self.count = count
    }
}
extension HintTableStruct: Equatable {}

func ==(lhs: HintTableStruct, rhs: HintTableStruct) -> Bool {
    let areEqual = lhs.hint == rhs.hint && lhs.type == rhs.type

    return areEqual
}

struct HintForShow {
    var hint: String
    var score: Int
    var type: HintType
    var count: Int
    init(hint: String, score: Int, type: HintType, count: Int) {
        self.hint = hint
        self.score = score
        self.type = type
        self.count = count
    }
}

enum DeviceOrientation: Int {
    case Portrait = 0, Landscape
}
struct GV {
    static var actLanguage: String {
        get {
            return GV.language.getText(.tcAktLanguage)
        }
    }
    static let sizeOfGridValue: [Int:Int] = [0:10, 50:5, 72:6, 98:7, 128:8, 162:9, 200:10, 242:11, 288:12, 338:13, 392:14, 450:15]
    static var globalInfoTable = [PlayerData]()
    static var blockSize = CGFloat(0)
    static let calculatedSize: [Int:Int] = [0:10, 50:5, 72:6, 98:7, 128:8, 162:9, 200:10, 242:11, 288:12]
    static var deviceHasNotch = false
    static var actWidth: CGFloat = 0
    static var actHeight: CGFloat = 0
    static var deviceOrientation: DeviceOrientation = .Portrait
    static var target: AnyObject?
    static var orientationHandler: Selector?
    static var gameType: GameDifficulty = .CollectWords
    static let minSide: CGFloat = min(UIScreen.main.bounds.width, UIScreen.main.bounds.height)
    static let maxSide: CGFloat = max(UIScreen.main.bounds.width, UIScreen.main.bounds.height)
    static var actLanguageInt = GV.languageToInt[actLanguage]
    static let GameStatusNew = 0
    static let GameStatusPlaying = 1
    static let GameStatusFinished = 2
    static let GameStatusContinued = 3
    static var wtScene: WTScene?
    static var mainViewController: MainViewController?
    static var comeBackFromSleeping = false
    static var wordToSend = ""
    static var bonusForReport = 0

//    static let ButtonTypeSimple = "S"
//    static let ButtonTypeElite = "E"
    static var countOfWords = 0
    static var countOfLetters = 0
    static var minGameNumber = 0
    static var maxGameNumber = 0
    static var origDifficulty = 0
    static let SimpleGame = 0
    static let HardGame = 1
    static var actLetter = ""
//    static let DemoEasyGameNumber = 10000
//    static let DemoMediumGameNumber = 11000
    static var countOfWordsMaxValue = 1000
    static var countOfLettersMaxValue = 250
    static let TimeModifier: Int64 = 10000000000
    static let accepted = "accepted"
    static let pending = "pending"
    static let denied = "denied"
    static let waiting = "wait"
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
//    static var helpInfoRecords: Results<HelpInfo>?
    static let frequencyString = ":freq:"
    static var darkMode = false
    static var hintTable = [HintTableStruct]()
//    static var stopHintEngine = false
//    static var hintEngineStopped = true
    static let language = Language()
//    static var size = 5
    static var maxRecordCount = 0
    static var actRecordCount = 0
    static var EndOfFileReached = false
    static var lastSavedWord = ""
//    static var loadingScene: LoadingScene?
    static var gameNumber = 0
//    static var gameType = 0
    static var connectedToInternet = false
    static let onIpad = UIDevice.current.model.hasSuffix("iPad")
    static let onIPhone5 = UIDevice.current.modelName.begins(with: "iPhone 5")
    static let onSimulator = UIDevice.current.modelName.contains(strings: ["Simulator", "i386", "x86_64"])
    static var debug = false
    static let oneGrad:CGFloat = CGFloat(Double.pi) / 180
    static var activated = false
    static var gameArray: [[WTGameboardItem]] = [[WTGameboardItem]]()
    static var notificationToken: NotificationToken?
    static var sizeOfGrid = 10
//    static var mandatoryScore = 0
    static var ownScore = 0
    static var bonusScore = 0
    static var totalScore = 0
//    static var myBonusMalus = 0
//    static var generateHelpInfo = false
    static var mandatoryWords = [String]()
    static var blinkingNodes = [WTGameboardItem]()
    static var countBlinkingNodes = 0
    static var nextRoundAnimationFinished = true
    static var scoreTable = [Int]()
    static var languageToInt: [String : Int] = ["en":0, "de":1, "hu":2, "ru":3]
    static var IntToLanguage: [Int : String] = [0:"en", 1:"de", 2:"hu", 3:"ru"]
    
    static var scoreForShowTable = [ScoreForShow]()
//    static var myPlace = 0
//    static var myScore = 0
    static func convertLocaleToInt()->Int {
        var actLocale = "EN"
        if Locale.current.regionCode != nil {
            actLocale = Locale.current.regionCode!
        }
        let language = actLanguage.uppercased()
        let letter1 = actLocale.subString(at:0, length: 1)
        let letter2 = actLocale.subString(at:1, length: 1)
        let letter3 = language.subString(at:0, length: 1)
        let letter4 = language.subString(at:1, length: 1)
        let value = 10000 * (codeTableToInt[letter1]! * 100 + codeTableToInt[letter2]!) + codeTableToInt[letter3]! * 100 + codeTableToInt[letter4]!
        return value
    }
    
    static func convertIntToLocale(value: Int)->String {
        let landInt = value / 10000
        let languageInt = value % 10000
        let returnValue =
            codeTableToString[landInt / 100]! +
            codeTableToString[landInt % 100]! +
            "/" +
            codeTableToString[languageInt / 100]!.lowercased() +
            codeTableToString[languageInt % 100]!.lowercased()
        return returnValue
    }
    
    static func convertNowToMyDate()->MyDate {
        let returnValue = MyDate(date: Date())
        return returnValue
    }
    
    static func getTimeIntervalSince20190101(date: Date = Date())->Int {
        var dateComponents = DateComponents()
        dateComponents.year = 2019
        dateComponents.month = 1
        dateComponents.day = 1
        //        dateComponents.timeZone = TimeZone(abbreviation: "JST") // Japan Standard Time
        let userCalendar = Calendar.current // user calendar
        let someDateTime = userCalendar.date(from: dateComponents)
        let now = date
        let returnValue = now.timeIntervalSince(someDateTime!)
        return Int(returnValue)
    }
    

    static func getDateFromInterval(interval: Int)->MyDate {
        var dateComponents = DateComponents()
        dateComponents.year = 2019
        dateComponents.month = 1
        dateComponents.day = 1
        let userCalendar = Calendar.current // user calendar
        let referenceDate = userCalendar.date(from: dateComponents)
        let date = Date(timeInterval: Double(interval), since: referenceDate!)
        let returnValue = MyDate(date: date)
        return returnValue
    }


    

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
var timer = [Date]()
public func setFirstTime()->Int {
    let time = Date()
    timer.append(time)
    return timer.count - 1
}

public func showTime(num: Int, string: String) {
    let date = Date()
    print("time at \(string): \((date.timeIntervalSince(timer[num]) * 1000).nDecimals(10))")
    timer[num] = Date()
}

public func stopTime() {
    timer.removeLast()
}





