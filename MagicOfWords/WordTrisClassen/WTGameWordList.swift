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
let pointsForWord: [Int:Int] = [0: 0, 1: 0, 2: 0, 3: 10, 4: 50, 5:100, 6: 150, 7: 200, 8: 250, 9: 300, 10: 350, 11: 410, 12: 470, 13: 530, 14: 600,
                                15: 670, 16: 740, 17: 820, 18:900, 19: 1000, 20:1100, 21: 1200, 22: 1300, 23: 1400, 24: 1500, 25: 2000]
let minutesForWord: [Int: Int] = [0: 0, 1: 0, 2: 0, 3: 0, 4: 0, 5: 0, 6: 0, 7: 5, 8: 5, 9:10, 10: 10, 11: 15, 12: 15, 13: 15, 14: 15,
                                  15: 20, 16: 20, 17: 20, 18:20, 19: 25, 20:25, 21: 25, 22: 30, 23: 30, 24: 30, 25: 60]

public struct ConnectionType {
    var left = false
    var top = false
    var right = false
    var bottom = false
    init(left: Bool=false, top: Bool=false, right: Bool=false, bottom: Bool=false) {
        self.left = left
        self.top = top
        self.right = right
        self.bottom = bottom
    }
}
public struct SelectedWord {
    var word: String = ""
    var usedLetters = [UsedLetter]()
    var connectionTypes = [ConnectionType]()
//    var mandatory = false
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
    init(word: String = "", usedLetters: [UsedLetter] = [UsedLetter]()) {
        self.word = word
        self.usedLetters = usedLetters
        self.connectionTypes = setConnectionTypes()
//        self.mandatory = WTGameWordList.shared.isMandatory(word: word)
    }
    init(from: String) {
        let valueTab = from.components(separatedBy: itemInnerSeparator)
        if valueTab.count > 1 {
            self.word = valueTab[0]
            for index in 1..<valueTab.count {
                if let iColRow = Int(valueTab[index]) {
                    let col = iColRow / 10
                    let row = iColRow % 10
                    self.usedLetters.append(UsedLetter(col: col, row: row, letter: word.subString(startPos: index - 1, length: 1)))
                }
            }
        }
        self.connectionTypes = setConnectionTypes()
    }
    
