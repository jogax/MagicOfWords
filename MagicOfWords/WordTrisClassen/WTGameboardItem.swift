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
    case Empty = 0, Temporary, Used, WholeWord, FixUsed, FixWholeWord, FixItem, Error, DarkGreenStatus, GoldStatus, DarkGoldStatus, OrigStatus
    var description: String {
        return String(self.rawValue)
    }
}

let emptyLetter = " "
let noChange = ""


class WTGameboardItem: SKSpriteNode {
    public var status: ItemStatus = .Empty
    private var origLetter: String = emptyLetter
    private var origStatus: ItemStatus = .Empty
    public var doubleUsed = false
    private var blockSize:CGFloat = 0
    private var label: SKLabelNode
    private var countWordsLabel: SKLabelNode
    private var connectionType = ConnectionType()
    private var countOccurencesInWords = 0
    public var fixItem = false
    public var inFreeArray = -1
    struct StatusType: Hashable {
        var itemStatus: ItemStatus = .Empty
        var fixItem: Bool = false
    }
    private var textureName: [StatusType : String] =
        [StatusType(itemStatus: .Empty, fixItem: false) : "whiteSprite",
         StatusType(itemStatus: .Empty, fixItem: true) : "whiteSprite",
         StatusType(itemStatus: .Temporary, fixItem: false) : "LightBlueSprite",
         StatusType(itemStatus: .Temporary, fixItem: true) : "LightBlueSprite",
         StatusType(itemStatus: .Used, fixItem: false) : "LightRedSprite",
         StatusType(itemStatus: .Used, fixItem: true) : "LilaSprite",
         StatusType(itemStatus: .WholeWord, fixItem: false) : "GreenSprite",
         StatusType(itemStatus: .WholeWord, fixItem: true) : "GreenLilaSprite",
         StatusType(itemStatus: .Error, fixItem: false) : "RedSprite",
         StatusType(itemStatus: .Error, fixItem: true) : "RedSprite",
         StatusType(itemStatus: .DarkGreenStatus, fixItem: false) : "DarkGreenSprite",
         StatusType(itemStatus: .DarkGreenStatus, fixItem: true) : "DarkGreenSprite",
         StatusType(itemStatus: .GoldStatus, fixItem: false) : "GoldSprite",
         StatusType(itemStatus: .GoldStatus, fixItem: true) : "GoldSprite",
         StatusType(itemStatus: .DarkGoldStatus, fixItem: false) : "DarkGoldSprite",
         StatusType(itemStatus: .DarkGoldStatus, fixItem: true) : "DarkGoldSprite"]

    public var letter = emptyLetter
    private var fontSize: CGFloat = 0
    init(blockSize: CGFloat, fontSize: CGFloat) {
        label = SKLabelNode()
        // Call the init        
        countWordsLabel = SKLabelNode()
        self.fontSize = fontSize
        let texture = SKTexture(imageNamed: "whiteSprite")
        super.init(texture: texture, color: .white, size: CGSize(width: blockSize, height: blockSize))
//        label.fontName = "KohinoorTelugu-Regular"
//        label.fontName = "Baskerville"
//        label.fontName = "ChalkboardSE-Light"
//        label.fontName = "PingFangTC-Semibold"
        label.fontName = GV.actPieceFont //"KohinoorBangla-Regular"
        label.fontColor = .black
        label.verticalAlignmentMode = .center
        var mySize = blockSize * 0.4
        repeat {
            if "A".height(font: UIFont(name: GV.actPieceFont, size: mySize)!) > blockSize * 0.7 {
                self.fontSize = mySize
                break
            }
            mySize += 1
        } while true
        label.fontSize = self.fontSize
        label.zPosition = self.zPosition + 1
        addChild(label)
        countWordsLabel.position = CGPoint(x: blockSize * 0.28, y: -blockSize * 0.35)
        countWordsLabel.fontName = GV.actPieceFont //"KohinoorBangla-Regular"
        countWordsLabel.fontColor = .black
//        countWordsLabel.verticalAlignmentMode = .center
        countWordsLabel.fontSize = fontSize * 0.5
//        countWordsLabel.text = String(countOccurencesInWords)
        countWordsLabel.zPosition = self.zPosition + 2
        addChild(countWordsLabel)
    }
    
    public var moveable:Bool {
        get {
            if fixItem {
                return false
            }
            if status == .Temporary && origStatus == .WholeWord {
                return false
            }
            if status == .WholeWord {
                return false
            }
           return true
        }
    }
    public func copyMe()->WTGameboardItem {
        let copyed = WTGameboardItem(blockSize: self.size.height, fontSize: self.fontSize)
        copyed.texture = self.texture
        copyed.position = self.position
        copyed.status = self.status
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
    public func setLetter(letter: String, toStatus: ItemStatus, calledFrom: String)->Bool {
        if letter != emptyLetter && toStatus == .Empty {
            print("hier at problem")
        }
        if (self.status == .Used && toStatus != .FixItem) || self.status == .WholeWord {
            self.origStatus = self.status
            setStatus(toStatus: .Error)
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
                setStatus(toStatus: .Used)
            } else {
                setStatus(toStatus: toStatus)
            }
            return true
        }
    }
    
