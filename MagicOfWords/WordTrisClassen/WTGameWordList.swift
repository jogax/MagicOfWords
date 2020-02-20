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
import RealmSwift
let maxScore = 2000
let pointsForLetter = 10
let maxUsedLength = 25
let pointsForWord: [Int:Int] = [0: 0, 1: 0, 2: 0, 3: 10, 4: 50, 5:100, 6: 150, 7: 200, 8: 250, 9: 300, 10: 350, 11: 410, 12: 470, 13: 530, 14: 600, 15: 670, 16: 740, 17: 820, 18:900, 19: 1000, 20:1100, 21: 1200, 22: 1300, 23: 1400, 24: 1500, 25: 2000]
let minutesForWord: [Int: Int] = [0: 0, 1: 0, 2: 0, 3: 0, 4: 0, 5: 0, 6: 0, 7: 5, 8: 5, 9:10, 10: 10, 11: 15, 12: 15, 13: 15, 14: 15, 15: 20, 16: 20, 17: 20, 18:20, 19: 25, 20:25, 21: 25, 22: 30, 23: 30, 24: 30, 25: 60]
let pointsForLettersInPosition: [Int:Int] = [0: 0, 1: 0, 2: 10, 3: 20, 4: 30, 5:50, 6: 60, 7: 70, 8: 90, 9: 100, 10: 110, 11: 130, 12: 140, 13: 150, 14: 170, 15: 180, 16: 190, 17: 210, 18: 220, 19: 230, 20:250, 21: 260, 22: 270, 23: 280, 24: 300, 25: 310]
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

public struct LineOfFoundedWords {
    var word = ""
    var score: Int {
        get {
            let score = (word.length > 25 ? maxScore : pointsForWord[word.length]!)
            return score
        }
    }
    var length: Int {
        get {
            return word.length
        }
    }
    init(_ word: String) {
       self.word = word
    }
}

public struct SelectedWord {
    var word: String = ""
    var usedLetters = [UsedLetter]()
    var countFixLetters = 0
    var connectionTypes = [ConnectionType]()
    var score = 0
//    var mandatory = false
    public mutating func setScore(round: Int) {
        let multiplier = countFixLetters > 0 ? countFixLetters + round : 1
        self.score = (word.length > 25 ? maxScore : pointsForWord[word.length]!) * multiplier + bonus(plus: true)
        let realm = try! Realm(configuration: Realm.Configuration.defaultConfiguration)
        let searchWord = GV.actLanguage + self.word.lowercased()
        let foundedRecords = realm.objects(MyReportedWords.self).filter("word = %@ and status = %@", searchWord, GV.accepted)
        if foundedRecords.count == 1 {
            self.score += foundedRecords.first!.bonus
        }
    }
//    var creationIndex = 0
//    var round = 0
    init(word: String = "", usedLetters: [UsedLetter] = [UsedLetter]()) {
        self.word = word
        self.usedLetters = usedLetters
        self.connectionTypes = setConnectionTypes()
        self.countFixLetters = getCountFixLetters()
        self.score = 0
    }
    init(from: String) {
        let valueTab = from.components(separatedBy: itemInnerSeparator)
        countFixLetters = 0
        if valueTab.count > 1 {
            self.word = valueTab[0]
            for index in 1..<valueTab.count {
                if let iColRow = Int(valueTab[index]) {
                    let col = iColRow / 10
                    let row = iColRow % 10
                    self.usedLetters.append(UsedLetter(col: col, row: row, letter: word.subString(at: index - 1, length: 1)))
                    countFixLetters += GV.gameArray[col][row].fixItem ? 1 : 0
                }
            }
        }
        self.connectionTypes = setConnectionTypes()
    }
    
    private func getCountFixLetters()->Int {
        var countFixLetters = 0
        for usedLetter in usedLetters {
            countFixLetters += GV.gameArray[usedLetter.col][usedLetter.row].fixItem ? 1 : 0
        }
        return countFixLetters
    }
    
    public func totalScore(plus: Bool)->Int {
        return self.score/* + self.bonus(plus: plus)*/
    }

