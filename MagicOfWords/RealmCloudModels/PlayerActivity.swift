////
////  PlayerActivity.swift
////  MagicOfWords
////
////  Created by Jozsef Romhanyi on 13/09/2018.
////Copyright © 2018 Jozsef Romhanyi. All rights reserved.
////
//
//import Foundation
//import RealmSwift
//
//class PlayerActivity: Object {
//    
//    // Specify properties to ignore (Realm won't persist these)
//    @objc dynamic var name: String = UUID().uuidString
//    @objc dynamic var nickName: String?
//    @objc dynamic var keyWord: String?
//    @objc dynamic var isOnline: Bool = false
//    @objc dynamic var onlineSince: Date?
//    @objc dynamic var onlineTime: Int = 0
//    @objc dynamic var playingTime: Int = 0
//    @objc dynamic var countOnlines: Int = 0
//    @objc dynamic var creationTime: Date?
//    @objc dynamic var territory: String?
//    @objc dynamic var country: String?
//    @objc dynamic var deviceType: String?
//    @objc dynamic var expertUser: Bool = false
//    @objc dynamic var maySaveInfos: Bool = false
//    @objc dynamic var lastTouched: Date?
//    @objc dynamic var myCommentar: String?
//    @objc dynamic var version: String = ""
//
//    override static func primaryKey() -> String? {
//        return "name"
//    }
//    
//    public func update(from: PlayerActivity) {
//        if self.name != from.name {
//            self.name = from.name
//        }
//        self.nickName = from.nickName
//        self.keyWord = from.keyWord
//        self.isOnline = from.isOnline
//        self.onlineSince = from.onlineSince
//        self.onlineTime = from.onlineTime
//        self.playingTime = from.playingTime
//        self.countOnlines = from.countOnlines
//        self.creationTime = from.creationTime
//        self.territory = from.territory
//        self.country = from.country
//        self.deviceType = from.deviceType
//        self.expertUser = from.expertUser
//        self.maySaveInfos = from.maySaveInfos
//        self.lastTouched = from.lastTouched
//        self.myCommentar = from.myCommentar
//        self.version = from.version
//    }
//
//    //  override static func ignoredProperties() -> [String] {
//    //    return []
//    //  }
//}
