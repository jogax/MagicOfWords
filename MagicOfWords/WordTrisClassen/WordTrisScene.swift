//
//  CollectWordsScene.swift
//  MagicOfWords
//
//  Created by Jozsef Romhanyi on 06/02/2018.
//  Copyright © 2018 Jozsef Romhanyi. All rights reserved.
//

import Foundation
import GameplayKit
public protocol WordTrisSceneDelegate: class {
    
    /// Method called when Game finished
    func gameFinished()
    
}
class WordTrisScene: SKScene {
    var wordTrisSceneDelegate: WordTrisSceneDelegate?
    var wordTrisGameboard: WordTrisGameboard?
    var wordsToPlay = Array<GameDataModel>()
    var lettersToPlay = [String]()
    var grid: Grid?
    var random: MyRandom?
    override func didMove(to view: SKView) {
        self.backgroundColor = SKColor(red: 223/255, green: 255/255, blue: 216/255, alpha: 1)
//        createMenuItem(menuInt: .tcPackage, firstLine: true)
        createMenuItem(menuInt: .tcBack)
        showWordsToCollect()
        play()
   }

    public func setDelegate(delegate: WordTrisSceneDelegate) {
        wordTrisSceneDelegate = delegate
    }

    var line = 0
    private func createMenuItem(menuInt: TextConstants, firstLine: Bool = false) {
        line = firstLine ? 1 : line + 1
        let menuItem = SKLabelNode(fontNamed: "Noteworthy")// Snell Roundhand")
        let startYPosition = self.frame.height * 0.98
        menuItem.text = GV.language.getText(menuInt)
        menuItem.name = String(menuInt.rawValue)
        menuItem.fontSize = self.frame.size.height / 50
        menuItem.position = CGPoint(x: self.frame.size.width * 0.1, y: startYPosition - (CGFloat(line) * 45) )
        menuItem.fontColor = SKColor.blue
        menuItem.color = UIColor.brown
        self.addChild(menuItem)
    }
    
    private func showWordsToCollect() {
        let wordListToShow = realm.objects(GameDataModel.self).filter("gameType = %d and gameNumber = %d", GV.gameType, GV.gameNumber)
        wordsToPlay = Array(wordListToShow)
        createLabel(word: GV.language.getText(.tcWordsToCollect), counter: 0)
        var counter = 1
        for wordRecord in wordsToPlay {
            createLabel(word: wordRecord.word, counter: counter)
            counter += 1
        }
        
    }

    private func createLabel(word: String, counter: Int) {
        let xPositionMultiplier = [0.2, 0.5, 0.8]
        let yPositionMultiplier = [0.86, 0.84, 0.82]
        let label = SKLabelNode(fontNamed: (counter == 0 ? "Noteworthy-Bold" : "Noteworthy"))// Snell Roundhand")
        let yPosition = self.frame.height * (counter == 0 ? 0.90 : CGFloat((yPositionMultiplier[(counter - 1) / 3])))
        let xPosition = self.frame.size.width * (counter == 0 ? 0.5 : CGFloat(xPositionMultiplier[(counter - 1) % 3]))
        label.position = CGPoint(x: xPosition, y: yPosition)
        label.fontSize = self.frame.size.height / (counter == 0 ? 50 : 50)
        label.fontColor = .black
        label.text = word
        self.addChild(label)
    }

    private func createGridShape(type: MyShapes, cols: Int = 0, position: CGPoint) {
        let path = CGMutablePath()
        path.move(to: CGPoint(x: self.frame.midX, y: self.frame.midY))
        path.addLine(to: CGPoint(x: self.frame.origin.x + self.frame.width / 2, y: self.frame.origin.y))
        let myShape = SKShapeNode(path: path)
        myShape.fillColor = .green
        
        self.addChild(myShape)
    }
    
    private func play() {
        random = MyRandom(gameType: GV.gameType, gameNumber: GV.gameNumber)
        wordTrisGameboard = WordTrisGameboard(size: 10, parentScene: self)
        generateLettersForThisGame()
        let blockSize = self.frame.width / 14
        let zShape1 = WordTrisShape(type: .Z_Shape_1, parent: self, blockSize: blockSize).sprite()
        zShape1.position = CGPoint(x:self.frame.width * 0.19, y:self.frame.height * 0.12)
        self.addChild(zShape1)
        let zShape2 = WordTrisShape(type: .Z_Shape_2, parent: self, blockSize: blockSize).sprite()
        zShape2.position = CGPoint(x:self.frame.width * 0.50, y:self.frame.height * 0.12)
        self.addChild(zShape2)
        let lShape2 = WordTrisShape(type: .L_Shape_2, parent: self, blockSize: blockSize).sprite()
        lShape2.position = CGPoint(x:self.frame.width * 0.81, y:self.frame.height * 0.12)
        self.addChild(lShape2)

    }
    
    private func generateLettersForThisGame() {
        var allWords = ""
        for record in wordsToPlay {
            allWords += record.word
            print(allWords)
        }
        repeat {
            var actLength = random!.getRandomInt(1, max: 3)
            actLength = actLength > allWords.count ? allWords.count : actLength
            let endIndex = allWords.index(allWords.startIndex, offsetBy: actLength)
            let word = String(allWords[..<endIndex])
            allWords = String(allWords.mySubString(startPos: actLength))
            lettersToPlay.append(word)
        } while allWords.count > 0
    }
    

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if wordTrisSceneDelegate == nil {
            return
        }
        let firstTouch = touches.first
        let touchLocation = firstTouch!.location(in: self)
        let nodes = self.nodes(at: touchLocation)
        if nodes.count > 0 {
            if let name = nodes.first!.name {
                switch name {
                case String(TextConstants.tcBack.rawValue):
                    wordTrisSceneDelegate!.gameFinished()

                default: break
                }
            }
        }
    }
    
    
    deinit {
        print("\n THE SCENE \((type(of: self))) WAS REMOVED FROM MEMORY (DEINIT) \n")
    }
}