    public func bonus(plus: Bool)->Int {
        var returnValue = 0
        for letter in usedLetters {
            let node = GV.gameArray[letter.col][letter.row]
            var actCount = node.getCountOccurencesInWords()
            let change = actCount < 1 ? 0 : plus ? 1 : -1
            actCount = actCount > 25 ? 25 : actCount
            let actBonus = pointsForLettersInPosition[actCount]!
            let oldBonus = pointsForLettersInPosition[actCount - change]!
            let adder = (actBonus - oldBonus) * (node.fixItem ? 5 : 1)
            returnValue += adder
        }
        return returnValue
    }
    
    public func isMandatory()->Bool {
        for word in GV.mandatoryWords {
            if word == self.word {
                return true
            }
        }
        return false
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
        return lhs.word == rhs.word && checkPositions()
    }
}

public struct WordWithCounter {
    var word: String
//    var mandatory: Bool
    var counter: Int
    var score: Int
    init(word: String, counter: Int, score: Int) {
        self.word = word
        self.counter = counter
//        self.mandatory = mandatory
//        self.countFixLetters = countFixLetters
        self.score = score
    }
}


public protocol WTGameWordListDelegate: class {
    
    /// Method called when a new Word is saved
    func showScore(newWord: SelectedWord, minus: Bool, doAnimate: Bool)
    func startShowingWordsOverPosition(wordList: [SelectedWord])
//    func stopShowingWordsOverPosition()
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
//    private var mandatoryWords = [String]()
//    static let shared = WTGameWordList()
    public class var shared: WTGameWordList {
        struct Static {
            static let instance = WTGameWordList()
        }
        return Static.instance
    }
    
    init() {
        wordsInRound = [WordInRound]()
//        mandatoryWords = GV.playingRecord.mandatoryWords.uppercased().components(separatedBy: itemSeparator)
    }
    public func reset() {
        wordsInRound = [WordInRound]()
        allWords = [WordWithCounter]()
//        setMandatoryWords()
    }
    public func setDelegate(delegate: WTGameWordListDelegate) {
        self.delegate = delegate
    }
    
//    public func setMandatoryWords() {
//        mandatoryWords = GV.playingRecord.mandatoryWords.uppercased().components(separatedBy: itemSeparator)
//        GV.mandatoryWords.removeAll()
//        for word in mandatoryWords {
//            allWords.append(WordWithCounter(word: word, counter: 0, mandatory: true, score: 0))
//            GV.mandatoryWords.append(word)
//        }
//    }
//
//    public func getMandatoryWords()->[WordWithCounter] {
//        var returnArray = [WordWithCounter]()
//        let mandatorySorted = allWords.filter({$0.mandatory == true}).sorted(by: {
//            $0.word.length < $1.word.length ||
//            $0.word.length == $1.word.length && $0.word < $1.word ||
//            $0.word == $1.word && $0.counter < $1.counter})
//        for (index, mandatoryWord) in mandatorySorted.enumerated() {
////            print(mandatoryWord)
//            if !(mandatoryWord.counter == 0 && index < mandatorySorted.count - 1 && mandatoryWord.word == mandatorySorted[index + 1].word)
//            {
//                returnArray.append(mandatoryWord)
//            }
//        }
//        return returnArray
//
//    }
    
//    public func gameFinished()->Bool {
//        var counter = 0
//        let myMandatoryWords = allWords.filter({$0.mandatory == true && $0.counter > 0})
//        for mandatoryWord in GV.mandatoryWords {
//            counter += myMandatoryWords.filter({$0.word == mandatoryWord}).count > 0 ? 1 : 0
//        }
//        return counter == GV.mandatoryWords.count
//    }
    
    public func getCountWords()->Int {
            return allWords.count
    }
    
//    public func getMinutesForWord(word: String)->Int {
//        if word.length < minutesForWord.count {
//            return minutesForWord[word.length]!
//        } else {
//            return minutesForWord[minutesForWord.count - 1]!
//        }
//    }
//
//
//
    public func getCountOwnWords(founded: Bool)->(Int) {
        var returnValue = 0
        var lastWord = ""
        let myWords = allWords.sorted(by: {
            $0.word.length > $1.word.length ||
            $0.word.length == $1.word.length && $0.word < $1.word
        })
        for word in myWords {
            if founded {
                if word.word != lastWord {
                    returnValue += 1
                    lastWord = word.word
                }
            } else {
                returnValue += word.counter
            }
        }
        return returnValue
    }
    
