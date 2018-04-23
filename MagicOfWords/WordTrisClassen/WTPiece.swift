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
        T_Shape_1, // 5
        O_Shape_1, // 6
        I_Shape_1, // 7
        I_Shape_2, // 8
        I_Shape_3, // 9
        I_Shape_4, // 10
        NotUsed
    static var count: Int { return MyShapes.NotUsed.hashValue + 1}
    func toString()->String {
        let stringType = ["Z1", "Z2", "L1", "L2", "L3", "T1", "O1", "I1", "I2", "I3", "I4", "NotUsed"]
        return stringType[self.rawValue]
    }
    static func toValue(name: String)->MyShapes {
        let stringType = ["Z1", "Z2", "L1", "L2", "L3", "T1", "O1", "I1", "I2", "I3", "I4", "NotUsed"]
        return MyShapes(rawValue: stringType.index{$0 == name}!)!
    }

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
    .T_Shape_1 : [[12, 11, 10, 01], [01, 11, 21, 10], [00, 01, 02, 11], [20, 10, 00, 11]],  // OK
    .O_Shape_1  : [[00, 01, 11, 10], [10, 00, 01, 11], [11, 10, 00, 01], [01, 11, 10, 00]], // OK
    .I_Shape_1 : [[00], [00], [00], [00]], // OK
    .I_Shape_2 : [[00, 10], [00, 01], [10, 00], [01, 00]], // OK
    .I_Shape_3 : [[00, 10, 20], [00, 01, 02], [20, 10, 00], [02, 01, 00]], // OK
    .I_Shape_4 : [[00, 10, 20, 30], [00, 01, 02, 03], [30, 20, 10, 00], [03, 02, 01, 00]] // OK
]


class WTPiece: SKSpriteNode {
    let countRows: CGFloat = 3
//    var mySprite: SKSpriteNode
//    var myShape: SKSpriteNode
    let myParent: SKScene
    let blockSize: CGFloat
    let letters: [String]
    var gameArrayPositions = [String]()
    var arrayIndex: Int
    var pieceFromPosition = NoValue
    var isOnGameboard = false
    public var rotateIndex: Int = 0
//    var origPosition: [CGPoint] = [CGPoint(x:0, y:0), CGPoint(x:0, y:0), CGPoint(x:0, y:0), CGPoint(x:0, y:0), CGPoint(x:0, y:0)]
    var myType: MyShapes
    // Shape Form
    // y:  x:   0   1   2   3
    // 3        x   x   x   x
    // 2        x   x   x   x
    // 1        x   x   x   x
    // 0        x   x   x   x
    
    init(type: MyShapes = .NotUsed,
         rotateIndex: Int = 0,
         parent: SKScene = SKScene(),
         blockSize: CGFloat = 0,
         letters: [String] = [""],
         pieceFromPosition: Int = NoValue,
         isOnGameboard: Bool = false,
         arrayIndex: Int = 0) {
        let texture = SKTexture()
        self.myParent = parent
        self.blockSize = blockSize
        self.letters = letters
        self.myType = type
        self.arrayIndex = arrayIndex
        super.init(texture: texture, color: .clear, size: CGSize(width: 10, height: 10))
        self.zPosition = -1
        self.colorBlendFactor = 1.0
        self.color = .clear
        self.rotateIndex = rotateIndex
        self.isOnGameboard = isOnGameboard
        self.pieceFromPosition = pieceFromPosition
        
//        self.mySprite = SKSpriteNode()
        if myType != .NotUsed {
            self.size = calculateSize()
            addLettersToPositions()
            self.gameArrayPositions = Array(repeating: "00", count: myForms[self.myType]![0].count)
        }
    }
    
    convenience init(from: String, parent: SKScene = SKScene(), blockSize: CGFloat = 0, arrayIndex: Int) {
//        let myString = sType + "/" + sRotateIndex + "/" + sLetters + "/" + sGameArrayPositions
        let myValues = from.components(separatedBy: "/")
        let type = MyShapes.toValue(name: myValues[0])
        let rotateIndex = Int(myValues[1])
        var letters = [String]()
        for letter in myValues[2] {
            letters.append(String(letter))
        }
        var tempPieceFromPosition = NoValue
        if let position = Int(myValues[4]) {
            tempPieceFromPosition = position
        }
        let isOnGameboard = myValues[5] == "1"
        self.init(type: type, rotateIndex: rotateIndex!, parent: parent, blockSize: blockSize, letters: letters, pieceFromPosition: tempPieceFromPosition, isOnGameboard: isOnGameboard, arrayIndex: arrayIndex)
        gameArrayPositions = myValues[3].components(separatedBy: "-")
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
            let frameForLetter = SKSpriteNode(color: .clear, size: CGSize(width: blockSize * 0.9, height: blockSize * 0.9))
            frameForLetter.position = position
            frameForLetter.color = .white
            let label = SKLabelNode(fontNamed: "TimesNewRomanPS-BoldMT")
//            label.position = position
            label.text = letters[index]
            label.fontColor = .black
            label.fontSize = myParent.frame.width / 25
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
            self.addChild(frameForLetter)

        }
    }
