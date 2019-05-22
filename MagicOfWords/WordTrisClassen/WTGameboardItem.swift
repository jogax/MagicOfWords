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
    case Empty = 0, Temporary, Used, WholeWord, FixItem, Error, DarkGreenStatus, GoldStatus, DarkGoldStatus, NoChange
    var description: String {
        return String(self.rawValue)
    }
}

//enum MyColor: Int {
//    case myWhiteColor = 0, myGreenColor, myUsedColor, myFixColor, myGoldColor, myBlueColor, myTemporaryColor, myRedColor, myNoColor, myDarkGoldColor, myDarkGreenColor,
//    myLightGreenColor
//    var description: String {
//    return String(self.rawValue)
////    switch self {
////    case myWhiteColor: return "0"
////    case myWholeWordColor: return "1"
////    case myUsedColor: "2"
////    case myGoldColor: "3"
////    case myBlueColor: "4"
////    case myTemporaryColor: "5"
////    case
////    }
//    }
//}
//
//let usedColor = SKColor(red:255/255, green: 153/255, blue: 153/255, alpha: 1.0)
//let goldColor  = SKColor(red:255/255, green: 215/255, blue: 0/255, alpha: 1.0)
//let temporaryColor = SKColor(red: 212/255, green: 249/255, blue: 236/255, alpha: 1.0)
//let turquoiseColor = SKColor(red: 64/255, green: 224/255, blue: 208/255, alpha: 1.0)
//let darkGoldColor = SKColor(red: 255/255, green: 180/255, blue: 0/255, alpha: 1.0)
//let darkGreenColor = SKColor(red: 0/255, green: 186/255, blue: 0/255, alpha: 1.0)
//let lightGreenColor = SKColor(red: 127/255, green: 255/255, blue: 0/255, alpha: 1.0)
//let fixColor = SKColor.lightGray

let emptyLetter = " "
let noChange = ""


class WTGameboardItem: SKSpriteNode {
    public var status: ItemStatus = .Empty
//    public var myColor: MyColor = .myWhiteColor
//    private var colorToStatus: [ItemStatus:MyColor] = [
//        .empty : .myWhiteColor, .temporary : .myTemporaryColor, .used : .myUsedColor, .fixItem: .myFixColor, .wholeWord : .myGreenColor
//    ]
    private var origLetter: String = emptyLetter
    private var origStatus: ItemStatus = .Empty
    public var doubleUsed = false
    private var blockSize:CGFloat = 0
    private var label: SKLabelNode
    private var countWordsLabel: SKLabelNode
    private var connectionType = ConnectionType()
    private var countOccurencesInWords = 0
    private var fixItem = false

