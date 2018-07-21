//
//  WTGameWordList
//  MagicOfWords
//
//  Created by Jozsef Romhanyi on 16/07/2018.
//  Copyright © 2018 Jozsef Romhanyi. All rights reserved.
//
// This class collects the words defined by the player.

import Foundation
import GameplayKit
let maxScore = 2000
let pointsForLetter = 10
let maxUsedLength = 25
let pointsForWord: [Int:Int] = [0: 0, 1: 0, 2: 0, 3: 0, 4: 50, 5:90, 6: 120, 7: 150, 8: 180, 9: 210, 10: 250, 11: 290, 12: 320, 13: 380, 14: 440,
                                15: 500, 16: 560, 17: 620, 18:680, 19: 740, 20:800, 21: 860, 22: 920, 23: 1030, 24: 1140, 25: 1250]
let minutesForWord: [Int: Int] = [0: 0, 1: 0, 2: 0, 3: 0, 4: 0, 5: 0, 6: 5, 7: 5, 8: 10, 9:10, 10: 15, 11: 15, 12: 20, 13: 20, 14: 20,
                                  15: 20, 16: 25, 17: 25, 18:25, 19: 25, 20:30, 21: 30, 22: 30, 23: 30, 24: 30, 25: 60]

struct SelectedWord {
    var word: String = ""
    var usedLetters = [UsedLetter]()
    var mandatory = false
    var score: Int {
        get {
            //var countUsing = 0
            //for letter in usedLetters {
            //    countUsing += GV.gameArray[letter.col][letter.row].getCountOccurences()
            //}
            let score = (word.length > 25 ? maxScore : pointsForWord[word.length]!)
            return score
        }
    }
//    var creationIndex = 0
//    var round = 0
    init(word: String, usedLetters: [UsedLetter]) {
        self.word = word
        self.usedLetters = usedLetters
        self.mandatory = WTGameWordList.shared.isMandatory(word: word)
    }
    init(from: String) {
        let valueTab = from.components(separatedBy: itemInnerSeparator)
        if valueTab.count > 4 {
            self.word = valueTab[0]
            for index in 1..<valueTab.count {
                if let iColRow = Int(valueTab[index]) {
                    let col = iColRow / 10
                    let row = iColRow % 10
                    self.usedLetters.append(UsedLetter(col: col, row: row, letter: word.subString(startPos: index - 1, length: 1)))
                }
            }
        }
    }
    func toString()->String {
        var colRowString = ""
        for letter in usedLetters {
            colRowString += String(10 * letter.col + letter.row)
            if colRowString.length == 1 {
                colRowString = "0" + colRowString
            }
            colRowString +=  itemInnerSeparator
        }
        if colRowString.length > 1 {
            colRowString.removeLast()
        }
        return word +
//            itemInnerSeparator + (mandatory ? "1" : "0") +
//            itemInnerSeparator + String(creationIndex) +
            itemInnerSeparator + colRowString
    }
}

extension SelectedWord: Equatable {
    static func == (lhs: SelectedWord, rhs: SelectedWord) -> Bool {
        func checkPositions()->Bool {
            var positionsOK = true
            for index in 0..<lhs.usedLetters.count {
                if !(lhs.usedLetters[index] == rhs.usedLetters[index]) {
                    positionsOK = false
                }
            }
            return positionsOK
        }
        return
            lhs.word == rhs.word && checkPositions()
    }
}


public protocol WTGameWordListDelegate: class {
    
    /// Method called when a new Word is saved
    func showScore(newWord: String, newScore: Int, totalScore: Int, doAnimate: Bool, changeTime: Int)
}


class WTGameWordList {
    struct WordWithCounter {
        var word: String
        var mandatory: Bool
        var counter: Int
        var score: Int {
            get {
                return WTGameWordList.shared.getScore(forWord: word)
            }
        }
        init(word: String, counter: Int, mandatory: Bool) {
            self.word = word
            self.counter = counter
            self.mandatory = mandatory
        }
    }
    var wordsInGame: [SelectedWord]
    var delegate: WTGameWordListDelegate?
    var allWords = [WordWithCounter]()
    static let shared = WTGameWordList()
    init() {
        wordsInGame = [SelectedWord]()
    }
    public func setDelegate(delegate: WTGameWordListDelegate) {
        self.delegate = delegate
    }
    
    public func setMandatoryWords() {
        let myMandatoryWords = GV.playingRecord.mandatoryWords.uppercased().components(separatedBy: itemSeparator)
        for word in myMandatoryWords {
            allWords.append(WordWithCounter(word: word, counter: 0, mandatory: true))
        }
    }
    
    public func getMandatoryWords()->[WordWithCounter] {
        var returnArray = [WordWithCounter]()
        for mandatoryWord in allWords {
            if mandatoryWord.mandatory {
                returnArray.append(mandatoryWord)
            } else {
                break
            }
        }
        return returnArray
        
    }
    
    public func gameFinished()->Bool {
        var counter = 0
        var countMandatoryWords = 0
        for word in allWords {
            if word.mandatory {
                counter += word.counter > 0 ? 1 : 0
                countMandatoryWords += 1
            }
        }
        return counter == countMandatoryWords
    }
    
    public func getCountWords(mandatory: Bool)->Int {
        var counter = 0
        for word in allWords {
            if word.mandatory == mandatory {
                counter += 1
            }
        }
        return counter
    }
 
