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
        Z_Shape_1,
        Z_Shape_2,
        L_Shape_1,
        L_Shape_2,
        L_Shape_3,
        L_Shape_4,
        T_Shape_1,
        T_Shape_2,
        O_Shape,
        I_Shape_1,
        I_Shape_2,
        I_Shape_3,
        Not_Used
    static var count: Int { return MyShapes.Not_Used.hashValue + 1}

}
let myForms: [MyShapes : [Int]] = [
    .Z_Shape_1 : [02, 01, 11, 10], //OK
    .Z_Shape_2 : [00, 01, 11, 12], //OK
    .L_Shape_1 : [11, 10, 00], // OK
    .L_Shape_2 : [21, 20, 10, 00], // OK
    .L_Shape_3 : [20, 21, 11, 01], // OK
    .L_Shape_4 : [02, 01, 00, 10, 20], // OK
    .T_Shape_1 : [12, 11, 10, 01],  //OK
    .T_Shape_2 : [22, 21, 20, 11, 01], //OK
    .O_Shape   : [00, 01, 11, 10], // OK
    .I_Shape_1 : [00], // OK
    .I_Shape_2 : [10, 00],
    .I_Shape_3 : [20, 10, 00]
]


class WordTrisShape {
    let countRows: CGFloat = 3
    var mySprite: SKSpriteNode
//    var myShape: SKSpriteNode
    let parent: SKScene
    let blockSize: CGFloat
    let letters: [String]
    var rotateIndex: Int = 0
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
    init(type: MyShapes, parent: SKScene, blockSize: CGFloat, letters: [String]) {
        self.parent = parent
        self.blockSize = blockSize
        self.letters = letters
        self.myType = type
        self.mySprite = SKSpriteNode()
        mySprite.size = calculateSize()
        addLettersToPositions()
    }
    
