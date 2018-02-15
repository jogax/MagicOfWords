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
    var random: GKARC4RandomSource
    init(gameType: Int, gameNumber: Int) {
        
        let gameData = levelDataArray[gameType]!.dataFromHexadecimalString()!
        random = GKARC4RandomSource(seed: gameData)
        random.dropValues(2048 + 1000 * gameNumber)
    }
    
    func getRandomInt(_ min: Int, max: Int) -> Int {
        return min + random.nextInt(upperBound: (max + 1 - min))
    }
    
    private var levelDataArray = [
        0:"5ff5310cc41380bf720ce9238f984730",
        1:"c43d64fe101c1051f58927cd68717bf9",
        2:"119db944bcf1fd22d64e5758fb1d70b3",
        3:"61d4430034ac9a4aee4c4d7630736664",
        4:"2753d55686501e3468bf2a0e29c59de4",
        5:"82bd26db5190373a5dfb9042dceceb52",
        6:"3b341d1122c7003f1d5369f31ea75dfa",
        7:"22de5a0c83eb696fa6c134e14f9c2f41",
        8:"50e40b23e3d82733e3ee8903a00ca7a4",
        9:"7c5ad945f2127550dd7f3537a25f0d4f",
        ]
    
}

