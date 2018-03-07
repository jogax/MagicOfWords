//
//  WordTrisGamebord.swift
//  MagicOfWords
//
//  Created by Jozsef Romhanyi on 11/02/2018.
//  Copyright © 2018 Jozsef Romhanyi. All rights reserved.
//

import Foundation
import GameplayKit

class WordTrisGameboard: SKShapeNode {
    struct UsedItems {
        var col: Int = 0
        var row: Int = 0
        var item: WordTrisGameboardItem?
    }
    var parentScene: SKScene
    var size: Int
    var grid: Grid?
    let blockSize: CGFloat?
    let tileColor = SKColor(red: 212/255, green: 249/255, blue: 236/255, alpha: 1.0)
    var gameArray: [[WordTrisGameboardItem]]?
    var shape: WordTrisShape?
    private var lastCol: Int = 0
    private var lastRow: Int = 0
    private var startCol: Int = 0
    private var startRow: Int = 0
    private var startLocation = CGPoint(x: 0, y: 0)
    private var usedItems = [UsedItems]()
    private var usedItemsOK = true
    private var origArrayCol: Int = 0
    private var origArrayRow: Int = 9
    private var oldRowChange: Int = 0
    private var oldColChange: Int = 0

    init(size: Int, parentScene: SKScene) {
        self.size = size
        self.parentScene = parentScene
        self.blockSize = parentScene.frame.size.width * (GV.onIpad ? 0.70 : 0.90) / CGFloat(size)
        super.init()
        createBackgroundShape(size: size)
        gameArray = createNewGameArray(size: size)
        for col in 0..<size {
            for row in 0..<size {
                gameArray![col][row].position = grid!.gridPosition(col: col, row: row) //+
//                    CGPoint (x:parentScene.frame.midX, y:parentScene.frame.midY * 0.874)
                gameArray![col][row].name = "col\(col)-row\(row)"
//                gameArray![col][row].setLetter(letter: "\(col)\(row)", status: .empty, color: .white)
                grid!.addChild(gameArray![col][row])
            }
        }
        parentScene.addChild(self)
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
    
    public func fixSpriteOnGameboardIfNecessary(shape: WordTrisShape)->Bool {
        if shape.sprite().frame.minY >= self.children[0].frame.minY && usedItemsOK &&
            shape.sprite().frame.maxY < self.children[0].frame.maxY
        {
            _ = usedItems.map {$0.item!.fixIfTemporary()}
            return true
        } else {
            _ = usedItems.map {$0.item!.clearIfTemporary()}
            return false
        }
    }
    
    public func clear() {
        usedItems.removeAll()
        usedItemsOK = true
    }
    
    
    public func startShowingSpriteOnGameboard(touchLocation: CGPoint, shape: WordTrisShape) {
        self.shape = shape
        startLocation = touchLocation //+ CGPoint(x: 0, y: shape.sprite().frame.height)
        var colDistance: CGFloat = 10000
        var searchPosition: CGPoint
        var actCol = 0
        for col in 0..<size {
            searchPosition = grid!.gridPosition(col: col, row: 9) + grid!.position
            let actDistance = abs(startLocation.x - searchPosition.x)
            if colDistance > actDistance {
                colDistance = actDistance
                actCol = col
            } else {
                break
            }
        }
        origArrayCol = actCol
        origArrayRow = 9
        let formOfShape = myForms[shape.myType]![shape.rotateIndex]
        var maxX = 0
        var maxY = 0
        for actItem in formOfShape {
            let actX = actItem % 10
            let actY = actItem / 10
            maxX = maxX < actX ? actX : maxX
            maxY = maxY < actY ? actY : maxY
        }
        var adder = 0
        for index in 0..<shape.sprite().children.count {
            if origArrayCol + formOfShape[index] % 10 > size - 1 {
                adder += 1
            }
            if origArrayCol + formOfShape[index] % 10  < 0 {
                adder -= 1
            }
        }
       for index in 0..<shape.sprite().children.count {
            let letter = shape.letters[index]
            let itemRow = formOfShape[index] / 10
            let itemCol = formOfShape[index] % 10
            let calculatedCol = origArrayCol + itemCol - adder
            let calculatedRow = origArrayRow - itemRow
            gameArray![calculatedCol][calculatedRow].setLetter(letter: letter, status: .temporary, color: tileColor)
            let usedItem = UsedItems(col: calculatedCol, row: calculatedRow, item: gameArray![calculatedCol][calculatedRow])
            usedItems.append(usedItem)
        }
    }
    
    public func moveSpriteOnGameboard(touchLocation: CGPoint) {
        let myLocation = touchLocation // + CGPoint(x: 0, y: shape!.sprite().frame.height)
//        if ( myLocation.y - grid!.frame.minY ) > 0 {
            let distance = startLocation - myLocation
            let colChange = Int(distance.x / blockSize!)
            let rowChange = Int(distance.y / blockSize!)
            if oldColChange != colChange || oldRowChange != rowChange {
                let colDelta = oldColChange - colChange
                let rowDelta = oldRowChange - rowChange
                oldColChange = colChange
                oldRowChange = rowChange
                var OK = true
                for index in 0..<usedItems.count {
                    var item = usedItems[index]
                    item.row -= rowDelta
                    item.col += colDelta
                    if item.col < 0 || item.col > size - 1 || item.row > size - 1 || item.row < 0 {
                        OK = false
                    }
                }
                if OK {
                    for index in 0..<usedItems.count {
                        usedItems[index].item!.clearIfTemporary()
                    }
                    var setToRed = false
                    for index in 0..<usedItems.count {
                        usedItems[index].row -= rowDelta
                        usedItems[index].col += colDelta
                        let row = usedItems[index].row
                        let col = usedItems[index].col
                        let letter = shape!.letters[index]
                        if !gameArray![col][row].setLetter(letter: letter, status: .temporary, color: tileColor) {
                            setToRed = true
                        }
                        usedItems[index].item = gameArray![col][row]
                    }
                    if setToRed {
                        for index in 0..<usedItems.count {
                            usedItems[index].item!.setRedColor()
                        }
                    }
                }
            }
//        } else {
//            for index in 0..<usedItems.count {
//                usedItems[index].item!.clearIfTemporary()
//            }
//        }
    }
    
    public func stopShowingSpriteOnGameboard(touchLocation: CGPoint)->Bool {
        if touchLocation.y + shape!.sprite().frame.height - grid!.frame.minY < 0 {
            for index in 0..<usedItems.count {
                usedItems[index].item!.clearIfTemporary()
            }
            return false  // when shape not remaining on gameBoard, return false
        } else {
            for index in 0..<usedItems.count {
                usedItems[index].item!.fixIfTemporary()
            }
            return true  // when shape remaining on gameBoard, return true
        }
    }

    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
