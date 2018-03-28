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
    
    struct OwnWord {
        var word: String = ""
        var creationIndex: Int = 0
        init(word: String = "", creationIndex: Int = 0) {
            self.word = word
            self.creationIndex = creationIndex
        }
        init(from: String) {
            let valueTab = from.components(separatedBy: "-")
            if valueTab.count == 2 {
                word = valueTab[0]
                self.creationIndex = 0
                if let createIndex = Int(valueTab[1]) {
                    self.creationIndex = createIndex
                }
            }
        }
        func toString()->String {
            return word + "-" + String(creationIndex)
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
    var ownWords = [OwnWord]()
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
    var timeLabel = SKLabelNode(fontNamed: "TimesNewRomanPS-BoldMT")
    var headerLabel = SKLabelNode(fontNamed: "TimesNewRomanPS-BoldMT")
    var goBackLabel = SKLabelNode(fontNamed: "TimesNewRomanPS-BoldMT")
    var testCounter = 0
    var firstTouchLocation = CGPoint(x: 0, y: 0)
    var scoreMandatoryWords = 0
    var scoreOwnWords = 0
    var countMandatoryWords = 0
    var countOwnWords = 0
    var playingRecord = GameDataModel()
    var onGameboardIndexes = [String]()
    var roundIndexes = [String]()
    var new: Bool = true

    var ws = [WTPiece]()
    var origPosition: [CGPoint] = Array(repeating: CGPoint(x:0, y: 0), count: 3)
    var origSize: [CGSize] = Array(repeating: CGSize(width:0, height: 0), count: 3)
    var totalScore: Int = 0
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
    let headerName = "header"
    let timeName = "time"
    let gameNumberName = "gameNumber"

    
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
//        createHeader()
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
    
    private func createHeader() {
        if self.childNode(withName: goBackName) == nil {
            let startYPosition = self.frame.height * 0.94
            let fontSize = self.frame.size.height * 0.0175
            goBackLabel = SKLabelNode(fontNamed: "CourierNewPS-BoldMT")// Snell Roundhand")
            goBackLabel.text = GV.language.getText(.tcBack)
            goBackLabel.name = String(goBackName)
            goBackLabel.fontSize = fontSize
            goBackLabel.position = CGPoint(x: self.frame.size.width * 0.1, y: startYPosition )
            headerLabel.horizontalAlignmentMode = .left
            goBackLabel.fontColor = SKColor.blue
            self.addChild(goBackLabel)
        }

        if self.childNode(withName: headerName) == nil {
            let startYPosition = self.frame.height * 0.92
            let fontSize = self.frame.size.height * 0.0175
            let text = GV.language.getText(.tcHeader, values: String(playingRecord.gameNumber + 1), String(0), String(0))
            headerLabel = SKLabelNode(fontNamed: "CourierNewPS-BoldMT")// Snell Roundhand")
            headerLabel.text = text
            headerLabel.name = String(headerName)
            headerLabel.fontSize = fontSize
            headerLabel.position = CGPoint(x: self.frame.size.width * 0.5, y: startYPosition)
            headerLabel.horizontalAlignmentMode = .center
            headerLabel.fontColor = SKColor.black
            self.addChild(headerLabel)
        }
        
        if self.childNode(withName: timeName) == nil {
            timeLabel = SKLabelNode(fontNamed: "CourierNewPS-BoldMT") // Snell Roundhand")
            let yPosition = self.frame.height * 0.94
            let xPosition = self.frame.size.width * 0.8
            timeLabel.position = CGPoint(x: xPosition, y: yPosition)
            timeLabel.fontSize = self.frame.size.height * 0.0175
            timeLabel.fontColor = .black
            timeLabel.text = GV.language.getText(.tcTime, values: time.HourMinSec)
            headerLabel.horizontalAlignmentMode = .right
            timeLabel.name = "TimeLabel"
            self.addChild(timeLabel)
        }
    }
    
    private func modifyHeader() {
        let text = GV.language.getText(.tcHeader, values: String(playingRecord.gameNumber + 1), String(roundIndexes.count), String(totalScore))
        headerLabel.text = text
    }
    

    func showFoundedWords(foundedWordsToShow: [FoundedWordsWithCounter]) {
        self.scoreMandatoryWords = 0
        self.scoreOwnWords = 0
        self.countMandatoryWords = 0
        self.countOwnWords = 0
        
        for foundedWordToShow in foundedWordsToShow {
            if let label = self.childNode(withName: foundedWordToShow.word)! as? SKLabelNode {
                label.text = foundedWordToShow.word + " (\(foundedWordToShow.counter)) "
            }
            if ownWords.contains(where: {$0.word == foundedWordToShow.word}) {
                self.scoreOwnWords += foundedWordToShow.score
                self.countOwnWords += foundedWordToShow.counter
            } else  if mandatoryWords.contains(where: {$0 == foundedWordToShow.word}) {
                self.scoreMandatoryWords += foundedWordToShow.score
                self.countMandatoryWords += foundedWordToShow.counter
            }
            

        }
        totalScore = scoreMandatoryWords + scoreOwnWords
        if let label = self.childNode(withName: mandatoryWordsHeaderName)! as? SKLabelNode {
            label.text = GV.language.getText(.tcWordsToCollect, values: String(countMandatoryWords), String(scoreMandatoryWords))
        }
        if let label = self.childNode(withName: ownWordsHeaderName)! as? SKLabelNode {
            label.text = GV.language.getText(.tcOwnWords, values: String(countOwnWords), String(scoreOwnWords))
        }
        modifyHeader()

    }
    
    
    func addOwnWord(word: String, index: Int) {
        if realm.objects(WordListModel.self).filter("word = %@", word.lowercased()).count == 1 {
            if !ownWords.contains(where: {$0.word == word}) && !playingWords.contains(where: {$0 == word}) {
                let myIndex = (index == NoValue ? indexOfTilesForGame : index)
                ownWords.append(OwnWord(word: word, creationIndex: myIndex))
                wtGameboard!.checkWholeWords(wordsToCheck: playingWords)
                playingWords.append(word)
                var wordToShow = AllWordsToShow(word: word)
                allWordsToShow.append(wordToShow)
                createLabel(wordToShow: &wordToShow, counter: ownWords.count, own: true)
                wtGameboard!.addOwnWordToCheck(word: word)
                wtGameboard!.checkWholeWords(wordsToCheck: playingWords)
            }
        }
    }
    
    func removeOwnWord(index: Int) {
        let word = ownWords[index].word
        wtGameboard!.removeOwnWordToCheck(word: word)
        if let playingIndex = playingWords.index(where: {$0 == word}) {
            playingWords.remove(at: playingIndex)
        }
        ownWords.remove(at: index)
        removeNodesWith(name: word)

    }

    private func addOwnWord(ownWord: OwnWord) {
        addOwnWord(word: ownWord.word, index: ownWord.creationIndex)
    }
    
    var line = 0

 private func createUndo() {
        undoSprite = SKSpriteNode(imageNamed: "undo.png")
        let yPosition = self.frame.height * 0.95
        let xPosition = self.frame.width * 0.95
        undoSprite.position = CGPoint(x:xPosition, y:yPosition)
        undoSprite.alpha = 0.2
        undoSprite.size = CGSize(width: self.frame.width * 0.08, height: self.frame.width * 0.08)
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
        let mandatoryYPositionMultiplier:CGFloat = 0.88
        let ownYPositionMultiplier:CGFloat = 0.80
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
        wordToShow.wordLabel.fontSize = self.frame.size.height * 0.0175
        wordToShow.wordLabel.fontColor = .black
        wordToShow.wordLabel.text = wordToShow.word + " (\(wordToShow.countFounded))"
        wordToShow.wordLabel.name = wordToShow.word
        
        self.addChild(wordToShow.wordLabel)
    }
    
    private func createLabel(word: String, first: Bool, name: String) {
        let label = SKLabelNode(fontNamed: "TimesNewRomanPS-BoldMT") // Snell Roundhand")
        let yPosition = self.frame.height * (first ? 0.90 : 0.82)
        let xPosition = self.frame.size.width * 0.5
        label.position = CGPoint(x: xPosition, y: yPosition)
        label.fontSize = self.frame.size.height * 0.0175
        label.fontColor = .black
        label.text = word
        label.name = name
        self.addChild(label)
    }
    
    private func play() {
        time = 0
        createHeader()
        wtGameboard = WTGameboard(size: sizeOfGrid, parentScene: self, delegate: self, mandatoryWords: mandatoryWords)
        generateArrayOfWordPieces(new: new)
        indexOfTilesForGame = 0
        ws = Array(repeating: WTPiece(), count: 3)
        for index in 0..<3 {
            origPosition[index] = CGPoint(x:self.frame.width * shapeMultiplicator[index], y:self.frame.height * heightMultiplicator)
        }
        if !new {
            let words = playingRecord.ownWords.components(separatedBy: "°")
            for item in words {
                if item.count > 0 {
                    addOwnWord(ownWord: OwnWord(from: item))
                }
            }
            restoreGameArray()
        } else {
            ws = Array(repeating: WTPiece(), count: 3)
            roundIndexes.append("0")
            for index in 0..<3 {
                ws[index] = getNextPiece(horizontalPosition: index)
                origSize[index] = ws[index].size
                ws[index].position = origPosition[index]
                ws[index].name = "Pos\(index)"
                self.addChild(ws[index])
            }
        }
        modifyHeader()
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(countTime(timerX: )), userInfo: nil, repeats: true)
    }
    
    @objc private func countTime(timerX: Timer) {
        time += 1
        timeLabel.text = GV.language.getText(.tcTime, values: time.HourMinSec)
        realm.beginWrite()
        playingRecord.time = String(time)
        try! realm.commitWrite()
    }
    
    private func generateArrayOfWordPieces(new: Bool) {
        if new {
            realm.beginWrite()
            playingRecord.pieces = generateArrayOfWordPieces()
            try! realm.commitWrite()
        }
        tilesForGame.removeAll()
        let piecesToPlay = playingRecord.pieces.components(separatedBy: "°")
        for index in 0..<piecesToPlay.count {
            let piece = piecesToPlay[index]
            if piece.count > 0 {
                let tile = WTPiece(from: piece, parent: self, blockSize: blockSize, arrayIndex: index)
                tilesForGame.append(tile)
                tilesForGame.last!.addArrayIndex(index: index)
//                if new {
//                    tilesForGame.last!.reset()
//                }
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
        let touchedNodes = analyzeNodes(nodes: nodes, calledFrom: .start)
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
        let touchedNodes = analyzeNodes(nodes: nodes, calledFrom: .move)
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
    
    enum CalledFrom: Int {
        case start = 0, move, stop
    }

    private func analyzeNodes(nodes: [SKNode], calledFrom: CalledFrom)->TouchedNodes {
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
                case "Pos":
                    if calledFrom == .start || startShapeIndex == number {
                        touchedNodes.shapeIndex = number
                    }
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
        let touchedNodes = analyzeNodes(nodes: nodes, calledFrom: .stop)
        if touchedNodes.undo {
            startUndo()
            saveActualState()
        }
        if inChoosingOwnWord {
            wtGameboard?.endChooseOwnWord(col: touchedNodes.GCol, row: touchedNodes.GRow)
            saveActualState()
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

                if !freePlaceFound || testCounter >= 10000 {
                    wtGameboard!.clearGreenFieldsForNextRound()
                    if !checkFreePlace() || testCounter >= 10000 {
                        print("game is finished!")
                        let size = CGSize(width: self.frame.width * 0.8, height: self.frame.height * 0.8)
                        let position = CGPoint(x: self.frame.midX, y: self.frame.midY)
                        let gameFinishedSprite = WTGameFinished(size: size, position: position, delegate: self)
                        self.addChild(gameFinishedSprite)
                        gameFinishedSprite.showFinish()
                        realm.beginWrite()
                        playingRecord.gameStatus = GameStatusFinished
                        try! realm.commitWrite()
                    } else {
                        roundIndexes.append(String(indexOfTilesForGame))
                        modifyHeader()
                    }
                }
               saveActualState()
               testCounter += 1
            } else {
                ws[movedIndex].position = origPosition[movedIndex]
//                ws[movedIndex].scale(to: origSize[movedIndex])
                ws[movedIndex].alpha = 1
            }
            moved = false
        } else if nodes.count > 0 {
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
    
    private func saveActualState() {
        var pieces = ""
        for tile in tilesForGame {
            pieces += tile.toString() + "°"
        }
        var tempOwnWords = ""
        for item in ownWords {
            tempOwnWords += item.toString() + "°"
        }
        realm.beginWrite()
        playingRecord.ownWords = tempOwnWords
        playingRecord.pieces = pieces
        playingRecord.gameStatus = GameStatusPlaying
        var roundIndexesString = ""
        for index in 0..<roundIndexes.count {
            roundIndexesString += roundIndexes[index] + "°"
        }
        roundIndexesString.removeLast()
        playingRecord.roundIndexes = roundIndexesString
        try! realm.commitWrite()
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
                    tileForGame.resetGameArrayPositions()
                    indexOfTilesForGame -= 1
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
                var doing = true
                repeat {
                    if let index = ownWords.index(where: {$0.creationIndex > indexOfTilesForGame}) {
                        removeOwnWord(index: index)
                    } else {
                        doing = false
                    }
                } while doing
                wtGameboard!.checkWholeWords(wordsToCheck: playingWords)
                onGameboardIndexes.removeLast()
                if onGameboardIndexes.count == 0 {
                    undoSprite.alpha = 0.1
                }
            } 
        }
    }
    
    func restoreGameArray() {
        func addPieceAsChild(pieceIndex: Int, piece: WTPiece) {
            ws[pieceIndex] = piece
            ws[pieceIndex].position = origPosition[pieceIndex]
            origSize[pieceIndex] = piece.size
            ws[pieceIndex].name = "Pos\(pieceIndex )"
            self.addChild(ws[pieceIndex])

        }
        roundIndexes.removeAll()
        onGameboardIndexes.removeAll()
        roundIndexes = playingRecord.roundIndexes.components(separatedBy: "°")
        for index in 0..<tilesForGame.count {
            if roundIndexes.contains(String(index)) {
                print("hier resetgreens!")
                wtGameboard!.checkWholeWords(wordsToCheck: playingWords)
                wtGameboard!.clearGreenFieldsForNextRound()
            }
            let tileForGame = tilesForGame[index]
            if tileForGame.isOnGameboard {
                onGameboardIndexes.append(String(index))
                wtGameboard!.showPieceOnGameArray(piece: tileForGame)
            } else {
                if tileForGame.pieceFromPosition >= 0 {
                    let pieceIndex = tileForGame.pieceFromPosition
                    addPieceAsChild(pieceIndex: pieceIndex, piece: tileForGame)
                } else {
                    indexOfTilesForGame = index
                    break
                }
            }
        }
        if onGameboardIndexes.count > 0 {
            undoSprite.alpha = 1.0
        }
        if let iTime = Int(playingRecord.time) {
            time = iTime
        } else {
            time = 0
        }
        wtGameboard!.checkWholeWords(wordsToCheck: playingWords)
    }
    
    private func generateArrayOfWordPieces()->String {
        let gameType = playingRecord.gameType
        let gameNumber =  playingRecord.gameNumber
        let words = playingRecord.mandatoryWords.components(separatedBy: "°")
        let blockSize = frame.size.width * (GV.onIpad ? 0.70 : 0.90) / CGFloat(12)
        let random = MyRandom(gameType: gameType, gameNumber: gameNumber)
        func getLetters( from: inout [String], archiv: inout [String])->[String] {
            
            if from.count == 0 {
                for item in archiv {
                    from.append(item)
                }
                archiv.removeAll()
            }
            let index = random.getRandomInt(0, max: from.count - 1)
            let temp = from[index]
            var piece = [String]()
            piece.append(temp.subString(startPos:0, length: 1))
            if temp.count == 2 {
                piece.append(temp.subString(startPos:1, length: 1))
            }
            archiv.append(temp)
            from.remove(at: index)
            return piece
        }
        tilesForGame.removeAll()
        var oneLetterPieces = [String]()
        var oneLetterPiecesArchiv = [String]()
        var twoLetterPieces = [String]()
        var twoLetterPiecesArchiv = [String]()
        for word in words {
            for letter in word {
                oneLetterPieces.append(String(letter).uppercased())
            }
            for index in 0..<word.count - 1 {
                twoLetterPieces.append(word.subString(startPos: index, length: 2).uppercased())
            }
        }
        var typesWithLen1 = [MyShapes]()
        var typesWithLen2 = [MyShapes]()
        var typesWithLen3 = [MyShapes]()
        var typesWithLen4 = [MyShapes]()
        
        for index in 0..<MyShapes.count - 1 {
            guard let type = MyShapes(rawValue: index) else {
                return ""
            }
            let length = myForms[type]![0].count
            switch length {
            case 1: typesWithLen1.append(type)
            case 2: typesWithLen2.append(type)
            case 3: typesWithLen3.append(type)
            case 4: typesWithLen4.append(type)
            default: break
            }
        }
        let lengths = [1,1,1,1,2,2,2,3,3,4]
        var generateLength = 0
        repeat {
            let tileLength = lengths[random.getRandomInt(0, max: lengths.count - 1)]
            var tileType = MyShapes.NotUsed
            var letters = [String]()
            switch tileLength {
            case 1: tileType = typesWithLen1[0]
            letters += getLetters(from: &oneLetterPieces, archiv: &oneLetterPiecesArchiv)
            case 2: tileType = typesWithLen2[0]
            letters += getLetters(from: &twoLetterPieces, archiv: &twoLetterPiecesArchiv)
            case 3: tileType = typesWithLen3[random.getRandomInt(0, max: typesWithLen3.count - 1)]
            letters += getLetters(from: &twoLetterPieces, archiv: &twoLetterPiecesArchiv)
            letters += getLetters(from: &oneLetterPieces, archiv: &oneLetterPiecesArchiv)
            case 4: tileType = typesWithLen4[random.getRandomInt(0, max: typesWithLen4.count - 1)]
            letters += getLetters(from: &twoLetterPieces, archiv: &twoLetterPiecesArchiv)
            letters += getLetters(from: &twoLetterPieces, archiv: &twoLetterPiecesArchiv)
            default: break
            }
            let rotateIndex = random.getRandomInt(0, max: 3)
            
            //            let tileForGameItem = TilesForGame(type: tileType, rotateIndex: rotateIndex, letters: letters)
            let tileForGameItem = WTPiece(type: tileType, rotateIndex: rotateIndex, parent: self, blockSize: blockSize, letters: letters)
            tilesForGame.append(tileForGameItem)
            generateLength += tileLength
        } while generateLength < 500
        var generatedArrayInStringForm = ""
        for tile in tilesForGame {
            generatedArrayInStringForm += tile.toString() + "°"
        }
        return generatedArrayInStringForm
    }
    

    
    deinit {
        print("\n THE SCENE \((type(of: self))) WAS REMOVED FROM MEMORY (DEINIT) \n")
    }
}