    public func getCountFoundedWords(mandatory: Bool, countFoundedMandatory: Bool = false, countAll: Bool = false)->Int {
        var counter = 0
        var countAllWords = 0
        var countFoundedMandatoryWords = 0
        for word in allWords {
            if word.mandatory == mandatory {
                for myWord in wordsInGame {
                    if myWord.word == word.word {
                        countAllWords += 1
                    }
                }
                countFoundedMandatoryWords += word.counter > 0 ? 1 : 0
                counter += 1
            }
        }
        return countFoundedMandatory ? countFoundedMandatoryWords : countAll ? countAllWords : counter
    }
    
    public func initFromString(from: String) {
        wordsInGame = [SelectedWord]()
        if from.length > 0 {
            let selectedWords = from.components(separatedBy: itemSeparator)
            for selectedWordString in selectedWords {
                let selectedWord = SelectedWord(from: selectedWordString)
                if selectedWord.word.length > 0 {
                    _ = addWord(selectedWord: selectedWord, doAnimate: false)
                }
            }
        }
    }
    
    public func isMandatory(word: String)->Bool {
        var returnBool = false
        if let index = allWords.index(where: {$0.word == word}) {
            returnBool = allWords[index].mandatory
        }
        return returnBool
    }
    
    public func addWord(selectedWord: SelectedWord, doAnimate: Bool = true)->Bool {
        
        var noCommonLetter = true
        var noDiagonal = true
        for index1 in 0..<selectedWord.usedLetters.count - 1 {
            // check if a letter is 2x used in the word
            for index2 in index1 + 1..<selectedWord.usedLetters.count {
                if selectedWord.usedLetters[index1].col == selectedWord.usedLetters[index2].col &&
                    selectedWord.usedLetters[index1].row == selectedWord.usedLetters[index2].row {
                    noCommonLetter = false
                }
            }
            // check if in the word is using the diagonal way from one letter to the other
            let index2 = index1 + 1
            if selectedWord.usedLetters[index1].col != selectedWord.usedLetters[index2].col &&
                selectedWord.usedLetters[index1].row != selectedWord.usedLetters[index2].row {
                noDiagonal = false
            }
        }
        for savedSelectedWord in wordsInGame{
            // check if there is the same word in the table with one or more letters with the same position
            if savedSelectedWord.word == selectedWord.word {
                for letterIndex in 0..<savedSelectedWord.word.length {
                    if savedSelectedWord.usedLetters[letterIndex].col == selectedWord.usedLetters[letterIndex].col &&
                        savedSelectedWord.usedLetters[letterIndex].row == selectedWord.usedLetters[letterIndex].row {
                        noCommonLetter = false
                    }
                }
            }
        }
        if noCommonLetter && noDiagonal {
//            var isSaved = false
            let oldScore = getActualScore()
            wordsInGame.append(selectedWord)
            for letter in selectedWord.usedLetters {
                GV.gameArray[letter.col][letter.row].incrementCountOccurences()
            }
            addWordToAllWords(word: selectedWord.word)
            let newScore = getActualScore()
            let changeTime = minutesForWord[selectedWord.word.length]
            delegate!.showScore(newWord: selectedWord.word, newScore: newScore - oldScore, totalScore: newScore, doAnimate: doAnimate, changeTime: changeTime!)
        }
        return noCommonLetter
    }
    
    private func addWordToAllWords(word: String) {
        let index = allWords.index(where: {$0.word == word})
        if index == nil {
            allWords.append(WordWithCounter(word: word, counter: 1, mandatory: false))
        } else {
            allWords[index!].counter += 1
        }
    }
    
    public func removeLastWord(selectedWord: SelectedWord) {
        if wordsInGame.count > 0 {
            let oldScore = getActualScore()
            removeWordFromAllWords(word: selectedWord.word)
            if selectedWord == wordsInGame.last! {
                wordsInGame.removeLast()
            }
            for letter in selectedWord.usedLetters {
                GV.gameArray[letter.col][letter.row].decrementCountOccurences()
            }
            let newScore = getActualScore()
            let changeTime = -selectedWord.word.length > maxUsedLength ? minutesForWord[maxUsedLength] : minutesForWord[selectedWord.word.length]
            delegate!.showScore(newWord: selectedWord.word, newScore: newScore - oldScore, totalScore: newScore, doAnimate: true, changeTime: changeTime!)
        }
    }
    
    private func removeWordFromAllWords(word: String) {
        if let index = allWords.index(where: {$0.word == word}) {
            if allWords[index].counter > 1 {
                allWords[index].counter -= 1
            } else {
                if allWords[index].mandatory {
                    allWords[index].counter -= 1
                } else {
                    allWords.remove(at: index)
                }
            }
        }
    }
    
    private func getScore(forWord: String)->Int {
        var score = 0
        for selectedWord in wordsInGame {
            if selectedWord.word == forWord {
                score += selectedWord.score
            }
        }
        return score
    }
    
    public func getScore(forAll: Bool = false, mandatory: Bool = false)->Int {
        var score = 0
        for word in allWords {
            if forAll || word.mandatory == mandatory {
                score += word.score
            }
        }
        return score
    }
    
    private func getActualScore()->Int {
        var score = 0
        for selectedWord in wordsInGame {
            score += selectedWord.score
        }
        return score
    }
    
    public func toString()->String {
        var returnString = ""
        for selectedWord in wordsInGame {
            returnString += selectedWord.toString() + itemSeparator
        }
        if returnString.length > 1 {
            returnString.removeLast()
        }
        return returnString
    }
}
