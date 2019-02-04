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

class TimeForGame {
    var time: Int
    var maxTime: Int
    var hourMinSec: String {
        get {
            return time.HourMinSec
        }
    }
    var remainingTime: Int {
        get {
            return maxTime - time > 0 ? maxTime - time : 0
        }
    }
    init() {
        time = 0
        maxTime = iHour
    }
    init(from: String) {
        time = 0
        maxTime = iHour
        let components = from.components(separatedBy: itemSeparator)
        if components.count == 2 {
            if let myTime = Int(components[0]) {
                time = myTime
            }
            if let myMaxTime = Int(components[1]) {
                maxTime = myMaxTime
            }
        }
    }
    func toString()->String {
        return String(time) + itemSeparator + String(maxTime)
    }
    func incrementTime() {
        time += 1
    }
    func incrementMaxTime(value: Int) {
        maxTime += value
    }
    func decrementMaxTime(value: Int) {
        maxTime -= value
    }
}

class MyTimer: SKSpriteNode {
    let screenHeight: CGFloat
    let screenWidth: CGFloat
    var timeBackgroundSprite: SKSpriteNode?
    var mySize: CGSize
    var myTime: TimeForGame
    init(time: TimeForGame) {
        self.myTime = time
        let bounds = UIScreen.main.bounds
        screenHeight = bounds.size.height
        screenWidth = bounds.size.width
        let texture = SKTexture()
        let color:SKColor = SKColor(red: 220/255, green: 220/255, blue: 220/255, alpha: 1.0)
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
    
    public func update(time: TimeForGame)->Bool {
        var color: SKColor = .green
        var heightMultiplier = CGFloat(time.maxTime - time.time) / CGFloat(time.maxTime)
        heightMultiplier = heightMultiplier < 0 ? 0 : heightMultiplier
        switch Int(heightMultiplier * 100) {
        case 5...10: color = .yellow
        case 0...5: color = .red
        default: color = .green
        }
        let greenHeight = mySize.height * heightMultiplier
        timeBackgroundSprite!.size = mySize * CGSize(width: 0.98, height: heightMultiplier)
        timeBackgroundSprite!.position = CGPoint(x: 0, y: -(mySize.height - greenHeight) / 2)
        
        timeBackgroundSprite!.color = color
            
        if time.time >= time.maxTime {
            return true
        } else {
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
    
    private var startTime: Double = 0
    private var lastTime: Double = 0
    
    public func startTimeMessing() {
        startTime = CACurrentMediaTime()
        lastTime = startTime
    }
    
    private func myPrint(head: String, time: Double) {
        if time > 1 {
            print("\(head) \(time) sec ***")
        } else {
            print("\(head) used time: \(time * 1000) mSec")
        }

    }
    public func showWholeTime(text: String = "") {
        let head = text == "" ? text : text + ":"
        let actTime = CACurrentMediaTime()
        myPrint(head: head, time: lastTime - startTime)
        lastTime = actTime
  }

    public func showLastTime(text: String = "") {
        let head = text == "" ? text : text + ":"
        let actTime = CACurrentMediaTime()
        myPrint(head: head, time: actTime - lastTime)
        lastTime = actTime
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
            return
    }

}
