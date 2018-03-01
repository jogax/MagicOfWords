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
    private var blockSize:CGFloat = 0
    private var label: SKLabelNode
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
        addChild(label)
    }
    
    public func setLetter(letter: String, status: ItemStatus, color: SKColor) {
        self.colorBlendFactor = 1
        label.text = letter
        self.status = status
        self.color = color
    }
    public func clearIfTemporary() {
        if status == .temporary {
            label.text = ""
            self.status = .empty
            self.color = .white
        }
    }
    
    public func fixIfTemporary() {
        if status == .temporary {
            self.status = .used
            self.color = .red
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
