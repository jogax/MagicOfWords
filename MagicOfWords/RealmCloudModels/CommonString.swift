//
//  CommonString.swift
//  MagicOfWords
//
//  Created by Jozsef Romhanyi on 23/12/2018.
//Copyright © 2018 Jozsef Romhanyi. All rights reserved.
//

import Foundation
import RealmSwift

class CommonString: Object {
// hier are all things:
    // 1. mandatory words for generating:
    // structure: language + word
    @objc dynamic var word: String = ""
    override static func primaryKey() -> String? {
        return "word"
    }
}
