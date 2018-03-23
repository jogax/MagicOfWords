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

enum GameType: Int {
    case WordTris = 1, SearchWords, NoMoreGames
}
let NoValue = -1
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
}



