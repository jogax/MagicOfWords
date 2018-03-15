//
//  WordTrisGamebord.swift
//  MagicOfWords
//
//  Created by Jozsef Romhanyi on 11/02/2018.
//  Copyright © 2018 Jozsef Romhanyi. All rights reserved.
//

import Foundation
import GameplayKit
public protocol WordTrisGameboardDelegate: class {
    
    /// Method called when a word is founded
    func showFoundedWord(foundedWord: String, counter: Int)
    /// method is called when an own word is chosed
    func addOwnWord(word: String)
}



let WSGameboardSizeMultiplier:CGFloat = 2.0
func == (left: WordTrisGameboard.UsedLetters, right: WordTrisGameboard.UsedLetters) -> Bool {
    return left.col == right.col && left.row == right.row && left.letter == right.letter
}

class WordTrisGameboard: SKShapeNode {
    struct FoundedWordsWithCounter {
        var word: String = ""
        var counter: Int
        init(word: String, counter: Int) {
            self.word = word
            self.counter = counter
        }
    }
    
    struct UsedItems {
        var col: Int = 0
        var row: Int = 0
        var item: WordTrisGameboardItem?
    }
    
    struct UsedLetters {
        var col: Int = 0
        var row: Int = 0
        var letter: String = ""
        init(col: Int, row: Int, letter: String) {
            self.col = col
            self.row = row
            self.letter = letter
        }
    }
    struct FoundedWords {
        var word: String = ""
        var usedLetters = [UsedLetters]()
        init(word: String, usedLetters: [UsedLetters]) {
            self.word = word
            self.usedLetters = usedLetters
        }
        
    }
    var delegate: WordTrisGameboardDelegate
    var parentScene: SKScene
    var size: Int
    var grid: Grid?
    let blockSize: CGFloat?
    let tileColor = SKColor(red: 212/255, green: 249/255, blue: 236/255, alpha: 1.0)
    var gameArray: [[WordTrisGameboardItem]]?
    var shape: WordTrisShape = WordTrisShape()
    private var lastCol: Int = 0
    private var lastRow: Int = 0
    private var startCol: Int = 0
    private var startRow: Int = 0
    private var startLocation = CGPoint(x: 0, y: 0)
    private var usedItems = [UsedItems]()
    private var usedItemsOK = true
    private var wordsToCheck = [String]()
    private var ownWords = [String]()
    private var choosedWord = [UsedLetters]()
    private var foundedWords = [FoundedWords]()

    init(size: Int, parentScene: SKScene, delegate: WordTrisGameboardDelegate) {
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
            colSprite.name = "Row\(col)"
            parentScene.addChild(colSprite)
        }
        let colSprite = SKSpriteNode()
        let col10Width = parentScene.frame.maxX - grid!.frame.maxX
        colSprite.position = CGPoint(x: grid!.frame.maxX + col10Width / 2, y: grid!.frame.midY)
        colSprite.size = CGSize(width: col10Width, height: parentScene.frame.height)
//        colSprite.color = .green
        colSprite.name = "Row\(size)"
        parentScene.addChild(colSprite)
        
        let rowSprite = SKSpriteNode()
        let row10Height = grid!.frame.minY - parentScene.frame.minY
        rowSprite.position = CGPoint(x: parentScene.frame.midX, y: grid!.frame.minY - row10Height / 2) - CGPoint(x: 0, y: WSGameboardSizeMultiplier * blockSize!)
        rowSprite.size = CGSize(width: parentScene.frame.width, height: row10Height)
//        rowSprite.color = .blue
        rowSprite.name = "Col\(size)"
        parentScene.addChild(rowSprite)
        for row in 0..<size {
            let rowSprite = SKSpriteNode()
            rowSprite.position = CGPoint(x: grid!.frame.minX, y: grid!.frame.midY) - grid!.gridPosition(col: 0, row: row) - CGPoint(x: 0, y: WSGameboardSizeMultiplier * blockSize!)
            rowSprite.size = CGSize(width: parentScene.frame.width * 1.1, height: blockSize!)
//            if row % 2 == 0 {
//                rowSprite.alpha = 0.1
//                rowSprite.color = .green
//            }
            rowSprite.name = "Col\(size - 1 - row)"
            parentScene.addChild(rowSprite)
        }
    }
    private func createNewGameArray(size: Int) -> [[WordTrisGameboardItem]] {
        var gameArray: [[WordTrisGameboardItem]] = []
        
        for i in 0..<size {
            gameArray.append( [WordTrisGameboardItem]() )
            
            for _ in 0..<size {
                gameArray[i].append( WordTrisGameboardItem(blockSize: blockSize!, fontSize: parentScene.frame.width / 20) )
            }
        }
        return gameArray
    }

    private func createBackgroundShape(size: Int) {
        //        let myShape =

        grid = Grid(blockSize: blockSize!, rows:size, cols:size)
        grid!.position = CGPoint (x:parentScene.frame.midX, y:parentScene.frame.maxY * 0.5)
        grid!.name = "Gameboard"
        self.addChild(grid!)
    }
    
