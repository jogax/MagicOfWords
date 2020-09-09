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
extension UsedLetter: Equatable {}

public func ==(lhs: UsedLetter, rhs: UsedLetter) -> Bool {
    let areEqual = lhs.col == rhs.col && lhs.row == rhs.row

    return areEqual
}

public struct UsedLetterWithCounter {
    var col: Int = 0
    var row: Int = 0
    var letter: String = emptyLetter
    var freeCount: Int = 0
    init(col: Int, row: Int, letter: String, freeCount: Int) {
        self.col = col
        self.row = row
        self.letter = letter
        self.freeCount = freeCount
    }
    func freeDistance(to: UsedLetterWithCounter)->Int {        
        let distance = abs(self.col - to.col) + abs(self.row - to.row) - 1
        var colAdder = self.col == to.col ? 0 : (self.col < to.col ? 1 : -1)
        var rowAdder = self.row == to.row ? 0 : (self.row < to.row ? 1 : -1)
        var actCol = self.col
        var actRow = self.row
        repeat {
            if colAdder != 0 {
                actCol += colAdder
                if actCol == to.col && actRow == to.row {
                    return distance
                }
                if !(GV.gameArray[actCol][actRow].status == .Empty || (GV.gameArray[actCol][actRow].status == .Used && !GV.gameArray[actCol][actRow].fixItem)) {
                    actCol -= colAdder
                    if rowAdder == 0 {
                        return 0
                    }
                    actRow += rowAdder
                    if !(GV.gameArray[actCol][actRow].status == .Empty || (GV.gameArray[actCol][actRow].status == .Used && !GV.gameArray[actCol][actRow].fixItem)) {
                        return 0
                    }
                }
            } else {
                actRow += rowAdder
                if actCol == to.col && actRow == to.row {
                    return distance
                }
                if !(GV.gameArray[actCol][actRow].status == .Empty || (GV.gameArray[actCol][actRow].status == .Used && !GV.gameArray[actCol][actRow].fixItem)) {
                    actRow -= rowAdder
                    if colAdder == 0 {
                        return 0
                    }
                    actCol += colAdder
                    if !(GV.gameArray[actCol][actRow].status == .Empty || (GV.gameArray[actCol][actRow].status == .Used && !GV.gameArray[actCol][actRow].fixItem)) {
                        return 0
                    }
                }
            }
            colAdder = actCol == to.col ? 0 : colAdder
            rowAdder = actRow == to.row ? 0 : rowAdder

        } while !(actCol == to.col && actRow == to.row)
        return distance
    }
}
extension UsedLetterWithCounter: Equatable {}

public func ==(lhs: UsedLetterWithCounter, rhs: UsedLetterWithCounter) -> Bool {
    let areEqual = lhs.col == rhs.col && lhs.row == rhs.row

    return areEqual
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
                let col = Int(inputString.subString(at: index, length: 1))
                let row = Int(inputString.subString(at: index + 1, length: 1))
                let letter = inputString.subString(at: index + 1, length: 1)
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
        if usedLetters.count > 0 {
            checkContinuity(letter: letter)
        }
        word.append(letter.letter)
        usedLetters.append(letter)
    }
    
    private mutating func checkContinuity(letter:UsedLetter) {
        func saveLetter(col: Int, row: Int) {
            GV.gameArray[col][row].setStatus(toStatus: .Temporary)
            let actLetter = GV.gameArray[col][row].letter
            let newLetter = UsedLetter(col: col, row: row, letter: actLetter)
            word.append(newLetter.letter)
            usedLetters.append(newLetter)
        }
        let actLetter = letter
        let lastLetter = usedLetters.last!
        if actLetter.col == lastLetter.col {
                if actLetter.row - 1 > lastLetter.row {
                    let col = actLetter.col
                    for row in lastLetter.row + 1...actLetter.row - 1 {
                        saveLetter(col: col, row: row)
                    }
                } else if lastLetter.row - 1 > actLetter.row {
                    let col = actLetter.col
                    for row in actLetter.row + 1...lastLetter.row - 1 {
                        saveLetter(col: col, row: row)
                    }
            }
        }
        if actLetter.row == lastLetter.row {
            if actLetter.col - 1 > lastLetter.col {
                let row = actLetter.row
                for col in lastLetter.col + 1...actLetter.col - 1 {
                    saveLetter(col: col, row: row)
                }
            } else if lastLetter.col - 1 > actLetter.col {
                let row = actLetter.row
                for col in actLetter.col + 1...lastLetter.col - 1 {
                    saveLetter(col: col, row: row)
                }
            }
        }

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
//    var minutes: Int = 0
    init(word: String, counter: Int, score: Int) {
        self.word = word
        self.counter = counter
        self.score = score
//        self.minutes = minutes
    }
}

public struct GameArrayPositions {
    var col: Int
    var row: Int
}
enum ConnectionTo: Int {
   case up, down, left, right
}

public struct GameArrayPositionsWithRelations {
    var col: Int = 0
    var row: Int = 0
    var free: Bool = false
    var up: Bool = false
    var down: Bool = false
    var left: Bool = false
    var right: Bool = false
    var countConnections = 0
    init(col: Int, row: Int) {
        self.col = col
        self.row = row
    }
}

