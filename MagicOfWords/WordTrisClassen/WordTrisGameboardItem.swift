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
    case empty = 0, temporary, used
}
class WordTrisGameboardItem: SKSpriteNode {
    public var status: ItemStatus = .empty
    private var doubleUsed = false
    private var blockSize:CGFloat = 0
    private var label: SKLabelNode
    private var origLetter: String = ""
    public var letter = ""
    private var usedColor = SKColor(red:255/255, green: 153/255, blue: 153/255, alpha: 1)
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
        if self.status != .used {
            self.colorBlendFactor = 1
            label.text = letter
            self.letter = letter
            self.status = status
            self.color = color
            return true
        } else {
            self.color = .red
            self.origLetter = label.text!
            label.text = letter
            self.letter = letter
            doubleUsed = true
            return false
        }
    }
    public func setRedColor() {
        self.color = .red
    }
    
    public func clearIfTemporary() {
        if status == .temporary {
            label.text = ""
            self.letter = ""
            self.status = .empty
            self.color = .white
        } else if status == .used && doubleUsed {
            label.text = self.origLetter
            self.letter = self.origLetter
            self.color = usedColor
            self.doubleUsed = false
        }
    }
    
    public func fixIfTemporary() {
        if status == .temporary {
            self.status = .used
            self.color = usedColor
        } else if status == .used && doubleUsed {
            label.text = self.origLetter
            self.color = usedColor
            doubleUsed = false
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
