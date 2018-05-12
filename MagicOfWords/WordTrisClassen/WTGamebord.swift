//
//  WTGamebord.swift
//  MagicOfWords
//
//  Created by Jozsef Romhanyi on 11/02/2018.
//  Copyright © 2018 Jozsef Romhanyi. All rights reserved.
//

import Foundation
import GameplayKit
public let gameboardName = "°°°GameboardName°°°"
public let gridName = "°°°Grid°°°"
public struct UsedItems {
    var col: Int = 0
    var row: Int = 0
    var item: WTGameboardItem?
}

public struct UsedLetter {
    var col: Int = 0
    var row: Int = 0
    var letter: String = ""
    init(col: Int, row: Int, letter: String) {
        self.col = col
        self.row = row
        self.letter = letter
    }
    func toString()->String {
        return String(col) + String(row) + String(letter)
    }
}
public struct FoundedWord {
    var word: String = ""
    var score: Int = 0
    var usedLetters = [UsedLetter]()
    init(word: String = "", usedLetters: [UsedLetter] = [UsedLetter]()) {
        self.word = word
        self.usedLetters = usedLetters
    }
    public mutating func addLetter(letter: UsedLetter) {
        word.append(letter.letter)
        usedLetters.append(letter)
    }
    public mutating func removeLast() {
        if word.count > 0 {
            word.removeLast()
            usedLetters.removeLast()
        }
    }

    func toString()->String {
        var returnValue = word + itemInnerSeparator
        for usedLetter in usedLetters {
            returnValue += usedLetter.toString()
        }
        return returnValue
    }
}

public struct FoundedWordWithCounter {
    var word: String = ""
    var score: Int = 0
    var counter: Int = 0
    init(word: String, counter: Int, score: Int) {
        self.word = word
        self.counter = counter
        self.score = score
    }
}

public struct GameArrayPositions {
    var col: Int
    var row: Int
}

public struct RoundInfos {
    var words = [FoundedWordWithCounter]()
}


public protocol WTGameboardDelegate: class {
    
    /// Method called when a word is founded
    func showFoundedWords()
    /// method is called when an own word is chosed
    func addOwnWord(word: String, creationIndex: Int, check: Bool)->Bool
}


let WSGameboardSizeMultiplier:CGFloat = 2.0
func == (left: UsedLetter, right: UsedLetter) -> Bool {
    return left.col == right.col && left.row == right.row && left.letter == right.letter
}

func == (left: FoundedWord, right: FoundedWord) -> Bool {
    return left.word == right.word
}


class WTGameboard: SKShapeNode {
    var delegate: WTGameboardDelegate
    var parentScene: SKScene
    var size: Int
    var grid: Grid?
    let blockSize: CGFloat?
    var gameArray: [[WTGameboardItem]]?
    var shape: WTPiece = WTPiece()
    private var lastCol: Int = 0
    private var lastRow: Int = 0
    private var startCol: Int = 0
    private var startRow: Int = 0
    private var startLocation = CGPoint(x: 0, y: 0)
    private var usedItems = [UsedItems]()
    private var usedItemsOK = true
//    private var mandatoryWords = [String]()
//    private var wordsToCheck = [String]()
//    private var ownWords = [String]()
    private var choosedWord = FoundedWord() //[UsedLetter]()
    private var foundedWords = [FoundedWord]()
    private var roundInfos = [RoundInfos]()
    private var foundedWordsWithCount = [FoundedWordWithCounter]()
//    private var foundedWordsWithCountArchiv = [FoundedWordsWithCounter]()
    private let scoreProWord = 50
    private let scoreProLetter = 10

