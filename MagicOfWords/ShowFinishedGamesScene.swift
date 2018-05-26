//
//  ShowFinishedGamesScene.swift
//  MagicOfWords
//
//  Created by Jozsef Romhanyi on 24/05/2018.
//  Copyright © 2018 Jozsef Romhanyi. All rights reserved.
//

import Foundation
import GameKit

public protocol ShowFinishedGamesSceneDelegate: class {
    func backToMenuScene()
}
class ShowFinishedGamesScene: SKScene {
    let xMultiplierTab: [CGFloat] = [0.3, 0.5, 0.8]
    var myDelegate: ShowFinishedGamesSceneDelegate?
    let OKLabelName = "°°°OKLabel°°°"
    let OKButtonName = "°°°OKButton°°°"
    
    override func didMove(to view: SKView) {
        self.backgroundColor = SKColor(red: 200/255, green: 220/255, blue: 208/255, alpha: 1)
        createShowingItem()
    }
    
    private func createShowingItem() {
        let finishedGames = realm.objects(GameDataModel.self).filter("gameType = %d and gameStatus = %d", GV.gameType, GV.GameStatusFinished)
        createHeader(text: GV.language.getText(.tcGameNumber), index: 0)
        createHeader(text: GV.language.getText(.tcScore), index: 1)
        createHeader(text: GV.language.getText(.tcBest), index: 2)
        var lineNr = 0
        for finishedGame in finishedGames {
            createItem(text: String(finishedGame.gameNumber + 1), index: 0, lineNr: lineNr)
            createItem(text: String(finishedGame.score), index: 1, lineNr: lineNr)
            createItem(text: String(0), index: 2, lineNr: lineNr)
            lineNr += 1
        }
        createOKButton()
    }
    
    private func createHeader(text: String, index: Int) {
        let label = SKLabelNode(fontNamed: "TimesNewRomanPS-BoldMT")// Snell Roundhand")
        let yPosition = self.frame.height * 0.80
        let xPosition = self.frame.size.width * xMultiplierTab[index]
        label.position = CGPoint(x: xPosition, y: yPosition)
        label.fontSize = self.frame.size.height * 0.018
        label.fontSize = UIScreen.main.bounds.height * 0.03
        label.fontColor = SKColor.blue
        label.colorBlendFactor = 0.9
        label.text = text
        label.zPosition = self.zPosition + 1
        label.horizontalAlignmentMode = .center
        label.verticalAlignmentMode = .center
        //        menuItem.name = String(String(score))
        self.addChild(label)
    }
    
    private func createItem(text: String, index: Int, lineNr: Int) {
        let label = SKLabelNode(fontNamed: "TimesNewRomanPS-BoldMT")// Snell Roundhand")
        let yPosition = self.frame.height * (0.75 - CGFloat(lineNr) * 0.04)
        let xPosition = self.frame.size.width * xMultiplierTab[index]
        label.position = CGPoint(x: xPosition, y: yPosition)
        label.fontSize = self.frame.size.height * 0.018
        label.fontSize = UIScreen.main.bounds.height * 0.03
        label.fontColor = SKColor.blue
        label.colorBlendFactor = 0.9
        label.text = text
        label.zPosition = self.zPosition + 1
        label.horizontalAlignmentMode = .center
        label.verticalAlignmentMode = .center
//        menuItem.name = String(String(score))
        self.addChild(label)
    }
    
    func createOKButton() {
        let texture = SKTexture(imageNamed: "button.png")
        let button = SKSpriteNode(texture: texture, color: .white, size: CGSize(width: self.size.width * 0.5, height: self.size.height * 0.2))
        let yPosition = self.frame.size.height * 0.20
        button.size = CGSize(width: self.frame.size.width * 0.4, height: self.frame.size.height * 0.1)
        button.position = CGPoint(x: self.frame.size.width / 2, y: yPosition)
        button.name = OKButtonName
        let label = SKLabelNode(fontNamed: "TimesNewRomanPS-BoldMT")// Snell Roundhand")
        label.fontSize = self.frame.size.height / 30
        label.position = CGPoint(x:0, y: button.frame.height * 0.1)
        label.fontColor = SKColor.blue
        label.colorBlendFactor = 0.9
        label.text = GV.language.getText(.tcOK)
        label.zPosition = self.zPosition + 1
        label.horizontalAlignmentMode = .center
        label.verticalAlignmentMode = .center
        label.name = OKLabelName
        button.addChild(label)
        self.addChild(button)
    }

    public func setDelegate(delegate: ShowFinishedGamesSceneDelegate) {
        myDelegate = delegate
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if myDelegate == nil {
            return
        }
        let firstTouch = touches.first
        let touchLocation = firstTouch!.location(in: self)
        let nodes = self.nodes(at: touchLocation)
        if nodes.count > 0 {
            for node in nodes {
                let name = node.name
                if name != nil {
                    switch name {
                    case OKLabelName:
                        myDelegate!.backToMenuScene()
                    default: break
                    }
                }
            }
        }
    }

}
