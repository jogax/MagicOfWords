//
//  WordsFromCloud.swift
//  MagicOfWords
//
//  Created by Romhanyi Jozsef on 2020. 01. 27..
//  Copyright © 2020. Jozsef Romhanyi. All rights reserved.
//

import Foundation
import RealmSwift



class WordsFromCloud: Object {
    @objc dynamic var word = ""
    @objc dynamic var timeStamp = Date()
    override  class func primaryKey() -> String {
        return "word"
    }
    

}
