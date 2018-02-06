//
//  CollectWordsScene.swift
//  MagicOfWords
//
//  Created by Jozsef Romhanyi on 06/02/2018.
//  Copyright © 2018 Jozsef Romhanyi. All rights reserved.
//

import Foundation
import GameplayKit

public protocol CollectWordsSceneDelegate: class {
    
    /// Method called when Game finished
    func gameFinished()
    
}
class CollectWordsScene: SKScene {
    var collectWordsSceneDelegate: CollectWordsSceneDelegate?
    override func didMove(to view: SKView) {
        self.backgroundColor = SKColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1)
        createMenuItem(menuInt: .tcCancel, firstLine: true)
    }

    public func setDelegate(delegate: CollectWordsSceneDelegate) {
        collectWordsSceneDelegate = delegate
    }

    var line = 0
    func createMenuItem(menuInt: TextConstants, firstLine: Bool = false) {
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
