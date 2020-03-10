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
    
    private func getAllWords()->[Results<MandatoryListModel>] {
        var returnValue5_10 = [Results<MandatoryListModel>]()
        var returnValue3_4 = [Results<WordListModel>]()
        let formatString5_10 = "language = %@ AND word Like %@"
        let formatString3_4 = "word beginswith %@ AND word Like %@"
        let like = ""
        for count in 3...4 {
            let results = realmWordList.objects(WordListModel.self).filter(formatString3_4, GV.actLanguage, like.fill(with: "?", toLength: count + 2))
            returnValue3_4.append(results)
        }
        for count in 5...10 {
            let results = realmMandatoryList.objects(MandatoryListModel.self).filter(formatString5_10, GV.actLanguage, like.fill(with: "?", toLength: count))
            returnValue5_10.append(results)
        }

        return returnValue5_10
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
    
    public func createHints() {
        let countHints = 20
        checkHintsTable()
        if GV.hintTable.count == countHints {
            return
        }
        var usedRedLetters = [String]()
        var redLetters = wtGameboard!.getRedLetters()
        let fixLetters = wtGameboard!.getFixLetters()
        let freeGreenLetters = wtGameboard!.getFreeGreenLetters()
        let freeArrays = wtGameboard!.getFreeArrays()
        let results = getAllWords()
        var OKWords = [String]()
        var countCycles = 0
        var maxWordLength = 0
        for array in freeArrays {
            if array.countFree > maxWordLength {
                maxWordLength = array.countFree
            }
            if maxWordLength >= 10 {
                break
            }
        }
        var resultIndex = results.count - 1
        var stopCycle = false
        repeat {
            if results[resultIndex][0].word.length <= maxWordLength {
                stopCycle = true
            } else {
                resultIndex -= 1
            }
        } while !stopCycle && resultIndex >= 0
        if resultIndex < 0 {
            GV.hintTable.removeAll()
            return
        }
        var maxCountCycles = 0
        repeat {
            repeat {
                countCycles = 0
                let actResults = results[resultIndex]
                maxCountCycles = actResults.count
                var wordIndexes = [Int]()
                for index in 0..<actResults.count {
                    wordIndexes.append(index)
                }
                repeat {
                    var wordOK = true
                    let index = Int.random(in: 0 ..< wordIndexes.count)
                    let ind = wordIndexes[index]
                    wordIndexes.remove(at: index)
                    let word = results[resultIndex][ind].word
//     checking fix letters Start
                    //     checking fix letters End
                    var temporaryRedLetters = [(letter:String, index:Int)]()
//                    var letterIndexes = [Int]()
//                    var temporaryFixLetters = [(letter: UsedLetterWithCounter, index: Int)]()
//                    for (letterIndex, letter) in word.uppercased().enumerated() {
//                        let fixLetterIndex = find(value: String(letter), inArray: fixLetters)
//                        if fixLetterIndex != nil {
//                            temporaryFixLetters.append((fixLetters[fixLetterIndex!], letterIndex))
//                                letterIndexes.append(letterIndex)
//                        }
//                    }
//                    var wordToCheck = "".fill(with: "?", toLength: word.count)
                    
//                    itt ellenőrizni, hogy egy fix letter ki lehet e rakni a szót, redLetterssel ellenőrizni! és eltárolni a
//                    for (index, temporaryFixLetter) in temporaryFixLetters.enumerated() {
//                        var nextItem = temporaryFixLetter
//                        if index < temporaryFixLetters.count - 1 {
//                            nextItem = temporaryFixLetters[index + 1]
//                        }
//                        let lettersBetween = nextItem.index - temporaryFixLetter.index - 1
//                        let fixLetterDistance = abs(nextItem.letter.col - temporaryFixLetter.letter.col) + abs(nextItem.letter.row - temporaryFixLetter.letter.row) - 1
//                        if lettersBetween > 0 && lettersBetween == fixLetterDistance {
//                            wordToCheck = wordToCheck.changeChars(at: temporaryFixLetter.index - 1, by: temporaryFixLetter.letter.letter)
//                            break
//                        } else {
//                            wordToCheck = wordToCheck.changeChars(at: temporaryFixLetter.index - 1, by: temporaryFixLetter.letter.letter)
//                            break
//                        }
//                    }
//                    print("wordToInsert:\(wordToCheck), word: \(word)")
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
                            for temporaryLetter in temporaryRedLetters {
                                usedRedLetters.append(temporaryLetter.letter)
                            }
                        }
                    }
                    for temporaryLetter in temporaryRedLetters {
                        redLetters.append(temporaryLetter.letter)
                    }
                    countCycles += 1
                } while OKWords.count < countHints && countCycles < maxCountCycles
                resultIndex -= 1
            } while OKWords.count < countHints && resultIndex >= 0
            for word in OKWords {
                let formattedWord = word.uppercased()
                if !GV.hintTable.contains(formattedWord) {
                    GV.hintTable.append(formattedWord)
                    if GV.hintTable.count == countHints {
                        break
                    }
                }
            }
        } while GV.hintTable.count < 10 && countCycles < maxCountCycles
//        print("count: \(results.count)")
        

    }
    private func checkHintsTable() {
        var redLetters = wtGameboard!.getRedLetters()
        var wordsToDeleteFromHintTable = [String]()
        // itt még ellenőrizni kell, hogy megfelelő számú betű áll rendelkezésre, pl. a sárgaság szóhoz két á és két s és két g -re van szükség
        var temporaryLetters = [String]()
        for word in GV.hintTable {
            for letter in word {
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
