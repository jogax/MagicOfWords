//
//  CollectWordsScene.swift
//  MagicOfWords
//
//  Created by Jozsef Romhanyi on 06/02/2018.
//  Copyright © 2018 Jozsef Romhanyi. All rights reserved.
//

import Foundation
import GameplayKit

public protocol WordTrisSceneDelegate: class {
    
    /// Method called when Game finished
    func gameFinished()
    
}
class WordTrisScene: SKScene {
    enum MyShapes: Int {
        case Grid_Shape = 0, Z_Shape, L_Shape, T_Shape, I_Shape, Edge_Shape
    }
    var collectWordsSceneDelegate: WordTrisSceneDelegate?
    override func didMove(to view: SKView) {
        self.backgroundColor = SKColor(red: 223/255, green: 255/255, blue: 216/255, alpha: 1)
//        createMenuItem(menuInt: .tcPackage, firstLine: true)
        createMenuItem(menuInt: .tcCancel)
//        createBackgroundShape()
        createGridShape(type: .Grid_Shape, position: CGPoint(x:self.frame.midX, y: self.frame.midY))
   }

    public func setDelegate(delegate: WordTrisSceneDelegate) {
        collectWordsSceneDelegate = delegate
    }

    var line = 0
    private func createMenuItem(menuInt: TextConstants, firstLine: Bool = false) {
        line = firstLine ? 1 : line + 1
        let menuItem = SKLabelNode(fontNamed: "Noteworthy")// Snell Roundhand")
        let startYPosition = self.frame.size.height * 0.80
        menuItem.text = GV.language.getText(menuInt)
        menuItem.name = String(menuInt.rawValue)
        menuItem.fontSize = self.frame.size.height / 30
        menuItem.position = CGPoint(x: self.frame.size.width / 2, y: startYPosition - (CGFloat(line) * 45) )
        menuItem.fontColor = SKColor.blue
        menuItem.color = UIColor.brown
        self.addChild(menuItem)
    }
    
    private func createBackgroundShape() {
//        let myShape =
//        let countRows = 10
//        let blockSize = self.frame.size.width * 0.95 / CGFloat(countRows)
//        if let grid = Grid(blockSize: blockSize, rows:countRows, cols:countRows) {
//            grid.position = CGPoint (x:frame.midX, y:frame.midY * 0.8)
//            addChild(grid)
//
//        }
    }
    
    private func createGridShape(type: MyShapes, cols: Int = 0, position: CGPoint) {
        let path = CGMutablePath()
        path.move(to: CGPoint(x: self.frame.midX, y: self.frame.midY))
        path.addLine(to: CGPoint(x: self.frame.origin.x + self.frame.width / 2, y: self.frame.origin.y))
        let myShape = SKShapeNode(path: path)
        myShape.fillColor = .green
        
        self.addChild(myShape)
    }
    

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if collectWordsSceneDelegate == nil {
            return
        }
        let firstTouch = touches.first
        let touchLocation = firstTouch!.location(in: self)
        let nodes = self.nodes(at: touchLocation)
        if nodes.count > 0 {
            if let name = nodes.first!.name {
                switch name {
                case String(TextConstants.tcCancel.rawValue):
                    collectWordsSceneDelegate!.gameFinished()

                default: break
                }
            }
        }
    }
    
    
    deinit {
        print("\n THE SCENE \((type(of: self))) WAS REMOVED FROM MEMORY (DEINIT) \n")
    }
}

class Grid:SKSpriteNode {
    var rows:Int!
    var cols:Int!
    var blockSize:CGFloat!
    
    convenience init?(blockSize:CGFloat,rows:Int,cols:Int) {
        guard let texture = Grid.gridTexture(blockSize: blockSize,rows: rows, cols:cols) else {
            return nil
        }
        self.init(texture: texture, size: texture.size())
        self.blockSize = blockSize
        self.rows = rows
        self.cols = cols
    }
    
    class func gridTexture(blockSize:CGFloat,rows:Int,cols:Int) -> SKTexture? {
        // Add 1 to the height and width to ensure the borders are within the sprite
        let size = CGSize(width: CGFloat(cols)*blockSize+1.0, height: CGFloat(rows)*blockSize+1.0)
        UIGraphicsBeginImageContext(size)
        
        guard let context = UIGraphicsGetCurrentContext() else {
            return nil
        }
        let bezierPath = UIBezierPath()
        let offset:CGFloat = 0.5
        // Draw vertical lines
        for i in 0...cols {
            let x = CGFloat(i)*blockSize + offset
            bezierPath.move(to: CGPoint(x: x, y: 0))
            bezierPath.addLine(to: CGPoint(x: x, y: size.height))
        }
        // Draw horizontal lines
        for i in 0...rows {
            let y = CGFloat(i)*blockSize + offset
            bezierPath.move(to: CGPoint(x: 0, y: y))
            bezierPath.addLine(to: CGPoint(x: size.width, y: y))
        }
        SKColor.gray.setStroke()
        bezierPath.lineWidth = 1.0
        bezierPath.stroke()
        context.addPath(bezierPath.cgPath)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return SKTexture(image: image!)
    }
    
    func gridPosition(row:Int, col:Int) -> CGPoint {
        let offset = blockSize / 2.0 + 0.5
        let x = CGFloat(col) * blockSize - (blockSize * CGFloat(cols)) / 2.0 + offset
        let y = CGFloat(rows - row - 1) * blockSize - (blockSize * CGFloat(rows)) / 2.0 + offset
        return CGPoint(x:x, y:y)
    }
}