    public func clearFixLetter() {
        fixItem = false
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
    
    public func incrementCountOccurencesInWords() {
        countOccurencesInWords += 1
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
            setStatus(toStatus: .Empty)
        case (.Temporary, true):
            if doubleUsed {
                label.text = self.origLetter
                self.letter = self.origLetter
                setStatus(toStatus: self.origStatus)
            }
        case (.Used, _):
            if doubleUsed {
                label.text = self.origLetter
                self.letter = self.origLetter
                setStatus(toStatus: self.origStatus)
            }
        case (.WholeWord, _):
            if doubleUsed {
                label.text = self.origLetter
                self.letter = self.origLetter
                setStatus(toStatus: self.origStatus)
            }
        case (.Error, _):
            if doubleUsed {
                label.text = self.origLetter
                self.letter = self.origLetter
                setStatus(toStatus: self.origStatus)
            }
        case (.GoldStatus, _):
            setStatus(toStatus: .Used)
        case (.DarkGoldStatus, _):
            setStatus(toStatus: .Used)
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
            setStatus(toStatus: .Used)
            return true
        } else if (status == .Used || status == .WholeWord) && doubleUsed {
            label.text = self.origLetter
            setStatus(toStatus: self.origStatus)
//            self.color = convertMyColorToSKColor(color: self.origColor)
            doubleUsed = false
            return false
        } else if status == .Error {
            label.text = origLetter
            setStatus(toStatus: self.origStatus)
            return false
        }
        return true
    }
    
    public func clearIfUsed() {
        if status == .WholeWord {
            label.text = emptyLetter
            self.letter = emptyLetter
            setStatus(toStatus: .Empty)
            clearConnectionType()
        }
    }
    
    public func correctStatusIfNeeded() {
        if status == .WholeWord && letter == emptyLetter {
            status = .Empty
        }
    }
    public func remove(all:Bool = false) {
        if all || !fixItem {
            label.text = emptyLetter
            self.letter = emptyLetter
            setStatus(toStatus: .Empty)
            fixItem = false
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
    
    public func setStatus(/*toColor: MyColor = .myWhiteColor,*/ toStatus: ItemStatus, connectionType: ConnectionType = ConnectionType(), incrWords: Bool = false, decrWords: Bool = false) {
        let newStatus = toStatus == .OrigStatus ? origStatus : toStatus
//        let oldStatus = status
        switch (status, newStatus) {
        case (.Used, .Temporary):
            origStatus = status
            origLetter = letter
            status = .Temporary
        case (.WholeWord, .Temporary):
            origStatus = status
            origLetter = letter
            status = .Temporary
        case (.WholeWord, .DarkGreenStatus):
            origStatus = status
            origLetter = letter
            status = toStatus
        case (.WholeWord, .Error):
            origStatus = status
            origLetter = letter
            status = toStatus
       default:
            self.status = newStatus
        }
        self.status = letter == emptyLetter ? .Empty : self.status
        self.countOccurencesInWords += incrWords ? 1 : 0
        if self.countOccurencesInWords > 0 && decrWords {
            self.countOccurencesInWords -= 1
        }
        
        if newStatus == .WholeWord || newStatus == .GoldStatus || newStatus == .DarkGoldStatus || newStatus == .Error || newStatus == .DarkGreenStatus {
            if countOccurencesInWords > 0 {
                self.countWordsLabel.text = String(countOccurencesInWords)
                self.countWordsLabel.fontSize = self.fontSize * (countOccurencesInWords < 10 ? 0.6 : 0.5)
            }
        } else {
            self.countWordsLabel.text = ""
        }
//        print("In SetStatus: caller: \(calledFrom), letter: \(letter), oldStatus: \(oldStatus), status: \(newStatus), newStatus: \(status)")
        setConnectionType(connectionType: connectionType)
        self.alpha = self.status == .Empty ? 0.2 : 1.0
    }
    
    var lastCol = 0
    var lastRow = 0
    var timer = Date()
    private func setFirstTime() {
        timer = Date()
    }
    
    private func showTime(string: String) {
        let date = Date()
        print("time at \(string): \((date.timeIntervalSince(timer) * 1000).nDecimals(10))")
        timer = Date()
    }
    

    
    private func setTexture() {
        var connectionName = "Connection"
        connectionName += self.connectionType.left ? "1" : "0"
        connectionName += self.connectionType.top ? "1" : "0"
        connectionName += self.connectionType.right ? "1" : "0"
        connectionName += self.connectionType.bottom ? "1" : "0"
        let name = textureName[StatusType(itemStatus: status, fixItem: fixItem)]!
        self.texture = SKTexture(imageNamed: name)
        let child = self.childNode(withName: "Connection")
        if connectionName != "Connection" {
            if child == nil {
                let child = SKSpriteNode(imageNamed: connectionName)
                child.size = self.size
                child.zPosition = self.zPosition - 10
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
        
        var modifiedStatus = status
        if fixItem {
            switch status {
            case .Used:
                modifiedStatus = .FixUsed
            case .WholeWord:
                modifiedStatus = .FixWholeWord
            default: break
            }
        }
        let actLetter = status == .Empty || status == .Temporary ? emptyLetter : letter
        return modifiedStatus.description + actLetter
    }
    
    public func restore(from: String) {
//        var color: MyColor = .myWhiteColor
        var status: ItemStatus = .Empty
        var letter = emptyLetter
        setFirstTime()
        remove(all: true)
//        showTime(string: "remove")
        if let rawStatus = Int(from.firstChar()) {
            if let itemStatus = ItemStatus(rawValue: rawStatus) {
                switch itemStatus {
                case .FixUsed:
                    fixItem = true
                    status = .Used
                case .FixWholeWord:
                    fixItem = true
                    status = .WholeWord
                default:
                    status = itemStatus
                }
            }
        }
        letter = from.subString(at: 1, length: 1)
//        showTime(string: "from.subString")
        _ = setLetter(letter: letter, toStatus: status, calledFrom: "restore")
//        showTime(string: "setLetter")
        origLetter = emptyLetter
        origStatus = .Empty
        doubleUsed = false
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
