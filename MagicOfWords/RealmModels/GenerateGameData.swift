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
    var myGeneratedWords: [String] = []
    var myLines: [String] = []
    var wordsPointer = 0
    var maxWordsPointer = 0
    var myLinesPointer = 0
    var maxLinesPointer = 0
    var minGameNumber = 0
    var wordLengthTable: [Int] = [4,4,4,4,4,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,7,7,7,7,7,8,9,10]
    var countWordsTable: [Int] = [6,6,7,7,8,8]
    enum WhatToDo: Int {
        case GenerateWordList = 0, GenerateGameData
    }
    var whatToDo = WhatToDo.GenerateWordList
//    var whatToDo = WhatToDo.GenerateGameData
    var timer = Timer()
    init() {
        let (wordListVersion, gameDataVersion) = readRecordsAndCalculateCount()
        let basicData = realm.objects(BasicDataModel.self)
        GV.gameType = 0
        GV.gameNumber = 0
//        if true {
        if basicData.count == 0 ||
            basicData.first!.actLanguage != GV.language.getText(.tcAktLanguage) ||
            basicData.first!.wordListVersion != wordListVersion  ||
            basicData.first!.gameDataVersion != gameDataVersion
            {
            // delete all records if new loading
            realm.beginWrite()
//                let wordListRecordsToDelete = realm.objects(WordListModel.self)
//                realm.delete(wordListRecordsToDelete)
                let gameDataRecordsToDelete = realm.objects(GameDataModel.self)
                realm.delete(gameDataRecordsToDelete)
                let basicDataRecord = realm.objects(BasicDataModel.self)
                if basicDataRecord.count == 0 {
                    let basicData = BasicDataModel()
                    basicData.actLanguage = GV.language.getText(.tcAktLanguage)
                    basicData.wordListVersion = wordListVersion
                    basicData.gameDataVersion = gameDataVersion
                    realm.add(basicData)
                    for gameType in 1..<GameType.NoMoreGames.rawValue {
                        let gameTypeRecord = GameTypeModel()
                        gameTypeRecord.gameType = gameType
                        gameTypeRecord.gameNumber = 1
                        realm.add(gameTypeRecord)
                    }
                } else {
                    basicDataRecord.first!.actLanguage = GV.language.getText(.tcAktLanguage)
                    basicDataRecord.first!.wordListVersion = wordListVersion
                    basicDataRecord.first!.gameDataVersion = gameDataVersion
                }
            try! realm.commitWrite()
            timer = Timer.scheduledTimer(timeInterval: 0.00001, target: self, selector: #selector(importWords(timerX:)), userInfo: nil, repeats: false)
        } else {
            GV.EndOfFileReached = true
        }
    }
    
    func readRecordsAndCalculateCount()->(String, String) {
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
//        myWords = wordsFile.components(separatedBy: .newlines).sorted(by: {$0 < $1})
        myWords = wordsFile.components(separatedBy: .newlines)
        let wordListVersion = myWords[0]
        myWords.remove(at: 0)

        // Read from the GameData file
        let dataFileURL = Bundle.main.path(forResource: GV.language.getText(.tcAktLanguage) + "GameData", ofType: "txt")
        do {
            gameDataFile = try String(contentsOfFile: dataFileURL!, encoding: String.Encoding.utf8)
        } catch let error as NSError {
            print("Failed reading from URL: \(String(describing: dataFileURL)), Error: " + error.localizedDescription)
        }
        myLines = gameDataFile.components(separatedBy: .newlines)
        let gameDataVersion = myLines[0]

        GV.maxRecordCount = myWords.count - 1 + myLines.count
        GV.actRecordCount = 0
        maxWordsPointer = myWords.count
        maxLinesPointer = myLines.count
        return (wordListVersion, gameDataVersion)
    }
    
    @objc func importWords(timerX: Timer) {
        // File location
        switch whatToDo {
        case .GenerateWordList:
            
            repeat {
                let word = myWords[wordsPointer]
                wordsPointer += 1
                if word.count > 0 {
                    GV.lastSavedWord = word
                    realm.beginWrite()
                    let wordListModel = WordListModel()
                    wordListModel.length = word.mySubString(startPos:word.count - 1) == exclamationMark ? word.count - 1 : word.count
                    wordListModel.word = word
                    realm.add(wordListModel)
                    try! realm.commitWrite()
                }
                GV.actRecordCount += 1 //realm.objects(WordListModel.self).count
                //GV.loadingScene!.showProgress()
            } while wordsPointer % 200 != 0 && wordsPointer < maxWordsPointer
            if wordsPointer == maxWordsPointer {
                whatToDo = .GenerateGameData
            }
            timer = Timer.scheduledTimer(timeInterval: 0.000001, target: self, selector: #selector(importWords(timerX: )), userInfo: nil, repeats: false)
        case .GenerateGameData:
            let line = myLines[myLinesPointer]
            myLinesPointer += 1
            let components = line.components(separatedBy: "/")
            if components.count == 3 {
                let gameType = Int(components[0])!
                let gameNumber = Int(components[1])!
                let words = components[2]
                realm.beginWrite()
                let gameData = GameDataModel()
                gameData.gameType = gameType
                gameData.gameNumber = gameNumber
                gameData.words = words
                realm.add(gameData)
                let wordTable = words.components(separatedBy: "°")
                GV.lastSavedWord = wordTable[0]
                try! realm.commitWrite()
            }

            GV.actRecordCount = realm.objects(WordListModel.self).count + realm.objects(GameDataModel.self).count
            if myLinesPointer == maxLinesPointer {
                timer.invalidate()
                GV.EndOfFileReached = true
            } else {
                timer = Timer.scheduledTimer(timeInterval: 0.000001, target: self, selector: #selector(importWords(timerX: )), userInfo: nil, repeats: false)
            }
        }
    }
}




