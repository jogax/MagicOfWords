//
//  MandatoryWordsModel.swift
//  MagicOfWords
//
//  Created by Jozsef Romhanyi on 01/06/2018.
//  Copyright © 2018 Jozsef Romhanyi. All rights reserved.
//


import Foundation
import RealmSwift

class MandatoryModel: Object {
//    @objc dynamic var gameType = 0
    @objc dynamic var gameNumber = 0
    @objc dynamic var language = ""
    @objc dynamic var mandatoryWords = ""
    override  class func primaryKey() -> String {
        return "gameNumber"
    }
    
    
}

