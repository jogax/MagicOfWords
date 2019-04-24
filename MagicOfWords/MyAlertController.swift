//
//  MyAlertController.swift
//  MagicOfWords
//
//  Created by Jozsef Romhanyi on 04/04/2019.
//  Copyright © 2019 Jozsef Romhanyi. All rights reserved.
//

import Foundation
import SpriteKit

class MyAlertController: SKSpriteNode {
    var myLabels = [SKLabelNode]()
    var myTargets = [AnyObject]()
    var myActions = [Selector]()
    var ownWidth = CGFloat(0)
    var ownHeight = CGFloat(0)
    var myFont = UIFont()
    var countLines = 0
    init(mainText: String, message: String) {
        myFont = UIFont(name: GV.actLabelFont, size: GV.onIpad ? 18 : 15)!
        super.init(texture: SKTexture(), color: UIColor.blue, size: CGSize(width: 0, height: 0))
        let label1 = createLabel(text: mainText)
        self.addChild(label1)
        let label2 = createLabel(text: message)
        self.addChild(label2)
        ownWidth = mainText.width(font:myFont)
        ownWidth = message.width(font: myFont) > ownWidth ? message.width(font: myFont) : ownWidth
        ownHeight = mainText.height(font: myFont)
        self.size = CGSize(width: ownWidth, height: ownHeight * CGFloat(2))
    }
    public func addAction(text: String, target: AnyObject, action:Selector) {
        let label = createLabel(text: text)
        ownWidth = text.width(font: myFont) > ownWidth ? text.width(font: myFont) : ownWidth
        myTargets.append(target)
        myActions.append(action)
        label.name = String(myLabels.count - 1)
        self.addChild(label)
    }
    
    public func presentAlert(target: AnyObject) {
        for (index, label) in myLabels.enumerated() {
            label.fontColor = .black
            label.position = CGPoint(x: self.frame.midX, y: self.frame.maxY - ownHeight * CGFloat(index + 1))
        }
        target.addChild(self)
        self.size = CGSize(width: ownWidth, height: ownHeight * CGFloat(myLabels.count + 1))
        self.position = CGPoint(x: target.frame.midX, y: target.frame.minY)
    }
    private func createLabel(text: String, fontSize: CGFloat = 10)->SKLabelNode {
        let label = SKLabelNode(fontNamed: GV.actLabelFont)
        label.fontSize = fontSize
        label.text = text
        myLabels.append(label)
        return label
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
