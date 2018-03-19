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
    func getResults()->WTResults
}

class WTGameFinished: SKSpriteNode {
    var delegate: WTGameFinishedDelegate
    init(size: CGSize, position: CGPoint, delegate: WTGameFinishedDelegate) {
        self.delegate = delegate
        let texture = SKTexture()
        let color:SKColor = SKColor(red:250/255, green: 220/255, blue: 120/255, alpha: 0.99)
        super.init(texture: texture, color: color, size: size)
        self.size = size
        self.position = position
        self.colorBlendFactor = 0.9
        self.alpha = 0.9
        self.zPosition = 10
    }
    
    public func showFinish() {
        let results = delegate.getResults()
        createLabel(text: GV.language.getText(.tcNoMoreSteps), positionIndex: 0, smallFont: false)
        createLabel(text: GV.language.getText(.tcCollectedRequiredWords), positionIndex: 1)
        createLabel(text: String(results.countMandatoryWords), positionIndex: 2)
        createLabel(text: GV.language.getText(.tcScore), positionIndex: 3)
        createLabel(text: String(results.scoreMandatoryWords), positionIndex: 4)
        
        createLabel(text: GV.language.getText(.tcCollectedOwnWords), positionIndex: 5)
        createLabel(text: String(results.countOwnWords), positionIndex: 6)
        createLabel(text: GV.language.getText(.tcScore), positionIndex: 7)
        createLabel(text: String(results.scoreOwnWords), positionIndex: 8)
        
        createLabel(text: GV.language.getText(.tcUsedLetters), positionIndex: 9)
        createLabel(text: String(results.countUsedLetters), positionIndex: 10)
        createLabel(text: GV.language.getText(.tcScore), positionIndex: 11)
        createLabel(text: String(results.scoreUsedLetters), positionIndex: 12)
        
        createLabel(text: GV.language.getText(.tcUsedLetters), positionIndex: 9)

  }
    
    private func createLabel(text: String, positionIndex: Int, smallFont: Bool = true) {
        let label = SKLabelNode(fontNamed: "TimesNewRomanPS-BoldMT")
        let parentScene = self.parent as! SKScene
        let positionsTab: [(x:CGFloat, y:CGFloat)] = [
            (x: 0.12, y: 0.85),  // Header Line
            (x: 0.12, y: 0.80),  // 1 = Required words
            (x: 0.50, y: 0.80),  // 2 = Value
            (x: 0.60, y: 0.80),  // 3 = Score
            (x: 0.80, y: 0.80),  // 4 = ScoreValue

            (x: 0.12, y: 0.78),  // 5 = Required words
            (x: 0.50, y: 0.78),  // 6 = Value
            (x: 0.60, y: 0.78),  // 7 = Score
            (x: 0.80, y: 0.78),  // 8 = ScoreValue

            (x: 0.12, y: 0.76),  // 9 = Required words
            (x: 0.50, y: 0.76),  // 10 = Value
            (x: 0.60, y: 0.76),  // 11 = Score
            (x: 0.80, y: 0.76)   // 12 = ScoreValue
        ]
        label.text = text
        label.fontSize = self.size.height * (smallFont ? 0.017 :0.03)
        label.fontColor = .black
        label.colorBlendFactor = 0.9
        label.color = .white
        let (x, y) = positionsTab[positionIndex]
        label.position = CGPoint(x: parentScene.size.width * x, y: parentScene.size.height * y)
        label.zPosition = self.zPosition + 1
        label.alpha = 1
        label.horizontalAlignmentMode = .left
        label.verticalAlignmentMode = .center
        (self.parent as! SKScene).addChild(label)
//        self.addChild(label)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    deinit {
        print("\n THE SCENE \((type(of: self))) WAS REMOVED FROM MEMORY (DEINIT) \n")
    }

}