extension GameArrayPositionsWithRelations: Equatable {}

public func ==(lhs: GameArrayPositionsWithRelations, rhs: GameArrayPositionsWithRelations) -> Bool {
    let areEqual = lhs.col == rhs.col && lhs.row == rhs.row

    return areEqual
}

public struct FreeArray {
    var countFree = 0
    var numberOfFreeArray = 0
    var freePlaces = [GameArrayPositionsWithRelations]()
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
//    func setMovingSprite()
}


let WSGameboardSizeMultiplier:CGFloat = 2.0
//func == (left: UsedLetter, right: UsedLetter) -> Bool {
//    return left.col == right.col && left.row == right.row && left.letter == right.letter
//}

func == (left: FoundedWord, right: FoundedWord) -> Bool {
    return left.word == right.word
}


class WTGameboard: SKShapeNode {
    var delegate: WTGameboardDelegate
    var parentScene: SKScene
    var myPiece = WTPiece()
    var countCols: Int
    var grid: Grid?
//    let blockSize: CGFloat?
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
    private var yCenter: CGFloat = 0
    

    init(countCols: Int, parentScene: SKScene, delegate: WTGameboardDelegate, yCenter: CGFloat) {
        let blockSizeMultiplierForIpad: [Int:CGFloat] = [5: 0.08, 6: 0.08, 7: 0.08, 8: 0.075, 9: 0.07, 10: 0.065, 11: 0.060, 12: 0.055]
        let blockSizeMultiplierForIPhone: [Int:CGFloat] = [5: 0.15, 6: 0.14, 7: 0.13, 8: 0.11, 9: 0.10, 10: 0.090, 11:0.078, 12: 0.075]

        self.countCols = GV.sizeOfGrid
        self.parentScene = parentScene
//        let onIPhoneValue: CGFloat = GV.onIPhone5 ? 0.80 : 0.85
        GV.blockSize = GV.onIpad ?
            blockSizeMultiplierForIpad [GV.sizeOfGrid]! * GV.minSide : blockSizeMultiplierForIPhone [GV.sizeOfGrid]! * GV.minSide
        self.delegate = delegate
        self.yCenter = yCenter
        super.init()
        createBackgroundShape(countCols: countCols)
        GV.gameArray = createNewGameArray(countCols: countCols)
        for col in 0..<countCols {
            for row in 0..<countCols {
                GV.gameArray[col][row].plPosSize = grid!.gridPosition(col: col, row: row) //+
                GV.gameArray[col][row].name = "GBD/\(col)/\(row)"
                grid!.addChild(GV.gameArray[col][row])
//                bgSprite!.addChild(GV.gameArray[col][row])
            }
        }
        self.name = gameboardName
        self.zPosition = -1
        bgSprite!.addChild(self)
        generateNetOfColsAndRows()
    }
    
    private func generateNetOfColsAndRows() {
        for col in 0..<countCols {
            let colSprite = SKSpriteNode()
            colSprite.nodeType = .SKSpriteNode
            colSprite.plPosSize = grid!.gridPosition(col: col, row: 0) +
                PLPosSize(
                    PPos: CGPoint(x: grid!.plPosSize!.PPos.x, y: grid!.plPosSize!.PPos.y - grid!.frame.height / 2),
                    LPos: CGPoint(x: grid!.plPosSize!.LPos.x, y: grid!.plPosSize!.LPos.y - grid!.frame.height / 2)
            )
            colSprite.size = CGSize(width: GV.blockSize, height: parentScene.frame.height)
            colSprite.name = "Col\(col)"
//            if col % 2 == 0 {
//                colSprite.alpha = 0.5
//                colSprite.color = .red
//            }

            bgSprite!.addChild(colSprite)
        }
        let colSprite = SKSpriteNode()
        colSprite.nodeType = .SKSpriteNode
        let col10Width = parentScene.frame.maxX - grid!.frame.maxX
        colSprite.position = CGPoint(x: grid!.frame.maxX + col10Width / 2, y: grid!.frame.midY)
        colSprite.size = CGSize(width: col10Width, height: parentScene.frame.height)
        colSprite.name = "Col\(countCols)"
        bgSprite!.addChild(colSprite)
        
        let rowSprite = SKSpriteNode()
        rowSprite.nodeType = .SKSpriteNode
        let row10Height = grid!.frame.minY - parentScene.frame.minY
        rowSprite.plPosSize = PLPosSize(PPos: CGPoint(x: GV.minSide / 2, y: grid!.frame.minY - row10Height / 2) - CGPoint(x: 0, y: WSGameboardSizeMultiplier * GV.blockSize),
                                        LPos: CGPoint(x: GV.maxSide / 2, y: grid!.frame.minY - row10Height / 2) - CGPoint(x: 0, y: WSGameboardSizeMultiplier * GV.blockSize),
                                        PSize: CGSize(width: GV.minSide, height: row10Height),
                                        LSize: CGSize(width: GV.maxSide, height: row10Height))
//        rowSprite.color = .blue
        rowSprite.name = "Row\(countCols)"
        bgSprite!.addChild(rowSprite)
        for row in 0..<countCols {
            let rowSprite = SKSpriteNode()
            rowSprite.nodeType = .SKSpriteNode
            rowSprite.plPosSize = PLPosSize(
                PPos: CGPoint(x: 0, y: (grid!.plPosSize?.PPos.y)!) - grid!.gridPosition(col: 0, row: row).PPos - CGPoint(x: 0, y: WSGameboardSizeMultiplier * GV.blockSize),
                LPos: CGPoint(x: 0, y: (grid!.plPosSize?.LPos.y)!) - grid!.gridPosition(col: 0, row: row).LPos - CGPoint(x: 0, y: WSGameboardSizeMultiplier * GV.blockSize),
                PSize: CGSize(width: GV.minSide * 2, height: GV.blockSize),
                LSize: CGSize(width: GV.maxSide * 2, height: GV.blockSize)
            )
//            if row % 2 == 0 {
//                rowSprite.alpha = 0.5
//                rowSprite.color = .green
//            }
            rowSprite.name = "Row\(countCols - 1 - row)"
            bgSprite!.addChild(rowSprite)
        }
    }
    public func createNewGameArray(countCols: Int) -> [[WTGameboardItem]] {
        var gameArray: [[WTGameboardItem]] = []
        
        for i in 0..<countCols {
            gameArray.append( [WTGameboardItem]() )
            
            for j in 0..<countCols {
                gameArray[i].append( WTGameboardItem(blockSize: GV.blockSize, fontSize: parentScene.frame.width * 0.040) )
                _ = gameArray[i][j].setLetter(letter: emptyLetter, toStatus: .Empty, calledFrom: "")
            }
        }
        return gameArray
    }