    init(size: Int, parentScene: SKScene, delegate: WTGameboardDelegate) {
        self.size = size
        self.parentScene = parentScene
        self.blockSize = parentScene.frame.size.width * (GV.onIpad ? 0.70 : 0.90) / CGFloat(size)
        self.delegate = delegate
        super.init()
        createBackgroundShape(size: size)
        gameArray = createNewGameArray(size: size)
        for col in 0..<size {
            for row in 0..<size {
                gameArray![col][row].position = grid!.gridPosition(col: col, row: row) //+
//                    CGPoint (x:parentScene.frame.midX, y:parentScene.frame.midY * 0.874)
                gameArray![col][row].name = "GBD/\(col)/\(row)"
//                gameArray![col][row].setLetter(letter: "\(col)\(row)", status: .empty, color: .white)
                grid!.addChild(gameArray![col][row])
            }
        }
//        roundInfos.append(RoundInfos())
        self.name = gameboardName
        parentScene.addChild(self)
        generateNetOfColsAndRows()
    }
    
    private func generateNetOfColsAndRows() {
        for col in 0..<size {
            let colSprite = SKSpriteNode()
            colSprite.position = grid!.gridPosition(col: col, row: 0) + CGPoint(x: grid!.frame.midX, y: grid!.frame.minY)
            colSprite.size = CGSize(width: blockSize!, height: parentScene.frame.height)
//            if col % 2 == 1 {
//                colSprite.color = .yellow
//            }
            colSprite.name = "Col\(col)"
            parentScene.addChild(colSprite)
        }
        let colSprite = SKSpriteNode()
        let col10Width = parentScene.frame.maxX - grid!.frame.maxX
        colSprite.position = CGPoint(x: grid!.frame.maxX + col10Width / 2, y: grid!.frame.midY)
        colSprite.size = CGSize(width: col10Width, height: parentScene.frame.height)
//        colSprite.color = .green
        colSprite.name = "Col\(size)"
        parentScene.addChild(colSprite)
        
        let rowSprite = SKSpriteNode()
        let row10Height = grid!.frame.minY - parentScene.frame.minY
        rowSprite.position = CGPoint(x: parentScene.frame.midX, y: grid!.frame.minY - row10Height / 2) - CGPoint(x: 0, y: WSGameboardSizeMultiplier * blockSize!)
        rowSprite.size = CGSize(width: parentScene.frame.width, height: row10Height)
//        rowSprite.color = .blue
        rowSprite.name = "Row\(size)"
        parentScene.addChild(rowSprite)
        for row in 0..<size {
            let rowSprite = SKSpriteNode()
            rowSprite.position = CGPoint(x: grid!.frame.minX, y: grid!.frame.midY) - grid!.gridPosition(col: 0, row: row) - CGPoint(x: 0, y: WSGameboardSizeMultiplier * blockSize!)
            rowSprite.size = CGSize(width: parentScene.frame.width * 1.1, height: blockSize!)
//            if row % 2 == 0 {
//                rowSprite.alpha = 0.1
//                rowSprite.color = .green
//            }
            rowSprite.name = "Row\(size - 1 - row)"
            parentScene.addChild(rowSprite)
        }
    }
    private func createNewGameArray(size: Int) -> [[WTGameboardItem]] {
        var gameArray: [[WTGameboardItem]] = []
        
        for i in 0..<size {
            gameArray.append( [WTGameboardItem]() )
            
            for _ in 0..<size {
                gameArray[i].append( WTGameboardItem(blockSize: blockSize!, fontSize: parentScene.frame.width / 20) )
            }
        }
        return gameArray
    }

    private func createBackgroundShape(size: Int) {
        //        let myShape =

        grid = Grid(blockSize: blockSize!, rows:size, cols:size)
        grid!.position = CGPoint (x:parentScene.frame.midX, y:parentScene.frame.maxY * 0.45)
        grid!.name = gridName
        self.addChild(grid!)
    }
    
//    public func fixSpriteOnGameboardIfNecessary(shape: WTShape)->Bool {
//        if shape.sprite().frame.minY >= self.children[0].frame.minY && usedItemsOK &&
//            shape.sprite().frame.maxY < self.children[0].frame.maxY
//        {
//            _ = usedItems.map {$0.item!.fixIfTemporary()}
//            return true
//        } else {
//            _ = usedItems.map {$0.item!.clearIfTemporary()}
//            return false
//        }
//    }
    
