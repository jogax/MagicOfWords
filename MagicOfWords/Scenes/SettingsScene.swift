//
//  SettingsScene.swift
//  MagicOfWords
//
//  Created by Jozsef Romhanyi on 02/06/2018.
//  Copyright © 2018 Jozsef Romhanyi. All rights reserved.
//

import Foundation
import GameKit

public protocol SettingsSceneDelegate: class {
    
    func backFromSettingsScene()
}

class SettingsScene: SKScene {
    var settingsSceneDelegate: SettingsSceneDelegate?
    let enabledAlpha: CGFloat = 1.0
    let disabledAlpha: CGFloat = 0.4
    var line = 0

    
    override func didMove(to view: SKView) {
        self.backgroundColor = SKColor(red: 255/255, green: 220/255, blue: 208/255, alpha: 1)
        createMenuItem(menuInt: .tcEnglish, firstLine: true)
        createMenuItem(menuInt: .tcGerman)
        createMenuItem(menuInt: .tcHungarian)
        createMenuItem(menuInt: .tcRussian)
        createMenuItem(menuInt: .tcCancel)
    }

    public func setDelegate(delegate: SettingsSceneDelegate) {
        settingsSceneDelegate = delegate
    }

    func createMenuItem(menuInt: TextConstants, firstLine: Bool = false, showValue: Bool = true, touchbar: Bool = true) {
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
        menuItem.alpha = enabledAlpha
        menuItem.colorBlendFactor = 0.9
        menuItem.text = GV.language.getText(menuInt)
        menuItem.zPosition = self.zPosition + 1
        menuItem.horizontalAlignmentMode = .center
        menuItem.verticalAlignmentMode = .center
        menuItem.name = String(menuInt.rawValue) + (touchbar ? "" : "noTouch")
        button.addChild(menuItem)
        self.addChild(button)
    }
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        let firstTouch = touches.first
        let touchLocation = firstTouch!.location(in: self)
        let nodes = self.nodes(at: touchLocation)
        if nodes.count > 0 {
            for node in nodes {
                let name = node.name
                if name != nil && node.alpha == enabledAlpha {
                    switch name {
                    case String(TextConstants.tcEnglish.rawValue):
                        GV.language.setLanguage(GV.language.getText(.tcEnglishShort))
                    case String(TextConstants.tcGerman.rawValue):
                        GV.language.setLanguage(GV.language.getText(.tcGermanShort))

                    case String(TextConstants.tcHungarian.rawValue):
                        GV.language.setLanguage(GV.language.getText(.tcHungarianShort))

                    case String(TextConstants.tcRussian.rawValue):
                        GV.language.setLanguage(GV.language.getText(.tcRussianShort))
                        
                   case String(TextConstants.tcCancel.rawValue):
                        settingsSceneDelegate!.backFromSettingsScene()
                        
                        //                    case String(TextConstants.tcChooseGameType.rawValue):
                        //                        menuSceneDelegate!.startChooseGameType()
                    //
                    default: break
                    }
                }
            }
        }
//        let enButton = self.childNode(withName: "button\(TextConstants.tcEnglish.rawValue)")!
//        if enLabel != nil {
//            enLabel!.text = GV.language.getText(.tcEnglish)
//        }
//        let deLabel = self.childNode(withName: String(TextConstants.tcGerman.rawValue))! as? SKLabelNode
//        if deLabel != nil {
//            deLabel!.text = GV.language.getText(.tcGerman)
//        }
//        let huLabel = self.childNode(withName: String(TextConstants.tcHungarian.rawValue))! as? SKLabelNode
//        if huLabel != nil {
//            huLabel!.text = GV.language.getText(.tcHungarian)
//        }
//        let ruLabel = self.childNode(withName: String(TextConstants.tcRussian.rawValue))! as? SKLabelNode
//        if ruLabel != nil {
//            ruLabel!.text = GV.language.getText(.tcRussian)
//        }

    }

}
