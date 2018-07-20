//
//  WTGameFinished.swift
//  MagicOfWords
//
//  Created by Jozsef Romhanyi on 17/03/2018.
//  Copyright © 2018 Jozsef Romhanyi. All rights reserved.
//


import Foundation
import GameplayKit

enum GameFinisheStatus: Int {
    case OK = 0, TimeOut, NoMoreSteps
}

let GameFinishedOKName = "°°°GameFinishedOKName°°°"

struct WTResults {
    var countMandatoryWords: Int
    var scoreMandatoryWords: Int
    var countOwnWords: Int
    var scoreOwnWords: Int
    var countUsedLetters: Int
    var allAroundScore: Int
    init() {
        self.countMandatoryWords = 0
        self.scoreMandatoryWords = 0
        self.countOwnWords = 0
        self.scoreOwnWords = 0
        self.countUsedLetters = 0
        self.allAroundScore = 0
    }
    
}

public protocol WTGameFinishedDelegate: class {
    func startNewGame()
    func restartThisGame()
}


class WTGameFinished: SKSpriteNode {
    var results = WTResults()
    var status: GameFinisheStatus = .OK
    var resultsOnScreen = false
    var myDelegate: WTGameFinishedDelegate?
    var buttonText = ""
    init() {
        let texture = SKTexture(imageNamed: "menuBackground.png")
        let size = CGSize(width: UIScreen.main.bounds.size.width * 0.9, height: UIScreen.main.bounds.size.height * 0.3)
        let position = CGPoint(x: UIScreen.main.bounds.midX, y: UIScreen.main.bounds.midY)
        let color:SKColor = SKColor(red:230/255, green: 210/255, blue: 120/255, alpha: 0.99)
        super.init(texture: texture, color: color, size: size)
        self.size = size
        self.position = position
        self.colorBlendFactor = 0.9
        self.alpha = 0.9
        self.isHidden = true
        self.zPosition = 10
    }
    
    public func showFinish(status: GameFinisheStatus) {
        if !resultsOnScreen {
            self.status = status
            isHidden = false
            let OK = getResults()
            if !OK {
                switch status {
                case .TimeOut: createHeaderLabel(line: 1, text: GV.language.getText(.tcTaskNotCompletedWithTimeOut))
                case .NoMoreSteps: createHeaderLabel(line: 1, text: GV.language.getText(.tcTaskNotCompletedWithNoMoreSteps))
                case .OK: break
                }
                buttonText = GV.language.getText(.tcRestart)
                createHeaderLabel(line: 2, text: GV.language.getText(.tcWillBeRestarted))
             } else {
                createHeaderLabel(line: 1, text: GV.language.getText(.tcNoMoreSteps))
                buttonText = GV.language.getText(.tcNewGame)

            }
            createLabel(text: GV.language.getText(.tcCollectedRequiredWords), positionIndex: 1)
            createLabel(text: String(results.countMandatoryWords), positionIndex: 2)
            createLabel(text: GV.language.getText(.tcScore), positionIndex: 3)
            createLabel(text: String(results.scoreMandatoryWords), positionIndex: 4)

            createLabel(text: GV.language.getText(.tcCollectedOwnWords), positionIndex: 5)
            createLabel(text: String(results.countOwnWords), positionIndex: 6)
            createLabel(text: GV.language.getText(.tcScore), positionIndex: 7)
            createLabel(text: String(results.scoreOwnWords), positionIndex: 8)
            
            createLabel(text: GV.language.getText(.tcTotal), positionIndex: 9)
            createLabel(text: String(results.scoreOwnWords + results.scoreMandatoryWords), positionIndex: 10)

            createButton()
            resultsOnScreen = true
        }

  }
    
    private func getResults()->Bool {
        for actWord in WTGameWordList.shared.allWords {
            if actWord.mandatory {
                results.countMandatoryWords += actWord.counter
                results.scoreMandatoryWords += actWord.score
            } else {
                results.countOwnWords += actWord.counter
                results.scoreOwnWords += actWord.score
            }
            results.countUsedLetters += actWord.word.count
        }
        return WTGameWordList.shared.gameFinished()
    }
    