    public func clear() {
        for index in 0..<usedItems.count {
            usedItems[index].item!.clearIfTemporary()
        }
        usedItems.removeAll()
        usedItemsOK = true
    }
    
    
    public func startShowingSpriteOnGameboard(shape: WTPiece, col: Int, row: Int, shapePos: Int)->Bool {
//        if col < 0 && row < 0 {
//            return false
//        }
        
        self.shape = shape
        let formOfShape = myForms[shape.myType]![shape.rotateIndex]
        let (myCol, myRow) = analyseColAndRow(col: col, row: row, formOfShape: formOfShape)
        if myRow == size {
            clear()
            return true
        }

       for index in 0..<shape.children.count {
            let letter = shape.letters[index]
            let itemRow = formOfShape[index] / 10
            let itemCol = formOfShape[index] % 10
            let calculatedCol = myCol + itemCol //- colAdder
            let calculatedRow = myRow - itemRow //- rowAdder
            if calculatedRow < 0 {return false}
        _ = gameArray![calculatedCol][calculatedRow].setLetter(letter: letter, status: .temporary, toColor: .myTemporaryColor)
            let usedItem = UsedItems(col: calculatedCol, row: calculatedRow, item: gameArray![calculatedCol][calculatedRow])
            usedItems.append(usedItem)
        }
        return true
    }
    
    public func moveSpriteOnGameboard(col: Int, row: Int) -> Bool {
        let formOfShape = myForms[shape.myType]![shape.rotateIndex]
        let (myCol, myRow) = analyseColAndRow(col: col, row: row, formOfShape: formOfShape)
        clear()
        if myRow == size {
            clear()
            return true
        }
        
        for index in 0..<shape.children.count {
            let letter = shape.letters[index]
            let itemCol = formOfShape[index] % 10
            let itemRow = formOfShape[index] / 10
            let calculatedCol = myCol + itemCol // - adder
            let calculatedRow = myRow - itemRow
            _ = gameArray![calculatedCol][calculatedRow].setLetter(letter: letter, status: .temporary, toColor: .myTemporaryColor)
            let usedItem = UsedItems(col: calculatedCol, row: calculatedRow, item: gameArray![calculatedCol][calculatedRow])
            usedItems.append(usedItem)
        }
        return false
    }
    
    private func analyseColAndRow(col: Int, row: Int, formOfShape: [Int])->(Int, Int) {
        var maxCol = 0
        var maxRow = 0
        var myCol = col
        var myRow = row
        for actItem in formOfShape {
            let actCol = actItem % 10
            let actRow = actItem / 10
            maxCol = maxCol < actCol ? actCol : maxCol
            maxRow = maxRow < actRow ? actRow : maxRow
        }
        if myRow < maxRow {
            myRow = maxRow
        }
        
        if myCol + maxCol > size - 1 {
            myCol = size - maxCol - 1
        }
        
        if myCol < 0 {
            myCol = 0
        }
        return (myCol, myRow)

    }
    
    public func showPieceOnGameArray(piece: WTPiece) {
        if piece.isOnGameboard {
            for index in 0..<piece.letters.count {
                let letter = piece.letters[index]
                if let col = Int(piece.gameArrayPositions[index].subString(startPos: 0, length:1)) {
                    if let row = Int(piece.gameArrayPositions[index].subString(startPos: 1, length:1)) {
                        _ = gameArray![col][row].setLetter(letter: letter, status: .used, toColor: .myUsedColor)
                    }
                }
            }
            piece.alpha = 0
        }
    }
    