    private func createBackgroundShape(countCols: Int) {
        //        let myShape =

        grid = Grid(blockSize: GV.blockSize, rows:countCols, cols:countCols)
        grid!.plPosSize = PLPosSize(PPos: CGPoint (x: GV.minSide * 0.5, y: GV.maxSide * yCenter),
                                    LPos: CGPoint (x: GV.maxSide * 0.5, y: GV.minSide * 0.5))
            
        grid!.name = gridName
        grid!.setActPosSize()
        grid!.nodeType = .Grid
//        self.addChild(grid!)
//        grid!.zPosition = 100
        bgSprite!.addChild(grid!)
    }
    
    public func getGridSize()->CGSize {
        return grid!.size
    }
    
    public func getGridPosition()->CGPoint {
        return grid!.position
    }
    
    
    public func clear() {
        for index in 0..<usedItems.count {
            usedItems[index].item!.clearIfTemporary(col: usedItems[index].col, row: usedItems[index].row)
        }
        usedItems.removeAll()
        usedItemsOK = true
    }
    
    var showingSprite = false
    
    public func startShowingSpriteOnGameboard(shape: WTPiece, col: Int, row: Int)->Bool {
        showingSprite = true
        moveModusStarted = false
        self.shape = shape
        let formOfShape = myForms[shape.myType]![shape.rotateIndex].points
        let (myCol, myRow) = analyseColAndRow(col: col, row: row, GRow: row - 2, formOfShape: formOfShape)
        if myRow == countCols {
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
        _ = GV.gameArray[calculatedCol][calculatedRow].setLetter(letter: letter, toStatus: .Temporary, calledFrom: "startShowingSpriteOnGameboard")
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
        let formOfShape = myForms[shape.myType]![shape.rotateIndex].points
        let (myCol, myRow) = analyseColAndRow(col: col, row: row, GRow: GRow, formOfShape: formOfShape)
        if moveModusStarted {
            if (shape.rotateIndex == leftDir && col + shape.letters.count - 1 < countCols && col >= 0) || // OK
               (shape.rotateIndex == rightDir && col < countCols && col - shape.letters.count + 1 >= 0) || // OK
               (shape.rotateIndex == upDir && row + shape.letters.count - 1 < countCols && row >= 0) ||
               (shape.rotateIndex == downDir && row < countCols && row - shape.letters.count + 1 >= 0) {
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
                        calculatedRow = row - itemRow < 0 ? 0 : row - itemRow > countCols - 1 ? countCols - 1 : row - itemRow
                    default: break
                    }
                    if calculatedRow > countCols - 1 {
                        calculatedRow = countCols - 1
                    }
                    _ = GV.gameArray[calculatedCol][calculatedRow].setLetter(letter: letter, toStatus: .Temporary, calledFrom: "moveSpriteOnGameboard - 1")
                    let usedItem = UsedItems(col: calculatedCol, row: calculatedRow, item: GV.gameArray[calculatedCol][calculatedRow])
                    usedItems.append(usedItem)
                }
            }

        } else {
            clear()
            if myRow == countCols {
                return true
            }
            for index in 0..<shape.children.count {
                let letter = shape.letters[index]
                let itemCol = formOfShape[index] % 10
                let itemRow = formOfShape[index] / 10
                let calculatedCol = myCol + itemCol // - adder
                let calculatedRow = myRow - itemRow < 0 ? 0 : myRow - itemRow > countCols - 1 ? countCols - 1 : myRow - itemRow
                _ = GV.gameArray[calculatedCol][calculatedRow].setLetter(letter: letter, toStatus: .Temporary, calledFrom: "moveSpriteOnGameboard - 2")
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
        
        if myCol + maxCol > countCols - 1 {
            myCol = countCols - maxCol - 1
        }
        
        if myCol < 0 {
            myCol = 0
        }
        return (myCol, myRow)

    }
    
    public func stopShowingSpriteOnGameboard(col: Int, row: Int, fromBottom: Bool /*, wordsToCheck: [String]*/)->(Bool, String) {
        showingSprite = false
        var fixed = true
        var letters = ""
//        self.wordsToCheck = wordsToCheck
        if row == GV.sizeOfGrid {
            if fromBottom {
                for index in 0..<usedItems.count {
                    usedItems[index].item!.clearIfTemporary(col: usedItems[index].col, row: usedItems[index].row)
                }
                return (false, "")  // when shape not remaining on gameBoard, return false
            }
         }
        var clearNeaded = false
        for usedItem in usedItems {
            let actItemStatus = usedItem.item!.status
            if actItemStatus == .Used || actItemStatus == .WholeWord || actItemStatus == .Error {
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
                        _ = GV.gameArray[origCol][origRow].setLetter(letter: letter, toStatus: .Used, calledFrom: "stopShowingSpriteOnGameboard")
                        _ = GV.gameArray[actCol][actRow].clearIfTemporary(col: actCol, row: actRow)
                    }
                }
            } else {
                clear()
            }
            return (false, "")
        } else {
            for usedItem in usedItems {
                fixed = fixed && usedItem.item!.fixIfTemporary()
            }
        }
        if fixed {
//                checkWholeWords()
            var gameArrayPositions = [GameArrayPositions]()
            for (index, item) in usedItems.enumerated() {
                gameArrayPositions.append(GameArrayPositions(col:usedItems[index].col,row: usedItems[index].row))
                letters += item.item!.letter
            }
            shape.setGameArrayPositions(gameArrayPositions: gameArrayPositions)
            if !fromBottom {
                    delegate.setLettersMoved(fromLetters: origChoosedWord.usedLetters, toLetters: shape.usedLetters)
            }
        }
        return (fixed, letters)  // when shape remaining on gameBoard, return true
    }
    
    var moveModusStarted = false
    var noMoreMove = false
    
    public func startChooseOwnWord(col: Int, row: Int) {
        moveModusStarted = false
        noMoreMove = false
        stopChoosing = false
        if showingWords {
//            WTGameWordList.shared.stopShowingWords()
            showingWords = false
        }
        choosedWord = FoundedWord()
        choosedWord.addLetter(letter: UsedLetter(col: col, row: row, letter: GV.gameArray[col][row].letter))
        GV.gameArray[col][row].setStatus(toStatus: .Temporary)
    }
    
    var origChoosedWord = FoundedWord()
    var stopChoosing = false

    public func setMoveModusBecauseOfTimer(col: Int, row: Int)->Bool {
        myPiece = WTPiece(fromChoosedWord: choosedWord, parent: parentScene, blockSize: GV.blockSize)
        if myPiece.myType != .NotUsed {
            origChoosedWord = choosedWord
            if startShowingSpriteOnGameboard(shape: myPiece, col: choosedWord.usedLetters[0].col, row: choosedWord.usedLetters[0].row) {
//                for usedLetter in choosedWord.usedLetters {
//                    GV.gameArray[usedLetter.col][usedLetter.row].remove()
//                }
                moveModusStarted = true
                return true
            }
        }
        return false
//        return setMoveModusIfPossible(col: col, row: row)
    }
    
    public func moveChooseOwnWord(col: Int, row: Int)->Bool {
        if choosedWord.usedLetters.count == 0 {
            return false
        }
        let actLetter = UsedLetter(col: col, row: row, letter: GV.gameArray[col][row].letter)
        GV.gameArray[col][row].correctStatusIfNeeded()
        let status = GV.gameArray[col][row].status
        // when in the same position
        if choosedWord.usedLetters.last! == actLetter {
            return false
        }
        if (status == .Empty) { // empty block
            if setMoveModusIfPossible(col: col, row: row) {
                return true
            } else {
                for letter in choosedWord.usedLetters {
                    GV.gameArray[letter.col][letter.row].setStatus(toStatus: .OrigStatus)
                }
                choosedWord = FoundedWord()
                return false
            }
        } else { // Not empty field
               if choosedWord.usedLetters.count > 1 && choosedWord.usedLetters[choosedWord.usedLetters.count - 2] == actLetter {
                    let last = choosedWord.usedLetters.last!
                    GV.gameArray[last.col][last.row].setStatus(toStatus: .OrigStatus)
                    choosedWord.removeLast()
                } else {
                    if choosedWord.usedLetters.count > 0 {
                        if abs(choosedWord.usedLetters.last!.col - col) == 1 && abs(choosedWord.usedLetters.last!.row - row) == 1 || !(choosedWord.usedLetters.last!.col == col || choosedWord.usedLetters.last!.row == row)
                        {
                            if setMoveModusIfPossible(col: col, row: row) {
                                return true
                            } else {
                                stopChoosing = true
                            }
                        }
                    }
                    if !stopChoosing {

                        if GV.gameArray[col][row].letter == " " {
                            return false
                        }
                        GV.gameArray[col][row].setStatus(toStatus: .Temporary)
                        choosedWord.addLetter(letter: actLetter)
                    }
                }
        }
        return false
    }
    
    private func setMoveModusIfPossible(col: Int, row: Int)->Bool {
        var onlyUsedLetters = true
        var startsWithLetters = FoundedWord()
        if !moveModusStarted {
            for letter in choosedWord.usedLetters {
                if !GV.gameArray[letter.col][letter.row].moveable {
                    onlyUsedLetters = false
                } else if onlyUsedLetters {
                    startsWithLetters.addLetter(letter: letter)
                }
            }
        }
        if onlyUsedLetters {
            myPiece = WTPiece(fromChoosedWord: choosedWord, parent: parentScene, blockSize: GV.blockSize)
            if myPiece.myType != .NotUsed {
                origChoosedWord = choosedWord
                if startShowingSpriteOnGameboard(shape: myPiece, col: choosedWord.usedLetters[0].col, row: choosedWord.usedLetters[0].row) {
                    for usedLetter in choosedWord.usedLetters {
                        GV.gameArray[usedLetter.col][usedLetter.row].remove()
                    }
                    moveModusStarted = true
                    return true
                }
            } else {
                for usedLetter in choosedWord.usedLetters {
                    GV.gameArray[usedLetter.col][usedLetter.row].setStatus(toStatus: .OrigStatus)
                }
                choosedWord = FoundedWord()
            }
        } else {
            if startsWithLetters.usedLetters.count > 0 {
                var sameCol = true
                var sameRow = true
                let startCol = startsWithLetters.usedLetters.first!.col
                let startRow = startsWithLetters.usedLetters.first!.row
                for letter in startsWithLetters.usedLetters {
                    sameCol = sameCol && startCol == letter.col
                    sameRow = sameRow && startRow == letter.row
                }
                if sameCol || sameRow {
                    for letter in choosedWord.usedLetters {
                        GV.gameArray[letter.col][letter.row].setStatus(toStatus: .OrigStatus)
                    }
                    myPiece = WTPiece(fromChoosedWord: startsWithLetters, parent: parentScene, blockSize: GV.blockSize)
                    if myPiece.myType != .NotUsed {
                        origChoosedWord = startsWithLetters
                        if startShowingSpriteOnGameboard(shape: myPiece, col: startsWithLetters.usedLetters[0].col, row: startsWithLetters.usedLetters[0].row) {
                            for usedLetter in startsWithLetters.usedLetters {
                                GV.gameArray[usedLetter.col][usedLetter.row].remove()
                            }
                            moveModusStarted = true
                            return true
                        }
                    }

                }
            }
//            print ("letter: \(choosedWord.usedLetters[choosedWord.usedLetters.count - 1]), count: \(choosedWord.usedLetters.count), col: \(col), lastCol: \(choosedWord.usedLetters.last!.col), row: \(row), lastRow: \(choosedWord.usedLetters.last!.row)")
        }
        return false
    }
    
    
    public func endChooseOwnWord(col: Int, row: Int)->FoundedWord? {
        for col in 0..<countCols {
            for row in 0..<countCols {
                if GV.gameArray[col][row].status == .Temporary {
                    GV.gameArray[col][row].setStatus(toStatus: .OrigStatus)
                }
            }
        }
        if moveModusStarted {
            return nil
        } else {
            if col < 0 || col >= countCols || row < 0 || row >= countCols {
                return nil
            }
            //        let actLetter = UsedLetters(col: col, row: row, letter: gameArray![col][row].letter)
            var word = ""
            var wordAdded = false
            for letter in choosedWord.usedLetters {
                if letter.letter == " " {
                    return nil
                }
                word.append(letter.letter)
            }
            if word.count > 1 {
//                wordAdded = delegate.addOwnWordOld(word: word, creationIndex: NoValue, check: true)
                wordAdded = delegate.addOwnWordNew(word: word, usedLetters: choosedWord.usedLetters)
                clear()
            } else {
                showingWords = true
                if choosedWord.usedLetters.count == 0 {
                    return nil
                }
                if choosedWord.usedLetters[0].letter != emptyLetter {
                    if choosedWord.usedLetters[0].col == col && choosedWord.usedLetters[0].row == row {
                        GV.actLetter = choosedWord.usedLetters[0].letter
                        WTGameWordList.shared.showWordsContainingThisLetter(choosedWord: choosedWord)
                    }
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
            _ = GV.gameArray[colFrom][rowFrom].setLetter(letter: letter, toStatus: .Used, calledFrom: "moveItemToOrigPlace")
            GV.gameArray[colTo][rowTo].remove()
       }
    }
    
    public func addFixLettersToGamearray(fixLetters: [UsedLetter]) {
        for fixLetter in fixLetters {
            _ = GV.gameArray[fixLetter.col][fixLetter.row].setLetter(letter: fixLetter.letter, toStatus: .FixItem, calledFrom: "addFixLettersToGamearray")
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
    var timer = Date()
    private func setFirstTime() {
        timer = Date()
    }
    
    private func showTime(string: String) {
        let date = Date()
        print("time at \(string): \((date.timeIntervalSince(timer) * 1000).nDecimals(10))")
        timer = Date()
    }
    

    
    public func stringToGameArray(string: String) {
        setFirstTime()
        for index in 0..<GV.sizeOfGrid * GV.sizeOfGrid {
            let col = index / GV.sizeOfGrid
            let row = index % GV.sizeOfGrid
            GV.gameArray[col][row].restore(from: string.subString(at: 2 * index, length: 2))
//            showTime(string: "col: \(col), row: \(row)")
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
    
    public func checkFixLetters()->Int {
        var returnValue = 0
        for col in 0..<countCols {
            for row in 0..<countCols {
                let item = GV.gameArray[col][row]
                if item.fixItem /* && item.status == .Used*/ {
                    returnValue += 1
                }
            }
        }
        return returnValue
    }
    
    public func checkFreePlaceForPiece(piece: WTPiece, rotateIndex: Int)->Bool {
        let form = myForms[piece.myType]![rotateIndex]
        for col in 0..<countCols {
            for row in 0..<countCols {
                var pieceOK = true
                for formItem in form.points {
                    let summarizedCol = col + formItem / 10
                    let summarizedRow = row - formItem % 10
                    if summarizedCol >= countCols || summarizedRow < 0 {
                        pieceOK = false
                        break
                    } else if GV.gameArray[summarizedCol][summarizedRow].status != .Empty {
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
    
    public func getCountFreePlaces()->Int {
        var returnValue = 0
        for col in 0..<countCols {
            for row in 0..<countCols {
                if GV.gameArray[col][row].status == .Empty {
                    returnValue += 1
                }
            }
        }
        return returnValue
    }
    
    public func getRedLetters()->[String] {
        var returnValue = [String]()
        for col in 0..<countCols {
            for row in 0..<countCols {
                if GV.gameArray[col][row].status == .Used && !GV.gameArray[col][row].fixItem {
                    returnValue.append(GV.gameArray[col][row].letter)
                }
            }
        }
        return returnValue
    }
    public func getFixLetters()->[UsedLetterWithCounter] {
        var returnValue = [UsedLetterWithCounter]()
        for col in 0..<countCols {
            for row in 0..<countCols {
                if GV.gameArray[col][row].fixItem {
                    let usedLetter = setCounterForItem(col: col, row: row)
                    returnValue.append(usedLetter)
                }
            }
        }
        return returnValue
    }
    
    public func getFreeArrays()->(Int, [FreeArray]) {
        var returnValue = [FreeArray]()
        for index in 0...15 {
            let freeArray = FreeArray(countFree: 0, numberOfFreeArray: index, freePlaces: [GameArrayPositionsWithRelations]())
            returnValue.append(freeArray)
        }
        for col in 0..<countCols {
            for row in 0..<countCols {
                var connections = GameArrayPositionsWithRelations(col: col, row: row)
                func setConnection(toDirection: ConnectionTo) {
                    switch toDirection {
                    case .up:
                        if row > 0 && (GV.gameArray[col][row - 1].status == .Used && !GV.gameArray[col][row - 1].fixItem || GV.gameArray[col][row - 1].status == .Empty) {
                            connections.up = true
                            connections.countConnections += 1
                            connections.free = true
                        }
                    case .down:
                        if row < countCols - 1 && (GV.gameArray[col][row + 1].status == .Used && !GV.gameArray[col][row + 1].fixItem || GV.gameArray[col][row + 1].status == .Empty) {
                            connections.down = true
                            connections.countConnections += 1
                            connections.free = true
                        }
                    case .left:
                        if col > 0 && (GV.gameArray[col - 1][row].status == .Used && !GV.gameArray[col - 1][row].fixItem || GV.gameArray[col - 1][row].status == .Empty) {
                            connections.left = true
                            connections.countConnections += 1
                            connections.free = true
                        }
                    case .right:
                        if col < countCols - 1 && (GV.gameArray[col + 1][row].status == .Used && !GV.gameArray[col + 1][row].fixItem || GV.gameArray[col + 1][row].status == .Empty) {
                            connections.right = true
                            connections.countConnections += 1
                            connections.free = true
                        }
                    }
                }
                var foundedInFreeArray = [Int]()
                func addToAnArray(item: GameArrayPositionsWithRelations) {
                    var itemSaved = false
                    outerLoop: for index in 0..<returnValue.count {
                        if returnValue[index].countFree > 0 {
                            for searchIndex in 0..<returnValue[index].freePlaces.count {
                                if (returnValue[index].freePlaces[searchIndex].col == item.col - 1 && returnValue[index].freePlaces[searchIndex].row == item.row) ||
                                    (returnValue[index].freePlaces[searchIndex].col == item.col + 1 && returnValue[index].freePlaces[searchIndex].row == item.row) ||
                                    (returnValue[index].freePlaces[searchIndex].col == item.col && returnValue[index].freePlaces[searchIndex].row - 1 == item.row) ||
                                    (returnValue[index].freePlaces[searchIndex].col == item.col && returnValue[index].freePlaces[searchIndex].row + 1 == item.row) {
                                    returnValue[index].freePlaces.append(item)
                                    returnValue[index].countFree += 1
                                    foundedInFreeArray.append(index)
                                    itemSaved = true
                                    break
                                }
                            }
                        } else if !itemSaved {
                            returnValue[index].freePlaces.append(item)
                            returnValue[index].countFree += 1
                            foundedInFreeArray.append(index)
                            break outerLoop
                        } else {
                            break outerLoop
                        }
                    }
                }
                if (GV.gameArray[col][row].status == .Used && !GV.gameArray[col][row].fixItem) || GV.gameArray[col][row].status == .Empty {
                    setConnection(toDirection: .up)
                    setConnection(toDirection: .down)
                    setConnection(toDirection: .left)
                    setConnection(toDirection: .right)
                }
                if connections.free {
                    addToAnArray(item: connections)
                    if foundedInFreeArray.count > 1 {
                        let toIndex = foundedInFreeArray[0]
                        for index in 1..<foundedInFreeArray.count {
                            let fromIndex = foundedInFreeArray[index]
                            for moveIndex in 0..<returnValue[fromIndex].freePlaces.count {
                                let item = returnValue[fromIndex].freePlaces[moveIndex]
                                if !returnValue[toIndex].freePlaces.contains(item) {
                                    returnValue[toIndex].freePlaces.append(returnValue[fromIndex].freePlaces[moveIndex])
                                    returnValue[toIndex].countFree += 1
                                }
                            }
                            returnValue[fromIndex].freePlaces.removeAll()
                            returnValue[fromIndex].countFree = 0
                        }
                    }
                }
            }
        }
        for index in 0..<returnValue.count {
            if returnValue[index].freePlaces.count > 0 {
                returnValue[index].freePlaces.sort(by: {$0.col < $1.col || $0.col == $1.col && $0.row < $1.row})
            }
        }
        var maxWordLength = 0
        for (index, array) in returnValue.enumerated() {
            if array.countFree > maxWordLength {
                maxWordLength = array.countFree
                var itemsWithOneConnection = 0
                for item in array.freePlaces {
                    if item.countConnections == 1 {
                        itemsWithOneConnection += 1
                    }
                }
                if itemsWithOneConnection > 2 {
                    maxWordLength = maxWordLength - itemsWithOneConnection + 2
                    returnValue[index].countFree -= (itemsWithOneConnection - 2)
                }
            }
            if maxWordLength >= 10 {
                maxWordLength = 10
                break
            }
        }
        for (index, array) in returnValue.enumerated() {
            for item in array.freePlaces {
                let col = item.col
                let row = item.row
                GV.gameArray[col][row].inFreeArray = index
            }
        }

        return (maxWordLength, returnValue)
    }

    public func getFreeGreenLetters()->[UsedLetterWithCounter] {
        var returnValue = [UsedLetterWithCounter]()
        for col in 0..<countCols {
            for row in 0..<countCols {
                if GV.gameArray[col][row].status == .WholeWord {
                    let usedLetter = setCounterForItem(col: col, row: row)
                    if usedLetter.freeCount > 0 {
                        returnValue.append(usedLetter)
                    }
                }
            }
        }
        return returnValue
    }
    
    public func getAllGreenLetters()->[String:[UsedLetter]] {
        var returnValue = [String:[UsedLetter]]()
        let myLetters = GV.language.getText(.tcAlphabet)
        for letter in myLetters {
            returnValue[String(letter)] = [UsedLetter]()
        }
        for col in 0..<GV.sizeOfGrid {
            for row in 0..<GV.sizeOfGrid {
                if GV.gameArray[col][row].status == .WholeWord /* || GV.gameArray[col][row].fixItem */ {
                    let actLetter = UsedLetter(col: col, row: row, letter: GV.gameArray[col][row].letter)
                    returnValue[GV.gameArray[col][row].letter]?.append(actLetter)
                }
            }
        }
        return returnValue
    }


    private func setCounterForItem(col: Int, row: Int)->UsedLetterWithCounter {
        var returnValue = UsedLetterWithCounter(col: col, row: row, letter: GV.gameArray[col][row].letter, freeCount: 0)
        if col > 0 {
            if GV.gameArray[col - 1][row].status == .Empty || (GV.gameArray[col - 1][row].status == .Used && !GV.gameArray[col - 1][row].fixItem) {
                returnValue.freeCount += 1
            }
        }
        if col < 9 {
            if GV.gameArray[col + 1][row].status == .Empty || (GV.gameArray[col + 1][row].status == .Used && !GV.gameArray[col + 1][row].fixItem) {
                returnValue.freeCount += 1
            }
        }
        if row > 0 {
            if GV.gameArray[col][row - 1].status == .Empty || (GV.gameArray[col][row - 1].status == .Used && !GV.gameArray[col][row - 1].fixItem) {
                returnValue.freeCount += 1
            }
        }
        if row < 9 {
            if GV.gameArray[col][row + 1].status == .Empty || (GV.gameArray[col][row + 1].status == .Used && !GV.gameArray[col][row + 1].fixItem) {
                returnValue.freeCount += 1
            }
        }
        return returnValue
    }
    
    var countReadyAnimations = 0
    
    public func clearGreenFieldsForNextRound() {
        waiting = 0
        countReadyAnimations = 0
        countOfAnimations = 0
        GV.nextRoundAnimationFinished = false
        toPositionX = grid!.frame.maxX
        adder = grid!.blockSize
        for row in 0..<GV.sizeOfGrid {
            for col in 0..<GV.sizeOfGrid {
                let newCol = row % 2 == 0 ? GV.sizeOfGrid - col - 1 : col
                animateClearing(col: newCol, row: row)
            }
        }
        self.roundInfos.append(RoundInfos())
    }
    
    var waiting = 0.0
    var countOfAnimations = 0
    var toPositionX = CGFloat(0)
    var adder: CGFloat = 0
    
    private func animateClearing(col: Int, row:Int) {
//        if GV.buttonType == GV.ButtonTypeSimple {
//            return
//        }
        if GV.gameArray[col][row].status != .WholeWord {
            return
        }
        countOfAnimations += 1
        let sprite = (GV.gameArray[col][row]).copyMe()
        sprite.zPosition = self.zPosition + 10
        let xPos = grid!.frame.minX + grid!.blockSize * (CGFloat(col) + 0.5)
        let yPos = grid!.frame.maxY - grid!.blockSize * (CGFloat(row) + 0.5)
        sprite.position = CGPoint(x: xPos, y: yPos)
//        grid!.addChild(greenSprite)
        self.addChild(sprite)
        var actions = Array<SKAction>()
        let waitAction = SKAction.wait(forDuration: waiting)
        waiting += 0.05
        let clearAction = SKAction.run {
            GV.gameArray[col][row].clearIfUsed()
            GV.gameArray[col][row].resetCountOccurencesInWords()
            GV.gameArray[col][row].clearFixLetter()
        }
        toPositionX += adder
        if toPositionX >= grid!.frame.maxX {
            adder = -grid!.blockSize
            toPositionX += adder
        }
        if toPositionX < grid!.frame.minX {
            adder = grid!.blockSize
            toPositionX += adder
        }
        let movingAction = SKAction.move(to: CGPoint(x: toPositionX, y: parent!.frame.maxY), duration: 0.75)
        let removeNodeAction = SKAction.removeFromParent()
        actions.append(SKAction.sequence([clearAction, waitAction, movingAction, removeNodeAction]))
        //        actions.append(SKAction.sequence([waitAction, fadeAway, removeNode]))
        let group = SKAction.group(actions)
//        GV.greenSpriteArray.append(greenSprite)
//        GV.gameArray[col][row].clearIfUsed()
//        GV.gameArray[col][row].resetCountOccurencesInWords()
        sprite.run(group, completion: {
            self.countReadyAnimations += 1
            if self.countReadyAnimations == self.countOfAnimations {
//                for sprite in GV.greenSpriteArray {
//                    sprite.removeFromParent()
//                }
//                GV.greenSpriteArray.removeAll()
                GV.nextRoundAnimationFinished = true
            }
        }
)
    }
    
    public func removeFromGameboard(sprite: WTPiece) {
        let gameboardIndexes = sprite.gameArrayPositions
        for gbIndex in gameboardIndexes {
            if let col = Int(gbIndex.subString(at: 0, length: 1)) {
                if let row = Int(gbIndex.subString(at: 1, length: 1)) {
                    GV.gameArray[col][row].remove()
                }
            }
        }
    }
    
    public func getCountLetters(empty: Bool = false)->Int {
        var returnValue = 0
        let adder = empty ? 0 : 1
        for row in 0..<countCols {
            for col in 0..<countCols {
                returnValue += GV.gameArray[col][row].status != .Empty ? adder : 1 - adder
            }
        }
        return returnValue
    }

    
    public func clearGameArray(all: Bool = false) {
        for row in 0..<GV.sizeOfGrid {
            for col in 0..<GV.sizeOfGrid {
                GV.gameArray[col][row].remove(all: all)
            }
        }
    }
    
    public func getCellPosition(col: Int, row: Int)->PLPosSize {
        let addPosition = grid!.plPosSize!
        return grid!.gridPosition(col: col, row: row) + addPosition
    }
    
    public func checkGameArrayIsEmpty()->Bool {
        var isEmpty = true
        for row in 0..<countCols {
            for col in 0..<countCols {
                if GV.gameArray[col][row].status != .Empty {
                    isEmpty = false
                }
            }
        }
        return isEmpty
    }
    
    public func printGameArray() {
        let line = "____________________________________________"
        for row in 0..<GV.sizeOfGrid {
            var infoLine = "|"
            for col in 0..<GV.sizeOfGrid {
                let char = GV.gameArray[col][row].letter
                var greenMark = emptyLetter
                if GV.gameArray[col][row].status == .WholeWord {
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
    
    public func delay(bySeconds seconds: Double, dispatchLevel: DispatchLevel = .main, closure: @escaping () -> Void) {
        let dispatchTime = DispatchTime.now() + seconds
        dispatchLevel.dispatchQueue.asyncAfter(deadline: dispatchTime, execute: closure)
    }
    
    public enum DispatchLevel {
        case main, userInteractive, userInitiated, utility, background
        var dispatchQueue: DispatchQueue {
            switch self {
            case .main:                 return DispatchQueue.main
            case .userInteractive:      return DispatchQueue.global(qos: .userInteractive)
            case .userInitiated:        return DispatchQueue.global(qos: .userInitiated)
            case .utility:              return DispatchQueue.global(qos: .utility)
            case .background:           return DispatchQueue.global(qos: .background)
            }
        }
    }


    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