    private func createHeaderLabel(line: Int, text: String) {
        let label = SKLabelNode(fontNamed: "TimesNewRomanPS-BoldMT")
        label.text = text
        label.fontSize = UIScreen.main.bounds.width * (GV.onIpad ? 0.030 : 0.04)
//        label.fontSize = self.parent!.frame.size.height * (smallFont ? 0.017 :0.03)
        label.fontColor = .black
        label.colorBlendFactor = 0.9
        label.color = .white
        let xPosition: CGFloat = 0 //-self.size.width * 0.5
        let yPosition: CGFloat = self.size.height * 0.4 - CGFloat(line) * self.size.height * 0.07
        label.position = CGPoint(x: xPosition, y: yPosition)
        //        label.position = CGPoint(x: 0, y: -100)
        label.zPosition = self.zPosition + 1
        label.alpha = 1
        label.horizontalAlignmentMode = .center
        label.verticalAlignmentMode = .center
        //        (self.parent as! SKScene).addChild(label)
        self.addChild(label)
    }
    
    private func createLabel(text: String, positionIndex: Int) {
        let label = SKLabelNode(fontNamed: "TimesNewRomanPS-BoldMT")
        let column1Value:CGFloat = 0.07
        let column2Value:CGFloat = 0.55
        let column3Value:CGFloat = 0.60
        let column4Value:CGFloat = 0.85
        
        let row1Value:CGFloat = 0.50
        let row2Value:CGFloat = 0.46
        let row3Value:CGFloat = 0.42

        let positionsTab: [(x:CGFloat, y:CGFloat, fixLength: Int)] = [
            (x: 0, y: 0, fixLength: 0),  // Dummy

            (x: column1Value, y: row1Value, fixLength: 0),  // 1 = Required words
            (x: column2Value, y: row1Value, fixLength: 3), // 2 = Countwords
            (x: column3Value, y: row1Value, fixLength: 0), // 3 = Score
            (x: column4Value, y: row1Value, fixLength: 6),  // 4 = ScoreValue

            (x: column1Value, y: row2Value, fixLength: 0),  // 5 = Own words
            (x: column2Value, y: row2Value, fixLength: 3),  // 6 = Countwords
            (x: column3Value, y: row2Value, fixLength: 0),  // 7 = Score
            (x: column4Value, y: row2Value, fixLength: 6),  // 8 = ScoreValue
            
            (x: column1Value, y: row3Value, fixLength: 0), // 9 = Total
            (x: column4Value, y: row3Value, fixLength: 7), // 10 = Total Score

       ]
        label.fontSize = UIScreen.main.bounds.width * (GV.onIpad ? 0.025 : 0.035)
        label.fontColor = .black
        label.colorBlendFactor = 0.9
        label.color = .white
        let startPointX = -self.size.width * 0.5
        let startPointY = -self.size.height * (GV.onIpad ? 1.0 : 0.55)
        let (x, y, fixLength) = positionsTab[positionIndex]
        label.text = fixLength == 0 ? text : text.fixLength(length: fixLength)

        label.position = CGPoint(x: startPointX + self.size.width * x, y: startPointY + self.size.width * y)
//        label.position = CGPoint(x: 0, y: -100)
        label.zPosition = self.zPosition + 1
        label.alpha = 1
        label.horizontalAlignmentMode = fixLength == 0 ? .left : .right
        label.verticalAlignmentMode = .center
//        (self.parent as! SKScene).addChild(label)
        self.addChild(label)
    }
    
    private func createButton() {
        let texture = SKTexture(imageNamed: "button.png")
        let button = SKSpriteNode(texture: texture, color: .white, size: CGSize(width: self.size.width * 0.5, height: self.size.height * 0.2))
        button.position = CGPoint(x: 0, y: self.size.height * -0.2)
        button.name = name
        let label = SKLabelNode(fontNamed: "TimesNewRomanPS-BoldMT")
        label.text = buttonText
        label.fontSize = self.size.height * 0.1
        label.fontColor = .black
        label.colorBlendFactor = 0.9
        label.color = .white
        label.position = CGPoint(x:0, y: button.frame.height * 0.1)
        label.zPosition = self.zPosition + 1
        label.alpha = 1
        label.color = .blue
        label.horizontalAlignmentMode = .center
        label.verticalAlignmentMode = .center
        label.name = GameFinishedOKName
        button.addChild(label)
        self.addChild(button)
    }
    
    public func setDelegate(delegate: WTGameFinishedDelegate) {
        myDelegate = delegate
    }
    
    public func OKButtonPressed() {
        if status == .OK {
            myDelegate!.startNewGame()
            return
        }
        myDelegate!.restartThisGame()
        self.removeFromParent()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    deinit {
        print("\n THE SCENE \((type(of: self))) WAS REMOVED FROM MEMORY (DEINIT) \n")
    }

}