    private func setConnectionTypes()->[ConnectionType] {
        var connectionTypes = Array(repeating: ConnectionType(), count: usedLetters.count)
        if usedLetters.count > 0 {
            for index in 0..<usedLetters.count - 1 {
                if usedLetters[index].row < usedLetters[index + 1].row {
                    connectionTypes[index].bottom = true
                    connectionTypes[index + 1].top = true
                }
                if usedLetters[index].row > usedLetters[index + 1].row {
                    connectionTypes[index].top = true
                    connectionTypes[index + 1].bottom = true
                }
                if usedLetters[index].col < usedLetters[index + 1].col {
                    connectionTypes[index].right = true
                    connectionTypes[index + 1].left = true
                }
                if usedLetters[index].col > usedLetters[index + 1].col {
                    connectionTypes[index].left = true
                    connectionTypes[index + 1].right = true
                }
            }
        }
        return connectionTypes
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
    public static func == (lhs: SelectedWord, rhs: SelectedWord) -> Bool {
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

public struct WordWithCounter {
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


public protocol WTGameWordListDelegate: class {
    
    /// Method called when a new Word is saved
    func showScore(newWord: SelectedWord, newScore: Int, totalScore: Int, doAnimate: Bool, changeTime: Int)
    func startShowingWordsOverPosition(wordList: [SelectedWord])
    func stopShowingWordsOverPosition()
    func blinkWords(newWord: SelectedWord, foundedWord: SelectedWord)
}


public class WTGameWordList {
    struct WordInRound {
        var wordsInGame = [SelectedWord]()
        init() {
            
        }
    }
    private var wordsInRound: [WordInRound]
    private var delegate: WTGameWordListDelegate?
    public var allWords = [WordWithCounter]()
    static let shared = WTGameWordList()
    init() {
        wordsInRound = [WordInRound]()
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
                for item in wordsInRound {
                    for myWord in item.wordsInGame {
                        if myWord.word == word.word {
                            countAllWords += 1
                        }
                    }
                }
                countFoundedMandatoryWords += word.counter > 0 ? 1 : 0
                counter += 1
            }
        }
        return countFoundedMandatory ? countFoundedMandatoryWords : countAll ? countAllWords : counter
    }
    
    public func restoreFromPlayingRecord() {
        clearWordsInGame()
        for round in GV.playingRecord.rounds {
            cleanGameArrayConnections()
            wordsInRound.append(WordInRound())
            initFromString(from: round.infos)
        }
    }
    
    private func cleanGameArrayConnections() {
        for col in 0..<GV.size {
            for row in 0..<GV.size {
                GV.gameArray[col][row].clearConnectionType()
            }
        }
    }
    
    private func initFromString(from: String) {
        
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
    
    public func getPreviousRound() {
        wordsInRound.removeLast()
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
        var commonLetters = [UsedLetter]()
        if wordsInRound.count == 0 {
            wordsInRound.append(WordInRound())
        }
        let wordsInGame = wordsInRound.last!.wordsInGame
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
                        commonLetters.append(savedSelectedWord.usedLetters[letterIndex])
                        noCommonLetter = false
                    }
                }
                if !noCommonLetter {
                    delegate!.blinkWords(newWord: selectedWord, foundedWord: savedSelectedWord)
                }
            }
        }
        if noCommonLetter && noDiagonal {
//            var isSaved = false
            let oldScore = getActualScore()
            wordsInRound[wordsInRound.count - 1].wordsInGame.append(selectedWord)
            for index in 0..<selectedWord.usedLetters.count {
//            for letter in selectedWord.usedLetters {
                let letter = selectedWord.usedLetters[index]
                let connectionType = selectedWord.connectionTypes[index]
                GV.gameArray[letter.col][letter.row].setColors(toColor: .myGreenColor, toStatus: .wholeWord, connectionType: connectionType)
            }
            addWordToAllWords(word: selectedWord.word)
            let newScore = getActualScore()
            let changeTime = minutesForWord[selectedWord.word.length]
            delegate!.showScore(newWord: selectedWord, newScore: newScore - oldScore, totalScore: newScore, doAnimate: doAnimate, changeTime: changeTime!)
        }
        return noCommonLetter && noDiagonal
    }
    
    private func addWordToAllWords(word: String) {
        let index = allWords.index(where: {$0.word == word})
        if index == nil {
            allWords.append(WordWithCounter(word: word, counter: 1, mandatory: false))
        } else {
            allWords[index!].counter += 1
        }
    }
    
    public func addNewRound() {
        wordsInRound.append(WordInRound())
    }
    
    public func getAllWords()->[WordWithCounter] {
        return allWords
    }
    
    public func removeLastWord(selectedWord: SelectedWord) {
        let wordsInGame = wordsInRound.last!.wordsInGame
        if wordsInGame.count > 0 {
            let oldScore = getActualScore()
            removeWordFromAllWords(word: selectedWord.word)
            for index in 0..<wordsInGame.count {
                if selectedWord == wordsInGame[index] {
                    wordsInRound[wordsInRound.count - 1].wordsInGame.removeLast()
                    break
                }
            }
            for letter in selectedWord.usedLetters {
                if isThisPositionFree(letter: letter) {
                    GV.gameArray[letter.col][letter.row].setColors(toColor: .myUsedColor, toStatus: .used)
                }
            }
            let newScore = getActualScore()
            let changeTime = selectedWord.word.length > maxUsedLength ? minutesForWord[maxUsedLength] : minutesForWord[selectedWord.word.length]
            delegate!.showScore(newWord: selectedWord, newScore: newScore - oldScore, totalScore: newScore, doAnimate: true, changeTime: -changeTime!)
        }
        
        cleanGameArrayConnections()
        for word in wordsInRound.last!.wordsInGame
 {
            for index in 0..<word.usedLetters.count {
                let col = word.usedLetters[index].col
                let row = word.usedLetters[index].row
                let connectionType = word.connectionTypes[index]
                GV.gameArray[col][row].setConnectionType(connectionType: connectionType)
            }
        }
    }
    
    private func isThisPositionFree(letter: UsedLetter)->Bool {
        let wordsInGame = wordsInRound.last!.wordsInGame
        for selectedWord in wordsInGame {
            if selectedWord.usedLetters.contains(where: {$0.col == letter.col && $0.row == letter.row}) {
                return false
            }
        }
        return true
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
    
    public func getScore(forWord: String)->Int {
        var score = 0
        for item in wordsInRound {
            for selectedWord in item.wordsInGame {
                if selectedWord.word == forWord {
                    score += selectedWord.score
                }
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
        for item in wordsInRound {
            for selectedWord in item.wordsInGame {
                score += selectedWord.score
            }
        }
        return score
    }
    
    public func toStringLastRound()->String {
        var returnString = ""
        if wordsInRound.count > 0 {
            let lastItem = wordsInRound.last!
            for selectedWord in lastItem.wordsInGame {
                returnString += selectedWord.toString() + itemSeparator
            }
            if returnString.length > 1 {
                returnString.removeLast()
            }
        }
        return returnString
    }
    
    public func clear() {
        wordsInRound = [WordInRound]()
//        wordsInGame = [SelectedWord]()
        allWords = [WordWithCounter]()
    }
    
    public func clearWordsInGame(changeGameArray: Bool = true) {
        if changeGameArray {
            for item in wordsInRound {
                for selectedWord in item.wordsInGame {
                    for letter in selectedWord.usedLetters {
                        GV.gameArray[letter.col][letter.row].setColors(toColor: .myUsedColor, toStatus: .used)
                    }
                }
            }
        }
        wordsInRound = [WordInRound()]
        wordsInRound.removeLast()
    }
    var showedWords = [SelectedWord]()
    var wordsToShow = [String]()
    
    public func showWordsContainingThisLetter(choosedWord: FoundedWord) {
//        wordsToShow = [String]()
        if wordsInRound.count > 0 {
            showedWords = [SelectedWord]()
            let lastItem = wordsInRound.last!
            for selectedWord in lastItem.wordsInGame {
                if selectedWord.usedLetters.contains(where: {$0.col == choosedWord.usedLetters[0].col && $0.row == choosedWord.usedLetters[0].row}) {
                    for letter in selectedWord.usedLetters {
                        GV.gameArray[letter.col][letter.row].setColors(toColor: .myGoldColor, toStatus: .noChange)
                    }
                    GV.gameArray[choosedWord.usedLetters[0].col][choosedWord.usedLetters[0].row].setColors(toColor: .myDarkGoldColor, toStatus: .noChange)
                    showedWords.append(selectedWord)
    //                wordsToShow.append(selectedWord.word)
                }
            }
            delegate!.startShowingWordsOverPosition(wordList: showedWords)
            
        }
    }
    public func stopShowingWords() {
        for selectedWord in showedWords {
            for letter in selectedWord.usedLetters {
                GV.gameArray[letter.col][letter.row].setColors(toColor: .myGreenColor, toStatus: .wholeWord)
            }
        }
        showedWords = [SelectedWord]()
        delegate!.stopShowingWordsOverPosition()
    }
    public func getWordsForShow(mandatory: Bool)->([FoundedWordWithCounter], Int) {
        var returnWords = [FoundedWordWithCounter]()
        var maxLengthOfWords = 0
        for foundedWord in allWords {
            if foundedWord.mandatory == mandatory {
                if foundedWord.word.length > maxLengthOfWords {
                    maxLengthOfWords = foundedWord.word.length
                }
            }
        }
        for foundedWord in allWords {
            if foundedWord.mandatory == mandatory {
                returnWords.append(FoundedWordWithCounter(
                    word: foundedWord.word,
                    counter: foundedWord.counter,
                    score: foundedWord.score,
                    minutes: foundedWord.score > 0 ? minutesForWord[foundedWord.word.length]! : 0))
            }
        }
        
        return (returnWords.sorted(by: {
            $0.word.length > $1.word.length ||
            $0.word.length == $1.word.length && $0.score > $1.score ||
            $0.word.length == $1.word.length && $0.score == $1.score && $0.counter <= $1.counter && $0.word < $1.word}), maxLengthOfWords)
    }
    
}
