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
    let fromToSeparator = "|"
    let dataSeparator = "?"
    var fromLetters = [UsedLetter]()
    var toLetters = [UsedLetter]()
    init(){
    }
    init(fromLetters: [UsedLetter], toLetters: [UsedLetter]) {
        self.fromLetters = fromLetters
        self.toLetters = toLetters
    }
    init(from: String){
        func convertStringToUsedLetters(inputString: String)->[UsedLetter] {
            //        let lettersString = inputString
            var letters = [UsedLetter]()
            var index = 0
            repeat {
                let col = Int(inputString.subString(startPos: index, length: 1))
                let row = Int(inputString.subString(startPos: index + 1, length: 1))
                let letter = inputString.subString(startPos: index + 1, length: 1)
                letters.append(UsedLetter(col: col!, row: row!, letter: letter))
                index += 3
            } while index >= inputString.count
            return letters
        }
        let components = from.components(separatedBy: roundSeparator)
        if components.count == 2 {
            let fromLetters = convertStringToUsedLetters(inputString: components[0])
            let toLetters = convertStringToUsedLetters(inputString: components[1])
            if fromLetters.count > 0 && toLetters.count > 0 {
                self.init(fromLetters: fromLetters, toLetters: toLetters)
            } else {
                self.init()
            }
        } else {
            self.init()
        }
    }
    
    func toString()->String {
        var returnString = ""
        for fromLetter in fromLetters {
            returnString += fromLetter.toString() + dataSeparator
        }
        if returnString.length > 1 {
            returnString.removeLast()
            returnString += fromToSeparator
        }
        for toLetter in toLetters {
            returnString += toLetter.toString() + dataSeparator
        }
        if returnString.length > 1 {
            returnString.removeLast()
        }
        return returnString
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
    func setLettersMoved(fromLetters: [UsedLetter], toLetters: [UsedLetter])
    /// method is called when waitingTimer has fired
    func setMovingSprite()
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
    var myPiece = WTPiece()
    var size: Int
    var grid: Grid?
    let blockSize: CGFloat?
    var shape: WTPiece = WTPiece()
    private var showingWords = false
    private var lastCol: Int = 0
    private var lastRow: Int = 0
    private var startCol: Int = 0
    private var startRow: Int = 0
    private var startLocation = CGPoint(x: 0, y: 0)
    private var usedItems = [UsedItems]()
    private var usedItemsOK = true
    private var choosedWord = FoundedWord() //[UsedLetter]()
    private var foundedWords = [FoundedWord]()
    private var roundInfos = [RoundInfos]()
    private var foundedWordsWithCount = [FoundedWordWithCounter]()
    private let scoreProLetter = 10

    init(size: Int, parentScene: SKScene, delegate: WTGameboardDelegate) {
        self.size = size
        self.parentScene = parentScene
        self.blockSize = parentScene.frame.size.width * (GV.onIpad ? 0.70 : 0.90) / CGFloat(size)
        self.delegate = delegate
        super.init()
        createBackgroundShape(size: size)
        GV.gameArray = createNewGameArray(size: size)
        for col in 0..<size {
            for row in 0..<size {
                GV.gameArray[col][row].position = grid!.gridPosition(col: col, row: row) //+
                GV.gameArray[col][row].name = "GBD/\(col)/\(row)"
                grid!.addChild(GV.gameArray[col][row])
            }
        }
        self.name = gameboardName
        parentScene.addChild(self)
        generateNetOfColsAndRows()
    }
    
    private func generateNetOfColsAndRows() {
        for col in 0..<size {
            let colSprite = SKSpriteNode()
            colSprite.position = grid!.gridPosition(col: col, row: 0) + CGPoint(x: grid!.frame.midX, y: grid!.frame.minY)
            colSprite.size = CGSize(width: blockSize!, height: parentScene.frame.height)
            colSprite.name = "Col\(col)"
            parentScene.addChild(colSprite)
        }
        let colSprite = SKSpriteNode()
        let col10Width = parentScene.frame.maxX - grid!.frame.maxX
        colSprite.position = CGPoint(x: grid!.frame.maxX + col10Width / 2, y: grid!.frame.midY)
        colSprite.size = CGSize(width: col10Width, height: parentScene.frame.height)
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
//                rowSprite.alpha = 1
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
    
    public func clear() {
        for index in 0..<usedItems.count {
            usedItems[index].item!.clearIfTemporary()
        }
        usedItems.removeAll()
        usedItemsOK = true
    }
    
    var showingSprite = false
    
    public func startShowingSpriteOnGameboard(shape: WTPiece, col: Int, row: Int)->Bool {
        showingSprite = true
        moveModusStarted = false
        self.shape = shape
        let formOfShape = myForms[shape.myType]![shape.rotateIndex]
        let (myCol, myRow) = analyseColAndRow(col: col, row: row, GRow: row - 2, formOfShape: formOfShape)
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

    public func moveSpriteOnGameboard(col: Int, row: Int, GRow: Int) -> Bool {
        let upDir = 0 // rotateIndex 0
        let rightDir = 1 // rotateIndex 1
        let downDir = 2 // rotateIndex 2
        let leftDir = 3 // rotateIndex 3
        let formOfShape = myForms[shape.myType]![shape.rotateIndex]
        let (myCol, myRow) = analyseColAndRow(col: col, row: row, GRow: GRow, formOfShape: formOfShape)
        if moveModusStarted {
            if (shape.rotateIndex == leftDir && col + shape.letters.count - 1 < size && col >= 0) || // OK
               (shape.rotateIndex == rightDir && col < size && col - shape.letters.count + 1 >= 0) || // OK
               (shape.rotateIndex == upDir && row + shape.letters.count - 1 < size && row >= 0) ||
               (shape.rotateIndex == downDir && row < size && row - shape.letters.count + 1 >= 0) {
                clear()
                for index in 0..<shape.children.count {
                    let letter = shape.letters[index]
                    let itemCol = formOfShape[index] % 10
                    let itemRow = formOfShape[index] / 10
                    var calculatedCol = 0
                    var calculatedRow = 0
                    let rowX = (row == 1 && GRow >= 0) ? GRow : (row == 1 && GRow < 0) ? row - 1 : row
                    switch shape.rotateIndex {
                    case leftDir: // OK
                        calculatedCol = myCol + itemCol
                        calculatedRow = rowX - itemRow //+ shape.letters.count - 1
                   case rightDir:  // OK
                        calculatedCol = col + itemCol - shape.letters.count + 1
                        calculatedRow = rowX - itemRow //+ shape.letters.count - 1
                    case upDir:
                        calculatedCol = myCol
                         calculatedRow = rowX - itemRow + shape.letters.count - 1
                    case downDir:
                        calculatedCol = myCol
                        calculatedRow = row - itemRow < 0 ? 0 : row - itemRow > size - 1 ? size - 1 : row - itemRow
                    default: break
                    }
                    if calculatedRow > size - 1 {
                        calculatedRow = size - 1
                    }
                  _ = GV.gameArray[calculatedCol][calculatedRow].setLetter(letter: letter, status: .temporary, toColor: .myTemporaryColor)
                    let usedItem = UsedItems(col: calculatedCol, row: calculatedRow, item: GV.gameArray[calculatedCol][calculatedRow])
                    usedItems.append(usedItem)
                }
            }

        } else {
            clear()
            if myRow == size {
                return true
            }
            for index in 0..<shape.children.count {
                let letter = shape.letters[index]
                let itemCol = formOfShape[index] % 10
                let itemRow = formOfShape[index] / 10
                let calculatedCol = myCol + itemCol // - adder
                let calculatedRow = myRow - itemRow < 0 ? 0 : myRow - itemRow > size - 1 ? size - 1 : myRow - itemRow
                _ = GV.gameArray[calculatedCol][calculatedRow].setLetter(letter: letter, status: .temporary, toColor: .myTemporaryColor)
                let usedItem = UsedItems(col: calculatedCol, row: calculatedRow, item: GV.gameArray[calculatedCol][calculatedRow])
                usedItems.append(usedItem)
            }
        }
        return false
    }
    
    private func analyseColAndRow(col: Int, row: Int, GRow: Int, formOfShape: [Int])->(Int, Int) {
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
        
        if myRow == 1 && GRow == 0 {
            myRow = 0
        }
        
        if myCol + maxCol > size - 1 {
            myCol = size - maxCol - 1
        }
        
        if myCol < 0 {
            myCol = 0
        }
        return (myCol, myRow)

    }
    
    public func stopShowingSpriteOnGameboard(col: Int, row: Int, fromBottom: Bool /*, wordsToCheck: [String]*/)->Bool {
        showingSprite = false
        var fixed = true
//        self.wordsToCheck = wordsToCheck
        if row == 10 {
            if fromBottom {
                for index in 0..<usedItems.count {
                    usedItems[index].item!.clearIfTemporary()
                }
                return false  // when shape not remaining on gameBoard, return false
            }
         }
        var clearNeaded = false
        for usedItem in usedItems {
            let actItemStatus = usedItem.item!.status
            if actItemStatus == .used || actItemStatus == .wholeWord {
                clearNeaded = true
                break
            }
        }
        if clearNeaded {
            if !fromBottom {
                for index in 0..<usedItems.count {
                    if index < origChoosedWord.usedLetters.count {
                        let origCol = origChoosedWord.usedLetters[index].col
                        let origRow = origChoosedWord.usedLetters[index].row
                        let letter = origChoosedWord.usedLetters[index].letter
                        let actCol = usedItems[index].col
                        let actRow = usedItems[index].row
                        _ = GV.gameArray[origCol][origRow].setLetter(letter: letter, status: .used, toColor: .myUsedColor)
                        _ = GV.gameArray[actCol][actRow].clearIfTemporary()
                    }
                }
            } else {
                clear()
            }
            return false
        } else {
            for usedItem in usedItems {
                fixed = fixed && usedItem.item!.fixIfTemporary()
            }
        }
        if fixed {
//                checkWholeWords()
            var gameArrayPositions = [GameArrayPositions]()
            for index in 0..<usedItems.count {
                gameArrayPositions.append(GameArrayPositions(col:usedItems[index].col,row: usedItems[index].row))
            }
            shape.setGameArrayPositions(gameArrayPositions: gameArrayPositions)
            if !fromBottom {
                    delegate.setLettersMoved(fromLetters: origChoosedWord.usedLetters, toLetters: shape.usedLetters)
            }
        }
        return fixed  // when shape remaining on gameBoard, return true
    }
    
    var moveModusStarted = false
    var noMoreMove = false
    public func startChooseOwnWord(col: Int, row: Int) {
        moveModusStarted = false
        noMoreMove = false
        if showingWords {
//            WTGameWordList.shared.stopShowingWords()
            showingWords = false
        }
        choosedWord = FoundedWord()
        choosedWord.addLetter(letter: UsedLetter(col: col, row: row, letter: GV.gameArray[col][row].letter))
        GV.gameArray[col][row].changeColor(toColor: .myBlueColor)
    }
    
    var origChoosedWord = FoundedWord()

    public func moveChooseOwnWord(col: Int, row: Int)->Bool {
        let actLetter = UsedLetter(col: col, row: row, letter: GV.gameArray[col][row].letter)
        GV.gameArray[col][row].correctStatusIfNeeded()
        let status = GV.gameArray[col][row].status
        // when in the same position
        if choosedWord.usedLetters.last! == actLetter {
            return false
        }
        
        if (status == .empty) { // empty block
            if setMoveModusIfPossible() {
                return true
            }
        } else { // Not empty field
               if choosedWord.usedLetters.count > 1 && choosedWord.usedLetters[choosedWord.usedLetters.count - 2] == actLetter {
                    let last = choosedWord.usedLetters.last!
                    GV.gameArray[last.col][last.row].changeColor(toColor: .myNoColor)
                    choosedWord.removeLast()
                } else {
                    if choosedWord.usedLetters.count > 0 {
                        if abs(choosedWord.usedLetters.last!.col - col) == 1 && abs(choosedWord.usedLetters.last!.row - row) == 1 {
                            if setMoveModusIfPossible() {
                                return true
                            }
                        }
                    }
                    GV.gameArray[col][row].changeColor(toColor: .myBlueColor)
                    choosedWord.addLetter(letter: actLetter)
                }
        }
        return false
    }
    
    private func setMoveModusIfPossible()->Bool {
        var onlyUsedLetters = true
        if !moveModusStarted {
            for letter in choosedWord.usedLetters {
                if GV.gameArray[letter.col][letter.row].status == .wholeWord {
                    onlyUsedLetters = false
                }
            }
        }
        if onlyUsedLetters {
            myPiece = WTPiece(fromChoosedWord: choosedWord, parent: parentScene, blockSize: blockSize!)
            if myPiece.myType != .NotUsed {
                origChoosedWord = choosedWord
                if startShowingSpriteOnGameboard(shape: myPiece, col: choosedWord.usedLetters[0].col, row: choosedWord.usedLetters[0].row) {
                    for usedLetter in choosedWord.usedLetters {
                        GV.gameArray[usedLetter.col][usedLetter.row].remove()
                    }
                    moveModusStarted = true
                    return true
                }
            }
        }
        return false
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
    

    public func setRoundInfos() {
        roundInfos.removeAll()
        var index = 0
        for round in GV.playingRecord.rounds {
            roundInfos.append(RoundInfos())
            let items = round.infos.components(separatedBy: itemSeparator)
            for item in items {
                let itemData = item.components(separatedBy: itemInnerSeparator)
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
        for index in 0..<movedItem.fromLetters.count {
            let colFrom = movedItem.fromLetters[index].col
            let rowFrom = movedItem.fromLetters[index].row
            let colTo = movedItem.toLetters[index].col
            let rowTo = movedItem.toLetters[index].row
            let letter = movedItem.fromLetters[index].letter
            _ = GV.gameArray[colFrom][rowFrom].setLetter(letter: letter, status: .used, toColor: .myUsedColor)
            GV.gameArray[colTo][rowTo].remove()
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
                    infoString += item.word + itemInnerSeparator + String(item.score) + itemInnerSeparator + String(item.counter) + itemSeparator
                 }
                if infoString.count > 0 {
                    infoString.removeLast()
                    infoString += roundSeparator
                }
            }
        } else {
            let lastRound = roundInfos.last!
            for item in lastRound.words {
                infoString += item.word + itemInnerSeparator + String(item.score) + itemInnerSeparator + String(item.counter) + itemSeparator
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
    
    public func clearGreenFieldsForNextRound() {
        for col in 0..<size {
            for row in 0..<size {
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
    
    public func getCellPosition(col: Int, row: Int)->CGPoint {
        let addPosition = grid!.position
        return grid!.gridPosition(col: col, row: row) + addPosition
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
                if GV.gameArray[col][row].doubleUsed {
                    greenMark = "!"
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
