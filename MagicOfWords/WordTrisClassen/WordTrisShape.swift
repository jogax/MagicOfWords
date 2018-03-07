//
//  WordTrisShape.swift
//  MagicOfWords
//
//  Created by Jozsef Romhanyi on 11/02/2018.
//  Copyright © 2018 Jozsef Romhanyi. All rights reserved.
//

import Foundation
import GameplayKit
enum MyShapes: Int {
    case
        Z_Shape_1, // 0
        Z_Shape_2, // 1
        L_Shape_1, // 2
        L_Shape_2, // 3
        L_Shape_3, // 4
        L_Shape_4, // 5
        T_Shape_1, // 7
        T_Shape_2, // 8
        O_Shape,   // 9
        I_Shape_1, // 10
        I_Shape_2, // 11
        I_Shape_3, // 12
        I_Shape_4, // 13
        Not_Used
    static var count: Int { return MyShapes.Not_Used.hashValue + 1}

}
struct LetterCoordinates {
    var letter: String = ""
    var col: Int = 0
    var row: Int = 0
}
let myForms: [MyShapes : [[Int]]] = [
    .Z_Shape_1 : [[00, 01, 11, 12], [20, 10, 11, 01], [12, 11, 01, 00], [01, 11, 10, 20]], //OK
    .Z_Shape_2 : [[10, 11, 01, 02], [21, 11, 10, 00], [02, 01, 11, 10], [00, 10, 11, 21]], //OK
    .L_Shape_1 : [[00, 01, 11], [10, 00, 01], [11, 10, 00], [01, 11, 10]], // OK
    .L_Shape_2 : [[21, 20, 10, 00], [02, 12, 11, 10], [00, 01, 11, 21], [10, 00, 01, 02]], // OK
    .L_Shape_3 : [[20, 21, 11, 01], [12, 02, 01, 00], [01, 00, 10, 20], [00, 10, 11, 12]], // OK
    .L_Shape_4 : [[20, 10, 00, 01, 02], [22, 21, 20, 10, 00], [02, 12, 22, 21, 20], [00, 01, 02, 12, 22]], // OK
    .T_Shape_1 : [[12, 11, 10, 01], [01, 11, 21, 10], [00, 01, 02, 11], [20, 10, 00, 11]],  // OK
    .T_Shape_2 : [[22, 21, 20, 11, 01], [02, 12, 22, 11, 10], [00, 01, 02, 11, 21], [20, 10, 00, 11, 12]], // OK
    .O_Shape   : [[00, 01, 11, 10], [10, 00, 01, 11], [11, 10, 00, 01], [01, 11, 10, 00]], // OK
    .I_Shape_1 : [[00], [00], [00], [00]], // OK
    .I_Shape_2 : [[00, 10], [00, 01], [10, 00], [01, 00]], // OK
    .I_Shape_3 : [[00, 10, 20], [00, 01, 02], [20, 10, 00], [02, 01, 00]], // OK
    .I_Shape_4 : [[00, 10, 20, 30], [00, 01, 02, 03], [30, 20, 10, 00], [03, 02, 01, 00]] // OK
]


class WordTrisShape {
    let countRows: CGFloat = 3
    var mySprite: SKSpriteNode
//    var myShape: SKSpriteNode
    let parent: SKScene
    let blockSize: CGFloat
    let letters: [String]
    public var rotateIndex: Int = 0
    var origPosition: [CGPoint] = [CGPoint(x:0, y:0), CGPoint(x:0, y:0), CGPoint(x:0, y:0), CGPoint(x:0, y:0), CGPoint(x:0, y:0)]
    var myType: MyShapes
    // Shape Form
    // y:  x:   0   1   2   3
    // 3        x   x   x   x
    // 2        x   x   x   x
    // 1        x   x   x   x
    // 0        x   x   x   x
    
    init() {
        self.parent = SKScene()
        self.blockSize = 0
        self.letters = []
        self.myType = MyShapes.Not_Used
        self.mySprite = SKSpriteNode()
//        self.myShape = SKSpriteNode()

    }
    init(type: MyShapes, rotateIndex: Int, parent: SKScene, blockSize: CGFloat, letters: [String]) {
        self.parent = parent
        self.blockSize = blockSize
        self.letters = letters
        self.myType = type
        self.rotateIndex = rotateIndex
        self.mySprite = SKSpriteNode()
        mySprite.size = calculateSize()
        addLettersToPositions()
    }
    
