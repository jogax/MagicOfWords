//
//  ModifiedWords.swift
//  MagicOfWords
//
//  Created by Jozsef Romhanyi on 19/02/2019.
//Copyright © 2019 Jozsef Romhanyi. All rights reserved.
//

import Foundation
import RealmSwift

class ModifiedWordsModel: Object {
    
    @objc dynamic var combinedKey = ""
    @objc dynamic var owner: PlayerActivity?
    @objc dynamic var language = ""
    @objc dynamic var word = ""
    @objc dynamic var willDo = 0
    override  class func primaryKey() -> String {
        return "combinedKey"
    }
}


