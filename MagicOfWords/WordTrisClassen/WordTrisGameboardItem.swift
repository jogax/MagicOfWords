//
//  WordTrisGameboardItem.swift
//  MagicOfWords
//
//  Created by Jozsef Romhanyi on 14/02/2018.
//  Copyright © 2018 Jozsef Romhanyi. All rights reserved.
//

import Foundation
import GameplayKit

class WordTrisGameboardItem: SKLabelNode {
    var letter = "A"
    init(letter: String) {
        self.letter = letter
        super.init()
        self.fontName = "Noteworthy"
        self.fontColor = .black
        self.text = letter
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
