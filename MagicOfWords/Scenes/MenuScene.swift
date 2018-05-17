//
//  MenuScene.swift
//  Szómágia
//
//  Created by Jozsef Romhanyi on 30/01/2018.
//  Copyright © 2018 Jozsef Romhanyi. All rights reserved.
//

import Foundation
import GameKit

public protocol MenuSceneDelegate: class {
    
    /// Method called when New Game choosed
    func startNewGame()
    
    /// Method called when Continue choosed
    func continueGame()
    
    /// Method called when Choose Game Type pressed
    func startChooseGameType()
    
    /// Method called when Settings choosed
    func startSettings()
}

class MenuScene: SKScene {
    var menuSceneDelegate: MenuSceneDelegate?
    override func didMove(to view: SKView) {
        self.backgroundColor = SKColor(red: 255/255, green: 220/255, blue: 208/255, alpha: 1)
        if realm.objects(GameDataModel.self).filter("gameType = %d and gameStatus = %d", GV.gameType, GV.GameStatusNew).count > 0 {
            createMenuItem(menuInt: .tcNewGame, firstLine: true)
        }
        if realm.objects(GameDataModel.self).filter("gameType = %d and gameStatus = %d", GV.gameType, GV.GameStatusPlaying).count > 0 {
            createMenuItem(menuInt: .tcContinue)
        }
        createMenuItem(menuInt: .tcChooseGameType)
        createMenuItem(menuInt: .tcSettings)
    }
    public func setDelegate(delegate: MenuSceneDelegate) {
        menuSceneDelegate = delegate
    }
    var line = 0
    func createMenuItem(menuInt: TextConstants, firstLine: Bool = false) {
        line = firstLine ? 1 : line + 1
        let menuItem = SKLabelNode(fontNamed: "Noteworthy")// Snell Roundhand")
        let startYPosition = self.frame.size.height * 0.80
        menuItem.text = GV.language.getText(menuInt)
        menuItem.name = String(menuInt.rawValue)
        menuItem.fontSize = self.frame.size.height / 30
        menuItem.position = CGPoint(x: self.frame.size.width / 2, y: startYPosition - (CGFloat(line) * 50) )
        menuItem.fontColor = SKColor.blue
        menuItem.color = UIColor.brown
        self.addChild(menuItem)
    }
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if menuSceneDelegate == nil {
            return
        }
        let firstTouch = touches.first
        let touchLocation = firstTouch!.location(in: self)
        let nodes = self.nodes(at: touchLocation)
        if nodes.count > 0 {
            if let name = nodes.first!.name {
                switch name {
                    case String(TextConstants.tcNewGame.rawValue):
                        menuSceneDelegate!.startNewGame()
                    case String(TextConstants.tcContinue.rawValue):
                        menuSceneDelegate!.continueGame()
                    
                    case String(TextConstants.tcSettings.rawValue):
                        menuSceneDelegate!.startSettings()
                    
                case String(TextConstants.tcChooseGameType.rawValue):
                    menuSceneDelegate!.startChooseGameType()

                default: break
                }
            }
        }
    }
    deinit {
        print("\n THE SCENE \((type(of: self))) WAS REMOVED FROM MEMORY (DEINIT) \n")
    }
    
    
}

