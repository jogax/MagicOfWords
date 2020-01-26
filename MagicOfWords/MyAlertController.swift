//
//  MyAlertController.swift
//  MagicOfWords
//
//  Created by Jozsef Romhanyi on 04/04/2019.
//  Copyright © 2019 Jozsef Romhanyi. All rights reserved.
//

import Foundation
import SpriteKit

enum AlertType: Int {
    case Gold = 0, Red, Green, White
}
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
    var myTexts = [String]()
    let myTitle: String
    let myMessage: String
    var myColor: UIColor

    var lastIndex: Int?
    var radiusShape = SKShapeNode()
    let myGrayColor = UIColor(red: 230/255, green: 230/255, blue: 230/255, alpha: 1.0)
    let myGoldColor = UIColor(red: 255/255, green: 215/255, blue: 0/255, alpha: 1.0)
    let myRedColor = UIColor(red: 250/255, green: 180/255, blue: 190/255, alpha: 1.0)
    let myGreenColor = UIColor(red: 180/255, green: 250/255, blue: 190/255, alpha: 1.0)
    let myWhiteColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1.0)
//    let fontName = "AvenirNextCondensed-Regular"
//    let titleFontName = "AvenirNextCondensed-Bold"
    let titleFontName = "HelveticaNeue-Bold"
    let fontName = "HelveticaNeue-Medium"
    
    init(title: String, message: String, target: AnyObject, type: AlertType) {
        myTitle = title
        myMessage = message
        myTarget = target
        switch type {
        case .Gold: myColor = myGoldColor
        case .Red: myColor = myRedColor
        case .Green: myColor = myGreenColor
        case .White: myColor = myWhiteColor
        }
        
        super.init(texture: nil /*SKTexture(imageNamed: "MenuBG")*/, color: .clear, size: CGSize(width: 1, height: 1))
    }
    public func addAction(text: String, action:Selector) {
        myTexts.append(text)
//        createLabel(text: text)
//        let textWidth = text.width(font: myFont)
//        ownWidth = textWidth > ownWidth ? textWidth : ownWidth
        myActions.append(action)
//        label.name = String(myLabels.count - 1)
//        self.addChild(label)
    }
    
    public func getPositionForAction(action: Selector)->CGPoint {
        for (index, selector) in myActions.enumerated() {
            if action == selector {
                return self.position + myBackgrounds[countHeaderLines - 1 + index].position
            }
        }
        return self.position
    }
    
    public func presentAlert() {
        generateLabels()
        let multiplier: CGFloat = 1.5

        self.size = CGSize(width: ownWidth * 1.1, height: calculatedHeight)
        radiusShape = SKShapeNode.init(rect: CGRect.init(origin: CGPoint.zero, size: size), cornerRadius: 15)
        radiusShape.position = CGPoint.zero
        radiusShape.lineWidth = 2.0
        radiusShape.fillColor = myColor
        radiusShape.strokeColor = .black
        radiusShape.zPosition = -2
        radiusShape.position = CGPoint(x:self.frame.minX, y: self.frame.minY)
        self.addChild(radiusShape)


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
                myBackgrounds[index].position = CGPoint(x: self.frame.midX, y: actY + (GV.onIpad ? 10 : 8))
                myBackgrounds[index].color = .clear
                myBackgrounds[index].size = CGSize(width: self.frame.width, height:ownHeight * multiplier)
            }
            if isNormalLine {
                createLine(atY: actY + ownHeight * 1.5)
            }
            self.addChild(label)
        }
        position = CGPoint(x: myTarget.frame.midX, y: myTarget.frame.midY)
        self.zPosition = 50
   }
    
    private func generateLabels() {
        myFontSize = GV.onIpad ? 20 : 15
        titleFontSize = myFontSize * 1.1
        messageFontSize = myFontSize * 0.8
        ownWidth = 0
        myFont = UIFont(name: fontName, size: myFontSize)!
        titleFont = UIFont(name: titleFontName, size: titleFontSize)!
        messageFont = UIFont(name: fontName, size: messageFontSize)!
        let titleLines = createFragments(text: myTitle, font:titleFont)
        let messageLines = createFragments(text: myMessage, font: messageFont)
        ownHeight = myTitle.height(font: titleFont) * 1.2
        calculatedHeight = myTitle.height(font: myFont) * 0.8
        firstTitleLine = true
        for text in titleLines {
            let textWidth = text.width(font:titleFont)
            ownWidth = ownWidth > textWidth ? ownWidth : textWidth
            createLabel(text: text, color: .black, title: true, header: true)
            countHeaderLines += 1
            firstTitleLine = false
        }
        firstMessageLine = true
        for text in messageLines {
            let textWidth = text.width(font:messageFont)
            ownWidth = ownWidth > textWidth ? ownWidth : textWidth
            createLabel(text: text, color: .black, title: false, header: true)
            countHeaderLines += 1
            firstMessageLine = false
        }
        for text in myTexts {
            createLabel(text: text)
            let textWidth = text.width(font: myFont)
            ownWidth = textWidth > ownWidth ? textWidth : ownWidth
        }
    }
    
    private func createFragments(text: String, font: UIFont)->[String] {
        var returnArray = [String]()
        let fragments = text.components(separatedBy: " ")
        let maxLength = myTarget.frame.width * (GV.onIpad ? 0.3 : 0.6)
        var newFragment = ""
        for fragment in fragments {
            let adderWidth = fragment.width(font: font)
            let newFragmentWidth = newFragment.width(font: font)
            if newFragmentWidth + adderWidth < maxLength {
                newFragment += fragment + " "
            } else {
                if newFragment.count > 0 {
                    newFragment.removeLast()
                }
                returnArray.append(newFragment)
                newFragment = fragment + " "
            }
        }
        newFragment.removeLast()
        returnArray.append(newFragment)
        return returnArray
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
        myTouchesBegan(touchLocation: touchLocation)
    }
    
    public func myTouchesBegan(touchLocation: CGPoint, absolutLocation: Bool = false) {
        let myLocation = absolutLocation ? touchLocation - self.position : touchLocation
        let nodes = self.nodes(at: myLocation)
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
        myTouchesEnded(touchLocation: touchLocation)
    }
    
    public func myTouchesEnded(touchLocation: CGPoint, absolutLocation: Bool = false) {
        let myLocation = absolutLocation ? touchLocation - self.position: touchLocation
        let nodes = self.nodes(at: myLocation)
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
                break
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
