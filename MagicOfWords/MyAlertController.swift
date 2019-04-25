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
    var myFontSize = CGFloat(0)
    var countHeaderLines = 1
    var myFont = UIFont()
    init(mainText: String, message: String) {
        myFontSize = GV.onIpad ? 20 : 15
        //let fontName = "HiraMaruProN-W4"
        let fontName = "HelveticaNeue-Bold"
        myFont = UIFont(name: fontName, size: myFontSize)!
        super.init(texture: SKTexture(imageNamed: "MenuBG"), color: UIColor.blue, size: CGSize(width: 100, height: 100))
        self.color = .blue
        let label1 = createLabel(text: mainText, color: .black, fontSizeMpx: 1.3)
        self.addChild(label1)
        countHeaderLines += 1
        let label2 = createLabel(text: message, color: .black, fontSizeMpx: 0.8)
        self.addChild(label2)
        countHeaderLines += 1
        let mainFont = UIFont(name: fontName, size: myFontSize * 1.3)!
        ownWidth = mainText.width(font:mainFont) * 0.8
        let messageWidth = message.width(font: myFont)
        ownWidth = messageWidth > ownWidth ? messageWidth : ownWidth
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
        self.size = CGSize(width: ownWidth, height: ownHeight * CGFloat(myLabels.count + countHeaderLines))
        self.position = CGPoint(x: target.frame.maxX, y: target.frame.midY)
        for (index, label) in myLabels.enumerated() {
            let y = self.frame.maxY - ownHeight * CGFloat(index + 1) * 1.5//* (index > 0 ? 1.5 : 1)
            label.position = CGPoint(x: self.frame.midX, y: y)
            if index > 0 && index < myLabels.count - 1 {
                createLine(atY: y)
            }
        }

    }
    private func createLabel(text: String, color: UIColor = .blue, fontSizeMpx: CGFloat = 1)->SKLabelNode {
        let label = SKLabelNode(fontNamed: GV.actLabelFont)
        label.fontSize = myFontSize * fontSizeMpx
        label.text = text
        label.fontColor = color
        myLabels.append(label)
        return label
    }
    
    func createLine(atY: CGFloat) {
        let line = SKShapeNode()
        let pathToDraw = CGMutablePath()
        let toY = atY - ownHeight * 0.5
        pathToDraw.move(to: CGPoint(x: self.frame.minX + 10, y: toY))
        pathToDraw.addLine(to: CGPoint(x: self.frame.maxX - 10, y: toY))
        line.path = pathToDraw
        line.strokeColor = SKColor.darkGray
        line.lineWidth = 0.05
        addChild(line)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touchLocation = touches.first!.location(in: self)
        let nodes = self.nodes(at: touchLocation)
        for node in nodes {
            guard let name = node.name else {
                continue
            }
            let index: Int? = Int(name)
            if index != nil {
                let target = myTargets[index! - countHeaderLines + 1]
                let action = myActions[index! - countHeaderLines + 1]
                _ = target.perform(action)
                self.removeFromParent()
            }
        }
    }
    
    override var isUserInteractionEnabled: Bool {
        set {
            // ignore
        }
        get {
            return true
        }
    }

    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
