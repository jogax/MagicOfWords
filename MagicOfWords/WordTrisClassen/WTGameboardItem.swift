//
//  WordTrisGameboardItem.swift
//  MagicOfWords
//
//  Created by Jozsef Romhanyi on 14/02/2018.
//  Copyright © 2018 Jozsef Romhanyi. All rights reserved.
//

import Foundation
import GameplayKit

enum ItemStatus: Int {
    case empty = 0, temporary, used, wholeWord, fixItem, fixInWord, noChange
    var description: String {
        return String(self.rawValue)
    }
}

enum MyColor: Int {
    case myWhiteColor = 0, myGreenColor, myUsedColor, myFixColor, myGoldColor, myBlueColor, myTemporaryColor, myRedColor, myNoColor, myDarkGoldColor, myDarkGreenColor,
    myLightGreenColor
    var description: String {
    return String(self.rawValue)
//    switch self {
//    case myWhiteColor: return "0"
//    case myWholeWordColor: return "1"
//    case myUsedColor: "2"
//    case myGoldColor: "3"
//    case myBlueColor: "4"
//    case myTemporaryColor: "5"
//    case
//    }
    }
}

let usedColor = SKColor(red:255/255, green: 153/255, blue: 153/255, alpha: 1.0)
let goldColor  = SKColor(red:255/255, green: 215/255, blue: 0/255, alpha: 1.0)
let temporaryColor = SKColor(red: 212/255, green: 249/255, blue: 236/255, alpha: 1.0)
let turquoiseColor = SKColor(red: 64/255, green: 224/255, blue: 208/255, alpha: 1.0)
let darkGoldColor = SKColor(red: 255/255, green: 180/255, blue: 0/255, alpha: 1.0)
let darkGreenColor = SKColor(red: 0/255, green: 186/255, blue: 0/255, alpha: 1.0)
let lightGreenColor = SKColor(red: 127/255, green: 255/255, blue: 0/255, alpha: 1.0)
let fixColor = SKColor.lightGray

let emptyLetter = " "


class WTGameboardItem: SKSpriteNode {
    public var status: ItemStatus = .empty
    public var myColor: MyColor = .myWhiteColor
    private var colorToStatus: [ItemStatus:MyColor] = [
        .empty : .myWhiteColor, .temporary : .myTemporaryColor, .used : .myUsedColor, .fixItem: .myFixColor, .wholeWord : .myGreenColor
    ]
    private var origLetter: String = emptyLetter
    private var origColor: MyColor = .myWhiteColor
    public var doubleUsed = false
    private var blockSize:CGFloat = 0
    private var label: SKLabelNode
    private var countWordsLabel: SKLabelNode
    private var connectionType = ConnectionType()
    private var countOccurencesInWords = 0
    private var fixLetter = false

    public var letter = emptyLetter
    private var fontSize: CGFloat = 0
    init(blockSize: CGFloat, fontSize: CGFloat) {
        label = SKLabelNode()
        // Call the init        
        countWordsLabel = SKLabelNode()
        self.fontSize = fontSize
        let texture = SKTexture(imageNamed: "whiteSprite.png")
        super.init(texture: texture, color: .white, size: CGSize(width: blockSize, height: blockSize))
//        label.fontName = "KohinoorTelugu-Regular"
//        label.fontName = "Baskerville"
//        label.fontName = "ChalkboardSE-Light"
//        label.fontName = "PingFangTC-Semibold"
        label.fontName = GV.actPieceFont //"KohinoorBangla-Regular"
        label.fontColor = .black
        label.verticalAlignmentMode = .center
        label.fontSize = self.fontSize
        label.zPosition = self.zPosition + 1
        addChild(label)

        countWordsLabel.position = CGPoint(x: blockSize * 0.28, y: -blockSize * 0.35)
        countWordsLabel.fontName = GV.actPieceFont //"KohinoorBangla-Regular"
        countWordsLabel.fontColor = .black
//        countWordsLabel.verticalAlignmentMode = .center
        countWordsLabel.fontSize = fontSize * 0.7
//        countWordsLabel.text = String(countOccurencesInWords)
        countWordsLabel.zPosition = self.zPosition + 2
        addChild(countWordsLabel)
    }
    
    public func copyMe(imageNamed: String)->WTGameboardItem {
        let copyed = WTGameboardItem(blockSize: self.size.height, fontSize: self.fontSize)
        copyed.texture = SKTexture(imageNamed: imageNamed)
        copyed.position = self.position
        copyed.status = self.status
        copyed.myColor = self.myColor
        copyed.origLetter = self.origLetter
        copyed.origColor = self.origColor
        copyed.blockSize = self.blockSize
        copyed.letter = self.letter
        copyed.label = self.label.copyMe()
        copyed.label.zPosition = self.zPosition + 1
        copyed.addChild(copyed.label)
        copyed.countWordsLabel = self.countWordsLabel.copyMe()
        copyed.addChild(copyed.countWordsLabel)
        copyed.countWordsLabel.zPosition = self.zPosition + 1
        return copyed
    }
    
