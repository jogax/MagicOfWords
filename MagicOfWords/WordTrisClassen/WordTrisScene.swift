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
    var piecesOfWordsToPlay = [String]()
    var grid: Grid?
    let heightMultiplicator = CGFloat(0.08)
    var random: MyRandom?
    var ws = [WordTrisShape]()
    let shapeMultiplicator = [CGFloat(0.19), CGFloat(0.52), CGFloat(0.81)]
    
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
        generateArrayOfWordPieces()
        ws = Array(repeating: WordTrisShape(), count: 3)
        wordTrisGameboard = WordTrisGameboard(size: 10, parentScene: self)
        let blockSize = self.frame.width / 16.0
        for index in 0..<3 {
            var type: MyShapes
//            guard let type = MyShapes(rawValue: random!.getRandomInt(1, max: MyShapes.count - 1)) else {
//                return
//            }
            switch index {
//            case 0: type = .L_Shape_1  // OK 3
//            case 1: type = .L_Shape_2   // OK 4
//            case 2: type = .L_Shape_3  // OK 4
//            case 0: type = .L_Shape_4  // OK 4
//            case 1: type = .Z_Shape_1  // OK 4
//            case 2: type = .Z_Shape_2  // OK 5
//                    case 0: type = .O_Shape // OK 4
//                    case 1: type = .T_Shape_1 // OK
//                    case 2: type = .T_Shape_2 // OK - 5
            case 0: type = .I_Shape_1 // NOK - 1
            case 1: type = .I_Shape_2 // NOK - 2
            case 2: type = .I_Shape_3 // NOK - 3
           default: continue
            }
            let length = myForms[type]!.count
            var letters = [String]()
            repeat {
                var actPos = random!.getRandomInt(0, max: allWords.count - 1)
                let actMaxValue = allWords.count - actPos < 3 ? allWords.count - actPos : 3
                let calculatedLength = random!.getRandomInt(1, max: actMaxValue)
                var actLength = calculatedLength > length - letters.count ? length - letters.count : calculatedLength
//                for index in actPos..<actPos + actLength {
//                    allWordsUsing[index] += 1
//                }
                repeat {
                    letters.append(String(allWords.mySubString(startPos: actPos, length: 1)))
                    actPos += 1
                    actLength -= 1
                } while actLength > 0
            } while letters.count < length
            ws[index] = WordTrisShape(type: type, parent: self, blockSize: blockSize, letters: letters)
            ws[index].sprite().position = CGPoint(x:self.frame.width * shapeMultiplicator[index], y:self.frame.height * heightMultiplicator)
            ws[index].sprite().name = "Pos\(index )"
            self.addChild(ws[index].sprite())
        }

    }
    
    private func generateArrayOfWordPieces() {
        for record in wordsToPlay {
            allWords += record.word.uppercased()
        }
        var allWordsUsing = Array(repeating: 0, count: allWords.count)
        var counterOfPieces = allWords.count * 5
        repeat {
            let actPos = random!.getRandomInt(0, max: allWords.count - 1)
            let actMaxValue = allWords.count - actPos < 3 ? allWords.count - actPos : 3
            let actLength = random!.getRandomInt(1, max: actMaxValue)
            for index in actPos..<actPos + actLength {
                allWordsUsing[index] += 1
            }
            let word = String(allWords.mySubString(startPos: actPos, length: actLength))
            piecesOfWordsToPlay.append(word)
            counterOfPieces -= 1
        } while counterOfPieces > 0 && allWordsUsing.contains(0)
    }

    
//    private func generateLettersForThisGame() {
//        var allWords = ""
//        for record in wordsToPlay {
//            allWords += record.word
//        }
//        repeat {
//            var actLength = random!.getRandomInt(1, max: 3)
//            actLength = actLength > allWords.count ? allWords.count : actLength
//            let endIndex = allWords.index(allWords.startIndex, offsetBy: actLength)
//            let word = String(allWords[..<endIndex])
//            allWords = String(allWords.mySubString(startPos: actLength))
//            lettersToPlay.append(word)
//        } while allWords.count > 0
//    }
    

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if wordTrisSceneDelegate == nil {
            return
        }
        let firstTouch = touches.first
        let touchLocation = firstTouch!.location(in: self)
        let nodes = self.nodes(at: touchLocation)
        if nodes.count > 0 {
            for node in nodes {
                guard let name = node.name else {
                    continue
                }
                switch name {
                case String(TextConstants.tcBack.rawValue):
                    wordTrisSceneDelegate!.gameFinished()

                case String("Pos0"):
//                    let newPosition = ws[0].sprite().position + CGPoint(x: 10, y: 50)
//                    ws[0].sprite().position = newPosition
                    ws[0].rotate()
                    break
                case String("Pos1"):
                    ws[1].rotate()
                    break
                case String("Pos2"):
                    ws[2].rotate()
                    break
                default: continue
                }
            }
        }
    }
    
    
    deinit {
        print("\n THE SCENE \((type(of: self))) WAS REMOVED FROM MEMORY (DEINIT) \n")
    }
}