    public func stopShowingSpriteOnGameboard(col: Int, row: Int/*, wordsToCheck: [String]*/)->Bool {
        var fixed = true
//        self.wordsToCheck = wordsToCheck
        if row == 10 {
            for index in 0..<usedItems.count {
                usedItems[index].item!.clearIfTemporary()
            }
            return false  // when shape not remaining on gameBoard, return false
        } else {
            var clearNeaded = false
            for index in 0..<usedItems.count {
                if usedItems[index].item!.status == .used {
                    clearNeaded = true
                    break
                }
            }
            if clearNeaded {
                clear()
                return false
            } else {
                for index in 0..<usedItems.count {
                    fixed = fixed && usedItems[index].item!.fixIfTemporary()
                }
            }
            if fixed {
                checkWholeWords()
                var gameArrayPositions = [GameArrayPositions]()
                for index in 0..<usedItems.count {
                    gameArrayPositions.append(GameArrayPositions(col:usedItems[index].col,row: usedItems[index].row))
                }
                shape.setGameArrayPositions(gameArrayPositions: gameArrayPositions)
            }
            return fixed  // when shape remaining on gameBoard, return true
        }
    }

    public func checkWholeWords() {
        foundedWords.removeAll()
        for col in 0..<size {
            for row in 0..<size {
                gameArray![col][row].resetCountOccurences()
                gameArray![col][row].setGreenToUsedColor()
            }
        }
        for col in 0..<gameArray!.count {
            for row in 0..<gameArray!.count {
                let letter = getLetter(col: col, row: row)
                if letter != "" {
                    for actWord in GV.allWords {
                        if actWord.word.count > 0 {
                            if letter == actWord.word.subString(startPos: 0, length: 1) {
                                OKPositions.removeAll()
                                if flyOverWord(compare: letter, col: col, row: row, fromCol: col, fromRow: row, withWord: actWord.word) {
                                } else {
                                }
                            }
                        }
                    }
                }
            }
        }
        // analyze the repeated words: in 2 identical words my be only 1 letter with the same position
        analyzeFoundedWords()
//        if roundInfos.count == GV.actRound {
//            roundInfos.append(RoundInfos())
//        }
//        if GV.actRound > roundInfos.count - 1 {
//            GV.actRound = roundInfos.count - 1
//        }
        if roundInfos.count > 0 {
            if roundInfos.last!.words.count > 0 {
                roundInfos[roundInfos.count - 1].words.removeAll()
            }
        } else {
            roundInfos.append(RoundInfos())
        }
        for foundedWord in foundedWords {
            var color:MyColor = GV.allMandatoryWordsFounded() ? .myWholeWordColor : .myGoldColor
            if GV.allWords.contains(where: {$0.word == foundedWord.word}) {
                color = .myWholeWordColor
            }
            for letter in foundedWord.usedLetters {
                var letterColor: MyColor = .myWholeWordColor
                if gameArray![letter.col][letter.row].myColor != .myWholeWordColor {
                    letterColor = color
                }
                gameArray![letter.col][letter.row].setFoundedWord(toColor: letterColor)
                gameArray![letter.col][letter.row].incrementCountOccurences()
            }
        }
        for index in 0..<foundedWords.count {
            var countLetterUsing = 0
            for letter in foundedWords[index].usedLetters {
                countLetterUsing += gameArray![letter.col][letter.row].getCountOccurences()
            }
            foundedWords[index].score = scoreProWord + countLetterUsing * scoreProLetter
        }
        foundedWordsWithCount.removeAll()
        for foundedWord in foundedWords {
            var founded = false
            if roundInfos.count > 0 {
                for index in 0..<roundInfos.last!.words.count {
                    if foundedWord.word == roundInfos.last!.words[index].word {
                        roundInfos[roundInfos.count - 1].words[index].counter += 1
                        roundInfos[roundInfos.count - 1].words[index].score += foundedWord.score
                        founded = true
                    }
                }
            }
            for index in 0..<foundedWordsWithCount.count {
                if foundedWord.word == foundedWordsWithCount[index].word {
                    foundedWordsWithCount[index].counter += 1
                    foundedWordsWithCount[index].score += foundedWord.score
                    founded = true
                }
            }

            if !founded {
                foundedWordsWithCount.append(FoundedWordWithCounter(word: foundedWord.word, counter: 1, score: foundedWord.score))
                roundInfos[roundInfos.count - 1].words.append(FoundedWordWithCounter(word: foundedWord.word, counter: 1, score: foundedWord.score))
            }
        }
        
        for index in 0..<GV.allWords.count {
            GV.allWords[index].countFounded = 0
            GV.allWords[index].score = 0
        }
        
        for roundInfo in roundInfos {
            for index in 0..<roundInfo.words.count {
                for index1 in 0..<GV.allWords.count {
                    if roundInfo.words[index].word == GV.allWords[index1].word {
                        GV.allWords[index1].countFounded += roundInfo.words[index].counter
                        GV.allWords[index1].score += roundInfo.words[index].score
                    }
                }
            }
        }

//        var wordDictionary = calculateCountersAndScores()
//        var foundedWordsToShow = [FoundedWordWithCounter]()
//        for (key, _) in wordDictionary {
//            foundedWordsToShow.append(wordDictionary[key]!)
//        }
        delegate.showFoundedWords()
    }
    