    public func setLetter(letter: String, status: ItemStatus)->Bool {
        
        switch self.status {
            default: break
        }
        
        if self.status == .used || self.status == .wholeWord || (self.status == .fixItem && status == .temporary){
            self.origColor = self.myColor
            setColors(toColor: .myRedColor, toStatus: .noChange)
            self.origLetter = label.text!
            label.text = letter
            self.letter = letter
            doubleUsed = true
            return false
        } else {
            self.fixLetter = status == .fixItem ? true : false
            self.colorBlendFactor = 1
            label.text = letter
            self.letter = letter
//            self.status = status
            setColors(toStatus: status)
            return true
        }
    }
    
    public func resetCountOccurencesInWords() {
        countOccurencesInWords = 0
    }
    
    public func getColor()->MyColor {
        return myColor
    }
    
    public func getCountOccurencesInWords()->Int {
        return countOccurencesInWords
    }
    public func setColorByState() {
        switch status {
        case .used:
            setColors(toColor: .myUsedColor, toStatus: .noChange)
        case .wholeWord:
            setColors(toColor: .myGreenColor, toStatus: .noChange)
        case .fixItem:
            setColors(toColor: .myFixColor, toStatus: .noChange)
        default:
            break
        }
    }
    
    public func clearIfTemporary() {
        label.removeShadow()
        if status == .temporary {
            label.text = emptyLetter
            self.letter = emptyLetter
            setColors(toColor: .myWhiteColor, toStatus: .empty)
        } else if (status == .used || status == .wholeWord || status == .fixItem) && doubleUsed {
            label.text = self.origLetter
            self.letter = self.origLetter
            setColors(toColor: self.origColor, toStatus: .noChange)
//            self.color = convertMyColorToSKColor(color: self.origColor)
        } else if letter != emptyLetter && (myColor == .myBlueColor || myColor == .myGoldColor || myColor == .myDarkGoldColor) {
            setColors(toColor: .myUsedColor, toStatus: .used)
        } 
        self.doubleUsed = false
    }
    
    public func fixIfTemporary()->Bool {
        if status == .temporary {
//            self.status = .used
            setColors(toColor: .myUsedColor, toStatus: .used)
            return true
        } else if (status == .used || status == .wholeWord) && doubleUsed {
            label.text = self.origLetter
            setColors(toColor: self.origColor, toStatus: .noChange)
//            self.color = convertMyColorToSKColor(color: self.origColor)
            doubleUsed = false
            return false
        }
        return true
    }
    
    public func clearIfUsed() {
        if status == .wholeWord {
            label.text = emptyLetter
            self.letter = emptyLetter
            setColors(toColor: .myWhiteColor, toStatus: .empty)
            clearConnectionType()
        }
    }
    
    public func correctStatusIfNeeded() {
        if status == .wholeWord && letter == emptyLetter {
            status = .empty
        }
    }
    public func remove() {
//        self.status = .empty
        label.text = emptyLetter
        self.letter = emptyLetter
        setColors(toColor: .myWhiteColor, toStatus: .empty)
    }
    
    private func convertMyColorToSKColor(color: MyColor)->SKColor {
        if GV.buttonType == GV.ButtonTypeElite {
            switch color {
            case .myRedColor: return .white
            case .myWhiteColor: return .white
            case .myGreenColor: return .white
            case .myUsedColor: return .white
            case .myGoldColor: return .white //goldColor
            case .myBlueColor: return .white //turquoiseColor
            case .myFixColor: return .white
            case .myTemporaryColor: return temporaryColor
            case .myDarkGoldColor: return darkGoldColor
            case .myDarkGreenColor: return darkGreenColor
            case .myLightGreenColor: return lightGreenColor
            case .myNoColor: return .white
            }
        } else {
            switch color {
            case .myRedColor: return .red
            case .myWhiteColor: return .white
            case .myGreenColor: return .green
            case .myUsedColor: return usedColor
            case .myGoldColor: return goldColor
            case .myBlueColor: return turquoiseColor
            case .myFixColor: return fixColor
            case .myTemporaryColor: return temporaryColor
            case .myDarkGoldColor: return darkGoldColor
            case .myDarkGreenColor: return darkGreenColor
            case .myLightGreenColor: return lightGreenColor
            case .myNoColor: return .white
            }
        }
    }
    
