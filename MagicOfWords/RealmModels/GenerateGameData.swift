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
    var tilesForGame = [WTPiece]()
    var parentScene: SKScene

    enum WhatToDo: Int {
        case GenerateWordList = 0, GenerateGameData, Nothing
    }
    var whatToDo = WhatToDo.GenerateWordList
//    var whatToDo = WhatToDo.GenerateGameData
    var timer = Timer()
    init(parentScene: SKScene) {
        self.parentScene = parentScene
        let (wordListVersion, gameDataVersion) = readRecordsAndCalculateCount()
        let basicData = realm.objects(BasicDataModel.self)
        GV.gameType = 0
        GV.gameNumber = 0
        whatToDo = .Nothing
        if basicData.count == 0 ||
            basicData.first!.actLanguage != GV.language.getText(.tcAktLanguage) ||
            basicData.first!.wordListVersion != wordListVersion  ||
            basicData.first!.gameDataVersion != gameDataVersion
            {
                if basicData.count == 0 ||
                    basicData.first!.actLanguage != GV.language.getText(.tcAktLanguage) ||
                    basicData.first!.wordListVersion != wordListVersion {
                    whatToDo  = .GenerateWordList
                } else if basicData.first!.gameDataVersion != gameDataVersion {
                    whatToDo = .GenerateGameData
                }
        
            // delete all records if new loading
                realm.beginWrite()
                if whatToDo == .GenerateWordList {
                    let wordListRecordsToDelete = realm.objects(WordListModel.self)
                    realm.delete(wordListRecordsToDelete)
                    let gameDataRecordsToDelete = realm.objects(GameDataModel.self)
                    realm.delete(gameDataRecordsToDelete)
                } else if whatToDo == .GenerateGameData {
                    let gameDataRecordsToDelete = realm.objects(GameDataModel.self)
                    realm.delete(gameDataRecordsToDelete)
                }
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
                let word = myWords[wordsPointer].lowercased()
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
                gameData.mandatoryWords = words
                let wordTable = words.components(separatedBy: "°")
//                gameData.pieces = generateArrayOfWordPieces(gameType: gameType, gameNumber: gameNumber, words: wordTable)
                realm.add(gameData)
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
        case .Nothing:
            break
        }
    }
    
//    private func generateArrayOfWordPieces(gameType: Int, gameNumber: Int, words: [String])->String {
//        let blockSize = parentScene.frame.size.width * (GV.onIpad ? 0.70 : 0.90) / CGFloat(12)
//        let random = MyRandom(gameType: gameType, gameNumber: gameNumber)
//        func getLetters( from: inout [String], archiv: inout [String])->[String] {
//
//            if from.count == 0 {
//                for item in archiv {
//                    from.append(item)
//                }
//                archiv.removeAll()
//            }
//            let index = random.getRandomInt(0, max: from.count - 1)
//            let temp = from[index]
//            var piece = [String]()
//            piece.append(temp.subString(startPos:0, length: 1))
//            if temp.count == 2 {
//                piece.append(temp.subString(startPos:1, length: 1))
//            }
//            archiv.append(temp)
//            from.remove(at: index)
//            return piece
//        }
//        tilesForGame.removeAll()
//        var oneLetterPieces = [String]()
//        var oneLetterPiecesArchiv = [String]()
//        var twoLetterPieces = [String]()
//        var twoLetterPiecesArchiv = [String]()
//        for word in words {
//            for letter in word {
//                oneLetterPieces.append(String(letter))
//            }
//            for index in 0..<word.count - 1 {
//                twoLetterPieces.append(word.subString(startPos: index, length: 2))
//            }
//        }
//        var typesWithLen1 = [MyShapes]()
//        var typesWithLen2 = [MyShapes]()
//        var typesWithLen3 = [MyShapes]()
//        var typesWithLen4 = [MyShapes]()
//
//        for index in 0..<MyShapes.count - 1 {
//            guard let type = MyShapes(rawValue: index) else {
//                return ""
//            }
//            let length = myForms[type]![0].count
//            switch length {
//            case 1: typesWithLen1.append(type)
//            case 2: typesWithLen2.append(type)
//            case 3: typesWithLen3.append(type)
//            case 4: typesWithLen4.append(type)
//            default: break
//            }
//        }
//        let lengths = [1,1,1,1,2,2,2,3,3,4]
//        var generateLength = 0
//        repeat {
//            let tileLength = lengths[random.getRandomInt(0, max: lengths.count - 1)]
//            var tileType = MyShapes.NotUsed
//            var letters = [String]()
//            switch tileLength {
//            case 1: tileType = typesWithLen1[0]
//            letters += getLetters(from: &oneLetterPieces, archiv: &oneLetterPiecesArchiv)
//            case 2: tileType = typesWithLen2[0]
//            letters += getLetters(from: &twoLetterPieces, archiv: &twoLetterPiecesArchiv)
//            case 3: tileType = typesWithLen3[random.getRandomInt(0, max: typesWithLen3.count - 1)]
//            letters += getLetters(from: &twoLetterPieces, archiv: &twoLetterPiecesArchiv)
//            letters += getLetters(from: &oneLetterPieces, archiv: &oneLetterPiecesArchiv)
//            case 4: tileType = typesWithLen4[random.getRandomInt(0, max: typesWithLen4.count - 1)]
//            letters += getLetters(from: &twoLetterPieces, archiv: &twoLetterPiecesArchiv)
//            letters += getLetters(from: &twoLetterPieces, archiv: &twoLetterPiecesArchiv)
//            default: break
//            }
//            let rotateIndex = random.getRandomInt(0, max: 3)
//
//            //            let tileForGameItem = TilesForGame(type: tileType, rotateIndex: rotateIndex, letters: letters)
//            let tileForGameItem = WTPiece(type: tileType, rotateIndex: rotateIndex, parent: parentScene, blockSize: blockSize, letters: letters)
//            tilesForGame.append(tileForGameItem)
//            generateLength += tileLength
//        } while generateLength < 500
//        var generatedArrayInStringForm = ""
//        for tile in tilesForGame {
//            generatedArrayInStringForm += tile.toString() + "°"
//        }
//        return generatedArrayInStringForm
//    }
//
}