    private func calculateCountersAndScores()->[String : FoundedWordWithCounter] {
        var wordDictionary = [String: FoundedWordWithCounter]()
        for index in 0..<roundInfos.count {
            for wordInfos in roundInfos[index].words {
                if wordDictionary[wordInfos.word] == nil {
                    wordDictionary[wordInfos.word] = wordInfos
                } else {
                    wordDictionary[wordInfos.word] = FoundedWordWithCounter(
                        word: wordInfos.word,
                        counter: wordInfos.counter + wordDictionary[wordInfos.word]!.counter,
                        score: wordInfos.score + wordDictionary[wordInfos.word]!.score
                    )
                }
            }
        }
        return wordDictionary
    }
    
    var OKPositions = [UsedLetter]()
    
    private func flyOverWord(compare: String, col: Int, row: Int, fromCol: Int, fromRow: Int, withWord: String)->Bool {
        let myWord = compare
//        var searchString = ""
//        if withWord == "МОЛОКО" {
//            var allPositions = ""
//            for okPosition in OKPositions {
//                allPositions += "\(okPosition.col)\(okPosition.row)-"
//            }
//            if allPositions.count > 0 {
//                allPositions.removeLast()
//            }
//            searchString = "searching: \(compare): at \(allPositions)-\(col)\(row)"
//        }
        
        var returnBool = false
        if myWord.count == withWord.count {
            if myWord != withWord {
                return false
            } else {
                
                OKPositions.append(UsedLetter(col:col, row: row, letter: gameArray![col][row].letter))
//                if withWord == "МОЛОКО" {
//                    print("Stopped at \(withWord)")
//                    print("\(OKPositions)")
//                }
                var positionOnce = true
                for index0 in 0..<OKPositions.count - 1 {
                    for index1 in index0 + 1..<OKPositions.count {
                        if OKPositions[index0].col == OKPositions[index1].col && OKPositions[index0].row == OKPositions[index1].row {
                            positionOnce = false
                        }
                    }
                }
                var word = ""
                for okPosition in OKPositions {
                    word += okPosition.letter
                }
                if positionOnce && word == withWord {
                    foundedWords.append(FoundedWord(word: myWord, usedLetters: OKPositions))
                }
//                if withWord == "МОЛОКО" {
//                    print ("\(searchString): \(positionOnce)")
//                }
                return positionOnce
            }
        }
        if myWord == withWord.subString(startPos: 0, length: myWord.count) {
            OKPositions.append(UsedLetter(col:col, row: row, letter: gameArray![col][row].letter))
            if col > 0 && col - 1 != fromCol && !OKPositions.contains(where: {$0.col == col - 1 && $0.row == row}) {
                let new = getLetter(col: col - 1, row: row)
                if new != "" {
                    if flyOverWord(compare: myWord + new, col: col - 1, row: row, fromCol: col, fromRow: row, withWord: withWord) {
                        OKPositions.removeLast()
                        returnBool = true
                    }
                }
            }
            if col < size - 1 && col + 1 != fromCol && !OKPositions.contains(where: {$0.col == col + 1 && $0.row == row}) {
                let new = getLetter(col: col + 1, row: row)
                if new != "" {
                    if flyOverWord(compare: myWord + new, col: col + 1, row: row, fromCol: col, fromRow: row, withWord: withWord) {
                        OKPositions.removeLast()
                        returnBool = true
                    }
                }
            }
            if row > 0 && row - 1 != fromRow && !OKPositions.contains(where: {$0.col == col && $0.row == row - 1}) {
                let new = getLetter(col: col, row: row - 1)
                if new != "" {
                    if flyOverWord(compare: myWord + new, col: col, row: row - 1, fromCol: col, fromRow: row, withWord: withWord) {
                        OKPositions.removeLast()
                        returnBool = true
                    }
                }
            }
            if row < size - 1 && row + 1 != fromRow && !OKPositions.contains(where: {$0.col == col && $0.row == row + 1}) {
                let new = getLetter(col: col, row: row + 1)
                if new != "" {
                    if flyOverWord(compare: myWord + new, col: col, row: row + 1, fromCol: col, fromRow: row, withWord: withWord) {
                        OKPositions.removeLast()
                        returnBool = true
                    }
                }
            }
            if !returnBool && OKPositions.count > 0 {
                OKPositions.removeLast()
            }
        }
        return returnBool
    }
    
