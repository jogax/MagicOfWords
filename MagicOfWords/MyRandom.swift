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
    var random: GKARC4RandomSource?
    var forName = false
    var counts = 0
//    var gameNumber = 0
//    var gameNumber = 0
//    var stringTable = [String]()
    
    init(forName: Bool = false) {
        self.forName = forName
        counts = GV.playingRecord.randomCounts
        prepareRandom()
    }
    
    private func prepareRandom() {
        let gameData = (forName ? nameData : levelData).dataFromHexadecimalString()!
        random = GKARC4RandomSource(seed: gameData)
        let startValue = 1111 * (GV.playingRecord.gameNumber + 555)
        random!.dropValues(startValue)
        dropCounts()
    }
    
    private func dropCounts() {
        for _ in 0..<counts {
            _ = random!.nextInt()
        }
    }
    
    
    public func dropValues(value: Int) {
        for _ in 0..<value {
            _ = getRandomInt(0, max: 1)
        }
    }
    
    public func decrementCounts(value: Int) {
        let adder = value + 0
        counts -= (counts > adder ? adder : counts)
        try! realm.write() {
            GV.playingRecord.randomCounts = counts
        }
        prepareRandom()
    }
    
    public func getRandomInt(_ min: Int, max: Int) -> Int {
        counts += 1
        try! realm.write() {
            GV.playingRecord.randomCounts = counts
        }
        let returnValue = min + random!.nextInt(upperBound: (max + 1 - min))
//        let returnValue = min + abs(random!.nextInt()) % (max + 1 - min)
       return returnValue
    }
    
    
    private var levelData = "5ff5310cc41380bf720ce9238f984730"
    
    private var nameData = "c43d64fe101c1051f58927cd68717bf9"
//        2:"119db944bcf1fd22d64e5758fb1d70b3",
//        3:"61d4430034ac9a4aee4c4d7630736664",
//        4:"2753d55686501e3468bf2a0e29c59de4",
//        5:"82bd26db5190373a5dfb9042dceceb52",
//        6:"3b341d1122c7003f1d5369f31ea75dfa",
//        7:"22de5a0c83eb696fa6c134e14f9c2f41",
//        8:"50e40b23e3d82733e3ee8903a00ca7a4",
//        9:"7c5ad945f2127550dd7f3537a25f0d4f",
    
}
