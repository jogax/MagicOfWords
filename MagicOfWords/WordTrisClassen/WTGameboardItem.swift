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
    case empty = 0, temporary, used, wholeWord, noChange
    var description: String {
        return String(self.rawValue)
    }
}

enum MyColor: Int {
    case myWhiteColor = 0, myGreenColor, myUsedColor, myGoldColor, myBlueColor, myTemporaryColor, myRedColor, myNoColor, myDarkGoldColor, myDarkGreenColor,
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

let emptyLetter = " "


class WTGameboardItem: SKSpriteNode {
    public var status: ItemStatus = .empty
    public var myColor: MyColor = .myWhiteColor
    private var colorToStatus: [ItemStatus:MyColor] = [
        .empty : .myWhiteColor, .temporary : .myTemporaryColor, .used : .myUsedColor, .wholeWord : .myGreenColor
    ]
    private var origLetter: String = emptyLetter
    private var origColor: MyColor = .myWhiteColor
    public var doubleUsed = false
    private var blockSize:CGFloat = 0
    private var label: SKLabelNode
    private var connectionType = ConnectionType()
//    private var countOccurencesInWords = 0
    public var letter = emptyLetter
    init(blockSize: CGFloat, fontSize: CGFloat) {
        label = SKLabelNode()
        let texture = SKTexture(imageNamed: "whiteSprite0000.png")
        super.init(texture: texture, color: .white, size: CGSize(width: blockSize, height: blockSize))
        label.fontName = "KohinoorTelugu-Regular"
        label.fontName = "Baskerville"
        label.fontName = "ChalkboardSE-Light"
        label.fontName = "PingFangTC-Semibold"
        label.fontName = "KohinoorBangla-Regular"
        label.fontColor = .black
        label.verticalAlignmentMode = .center
        label.fontSize = fontSize
        label.zPosition = self.zPosition + 1
        addChild(label)
    }
    
    public func setLetter(letter: String, status: ItemStatus, toColor: MyColor, forcedChange: Bool = false)->Bool {
        
        if (self.status == .used || self.status == .wholeWord) && !forcedChange {
            self.origColor = self.myColor
            setColors(toColor: .myRedColor, toStatus: .noChange)
            self.origLetter = label.text!
            label.text = letter
            self.letter = letter
            doubleUsed = true
            return false
        } else {
            self.colorBlendFactor = 1
            label.text = letter
            self.letter = letter
//            self.status = status
            setColors(toColor: toColor, toStatus: status)
            return true
        }
    }
    
    public func getColor()->MyColor {
        return myColor
    }
    public func setFoundedWord(toColor: MyColor, toStatus: ItemStatus) {
        setColors(toColor: toColor, toStatus: toStatus)
        self.status = .wholeWord
    }
    
    public func setColorByState() {
        switch status {
        case .used:
            setColors(toColor: .myUsedColor, toStatus: .noChange)
        case .wholeWord:
            setColors(toColor: .myGreenColor, toStatus: .noChange)
        default:
            break
        }
    }
    
    public func clearIfTemporary() {
        if status == .temporary {
            label.text = emptyLetter
            self.letter = emptyLetter
            setColors(toColor: .myWhiteColor, toStatus: .empty)
        } else if (status == .used || status == .wholeWord) && doubleUsed {
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
//            letterStack.append(letter)
            label.text = emptyLetter
            self.letter = emptyLetter
//            self.status = .empty
            setColors(toColor: .myWhiteColor, toStatus: .empty)
//            self.color = .white
        }
    }
    
    public func setGreenToUsedColor() {
        if status == .wholeWord {
            setColors(toColor: .myUsedColor, toStatus: .used)
//            status = .used
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
//        self.color = .white
    }
    
//    public func resetCountOccurences() {
//        countOccurencesInWords = 0
//    }
//
//    public func incrementCountOccurences() {
//        self.countOccurencesInWords += 1
//        print("increment myLetter: \(letter), count: \(countOccurencesInWords)")
//        setFoundedWord(toColor: .myWholeWordColor)
//    }
//
//    public func decrementCountOccurences() {
//        if countOccurencesInWords > 0 {
//            self.countOccurencesInWords -= 1
//            print("decrement myLetter: \(letter), count: \(countOccurencesInWords)")
//            if self.countOccurencesInWords == 0 {
//                setGreenToUsedColor()
//            }
//        }
//    }
//
//    public func getCountOccurences()->Int {
//        return countOccurencesInWords
//    }
//
    private func convertMyColorToSKColor(color: MyColor)->SKColor {
        switch color {
        case .myRedColor: return .red
        case .myWhiteColor: return .white
        case .myGreenColor: return .green
        case .myUsedColor: return usedColor
        case .myGoldColor: return goldColor
        case .myBlueColor: return turquoiseColor
        case .myTemporaryColor: return temporaryColor
        case .myDarkGoldColor: return darkGoldColor
        case .myDarkGreenColor: return darkGreenColor
        case .myLightGreenColor: return lightGreenColor
        case .myNoColor: return .white
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
    
    public func setColors(toColor: MyColor, toStatus: ItemStatus, connectionType: ConnectionType = ConnectionType()) {
        let color = letter == emptyLetter ? .myWhiteColor : toColor
        self.myColor = color
        self.color = convertMyColorToSKColor(color: color)
        self.status = toStatus == .noChange ? self.status : toStatus
        setConnectionType(connectionType: connectionType)
    }
    
    private func setTexture() {
        var name = "whiteSprite"
        name += self.connectionType.left ? "1" : "0"
        name += self.connectionType.top ? "1" : "0"
        name += self.connectionType.right ? "1" : "0"
        name += self.connectionType.bottom ? "1" : "0"
        let texture = SKTexture(imageNamed: name)
        self.texture = texture
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
        var color: MyColor = .myWhiteColor
        var status: ItemStatus = .empty
        var letter = emptyLetter
        remove()
        if let rawStatus = Int(from.subString(startPos: 0, length: 1)) {
            if let itemStatus = ItemStatus(rawValue: rawStatus) {
                status = itemStatus
                if let toColor = colorToStatus[status] {
                    color = toColor
                }
            }
        }
        letter = from.subString(startPos: 1, length: 1)
        if letter == emptyLetter {
            color = .myWhiteColor
        }
        _ = setLetter(letter: letter, status: status, toColor: color)
        origLetter = emptyLetter
        origColor = .myWhiteColor
        doubleUsed = false
//        countOccurencesInWords = 0
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
