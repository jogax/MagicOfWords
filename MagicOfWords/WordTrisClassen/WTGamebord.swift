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
    var letter: String = emptyLetter
    init(col: Int, row: Int, letter: String) {
        self.col = col
        self.row = row
        self.letter = letter
    }
    func toString()->String {
        return String(col) + String(row) + String(letter)
    }
}

public struct MovingItem {
    var colFrom: Int = 0
    var rowFrom: Int = 0
    var colTo: Int = 0
    var rowTo: Int = 0
    var length: Int = 0
    var horizontal: Bool {
        get {
            if colFrom == colTo {
                return true
            } else {
                return false
            }
        }
    }
    var multiplier: Int {
        get {
            if horizontal && colFrom < colTo || !horizontal && rowFrom < rowTo {
                return 1
                
            } else {
                return -1
            }
        }
    }
    init(){
        self.colFrom = 0
        self.rowFrom = 0
        self.colTo = 0
        self.rowTo = 0
        self.length = 0
    }
    init(colFrom: Int, rowFrom: Int, colTo: Int, rowTo: Int, length: Int) {
        self.colFrom = colFrom
        self.rowFrom = rowFrom
        self.colTo = colTo
        self.rowTo = rowTo
        self.length = length
    }
    init(from: String){
        let colFrom: Int? = Int(from.subString(startPos: 0, length: 1))
        let rowFrom: Int? = Int(from.subString(startPos: 1, length: 1))
        let colTo: Int? = Int(from.subString(startPos: 2, length: 1))
        let rowTo: Int? = Int(from.subString(startPos: 3, length: 1))
        let length: Int? = Int(from.subString(startPos: 4, length: 1))
        if colFrom != nil && rowFrom != nil && colTo != nil && rowTo != nil && length != nil {
            self.init(colFrom: colFrom!, rowFrom: rowFrom!, colTo: colTo!, rowTo: rowTo!, length: length!)
        } else {
            self.init()
        }
    }
    func toString()->String {
        return String(colFrom) + String(rowFrom) + String(colTo) + String(rowTo) + String(length)
    }
    
}

public struct FoundedWord {
    var word: String = ""
    var score: Int = 0
    var direction: Direction {
        get {
            let firstCol = usedLetters[0].col
            let firstRow = usedLetters[0].row
            var horizontal = true
            var vertical = true
            for index in 0..<usedLetters.count {
                if usedLetters[index].col != firstCol {
                    vertical = false
                }
                if usedLetters[index].row != firstRow {
                    horizontal = false
                }
            }
            switch (horizontal, vertical) {
            case (false,false): return .none
            case (true, false): return .horizontal
            case (false, true): return .vertical
            case (true, true): return .both
            }
        }
    }
    var usedLetters = [UsedLetter]()
    init(word: String = "", usedLetters: [UsedLetter] = [UsedLetter]()) {
        self.word = word
        self.usedLetters = usedLetters
    }
    public mutating func addLetter(letter: UsedLetter) {
        word.append(letter.letter)
        usedLetters.append(letter)
    }
    
    public mutating func removeFirstLetter() {
        for index in 1..<usedLetters.count {
            let reverseIndex = usedLetters.count - index
            if usedLetters.first!.row == usedLetters.last!.row { // horizontal ??
                usedLetters[reverseIndex].col = usedLetters[reverseIndex - 1].col
            } else {
                usedLetters[reverseIndex].row = usedLetters[reverseIndex - 1].row
            }
        }
        usedLetters.remove(at: 0)
        word.remove(at: word.startIndex)
    }
    
