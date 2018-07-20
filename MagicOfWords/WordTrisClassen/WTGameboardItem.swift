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
    case empty = 0, temporary, used, wholeWord
    var description: String {
        return String(self.rawValue)
    }
}

enum MyColor: Int {
    case myWhiteColor = 0, myWholeWordColor, myUsedColor, myGoldColor, myBlueColor, myTemporaryColor, myRedColor, myNoColor
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

let emptyLetter = " "


class WTGameboardItem: SKSpriteNode {
    public var status: ItemStatus = .empty
    public var myColor: MyColor = .myWhiteColor
    private var colorToStatus: [ItemStatus:MyColor] = [
        .empty : .myWhiteColor, .temporary : .myTemporaryColor, .used : .myUsedColor, .wholeWord : .myWholeWordColor
    ]
    private var origLetter: String = emptyLetter
    private var origColor: MyColor = .myWhiteColor
    private var doubleUsed = false
    private var blockSize:CGFloat = 0
    private var label: SKLabelNode
    private var countOccurencesInWords = 0
    public var letter = emptyLetter
    init(blockSize: CGFloat, fontSize: CGFloat) {
        label = SKLabelNode()
        let texture = SKTexture()
        super.init(texture: texture, color: .white, size: CGSize(width: blockSize * 0.9, height: blockSize * 0.9))
        label.fontName = "KohinoorTelugu-Regular"
        label.fontName = "Baskerville"
        label.fontColor = .black
        label.verticalAlignmentMode = .center
        label.fontSize = fontSize
        label.zPosition = self.zPosition + 1
        letter = emptyLetter
        addChild(label)
    }
    
    public func setLetter(letter: String, status: ItemStatus, toColor: MyColor, forcedChange: Bool = false)->Bool {
        
        if (self.status == .used || self.status == .wholeWord) && !forcedChange {
            self.origColor = self.myColor
            setColors(toColor: .myRedColor)
            self.origLetter = label.text!
            label.text = letter
            self.letter = letter
            doubleUsed = true
            return false
        } else {
            self.colorBlendFactor = 1
            label.text = letter
            self.letter = letter
            self.status = status
            setColors(toColor: toColor)
            return true
        }
    }
    public func setFoundedWord(toColor: MyColor) {
        setColors(toColor: toColor)
        self.status = .wholeWord
    }
    
    public func clearIfTemporary() {
        if status == .temporary {
            label.text = emptyLetter
            self.letter = emptyLetter
            self.status = .empty
            setColors(toColor: .myWhiteColor)
        } else if (status == .used || status == .wholeWord) && doubleUsed {
            label.text = self.origLetter
            self.letter = self.origLetter
            setColors(toColor: self.origColor)
//            self.color = convertMyColorToSKColor(color: self.origColor)
            self.doubleUsed = false
        }
    }
    
    public func fixIfTemporary()->Bool {
        if status == .temporary {
            self.status = .used
            setColors(toColor: .myUsedColor)
            return true
        } else if (status == .used || status == .wholeWord) && doubleUsed {
            label.text = self.origLetter
            setColors(toColor: self.origColor)
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
            self.status = .empty
            setColors(toColor: .myWhiteColor)
//            self.color = .white
        }
    }
    
    public func setGreenToUsedColor() {
        if status == .wholeWord {
            setColors(toColor: .myUsedColor)
            status = .used
        }
    }
    public func remove() {
        self.status = .empty
        label.text = emptyLetter
        self.letter = emptyLetter
        setColors(toColor: .myWhiteColor)
//        self.color = .white
    }
    
    public func resetCountOccurences() {
        countOccurencesInWords = 0
    }
    
    public func incrementCountOccurences() {
        self.countOccurencesInWords += 1
        setFoundedWord(toColor: .myWholeWordColor)
    }
    
    public func decrementCountOccurences() {
        self.countOccurencesInWords -= 1
        if self.countOccurencesInWords == 0 {
            setGreenToUsedColor()
        }
    }
    
    public func getCountOccurences()->Int {
        return countOccurencesInWords
    }
    
    private func convertMyColorToSKColor(color: MyColor)->SKColor {
        switch color {
        case .myRedColor: return .red
        case .myWhiteColor: return .white
        case .myWholeWordColor: return .green
        case .myUsedColor: return usedColor
        case .myGoldColor: return goldColor
        case .myBlueColor: return turquoiseColor
        case .myTemporaryColor: return temporaryColor
        case .myNoColor: return .white
        }
    }
    
    private func setColors(toColor: MyColor) {
        self.myColor = toColor
        self.color = convertMyColorToSKColor(color: toColor)
    }
    
    public func changeColor(toColor: MyColor = .myNoColor) {
        if toColor == .myNoColor {
            setColors(toColor: self.origColor)
        } else {
            if !(myColor == toColor) {
                origColor = myColor
                setColors(toColor: toColor)
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
        _ = setLetter(letter: letter, status: status, toColor: color)
        origLetter = emptyLetter
        origColor = .myWhiteColor
        doubleUsed = false
        countOccurencesInWords = 0
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
