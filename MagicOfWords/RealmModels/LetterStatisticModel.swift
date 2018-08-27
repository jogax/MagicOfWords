//
//  LetterStatisticModel.swift
//  MagicOfWords
//
//  Created by Jozsef Romhanyi on 27/08/2018.
//Copyright © 2018 Jozsef Romhanyi. All rights reserved.
//

import Foundation
import RealmSwift

class LetterStatisticModel: Object {
    
    @objc dynamic var primaryKey = ""
    @objc dynamic var language = ""
    @objc dynamic var letter = ""
    @objc dynamic var frequency = 0
    override  class func primaryKey() -> String {
        return "primaryKey"
    }

//  override static func ignoredProperties() -> [String] {
//    return []
//  }
}