//    public func sprite()->SKSpriteNode {
//        return mySprite
//    }
//
    public func setPieceFromPosition(index: Int) {
        pieceFromPosition = index
    }

    public func setGameArrayPositions(gameArrayPositions: [GameArrayPositions]) {
        if gameArrayPositions.count == myForms[myType]![0].count {
            for index in 0..<gameArrayPositions.count {
                self.gameArrayPositions[index] = String(gameArrayPositions[index].col) + String(gameArrayPositions[index].row)
            }
            isOnGameboard = true
        }
    }
    public func getLengthOfShape(type: MyShapes)->Int {
        return myForms[type]!.count
    }
    
    public func changeSize(by: CGFloat) {
        self.setScale(by)
    }
    
    public func rotate() {
        rotateIndex = (rotateIndex + 1) % 4
        let rotateAction = SKAction.rotate(byAngle: -90 * GV.oneGrad, duration: 0.1)
//        mySprite.anchorPoint = CGPoint(x: 0.1, y: 0.1)
        self.run(rotateAction)
//        addLettersToPositions()
        let form = myForms[myType]
        for index in 0..<form![rotateIndex].count {
            let searchName = "label\(index)"
            guard let child = self.childNode(withName: searchName) else {
                continue
            }
            let rotateLetterAction = SKAction.rotate(byAngle: 90 * GV.oneGrad, duration: 0.1)
            child.run(rotateLetterAction)
         }

    }
    
    
    private func gridPosition(col:Int, row:Int) -> CGPoint {
        let offset = blockSize * 0.5 + 0.5
        let x = self.frame.minX + (CGFloat(row) * blockSize - 1) + offset
        let y = self.frame.minY + (CGFloat(col) * blockSize - 1) + offset * 0.8 // / 2.2
        return CGPoint(x:x, y:y)
    }
    
    public func getLetterCoordinates()->[LetterCoordinates] {
        let coordinates = myForms[myType]![rotateIndex]
        print("\(coordinates)")
        var returnValue = [LetterCoordinates]()
        for index in 0..<self.children.count {
            var letterCoordinates = LetterCoordinates()
            letterCoordinates.letter = (self.children[index].children[0] as! SKLabelNode).text!
            letterCoordinates.col = coordinates[index] / 10
            letterCoordinates.row = coordinates[index] % 10
            returnValue.append(letterCoordinates)
        }
        return returnValue
    }

//    public func copy()->WTPiece {
//        let copy = WTPiece(type: myType, rotateIndex: rotateIndex, parent: myParent, blockSize: blockSize, letters: letters, )
//        return copy
//    }
//    
    public func reset() {
        self.resetGameArrayPositions()
        self.pieceFromPosition = NoValue
    }
    
    public func addArrayIndex(index: Int) {
        arrayIndex = index
    }
    
    public func getArrayIndex() ->Int {
        return arrayIndex
    }
    
    public func resetGameArrayPositions() {
        if myType != .NotUsed {
            self.gameArrayPositions = Array(repeating: "00", count: myForms[self.myType]![0].count)
            self.isOnGameboard = false
        }
    }
    
    public func toString()->String {
        let sType = myType.toString()
        var sLetters = String()
        for letter in letters {
            sLetters.append(letter.uppercased())
        }
        var sGameArrayPositions = String()
        for gameArrayPosition in gameArrayPositions {
            sGameArrayPositions.append(gameArrayPosition + "-")
        }
        if sGameArrayPositions.count > 0 {
            sGameArrayPositions.removeLast()
        }
        let sRotateIndex = String(rotateIndex)
        let sPositionIndex = String(pieceFromPosition)
        let sIsOnGameboard = isOnGameboard ? "1" : "0"
        let myString = sType + "/" + sRotateIndex + "/" + sLetters + "/" + sGameArrayPositions + "/" + sPositionIndex + "/" + sIsOnGameboard
        
        return myString
    }
    
    deinit {
//        print("\n WordtrisShape \((type(of: self))) WAS REMOVED FROM MEMORY (DEINIT) \n")
    }

}


