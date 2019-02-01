//
//  Mandatory.swift
//  MagicOfWords
//
//  Created by Jozsef Romhanyi on 15/01/2019.
//Copyright © 2019 Jozsef Romhanyi. All rights reserved.
//

import Foundation
import RealmSwift

class Mandatory: Object {
    // hier are all things:
    // 1. mandatory words for generating:
    // structure: language + word
    @objc dynamic var combinedKey = ""
    @objc dynamic var gameNumber = 0
    @objc dynamic var language = ""
    @objc dynamic var mandatoryWords = ""
    @objc dynamic var change = false
    override  class func primaryKey() -> String {
        return "combinedKey"
    }
}
