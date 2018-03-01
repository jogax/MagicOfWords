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
    var allWords = String()
    var workingLetters = String()
    var piecesOfWordsToPlay = [String]()
    var grid: Grid?
    let heightMultiplicator = CGFloat((GV.onIpad ? 0.10 : 0.15))
    var blockSize: CGFloat = 0
    var random: MyRandom?
    var ws = [WordTrisShape]()
    var origPosition: [CGPoint] = Array(repeating: CGPoint(x:0, y: 0), count: 3)
    var origSize: [CGSize] = Array(repeating: CGSize(width:0, height: 0), count: 3)
    var moved = false
    var movedIndex = 0
    var startShape = WordTrisShape()
    let shapeMultiplicator = [CGFloat(0.20), CGFloat(0.50), CGFloat(0.80)]
    
    override func didMove(to view: SKView) {
       self.name = "WordTrisScene"
       self.backgroundColor = SKColor(red: 223/255, green: 255/255, blue: 216/255, alpha: 0.8)
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
            createLabel(word: wordRecord.word.uppercased(), counter: counter)
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
    
    private func play() {
//        var allWordsUsing = Array(repeating: 0, count: allWords.count)
        random = MyRandom(gameType: GV.gameType, gameNumber: GV.gameNumber)
//        generateArrayOfWordPieces()
        
        ws = Array(repeating: WordTrisShape(), count: 3)
        wordTrisGameboard = WordTrisGameboard(size: 10, parentScene: self)
        for record in wordsToPlay {
            allWords += record.word.uppercased()
        }
        

        for index in 0..<3 {
            ws[index] = generateShape(horizontalPosition: index)
            origPosition[index] = CGPoint(x:self.frame.width * shapeMultiplicator[index], y:self.frame.height * heightMultiplicator)
            origSize[index] = ws[index].sprite().size
            ws[index].sprite().position = origPosition[index]
//            ws[index].sprite().anchorPoint = CGPoint(x: 0.5, y: 0.5)
            ws[index].sprite().name = "Pos\(index )"
            self.addChild(ws[index].sprite())
        }

    }
    
    private func generateShape(horizontalPosition: Int)->WordTrisShape {
//        guard let type = MyShapes(rawValue: random!.getRandomInt(1, max: MyShapes.count - 1)) else {
//            return WordTrisShape()
//        }
        let x = 0
        guard let type = MyShapes(rawValue: horizontalPosition + x) else {
            return WordTrisShape()
        }
        blockSize = self.frame.size.width * (GV.onIpad ? 0.70 : 0.90) / CGFloat(12)
//        let blockSize = self.frame.width / (GV.onIpad ? 18.0 : 15)
        let length = myForms[type]![0].count
        var letters = [String]()
        repeat {
            if workingLetters.count == 0 {
                workingLetters = allWords
            }
            let actPos = random!.getRandomInt(0, max: workingLetters.count - 1)
            let actMaxValue = workingLetters.count - actPos < 3 ? workingLetters.count - actPos : 3
            let calculatedLength = random!.getRandomInt(1, max: actMaxValue)
            var actLength = calculatedLength > length - letters.count ? length - letters.count : calculatedLength
            repeat {
                letters.append(String(workingLetters.subString(startPos: actPos, length: 1, remove: true)))
//                actPos += 1
                actLength -= 1
            } while actLength > 0
        } while letters.count < length
        return WordTrisShape(type: type, parent: self, blockSize: blockSize, letters: letters)

    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if wordTrisSceneDelegate == nil {
            return
        }
        moved = false
        let firstTouch = touches.first
        let touchLocation = firstTouch!.location(in: self)
        let nodes = self.nodes(at: touchLocation)
        if nodes.count > 0 {
            for node in nodes {
                guard let name = node.name else {
                    continue
                }
                if name == String(TextConstants.tcBack.rawValue) {
                    continue
                }
                if name.subString(startPos:0, length: 3) == "Pos" {
                    guard let index = Int(name.subString(startPos:3, length:1)) else {
                        continue
                    }
                    startShape = ws[index]
                }
            }
        }

    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if wordTrisSceneDelegate == nil {
            return
        }
        let firstTouch = touches.first
        let touchLocation = firstTouch!.location(in: self)
        let nodes = self.nodes(at: touchLocation)
        if moved {
            ws[movedIndex].sprite().position = touchLocation + CGPoint(x: 0, y: blockSize * 2)
//            ws[movedIndex].sprite().alpha = 0.1
            wordTrisGameboard!.showSpriteOnGameboard(shape: ws[movedIndex])
        } else if nodes.count > 0 {
            for node in nodes {
                guard let name = node.name else {
                    continue
                }
                if name == String(TextConstants.tcBack.rawValue) {
                    continue
                }
                if name.subString(startPos:0, length: 3) == "Pos" && startShape.sprite().name == name {
                    guard let index = Int(name.subString(startPos:3, length:1)) else {
                        continue
                    }
                    let delta = origPosition[index] - touchLocation
                    if !moved && (abs(delta.x) > 10 || abs(delta.y) > 10 ){
                        origSize[index] = ws[index].sprite().size
                        moved = true
                        ws[index].changeSize(by: 1.2)
                        movedIndex = index
                        break
                    }
                }
            }
        }
        
    }

    

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if wordTrisSceneDelegate == nil {
            return
        }
        let firstTouch = touches.first
        let touchLocation = firstTouch!.location(in: self)
        let nodes = self.nodes(at: touchLocation)
        if moved {
            let fixed = wordTrisGameboard!.fixSpriteOnGameboardIfNecessary(shape: ws[movedIndex])
            if fixed {
                if movedIndex == ws.count - 1 {
                    print ("last")
                } else {
                    for index in movedIndex..<ws.count - 1 {
                        ws[index] = ws[index + 1]
                        ws[index].sprite().name = "Pos \(String(index))"
                    }
                }
            } else {
                ws[movedIndex].sprite().position = origPosition[movedIndex]
                ws[movedIndex].sprite().scale(to: origSize[movedIndex])
                ws[movedIndex].sprite().alpha = 1
            }
            moved = false
        } else if nodes.count > 0 {
            for node in nodes {
                guard let name = node.name else {
                    continue
                }
                if name == String(TextConstants.tcBack.rawValue) {
                    wordTrisSceneDelegate!.gameFinished()
                } else if name.subString(startPos:0, length: 3) == "Pos" {
                    guard let index = Int(name.subString(startPos:3, length:1)) else {
                        continue
                    }
                    ws[index].rotate()
                }
            }
        }
    }
    
    deinit {
        print("\n THE SCENE \((type(of: self))) WAS REMOVED FROM MEMORY (DEINIT) \n")
    }
}