    public func clearConnectionType() {
        self.connectionType = ConnectionType()
        setTexture()
    }
    
    public func setConnectionType(connectionType: ConnectionType) {
        if connectionType.left {
            self.connectionType.left = true
        }
        if connectionType.top {
            self.connectionType.top = true
        }
        if connectionType.right {
            self.connectionType.right = true
        }
        if connectionType.bottom {
            self.connectionType.bottom = true
        }
        setTexture()
    }
    
    public func setColors(toColor: MyColor = .myWhiteColor, toStatus: ItemStatus, connectionType: ConnectionType = ConnectionType(), incrWords: Bool = false, decrWords: Bool = false) {
        var color: MyColor
        if self.status == .wholeWord && self.fixLetter && toColor == .myUsedColor {
            color = .myFixColor
        } else {
            color = letter == emptyLetter ? .myWhiteColor : toColor
        }
        self.myColor = color
        self.color = convertMyColorToSKColor(color: color)
        switch toStatus {
        case .used:
            self.status = self.fixLetter ? .fixItem : toStatus
        case .wholeWord:
            self.status = self.fixLetter ? .fixInWord : toStatus
        default:
            self.status = toStatus == .noChange ? self.status : toStatus
        }
//        if toStatus == .used {
//            self.status = self.fixLetter ? .fixItem : toStatus
//        } else {
//            self.status = toStatus == .noChange ? self.status : toStatus
//        }
        self.status = letter == emptyLetter ? .empty : self.status
        self.countOccurencesInWords += incrWords ? 1 : 0
        if self.countOccurencesInWords > 0 && decrWords {
            self.countOccurencesInWords -= 1
        }
        
        if toColor == .myGreenColor || (GV.buttonType == GV.ButtonTypeElite && (toColor == .myGoldColor || toColor == .myDarkGoldColor)) {
            if countOccurencesInWords > 0 {
                self.countWordsLabel.text = String(countOccurencesInWords)
                self.countWordsLabel.fontSize = self.fontSize * (countOccurencesInWords < 10 ? 0.7 : 0.6)
            }
        } else {
            self.countWordsLabel.text = ""
        }
        setConnectionType(connectionType: connectionType)
    }
    
    private func setTexture() {
        var name = ""
        var connectionName = "Connection"
        connectionName += self.connectionType.left ? "1" : "0"
        connectionName += self.connectionType.top ? "1" : "0"
        connectionName += self.connectionType.right ? "1" : "0"
        connectionName += self.connectionType.bottom ? "1" : "0"
        switch status {
        case .wholeWord:
            name = "GreenSprite"
        case .fixInWord:
            name = "GreenLilaSprite"
        case .temporary:
            name = "LightBlueSprite"
        case .noChange:
            name = "RedSprite"
        case .used:
            name = "LightRedSprite"
        case .fixItem:
            name = "LilaSprite"
        default:
            name = "whiteSprite"
        }
        self.texture = SKTexture(imageNamed: name)
        if connectionName != "Connection" {
            let child = self.childNode(withName: "Connection")
            if child == nil {
                let child = SKSpriteNode(imageNamed: connectionName)
                child.size = self.size
                child.zPosition = self.zPosition - 1
                child.name = "Connection"
                self.addChild(child)
            } else {
                (child! as! SKSpriteNode).texture = SKTexture(imageNamed: connectionName)
            }
        } else {
            let child = self.childNode(withName: "Connection")
            if child != nil {
                child!.removeFromParent()
            }

        }
    }
    public func changeColor(toColor: MyColor = .myNoColor) {
        if toColor == .myNoColor {
            setColors(toColor: self.origColor, toStatus: .noChange)
        } else {
            if !(myColor == toColor) {
                origColor = myColor
                setColors(toColor: toColor, toStatus: .noChange)
            }
        }
    }
    
    public func toString()->String {
        return status.description + letter
    }
    
    public func restore(from: String) {
//        var color: MyColor = .myWhiteColor
        var status: ItemStatus = .empty
        var letter = emptyLetter
        remove()
        if let rawStatus = Int(from.subString(at: 0, length: 1)) {
            if let itemStatus = ItemStatus(rawValue: rawStatus) {
                status = itemStatus
//                if let toColor = colorToStatus[status] {
//                    color = toColor
//                }
            }
        }
        letter = from.subString(at: 1, length: 1)
//        if letter == emptyLetter {
//            color = .myWhiteColor
//        }
        _ = setLetter(letter: letter, status: status)
        origLetter = emptyLetter
        origColor = .myWhiteColor
        doubleUsed = false
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
