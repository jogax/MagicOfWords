//
//  CollectWordsScene.swift
//  MagicOfWords
//
//  Created by Jozsef Romhanyi on 06/02/2018.
//  Copyright © 2018 Jozsef Romhanyi. All rights reserved.
//

import Foundation
import GameplayKit
public protocol WTSceneDelegate: class {
    
    /// Method called when Game finished
    func gameFinished()
    
}

struct WTResults {
    var countMandatoryWords: Int
    var scoreMandatoryWords: Int
    var countOwnWords: Int
    var scoreOwnWords: Int
    var countUsedLetters: Int
    var scoreUsedLetters: Int
    var allAroundScore: Int
    init(countMandatoryWords: Int,
         scoreMandatoryWords: Int,
         countOwnWords: Int,
         scoreOwnWords: Int,
         countUsedLetters: Int,
         scoreUsedLetters: Int,
         allAroundScore: Int) {
        self.countMandatoryWords = countMandatoryWords
        self.scoreMandatoryWords = scoreMandatoryWords
        self.countOwnWords = countOwnWords
        self.scoreOwnWords = scoreOwnWords
        self.countUsedLetters = countUsedLetters
        self.scoreUsedLetters = scoreUsedLetters
        self.allAroundScore = allAroundScore
    }

}
class WTScene: SKScene, WTGameboardDelegate, WTGameFinishedDelegate {
//    struct TilesForGame {
//        var type: MyShapes = .NotUsed
//        var rotateIndex: Int = 0
//        var letters: [String] = [String]()
//    }
    
    struct AllWordsToShow {
        var word: String
        var countFounded: Int {
            didSet {
                wordLabel.text = self.word + " (\(self.countFounded))"
            }
        }
        var wordLabel: SKLabelNode
        init(word: String) {
            self.word = word
            countFounded = 0
            wordLabel = SKLabelNode()
        }
    }
    
    struct TouchedNodes {
        var goBack = false
        var undo = false
        var GCol = NoValue
        var GRow = NoValue
        var col = NoValue
        var row = NoValue
        var shapeIndex = NoValue
    }
    
    var wtSceneDelegate: WTSceneDelegate?
    var wtGameboard: WTGameboard?
//    var wordsToPlay = Array<GameDataModel>()
//    var allWords = String()
    var ownWords = [String]()
    var workingLetters = String()
//    var tilesForGame = [TilesForGame]()
    var tilesForGame = [WTPiece]()
    var indexOfTilesForGame = 0
    var undoTouched = false
    var playingWords = [String]()
    var mandatoryWords = [String]()
    var grid: Grid?
    let heightMultiplicator = CGFloat((GV.onIpad ? 0.10 : 0.15))
    var blockSize: CGFloat = 0
    var random: MyRandom?
    var allWordsToShow = [AllWordsToShow]()
    var time: Int = 0
    var timer = Timer()
    var timeLabel = SKLabelNode(fontNamed: "Noteworthy-Bold")
    var testCounter = 0
    var firstTouchLocation = CGPoint(x: 0, y: 0)
    var scoreMandatoryWords = 0
    var scoreOwnWords = 0
    var countMandatoryWords = 0
    var countOwnWords = 0
    var playingRecord = GameDataModel()
    var onGameboardIndexes = [String]()
    var new: Bool = true