//    public func fixSpriteOnGameboardIfNecessary(shape: WordTrisShape)->Bool {
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
        usedItems.removeAll()
        usedItemsOK = true
    }
    
    
    public func startShowingSpriteOnGameboard(shape: WordTrisShape, col: Int, row: Int)->Bool {
//        if col < 0 && row < 0 {
//            return false
//        }
        
        self.shape = shape
        let formOfShape = myForms[shape.myType]![shape.rotateIndex]
        let (myCol, myRow) = analyseColAndRow(col: col, row: row, formOfShape: formOfShape)
        if myRow == size {
            for index in 0..<usedItems.count {
                usedItems[index].item!.clearIfTemporary()
            }
            return true
        }

       for index in 0..<shape.sprite().children.count {
            let letter = shape.letters[index]
            let itemRow = formOfShape[index] / 10
            let itemCol = formOfShape[index] % 10
            let calculatedCol = myCol + itemCol //- colAdder
            let calculatedRow = myRow - itemRow //- rowAdder
            if calculatedRow < 0 {return false}
            _ = gameArray![calculatedCol][calculatedRow].setLetter(letter: letter, status: .temporary, color: tileColor)
            let usedItem = UsedItems(col: calculatedCol, row: calculatedRow, item: gameArray![calculatedCol][calculatedRow])
            usedItems.append(usedItem)
        }
        return true
    }
    
    public func moveSpriteOnGameboard(col: Int, row: Int) -> Bool {
        let formOfShape = myForms[shape.myType]![shape.rotateIndex]
        let (myCol, myRow) = analyseColAndRow(col: col, row: row, formOfShape: formOfShape)

        if myRow == size {
            for index in 0..<usedItems.count {
                usedItems[index].item!.clearIfTemporary()
            }
            return true
        }
        
        for index in 0..<usedItems.count {
            usedItems[index].item!.clearIfTemporary()
        }

        for index in 0..<shape.sprite().children.count {
            let letter = shape.letters[index]
            let itemCol = formOfShape[index] % 10
            let itemRow = formOfShape[index] / 10
            let calculatedCol = myCol + itemCol // - adder
            let calculatedRow = myRow - itemRow
            _ = gameArray![calculatedCol][calculatedRow].setLetter(letter: letter, status: .temporary, color: tileColor)
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
    
    public func stopShowingSpriteOnGameboard(col: Int, row: Int, wordsToCheck: [String])->Bool {
        var fixed = true
        self.wordsToCheck = wordsToCheck
        if row == 10 {
            for index in 0..<usedItems.count {
                usedItems[index].item!.clearIfTemporary()
            }
            return false  // when shape not remaining on gameBoard, return false
        } else {
            for index in 0..<usedItems.count {
                fixed = fixed && usedItems[index].item!.fixIfTemporary()
            }
            checkReadyWords()
            return fixed  // when shape remaining on gameBoard, return true
        }
    }

    public func checkReadyWords() {
        foundedWords.removeAll()
        for col in 0..<gameArray!.count {
            for row in 0..<gameArray!.count {
                let letter = getLetter(col: col, row: row)
                if letter != "" {
                    for word in wordsToCheck {
                        if letter == word.subString(startPos: 0, length: 1) {
                            OKPositions.removeAll()
                            if flyOverWord(compare: letter, col: col, row: row, fromCol: col, fromRow: row, withWord: word) {
                                for position in OKPositions {  // set to green
                                    gameArray![position.col][position.row].setFoundedWord(toColor: .green)
                                }
                            } else {
                            }
                        }
                    }
                }
            }
        }
        var foundedWordsWithCount = [FoundedWordsWithCounter]()
        for foundedWord in foundedWords {
            var founded = false
            for index in 0..<foundedWordsWithCount.count {
                if foundedWord.word == foundedWordsWithCount[index].word {
                    foundedWordsWithCount[index].counter += 1
                    founded = true
                }
            }
            if !founded {
                foundedWordsWithCount.append(FoundedWordsWithCounter(word: foundedWord.word , counter: 1))
            }
        }
        for foundedWord in foundedWordsWithCount {
            delegate.showFoundedWord(foundedWord: foundedWord.word, counter: foundedWord.counter)
        }
    }
    var OKPositions = [UsedLetters]()
    
    private func flyOverWord(compare: String, col: Int, row: Int, fromCol: Int, fromRow: Int, withWord: String)->Bool {
        let myWord = compare
        var returnBool = false
        if myWord.count == withWord.count {
            if myWord != withWord {
                return false
            } else {
//                print("myWord: \(myWord)")
                OKPositions.append(UsedLetters(col:col, row: row, letter: gameArray![col][row].letter))
                foundedWords.append(FoundedWords(word: myWord, usedLetters: OKPositions))
                return true
            }
        }
        if myWord == withWord.subString(startPos: 0, length: myWord.count) {
            if col > 0 && col - 1 != fromCol {
                let new = getLetter(col: col - 1, row: row)
                if new != "" {
                    if flyOverWord(compare: myWord + new, col: col - 1, row: row, fromCol: col, fromRow: row, withWord: withWord) {
                        OKPositions.append(UsedLetters(col:col, row: row, letter: gameArray![col][row].letter))
                        returnBool = true
                    }
                }
            }
            if col < size - 1 && col + 1 != fromCol {
                let new = getLetter(col: col + 1, row: row)
                if new != "" {
                    if flyOverWord(compare: myWord + new, col: col + 1, row: row, fromCol: col, fromRow: row, withWord: withWord) {
                        OKPositions.append(UsedLetters(col:col, row: row, letter: gameArray![col][row].letter))
                        returnBool = true
                    }
                }
            }
            if row > 0 && row - 1 != fromRow {
                let new = getLetter(col: col, row: row - 1)
                if new != "" {
                    if flyOverWord(compare: myWord + new, col: col, row: row - 1, fromCol: col, fromRow: row, withWord: withWord) {
                        OKPositions.append(UsedLetters(col:col, row: row, letter: gameArray![col][row].letter))
                        returnBool = true
                    }
                }
            }
            if row < size - 1 && row + 1 != fromRow {
                let new = getLetter(col: col, row: row + 1)
                if new != "" {
                    if flyOverWord(compare: myWord + new, col: col, row: row + 1, fromCol: col, fromRow: row, withWord: withWord) {
                        OKPositions.append(UsedLetters(col:col, row: row, letter: gameArray![col][row].letter))
                        returnBool = true
                    }
                }
            }
        }
        return returnBool
    }
    
    private func getLetter(col: Int, row: Int)->String {
        if gameArray![col][row].status == .used || gameArray![col][row].status == .wholeWord {
            return (gameArray![col][row].children[0] as! SKLabelNode).text!
        } else {
            return ""
        }
    }
    
    public func startChooseOwnWord(col: Int, row: Int) {
        choosedWord.removeAll()
        choosedWord.append(UsedLetters(col: col, row: row, letter: gameArray![col][row].letter))
    }
    
    public func moveChooseOwnWord(col: Int, row: Int) {
        let actLetter = UsedLetters(col: col, row: row, letter: gameArray![col][row].letter)
        if choosedWord.contains(where: {$0 == actLetter}) {
            return
        }
        choosedWord.append(actLetter)
    }

    public func endChooseOwnWord(col: Int, row: Int) {
        let actLetter = UsedLetters(col: col, row: row, letter: gameArray![col][row].letter)
        var word = ""
        for letter in choosedWord {
            word.append(letter.letter)
        }
        delegate.addOwnWord(word: word)
        print ("\(word)")
    }
    
    public func addOwnWordToCheck(word: String) {
        wordsToCheck.append(word)
    }

    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
