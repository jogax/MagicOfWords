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
    case Grid_Shape = 0,
    Z_Shape_1,
    Z_Shape_2,
    L_Shape_1,
    L_Shape_2,
    L_Shape_3,
    T_Shape,
    Q_Shape,
    I_Shape_1,
    I_Shape_2,
    I_Shape_3,
    I_Shape_4
}


class WordTrisShape {
    let sizeOfShape = 3
    var mySprite: SKSpriteNode
    var myShape: SKSpriteNode
    let parent: SKScene
    let blockSize: CGFloat
    let letters: [String]
    var rotateIndex: Int = 0
    var origPosition: [CGPoint] = [CGPoint(x:0, y:0), CGPoint(x:0, y:0), CGPoint(x:0, y:0), CGPoint(x:0, y:0)]
    var myType: MyShapes
    // Shape Form
    // y:  x:   0   1   2   3
    // 3        x   x   x   x
    // 2        x   x   x   x
    // 1        x   x   x   x
    // 0        x   x   x   x
    
    let myForms: [MyShapes : [[Int]]] = [
        .Z_Shape_1 : [[10, 11, 01, 02], [00, 10, 11, 21], [02, 01, 11, 10], [21, 11, 10, 00]],
        .Z_Shape_2 : [[00, 01, 11, 12], [20, 10, 11, 01], [12, 11, 01, 00], [01, 11, 10, 20]],
        .L_Shape_1 : [[11, 10, 00], [10, 00, 01], [00, 01, 11], [01, 11, 10]]
//        .L_Shape_2 : [10, 00, 01, 02], [20, 10, 11, 01], [21, 11, 10, 00], [00, 01, 11, 12]],
//        .L_Shape_3 : [00, 01, 02, 12], [20, 10, 11, 01], [21, 11, 10, 00], [00, 01, 11, 12]]
    ]
    init(type: MyShapes, parent: SKScene, blockSize: CGFloat, letters: [String]) {
        self.parent = parent
        self.blockSize = blockSize
        self.letters = letters
        self.myType = type
        self.mySprite = SKSpriteNode()
        self.myShape = SKSpriteNode()
        mySprite.size = CGSize(width: blockSize * 3, height: blockSize * 3)
        let texture = gridTexture(type: type, blockSize: blockSize)
        self.myShape = SKSpriteNode(texture: texture, size: texture!.size())
        mySprite.addChild(myShape)
        myShape.position = CGPoint(x: mySprite.frame.midX, y: mySprite.frame.midY)
        myShape.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        addLettersToPositions()
    }
    
    private func addLettersToPositions() {
        let form = myForms[myType]
        for index in 0..<form![rotateIndex].count {
            let col = form![rotateIndex][index] / 10
            let row = form![rotateIndex][index] % 10
            let position = gridPosition(col: col, row: row)
            let label = SKLabelNode(fontNamed: "Noteworthy")
            label.position = position
            label.text = letters[index]
            label.fontColor = .black
            label.fontSize = parent.frame.width / 20
            label.horizontalAlignmentMode = .center
            let searchName = "label\(index)"
            label.name = searchName
            if mySprite.childNode(withName: searchName) != nil {
                mySprite.childNode(withName: searchName)!.removeFromParent()
            }
            mySprite.addChild(label)

        }
    }
    public func sprite()->SKSpriteNode {
        return mySprite
    }
    
