//
//  HintEngine.swift
//  MagicOfWords
//
//  Created by Romhanyi Jozsef on 2020. 03. 06..
//  Copyright © 2020. Jozsef Romhanyi. All rights reserved.
//

import Foundation
import RealmSwift

class HintEngine {
    public class var shared: HintEngine {
        struct Static {
            static let instance = HintEngine()
        }
        return Static.instance
    }
    init() {
        
    }
    
    private func getAllWords()->[Results<HintModel>] {
        var returnValue = [Results<HintModel>]()
        let formatString = "language = %@ AND word Like %@"
        let likes = ["????", "?????", "??????", "???????", "????????", "?????????", "??????????"]
        for like in likes {
            let results = realmMandatoryList.objects(HintModel.self).filter(formatString, GV.actLanguage, like)
            returnValue.append(results)
        }

        return returnValue
    }
    
    private func find(value searchValue: String, inArray: [UsedLetterWithCounter]) -> Int?
    {
//        var returnValue = 0
        for (index, value) in inArray.enumerated()
        {
            if value.letter == searchValue && value.freeCount > 0 {
                return index
            }
        }
        return nil
    }

    var redLetters = [String]()
    var fixLetters = [UsedLetterWithCounter]()
    var freeGreenLetters = [UsedLetterWithCounter]()
    var freeArrays = [FreeArray]()
    var results = [Results<HintModel>]()
    var maxWordLength = 0
    let maxCountWords = 10
    var searchWord = ""
    var OKWords = [String]()

    private func findWordsWithOneFixletter() {
        let startTime = Date()
        var interval = 0.0
        OKWords = [String]()
        for myIndex in 0..<results.count {
            let resultIndex = results.count - 1 - myIndex
            if maxWordLength < results[resultIndex].first!.word.length {
                continue
            }
            let fillLength = results[resultIndex].first!.word.length
            for fixLetter1 in fixLetters {
                if fixLetter1.freeCount == 0 {
                    continue
                }
                searchWord = "".fill(with: "?", toLength: fillLength)
                searchWord = searchWord.changeChars(at: 0, to: fixLetter1.letter)
    //                -----------------------------------------------
                let tippWordsResults = results[resultIndex].filter("word like %@", searchWord.lowercased())
                if tippWordsResults.count > 0 {
                    for foundedWord in tippWordsResults {
                        let word = foundedWord.word
                        var temporaryRedLetters = [(letter:String, index:Int)]()
                        var wordOK = true
                        for letterIndex in 0..<word.length {
                            if searchWord.char(at: letterIndex) == "?" {
                                if !(redLetters.contains(word.char(at: letterIndex).uppercased())) {
                                    wordOK = false
                                    break
                                } else {
                                    let letter = word.char(at: letterIndex).uppercased()
                                    temporaryRedLetters.append((letter, letterIndex))
                                    let index = redLetters.firstIndex(of: String(letter))
                                    if index != nil {
                                        redLetters.remove(at: index!)
                                    }
                                }
                            }
                        }
//                        for temporaryLetter in temporaryRedLetters {
//                            redLetters.append(temporaryLetter.letter)
//                        }
                        if wordOK {
                            if !OKWords.contains(word) {
                                OKWords.append(word)
                            }
                            break
                        }
                    }
                }
                if OKWords.count >= maxCountWords {
                    break
                }
                interval = Date().timeIntervalSince(startTime)
                if interval > 0.25 {
                    break
                }

            }
            for word in OKWords {
                let uppercasedWord = word.uppercased()
                if !WTGameWordList.shared.roundContainsWord(word: uppercasedWord) && !GV.hintTable.contains(uppercasedWord) {
                    GV.hintTable.append(uppercasedWord)
                }
            }
            if interval > 0.25 {
                break
            }
            OKWords.removeAll()
        }
    }
    
