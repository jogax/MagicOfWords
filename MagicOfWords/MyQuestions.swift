//
//  MyQuestions.swift
//  MagicOfWords
//
//  Created by Jozsef Romhanyi on 26/04/2018.
//  Copyright © 2018 Jozsef Romhanyi. All rights reserved.
//

import Foundation
import GameplayKit

enum QuestionType: Int {
    case NoMoreSteps = 0
}
let answer1Name = "Answer1"
let answer2Name = "Answer2"
let questionName = "Question"
let MyQuestionName = "MyQuestion"

class MyQuestion: SKSpriteNode {
    var questionLabel: SKLabelNode
    init(question: QuestionType, parentSize: CGSize) {
        //        self.mySprite = SKSpriteNode(color: .white, size: CGSize(width: blockSize * 0.9, height: blockSize * 0.9))
        questionLabel = SKLabelNode()
        switch question {
        case .NoMoreSteps:
            questionLabel.text = GV.language.getText(.tcNoMoreStepsQuestion)
        }
        //        self.letter = letter
        //        super.init(color: .white, size: CGSize(width: blockSize * 0.9, height: blockSize * 0.9))
        let texture = SKTexture(imageNamed: "menuBackground.png")
        super.init(texture: texture, color: .red, size: CGSize(width: parentSize.width * 0.9, height: parentSize.height * 0.25))
        self.name = MyQuestionName
        self.zPosition = 100
        createLabels(withText: GV.language.getText(.tcNoMoreStepsQuestion), position: CGPoint(x:self.size.width * 0.0, y:self.size.height * 0.2), name: questionName)
        addChild(createButton(withText: GV.language.getText(.tcNoMoreStepsAnswer1), position: CGPoint(x:-self.size.width * 0.24, y:-self.size.height * 0.1), name: answer1Name))
        addChild(createButton(withText: GV.language.getText(.tcNoMoreStepsAnswer2), position: CGPoint(x:self.size.width * 0.21, y:-self.size.height * 0.1), name: answer2Name))
    }
    
    private func createButton(withText: String, position: CGPoint, name: String)->SKSpriteNode {
        let texture = SKTexture(imageNamed: "button.png")
        let button = SKSpriteNode(texture: texture, color: .white, size: CGSize(width: self.size.width * 0.4, height: self.size.height * 0.3))
        button.position = position
        button.name = name
        button.addChild(createLabel(withText: withText, position: CGPoint(x:0, y:10), name: name + "Label"))
        return button
        
    }
    
    private func createLabels(withText: String, position: CGPoint, name: String) {
        let textTable = withText.components(separatedBy: itemSeparator)
        if textTable.count == 2 {
            let label1 = createLabel(withText: textTable[0], position: CGPoint(x: position.x, y: position.y + self.size.width * 0.035), name: name)
            let label2 = createLabel(withText: textTable[1], position: CGPoint(x: position.x, y: position.y - self.size.width * 0.015), name: name)
            addChild(label1)
            addChild(label2)
       }
    }
    
    private func createLabel(withText: String, position: CGPoint, name: String)->SKLabelNode {
        let label = SKLabelNode(fontNamed: "TimesNewRomanPS-BoldMT")
        label.fontColor = .black
        label.verticalAlignmentMode = .center
        label.horizontalAlignmentMode = .center
        label.fontSize = self.size.width * 0.04
        label.zPosition = self.zPosition + 1
        label.text = withText
        label.name = name
        label.position = position
        return label
    }
    
    public func show() {
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
//    required init?(coder aDecoder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }

}
