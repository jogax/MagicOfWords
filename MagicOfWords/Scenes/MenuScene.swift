//
//  MenuScene.swift
//  MagicOfWords
//
//  Created by Romhanyi Jozsef on 2020. 10. 01..
//  Copyright © 2020. Jozsef Romhanyi. All rights reserved.
//

import Foundation
import Realm
import RealmSwift
import GameKit

public protocol MenuSceneDelegate: class {
    
    /// Method called when Game finished
    func startGameChoosed()
    
}


class MenuScene: SKScene {
    
    let myTitleFont = UIFont(name: GV.actFont, size: GV.onIpad ? 30 : 10)
    let buttonFrameWidth = GV.minSide * 0.5
    let buttonFrameHeight = GV.maxSide * 0.05
    var buttonFrame: CGRect!
    var buttonSize = CGSize(width: CGFloat(0), height: CGFloat(0))
    var myDelegate: MainViewController!
    let linePPosYs: [CGFloat] = [0.8, 0.75, 0.70, 0.65, 0.60, 0.55, 0.50, 0.45, 0.40]
    let lineLPosYs: [CGFloat] = [0.8, 0.70, 0.60, 0.50, 0.40, 0.30, 0.20, 0.10, 0.10]
    
    struct MenuAction {
        var text: String = ""
        var action: Selector!
        
    }
    var title: String!
    var message: String!
    var target: AnyObject!
    var type: AlertType!
    var actions: [MenuAction]!
    var alert: MyAlertController!


    public func setDelegate(_ delegate: MainViewController) {
        myDelegate = delegate
    }
    
    public func setHeader(title: String, message: String, target: AnyObject, type: AlertType) {
        self.title = title
        self.message = message
        self.target = target
        self.type = type
        actions = [MenuAction]()
    }
    
    public func addAction(text: String, action:Selector) {
        actions.append(MenuAction(text: text, action: action))
    }

    override func didMove(to view: SKView) {
        self.size = CGSize(width: GV.actWidth, height: GV.actHeight)
        
        self.name = "MenuScene"
        bgSprite = SKSpriteNode()
        self.addChild(bgSprite!)
        setBackground(to: bgSprite)
        bgSprite!.name = "BGSprite"
        bgSprite!.size = self.frame.size
        alert = MyAlertController(title: title, message: message, target: self, type: type)
        for action in actions {
            alert.addAction(text: action.text, action: action.action)
        }
        alert.presentAlert()
        alert.zPosition = 20
        self.addChild(alert)
    }
    
    
    @objc private func backToStartGame() {
        myDelegate.startGameChoosed()
    }
    
}
