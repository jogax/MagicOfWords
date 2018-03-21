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
    
    var wtSceneDelegate: WTSceneDelegate?
    var wtGameboard: WTGameboard?
    var wordsToPlay = Array<GameDataModel>()
//    var allWords = String()
    var ownWords = [String]()
    var workingLetters = String()
//    var tilesForGame = [TilesForGame]()
    var tilesForGame = [WTPiece]()
    var indexOfTilesForGame = 0
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
    let letterCounts: [Int:[Int]] = [
        1: [1],
        2: [11, 2],
        3: [3, 21, 111],
        4: [31, 22],
        5: [32, 221]
    ]
    let mandatoryWordsHeaderName = "mandatoryWords"
    let ownWordsHeaderName = "ownWords"

    
    override func didMove(to view: SKView) {
        self.name = "WTScene"
        self.view!.isMultipleTouchEnabled = false
        self.blockSize = self.frame.size.width * (GV.onIpad ? 0.70 : 0.90) / CGFloat(12)

        self.backgroundColor = SKColor(red: 223/255, green: 255/255, blue: 216/255, alpha: 0.8)
//        createMenuItem(menuInt: .tcPackage, firstLine: true)
        createMenuItem(menuInt: .tcBack)
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
                wtGameboard!.checkWholeWords()
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
        menuItem.name = String(menuInt.rawValue)
        menuItem.fontSize = self.frame.size.height / 50
        menuItem.position = CGPoint(x: self.frame.size.width * 0.1, y: startYPosition - (CGFloat(line) * 45) )
        menuItem.fontColor = SKColor.blue
        menuItem.color = UIColor.brown
        self.addChild(menuItem)
    }
    
    private func showWordsToCollect() {
        let wordListToShow = realm.objects(GameDataModel.self).filter("gameType = %d and gameNumber = %d", GV.gameType, GV.gameNumber)[0]
        createLabel(word: GV.language.getText(.tcWordsToCollect, values: "0","0"), first: true, name: mandatoryWordsHeaderName)
        var counter = 1
        let wordList = wordListToShow.words.uppercased().components(separatedBy: "°")
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
        random = MyRandom(gameType: GV.gameType, gameNumber: GV.gameNumber)
        generateArrayOfWordPieces()
        indexOfTilesForGame = 0

        ws = Array(repeating: WTPiece(), count: 3)
        wtGameboard = WTGameboard(size: sizeOfGrid, parentScene: self, delegate: self, mandatoryWords: mandatoryWords)
//        for record in wordsToPlay {
//            allWords += record.word.uppercased()
//        }
        

        for index in 0..<3 {
            ws[index] = generateShape(horizontalPosition: index)
            origPosition[index] = CGPoint(x:self.frame.width * shapeMultiplicator[index], y:self.frame.height * heightMultiplicator)
            origSize[index] = ws[index].size
            ws[index].position = origPosition[index]
//            ws[index].anchorPoint = CGPoint(x: 0.5, y: 0.5)
            ws[index].name = "Pos\(index )"
            self.addChild(ws[index])
        }
        time = 0
        createTimeLabel()
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(countTime(timerX: )), userInfo: nil, repeats: true)
    }
    
    @objc private func countTime(timerX: Timer) {
        time += 1
        timeLabel.text = time.HourMinSec
    }
    
    private func generateArrayOfWordPieces() {
        func getLetters( from: inout [String], archiv: inout [String])->[String] {
            
            if from.count == 0 {
                for item in archiv {
                    from.append(item)
                }
                archiv.removeAll()
            }
            let index = random!.getRandomInt(0, max: from.count - 1)
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
            default: break
            }
        }
        let lengths = [1,1,1,1,2,2,2,2,3,3,3,3,3,3,3,3,4,4,4,4,4,4,4,1,1]
        var generateLength = 0
        repeat {
            let tileLength = lengths[random!.getRandomInt(0, max: lengths.count - 1)]
            var tileType = MyShapes.NotUsed
            var letters = [String]()
            switch tileLength {
            case 1: tileType = typesWithLen1[0]
                letters += getLetters(from: &oneLetterPieces, archiv: &oneLetterPiecesArchiv)
            case 2: tileType = typesWithLen2[0]
                letters += getLetters(from: &twoLetterPieces, archiv: &twoLetterPiecesArchiv)
            case 3: tileType = typesWithLen3[random!.getRandomInt(0, max: typesWithLen3.count - 1)]
                letters += getLetters(from: &twoLetterPieces, archiv: &twoLetterPiecesArchiv)
                letters += getLetters(from: &oneLetterPieces, archiv: &oneLetterPiecesArchiv)
           case 4: tileType = typesWithLen4[random!.getRandomInt(0, max: typesWithLen4.count - 1)]
               letters += getLetters(from: &twoLetterPieces, archiv: &twoLetterPiecesArchiv)
               letters += getLetters(from: &twoLetterPieces, archiv: &twoLetterPiecesArchiv)
            default: break
            }
            let rotateIndex = random!.getRandomInt(0, max: 3)
            
//            let tileForGameItem = TilesForGame(type: tileType, rotateIndex: rotateIndex, letters: letters)
            let tileForGameItem = WTPiece(type: tileType, rotateIndex: rotateIndex, parent: self, blockSize: blockSize, letters: letters)
            tilesForGame.append(tileForGameItem)
            generateLength += tileLength
        } while generateLength < 150

    }
    
    private func generateShape(horizontalPosition: Int)->WTPiece {
//        blockSize = self.frame.size.width * (GV.onIpad ? 0.70 : 0.90) / CGFloat(12)
        let tileForGame = tilesForGame[indexOfTilesForGame]
        indexOfTilesForGame += 1
        indexOfTilesForGame = indexOfTilesForGame >= tilesForGame.count ? 0 : indexOfTilesForGame
//        let type = tileForGame.type
//        let rotateIndex = tileForGame.rotateIndex
//        var letters = [String]()
//        for tiles in tileForGame.letters {
//            for letter in tiles {
//                letters.append(String(letter))
//            }
//        }
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
        let (GCol, GRow, _, _, shapeIndex, _) = analyzeNodes(nodes: nodes)
        if shapeIndex > -1 {
            startShapeIndex = shapeIndex
            wtGameboard!.clear()
        } else if GCol.between(min: 0, max: sizeOfGrid - 1) && GRow.between(min:0, max: sizeOfGrid - 1){
            inChoosingOwnWord = true
            wtGameboard?.startChooseOwnWord(col: GCol, row: GRow)
        }

    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if wtSceneDelegate == nil {
            return
        }
        let firstTouch = touches.first
        let touchLocation = firstTouch!.location(in: self)
        let nodes = self.nodes(at: touchLocation)
        let (GCol, GRow, row, col, shapeIndex, _) = analyzeNodes(nodes: nodes)
        if moved {
            let sprite = ws[movedIndex]
            sprite.position = touchLocation + CGPoint(x: 0, y: blockSize * WSGameboardSizeMultiplier)
            sprite.alpha = 0.0
            if wtGameboard!.moveSpriteOnGameboard(col: col, row: row) {  // true says moving finished
                if row == sizeOfGrid { // when at bottom
                    sprite.alpha = 1.0
                }
            }

        } else if inChoosingOwnWord {
            if GCol >= 0 && GCol < sizeOfGrid && GRow >= 0 && GRow < sizeOfGrid {
                wtGameboard?.moveChooseOwnWord(col: GCol, row: GRow)
            }
        } else {
            if shapeIndex >= 0 {
                ws[shapeIndex].position = touchLocation
            }
            let yDistance = (touchLocation - firstTouchLocation).y
            if yDistance > blockSize && row >= 0 && row < sizeOfGrid {
//                origSize[shapeindex] = ws[index].size
//                moved = true
                if shapeIndex >= 0 {
                    moved = wtGameboard!.startShowingSpriteOnGameboard(shape: ws[shapeIndex], col: col, row: row)
                    movedIndex = shapeIndex
                }
            } 
        }
    
    }

    private func analyzeNodes(nodes: [SKNode])->(GCol: Int, GRow: Int, col: Int, row: Int, shapeIndex: Int, goBack: Bool) {
        var values = (GCol: -1, GRow: -1, col: -1, row: -1, shapeIndex: -1, goBack: false)
        for node in nodes {
            guard let name = node.name else {
                continue
            }
            if name == String(TextConstants.tcBack.rawValue) {
                values.goBack = true
                return values
            }
            if name.begins(with: "GBD") {
                values.GCol = Int(name.subString(startPos: 4, length:1))!
                values.GRow = Int(name.subString(startPos: 6, length:1))!
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
        if wtSceneDelegate == nil {
            return
        }
        let firstTouch = touches.first
        let touchLocation = firstTouch!.location(in: self)
        let nodes = self.nodes(at: touchLocation)
        let lastPosition = ws.count - 1
        let (GCol, GRow, row, col, _, _) = analyzeNodes(nodes: nodes)
        if inChoosingOwnWord {
            wtGameboard?.endChooseOwnWord(col: GCol, row: GRow)
        } else if moved {
            let fixed = wtGameboard!.stopShowingSpriteOnGameboard(col: col, row: row, wordsToCheck: playingWords)
            if fixed {
                let fixedName = "Pos\(movedIndex)"
                removeNodesWith(name: fixedName)
                if movedIndex < lastPosition {
                    for index in movedIndex..<lastPosition {
                        ws[index] = ws[index + 1]
                        ws[index].name = "Pos\(String(index))"
                        ws[index].position = origPosition[index]
                        origSize[index] = ws[index].size
                    }
                }
                ws[lastPosition] = generateShape(horizontalPosition: lastPosition)
                ws[lastPosition].position = origPosition[lastPosition]
                ws[lastPosition].name = "Pos\(lastPosition)"
                self.addChild(ws[lastPosition])
                let freePlaceFound = checkFreePlace()
                
//                for piece in ws {
//                    for rotateIndex in 0..<4 {
//                        freePlaceFound = wtGameboard!.checkFreePlaceForPiece(piece: piece, rotateIndex: rotateIndex)
//                        if freePlaceFound {break}
//                    }
//                    if freePlaceFound {break}
//                }
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
            let (_, _, _, _, shapeIndex, goBack) = analyzeNodes(nodes: nodes)
            if goBack {
                wtSceneDelegate!.gameFinished()
                return
            }
            if shapeIndex >= 0 && startShapeIndex == shapeIndex {
                    ws[shapeIndex].rotate()
                    ws[shapeIndex].position = origPosition[shapeIndex]
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
    
    func removeNodesWith(name: String) {
        while self.childNode(withName: name) != nil {
            self.childNode(withName: name)!.removeFromParent()
        }
    }

    
    deinit {
        print("\n THE SCENE \((type(of: self))) WAS REMOVED FROM MEMORY (DEINIT) \n")
    }
}