    var ws = [WTPiece]()
    var origPosition: [CGPoint] = Array(repeating: CGPoint(x:0, y: 0), count: 3)
    var origSize: [CGSize] = Array(repeating: CGSize(width:0, height: 0), count: 3)
    var score: Int = 0
    var moved = false
    var inChoosingOwnWord = false
    var movedIndex = 0
    var startShapeIndex = 0
    let shapeMultiplicator = [CGFloat(0.20), CGFloat(0.50), CGFloat(0.80)]
    let sizeOfGrid = 10
    var undoSprite = SKSpriteNode()
    let letterCounts: [Int:[Int]] = [
        1: [1],
        2: [11, 2],
        3: [3, 21, 111],
        4: [31, 22],
        5: [32, 221]
    ]
    let mandatoryWordsHeaderName = "mandatoryWords"
    let ownWordsHeaderName = "ownWords"
    let undoName = "undo"
    let goBackName = "goBack"

    
    override func didMove(to view: SKView) {
        self.name = "WTScene"
        self.view!.isMultipleTouchEnabled = false
        self.blockSize = self.frame.size.width * (GV.onIpad ? 0.70 : 0.90) / CGFloat(12)

        self.backgroundColor = SKColor(red: 223/255, green: 255/255, blue: 216/255, alpha: 0.8)
        let searchStatus = new ? GameStatusNew : GameStatusPlaying
        let games = realm.objects(GameDataModel.self).filter("gameType = %d and gameStatus = %d", GV.gameType, searchStatus)
        if games.count > 0 {
            playingRecord = games[0]
        }
        createMenuItem(menuInt: .tcBack)
        createUndo()
        showWordsToCollect()
        play()
   }
    /// WTGameFinishedDelegate
    func getResults() -> WTResults {
        let wtResults = wtGameboard!.getResults()
        return wtResults
    }
    

    public func setDelegate(delegate: WTSceneDelegate) {
        wtSceneDelegate = delegate
    }
    
    public func setGameArt(new: Bool) {
        self.new = new
    }

    func showFoundedWords(foundedWordsToShow: [FoundedWordsWithCounter]) {
        self.scoreMandatoryWords = 0
        self.scoreOwnWords = 0
        self.countMandatoryWords = 0
        self.countOwnWords = 0
        
        for foundedWordToShow in foundedWordsToShow {
            print(foundedWordToShow.word)
            if let label = self.childNode(withName: foundedWordToShow.word)! as? SKLabelNode {
                label.text = foundedWordToShow.word + " (\(foundedWordToShow.counter)) "
            }
            if playingWords.contains(where: {$0 == foundedWordToShow.word}) {
                self.scoreMandatoryWords += foundedWordToShow.score
                self.countMandatoryWords += foundedWordToShow.counter
            }
            
            if ownWords.contains(where: {$0 == foundedWordToShow.word}) {
                self.scoreOwnWords += foundedWordToShow.score
                self.countOwnWords += foundedWordToShow.counter
            }
        }
        if let label = self.childNode(withName: mandatoryWordsHeaderName)! as? SKLabelNode {
            label.text = GV.language.getText(.tcWordsToCollect, values: String(countMandatoryWords), String(scoreMandatoryWords))
        }
        if let label = self.childNode(withName: ownWordsHeaderName)! as? SKLabelNode {
            label.text = GV.language.getText(.tcOwnWords, values: String(countOwnWords), String(scoreOwnWords))
        }

    }
    
    
    func addOwnWord(word: String) {
        if realm.objects(WordListModel.self).filter("word = %@", word.lowercased()).count == 1 {
            if !ownWords.contains(where: {$0 == word}) && !playingWords.contains(where: {$0 == word}) {
                ownWords.append(word)
                playingWords.append(word)
                var wordToShow = AllWordsToShow(word: word)
                allWordsToShow.append(wordToShow)
                createLabel(wordToShow: &wordToShow, counter: ownWords.count, own: true)
                wtGameboard!.addOwnWordToCheck(word: word)
                wtGameboard!.checkWholeWords(wordsToCheck: playingWords)
            }
        } else {
            print ("Word \(word) not OK")
        }
    }
    

    
    

    var line = 0

    private func createMenuItem(menuInt: TextConstants, firstLine: Bool = false) {
        line = firstLine ? 1 : line + 1
        let menuItem = SKLabelNode(fontNamed: "Noteworthy")// Snell Roundhand")
        let startYPosition = self.frame.height * 0.98
        menuItem.text = GV.language.getText(menuInt)
        menuItem.name = String(goBackName)
        menuItem.fontSize = self.frame.size.height / 50
        menuItem.position = CGPoint(x: self.frame.size.width * 0.1, y: startYPosition - (CGFloat(line) * 45) )
        menuItem.fontColor = SKColor.blue
        menuItem.color = UIColor.brown
        self.addChild(menuItem)
    }
    
