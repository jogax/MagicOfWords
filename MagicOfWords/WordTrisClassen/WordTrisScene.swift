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
    struct TilesForGame {
        var type: MyShapes = .NotUsed
        var rotateIndex: Int = 0
        var letters: [String] = [String]()
    }
    var wordTrisSceneDelegate: WordTrisSceneDelegate?
    var wordTrisGameboard: WordTrisGameboard?
    var wordsToPlay = Array<GameDataModel>()
    var allWords = String()
    var workingLetters = String()
    var tilesForGame = [TilesForGame]()
    var indexOfTilesForGame = 0
    var playingWords = [String]()
    var grid: Grid?
    let heightMultiplicator = CGFloat((GV.onIpad ? 0.10 : 0.15))
    var blockSize: CGFloat = 0
    var random: MyRandom?
    var ws = [WordTrisShape]()
    var origPosition: [CGPoint] = Array(repeating: CGPoint(x:0, y: 0), count: 3)
    var origSize: [CGSize] = Array(repeating: CGSize(width:0, height: 0), count: 3)
    var moved = false
    var movedIndex = 0
    var startShapeIndex = 0
    let shapeMultiplicator = [CGFloat(0.20), CGFloat(0.50), CGFloat(0.80)]
    let sizeOfGrid = 10
    let letterCounts: [Int:[Int]] = [
        1: [1],
        2: [11, 2],
        3: [3, 21, 111],
        4: [31, 22],
        5: [32, 221]
    ]
    
    
    override func didMove(to view: SKView) {
        self.name = "WordTrisScene"
        self.view!.isMultipleTouchEnabled = false
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
            playingWords.append(wordRecord.word.uppercased())
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
        random = MyRandom(gameType: GV.gameType, gameNumber: GV.gameNumber)
        generateArrayOfWordPieces()
        indexOfTilesForGame = 0

        ws = Array(repeating: WordTrisShape(), count: 3)
        wordTrisGameboard = WordTrisGameboard(size: sizeOfGrid, parentScene: self)
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
    
    private func generateArrayOfWordPieces() {
        func getLetters( from: inout [String], archiv: inout [String])->String {
            if from.count == 0 {
                for item in archiv {
                    from.append(item)
                }
                archiv.removeAll()
            }
            let index = random!.getRandomInt(0, max: from.count - 1)
            let piece = from[index]
            archiv.append(piece)
            from.remove(at: index)
            return piece
        }
        tilesForGame.removeAll()
        var oneLetterPieces = [String]()
        var oneLetterPiecesArchiv = [String]()
        var twoLetterPieces = [String]()
        var twoLetterPiecesArchiv = [String]()
       for word in playingWords {
            for letter in word {
                oneLetterPieces.append(String(letter))
            }
            for index in 0..<word.count / 2 {
                twoLetterPieces.append(word.subString(startPos: index * 2, length: 2))
            }
        }
        var typesWithLen1 = [MyShapes]()
        var typesWithLen2 = [MyShapes]()
        var typesWithLen3 = [MyShapes]()
        var typesWithLen4 = [MyShapes]()
        var typesWithLen5 = [MyShapes]()

        for index in 0..<MyShapes.count - 2 {
            guard let type = MyShapes(rawValue: index) else {
                return
            }
            let length = myForms[type]![0].count
            switch length {
            case 1: typesWithLen1.append(type)
            case 2: typesWithLen2.append(type)
            case 3: typesWithLen3.append(type)
            case 4: typesWithLen4.append(type)
            case 5: typesWithLen5.append(type)
            default: break
            }
        }
        let lengths = [1,1,1,1,2,2,2,2,3,3,3,3,3,3,3,3,4,4,4,4,4,4,4,5,5,1,1]
        var generateLength = 0
        repeat {
            let tileLength = lengths[random!.getRandomInt(0, max: lengths.count - 1)]
            var tileType = MyShapes.NotUsed
            var letters = [String]()
            switch tileLength {
            case 1: tileType = typesWithLen1[0]
                letters.append(getLetters(from: &oneLetterPieces, archiv: &oneLetterPiecesArchiv))
            case 2: tileType = typesWithLen2[0]
                letters.append(getLetters(from: &twoLetterPieces, archiv: &twoLetterPiecesArchiv))
            case 3: tileType = typesWithLen3[random!.getRandomInt(0, max: typesWithLen3.count - 1)]
                letters.append(getLetters(from: &twoLetterPieces, archiv: &twoLetterPiecesArchiv))
                letters.append(getLetters(from: &oneLetterPieces, archiv: &oneLetterPiecesArchiv))
           case 4: tileType = typesWithLen4[random!.getRandomInt(0, max: typesWithLen4.count - 1)]
               letters.append(getLetters(from: &twoLetterPieces, archiv: &twoLetterPiecesArchiv))
               letters.append(getLetters(from: &twoLetterPieces, archiv: &twoLetterPiecesArchiv))
            case 5: tileType = typesWithLen5[random!.getRandomInt(0, max: typesWithLen5.count - 1)]
                letters.append(getLetters(from: &twoLetterPieces, archiv: &twoLetterPiecesArchiv))
                letters.append(getLetters(from: &twoLetterPieces, archiv: &twoLetterPiecesArchiv))
                letters.append(getLetters(from: &oneLetterPieces, archiv: &oneLetterPiecesArchiv))
            default: break
            }
            let rotateIndex = random!.getRandomInt(0, max: 3)
            
            let tileForGameItem = TilesForGame(type: tileType, rotateIndex: rotateIndex, letters: letters)
            tilesForGame.append(tileForGameItem)
            generateLength += tileLength
        } while generateLength < 150

    }
    
    private func generateShape(horizontalPosition: Int)->WordTrisShape {
        blockSize = self.frame.size.width * (GV.onIpad ? 0.70 : 0.90) / CGFloat(12)
        let tileForGame = tilesForGame[indexOfTilesForGame]
        indexOfTilesForGame += 1
        indexOfTilesForGame = indexOfTilesForGame >= tilesForGame.count ? 0 : indexOfTilesForGame
        let type = tileForGame.type
        let rotateIndex = tileForGame.rotateIndex
        var letters = [String]()
        for tiles in tileForGame.letters {
            for letter in tiles {
                letters.append(String(letter))
            }
        }
        return WordTrisShape(type: type, rotateIndex: rotateIndex, parent: self, blockSize: blockSize, letters: letters)

    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if wordTrisSceneDelegate == nil {
            return
        }
        moved = false
        let firstTouch = touches.first
        let touchLocation = firstTouch!.location(in: self)
        let nodes = self.nodes(at: touchLocation)
        let (row, col, shapeIndex, goBack) = analyzeNodes(nodes: nodes)
        if shapeIndex > -1 {
            startShapeIndex = shapeIndex
            wordTrisGameboard!.clear()
        }

    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if wordTrisSceneDelegate == nil {
            return
        }
        let firstTouch = touches.first
        let touchLocation = firstTouch!.location(in: self)
        let nodes = self.nodes(at: touchLocation)
        let (row, col, shapeIndex, goBack) = analyzeNodes(nodes: nodes)
        if moved {
            let sprite = ws[movedIndex].sprite()
            sprite.position = touchLocation + CGPoint(x: 0, y: blockSize * 2.5)
            sprite.alpha = 0.0
            if wordTrisGameboard!.moveSpriteOnGameboard(col: col, row: row) {  // true says moving finished
                if row == sizeOfGrid { // when at bottom
                    sprite.alpha = 1.0
                }
            }

        } else {
            if shapeIndex >= 0 {
                ws[shapeIndex].sprite().position = touchLocation
            }
            if row >= 0 && row < 10 {
//                origSize[shapeindex] = ws[index].sprite().size
//                moved = true
                if shapeIndex >= 0 {
                    moved = wordTrisGameboard!.startShowingSpriteOnGameboard(shape: ws[shapeIndex], col: col, row: row)
                    movedIndex = shapeIndex
                }
            } 
        }
    
    }

    private func analyzeNodes(nodes: [SKNode])->(col: Int, row: Int, shapeIndex: Int, goBack: Bool) {
        var values = (col: -1, row: -1, shapeIndex: -1, goBack: false)
        for node in nodes {
            guard let name = node.name else {
                continue
            }
            if name == String(TextConstants.tcBack.rawValue) {
                values.goBack = true
                return values
            }
            guard let number = Int(name.subString(startPos: 3, length: name.count - 3)) else {
                continue
            }
            switch name.subString(startPos: 0, length: 3) {
            case "Col": values.col = number
            case "Row": values.row = number
            case "Pos": values.shapeIndex = number
            default: continue
            }
        }
        return values
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if wordTrisSceneDelegate == nil {
            return
        }
        let firstTouch = touches.first
        let touchLocation = firstTouch!.location(in: self)
        let nodes = self.nodes(at: touchLocation)
        let lastPosition = ws.count - 1
        let (row, col, shapeIndex, goBack) = analyzeNodes(nodes: nodes)
        if moved {
            let fixed = wordTrisGameboard!.stopShowingSpriteOnGameboard(col: col, row: row, wordsToCheck: playingWords)
            if fixed {
                let fixedName = "Pos\(movedIndex)"
                removeNodesWith(name: fixedName)
                if movedIndex < lastPosition {
                    for index in movedIndex..<lastPosition {
                        ws[index] = ws[index + 1]
                        ws[index].sprite().name = "Pos\(String(index))"
                        ws[index].sprite().position = origPosition[index]
                        origSize[index] = ws[index].sprite().size
                    }
                }
                ws[lastPosition] = generateShape(horizontalPosition: lastPosition)
                ws[lastPosition].sprite().position = origPosition[lastPosition]
                ws[lastPosition].sprite().name = "Pos\(lastPosition)"
                self.addChild(ws[lastPosition].sprite())

            } else {
                ws[movedIndex].sprite().position = origPosition[movedIndex]
//                ws[movedIndex].sprite().scale(to: origSize[movedIndex])
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
    
    func removeNodesWith(name: String) {
        while self.childNode(withName: name) != nil {
            self.childNode(withName: name)!.removeFromParent()
        }
    }

    
    deinit {
        print("\n THE SCENE \((type(of: self))) WAS REMOVED FROM MEMORY (DEINIT) \n")
    }
}

