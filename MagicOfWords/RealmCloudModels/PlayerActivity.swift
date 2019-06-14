//
//  PlayerActivity.swift
//  MagicOfWords
//
//  Created by Jozsef Romhanyi on 13/09/2018.
//Copyright © 2018 Jozsef Romhanyi. All rights reserved.
//

import Foundation
import RealmSwift

class PlayerActivity: Object {
    
    // Specify properties to ignore (Realm won't persist these)
    @objc dynamic var name: String = UUID().uuidString
    @objc dynamic var nickName: String?
    @objc dynamic var keyWord: String?
    @objc dynamic var isOnline: Bool = false
    @objc dynamic var onlineSince: Date?
    @objc dynamic var onlineTime: Int = 0
    @objc dynamic var playingTime: Int = 0
    @objc dynamic var countOnlines: Int = 0
    @objc dynamic var creationTime: Date?
    @objc dynamic var territory: String?
    @objc dynamic var country: String?
    @objc dynamic var deviceType: String?
    @objc dynamic var expertUser: Bool = false
    @objc dynamic var maySaveInfos: Bool = false
    @objc dynamic var lastTouched: Date?
    @objc dynamic var myCommentar: String?
    @objc dynamic var version: String = ""

    override static func primaryKey() -> String? {
        return "name"
    }
    
    public func copy()->PlayerActivity {
        let new = PlayerActivity()
        new.name = self.name
        new.nickName = self.nickName
        new.keyWord = self.keyWord
        new.isOnline = self.isOnline
        new.onlineSince = self.onlineSince
        new.onlineTime = self.onlineTime
        new.playingTime = self.playingTime
        new.countOnlines = self.countOnlines
        new.creationTime = self.creationTime
        new.territory = self.territory
        new.country = self.country
        new.deviceType = self.deviceType
        new.expertUser = self.expertUser
        new.maySaveInfos = self.maySaveInfos
        new.lastTouched = self.lastTouched
        new.myCommentar = self.myCommentar
        new.version = self.version
        return new
    }

    //  override static func ignoredProperties() -> [String] {
    //    return []
    //  }
}