    private func findWordsWithTwoFixLetters() {
        let startTime = Date()
        OKWords = [String]()
        func lettersInTheSameFreeArea(letter1: UsedLetterWithCounter, letter2: UsedLetterWithCounter)->Bool {
            var letter1InArray = 1000
            var letter2InArray = 1001
            for array in freeArrays {
                for freePlace in array.freePlaces {
                    if (freePlace.col == letter1.col && (freePlace.row == letter1.row - 1 || freePlace.row == letter1.row + 1)) ||
                        (freePlace.row == letter1.row && (freePlace.col == letter1.col - 1 || freePlace.col == letter1.col + 1)) {
                        letter1InArray = array.numberOfFreeArray
                        break
                    }
                }
                for freePlace in array.freePlaces {
                    if (freePlace.col == letter2.col && (freePlace.row == letter2.row - 1 || freePlace.row == letter2.row + 1)) ||
                        (freePlace.row == letter2.row && (freePlace.col == letter2.col - 1 || freePlace.col == letter2.col + 1)) {
                        letter2InArray = array.numberOfFreeArray
                        break
                    }
                }
            }
            return letter1InArray == letter2InArray
        }
        for myIndex in 0..<results.count {
            let resultIndex = results.count - 1 - myIndex
            if maxWordLength < results[resultIndex].first!.word.length {
                continue
            }
            let fillLength = results[resultIndex].first!.word.length
            for fixLetter1 in fixLetters {
                if fixLetter1.freeCount == 0 {
                    continue
                }
            //                -----------------------------------------------
                for fixLetter2 in fixLetters {
                    if fixLetter2.freeCount == 0 {
                        continue
                    }
                    searchWord = "".fill(with: "?", toLength: fillLength)
                    if lettersInTheSameFreeArea(letter1: fixLetter1, letter2: fixLetter2) {
                        if fixLetter1 != fixLetter2 {
                            let distance = fixLetter1.freeDistance(to: fixLetter2)
                            if  distance > 0 && distance  <= fillLength - 2 {
                                searchWord = searchWord.changeChars(at: 0, to: fixLetter1.letter)
                                searchWord = searchWord.changeChars(at: distance + 1, to: fixLetter2.letter).lowercased()
                                let tippWordsResults = results[resultIndex].filter("word like %@", searchWord)
                                if tippWordsResults.count > 0 {
                                    for foundedWord in tippWordsResults {
                                        let word = foundedWord.word
                                        var temporaryRedLetters = [(letter:String, index:Int)]()
                                        var wordOK = true
                                        for letterIndex in 0..<word.length - 1 {
                                            if searchWord.char(at: letterIndex) == "?" {
                                                if !redLetters.contains(word.char(at: letterIndex).uppercased()) {
                                                    wordOK = false
                                                    break
                                                } else {
                                                    let letter = word.char(at: letterIndex)
                                                    temporaryRedLetters.append((letter.uppercased(), letterIndex))
                                                    let index = redLetters.firstIndex(of: String(letter))
                                                    if index != nil {
                                                        redLetters.remove(at: index!)
                                                    }
                                                }
                                            }
                                        }
                                        if wordOK {
                                            if !OKWords.contains(foundedWord.word) {
                                                OKWords.append(foundedWord.word)
                                            }
//                                            for temporaryLetter in temporaryRedLetters {
//                                                redLetters.append(temporaryLetter.letter)
//                                            }
                                            break
                                        }

                                    }
                                }
                                searchWord = "".fill(with: "?", toLength: fillLength)
                            }
                        }
                    }
                }
                let actTime = Date()
                let interval = actTime.timeIntervalSince(startTime)
                if interval > 0.25 {
                    break
                }

            }
        }
        for word in OKWords {
            let uppercasedWord = word.uppercased()
            if !WTGameWordList.shared.roundContainsWord(word: uppercasedWord) && !GV.hintTable.contains(uppercasedWord) {
                GV.hintTable.append(uppercasedWord)
            }
        }
        OKWords.removeAll()
    }
    
