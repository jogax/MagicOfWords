////
////  HelpInfo.swift
////  MagicOfWords
////
////  Created by Jozsef Romhanyi on 12/04/2019.
////  Copyright © 2019 Jozsef Romhanyi. All rights reserved.
////
//
//import UIKit
//import RealmSwift
//
//enum TypeOfTouch: Int {
//    case FromBottom = 0, FromGameArray, UndoButton, ShowMyWordsButton, FinishButton, ContinueGameEasy, ContinueGameMedium, FinishGameEasy, FinishGameMedium, OKFixLettersSolved, OKMandatorySolved, NoMoreStepsBack, NoMoreStepsNext, NoMoreStepsCont, FinishGame
//}
//
//enum LettersColor: String {
//    case NoColor = "NoColor", Red = "Red", Green = "Green"
//}
//
//class HelpInfo: Object {
//    @objc dynamic var combinedKey = ""
//    @objc dynamic var language = ""
//    @objc dynamic var difficulty = 0
//    @objc dynamic var counter = 0
//    @objc dynamic var typeOfTouch = TypeOfTouch.FromBottom.rawValue
//    @objc dynamic var beganInfo = "" // FromBottom: "shapeIndex", FromGameArray: "col / row / GRow / relPosX / relPosY"
//    @objc dynamic var movedInfo = "" // "col / row / GRow / rexPosX / relPosY"
//    @objc dynamic var endedInfo = ""
//    @objc dynamic var letters = ""
//    override  class func primaryKey() -> String {
//        return "combinedKey"
//    }
//}
