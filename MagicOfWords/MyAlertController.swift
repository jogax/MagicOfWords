//
//  MyAlertController.swift
//  MagicOfWords
//
//  Created by Jozsef Romhanyi on 04/04/2019.
//  Copyright © 2019 Jozsef Romhanyi. All rights reserved.
//

import Foundation
import SpriteKit

class MyAlertController: SKSpriteNode {
    var myLabels = [SKLabelNode]()
    var myFont = UIFont()
    var countLines = 0
    init(mainText: String, message: String) {
//        let maxWith = GV.screenWidth * 0.8
        myFont = UIFont(name: GV.actLabelFont, size: GV.onIpad ? 18 : 15)!
//        let textWidth = mainText.width(font: myFont)
        super.init(texture: SKTexture(), color: UIColor.white, size: CGSize(width: 0, height: 0))
    }
    public func addAction(text: String, target: AnyObject, action:Selector) {
        let label = SKLabelNode()
        label.fontName = GV.actLabelFont
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