    private func findWordsWithRedLetters() {
        OKWords = [String]()
        for myIndex in 0..<results.count {
            var resultIndex = results.count - 1 - myIndex
            if maxWordLength < results[resultIndex].first!.word.length {
                continue
            }

//            var maxCountCycles = 0
            repeat {
                repeat {
                    let actResults = results[resultIndex]
//                    maxCountCycles = actResults.count
                    var wordIndexes = [Int]()
                    for index in 0..<actResults.count {
                        wordIndexes.append(index)
                    }
                    repeat {
                        var wordOK = true
                        let index = Int.random(in: 0 ..< wordIndexes.count)
                        let ind = wordIndexes[index]
                        wordIndexes.remove(at: index)
                        if wordIndexes.count == 0 {
                            break
                        }
                        let word = results[resultIndex][ind].word
                        var temporaryRedLetters = [(letter:String, index:Int)]()
                        for (letterIndex, letter) in word.uppercased().enumerated() {
    //                        if wordToCheck.char(at: letterIndex) == "?" {
                                if !redLetters.contains(String(letter)) {
                                    wordOK = false
                                    break
                                } else {
                                    temporaryRedLetters.append((String(letter), letterIndex))
                                    let index = redLetters.firstIndex(of: String(letter))
                                    if index != nil {
                                        redLetters.remove(at: index!)
                                    }
                                }
    //                        }
                        }
                        if wordOK {
    //                        print("temporaryFixLetters: \(temporaryFixLetters)")
                            if !OKWords.contains(word) {
                                OKWords.append(word)
                            }
                        }
//                        for temporaryLetter in temporaryRedLetters {
//                            redLetters.append(temporaryLetter.letter)
//                        }
                    } while OKWords.count < maxCountWords
                    resultIndex -= 1
                } while OKWords.count < maxCountWords && resultIndex >= 0
                for word in OKWords {
                    let uppercasedWord = word.uppercased()
                    if !GV.hintTable.contains(uppercasedWord) {
                        GV.hintTable.append(uppercasedWord)
                        if GV.hintTable.count == maxCountWords {
                            break
                        }
                    }
                }
            } while GV.hintTable.count < maxCountWords  && resultIndex >= 0

        }
    }
    
    var startTime = Date()
    
    public func createHints() {
        (maxWordLength, freeArrays) = wtGameboard!.getFreeArrays()
        redLetters = wtGameboard!.getRedLetters()
        fixLetters = wtGameboard!.getFixLetters()
        freeGreenLetters = wtGameboard!.getFreeGreenLetters()
        results = getAllWords()
        let countHints = GV.onIpad ? 30 : 20
        checkHintsTable(maxWordLength: maxWordLength)
        if GV.hintTable.count == countHints {
            return
        }
        startTime = Date()
        findWordsWithTwoFixLetters()
        if GV.hintTable.count < countHints {
            findWordsWithOneFixletter()
        }
        if GV.hintTable.count < countHints{
            findWordsWithRedLetters()
        }
        let sortedHints = GV.hintTable.sorted(by: {$0.length > $1.length})
        GV.hintTable = sortedHints
        

        

    }
    private func checkHintsTable(maxWordLength: Int) {
        var redLetters = wtGameboard!.getRedLetters()
        var wordsToDeleteFromHintTable = [String]()
        // itt még ellenőrizni kell, hogy megfelelő számú betű áll rendelkezésre, pl. a sárgaság szóhoz két á és két s és két g -re van szükség
        var temporaryLetters = [String]()
        for word in GV.hintTable {
            if word.length > maxWordLength {
                wordsToDeleteFromHintTable.append(word)
            } else {
                for letter in word.uppercased() {
                    if !redLetters.contains(String(letter)) {
                        wordsToDeleteFromHintTable.append(word)
                        break
                    } else {
                        temporaryLetters.append(String(letter))
                        let removeIndex = redLetters.firstIndex(of: String(letter))!
                        redLetters.remove(at: removeIndex)
                    }
                }
                for letter in temporaryLetters {
                    redLetters.append(letter)
                }
                temporaryLetters.removeAll()
            }
        }
        if wordsToDeleteFromHintTable.count > 0 {
            repeat {
                let wordToDelete = wordsToDeleteFromHintTable.last!
                let index = GV.hintTable.firstIndex(of: wordToDelete)
                if index != nil {
                    GV.hintTable.remove(at: index!)
                }
                wordsToDeleteFromHintTable.removeLast()
            } while wordsToDeleteFromHintTable.count > 0
        }
    }

}