    public mutating func addFirstLetter(letter: UsedLetter) {
        let origCol = usedLetters[0].col
        let origRow = usedLetters[0].row
        let char = Character(letter.letter == "" ? emptyLetter : letter.letter)
        word.insert(char, at: word.startIndex)
        usedLetters.insert(letter, at: 0)
        let myDirection = direction
        switch myDirection {
        case .horizontal:
            let adder = letter.col < origCol ? -1 : 1
            for index in 0..<usedLetters.count {
                usedLetters[index].col += adder
            }
        case .vertical:
            let adder = letter.row < origRow ? -1 : 1
            for index in 0..<usedLetters.count {
                usedLetters[index].row += adder
            }
        default: break
        }
        usedLetters[0].col = origCol
        usedLetters[0].row = origRow
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


enum Direction: Int {
    case horizontal = 0, vertical, both, none
}


public protocol WTGameboardDelegate: class {
    
    /// Method called when a word is founded
    func showFoundedWords()
    /// method is called when an own word is chosed
//    func addOwnWordOld(word: String, creationIndex: Int, check: Bool)->Bool
    func addOwnWordNew(word: String, usedLetters: [UsedLetter])->Bool
    /// method is called when letters are moved on gameboard
    func setLettersMoved(colFrom: Int, rowFrom: Int, colTo: Int, rowTo: Int, length: Int)
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
//    var gameArray: [[WTGameboardItem]]?
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
    private let scoreProLetter = 10

    init(size: Int, parentScene: SKScene, delegate: WTGameboardDelegate) {
        self.size = size
        self.parentScene = parentScene
        self.blockSize = parentScene.frame.size.width * (GV.onIpad ? 0.70 : 0.90) / CGFloat(size)
        self.delegate = delegate
        super.init()
        createBackgroundShape(size: size)
        GV.gameArray = createNewGameArray(size: size)
//        printGameArray()
        for col in 0..<size {
            for row in 0..<size {
                GV.gameArray[col][row].position = grid!.gridPosition(col: col, row: row) //+
//                    CGPoint (x:parentScene.frame.midX, y:parentScene.frame.midY * 0.874)
                GV.gameArray[col][row].name = "GBD/\(col)/\(row)"
//                gameArray![col][row].setLetter(letter: "\(col)\(row)", status: .empty, color: .white)
                grid!.addChild(GV.gameArray[col][row])
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
            
            for j in 0..<size {
                gameArray[i].append( WTGameboardItem(blockSize: blockSize!, fontSize: parentScene.frame.width * 0.045) )
                gameArray[i][j].letter = emptyLetter
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
        _ = GV.gameArray[calculatedCol][calculatedRow].setLetter(letter: letter, status: .temporary, toColor: .myTemporaryColor)
            let usedItem = UsedItems(col: calculatedCol, row: calculatedRow, item: GV.gameArray[calculatedCol][calculatedRow])
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
            _ = GV.gameArray[calculatedCol][calculatedRow].setLetter(letter: letter, status: .temporary, toColor: .myTemporaryColor)
            let usedItem = UsedItems(col: calculatedCol, row: calculatedRow, item: GV.gameArray[calculatedCol][calculatedRow])
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
                        _ = GV.gameArray[col][row].setLetter(letter: letter, status: .used, toColor: .myUsedColor)
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
                let actItemStatus = usedItems[index].item!.status
                if actItemStatus == .used || actItemStatus == .wholeWord {
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
//                checkWholeWords()
                var gameArrayPositions = [GameArrayPositions]()
                for index in 0..<usedItems.count {
                    gameArrayPositions.append(GameArrayPositions(col:usedItems[index].col,row: usedItems[index].row))
                }
                shape.setGameArrayPositions(gameArrayPositions: gameArrayPositions)
            }
            return fixed  // when shape remaining on gameBoard, return true
        }
    }
    private  let scoreProWord: [Int] = [0, 0, 10, 30, 50, 80, 120, 180, 250, 330, 430, 550]
    
//    public func checkWholeWords() {
//        return
//        foundedWords.removeAll()
//        for col in 0..<size {
//            for row in 0..<size {
//                GV.gameArray[col][row].resetCountOccurences()
//                GV.gameArray[col][row].setGreenToUsedColor()
//            }
//        }
//        for col in 0..<GV.gameArray.count {
//            for row in 0..<GV.gameArray.count {
//                let letter = getLetter(col: col, row: row)
//                if letter != "" {
//                    for actWord in GV.allWords {
//                        if actWord.word.count > 0 {
//                            if letter == actWord.word.subString(startPos: 0, length: 1) {
//                                OKPositions.removeAll()
//                                if flyOverWord(compare: letter, col: col, row: row, fromCol: col, fromRow: row, withWord: actWord.word) {
//                                } else {
//                                }
//                            }
//                        }
//                    }
//                }
//            }
//        }
//        // analyze the repeated words: in 2 identical words my be only 1 letter with the same position
//       foundedWords.removeAll()
//       analyzeFoundedWords()
//        if roundInfos.count == GV.actRound {
//            roundInfos.append(RoundInfos())
//        }
//        if GV.actRound > roundInfos.count - 1 {
//            GV.actRound = roundInfos.count - 1
//        }
//        if roundInfos.count > 0 {
//            if roundInfos.last!.words.count > 0 {
//                roundInfos[roundInfos.count - 1].words.removeAll()
//            }
//        } else {
//            roundInfos.append(RoundInfos())
//        }
//        for foundedWord in foundedWords {
//            var color:MyColor = GV.allMandatoryWordsFounded() ? .myWholeWordColor : .myGoldColor
//            if GV.allWords.contains(where: {$0.word == foundedWord.word}) {
//                color = .myWholeWordColor
//            }
//            for letter in foundedWord.usedLetters {
//                var letterColor: MyColor = .myWholeWordColor
//                if GV.gameArray[letter.col][letter.row].myColor != .myWholeWordColor {
//                    letterColor = color
//                }
//                GV.gameArray[letter.col][letter.row].setFoundedWord(toColor: letterColor)
//                GV.gameArray[letter.col][letter.row].incrementCountOccurences()
//            }
//        }
//        for index in 0..<foundedWords.count {
//            var countLetterUsing = 0
//            for letter in foundedWords[index].usedLetters {
//                countLetterUsing += GV.gameArray[letter.col][letter.row].getCountOccurences()
//            }
//            var countLetters = foundedWords[index].word.count
//            countLetters = countLetters > 10 ? 11 : countLetters
//            foundedWords[index].score = scoreProWord[countLetters] + countLetterUsing * scoreProLetter
//        }
//        foundedWordsWithCount.removeAll()
//        for foundedWord in foundedWords {
//            var founded = false
//            if roundInfos.count > 0 {
//                for index in 0..<roundInfos.last!.words.count {
//                    if foundedWord.word == roundInfos.last!.words[index].word {
//                        roundInfos[roundInfos.count - 1].words[index].counter += 1
//                        roundInfos[roundInfos.count - 1].words[index].score += foundedWord.score
//                        founded = true
//                    }
//                }
//            }
//            for index in 0..<foundedWordsWithCount.count {
//                if foundedWord.word == foundedWordsWithCount[index].word {
//                    foundedWordsWithCount[index].counter += 1
//                    foundedWordsWithCount[index].score += foundedWord.score
//                    founded = true
//                }
//            }
//
//            if !founded {
//                foundedWordsWithCount.append(FoundedWordWithCounter(word: foundedWord.word, counter: 1, score: foundedWord.score))
//                roundInfos[roundInfos.count - 1].words.append(FoundedWordWithCounter(word: foundedWord.word, counter: 1, score: foundedWord.score))
//            }
//        }
//
//        for index in 0..<GV.allWords.count {
//            GV.allWords[index].countFounded = 0
//            GV.allWords[index].score = 0
//        }
//
//        for roundInfo in roundInfos {
//            for index in 0..<roundInfo.words.count {
//                for index1 in 0..<GV.allWords.count {
//                    if roundInfo.words[index].word == GV.allWords[index1].word {
//                        GV.allWords[index1].countFounded += roundInfo.words[index].counter
//                        GV.allWords[index1].score += roundInfo.words[index].score
//                    }
//                }
//            }
//        }

//        var wordDictionary = calculateCountersAndScores()
//        var foundedWordsToShow = [FoundedWordWithCounter]()
//        for (key, _) in wordDictionary {
//            foundedWordsToShow.append(wordDictionary[key]!)
//        }
//        delegate.showFoundedWords()
//    }
    
//    private func calculateCountersAndScores()->[String : FoundedWordWithCounter] {
//        var wordDictionary = [String: FoundedWordWithCounter]()
//        for index in 0..<roundInfos.count {
//            for wordInfos in roundInfos[index].words {
//                if wordDictionary[wordInfos.word] == nil {
//                    wordDictionary[wordInfos.word] = wordInfos
//                } else {
//                    wordDictionary[wordInfos.word] = FoundedWordWithCounter(
//                        word: wordInfos.word,
//                        counter: wordInfos.counter + wordDictionary[wordInfos.word]!.counter,
//                        score: wordInfos.score + wordDictionary[wordInfos.word]!.score
//                    )
//                }
//            }
//        }
//        return wordDictionary
//    }
    
//    var OKPositions = [UsedLetter]()
    
//    private func flyOverWord(compare: String, col: Int, row: Int, fromCol: Int, fromRow: Int, withWord: String)->Bool {
//        let myWord = compare
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
        
//        var returnBool = false
//        if myWord.count == withWord.count {
//            if myWord != withWord {
//                return false
//            } else {
//
//                OKPositions.append(UsedLetter(col:col, row: row, letter: GV.gameArray[col][row].letter))
//                if withWord == "МОЛОКО" {
//                    print("Stopped at \(withWord)")
//                    print("\(OKPositions)")
//                }
//                var positionOnce = true
//                for index0 in 0..<OKPositions.count - 1 {
//                    for index1 in index0 + 1..<OKPositions.count {
//                        if OKPositions[index0].col == OKPositions[index1].col && OKPositions[index0].row == OKPositions[index1].row {
//                            positionOnce = false
//                        }
//                    }
//                }
//                var word = ""
//                for okPosition in OKPositions {
//                    word += okPosition.letter
//                }
//                if positionOnce && word == withWord {
//                    foundedWords.append(FoundedWord(word: myWord, usedLetters: OKPositions))
//                }
//                if withWord == "МОЛОКО" {
//                    print ("\(searchString): \(positionOnce)")
//                }
//                return positionOnce
//            }
//        }
//        if myWord == withWord.subString(startPos: 0, length: myWord.count) {
//            OKPositions.append(UsedLetter(col:col, row: row, letter: GV.gameArray[col][row].letter))
//            if col > 0 && col - 1 != fromCol && !OKPositions.contains(where: {$0.col == col - 1 && $0.row == row}) {
//                let new = getLetter(col: col - 1, row: row)
//                if new != "" {
//                    if flyOverWord(compare: myWord + new, col: col - 1, row: row, fromCol: col, fromRow: row, withWord: withWord) {
//                        OKPositions.removeLast()
//                        returnBool = true
//                    }
//                }
//            }
//            if col < size - 1 && col + 1 != fromCol && !OKPositions.contains(where: {$0.col == col + 1 && $0.row == row}) {
//                let new = getLetter(col: col + 1, row: row)
//                if new != "" {
//                    if flyOverWord(compare: myWord + new, col: col + 1, row: row, fromCol: col, fromRow: row, withWord: withWord) {
//                        OKPositions.removeLast()
//                        returnBool = true
//                    }
//                }
//            }
//            if row > 0 && row - 1 != fromRow && !OKPositions.contains(where: {$0.col == col && $0.row == row - 1}) {
//                let new = getLetter(col: col, row: row - 1)
//                if new != "" {
//                    if flyOverWord(compare: myWord + new, col: col, row: row - 1, fromCol: col, fromRow: row, withWord: withWord) {
//                        OKPositions.removeLast()
//                        returnBool = true
//                    }
//                }
//            }
//            if row < size - 1 && row + 1 != fromRow && !OKPositions.contains(where: {$0.col == col && $0.row == row + 1}) {
//                let new = getLetter(col: col, row: row + 1)
//                if new != "" {
//                    if flyOverWord(compare: myWord + new, col: col, row: row + 1, fromCol: col, fromRow: row, withWord: withWord) {
//                        OKPositions.removeLast()
//                        returnBool = true
//                    }
//                }
//            }
//            if !returnBool && OKPositions.count > 0 {
//                OKPositions.removeLast()
//            }
//        }
//        return returnBool
//    }
    
//    private func analyzeFoundedWords() {
//        if foundedWords.count > 0 {
//            var indexesToRemove = [Int]()
//            foundedWords = foundedWords.sorted(by:{$0.word < $1.word})
//            var wordTable = [String: [UsedLetter]]()
//            for (index, foundedWord) in foundedWords.enumerated() {
//                if wordTable[foundedWord.word] == nil {
//                    wordTable[foundedWord.word] = foundedWord.usedLetters
//                } else {
//                    var appended = false
//                    for usedLetter in foundedWord.usedLetters {
//                        if !wordTable[foundedWord.word]!.contains(where: {$0 == usedLetter}) {
//                            wordTable[foundedWord.word]!.append(usedLetter)
//                            appended = true
//                        }
//                    }
//                    if !appended {
//                        indexesToRemove.append(index)
//                    }
//                }
//            }
//            if indexesToRemove.count > 0 {
//                let indexes = indexesToRemove.sorted(by: {$0 > $1})
//                for index in indexes {
//                    foundedWords.remove(at: index)
//                }
//            }
//        }
//    }
    
//    private func getLetter(col: Int, row: Int)->String {
//        if GV.gameArray[col][row].status == .used || GV.gameArray[col][row].status == .wholeWord {
//            return GV.gameArray[col][row].letter //children[0] as! SKLabelNode).text!
//        } else {
//            return ""
//        }
//    }
//    
    var moveModusStarted = false
    var noMoreMove = false
//    var lengthOfMovedItem = 0
//    var colFrom = 0
//    var rowFrom = 0
//    var colTo = 0
//    var rowTo = 0
    
    public func startChooseOwnWord(col: Int, row: Int) {
        moveModusStarted = false
        noMoreMove = false
        choosedWord = FoundedWord()
        choosedWord.addLetter(letter: UsedLetter(col: col, row: row, letter: GV.gameArray[col][row].letter))
        GV.gameArray[col][row].changeColor(toColor: .myBlueColor)
    }
    
    
    public func moveChooseOwnWord(col: Int, row: Int) {
        let actLetter = UsedLetter(col: col, row: row, letter: GV.gameArray[col][row].letter)
        let status = GV.gameArray[col][row].status
        // when in the same recteck
        if choosedWord.usedLetters.last! == actLetter {
            return
        }
        
        if moveModusStarted {
            // when going back
            if choosedWord.usedLetters.contains(where: {$0.col == actLetter.col && $0.row == actLetter.row}) {
                let last = choosedWord.usedLetters.last!
                if choosedWord.usedLetters.first!.letter == emptyLetter {
                    choosedWord.removeFirstLetter()
                    GV.gameArray[last.col][last.row].remove()
                    for letter in choosedWord.usedLetters {
                        if letter.letter != emptyLetter {
                            _ = GV.gameArray[letter.col][letter.row].setLetter(letter: letter.letter, status: .used, toColor: .myBlueColor, forcedChange: true)
                        }
                    }
                    return
                } else {
                    var tempChoosedWord = FoundedWord()
                    for index in 0..<choosedWord.word.count {
                        let reverseIndex = choosedWord.word.count - index - 1
                        tempChoosedWord.word.append(choosedWord.word.subString(startPos: reverseIndex, length: 1))
                        tempChoosedWord.usedLetters.append(choosedWord.usedLetters[reverseIndex])
                    }
                    choosedWord = tempChoosedWord
                    return
//                    gameArray![col][row].changeColor(toColor: .myBlueColor)
                }
            }
            else {
//                print("and hier? ActLetter: \(actLetter), status: \(status), noMoreMove: \(noMoreMove) ")
            }
        }

        var onlyUsedLetters = true
//        print("col: \(col), row: \(row), actLetter: \(actLetter.letter), NoMoreMove: \(noMoreMove)")
        if (status == .empty) { // empty block
            if !noMoreMove {
                if !moveModusStarted {
                    for letter in choosedWord.usedLetters {
                        if GV.gameArray[letter.col][letter.row].status == .wholeWord {
                            onlyUsedLetters = false
                        }
                    }
                }
                if onlyUsedLetters {
                    moveModusStarted = true
//                    lengthOfMovedItem = choosedWord.word.count
                    choosedWord.addFirstLetter(letter: actLetter)
                    for letter in choosedWord.usedLetters {
                        if letter.letter == emptyLetter {
                            _ = GV.gameArray[letter.col][letter.row].setLetter(letter: letter.letter, status: .empty, toColor: .myWhiteColor, forcedChange: true)
                        } else {
                            _ = GV.gameArray[letter.col][letter.row].setLetter(letter: letter.letter, status: .used, toColor: .myUsedColor, forcedChange: true)
                            GV.gameArray[letter.col][letter.row].changeColor(toColor: .myBlueColor)
                        }
                    }
                 }
            }
        } else { // Not empty field
            if !moveModusStarted {
               if choosedWord.usedLetters.count > 1 && choosedWord.usedLetters[choosedWord.usedLetters.count - 2] == actLetter {
                    let last = choosedWord.usedLetters.last!
                    GV.gameArray[last.col][last.row].changeColor(toColor: .myNoColor)
                    choosedWord.removeLast()
                } else {
//                    colTo = actLetter.col
//                    rowTo = actLetter.row
                    GV.gameArray[col][row].changeColor(toColor: .myBlueColor)
                    choosedWord.addLetter(letter: actLetter)
                }
            } else {
                noMoreMove = true
            }
        }
    }
    
    public func endChooseOwnWord(col: Int, row: Int)->FoundedWord? {
        for col in 0..<size {
            for row in 0..<size {
                if GV.gameArray[col][row].myColor == .myBlueColor {
                    GV.gameArray[col][row].changeColor(toColor: .myNoColor)
                }
            }
        }
        if moveModusStarted {
            var index = -1
            repeat {
                index += 1
            } while index < choosedWord.usedLetters.count && choosedWord.usedLetters[index].letter == emptyLetter 
            let length = choosedWord.usedLetters.count - index
            if length > 0 {
                let colFrom = choosedWord.usedLetters[0].col
                let rowFrom = choosedWord.usedLetters[0].row
                let colTo = choosedWord.usedLetters[index].col
                let rowTo = choosedWord.usedLetters[index].row
                delegate.setLettersMoved(colFrom: colFrom, rowFrom: rowFrom, colTo: colTo, rowTo: rowTo, length: length)
//                checkWholeWords()
            }
            return nil
        } else {
            if col < 0 || col >= size || row < 0 || row >= size {
                return nil
            }
            //        let actLetter = UsedLetters(col: col, row: row, letter: gameArray![col][row].letter)
            var word = ""
            var wordAdded = false
            for letter in choosedWord.usedLetters {
                word.append(letter.letter)
            }
            if word.count > 1 {
//                wordAdded = delegate.addOwnWordOld(word: word, creationIndex: NoValue, check: true)
                wordAdded = delegate.addOwnWordNew(word: word, usedLetters: choosedWord.usedLetters)
                clear()
            }
            if wordAdded {
                return choosedWord
            } else {
                return nil
            }
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
    
    public func moveItemToOrigPlace(movedItem: MovingItem) {
        var colFrom = movedItem.colTo
        var rowFrom = movedItem.rowTo
        var colTo = movedItem.colFrom
        var rowTo = movedItem.rowFrom
        if colFrom == colTo && rowFrom == rowTo {
            return
        }
        if movedItem.colFrom == movedItem.colTo {  //vertical moved
            let adder = movedItem.rowFrom < movedItem.rowTo ? 1 : -1
            for _ in 0..<movedItem.length {
                let letter = GV.gameArray[colFrom][rowFrom].letter
                _ = GV.gameArray[colTo][rowTo].setLetter(letter: letter, status: .used, toColor: .myUsedColor)
                GV.gameArray[colFrom][rowFrom].remove()
                rowFrom += adder
                rowTo += adder
            }
        } else {
            let adder = movedItem.colFrom < movedItem.colTo ? 1 : -1
            for _ in 0..<movedItem.length {
                let letter = GV.gameArray[colFrom][rowFrom].letter
                _ = GV.gameArray[colTo][rowTo].setLetter(letter: letter, status: .used, toColor: .myUsedColor)
                GV.gameArray[colFrom][rowFrom].remove()
                colFrom += adder
                colTo += adder
            }
        }
    }
    
    public func gameArrayToString()->String {
        var gameArrayString = ""
        for col in 0..<GV.gameArray.count {
            for row in 0..<GV.gameArray.count {
                gameArrayString += GV.gameArray[col][row].toString()
            }
        }
        return gameArrayString
    }
    
    public func stringToGameArray(string: String) {
        for index in 0..<size * size {
            let col = index / size
            let row = index % size
            GV.gameArray[col][row].restore(from: string.subString(startPos: 2 * index, length: 2))
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
                    } else if GV.gameArray[summarizedCol][summarizedRow].status != .empty {
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
    
//    public func setGameArrayPositionsToGreenIfNeeded(piece: WTPiece, pieceIndex: Int) {
//        if piece.myType != .NotUsed {
//            for (index, gameArrayPosition) in piece.gameArrayPositions.enumerated() {
//                let col = Int(gameArrayPosition)! / 10
//                let row = Int(gameArrayPosition)! % 10
//                if GV.gameArray[col][row].status == .empty {
//                    _ = GV.gameArray[col][row].setLetter(letter: piece.letters[index], status: .used, toColor: .myUsedColor)
////                    print("restored at piece: index: \(pieceIndex) col: \(col) row: \(row) letter: \(piece.letters[index])")
//                } else {
////                    print("not restored at piece: index: \(pieceIndex) col: \(col) row: \(row) letter: \(piece.letters[index])")
//                }
//            }
//        }
//    }
//
//
//
//
    public func clearGreenFieldsForNextRound() {
        foundedWordsWithCount.removeAll()
        for col in 0..<size {
            for row in 0..<size {
//                print("col: \(col), row: \(row), letter: \(gameArray![col][row].letter) ")
                GV.gameArray[col][row].clearIfUsed()
            }
        }
        roundInfos.append(RoundInfos())
    }
    
    public func removeFromGameboard(sprite: WTPiece) {
        let gameboardIndexes = sprite.gameArrayPositions
        for gbIndex in gameboardIndexes {
            if let col = Int(gbIndex.subString(startPos: 0, length: 1)) {
                if let row = Int(gbIndex.subString(startPos: 1, length: 1)) {
                    GV.gameArray[col][row].remove()
                }
            }
        }
    }
    
    public func clearGameArray() {
        for row in 0..<size {
            for col in 0..<size {
                GV.gameArray[col][row].remove()
            }
        }
    }
    
    public func printGameArray() {
        let line = "____________________________________________"
        for row in 0..<10 {
            var infoLine = "|"
            for col in 0..<10 {
                let char = GV.gameArray[col][row].letter
                var greenMark = emptyLetter
                if GV.gameArray[col][row].status == .wholeWord {
                    greenMark = "*"
                }
                infoLine += greenMark + (char == "" ? "!" : char) + greenMark + "|"
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

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
