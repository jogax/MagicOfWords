//
//  WordListTemp.swift
//  MagicOfWords
//
//  Created by Jozsef Romhanyi on 21/01/2019.
//Copyright © 2019 Jozsef Romhanyi. All rights reserved.
//

import Foundation
import RealmSwift

class WordListTemp: Object {
    @objc dynamic var word = ""
    override  class func primaryKey() -> String {
        return "word"
    }
    
    
}
