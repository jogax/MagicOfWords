//
//  WordDBGenerator.swift
//  MagicOfWords
//
//  Created by Jozsef Romhanyi on 31/05/2018.
//  Copyright © 2018 Jozsef Romhanyi. All rights reserved.
//

import Foundation
import RealmSwift

class WordDBGenerator {
    
    init(mandatory: Bool) {
        if mandatory {
            generateMandatoryWords(language: "en")
            generateMandatoryWords(language: "de")
            generateMandatoryWords(language: "hu")
            generateMandatoryWords(language: "ru")
        } else {
            generateWordList(language: "en")
            generateWordList(language: "de")
            generateWordList(language: "hu")
            generateWordList(language: "ru")
        }
    }
    
    private func generateWordList(language: String) {
        let wordFileURL = Bundle.main.path(forResource: "\(language)Words", ofType: "txt")
        // Read from the file Words
        var wordsFile = ""
        do {
            wordsFile = try String(contentsOfFile: wordFileURL!, encoding: String.Encoding.utf8)
        } catch let error as NSError {
            print("Failed reading from URL: \(String(describing: wordFileURL)), Error: " + error.localizedDescription)
        }
        let wordList = wordsFile.components(separatedBy: .newlines)
        for word in wordList {
            let wordModel = WordListModel()
            wordModel.word = language + word
            realm.beginWrite()
            realm.add(wordModel)
            try! realm.commitWrite()
        }
    }
    
    private func generateMandatoryWords(language: String) {
        let dataFileURL = Bundle.main.path(forResource: language + "GameData", ofType: "txt")
        var gameDataFile = ""
        do {
            gameDataFile = try String(contentsOfFile: dataFileURL!, encoding: String.Encoding.utf8)
        } catch let error as NSError {
            print("Failed reading from URL: \(String(describing: dataFileURL)), Error: " + error.localizedDescription)
        }
        let myLines = gameDataFile.components(separatedBy: .newlines)
        for line in myLines {
            let myItems = line.components(separatedBy: "/")
            if myItems.count == 3 {
//                let gameType = myItems[0]
                let gameNumber = myItems[1]
                let myWords = myItems[2].components(separatedBy: itemSeparator)
                let maxIndex = 6
                var index = 0
                var lineToSave = ""
                repeat {
                    lineToSave += myWords[index] + itemSeparator
                    index += 1
                } while index < maxIndex
                lineToSave.removeLast()
                let mandatoryModel = MandatoryModel()
                mandatoryModel.gameNumber = Int(gameNumber)! + GV.gameNumberAdder[language]!
                mandatoryModel.language = language
                mandatoryModel.mandatoryWords = lineToSave
                realm.beginWrite()
                realm.add(mandatoryModel)
                try! realm.commitWrite()
            }
        }
    }

}
