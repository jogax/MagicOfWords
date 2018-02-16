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
    var mySprite: SKSpriteNode
    let parent: SKScene
    let myForms: [MyShapes: [Int]] = [
        .Z_Shape_1 : [02, 01, 12, 11, 10, 22, 21, 20, 31, 30],
        .Z_Shape_2 : [01, 00, 12, 11, 10, 22, 21, 20, 32, 31],
        .L_Shape_1 :   [02, 01, 00, 12, 11, 10, 21, 22],
        .L_Shape_2 : [00, 01, 02, 10, 11, 12, 21, 22, 31, 32]
    ]
    init(type: MyShapes, parent: SKScene, blockSize: CGFloat) {
        self.parent = parent
        let blockSize = blockSize
        self.mySprite = SKSpriteNode()
        let texture = gridTexture(type: type, blockSize: blockSize)
        self.mySprite = SKSpriteNode(texture: texture, size: texture!.size())
    }
    
    public func sprite()->SKSpriteNode {
        return mySprite
    }
    
    
    func gridTexture(type: MyShapes, blockSize: CGFloat) -> SKTexture? {
        // Add 1 to the height and width to ensure the borders are within the sprite
        let count = type == .I_Shape_4 ? 4 : 3
        let size = CGSize(width: CGFloat(count)*blockSize+1.0, height: CGFloat(count)*blockSize+1.0)
        UIGraphicsBeginImageContext(size)
        
        guard let context = UIGraphicsGetCurrentContext() else {
            return nil
        }
        let bezierPath = UIBezierPath()
        let offset:CGFloat = 0.5
        var pointsSortedX: [CGPoint] = []
        for i in 0..<myForms[type]!.count {
            let actPoint = CGPoint(x: count - myForms[type]![i] / 10, y: myForms[type]![i] % 10)
            pointsSortedX.append(actPoint)
        }
        let pointsSortedY = pointsSortedX.sorted(by: {$0.y < $1.y})
        var startPoint = pointsSortedX[0] * blockSize
        var endPoint = CGPoint(x: 0, y: 0)
        // Draw Horizontal lines
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
        // Draw viertical lines
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
//        let offset = blockSize / 2.0 + 0.5
//        let x = CGFloat(row) * blockSize - (blockSize * CGFloat(rows)) / 2.0 + offset
//        let y = CGFloat(cols - col - 1) * blockSize - (blockSize * CGFloat(cols)) / 2.0 + offset
//        return CGPoint(x:x, y:y)
        return CGPoint(x:0, y:0)
    }
    
    static func getShapeImage (_ size: CGSize) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, false, 1)
        let ctx = UIGraphicsGetCurrentContext()
        let w = size.width / 100
        let h = size.height / 100
        
        ctx!.setStrokeColor(UIColor.greenAppleColor().cgColor)
        ctx!.setLineJoin (.round)
        ctx!.setLineCap (.round)
        
        ctx!.setLineWidth(w * 20)
        let points = [
            CGPoint(x: w * 10, y: h * 70),
            CGPoint(x: w * 50, y: h * 95),
            CGPoint(x: w * 80, y: h * 20)
        ]
        //        CGContextAddLines(ctx, points, points.count)
        ctx!.addLines(between: points)
        ctx!.strokePath()
        
        if let image = UIGraphicsGetImageFromCurrentImageContext() {
            return image
        }
        return UIImage()
    }

}


