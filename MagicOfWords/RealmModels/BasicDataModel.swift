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
    @objc dynamic var myName = ""
    @objc dynamic var myNickname = ""
    @objc dynamic var keyWord = ""
    @objc dynamic var difficulty = 0
    @objc dynamic var creationTime = Date()
    @objc dynamic var searchPhrase = ""
    @objc dynamic var showingRow = 0
    @objc dynamic var showingRows = ""
    @objc dynamic var buttonType = GV.ButtonTypeElite
    @objc dynamic var onlineTime = 0
    @objc dynamic var playingTime = 0
    @objc dynamic var playing = false
    @objc dynamic var choosedCountsForLanguage = ""
    @objc dynamic var notSaved = true
    override  class func primaryKey() -> String {
        return "ID"
    }
}
