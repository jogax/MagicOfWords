//
//  MyTimer.swift
//  MagicOfWords
//
//  Created by Jozsef Romhanyi on 18/05/2018.
//  Copyright © 2018 Jozsef Romhanyi. All rights reserved.
//

import Foundation
import GameplayKit


let myTimerName = "°°°MyTimerName°°°"
class MyTimer: SKSpriteNode {
    let screenHeight: CGFloat
    let screenWidth: CGFloat
    var timeBackgroundSprite: SKSpriteNode?
    var mySize: CGSize
    let maxTime: Int
    init(maxTime: Int) {
        self.maxTime = maxTime
        let bounds = UIScreen.main.bounds
        screenHeight = bounds.size.height
        screenWidth = bounds.size.width
        let texture = SKTexture()
        let color:SKColor = .gray
        mySize = CGSize(width: screenWidth * 0.02, height: screenHeight * 0.70)
        let position = CGPoint(x: screenWidth * 0.98, y: screenHeight * 0.40)
        super.init(texture: texture, color: color, size: mySize)
        self.size = size
        self.position = position
        self.colorBlendFactor = 0.9
        self.alpha = 1.0
        self.zPosition = 100
        createTimer()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func update(time: Int)->Bool {
        if time >= maxTime {
            return true
        } else {
            let heightMultiplier = CGFloat(maxTime - time) / CGFloat(maxTime)
            let greenComponent = 255 * heightMultiplier
            let redComponent = 255 - (255 * heightMultiplier)
            let color = SKColor(red: redComponent / 255, green: greenComponent / 255, blue: 0, alpha: 1.0)
            let greenHeight = mySize.height * heightMultiplier
            timeBackgroundSprite!.size = mySize * CGSize(width: 0.98, height: heightMultiplier)
            timeBackgroundSprite!.position = CGPoint(x: 0, y: -(mySize.height - greenHeight) / 2)
            
            timeBackgroundSprite!.color = color
            
            return false
        }
    }
    private func createTimer() {
       if self.childNode(withName: myTimerName) == nil {
            let texture = SKTexture()
            timeBackgroundSprite = SKSpriteNode(texture: texture, color: .green, size: mySize * CGSize(width: 0.98, height: 1.0))
            timeBackgroundSprite!.position = CGPoint(x: 0, y: -0.001 * screenHeight)
            timeBackgroundSprite!.name = myTimerName
            timeBackgroundSprite!.alpha = 1.0
            timeBackgroundSprite!.colorBlendFactor = 0.9
            self.addChild(timeBackgroundSprite!)
        }
    }

}
