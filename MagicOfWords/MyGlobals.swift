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
let GameStatusNew = 0
let GameStatusPlaying = 1
let GameStatusFinished = 2
let itemSeparator = "°"
let itemInnerSeparator = "^"


enum GameType: Int {
    case WordTris = 1, SearchWords, NoMoreGames
}
let NoValue = -1
struct MandatoryWord {
    var word: String = ""
    var countFounded = 0
    var founded: Bool {
        get {
            return (countFounded > 0)
        }
    }
    init(word: String, countFounded: Int) {
        self.word = word
        self.countFounded = countFounded
    }
}
struct OwnWord {
    var word: String = ""
    var creationIndex: Int = 0
    init(word: String = "", creationIndex: Int = 0) {
        self.word = word
        self.creationIndex = creationIndex
    }
    init(from: String) {
        let valueTab = from.components(separatedBy: "-")
        if valueTab.count == 2 {
            word = valueTab[0]
            self.creationIndex = 0
            if let createIndex = Int(valueTab[1]) {
                self.creationIndex = createIndex
            }
        }
    }
    func toString()->String {
        return word + "-" + String(creationIndex)
    }
}


struct GV {
    static let language = Language()
    static var maxRecordCount = 0
    static var actRecordCount = 0
    static var EndOfFileReached = false
    static var lastSavedWord = ""
    static var loadingScene: LoadingScene?
    static var gameNumber = 0
    static var gameType = 0
    static let onIpad = UIDevice.current.model.hasSuffix("iPad")
    static let oneGrad:CGFloat = CGFloat(Double.pi) / 180
    static var activated = false
    static var actRound = 0
    static var allMandatoryWordsFounded = false
    static var countFoundedMandatoryWords = 0
    static var mandatoryWords = [MandatoryWord]()
    static var ownWords = [OwnWord]()
}



