//
//  RoundDataModel.swift
//  MagicOfWords
//
//  Created by Jozsef Romhanyi on 10/05/2018.
//Copyright © 2018 Jozsef Romhanyi. All rights reserved.
//

import Foundation
import RealmSwift

class RoundDataModel: Object {
    
//    @objc dynamic var index = 0
    @objc dynamic var infos = ""
    @objc dynamic var activityItems = ""
    @objc dynamic var gameArray = ""
    @objc dynamic var roundScore = 0
}
