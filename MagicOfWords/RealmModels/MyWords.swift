//
//  MyWords.swift
//  MagicOfWords
//
//  Created by Jozsef Romhanyi on 30/08/2019.
//Copyright © 2019 Jozsef Romhanyi. All rights reserved.
//

import Foundation
import RealmSwift

class MyWords: Object {
    @objc dynamic var word = ""
    override  class func primaryKey() -> String {
        return "word"
    }
}
