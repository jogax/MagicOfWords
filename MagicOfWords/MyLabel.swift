//
//  MyLabel.swift
//  DuelOfWords
//
//  Created by Romhanyi Jozsef on 2020. 06. 23..
//  Copyright © 2020. Romhanyi Jozsef. All rights reserved.
//

import Foundation
import GameKit

class MyLabel: SKLabelNode {
    init(text: String, position: CGPoint, fontName: String, fontSize: CGFloat, name: String? = nil) {
        super.init()
        self.text = text
        self.fontName = fontName
        self.fontSize = fontSize
        self.fontColor = .black
        self.position = position
        self.zPosition = 20
        self.name = name
//        MyLabel.countInstances += 1
    }
    init(text: String, position: PLPosSize, fontName: String, fontSize: CGFloat) {
        super.init()
        self.text = text
        self.fontName = fontName
        self.fontSize = fontSize
        self.fontColor = .black
        self.plPosSize = position
        self.zPosition = 20
        self.name = name
        self.nodeType = .MyLabel
        setActPosSize()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
//    deinit {
//        print("THE CLASS \((type(of: self))) WAS REMOVED FROM MEMORY (DEINIT): instance: \(GameboardItem.countInstances)")
//        MyLabel.countInstances -= 1
//    }
//
//    static var countInstances = 0

}
