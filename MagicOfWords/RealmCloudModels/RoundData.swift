//
//  RoundData.swift
//  MagicOfWords
//
//  Created by Jozsef Romhanyi on 21/03/2019.
//  Copyright © 2019 Jozsef Romhanyi. All rights reserved.
//

import Foundation
import RealmSwift

class RoundData: Object {
    
    //    @objc dynamic var index = 0
    @objc dynamic var infos = ""
    @objc dynamic var activityItems = ""
    @objc dynamic var gameArray = ""
    @objc dynamic var roundScore = 0
}