    private func createUndo() {
        undoSprite = SKSpriteNode(imageNamed: "undo.png")
        let yPosition = self.frame.height * 0.05
        let xPosition = self.frame.width * 0.9
        undoSprite.position = CGPoint(x:xPosition, y:yPosition)
        undoSprite.alpha = 0.2
        undoSprite.size = CGSize(width: self.frame.width * 0.1, height: self.frame.width * 0.1)
        undoSprite.name = undoName
        self.addChild(undoSprite)
    }
    
    private func showWordsToCollect() {
        createLabel(word: GV.language.getText(.tcWordsToCollect, values: "0","0"), first: true, name: mandatoryWordsHeaderName)
        var counter = 1
        let wordList = playingRecord.mandatoryWords.uppercased().components(separatedBy: "°")
        for word in wordList {
            mandatoryWords.append(word)
            playingWords.append(word)
            var wordToShow = AllWordsToShow(word: word)
            allWordsToShow.append(wordToShow)
            createLabel(wordToShow: &wordToShow, counter: counter)
            counter += 1
        }
        createLabel(word: GV.language.getText(.tcOwnWords, values: "0", "0"), first: false, name: ownWordsHeaderName)
    }
    
    private func createLabel(wordToShow: inout AllWordsToShow, counter: Int, own: Bool = false) {
        let xPositionMultiplier = [0.2, 0.5, 0.8]
        let mandatoryYPositionMultiplier:CGFloat = 0.89
        let ownYPositionMultiplier:CGFloat = 0.81
        let distance: CGFloat = 0.02
        wordToShow.wordLabel = SKLabelNode(fontNamed: "TimesNewRomanPS-BoldMT")// Snell Roundhand")
        let value = CGFloat((counter - 1) / 3) *  distance
        var yPosition: CGFloat = 0
        if !own {
            yPosition = self.frame.height * (mandatoryYPositionMultiplier - value)
        } else {
            yPosition = self.frame.height * (ownYPositionMultiplier - value)
        }
        let xPosition = self.frame.size.width * CGFloat(xPositionMultiplier[(counter - 1) % 3])
        wordToShow.wordLabel.position = CGPoint(x: xPosition, y: yPosition)
        wordToShow.wordLabel.fontSize = self.frame.size.height / (counter == 0 ? 50 : 50)
        wordToShow.wordLabel.fontColor = .black
        wordToShow.wordLabel.text = wordToShow.word + " (\(wordToShow.countFounded))"
        wordToShow.wordLabel.name = wordToShow.word
        
        self.addChild(wordToShow.wordLabel)
    }
    
    private func createLabel(word: String, first: Bool, name: String) {
        let label = SKLabelNode(fontNamed: "TimesNewRomanPS-BoldMT") // Snell Roundhand")
        let yPosition = self.frame.height * (first ? 0.92 : 0.84)
        let xPosition = self.frame.size.width * 0.5
        label.position = CGPoint(x: xPosition, y: yPosition)
        label.fontSize = self.frame.size.height * 0.02
        label.fontColor = .black
        label.text = word
        label.name = name
        self.addChild(label)
    }
    
