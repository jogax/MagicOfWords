//
//  ScoreInfoForLanguage.swift
//  MagicOfWords
//
//  Created by Jozsef Romhanyi on 30/07/2019.
//  Copyright © 2019 Jozsef Romhanyi. All rights reserved.
//

import Foundation
import RealmSwift

class ScoreInfoForLanguage: Object {
    @objc dynamic var language = 0
    let difficultyInfos = List<ScoreInfoForDifficulty>()
}
