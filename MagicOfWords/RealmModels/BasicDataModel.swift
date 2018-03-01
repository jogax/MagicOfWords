//
//  BasicDataModel.swift
//  MagicOfWords
//
//  Created by Jozsef Romhanyi on 13/02/2018.
//Copyright © 2018 Jozsef Romhanyi. All rights reserved.
//

import Foundation
import RealmSwift

class BasicDataModel: Object {
    @objc dynamic var ID = 0
    @objc dynamic var actLanguage = ""
    @objc dynamic var actVersion = ""
    @objc dynamic var gameType = 1
    override  class func primaryKey() -> String {
        return "ID"
    }
}