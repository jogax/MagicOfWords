//
//  ScoreInfoForDifficulty.swift
//  MagicOfWords
//
//  Created by Jozsef Romhanyi on 30/07/2019.
//  Copyright © 2019 Jozsef Romhanyi. All rights reserved.
//

import Foundation
import RealmSwift

class ScoreInfoForDifficulty: Object {
    @objc dynamic var difficulty = 0
    @objc dynamic var bestScore = 0
    @objc dynamic var bestPlayerName = ""
    @objc dynamic var myRank = 0
    @objc dynamic var myScore = 0
}

