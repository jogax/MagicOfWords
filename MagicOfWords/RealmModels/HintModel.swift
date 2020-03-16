//
//  HintModel.swift
//  MagicOfWords
//
//  Created by Romhanyi Jozsef on 2020. 03. 16..
//  Copyright © 2020. Jozsef Romhanyi. All rights reserved.
//


import Foundation
import RealmSwift

class HintModel: Object {
    @objc dynamic var languageWord = ""
    @objc dynamic var language = ""
    @objc dynamic var word = ""
    override  class func primaryKey() -> String {
        return "languageWord"
    }
}

//  override static func ignoredProperties() -> [String] {
//    return []
//  }
