//
//  WordDBGenerator.swift
//  MagicOfWords
//
//  Created by Jozsef Romhanyi on 31/05/2018.
//  Copyright © 2018 Jozsef Romhanyi. All rights reserved.
//
#if GENERATEWORDLIST || GENERATEMANDATORY || GENERATELETTERFREQUENCY || CREATEMANDATORY || CREATEWORDLIST
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

#if CREATEMANDATORY
// for generating Mandatory Words
let defaultConfig = Realm.Configuration(
    objectTypes: [MandatoryModel.self])
#endif

#if CREATEWORDLIST
// for generating Mandatory Words
let defaultConfig = Realm.Configuration(
    objectTypes: [WordListModel.self])
#endif



var realm: Realm = try! Realm(configuration: defaultConfig)

class WordDBGenerator {
    
    init(mandatory: Bool = false, create: Bool = false) {
        if create && mandatory {
            generatingMandatoryWords(language: "en")
            generatingMandatoryWords(language: "de")
            generatingMandatoryWords(language: "hu")
            generatingMandatoryWords(language: "ru")
        } else if create && !mandatory {
            generatingWordList(language: "en")
            generatingWordList(language: "de")
            generatingWordList(language: "hu")
            generatingWordList(language: "ru")

        } else if mandatory {
            generateMandatoryWords(language: "en")
            generateMandatoryWords(language: "de")
            generateMandatoryWords(language: "hu")
            generateMandatoryWords(language: "ru")
        } else {
            print("Start")
            generateWordList(language: "de")
            print("DE ready")
            generateWordList(language: "en")
            print("EN ready")
            generateWordList(language: "hu")
            print("HU ready")
            generateWordList(language: "ru")
            print("RU ready")
        }
    }

    var letters = [String: Int]()
    var countLetters = 0
    var primaryKey = -1

    private func generateWordList(language: String) {
        let notDELanguage = language != GV.language.getText(.tcGermanShort)
        countLetters = 0
        letters = [String: Int]()
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
            let charset = CharacterSet(charactersIn: "-!") // words with "-", "!" are not computed
            if word.rangeOfCharacter(from: charset) == nil {
                if notDELanguage || word.subString(startPos: 0, length: 1).uppercased() == word.subString(startPos: 0, length: 1) {
                    generateLetterFrequency(language: language, word: word.lowercased())
                    let wordModel = WordListModel()
                    wordModel.word = (language + word).lowercased()
                    if realm.objects(WordListModel.self).filter("word = %d", wordModel.word).count == 0 {
                        try! realm.write {
                            realm.add(wordModel)
                        }
                    }
                }
            }
        }
        saveLetterFrequency(language: language)
        
    }
    
    private func generateLetterFrequency(language: String, word: String) {
        countLetters += word.length
        for letter in word {
            if letters[String(letter)] != nil {
                letters[String(letter)]! += 1
            } else {
                letters[String(letter)] = 1
            }
        }
    }
    
    private func saveLetterFrequency(language: String) {
        for (letter, frequency) in letters {
            let frequencyInProcent = (Double(100) * Double(frequency) / Double(countLetters)).twoDecimals
            let frString = String(round(frequencyInProcent))
            let wordModel = WordListModel()
            wordModel.word = language + GV.frequencyString + itemSeparator + letter + itemSeparator + frString
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
                mandatoryModel.combinedKey = language + gameNumber
                mandatoryModel.gameNumber = Int(gameNumber)!
                mandatoryModel.language = language
                mandatoryModel.mandatoryWords = lineToSave
                try! realm.write {
                    realm.add(mandatoryModel)
                }
            }
        }
    }
    
    func generatingMandatoryWords(language: String) {
        let words = realmWordList.objects(WordListModel.self).filter("word BEGINSWITH %@", language)
        let sortedWords =  Array(words).sorted(by: {$0.word.length < $1.word.length})
        var minIndex = 0
        var maxIndex = 0
        repeat {
            for index in 0..<sortedWords.count {
                if minIndex == 0 && sortedWords[index].word.length == 7 {
                    minIndex = index
                }
                if minIndex != 0 && sortedWords[index].word.length < 14 {
                    maxIndex = index
                }
            }
        } while maxIndex == 0
        var wordTable = [String]()
        var wordsToPrint = [String]()
        let random = MyRandom(gameNumber: 0)
        repeat {
            let wordIndex = random.getRandomInt(minIndex, max: maxIndex)
            let word = sortedWords[wordIndex]
            let wLength = word.word.length
            let search = word.word.subString(startPos: 2, length: wLength - 2)
            if let _ = wordTable.index(where: { $0 == search }) {
                
            } else {
                wordTable.append(word.word.subString(startPos: 2, length: wLength - 2))
            }
        } while wordTable.count < 10000
        var index = 0
        for gameNumber in 0...999 {
            var text = ""
            for _ in 0...7 {
                text += wordTable[index] + "°"
                index += 1
            }
            text.removeLast()
            let mandatoryRecord = MandatoryModel()
            let combinedKey:String = language + String(gameNumber)
            mandatoryRecord.combinedKey = combinedKey
            mandatoryRecord.gameNumber = gameNumber
            mandatoryRecord.language = language
            mandatoryRecord.mandatoryWords = text
            try! realm.write() {
                realm.add(mandatoryRecord)
            }
            wordsToPrint.append(text)
        }
        
        print(wordsToPrint)
    }
    func generatingWordList(language: String) {
        let words = realmWordList.objects(WordListModel.self).filter("word BEGINSWITH %@", language)
        let sortedWords =  Array(words).sorted(by: {$0.word < $1.word})
        var wordsToPrint = [String]()
        for word in sortedWords {
            try! realm.write() {
                let wordListRecord = WordListModel()
                wordListRecord.word = word.word
                realm.add(wordListRecord)
            }
//            wordsToPrint.append(word.word)
        }
//        print(wordsToPrint)
    }


}
#endif