    private func analyzeFoundedWords() {
        if foundedWords.count > 0 {
            var indexesToRemove = [Int]()
//            foundedWords = foundedWords.sorted(by:{$0.word < $1.word})
            var wordTable = [String: [UsedLetter]]()
            for (index, foundedWord) in foundedWords.enumerated() {
                if wordTable[foundedWord.word] == nil {
                    wordTable[foundedWord.word] = foundedWord.usedLetters
                } else {
                    var appended = false
                    for usedLetter in foundedWord.usedLetters {
                        if !wordTable[foundedWord.word]!.contains(where: {$0 == usedLetter}) {
                            wordTable[foundedWord.word]!.append(usedLetter)
                            appended = true
                        }
                    }
                    if !appended {
                        indexesToRemove.append(index)
                    }
                }
            }
            if indexesToRemove.count > 0 {
                let indexes = indexesToRemove.sorted(by: {$0 > $1})
                for index in indexes {
                    foundedWords.remove(at: index)
                }
            }
        }
    }
    
    private func getLetter(col: Int, row: Int)->String {
        if gameArray![col][row].status == .used || gameArray![col][row].status == .wholeWord {
            return gameArray![col][row].letter //children[0] as! SKLabelNode).text!
        } else {
            return ""
        }
    }
    
    public func startChooseOwnWord(col: Int, row: Int) {
//        choosedWord.removeAll()
        choosedWord = FoundedWord()
        choosedWord.addLetter(letter: UsedLetter(col: col, row: row, letter: gameArray![col][row].letter))
//        choosedWord.append(UsedLetter(col: col, row: row, letter: gameArray![col][row].letter))
        gameArray![col][row].changeColor(toColor: .myBlueColor)
    }
    
