//
//  GenerateGameData.swift
//  MagicOfWords
//
//  Created by Jozsef Romhanyi on 07/02/2018.
//  Copyright © 2018 Jozsef Romhanyi. All rights reserved.
//

import Foundation
import RealmSwift
import GameplayKit

class GenerateGameData {
    var myWords: [String] = []
    var myLines: [String] = []
    var wordsPointer = 0
    var maxWordsPointer = 0
    init() {
        readRecordsAndCalculateCount()
        realm.beginWrite()
        let recordsToDelete = realm.objects(WordListModel.self)
        realm.delete(recordsToDelete)
        try! realm.commitWrite()

        importWords()
        createGameData()
    }
    
    func readRecordsAndCalculateCount() {
        let language = GV.language.getText(.tcAktLanguage)
        let wordFileURL = Bundle.main.path(forResource: "\(language)Words", ofType: "txt")
        // Read from the file Words
        var wordsFile = ""
        var gameDataFile = ""
        do {
            wordsFile = try String(contentsOfFile: wordFileURL!, encoding: String.Encoding.utf8)
        } catch let error as NSError {
            print("Failed reading from URL: \(String(describing: wordFileURL)), Error: " + error.localizedDescription)
        }
        myWords = wordsFile.components(separatedBy: .newlines)
        // Read from the GameData file
        let dataFileURL = Bundle.main.path(forResource: "\(language)GameData", ofType: "txt")
        do {
            gameDataFile = try String(contentsOfFile: dataFileURL!, encoding: String.Encoding.utf8)
        } catch let error as NSError {
            print("Failed reading from URL: \(String(describing: dataFileURL)), Error: " + error.localizedDescription)
        }
        myLines = gameDataFile.components(separatedBy: .newlines)
        var countLines = 0
        for line in myLines {
            if line != "" {
                let components = line.components(separatedBy: "/")
                let countGames = Int(components[1])!
                let countWords = components[2].components(separatedBy: "-").count
                countLines += countGames * countWords
            }
        }
        GV.maxRecordCount = myWords.count + countLines
        maxRecordCount = myWords.count
    }
    
    func createGameData() {
        realm.beginWrite()
        let recordsToDelete = realm.objects(GameDataModel.self)
        realm.delete(recordsToDelete)
        try! realm.commitWrite()
        
        var minGameNumber = 0
        for line in myLines {
            print(line)
            let components = line.components(separatedBy: "/")
            if components.count == 3 {
                let gameType = Int(components[0])!
                let maxGameNumber = Int(components[1])!
                for gameNumber in (minGameNumber + 1)...maxGameNumber {
                    let random = MyRandom(gameType: gameType, gameNumber: gameNumber)
                    let wordLengths = components[2].components(separatedBy: "-")
                    for wordLength in wordLengths {
                        let words = realm.objects(WordListModel.self).filter("length = %d", Int(wordLength)!)
                        var word = ""
                        repeat {
                            let wordIndex = random.getRandomInt(0, max: words.count - 1)
                            word = words[wordIndex].word
                        } while realm.objects(GameDataModel.self).filter("word == %@", word).count != 0
                        realm.beginWrite()
                        let gameData = GameDataModel()
                        gameData.gameType = gameType
                        gameData.gameNumber = gameNumber
                        gameData.word = word
                        print("gameNumber: \(gameNumber), word: \(word)")
                        realm.add(gameData)
                        try! realm.commitWrite()
                        minGameNumber = gameNumber
                    }
                    print("=====================")
                }
            }
        }

    }
    @objc func importWords() {
        // File location
        print("\(String(describing: Realm.Configuration.defaultConfiguration.fileURL))")
        if realm.objects(WordListModel.self).count > 0 {
            return
        }
        for word in myWords {
            if realm.objects(WordListModel.self).filter("word = '\(word)'").count == 0 {
                realm.beginWrite()
                let wordListModel = WordListModel()
                wordListModel.length = word.count
                wordListModel.word = word
                realm.add(wordListModel)
                try! realm.commitWrite()
                GV.actRecordCount = realm.objects(WordListModel.self).count
                //GV.loadingScene!.showProgress()
            }
        }
    }

}


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


