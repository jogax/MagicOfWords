//
//  MyReportedWords.swift
//  MagicOfWords
//
//  Created by Romhanyi Jozsef on 2020. 01. 22..
//  Copyright © 2020. Jozsef Romhanyi. All rights reserved.
//

import Foundation
import RealmSwift



class MyReportedWords: Object {
    @objc dynamic var ID = ""  // this ID is in the cloud, too
    @objc dynamic var word = ""
    @objc dynamic var bonus = 0
    @objc dynamic var status = ""
    @objc dynamic var counter = 0
    @objc dynamic var modifiedAt = Date()
    
    override  class func primaryKey() -> String {
        return "ID"
    }
    

}