    private func calculateSize()->CGSize {
        let form = myForms[myType]!
        var maxCol = 0
        var maxRow = 0
        for index in 0..<form.count {
            let col = form[index] / 10
            let row = form[index] % 10
            maxCol = col > maxCol ? col : maxCol
            maxRow = row > maxRow ? row : maxRow
        }
        let size = CGSize(width: blockSize * CGFloat(maxCol + 1), height: blockSize * CGFloat(maxRow + 1))
        return size
    }
    private func addLettersToPositions() {
        let form = myForms[myType]
        for index in 0..<form!.count {
            let col = form![index] / 10
            let row = form![index] % 10
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
        var moveLetterAction: SKAction?
        rotateIndex = (rotateIndex + 1) % 4
        let corr = parent.frame.width / 65
        let vectors: [CGVector] = [CGVector(dx: 0, dy: 0), // this is not used, because the orig Value will be set
                                   CGVector(dx: 1.5 * corr, dy: 1.0 * corr),
                                   CGVector(dx:-1.0 * corr, dy: 1.3 * corr),
                                   CGVector(dx: -1.5 * corr, dy: -1.8 * corr)]
        let rotateAction = SKAction.rotate(byAngle: -90 * GV.oneGrad, duration: 0.1)
        let rotateLetterAction = SKAction.rotate(byAngle: 90 * GV.oneGrad, duration: 0.1)
//        mySprite.anchorPoint = CGPoint(x: 0.1, y: 0.1)
        mySprite.run(rotateAction)
//        addLettersToPositions()
        let form = myForms[myType]
        for index in 0..<form!.count {
            let searchName = "label\(index)"
            guard let child = mySprite.childNode(withName: searchName) else {
                continue
            }
            if rotateIndex == 1 {
                origPosition[index] = child.position
            }
            
            if rotateIndex == 0 {
                moveLetterAction = SKAction.move(to: origPosition[index], duration: 0.1)
            } else {
                moveLetterAction = SKAction.move(by: vectors[rotateIndex], duration: 0.1)
            }
            child.run(SKAction.group([moveLetterAction!, rotateLetterAction]))
         }

    }
    
    
//    private func gridTexture(type: MyShapes, blockSize: CGFloat) -> SKTexture? {
//        var tempPoints: [CGPoint] = []
//        func addPoint(point: CGPoint) {
//            let point1 = CGPoint(x: point.x, y: point.y)
//            if !tempPoints.contains(point1) {
//                tempPoints.append(point1)
//            }
//        }
//        func generatePoints(type: MyShapes)->[CGPoint] {
//            let form = myForms[type]!
//            for index in 0..<form.count {
//                let formItem = form[index]
//                let xValue = formItem % 10
//                let yValue = formItem / 10
//                addPoint(point: CGPoint(x: xValue + 0, y: yValue + 0))
//                addPoint(point: CGPoint(x: xValue + 1, y: yValue + 0))
//                addPoint(point: CGPoint(x: xValue + 0, y: yValue + 1))
//                addPoint(point: CGPoint(x: xValue + 1, y: yValue + 1))
//            }
//            return tempPoints
//        }
//
//        // Add 1 to the height and width to ensure the borders are within the sprite
//        let count = myForms[type]?.count
//        var minPoint = CGPoint(x: 0, y: 0)
//        var maxPoint = CGPoint(x: 0, y: 0)
//        for index in 0..<count! {
//            let x = CGFloat(myForms[type]![index] % 10)
//            let y = CGFloat(myForms[type]![index] / 10)
//            if x < minPoint.x {
//                minPoint.x = x
//            }
//            if x > maxPoint.x {
//                maxPoint.x = x
//            }
//            if y < minPoint.y {
//                minPoint.y = y
//            }
//            if y > maxPoint.y {
//                maxPoint.y = y
//            }
//        }
//        let size = CGSize(width: (maxPoint.x - minPoint.x + 1)*blockSize+1.0, height:(maxPoint.y - minPoint.y + 1)*blockSize+1.0)
//        UIGraphicsBeginImageContext(size)
//        guard let context = UIGraphicsGetCurrentContext() else {
//            return nil
//        }
//        let bezierPath = UIBezierPath()
//        let offset:CGFloat = 0.5
//        let points = generatePoints(type: type)
//        let pointsSortedX = points.sorted(by: {$0.x < $1.x || ($0.x == $1.x && $0.y < $1.y) })
//        let pointsSortedY = points.sorted(by: {$0.y < $1.y || ($0.y == $1.y && $0.x < $1.x) })
//        var startPoint = pointsSortedX[0] * blockSize
//        var endPoint = CGPoint(x: 0, y: 0)
//        // Draw Vertical lines
//        for i in 0..<pointsSortedX.count {
//            if (pointsSortedX[i].x * blockSize) == startPoint.x {
//                endPoint = pointsSortedX[i] * blockSize
//            } else {
//                bezierPath.move(to: CGPoint(x: startPoint.x  + offset, y: startPoint.y))
//                bezierPath.addLine(to: CGPoint(x: endPoint.x + offset, y: endPoint.y))
//                startPoint = pointsSortedX[i] * blockSize
//            }
////            let x = CGFloat(i)*blockSize + offset
////            bezierPath.move(to: startPoint)
////            bezierPath.addLine(to: endPoint)
//        }
//        bezierPath.move(to: CGPoint(x: startPoint.x  + offset, y: startPoint.y))
//        bezierPath.addLine(to: CGPoint(x: endPoint.x + offset, y: endPoint.y))
//        // Draw Horizontal lines
//        startPoint = pointsSortedY[0] * blockSize
//        for i in 0..<pointsSortedY.count {
//            if (pointsSortedY[i].y * blockSize) == startPoint.y {
//                endPoint = pointsSortedY[i] * blockSize
//            } else {
//            bezierPath.move(to: CGPoint(x: startPoint.x, y: startPoint.y  + offset))
//            bezierPath.addLine(to: CGPoint(x: endPoint.x, y: endPoint.y  + offset))
//            startPoint = pointsSortedY[i] * blockSize
//            }
//        }
//        bezierPath.move(to: CGPoint(x: startPoint.x, y: startPoint.y  + offset))
//        bezierPath.addLine(to: CGPoint(x: endPoint.x, y: endPoint.y  + offset))
//        SKColor.gray.setStroke()
//
//        bezierPath.lineWidth = 1.5
//        bezierPath.stroke()
//        context.addPath(bezierPath.cgPath)
//
//        let image = UIGraphicsGetImageFromCurrentImageContext()
//
//        UIGraphicsEndImageContext()
//
//        return SKTexture(image: image!)
//    }
    
    func gridPosition(col:Int, row:Int) -> CGPoint {
        let offset = blockSize * 0.5 + 0.5
        let x = mySprite.frame.minX + (CGFloat(row) * blockSize - 1) + offset
        let y = mySprite.frame.minY + (CGFloat(col) * blockSize - 1) + offset * 0.8 // / 2.2
        return CGPoint(x:x, y:y)
    }

    public func copy()->WordTrisShape {
        let copy = WordTrisShape(type: myType, parent: parent, blockSize: blockSize, letters: letters)

        return copy
    }
}


