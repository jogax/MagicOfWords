//
//  FinishedGames.swift
//  MagicOfWords
//
//  Created by Jozsef Romhanyi on 18/09/2019.
//  Copyright © 2019 Jozsef Romhanyi. All rights reserved.
//

import Foundation
import RealmSwift


class FinishedGames: Object {
    @objc dynamic var ID: String = String(describing:Date())
    @objc dynamic var language = ""
    @objc dynamic var difficulty = 0
    @objc dynamic var countFixedLetters = 0
    @objc dynamic var countWords = 0
    @objc dynamic var myScore = 0
    @objc dynamic var bestScore = 0
    @objc dynamic var bestPlayer = ""
    @objc dynamic var myPlace = 0
    override  class func primaryKey() -> String {
        return "ID"
    }
        
}


