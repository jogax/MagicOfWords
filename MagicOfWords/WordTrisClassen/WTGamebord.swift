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
    private var showingWords = false
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
    
    
    var moveModusStarted = false
    var noMoreMove = false
    public func startChooseOwnWord(col: Int, row: Int) {
        moveModusStarted = false
        noMoreMove = false
        if showingWords {
            WTGameWordList.shared.stopShowingWords()
            showingWords = false
        }
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
                print("and hier? ActLetter: \(actLetter), status: \(status), noMoreMove: \(noMoreMove) ")
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
            } else {
                showingWords = true
                if choosedWord.usedLetters[0].letter != emptyLetter {
                    WTGameWordList.shared.showWordsContainingThisLetter(choosedWord: choosedWord)
                }
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
