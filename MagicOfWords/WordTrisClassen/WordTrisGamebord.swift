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
    var parentScene: SKScene
    var size: Int
    var grid: Grid?
    let blockSize: CGFloat?
    var gameArray: [[WordTrisGameboardItem]]?
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
        if shape.sprite().frame.minY >= self.children[0].frame.minY {
            _ = self.children[0].children.map {($0 as! WordTrisGameboardItem).fixIfTemporary()}
            return true
        } else {
            _ = self.children[0].children.map {($0 as! WordTrisGameboardItem).clearIfTemporary()}
            return false
        }
    }
    
    public func showSpriteOnGameboard(shape: WordTrisShape) {
        if shape.sprite().frame.minY >= self.children[0].frame.minY {
            shape.sprite().alpha = 0
            _ = self.children[0].children.map {($0 as! WordTrisGameboardItem).clearIfTemporary()}
            _ = self.children[0].children.map {check(child: $0, shape: shape)}
        } else {
            _ = self.children[0].children.map {($0 as! WordTrisGameboardItem).clearIfTemporary()}
        }
    }
    private func check(child: SKNode, shape: WordTrisShape) {
        if (child as! WordTrisGameboardItem).status == .empty {
            let absPosition = grid!.position + child.position
            let sprite = shape.sprite()
            _ = sprite.children.map{
                let minX = $0.frame.minX + sprite.position.x
                let maxX = $0.frame.maxX + sprite.position.x
                let minY = $0.frame.minY + sprite.position.y
                let maxY = $0.frame.maxY + sprite.position.y
                let name = $0.name
                if minX <= absPosition.x && maxX >= absPosition.x && minY <= absPosition.y && maxY >= absPosition.y {
                    (child as! WordTrisGameboardItem).setLetter(letter: ($0.children.first! as! SKLabelNode).text!, status: .temporary, color: SKColor(red: 212/255, green: 249/255, blue: 236/255, alpha: 1.0))
                    
                }
            }
        }
    }


    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