    public func restoreFromPlayingRecord() {
        clearWordsInGame()
        for (index, round) in GV.playingRecord.rounds.enumerated() {
//            print("round: \(index + 1)")
            setFirstTime()
            cleanGameArray()
//            showTime(string: "cleanGameArray")
            resetOccurencesInWords()
//            showTime(string: "resetOccurencesInWords")
            wordsInRound.append(WordInRound())
            wtGameboard!.stringToGameArray(string: round.gameArray)
//            showTime(string: "stringToGameArray")
            initFromString(from: round.infos, round: index + 1)
//            showTime(string: "initFromString")
        }
    }
     
    private func resetOccurencesInWords() {
        for col in 0..<GV.size {
            for row in 0..<GV.size {
                GV.gameArray[col][row].resetCountOccurencesInWords()
            }
        }
    }
    
    private func cleanGameArray() {
        for col in 0..<GV.size {
            for row in 0..<GV.size {
                GV.gameArray[col][row].clearConnectionType()
            }
        }
    }
    
    private func initFromString(from: String, round: Int) {
        if from.length > 0 {
            let selectedWords = from.components(separatedBy: itemSeparator)
            for selectedWordString in selectedWords {
                let selectedWord = SelectedWord(from: selectedWordString)
//                selectedWord.setScore(round: round)
                if selectedWord.word.length > 0 {
                    _ = addWord(selectedWord: selectedWord, doAnimate: false, round: round)
//                    addWordToAllWords(selectedWord: selectedWord, round: round)
                }
            }
        }
    }
    
    var timer = Date()
    private func setFirstTime() {
        timer = Date()
    }
    
    private func showTime(string: String) {
        let date = Date()
        print("time at \(string): \((date.timeIntervalSince(timer) * 1000).nDecimals(10))")
        timer = Date()
    }
    
    public func getPreviousRound() {
        wordsInRound.removeLast()
    }