    public var letter = emptyLetter
    private var fontSize: CGFloat = 0
    init(blockSize: CGFloat, fontSize: CGFloat) {
        label = SKLabelNode()
        // Call the init        
        countWordsLabel = SKLabelNode()
        self.fontSize = fontSize
        let texture = SKTexture(imageNamed: "WhiteSprite.png")
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
//        copyed.myColor = self.myColor
        copyed.origLetter = self.origLetter
        copyed.origStatus = self.origStatus
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
    public func setLetter(letter: String, toStatus: ItemStatus, calledFrom: String, col: Int, row: Int)->Bool {
        
        print("In SetLetter: caller: \(calledFrom), oldLetter: \(self.letter), letter: \(letter), fromStatus: \(status), toStatus: \(toStatus), col: \(col), row: \(row)")
        if self.status == .Used || self.status == .WholeWord || self.status == .FixItem {
            self.origStatus = self.status
            setStatus(toStatus: .Error, calledFrom: "setLetter - 1", col: col, row: row)
            self.origLetter = label.text!
            label.text = letter
            self.letter = letter
            doubleUsed = true
            return false
        } else {
            self.colorBlendFactor = 1
            if letter != noChange {
                label.text = letter
                self.letter = letter
            }
            if toStatus == .FixItem {
                fixItem = true
                setStatus(toStatus: .FixItem, calledFrom: "setLetter - 2", col: col, row: row)
            } else {
                setStatus(toStatus: toStatus, calledFrom: "setLetter - 3", col: col, row: row)
            }
            return true
        }
    }
    
    public func resetCountOccurencesInWords() {
        countOccurencesInWords = 0
    }
    
//    public func getColor()->MyColor {
//        return myColor
//    }
//
    public func getCountOccurencesInWords()->Int {
        return countOccurencesInWords
    }
//    public func setColorByState() {
//        switch status {
//        case .used:
//            setStatus(toColor: .myUsedColor, toStatus: .noChange)
//        case .wholeWord:
//            setColors(toColor: .myGreenColor, toStatus: .noChange)
//        case .fixItem:
//            setColors(toColor: .myFixColor, toStatus: .noChange)
//        default:
//            break
//        }
//    }
    
    public func clearIfTemporary(col: Int, row: Int) {
        label.removeShadow()
        switch (status, fixItem) {
        case (.Temporary, false):
            label.text = emptyLetter
            self.letter = emptyLetter
            setStatus(toStatus: .Empty, calledFrom: "clearIfTemporary - 1", col: col, row: row)
        case (.Temporary, true):
            if doubleUsed {
                label.text = self.origLetter
                self.letter = self.origLetter
                setStatus(toStatus: self.origStatus, calledFrom: "clearIfTemporary - 2", col:col, row: row)
            }
        case (.Used, _):
            if doubleUsed {
                label.text = self.origLetter
                self.letter = self.origLetter
                setStatus(toStatus: self.origStatus, calledFrom: "clearIfTemporary - 2", col:col, row: row)
            }
        case (.WholeWord, _):
            if doubleUsed {
                label.text = self.origLetter
                self.letter = self.origLetter
                setStatus(toStatus: self.origStatus, calledFrom: "clearIfTemporary - 2", col:col, row: row)
            }
        case (.Error, _):
            if doubleUsed {
                label.text = self.origLetter
                self.letter = self.origLetter
                setStatus(toStatus: self.origStatus, calledFrom: "clearIfTemporary - 2", col:col, row: row)
            }
        case (.GoldStatus, _):
            setStatus(toStatus: .Used, calledFrom: "clearIfTemporary - 3", col:col, row: row)
        case (.DarkGoldStatus, _):
            setStatus(toStatus: .Used, calledFrom: "clearIfTemporary - 3", col:col, row: row)
        default:
            break
        }
//        if status == .Temporary {
//        } else if (status == .Used || status == .WholeWord || status == .FixItem || status == .Error) && doubleUsed {
////            self.color = convertMyColorToSKColor(color: self.origColor)
//        } else if letter != emptyLetter && (status == .Temporary || status == .GoldStatus || status == .DarkGoldStatus) {
//            setStatus(toStatus: .Used, calledFrom: "clearIfTemporary - 3", col:col, row: row)
//        }
        self.doubleUsed = false
    }
    
    public func fixIfTemporary()->Bool {
        if status == .Temporary {
//            self.status = .used
            setStatus(toStatus: .Used, calledFrom: "fixIfTemporary - 1", col:0, row: 0)
            return true
        } else if (status == .Used || status == .WholeWord) && doubleUsed {
            label.text = self.origLetter
            setStatus(toStatus: self.origStatus, calledFrom: "fixIfTemporary - 2", col:0, row: 0)
//            self.color = convertMyColorToSKColor(color: self.origColor)
            doubleUsed = false
            return false
        } else if status == .Error {
            label.text = origLetter
            setStatus(toStatus: self.origStatus, calledFrom: "fixIfTemporary - 3", col:0, row: 0)
            return false
        }
        return true
    }
    
    public func clearIfUsed() {
        if status == .WholeWord {
            label.text = emptyLetter
            self.letter = emptyLetter
            setStatus(toStatus: .Empty, calledFrom: "clearIfUsed", col:0, row: 0)
            clearConnectionType()
        }
    }
    
    public func correctStatusIfNeeded() {
        if status == .WholeWord && letter == emptyLetter {
            status = .Empty
        }
    }
    public func remove() {
//        self.status = .empty
        label.text = emptyLetter
        self.letter = emptyLetter
        setStatus(toStatus: .Empty, calledFrom: "remove", col:0, row: 0)
    }
    
//    private func convertMyColorToSKColor(color: MyColor)->SKColor {
//        if GV.buttonType == GV.ButtonTypeElite {
//            switch color {
//            case .myRedColor: return .white
//            case .myWhiteColor: return .white
//            case .myGreenColor: return .white
//            case .myUsedColor: return .white
//            case .myGoldColor: return .white //goldColor
//            case .myBlueColor: return .white //turquoiseColor
//            case .myFixColor: return .white
//            case .myTemporaryColor: return temporaryColor
//            case .myDarkGoldColor: return darkGoldColor
//            case .myDarkGreenColor: return darkGreenColor
//            case .myLightGreenColor: return lightGreenColor
//            default: return .white
//            }
//        } else {
//            switch color {
//            case .myRedColor: return .red
//            case .myWhiteColor: return .white
//            case .myGreenColor: return .green
//            case .myUsedColor: return usedColor
//            case .myGoldColor: return goldColor
//            case .myBlueColor: return turquoiseColor
//            case .myFixColor: return fixColor
//            case .myTemporaryColor: return temporaryColor
//            case .myDarkGoldColor: return darkGoldColor
//            case .myDarkGreenColor: return darkGreenColor
//            case .myLightGreenColor: return lightGreenColor
//            case .myNoColor: return .white
//            }
//        }
//    }
    
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
    
    public func setStatus(/*toColor: MyColor = .myWhiteColor,*/ toStatus: ItemStatus, connectionType: ConnectionType = ConnectionType(), incrWords: Bool = false, decrWords: Bool = false, calledFrom: String, col: Int, row: Int) {
//        if self.status == .FixInWord && toStatus == .Used {
//            color = .myFixColor
//        } else {
//            color = letter == emptyLetter ? .myWhiteColor : toColor
//        }
//        self.myColor = color
//        self.color = convertMyColorToSKColor(color: color)
        let oldStatus = status
        switch (status, toStatus) {
        case (.Used, .Temporary):
            origStatus = status
            origLetter = letter
            status = .Temporary
        case (.FixItem, .Temporary):
            origStatus = status
            origLetter = letter
            status = .Temporary
        case (.Temporary, .NoChange):
            status = origStatus
            letter = origLetter
            label.text = letter
        default:
            self.status = toStatus
        }
//        if toStatus == .used {
//            self.status = self.fixLetter ? .fixItem : toStatus
//        } else {
//            self.status = toStatus == .noChange ? self.status : toStatus
//        }
        self.status = letter == emptyLetter ? .Empty : self.status
        self.countOccurencesInWords += incrWords ? 1 : 0
        if self.countOccurencesInWords > 0 && decrWords {
            self.countOccurencesInWords -= 1
        }
        
        if toStatus == .WholeWord || toStatus == .GoldStatus || toStatus == .DarkGoldStatus {
            if countOccurencesInWords > 0 {
                self.countWordsLabel.text = String(countOccurencesInWords)
                self.countWordsLabel.fontSize = self.fontSize * (countOccurencesInWords < 10 ? 0.7 : 0.6)
            }
        } else {
            self.countWordsLabel.text = ""
        }
        if lastCol != col || lastRow != row {
            print("In SetStatus: caller: \(calledFrom), letter: \(letter), oldStatus: \(oldStatus), status: \(toStatus), newStatus: \(status), col: \(col), row: \(row)")
            lastCol = col
            lastRow = row
        }
        setConnectionType(connectionType: connectionType)
    }
    
    var lastCol = 0
    var lastRow = 0
    
    private func setTexture() {
        var name = ""
        var connectionName = "Connection"
        connectionName += self.connectionType.left ? "1" : "0"
        connectionName += self.connectionType.top ? "1" : "0"
        connectionName += self.connectionType.right ? "1" : "0"
        connectionName += self.connectionType.bottom ? "1" : "0"
        switch (status, fixItem) {
        case (.WholeWord, false):
            name = "GreenSprite"
        case (.WholeWord, true):
            name = "GreenLilaSprite"
        case (.Temporary, _):
            name = "LightBlueSprite"
        case (.Used, false):
            name = "LightRedSprite"
        case (.Used, true):
            name = "LilaSprite"
        case (.FixItem, true):
            name = "LilaSprite"
        case (.Error, _):
            name = "RedSprite"
        case (.GoldStatus, _):
            name = "GoldSprite"
        case (.DarkGoldStatus, _):
            name = "GoldSprite"//"DarkGoldSprite"
        case (.DarkGreenStatus, _):
            name = "DarkGreenSprite"
        default:
            name = "WhiteSprite"
        }
        self.texture = SKTexture(imageNamed: name)
        let child = self.childNode(withName: "Connection")
        if connectionName != "Connection" {
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
            if child != nil {
                child!.removeFromParent()
            }

        }
    }
//    public func changeStatus(toStatus: ItemStatus = .NoChange) {
//        setStatus(toStatus: .noChange)
//    }
    
    public func toString()->String {
        return status.description + letter
    }
    
    public func restore(from: String) {
//        var color: MyColor = .myWhiteColor
        var status: ItemStatus = .Empty
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
        _ = setLetter(letter: letter, toStatus: status, calledFrom: "restore", col:0, row: 0)
        origLetter = emptyLetter
        origStatus = .Empty
        doubleUsed = false
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
