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
    let separator = "°"
    var myLabels = [SKLabelNode]()
    var myBackgrounds = [SKSpriteNode]()
    let myTarget: AnyObject
    var myActions = [Selector]()
    var ownWidth = CGFloat(0)
    var ownHeight = CGFloat(0)
    var myFontSize = CGFloat(0)
    var titleFontSize = CGFloat(0)
    var messageFontSize = CGFloat(0)
    var countHeaderLines = 1
    var myFont = UIFont()
    var titleFont = UIFont()
    var messageFont = UIFont()

    var lastIndex: Int?
    var radiusShape = SKShapeNode()
    let myGrayColor = UIColor(red: 230/255, green: 230/255, blue: 230/255, alpha: 1.0)
    let myGoldColor = UIColor(red: 255/255, green: 215/255, blue: 0/255, alpha: 1.0)
//    let myLightRedColor = UIColor(red: 251/255, green: 235/255, blue: 232/255, alpha: 1.0)
//    let fontName = "HelveticaNeue-Bold"
    let fontName = "AvenirNextCondensed-Regular"
    let titleFontName = "AvenirNextCondensed-Bold"
    init(title: String, message: String, target: AnyObject) {
        myFontSize = GV.onIpad ? 20 : 15
        titleFontSize = myFontSize * 1.1
        messageFontSize = myFontSize * 0.8
        myTarget = target
        ownWidth = 0
        //let fontName = "HiraMaruProN-W4"
        myFont = UIFont(name: fontName, size: myFontSize)!
        titleFont = UIFont(name: titleFontName, size: titleFontSize)!
        messageFont = UIFont(name: fontName, size: messageFontSize)!
        super.init(texture: nil /*SKTexture(imageNamed: "MenuBG")*/, color: .clear, size: CGSize(width: 1, height: 1))

        ownHeight = title.height(font: myFont) * 1.2
        calculatedHeight = title.height(font: myFont)
//        self.color = myGrayColor
        let textArray1 = title.components(separatedBy: separator)
        firstTitleLine = true
        for text in textArray1 {
            let textWidth = text.width(font:titleFont)
            ownWidth = ownWidth > textWidth ? ownWidth : textWidth
            createLabel(text: text, color: .black, title: true, header: true)
//            addChild(label)
            countHeaderLines += 1
            firstTitleLine = false
        }
        let textArray2 = message.components(separatedBy: separator)
        firstMessageLine = true
        for text in textArray2 {
            let textWidth = text.width(font:messageFont)
            ownWidth = ownWidth > textWidth ? ownWidth : textWidth
            createLabel(text: text, color: .black, title: false, header: true)
//            addChild(label)
            countHeaderLines += 1
            firstMessageLine = false
        }
//        self.size = CGSize(width: ownWidth * 0.8, height: ownHeight * CGFloat(2))
        self.zPosition = 1000
    }
    public func addAction(text: String, action:Selector) {
        createLabel(text: text)
        let textWidth = text.width(font: myFont)
        ownWidth = textWidth > ownWidth ? textWidth : ownWidth
        myActions.append(action)
//        label.name = String(myLabels.count - 1)
//        self.addChild(label)
    }
    
    public func presentAlert(target: AnyObject) {
        let multiplier: CGFloat = 1.5
//        let titleMultiplier: CGFloat = 1.9
        self.size = CGSize(width: ownWidth * 1.1, height: calculatedHeight)
        radiusShape = SKShapeNode.init(rect: CGRect.init(origin: CGPoint.zero, size: size), cornerRadius: 15)
        radiusShape.position = CGPoint.zero
        radiusShape.lineWidth = 2.0
        radiusShape.fillColor = myGoldColor
        radiusShape.strokeColor = .black
        radiusShape.zPosition = -2
        radiusShape.position = CGPoint(x:self.frame.minX, y: self.frame.minY)
        self.addChild(radiusShape)

        self.position = CGPoint(x: target.frame.maxX, y: target.frame.midY)
        var actY = self.frame.maxY
        var firstTitleLine = true
        var firstMessageLine = true
        for (index, label) in myLabels.enumerated() {
            var isNormalLine = false
            switch label.name!.lastChar() {
            case titleName:
                actY -= ownHeight * (firstTitleLine ? titleMultipler1 : titleMultipler2)
                firstTitleLine = false
            case messageName:
                actY -= ownHeight * (firstMessageLine ? messageMultiplier1 : messageMultiplier2)
                firstMessageLine = false
            case lineName:
                actY -= ownHeight * lineMultiplier
                isNormalLine = true
            default: break
            }
//            let y = self.frame.maxY - ownHeight * CGFloat(index + 1) * (multiplier + 0.04)
            label.position = CGPoint(x: self.frame.midX, y: actY)
            if index > countHeaderLines - 2 {
                myBackgrounds[index].position = CGPoint(x: self.frame.midX, y: actY)
                myBackgrounds[index].color = .clear
                myBackgrounds[index].size = CGSize(width: self.frame.width, height:ownHeight * multiplier)
            }
            if isNormalLine {
                createLine(atY: actY + ownHeight * 1.5)
            }
            self.addChild(label)
        }
        position = CGPoint(x: target.frame.midX, y: target.frame.midY)
    }
    var calculatedHeight:CGFloat = 0
    let titleMultipler1:CGFloat = 0.9
    let titleMultipler2:CGFloat = 0.7
    let messageMultiplier1:CGFloat = 0.8
    let messageMultiplier2:CGFloat = 0.5
    let lineMultiplier:CGFloat = 1.5
    var firstTitleLine = true
    var firstMessageLine = true
    let titleName = "T"
    let messageName = "M"
    let lineName = "L"
    
    private func createLabel(text: String, color: UIColor = .blue, title: Bool = false, header: Bool = false) {
        let label = SKLabelNode(fontNamed: fontName)
        switch (header, title) {
        case (true, true):
            label.fontSize = titleFontSize
            label.name = titleName
            calculatedHeight += ownHeight * (firstTitleLine ? titleMultipler1 : titleMultipler2)
        case (true, false):
            label.fontSize = myFontSize * 0.8
            label.name = messageName
            calculatedHeight += ownHeight * (firstMessageLine ? messageMultiplier1 : messageMultiplier2)
        case (false, false):
            label.fontSize = myFontSize
            label.name = lineName
            calculatedHeight += ownHeight * lineMultiplier
        default: break
        }
//        label.fontSize = title ? titleFontSize : (header ? myFontSize * 0.8 : myFontSize)
        label.text = text
        label.fontColor = color
//        label.name = String(myBackgrounds.count) + (header ? (title ? titleName : messageName) : lineName)
//        calculatedHeight += ownHeight * (header ? (title ? firstTitleLine : ownHeight * 0.8) : ownHeight * 1.5)
        myLabels.append(label)
        let sprite = SKSpriteNode(texture: nil, color: .clear, size: CGSize(width: 10, height: 10))
        if !header {
            sprite.name = String(myBackgrounds.count)
        }
        myBackgrounds.append(sprite)
        self.addChild(sprite)
//        return label
    }
    
    func createLine(atY: CGFloat) {
        let line = SKShapeNode()
        let pathToDraw = CGMutablePath()
        let toY = atY - ownHeight * 0.5
        pathToDraw.move(to: CGPoint(x: self.frame.minX + 10, y: toY))
        pathToDraw.addLine(to: CGPoint(x: self.frame.maxX - 10, y: toY))
        line.path = pathToDraw
        line.strokeColor = SKColor.lightGray
        line.lineWidth = 0.05
        addChild(line)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touchLocation = touches.first!.location(in: self)
        let nodes = self.nodes(at: touchLocation)
        for node in nodes {
            guard let name = node.name else {
                continue
            }
            let index: Int? = Int(name)
            if index != nil {
                lastIndex = index!
                myBackgrounds[index!].color = myGrayColor
            }
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touchLocation = touches.first!.location(in: self)
        let nodes = self.nodes(at: touchLocation)
        if nodes.count == 0 {
            if lastIndex != nil {
                myBackgrounds[lastIndex!].color = .clear
                lastIndex = nil
            }
        } else {
            for node in nodes {
                guard let name = node.name else {
                    continue
                }
                let index: Int? = Int(name)
                if index != nil {
                    if lastIndex == nil {
                        myBackgrounds[index!].color = myGrayColor
                        lastIndex = index!
                    } else if lastIndex != index {
                       myBackgrounds[lastIndex!].color = .clear
                       myBackgrounds[index!].color = myGrayColor
                       lastIndex = index!
                    }
                } else {
                    if lastIndex != nil {
                        myBackgrounds[lastIndex!].color = .clear
                        lastIndex = nil
                    }
                }
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touchLocation = touches.first!.location(in: self)
        let nodes = self.nodes(at: touchLocation)
        for node in nodes {
            guard let name = node.name else {
                continue
            }
            let index: Int? = Int(name)
            if index == nil {

            } else {
                let action = myActions[index! - countHeaderLines + 1]
                _ = myTarget.perform(action)
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
