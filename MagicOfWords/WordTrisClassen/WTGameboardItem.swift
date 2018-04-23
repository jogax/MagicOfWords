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
}
let usedColor = SKColor(red:255/255, green: 153/255, blue: 153/255, alpha: 1)

class WTGameboardItem: SKSpriteNode {
    public var status: ItemStatus = .empty
//    private var letterStack = [String]()
    private var origLetter: String = ""
    private var origColor: SKColor = .white
    private var doubleUsed = false
    private var blockSize:CGFloat = 0
    private var label: SKLabelNode
    private var countOccurencesInWords = 0
    public var letter = ""
    init(blockSize: CGFloat, fontSize: CGFloat) {
//        self.mySprite = SKSpriteNode(color: .white, size: CGSize(width: blockSize * 0.9, height: blockSize * 0.9))
        label = SKLabelNode()
//        self.letter = letter
//        super.init(color: .white, size: CGSize(width: blockSize * 0.9, height: blockSize * 0.9))
        let texture = SKTexture()
        super.init(texture: texture, color: .white, size: CGSize(width: blockSize * 0.9, height: blockSize * 0.9))
        label.fontName = "Courier"
        label.fontColor = .black
        label.verticalAlignmentMode = .center
        label.fontSize = fontSize
        label.zPosition = self.zPosition + 1
        addChild(label)
    }
    
    public func setLetter(letter: String, status: ItemStatus, color: SKColor)->Bool {
        switch self.status {
        case .used, .wholeWord:
            self.origColor = self.color
            self.color = .red
            self.origLetter = label.text!
            label.text = letter
            self.letter = letter
            doubleUsed = true
            return false
        default:
            self.colorBlendFactor = 1
            label.text = letter
            self.letter = letter
            self.status = status
            self.color = color
            return true

        }
    }
//    public func setColor(color: SKColor) {
//        self.color = color
//    }
//    
    public func setFoundedWord(toColor: SKColor) {
        self.color = toColor
        self.status = .wholeWord
    }
    
    public func clearIfTemporary() {
        if status == .temporary {
            label.text = ""
            self.letter = ""
            self.status = .empty
            self.color = .white
        } else if (status == .used || status == .wholeWord) && doubleUsed {
            label.text = self.origLetter
            self.letter = self.origLetter
            self.color = self.origColor
            self.doubleUsed = false
        }
    }
    
    public func fixIfTemporary()->Bool {
        if status == .temporary {
            self.status = .used
            self.color = usedColor
            return true
        } else if (status == .used || status == .wholeWord) && doubleUsed {
            label.text = self.origLetter
            self.color = self.origColor
            doubleUsed = false
            return false
        }
        return true
    }
    
    public func clearIfUsed() {
        if status == .wholeWord {
//            letterStack.append(letter)
            label.text = ""
            self.letter = ""
            self.status = .empty
            self.color = .white
        } 
    }
    
//    public func pull() {
//        if letterStack.count > 0 {
//            self.letter = letterStack.last!
//            self.letterStack.removeLast()
//            self.status = .wholeWord
//            self.label.text = letter
//        }
//    }
//    
    public func setGreenToUsedColor() {
        if status == .wholeWord {
            self.color = usedColor
        }
    }
    public func remove() {
        self.status = .empty
        label.text = ""
        self.letter = ""
        self.color = .white
    }
    
    public func resetCountOccurences() {
        countOccurencesInWords = 0
    }
    
    public func incrementCountOccurences() {
        self.countOccurencesInWords += 1
    }
    
    public func getCountOccurences()->Int {
        return countOccurencesInWords
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
