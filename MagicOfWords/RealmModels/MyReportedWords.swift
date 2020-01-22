//
//  MyReportedWords.swift
//  MagicOfWords
//
//  Created by Romhanyi Jozsef on 2020. 01. 22..
//  Copyright © 2020. Jozsef Romhanyi. All rights reserved.
//

import Foundation
//
//  BasicDataModel.swift
//  MagicOfWords
//
//  Created by Jozsef Romhanyi on 13/02/2018.
//Copyright © 2018 Jozsef Romhanyi. All rights reserved.
//

import Foundation
import RealmSwift



class MyReportedWords: Object {
    @objc dynamic var ID = ""  // this ID is in the cloud, too
    @objc dynamic var word = ""
    @objc dynamic var bonus = 0
    @objc dynamic var status = ""
    
    override  class func primaryKey() -> String {
        return "ID"
    }
    

}
