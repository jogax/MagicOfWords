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
        T_Shape_1, // 6
        O_Shape_1, // 7
        O_Shape_2, // 8
        I_Shape_1, // 9
        I_Shape_2, // 10
        I_Shape_3, // 11
        I_Shape_4, // 12
        I_Shape_5, // 13
        I_Shape_6, // 14
        I_Shape_7, // 15
        I_Shape_8, // 16
        NotUsed
    static var count: Int { return MyShapes.NotUsed.rawValue + 1}
    func toString()->String {
        let stringType = ["Z1", "Z2", "L1", "L2", "L3", "L4", "T1", "O1", "O2", "I1", "I2", "I3", "I4", "I5", "I6", "I7", "I8","NotUsed"]
        return stringType[self.rawValue]
    }
    static func toValue(name: String)->MyShapes {
        let stringType = ["Z1", "Z2", "L1", "L2", "L3", "L4", "T1", "O1", "O2", "I1", "I2", "I3", "I4", "I5", "I6", "I7", "I8","NotUsed"]
        return MyShapes(rawValue: stringType.index{$0 == name}!)!
    }

}
struct LetterCoordinates {
    var letter: String = ""
    var col: Int = 0
    var row: Int = 0
}
let myForms: [MyShapes : [(points:[Int], connects:[String])]] = [
    .Z_Shape_1 :    [(points:[00, 01, 11, 12], connects: ["0010", "1100", "0011", "1000"]),
                     (points:[20, 10, 11, 01], connects: ["0001", "0110", "1001", "0100"]),
                     (points:[12, 11, 01, 00], connects: ["1000", "0011", "1100", "0010"]),
                     (points:[01, 11, 10, 20], connects: ["0100", "1001", "0110", "0001"])], //OK
    
    
    .Z_Shape_2 :    [(points:[10, 11, 01, 02], connects: ["0010", "1001", "0110", "1000"]),
                     (points:[21, 11, 10, 00], connects: ["0001", "1100", "0011", "0100"]),
                     (points:[02, 01, 11, 10], connects: ["1000", "0110", "1001", "0010"]),
                     (points:[00, 10, 11, 21], connects: ["0100", "0011", "1100", "0001"])], //OK
    
    .L_Shape_1 :    [(points:[00, 10, 11], connects: ["0100", "0011", "1000"]),  
                     (points:[10, 11, 01], connects: ["0010", "1001", "0100"]),
                     (points:[11, 01, 00], connects: ["0001", "1100", "0010"]),
                     (points:[01, 00, 10], connects: ["1000", "0110", "0001"])], // OK
    
    .L_Shape_2 : [(points:[00, 01, 11], connects: ["0010", "1100", "0001"]),
                  (points:[10, 00, 01], connects: ["0001", "0110", "1000"]),
                  (points:[11, 10, 00], connects: ["1000", "0011", "0100"]),
                  (points:[01, 11, 10], connects: ["0100", "1001", "0010"])], // OK
//    .L_Shape_3 : [[21, 20, 10, 00], [02, 12, 11, 10], [00, 01, 11, 21], [10, 00, 01, 02]], // OK
//    .L_Shape_4 : [[20, 21, 11, 01], [12, 02, 01, 00], [01, 00, 10, 20], [00, 10, 11, 12]], // OK
//    .T_Shape_1 : [[12, 11, 10, 01], [01, 11, 21, 10], [00, 01, 02, 11], [20, 10, 00, 11]],  // OK
//    .O_Shape_1  : [[00, 01, 11, 10], [10, 11, 01, 00], [11, 01, 00, 11], [01, 00, 10, 11]], // OK
//    .O_Shape_2  : [[00, 10, 11, 01], [10, 00, 01, 11], [11, 10, 00, 01], [01, 11, 10, 00]], // OK
    .I_Shape_1 : [(points:[00], connects: ["0000"]),
                  (points:[00], connects: ["0000"]),
                  (points:[00], connects: ["0000"]),
                  (points:[00], connects: ["0000"])], // OK
    
    .I_Shape_2 : [(points:[00, 10], connects: ["0100", "0001"]),
                  (points:[00, 01], connects: ["0010", "1000"]),
                  (points:[10, 00], connects: ["0001", "0100"]),
                  (points:[01, 00], connects: ["1000", "0010"])], // OK
    
    .I_Shape_3 : [(points:[00, 10, 20], connects: ["0100", "0101", "0001"]),
                  (points:[00, 01, 02], connects: ["0010", "1010", "1000"]),
                  (points:[20, 10, 00], connects: ["0001", "0101", "0100"]),
                  (points:[02, 01, 00], connects: ["1000", "1010", "0010"])], // OK
                    
    .I_Shape_4 : [(points:[00, 10, 20, 30], connects: ["0100", "0101", "0101", "0001"]),
                  (points:[00, 01, 02, 03], connects: ["0010", "1010", "1010", "1000"]),
                  (points:[30, 20, 10, 00], connects: ["0001", "0101", "0101", "0100"]),
                  (points:[03, 02, 01, 00], connects: ["1000", "1010", "1010", "0010"])], // OK
    
    .I_Shape_5 : [(points:[00, 10, 20, 30, 40], connects: ["0100", "0101", "0101", "0101", "0001"]),
                  (points:[00, 01, 02, 03, 04], connects: ["0010", "1010", "1010", "1010", "1000"]),
                  (points:[40, 30, 20, 10, 00], connects: ["0001", "0101", "0101", "0101", "0100"]),
                  (points:[04, 03, 02, 01, 00], connects: ["1000", "1010", "1010", "1010", "0010"])], // OK
    
    .I_Shape_6 : [(points:[00, 10, 20, 30, 40, 50], connects: ["0100", "0101", "0101", "0101", "0101", "0001"]),
                  (points:[00, 01, 02, 03, 04, 05], connects: ["0010", "1010", "1010", "1010", "1010", "1000"]),
                  (points:[50, 40, 30, 20, 10, 00], connects: ["0001", "0101", "0101", "0101", "0101", "0100"]),
                  (points:[05, 04, 03, 02, 01, 00], connects: ["1000", "1010", "1010", "1010", "1010", "0010"])], // OK
    
    .I_Shape_7 : [ (points:[00, 10, 20, 30, 40, 50, 60], connects: ["0100", "0101", "0101", "0101", "0101", "0101", "0001"]),
                   (points:[00, 01, 02, 03, 04, 05, 06], connects: ["0010", "1010", "1010", "1010", "1010", "1010", "1000"]),
                   (points:[60, 50, 40, 30, 20, 10, 00], connects: ["0001", "0101", "0101", "0101", "0101", "0101", "0100"]),
                   (points:[06, 05, 04, 03, 02, 01, 00], connects: ["1000", "1010", "1010", "1010", "1010", "1010", "0010"])], // OK
    
    .I_Shape_8 : [(points:[00, 10, 20, 30, 40, 50, 60, 70], connects: ["0100", "0101", "0101", "0101", "0101", "0101", "0101", "0001"]),
                    (points:[00, 01, 02, 03, 04, 05, 06, 07], connects: ["0010", "1010", "1010", "1010", "1010", "1010", "1010", "1000"]),
                    (points:[70, 60, 50, 40, 30, 20, 10, 00], connects: ["0001", "0101", "0101", "0101", "0101", "0101", "0101", "0100"]),
                    (points:[07, 06, 05, 04, 03, 02, 01, 00], connects: ["1000", "1010", "1010", "1010", "1010", "1010", "1010", "0010"])]

]