    public func moveChooseOwnWord(col: Int, row: Int) {
        let actLetter = UsedLetter(col: col, row: row, letter: gameArray![col][row].letter)
        if choosedWord.usedLetters.last! == actLetter {
            return
        }
        print("choosedWord: \(choosedWord)")
        if choosedWord.usedLetters.count > 1 && choosedWord.usedLetters[choosedWord.usedLetters.count - 2] == actLetter {
            let last = choosedWord.usedLetters.last!
            gameArray![last.col][last.row].changeColor(toColor: .myNoColor)
            choosedWord.removeLast()
        } else {
            gameArray![col][row].changeColor(toColor: .myBlueColor)
            choosedWord.addLetter(letter: actLetter)
        }
    }
    
    public func endChooseOwnWord(col: Int, row: Int)->FoundedWord? {
//        for letter in choosedWord.usedLetters {
//            gameArray![letter.col][letter.row].changeColor(toColor: .myNoColor)
//        }
        for col in 0..<size {
            for row in 0..<size {
                if gameArray![col][row].myColor == .myBlueColor {
                    gameArray![col][row].changeColor(toColor: .myNoColor)
                }
            }
        }
        if col < 0 || col >= size || row < 0 || row >= size {
            return nil
        }
        //        let actLetter = UsedLetters(col: col, row: row, letter: gameArray![col][row].letter)
        var word = ""
        var wordAdded = false
        for letter in choosedWord.usedLetters {
            word.append(letter.letter)
        }
        if word.count > 2 {
            wordAdded = delegate.addOwnWord(word: word, creationIndex: NoValue, check: true)
            clear()
        }
        if wordAdded {
            return choosedWord
        } else {
            return nil
        }
    }
    
    private let roundSeparator = "/"
    private let itemSeparator = "°"
    private let itemDataSeparator = "^"

    public func setRoundInfos() {
        roundInfos.removeAll()
        var index = 0
        for round in GV.playingRecord.rounds {
            roundInfos.append(RoundInfos())
            let items = round.infos.components(separatedBy: itemSeparator)
            for item in items {
                let itemData = item.components(separatedBy: itemDataSeparator)
                if itemData.count == 3 {
                    if let score = Int(itemData[1]) {
                        if let counter = Int(itemData[2]) {
                            let foundedWordWithCounter = FoundedWordWithCounter(word: itemData[0], counter: counter, score: score)
                            roundInfos[index].words.append(foundedWordWithCounter)
                        }
                    }
                }
            }
            index += 1
        }
    }
    
    public func gameArrayToString()->String {
        var gameArrayString = ""
        for col in 0..<gameArray!.count {
            for row in 0..<gameArray!.count {
                gameArrayString += gameArray![col][row].toString()
            }
        }
        return gameArrayString
    }
    
    public func stringToGameArray(string: String) {
        for index in 0..<size * size {
            let col = index / size
            let row = index % size
            gameArray![col][row].restore(from: string.subString(startPos: 2 * index, length: 2))
        }
    }
    
    public func roundInfosToString(all: Bool)->String {
        var infoString = ""
        if all {
            for info in roundInfos {
                for item in info.words {
                    infoString += item.word + itemDataSeparator + String(item.score) + itemDataSeparator + String(item.counter) + itemSeparator
                 }
                if infoString.count > 0 {
                    infoString.removeLast()
                    infoString += roundSeparator
                }
            }
        } else {
            let lastRound = roundInfos.last!
            for item in lastRound.words {
                infoString += item.word + itemDataSeparator + String(item.score) + itemDataSeparator + String(item.counter) + itemSeparator
            }
        }
        if infoString.count > 0 {
            infoString.removeLast()
        }
        return infoString
    }

//    public func addOwnWordToCheck(word: String) {
//        wordsToCheck.append(word)
//    }
//
//    public func removeOwnWordToCheck(word: String) {
//        if let index = wordsToCheck.index(where: {$0 == word}) {
//            wordsToCheck.remove(at: index)
//        }
//    }
//
    public func checkFreePlaceForPiece(piece: WTPiece, rotateIndex: Int)->Bool {
        let form = myForms[piece.myType]![rotateIndex]
        for col in 0..<size {
            for row in 0..<size {
                var pieceOK = true
                for formItem in form {
                    let summarizedCol = col + formItem / 10
                    let summarizedRow = row - formItem % 10
                    if summarizedCol >= size || summarizedRow < 0 {
                        pieceOK = false
                        break
                    } else if gameArray![summarizedCol][summarizedRow].status != .empty {
                        pieceOK = false
                        break
                    }
                }
                if pieceOK {
                    return true
                }
            }
        }
        return false
    }
    