    private func calculateSize()->CGSize {
        let form = myForms[myType]![rotateIndex]
        var maxCol = 0
        var maxRow = 0
        for index in 0..<form.count {
            let col = form[index] / 10
            let row = form[index] % 10
            maxCol = col > maxCol ? col : maxCol
            maxRow = row > maxRow ? row : maxRow
        }
        let size = CGSize(width: blockSize * CGFloat(maxRow + 1), height: blockSize * CGFloat(maxCol + 1))
        return size
    }
    private func addLettersToPositions() {
        let form = myForms[myType]![rotateIndex]
        for index in 0..<form.count {
            let col = form[index] / 10
            let row = form[index] % 10
            let position = gridPosition(col: col, row: row)
            let frameForLetter = SKSpriteNode(color: .white, size: CGSize(width: blockSize * 0.9, height: blockSize * 0.9))
            frameForLetter.position = position
//            frameForLetter.fillColor = .yellow
            let label = SKLabelNode(fontNamed: "TimesNewRomanPS-BoldMT")
//            label.position = position
            label.text = letters[index]
            label.fontColor = .black
            label.fontSize = parent.frame.width / 25
            label.horizontalAlignmentMode = .center
            label.verticalAlignmentMode = .center
            label.color = .blue
            label.name = "Label"
            let searchName = "label\(index)"
            frameForLetter.name = searchName
            frameForLetter.addChild(label)
//            if mySprite.childNode(withName: searchName) != nil {
//                mySprite.childNode(withName: searchName)!.removeFromParent()
//            }
            mySprite.addChild(frameForLetter)

        }
    }
    public func sprite()->SKSpriteNode {
        return mySprite
    }
    
    public func getLengthOfShape(type: MyShapes)->Int {
        return myForms[type]!.count
    }
    
    public func changeSize(by: CGFloat) {
        mySprite.setScale(by)
    }
    
    public func rotate() {
        rotateIndex = (rotateIndex + 1) % 4
        let rotateAction = SKAction.rotate(byAngle: -90 * GV.oneGrad, duration: 0.1)
//        mySprite.anchorPoint = CGPoint(x: 0.1, y: 0.1)
        mySprite.run(rotateAction)
//        addLettersToPositions()
        let form = myForms[myType]
        for index in 0..<form![rotateIndex].count {
            let searchName = "label\(index)"
            guard let child = mySprite.childNode(withName: searchName) else {
                continue
            }
            let rotateLetterAction = SKAction.rotate(byAngle: 90 * GV.oneGrad, duration: 0.1)
            child.run(rotateLetterAction)
         }

    }
    
    
    private func gridPosition(col:Int, row:Int) -> CGPoint {
        let offset = blockSize * 0.5 + 0.5
        let x = mySprite.frame.minX + (CGFloat(row) * blockSize - 1) + offset
        let y = mySprite.frame.minY + (CGFloat(col) * blockSize - 1) + offset * 0.8 // / 2.2
        return CGPoint(x:x, y:y)
    }
    
    public func getLetterCoordinates()->[LetterCoordinates] {
        let coordinates = myForms[myType]![rotateIndex]
        print("\(coordinates)")
        var returnValue = [LetterCoordinates]()
        for index in 0..<mySprite.children.count {
            var letterCoordinates = LetterCoordinates()
            letterCoordinates.letter = (mySprite.children[index].children[0] as! SKLabelNode).text!
            letterCoordinates.col = coordinates[index] / 10
            letterCoordinates.row = coordinates[index] % 10
            returnValue.append(letterCoordinates)
        }
        return returnValue
    }

    public func copy()->WordTrisShape {
        let copy = WordTrisShape(type: myType, rotateIndex: rotateIndex, parent: parent, blockSize: blockSize, letters: letters)
        return copy
    }
    deinit {
        print("\n WordtrisShape \((type(of: self))) WAS REMOVED FROM MEMORY (DEINIT) \n")
    }

}