class WTPiece: SKSpriteNode {
    let countRows: CGFloat = 3
//    var mySprite: SKSpriteNode
//    var myShape: SKSpriteNode
    let myParent: SKScene
    let blockSize: CGFloat
    let letters: [String]
    var gameArrayPositions = [String]()
    var usedLetters = [UsedLetter]()
    var arrayIndex: Int
    var pieceFromPosition = NoValue
    var isOnGameboard = false
    var createdFromLetters = false
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
            self.gameArrayPositions = Array(repeating: "00", count: myForms[self.myType]![0].points.count)
            for letter in letters {
                let usedLetter = UsedLetter(col: 0, row: 0, letter: letter)
                usedLetters.append(usedLetter)
            }
        }
    }
    
    init(fromChoosedWord: FoundedWord, parent: SKScene, blockSize: CGFloat) {
        self.myParent = parent
        self.blockSize = blockSize
        self.arrayIndex = 0
        self.myType = .I_Shape_1
        var letters = [String]()
        for usedLetter in fromChoosedWord.usedLetters {
            letters.append(usedLetter.letter)
        }
        usedLetters = fromChoosedWord.usedLetters
        self.letters = letters
        let texture = SKTexture()
        super.init(texture: texture, color: .clear, size: CGSize(width: 10, height: 10))
        (self.myType, self.rotateIndex) = getTypeFromLetters(usedLetters: fromChoosedWord.usedLetters)
        if myType != .NotUsed {
            self.size = calculateSize()
            addLettersToPositions()
            self.gameArrayPositions = Array(repeating: "00", count: myForms[self.myType]![0].points.count)
        }
        createdFromLetters = true
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
    
    private func getTypeFromLetters(usedLetters: [UsedLetter])->(MyShapes, Int) {
        let searchTypes: [MyShapes] = [ .Z_Shape_1, // : [[00, 01, 11, 12], [20, 10, 11, 01], [12, 11, 01, 00], [01, 11, 10, 20]], //OK
            .I_Shape_8, // : [[00, 10, 20, 30, 40, 50, 60, 70], [00, 01, 02, 03, 04, 05, 06, 07], [70, 60, 50, 40, 30, 20, 10, 00], [07, 06, 05, 04, 03, 02, 01, 00]]
            .I_Shape_7, // : [[00, 10, 20, 30, 40, 50, 60], [00, 01, 02, 03, 04, 05, 06], [60, 50, 40, 30, 20, 10, 00], [06, 05, 04, 03, 02, 01, 00]]
            .I_Shape_6, // : [[00, 10, 20, 30, 40, 50], [00, 01, 02, 03, 04, 05], [50, 40, 30, 20, 10, 00], [05, 04, 03, 02, 01, 00]]
            .I_Shape_5, // : [[00, 10, 20, 30, 40], [00, 01, 02, 03, 04], [40, 30, 20, 10, 00], [04, 03, 02, 01, 00]]
//            .O_Shape_1, //  : [[00, 01, 11, 10], [10, 11, 01, 00], [11, 01, 00, 11], [01, 00, 10, 11]]
//            .O_Shape_2, //  : [[00, 10, 11, 01], [10, 00, 01, 11], [11, 10, 00, 01], [01, 11, 10, 00]]
            .I_Shape_4, // : [[00, 10, 20, 30], [00, 01, 02, 03], [30, 20, 10, 00], [03, 02, 01, 00]]
            .I_Shape_3, // : [[00, 10, 20], [00, 01, 02], [20, 10, 00], [02, 01, 00]]
            .I_Shape_2, // : [[00, 10], [00, 01], [10, 00], [01, 00]]
            .I_Shape_1, // : [[00], [00], [00], [00]]
        ]
        var minCol = usedLetters[0].col
        var maxCol = usedLetters[0].col
        var minRow = usedLetters[0].row
        var maxRow = usedLetters[0].row
        for usedLetter in usedLetters {
            minCol = minCol > usedLetter.col ? usedLetter.col : minCol
            maxCol = maxCol < usedLetter.col ? usedLetter.col : maxCol
            minRow = minRow > usedLetter.row ? usedLetter.row : minRow
            maxRow = maxRow < usedLetter.row ? usedLetter.row : maxRow
        }
        var myPositions = [Int]()
        for usedLetter in usedLetters {
            let position = 10 * (usedLetter.col - minCol) + usedLetter.row - minRow
            myPositions.append(position)
        }
//        maxCol = maxCol - minCol
//        minCol = 0
//        maxRow = maxRow - minRow
//        minRow = 0
        for type in searchTypes {
            let forms = myForms[type]
            if forms![0].points.count == usedLetters.count {
                for rotateIndex in 0...3 {
                    let form = forms![rotateIndex].points
                    if form == myPositions {
                        return (type, (rotateIndex + 1) % 4)
                    }
                }
            }
        }
        return (.NotUsed, 0)
    }
    private func calculateSize()->CGSize {
        let form = myForms[myType]![rotateIndex]
        var maxCol = 0
        var maxRow = 0
        for index in 0..<form.points.count {
            let col = form.points[index] / 10
            let row = form.points[index] % 10
            maxCol = col > maxCol ? col : maxCol
            maxRow = row > maxRow ? row : maxRow
        }
        let sizeMultiplier = blockSize * 0.8
        let size = CGSize(width: sizeMultiplier * CGFloat(maxRow + 1), height: sizeMultiplier * CGFloat(maxCol + 1))
        return size
    }
    
    private func generateNameArray()->[String] {
        let form = myForms[myType]![rotateIndex]
        var nameArray = [String]()
        
        for index in 0..<form.connects.count {
            let name = "GraySprite" + form.connects[index]
            nameArray.append(name)
        }
        return nameArray

    }
    private func addLettersToPositions() {
        let form = myForms[myType]![rotateIndex]
        let nameArray = generateNameArray()
        for index in 0..<form.points.count {
            let col = form.points[index] / 10
            let row = form.points[index] % 10
            let position = gridPosition(col: col, row: row)
            let width = blockSize * (GV.basicDataRecord.buttonType == GV.ButtonTypeElite ? 1.0 : 0.9)
            let frameForLetter = SKSpriteNode(color: .clear, size: CGSize(width: width, height: width))
            frameForLetter.position = position
            frameForLetter.color = .white
            let name = nameArray[index]
            if GV.basicDataRecord.buttonType == GV.ButtonTypeElite {
                frameForLetter.texture = SKTexture(imageNamed: name)
            }
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
        self.usedLetters = [UsedLetter]()
        if gameArrayPositions.count == myForms[myType]![0].points.count {
            for index in 0..<gameArrayPositions.count {
                let col = gameArrayPositions[index].col
                let row = gameArrayPositions[index].row
                let letter = letters[index]
                self.gameArrayPositions[index] = String(col) + String(row)
                self.usedLetters.append(UsedLetter(col: col,row: row, letter: letter))
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

        let form = myForms[myType]
        if form![0].points.count > 1 {  // rotate only pieces of 2 or 3 letters
            rotateIndex = (rotateIndex + 1) % 4
            let nameArray = generateNameArray()
            let rotateAction = SKAction.rotate(byAngle: -90 * GV.oneGrad, duration: 0.1)
    //        mySprite.anchorPoint = CGPoint(x: 0.1, y: 0.1)
            self.run(rotateAction)
    //        addLettersToPositions()
            for index in 0..<form![rotateIndex].points.count {
                let searchName = "label\(index)"
                guard let child = self.childNode(withName: searchName) else {
                    continue
                }
                
                let rotateLetterAction = SKAction.rotate(byAngle: 90 * GV.oneGrad, duration: 0.1)
                if GV.basicDataRecord.buttonType == GV.ButtonTypeElite {
                    (child as! SKSpriteNode).texture = SKTexture(imageNamed: nameArray[index])
                }
                child.run(rotateLetterAction)
             }
        }
    }
    
    
    private func gridPosition(col:Int, row:Int) -> CGPoint {
        let offset = blockSize * 0.5 + 0.5
        let x = self.frame.minX + (CGFloat(row) * blockSize - 1) + offset
        let y = self.frame.minY + (CGFloat(col) * blockSize - 1) + offset * 0.8 // / 2.2
        return CGPoint(x:x, y:y)
    }
    
    public func getLetterCoordinates()->[LetterCoordinates] {
        let coordinates = myForms[myType]![rotateIndex].points
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
            self.gameArrayPositions = Array(repeating: "00", count: myForms[self.myType]![0].points.count)
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


