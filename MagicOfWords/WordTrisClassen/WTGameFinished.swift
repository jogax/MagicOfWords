//
//  WTGameFinished.swift
//  MagicOfWords
//
//  Created by Jozsef Romhanyi on 17/03/2018.
//  Copyright © 2018 Jozsef Romhanyi. All rights reserved.
//


import Foundation
import GameplayKit

protocol WTGameFinishedDelegate: class {
    func getResults()->(WTResults, Bool)
}

class WTGameFinished: SKSpriteNode {
    var delegate: WTGameFinishedDelegate
    init(size: CGSize, position: CGPoint, delegate: WTGameFinishedDelegate) {
        self.delegate = delegate
        let texture = SKTexture()
        let color:SKColor = SKColor(red:230/255, green: 210/255, blue: 120/255, alpha: 0.99)
        super.init(texture: texture, color: color, size: size)
        self.size = size
        self.position = position
        self.colorBlendFactor = 0.9
        self.alpha = 0.9
        self.zPosition = 10
    }
    
    public func showFinish() {
        let (results, OK) = delegate.getResults()
        if !OK {
            createLabel(text: GV.language.getText(.tcTaskNotCompleted), positionIndex: 0, smallFont: false)
        } else {
            createLabel(text: GV.language.getText(.tcNoMoreSteps), positionIndex: 0, smallFont: false)
        }
        createLabel(text: GV.language.getText(.tcCollectedRequiredWords), positionIndex: 1)
        createLabel(text: String(results.countMandatoryWords), positionIndex: 2)
        createLabel(text: GV.language.getText(.tcScore), positionIndex: 3)
        createLabel(text: String(results.scoreMandatoryWords), positionIndex: 4)
        
        createLabel(text: GV.language.getText(.tcCollectedOwnWords), positionIndex: 5)
        createLabel(text: String(results.countOwnWords), positionIndex: 6)
        createLabel(text: GV.language.getText(.tcScore), positionIndex: 7)
        createLabel(text: String(results.scoreOwnWords), positionIndex: 8)
        
        createOKButton()

  }
    
    private func createLabel(text: String, positionIndex: Int, smallFont: Bool = true) {
        let label = SKLabelNode(fontNamed: "TimesNewRomanPS-BoldMT")
        let column1Value:CGFloat = 0.08
        let column2Value:CGFloat = 0.50
        let column3Value:CGFloat = 0.60
        let column4Value:CGFloat = 0.70
        
        let row1Value:CGFloat = 0.8
        let row2Value:CGFloat = 0.7
        let row3Value:CGFloat = 0.6
        let row4Value:CGFloat = 0.5

        let positionsTab: [(x:CGFloat, y:CGFloat)] = [
            (x: column1Value, y: row1Value),  // Header Line
            
            (x: column1Value, y: row2Value),  // 1 = Required words
            (x: column2Value, y: row2Value),  // 2 = Value
            (x: column3Value, y: row2Value),  // 3 = Score
            (x: column4Value, y: row2Value),  // 4 = ScoreValue

            (x: column1Value, y: row3Value),  // 5 = Required words
            (x: column2Value, y: row3Value),  // 6 = Value
            (x: column3Value, y: row3Value),  // 7 = Score
            (x: column4Value, y: row3Value),  // 8 = ScoreValue

            (x: column1Value, y: row4Value),  // 9 = Required words
            (x: column2Value, y: row4Value),  // 10 = Value
            (x: column3Value, y: row4Value),  // 11 = Score
            (x: column4Value, y: row4Value),   // 12 = ScoreValue
       ]
        label.text = text
        label.fontSize = self.parent!.frame.size.height * (smallFont ? 0.017 :0.03)
        label.fontColor = .black
        label.colorBlendFactor = 0.9
        label.color = .white
        let startPointX = -self.size.width / 2
        let startPointY = -self.size.height / 2
        let (x, y) = positionsTab[positionIndex]
        label.position = CGPoint(x: startPointX + self.size.width * x, y: startPointY + self.size.width * y)
//        label.position = CGPoint(x: 0, y: -100)
        label.zPosition = self.zPosition + 1
        label.alpha = 1
        label.horizontalAlignmentMode = .left
        label.verticalAlignmentMode = .center
//        (self.parent as! SKScene).addChild(label)
        self.addChild(label)
    }
    
    private func createOKButton() {
        let label = SKLabelNode(fontNamed: "TimesNewRomanPS-BoldMT")
        label.text = "OK"
        label.fontSize = self.size.height * 0.1
        label.fontColor = .black
        label.colorBlendFactor = 0.9
        label.color = .white
//        let startPointX = -self.size.width * 0.5
//        let startPointY = -self.size.height / 2
//        label.position = CGPoint(x: startPointX + self.size.width * 0.5, y: startPointY + self.size.width * 0.6)
        label.position = CGPoint(x:-self.size.width * 0.1, y:0)
        label.zPosition = self.zPosition + 1
        label.alpha = 1
        label.color = .blue
        label.horizontalAlignmentMode = .center
        label.verticalAlignmentMode = .center
        self.addChild(label)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    deinit {
        print("\n THE SCENE \((type(of: self))) WAS REMOVED FROM MEMORY (DEINIT) \n")
    }

}
