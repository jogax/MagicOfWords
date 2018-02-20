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
                gameArray![col][row].position = grid!.gridPosition(col: col, row: row) +
                    CGPoint (x:parentScene.frame.midX, y:parentScene.frame.midY * 0.874)
                gameArray![col][row].fontSize = parentScene.frame.width / 20
                parentScene.addChild(gameArray![col][row])
            }
        }
        parentScene.addChild(self)
    }
    
    private func createNewGameArray(size: Int) -> [[WordTrisGameboardItem]] {
        var gameArray: [[WordTrisGameboardItem]] = []
        
        for i in 0..<size {
            gameArray.append( [WordTrisGameboardItem]() )
            
            for _ in 0..<size {
                gameArray[i].append( WordTrisGameboardItem(letter: " ") )
            }
        }
        
        return gameArray
    }

    private func createBackgroundShape(size: Int) {
        //        let myShape =

        grid = Grid(blockSize: blockSize!, rows:size, cols:size)
        grid!.position = CGPoint (x:parentScene.frame.midX, y:parentScene.frame.midY * 0.9)
        grid!.name = "Gameboard"
        self.addChild(grid!)
        
    }


    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
