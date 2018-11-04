//
//  MyRandom.swift
//  MagicOfWords
//
//  Created by Jozsef Romhanyi on 15/02/2018.
//  Copyright © 2018 Jozsef Romhanyi. All rights reserved.
//

import Foundation
import GameplayKit

class MyRandom {
//    private var index = 0
    var random: GKARC4RandomSource
//    var gameNumber = 0
//    var stringTable = [String]()
    
    init(gameNumber: Int) {
        
        let gameData = levelData.dataFromHexadecimalString()!
        random = GKARC4RandomSource(seed: gameData)
        random.dropValues(2048 + 1111 * gameNumber)
//        self.gameNumber = gameNumber % 10000
//        index = 7 * self.gameNumber
    }
    
    func getRandomInt(_ min: Int, max: Int) -> Int {
        let returnValue = min + random.nextInt(upperBound: (max + 1 - min))
//        let returnValue = min + intValue[index] % (max + 1 - min)
//        index += 11 * gameNumber
//        if index >= intValue.count {
//            index = index % intValue.count
//        }
//        print("returnValue: \(returnValue)")
        return returnValue
    }
    
//    func generateRandomInts() {
//        var stringValue = ""
//        
//        for index in 0..<25000 {
//            if index % 25 == 0 {
//                if stringValue != "" {
//                    stringTable.append(stringValue)
//                    stringValue = ""
//                }
//            }
//            let intValue = random.nextInt(upperBound: 1000)
//            stringValue += ("\(intValue),")
//        }
//        print(stringTable)
//        print("\(value)")
//    }
    
    private var levelData = "5ff5310cc41380bf720ce9238f984730"
//        1:"c43d64fe101c1051f58927cd68717bf9",
//        2:"119db944bcf1fd22d64e5758fb1d70b3",
//        3:"61d4430034ac9a4aee4c4d7630736664",
//        4:"2753d55686501e3468bf2a0e29c59de4",
//        5:"82bd26db5190373a5dfb9042dceceb52",
//        6:"3b341d1122c7003f1d5369f31ea75dfa",
//        7:"22de5a0c83eb696fa6c134e14f9c2f41",
//        8:"50e40b23e3d82733e3ee8903a00ca7a4",
//        9:"7c5ad945f2127550dd7f3537a25f0d4f",
    
}