    public func setGameArrayPositionsToGreenIfNeeded(piece: WTPiece, pieceIndex: Int) {
        if piece.myType != .NotUsed {
            for (index, gameArrayPosition) in piece.gameArrayPositions.enumerated() {
                let col = Int(gameArrayPosition)! / 10
                let row = Int(gameArrayPosition)! % 10
                if gameArray![col][row].status == .empty {                    
                    _ = gameArray![col][row].setLetter(letter: piece.letters[index], status: .used, toColor: .myUsedColor)
//                    print("restored at piece: index: \(pieceIndex) col: \(col) row: \(row) letter: \(piece.letters[index])")
                } else {
//                    print("not restored at piece: index: \(pieceIndex) col: \(col) row: \(row) letter: \(piece.letters[index])")
                }
            }
        }
    }
    
    

    
    public func clearGreenFieldsForNextRound() {
        foundedWordsWithCount.removeAll()
        for col in 0..<size {
            for row in 0..<size {
//                print("col: \(col), row: \(row), letter: \(gameArray![col][row].letter) ")
                gameArray![col][row].clearIfUsed()
            }
        }
        roundInfos.append(RoundInfos())
    }
    
    public func getResults()->(WTResults, Bool) {
        var results = WTResults()
        var countFoundedMandatoryWords = 0
        let wordDictionary = calculateCountersAndScores()
        for actWord in GV.allWords {
            if wordDictionary[actWord.word] != nil {
                if actWord.mandatory {
                    results.countMandatoryWords += wordDictionary[actWord.word]!.counter
                    results.scoreMandatoryWords += wordDictionary[actWord.word]!.score
                    countFoundedMandatoryWords += 1
                } else {
                    results.countOwnWords += wordDictionary[actWord.word]!.counter
                    results.scoreOwnWords += wordDictionary[actWord.word]!.score
                }
            }
        }
        let OK = countFoundedMandatoryWords == GV.countMandatoryWords
        return (results, OK)
    }
    
    public func removeFromGameboard(sprite: WTPiece) {
        let gameboardIndexes = sprite.gameArrayPositions
        for gbIndex in gameboardIndexes {
            if let col = Int(gbIndex.subString(startPos: 0, length: 1)) {
                if let row = Int(gbIndex.subString(startPos: 1, length: 1)) {
                    gameArray![col][row].remove()
                }
            }
        }
    }
    
    public func clearGameArray() {
        for row in 0..<size {
            for col in 0..<size {
                gameArray![col][row].remove()
            }
        }
    }
    
    public func printGameArray() {
        let line = "____________________________________________"
        for row in 0..<10 {
            var infoLine = "|"
            for col in 0..<10 {
                let char = gameArray![col][row].letter
                var greenMark = " "
                if gameArray![col][row].status == .wholeWord {
                    greenMark = "*"
                }
                infoLine += greenMark + (char == "" ? " " : char) + greenMark + "|"
            }
            print(infoLine)
        }
        print(line)
    }
    
    func printFoundedWords(find: String) {
        for foundedWord in foundedWords {
            if foundedWord.word == find {
                var letters = ""
                for usedLetter in foundedWord.usedLetters {
                    letters += "\(usedLetter.col)\(usedLetter.row)-"
                }
                letters.removeLast()
                letters += ":"
                for usedLetter in foundedWord.usedLetters {
                    letters += usedLetter.letter
                }
                let printValue = "\(find): \"\(letters)\""
                print(printValue)
            }
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
