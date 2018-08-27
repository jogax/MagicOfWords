//
//  WordDBGenerator.swift
//  MagicOfWords
//
//  Created by Jozsef Romhanyi on 31/05/2018.
//  Copyright © 2018 Jozsef Romhanyi. All rights reserved.
//
#if GENERATEWORDLIST || GENERATEMANDATORY || GENERATELETTERFREQUENCY
import Foundation
import RealmSwift

#if GENERATEWORDLIST
// for Generating WordList DB
    let defaultConfig = Realm.Configuration(
        objectTypes: [WordListModel.self])
#endif
#if GENERATEMANDATORY
// for generating Mandatory Words
let defaultConfig = Realm.Configuration(
    objectTypes: [MandatoryModel.self])
#endif
#if GENERATELETTERFREQUENCY
// for Generating WordList DB
let defaultConfig = Realm.Configuration(
    objectTypes: [LetterStatisticModel.self])
#endif


var realm: Realm = try! Realm(configuration: defaultConfig)

class WordDBGenerator {
    
    init(mandatory: Bool = false, letterFrequency: Bool = false) {
        if letterFrequency {
            generateLetterFrequency(language: "en")
            generateLetterFrequency(language: "de")
            generateLetterFrequency(language: "hu")
            generateLetterFrequency(language: "ru")
        } else {
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
    }
    
    private func generateLetterFrequency(language: String) {
        var letters = [String: Int]()
        let words = realmWordList.objects(WordListModel.self).filter("word BEGINSWITH %@", language)
        for word in words {
            for letter in word.word {
                if letters[String(letter)] != nil {
                    letters[String(letter)]! += 1
                } else {
                    letters[String(letter)] = 1
                }
            }
        }
        var maxFreq = 0
        for (_, frequency) in letters {
            maxFreq = (maxFreq < frequency ? frequency : maxFreq)
        }
        if maxFreq > 100000 {
            maxFreq /= 1000
        }
        var primaryKey = -1
       for (letter, frequency) in letters {
            let model = LetterStatisticModel()
            primaryKey += 1
            model.primaryKey = language + String(primaryKey)
            model.language = language
            model.letter = letter
            model.frequency = frequency / 1000
            try! realm.write {
                realm.add(model)
            }
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
            wordModel.word = (language + word).lowercased()
            try! realm.write {
                realm.add(wordModel)
            }
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
                try! realm.write {
                    realm.add(mandatoryModel)
                }
            }
        }
    }

}
#endif