    private func createTimeLabel() {
        timeLabel = SKLabelNode(fontNamed: "TimesNewRomanPS-BoldMT") // Snell Roundhand")
        let yPosition = self.frame.height * 0.94
        let xPosition = self.frame.size.width * 0.8
        timeLabel.position = CGPoint(x: xPosition, y: yPosition)
        timeLabel.fontSize = self.frame.size.height * 0.015
        timeLabel.fontColor = .black
        timeLabel.text = 0.HourMinSec
        timeLabel.name = "TimeLabel"
        self.addChild(timeLabel)
    }
    


    
    private func play() {
//        random = MyRandom(gameType: GV.gameType, gameNumber: GV.gameNumber)
        
        wtGameboard = WTGameboard(size: sizeOfGrid, parentScene: self, delegate: self, mandatoryWords: mandatoryWords)
        generateArrayOfWordPieces(new: new)
        indexOfTilesForGame = 0
        ws = Array(repeating: WTPiece(), count: 3)
        for index in 0..<3 {
            origPosition[index] = CGPoint(x:self.frame.width * shapeMultiplicator[index], y:self.frame.height * heightMultiplicator)
        }
        if !new {
            ownWords = playingRecord.ownWords.components(separatedBy: "°")
            restoreGameArray()
        } else {
            ws = Array(repeating: WTPiece(), count: 3)
            for index in 0..<3 {
                ws[index] = getNextPiece(horizontalPosition: index)
                origSize[index] = ws[index].size
                ws[index].position = origPosition[index]
                ws[index].name = "Pos\(index )"
                self.addChild(ws[index])
            }
        }
        time = 0
        createTimeLabel()
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(countTime(timerX: )), userInfo: nil, repeats: true)
    }
    
    @objc private func countTime(timerX: Timer) {
        time += 1
        timeLabel.text = time.HourMinSec
    }
    
    private func generateArrayOfWordPieces(new: Bool) {
        let piecesToPlay = playingRecord.pieces.components(separatedBy: "°")
        for index in 0..<piecesToPlay.count {
            let piece = piecesToPlay[index]
            if piece.count > 0 {
                tilesForGame.append(WTPiece(from: piece, parent: self, blockSize: blockSize))
                tilesForGame.last!.addArrayIndex(index: index)
                if new {
                    tilesForGame.last!.reset()
                }
            }
        }
//        let playingWords = playingRecord.pieces.components(separatedBy: "°")
    }
    
    private func getNextPiece(horizontalPosition: Int)->WTPiece {
//        blockSize = self.frame.size.width * (GV.onIpad ? 0.70 : 0.90) / CGFloat(12)
        let tileForGame = tilesForGame[indexOfTilesForGame]
        indexOfTilesForGame += 1
        indexOfTilesForGame = indexOfTilesForGame >= tilesForGame.count ? 0 : indexOfTilesForGame
        return tileForGame

    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if wtSceneDelegate == nil {
            return
        }
        moved = false
        inChoosingOwnWord = false
        let firstTouch = touches.first
        firstTouchLocation = firstTouch!.location(in: self)
        let nodes = self.nodes(at: firstTouchLocation)
        let touchedNodes = analyzeNodes(nodes: nodes)
        if touchedNodes.undo {
            undoTouched = true
        }
        if touchedNodes.shapeIndex > NoValue {
            startShapeIndex = touchedNodes.shapeIndex
            wtGameboard!.clear()
        } else if touchedNodes.GCol.between(min: 0, max: sizeOfGrid - 1) && touchedNodes.GRow.between(min:0, max: sizeOfGrid - 1){
            inChoosingOwnWord = true
            wtGameboard?.startChooseOwnWord(col: touchedNodes.GCol, row: touchedNodes.GRow)
        }

    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if wtSceneDelegate == nil {
            return
        }
        let firstTouch = touches.first
        let touchLocation = firstTouch!.location(in: self)
        let nodes = self.nodes(at: touchLocation)
        let touchedNodes = analyzeNodes(nodes: nodes)
        if moved {
            let sprite = ws[movedIndex]
            sprite.position = touchLocation + CGPoint(x: 0, y: blockSize * WSGameboardSizeMultiplier)
            sprite.alpha = 0.0
            if wtGameboard!.moveSpriteOnGameboard(col: touchedNodes.col, row: touchedNodes.row) {  // true says moving finished
                if touchedNodes.row == sizeOfGrid { // when at bottom
                    sprite.alpha = 1.0
                }
            }

        } else if inChoosingOwnWord {
            if touchedNodes.GCol >= 0 && touchedNodes.GCol < sizeOfGrid && touchedNodes.GRow >= 0 && touchedNodes.GRow < sizeOfGrid {
                wtGameboard?.moveChooseOwnWord(col: touchedNodes.GCol, row: touchedNodes.GRow)
            }
        } else {
            if touchedNodes.shapeIndex >= 0 {
                ws[touchedNodes.shapeIndex].position = touchLocation
            }
            let yDistance = (touchLocation - firstTouchLocation).y
            if yDistance > blockSize && touchedNodes.row >= 0 && touchedNodes.row < sizeOfGrid {
//                origSize[shapeindex] = ws[index].size
//                moved = true
                if touchedNodes.shapeIndex >= 0 {
                    moved = wtGameboard!.startShowingSpriteOnGameboard(shape: ws[touchedNodes.shapeIndex], col: touchedNodes.col, row: touchedNodes.row, shapePos: touchedNodes.shapeIndex)
                    movedIndex = touchedNodes.shapeIndex
                }
            } 
        }
    
    }

    private func analyzeNodes(nodes: [SKNode])->TouchedNodes {
        var touchedNodes = TouchedNodes()
        for node in nodes {
            guard let name = node.name else {
                continue
            }
            if name == goBackName {
                touchedNodes.goBack = true
            } else if name == undoName {
                touchedNodes.undo = true
            } else if name.begins(with: "GBD") {
                touchedNodes.GCol = Int(name.subString(startPos: 4, length:1))!
                touchedNodes.GRow = Int(name.subString(startPos: 6, length:1))!
            } else if let number = Int(name.subString(startPos: 3, length: name.count - 3)) {
                switch name.subString(startPos: 0, length: 3) {
                case "Col": touchedNodes.col = number
                case "Row": touchedNodes.row = number
                case "Pos": touchedNodes.shapeIndex = number
                default: continue
                }
            }
        }
        return touchedNodes
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if wtSceneDelegate == nil {
            return
        }
        let firstTouch = touches.first
        let touchLocation = firstTouch!.location(in: self)
        let nodes = self.nodes(at: touchLocation)
        let lastPosition = ws.count - 1
        let touchedNodes = analyzeNodes(nodes: nodes)
        if touchedNodes.undo {
            startUndo()
        }
        if inChoosingOwnWord {
            wtGameboard?.endChooseOwnWord(col: touchedNodes.GCol, row: touchedNodes.GRow)
            var tempOwnWords = ""
            for word in ownWords {
                tempOwnWords += word + "°"
            }
            realm.beginWrite()
            playingRecord.ownWords = tempOwnWords
            try! realm.commitWrite()

        } else if moved {
            let fixed = wtGameboard!.stopShowingSpriteOnGameboard(col: touchedNodes.col, row: touchedNodes.row, wordsToCheck: playingWords)
            if fixed {
                ws[movedIndex].setPieceFromPosition(index: movedIndex)
                onGameboardIndexes.append(ws[movedIndex].getArrayIndex())
                undoSprite.alpha = 1.0
                let fixedName = "Pos\(movedIndex)"
                removeNodesWith(name: fixedName)
                if movedIndex < lastPosition {
                    for index in movedIndex..<lastPosition {
                        ws[index] = ws[index + 1]
                        ws[index].name = "Pos\(String(index))"
                        ws[index].position = origPosition[index]
                        ws[index].setPieceFromPosition(index: index)
                        origSize[index] = ws[index].size
                    }
                }
                ws[lastPosition] = getNextPiece(horizontalPosition: lastPosition)
                ws[lastPosition].position = origPosition[lastPosition]
                ws[lastPosition].name = "Pos\(lastPosition)"
                ws[lastPosition].setPieceFromPosition(index: lastPosition)
                self.addChild(ws[lastPosition])
                let freePlaceFound = checkFreePlace()
                var pieces = ""
                for tile in tilesForGame {
                    pieces += tile.toString() + "°"
                }
                var tempOwnWords = ""
                for word in ownWords {
                    tempOwnWords += word + "°"
                }
                realm.beginWrite()
                playingRecord.ownWords = tempOwnWords
                playingRecord.pieces = pieces
                playingRecord.gameStatus = GameStatusPlaying
                try! realm.commitWrite()

                if !freePlaceFound || testCounter >= 10000 {
                    wtGameboard!.clearGreenFieldsForNextRound()
                    if !checkFreePlace() || testCounter >= 10000 {
                        print("game is finished!")
                        let size = CGSize(width: self.frame.width * 0.8, height: self.frame.height * 0.8)
                        let position = CGPoint(x: self.frame.midX, y: self.frame.midY)
                        let gameFinishedSprite = WTGameFinished(size: size, position: position, delegate: self)
                        self.addChild(gameFinishedSprite)
                        gameFinishedSprite.showFinish()
                    }
                }
                testCounter += 1
            } else {
                ws[movedIndex].position = origPosition[movedIndex]
//                ws[movedIndex].scale(to: origSize[movedIndex])
                ws[movedIndex].alpha = 1
            }
            moved = false
        } else if nodes.count > 0 {
            let touchedNodes = analyzeNodes(nodes: nodes)
            if touchedNodes.goBack {
                wtSceneDelegate!.gameFinished()
                return
            }
            if touchedNodes.shapeIndex >= 0 && startShapeIndex == touchedNodes.shapeIndex {
                    ws[touchedNodes.shapeIndex].rotate()
                    ws[touchedNodes.shapeIndex].position = origPosition[touchedNodes.shapeIndex]
            }
            
        }
    }
    
    private func checkFreePlace()->Bool {
        var placeFound = true
        for piece in ws {
            for rotateIndex in 0..<4 {
                placeFound = wtGameboard!.checkFreePlaceForPiece(piece: piece, rotateIndex: rotateIndex)
                if placeFound {break}
            }
            if placeFound {break}
        }
        return placeFound
    }
    
    private func removeNodesWith(name: String) {
        while self.childNode(withName: name) != nil {
            self.childNode(withName: name)!.removeFromParent()
        }
    }
    
    private func startUndo() {
        func movePieceToPosition(from: WTPiece, to: Int, remove: Bool = false) {
            if remove {
                ws[to].removeFromParent()
                ws[to].reset()
            }
            ws[to] = from
            ws[to].name = "Pos\(String(to))"
            ws[to].position = origPosition[to]
            ws[to].setPieceFromPosition(index: to)
            origSize[to] = ws[to].size
        }
        if onGameboardIndexes.count > 0 {
            if let indexOfLastPiece = Int(onGameboardIndexes.last!) {
                let tileForGame = tilesForGame[indexOfLastPiece]
                if tileForGame.isOnGameboard {
                    wtGameboard!.removeFromGameboard(sprite: tileForGame)
                    wtGameboard!.checkWholeWords(wordsToCheck: playingWords)
                    tileForGame.resetGameArrayPositions()
                    switch tileForGame.pieceFromPosition {
                    case 0:
                        movePieceToPosition(from: ws[1], to: 2, remove: true)
                        movePieceToPosition(from: ws[0], to: 1)
                        movePieceToPosition(from: tileForGame, to: 0)
                        tileForGame.alpha = 1.0
                        self.addChild(ws[0])
                    case 1:
                        movePieceToPosition(from: ws[1], to: 2, remove: true)
                        movePieceToPosition(from: tileForGame, to: 1)
                        tileForGame.alpha = 1.0
                        self.addChild(ws[1])
                    case 2:
                        movePieceToPosition(from: tileForGame, to: 2, remove: true)
                        tileForGame.alpha = 1.0
                        self.addChild(ws[2])
                    default: break
                    }
                }
                onGameboardIndexes.removeLast()
                if onGameboardIndexes.count == 0 {
                    undoSprite.alpha = 0.1
                }
            } 
        }
    }
    
    func restoreGameArray() {
        onGameboardIndexes.removeAll()
        for index in 0..<tilesForGame.count {
            let tileForGame = tilesForGame[index]
            if tileForGame.isOnGameboard {
                onGameboardIndexes.append(String(index))
                wtGameboard!.showPieceOnGameArray(piece: tileForGame)
            } else {
                if tileForGame.pieceFromPosition >= 0 {
                    let pieceIndex = tileForGame.pieceFromPosition
                    ws[pieceIndex] = tileForGame
                    ws[pieceIndex].position = origPosition[pieceIndex]
                    origSize[pieceIndex] = tileForGame.size
                    ws[pieceIndex].name = "Pos\(pieceIndex )"
                    self.addChild(ws[pieceIndex])
                } else {
                    indexOfTilesForGame = index
                    break
                }
            }
        }
        if onGameboardIndexes.count > 0 {
            undoSprite.alpha = 1.0
        }
        wtGameboard!.checkWholeWords(wordsToCheck: playingWords)
    }
    

    
    deinit {
        print("\n THE SCENE \((type(of: self))) WAS REMOVED FROM MEMORY (DEINIT) \n")
    }
}

