//
//  WordListModel.swift
//  Szómágia
//
//  Created by Jozsef Romhanyi on 04/02/2018.
//Copyright © 2018 Jozsef Romhanyi. All rights reserved.
//

import Foundation
import RealmSwift

class WordListModel: Object {
        @objc dynamic var word = ""
        override  class func primaryKey() -> String {
            return "word"
        }
        
        
}