    public func rotate() {
        var moveLetterAction: SKAction?
        rotateIndex = (rotateIndex + 1) % 4
        let vectors: [CGVector] = [CGVector(dx: 12, dy: -10), CGVector(dx: 8, dy: 10), CGVector(dx:-10, dy: 10), CGVector(dx: -10, dy: -5)]
        let rotateAction = SKAction.rotate(byAngle: -90 * GV.oneGrad, duration: 0.1)
        let rotateLetterAction = SKAction.rotate(byAngle: 90 * GV.oneGrad, duration: 0.1)
        mySprite.run(rotateAction)
//        addLettersToPositions()
        let form = myForms[myType]
        for index in 0..<form![rotateIndex].count {
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
    
    
    private func gridTexture(type: MyShapes, blockSize: CGFloat) -> SKTexture? {
        var tempPoints: [CGPoint] = []
        func addPoint(point: CGPoint) {
            let point1 = CGPoint(x: point.x, y: point.y)
            if !tempPoints.contains(point1) {
                tempPoints.append(point1)
            }
        }
        func generatePoints(type: MyShapes)->[CGPoint] {
            let form = myForms[type]!
            for index in 0..<form[rotateIndex].count {
                let formItem = form[rotateIndex][index]
                let xValue = formItem % 10
                let yValue = formItem / 10
                addPoint(point: CGPoint(x: xValue + 0, y: yValue + 0))
                addPoint(point: CGPoint(x: xValue + 1, y: yValue + 0))
                addPoint(point: CGPoint(x: xValue + 0, y: yValue + 1))
                addPoint(point: CGPoint(x: xValue + 1, y: yValue + 1))
            }
            return tempPoints
        }
        
        // Add 1 to the height and width to ensure the borders are within the sprite
        let count = type == .I_Shape_4 ? 4 : 3
        let size = CGSize(width: CGFloat(count)*blockSize+1.0, height: CGFloat(count)*blockSize+1.0)
        UIGraphicsBeginImageContext(size)
        guard let context = UIGraphicsGetCurrentContext() else {
            return nil
        }
        let bezierPath = UIBezierPath()
        let offset:CGFloat = 0.5
        let points = generatePoints(type: type)
        let pointsSortedX = points.sorted(by: {$0.x < $1.x || ($0.x == $1.x && $0.y < $1.y) })
        let pointsSortedY = points.sorted(by: {$0.y < $1.y || ($0.y == $1.y && $0.x < $1.x) })
//        for i in 0..<myForms[type]!.count {
//            let actPoint = CGPoint(x: count - myForms[type]![i] / 10, y: myForms[type]![i] % 10)
//            pointsSortedX.append(actPoint)
//        }
//        let pointsSortedY = pointsSortedX.sorted(by: {$0.y < $1.y})
        var startPoint = pointsSortedX[0] * blockSize
        var endPoint = CGPoint(x: 0, y: 0)
        // Draw Vertical lines
        for i in 0..<pointsSortedX.count {
            if (pointsSortedX[i].x * blockSize) == startPoint.x {
                endPoint = pointsSortedX[i] * blockSize
            } else {
                bezierPath.move(to: CGPoint(x: startPoint.x  + offset, y: startPoint.y))
                bezierPath.addLine(to: CGPoint(x: endPoint.x + offset, y: endPoint.y))
                startPoint = pointsSortedX[i] * blockSize
            }
//            let x = CGFloat(i)*blockSize + offset
//            bezierPath.move(to: startPoint)
//            bezierPath.addLine(to: endPoint)
        }
        bezierPath.move(to: CGPoint(x: startPoint.x  + offset, y: startPoint.y))
        bezierPath.addLine(to: CGPoint(x: endPoint.x + offset, y: endPoint.y))
        // Draw Horizontal lines
        startPoint = pointsSortedY[0] * blockSize
        for i in 0..<pointsSortedY.count {
            if (pointsSortedY[i].y * blockSize) == startPoint.y {
                endPoint = pointsSortedY[i] * blockSize
            } else {
            bezierPath.move(to: CGPoint(x: startPoint.x, y: startPoint.y  + offset))
            bezierPath.addLine(to: CGPoint(x: endPoint.x, y: endPoint.y  + offset))
            startPoint = pointsSortedY[i] * blockSize
            }
        }
        bezierPath.move(to: CGPoint(x: startPoint.x, y: startPoint.y  + offset))
        bezierPath.addLine(to: CGPoint(x: endPoint.x, y: endPoint.y  + offset))
        SKColor.gray.setStroke()
        bezierPath.lineWidth = 1.0
        bezierPath.stroke()
        context.addPath(bezierPath.cgPath)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        
        return SKTexture(image: image!)
    }
    func gridPosition(col:Int, row:Int) -> CGPoint {
        let offset = blockSize / 2.0 + 0.5
        let x = CGFloat(row) * blockSize - (blockSize * CGFloat(sizeOfShape)) / 2.0 + offset
        let y = CGFloat(sizeOfShape - col - 1) * blockSize - (blockSize * CGFloat(sizeOfShape)) / 1.6  + offset
        return CGPoint(x:x, y:y)
    }
}