    public func addWord(selectedWord: SelectedWord, doAnimate: Bool, round: Int)->Bool {
//        var mySelectedWord = selectedWord
        var noCommonLetter = true
        var noDiagonal = true
        var commonLetters = [UsedLetter]()
        if wordsInRound.count == 0 {
            wordsInRound.append(WordInRound())
        }
        let wordsInGame = wordsInRound.last!.wordsInGame
        if doAnimate {
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
                    for savedLetterIndex in 0..<savedSelectedWord.word.length {
                        for selectedLetterIndex in 0..<selectedWord.word.length {
                            if savedSelectedWord.usedLetters[savedLetterIndex].col == selectedWord.usedLetters[selectedLetterIndex].col &&
                                savedSelectedWord.usedLetters[savedLetterIndex].row == selectedWord.usedLetters[selectedLetterIndex].row &&
                                savedSelectedWord.usedLetters[savedLetterIndex].letter == selectedWord.usedLetters[selectedLetterIndex].letter {
                                commonLetters.append(savedSelectedWord.usedLetters[savedLetterIndex])
                                noCommonLetter = false
                            }
                        }
                    }
                    if !noCommonLetter {
                        delegate!.blinkWords(newWord: selectedWord, foundedWord: savedSelectedWord)
                    }
                }
            }
        }
        if noCommonLetter && noDiagonal {

            for index in 0..<selectedWord.usedLetters.count {
//            for letter in selectedWord.usedLetters {
                let letter = selectedWord.usedLetters[index]
                let connectionType = selectedWord.connectionTypes[index]
                GV.gameArray[letter.col][letter.row].setStatus(toStatus: .WholeWord, connectionType: connectionType, incrWords: true)
            }
            addWordToAllWords(selectedWord: selectedWord, doAnimate: doAnimate, round: round)
            addWordToMyWords(word: selectedWord.word)
        }
        return noCommonLetter && noDiagonal
    }
    
    private func addWordToMyWords(word: String) {
        let foundedWord = realm.objects(MyWords.self).filter("word = %@", GV.actLanguage + word.lowercased())
        if foundedWord.count == 0 {
            let wordToInsert = MyWords()
            wordToInsert.word = GV.actLanguage + word.lowercased()
            try! realm.safeWrite() {
                realm.add(wordToInsert)
            }
            let counter = realm.objects(MyWords.self).filter("word BEGINSWITH %@", GV.actLanguage).count
            GCHelper.shared.sendCountWordsToGameCenter(counter: counter, completion: {})
        }
    }
    
    private func addWordToAllWords(selectedWord: SelectedWord, doAnimate: Bool = false, round: Int) {
        var mySelectedWord = selectedWord
        mySelectedWord.setScore(round: round)
        wordsInRound[wordsInRound.count - 1].wordsInGame.append(mySelectedWord)
        GV.totalScore += mySelectedWord.score
//        if self.isMandatory(word: mySelectedWord.word) {
//            GV.mandatoryScore += mySelectedWord.score
//        } else {
        GV.ownScore += mySelectedWord.score
//        }
        let index = allWords.firstIndex(where: {$0.word == mySelectedWord.word})
        if index == nil {
            allWords.append(WordWithCounter(word: mySelectedWord.word, counter: 1, score: mySelectedWord.score))
            GV.countOfWords += 1
        } else {
            allWords.append(WordWithCounter(word: mySelectedWord.word, counter: 1, score: mySelectedWord.score))
        }
        if doAnimate { // only when new word added, not in init
            delegate!.showScore(newWord: mySelectedWord, minus: false, doAnimate: doAnimate)
        }
        for letter in selectedWord.usedLetters {
            let item = GV.gameArray[letter.col][letter.row]
            if item.getCountOccurencesInWords() == 1 && item.fixItem {
                GV.countOfLetters += 1
            }
        }

    }
    
    
    public func addNewRound() {
        wordsInRound.append(WordInRound())
    }
    
    public func getAllWords()->[WordWithCounter] {
        return allWords
    }
    
    public func removeLastWord(selectedWord: SelectedWord) {
        var mySelectedWord = selectedWord
        let wordsInGame = wordsInRound.last!.wordsInGame
        if wordsInGame.count > 0 {
//            let oldScore = getActualScore()
            for index in 0..<wordsInGame.count {
                if mySelectedWord == wordsInGame[index] {
                    wordsInRound[wordsInRound.count - 1].wordsInGame.removeLast()
                    break
                }
            }
            mySelectedWord.setScore(round: GV.playingRecord.rounds.count)
            removeWordFromAllWords(selectedWord: mySelectedWord)
            GV.totalScore -= mySelectedWord.score
            GV.ownScore -= mySelectedWord.score

            for (index, letter) in mySelectedWord.usedLetters.enumerated() {
                if isThisPositionFree(letter: letter) {
                    GV.gameArray[letter.col][letter.row].setStatus(toStatus: .Used, decrWords: true)
                } else {
                    let connectionType = mySelectedWord.connectionTypes[index]
                    GV.gameArray[letter.col][letter.row].setStatus(toStatus: .WholeWord, connectionType: connectionType, decrWords: true)
                }
            }
            for letter in mySelectedWord.usedLetters {
                let item = GV.gameArray[letter.col][letter.row]
                if item.getCountOccurencesInWords() == 0 && item.fixItem {
                    GV.countOfLetters -= 1
                }
            }
            delegate!.showScore(newWord: mySelectedWord, minus: true, doAnimate: true)
        }
        
        cleanGameArray()
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
    
    public func getCountWordsInLastRound()->Int {
        if wordsInRound.count == 0 {
            return 0
        }
        return wordsInRound.last!.wordsInGame.count
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
    
    private func removeWordFromAllWords(selectedWord: SelectedWord) {
        if let index = allWords.firstIndex(where: {$0.word == selectedWord.word && $0.score == selectedWord.score}) {
            if allWords[index].counter > 1 {
                allWords[index].counter -= 1
            } else {
                allWords.remove(at: index)
                if allWords.firstIndex(where: {$0.word == selectedWord.word}) == nil {
                    if GV.countOfWords > 0 {
                        GV.countOfWords -= 1
                    }
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
    
//    public func getScore(forAll: Bool = false, mandatory: Bool = false)->Int {
//        var score = 0
//        for word in allWords {
//            if forAll || word.mandatory == mandatory {
//                score += word.score
//            }
//        }
//        if forAll {
//            let letterScore = getPointsForLetters()
//            score += letterScore
//        }
//        return score
//    }
    
//    private func getActualScore()->Int {
//        var score = 0
//        for item in wordsInRound {
//            for selectedWord in item.wordsInGame {
//                score += selectedWord.score
//            }
//        }
//        let letterScore = getPointsForLetters()
//        score += letterScore
//        return score
//    }
    
    public func getPointsForLetters()->Int {
        var letterScore = 0
        for round in GV.playingRecord.rounds {
            letterScore += round.roundScore
        }
        for col in 0..<GV.sizeOfGrid {
            for row in 0..<GV.sizeOfGrid {
                var count = GV.gameArray[col][row].getCountOccurencesInWords()
                count = count > 25 ? 25 : count
                letterScore += pointsForLettersInPosition[count]!
//                print("col: \(col), row: \(row), count: \(count), score: \(letterScore)")
            }
        }
        return letterScore
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
                        GV.gameArray[letter.col][letter.row].setStatus(toStatus: .Used)
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
                        GV.gameArray[letter.col][letter.row].setStatus(toStatus: .GoldStatus)
                    }
                    GV.gameArray[choosedWord.usedLetters[0].col][choosedWord.usedLetters[0].row].setStatus(toStatus: .DarkGoldStatus)
                    showedWords.append(selectedWord)
    //                wordsToShow.append(selectedWord.word)
                }
            }
            delegate!.startShowingWordsOverPosition(wordList: showedWords.sorted(by: {
                $0.word.length > $1.word.length ||
                $0.word.length == $1.word.length && $0.score > $1.score ||
                $0.word.length == $1.word.length && $0.score == $1.score && $0.word < $1.word}))
            
        }
    }
    public func stopShowingWords() {
        for selectedWord in showedWords {
            for letter in selectedWord.usedLetters {
                GV.gameArray[letter.col][letter.row].setStatus(toStatus: .WholeWord)
            }
        }
        showedWords = [SelectedWord]()
//        delegate!.stopShowingWordsOverPosition()
    }
    public func getWordsForShow()->([FoundedWordWithCounter], Int) {
        var returnWords = [FoundedWordWithCounter]()
        var maxLengthOfWords = 0
        var lastWord = ""
        let wordsToShow = allWords.sorted(by: {
            $0.word.length > $1.word.length ||
            $0.word.length == $1.word.length && $0.word < $1.word ||
            $0.word.length == $1.word.length && $0.word == $1.word && $0.score > $1.score ||
            $0.word.length == $1.word.length && $0.word == $1.word && $0.score == $1.score && $0.counter > $1.counter
        })
        for foundedWord in wordsToShow {
            if foundedWord.word.length > maxLengthOfWords {
                maxLengthOfWords = foundedWord.word.length
            }
        }
        for foundedWord in wordsToShow {
            if foundedWord.counter == 0 {
                if lastWord != foundedWord.word {
                    returnWords.append(FoundedWordWithCounter(
                        word: foundedWord.word,
                        counter: foundedWord.counter,
                        score: 0))
                }
            } else  {
                returnWords.append(FoundedWordWithCounter(
                    word: foundedWord.word,
                    counter: foundedWord.counter,
                    score: foundedWord.score))
            }
            lastWord = foundedWord.word
        }
        
        return (returnWords.sorted(by: {
            $0.word.length > $1.word.length ||
            $0.word.length == $1.word.length && $0.score > $1.score ||
            $0.word.length == $1.word.length && $0.score == $1.score && $0.counter <= $1.counter && $0.word < $1.word}), maxLengthOfWords)
    }
    
}
