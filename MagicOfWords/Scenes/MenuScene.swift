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
    
    func startNewGame()
    func continueGame()
    func showFinishedGames()
    func startChooseGameType()
    func startSettings()
}

class MenuScene: SKScene {
    var menuSceneDelegate: MenuSceneDelegate?
    let enabledAlpha: CGFloat = 1.0
    let disabledAlpha: CGFloat = 0.4
    override func didMove(to view: SKView) {
        self.backgroundColor = SKColor(red: 255/255, green: 220/255, blue: 208/255, alpha: 1)
        var count = realm.objects(GameDataModel.self).filter("gameType = %d and gameStatus = %d", GV.gameType, GV.GameStatusNew).count
        createMenuItem(menuInt: .tcNewGame, firstLine: true, count: count)
        count = realm.objects(GameDataModel.self).filter("gameType = %d and gameStatus = %d", GV.gameType, GV.GameStatusPlaying).count
        createMenuItem(menuInt: .tcContinue, count: count)
        count = realm.objects(GameDataModel.self).filter("gameType = %d and gameStatus = %d", GV.gameType, GV.GameStatusFinished).count
        createMenuItem(menuInt: .tcFinished, count: count)
        createMenuItem(menuInt: .tcChooseGameType, showValue: false, touchbar: false)
        createMenuItem(menuInt: .tcSettings, showValue: false, touchbar: false)
    }
    public func setDelegate(delegate: MenuSceneDelegate) {
        menuSceneDelegate = delegate
    }
    var line = 0
    
    func createMenuItem(menuInt: TextConstants, firstLine: Bool = false, count: Int = NoValue, showValue: Bool = true, touchbar: Bool = true) {
        let texture = SKTexture(imageNamed: "button.png")
        let button = SKSpriteNode(texture: texture, color: .white, size: CGSize(width: self.size.width * 0.5, height: self.size.height * 0.2))
        line = firstLine ? 1 : line + 1
        let startYPosition = self.frame.size.height * 0.80
        button.size = CGSize(width: self.frame.size.width * 0.8, height: self.frame.size.height * 0.1)
        button.position = CGPoint(x: self.frame.size.width / 2, y: startYPosition - (CGFloat(line) * self.frame.size.height * 0.1) )
        button.name = String("button\(menuInt.rawValue)")
        let menuItem = SKLabelNode(fontNamed: "TimesNewRomanPS-BoldMT")// Snell Roundhand")
        menuItem.fontSize = self.frame.size.height / 30
        menuItem.position = CGPoint(x:0, y: button.frame.height * 0.1)
        menuItem.fontColor = SKColor.blue
        menuItem.alpha = showValue && count > 0 ? enabledAlpha : disabledAlpha
        menuItem.colorBlendFactor = 0.9
        menuItem.text = GV.language.getText(menuInt, values: showValue ? "(\(count))" : "")
        menuItem.zPosition = self.zPosition + 1
        menuItem.horizontalAlignmentMode = .center
        menuItem.verticalAlignmentMode = .center
        menuItem.name = String(menuInt.rawValue) + (touchbar ? "" : "noTouch")
        button.addChild(menuItem)
        self.addChild(button)
    }
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if menuSceneDelegate == nil {
            return
        }
        let firstTouch = touches.first
        let touchLocation = firstTouch!.location(in: self)
        let nodes = self.nodes(at: touchLocation)
        if nodes.count > 0 {
            for node in nodes {
                let name = node.name
                if name != nil && node.alpha == enabledAlpha {
                    switch name {
                    case String(TextConstants.tcNewGame.rawValue):
                        menuSceneDelegate!.startNewGame()
                    case String(TextConstants.tcContinue.rawValue):
                        menuSceneDelegate!.continueGame()
                    
                    case String(TextConstants.tcFinished.rawValue):
                        menuSceneDelegate!.showFinishedGames()
                    
                    case String(TextConstants.tcSettings.rawValue):
                        menuSceneDelegate!.startSettings()

                    case String(TextConstants.tcChooseGameType.rawValue):
                        menuSceneDelegate!.startChooseGameType()

                    default: break
                    }
                }
            }
        }
    }
    
    deinit {
        print("\n THE SCENE \((type(of: self))) WAS REMOVED FROM MEMORY (DEINIT) \n")
    }
    
    
}

