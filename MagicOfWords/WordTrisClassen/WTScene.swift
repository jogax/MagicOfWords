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
    func gameFinished(start: Int)
    
}

struct WTResults {
    var countMandatoryWords: Int
    var scoreMandatoryWords: Int
    var countOwnWords: Int
    var scoreOwnWords: Int
    var countUsedLetters: Int
    var scoreUsedLetters: Int
    var allAroundScore: Int
    init(countMandatoryWords: Int = 0,
         scoreMandatoryWords: Int = 0,
         countOwnWords: Int = 0,
         scoreOwnWords: Int = 0,
         countUsedLetters: Int = 0,
         scoreUsedLetters: Int = 0,
         allAroundScore: Int = 0) {
        self.countMandatoryWords = countMandatoryWords
        self.scoreMandatoryWords = scoreMandatoryWords
        self.countOwnWords = countOwnWords
        self.scoreOwnWords = scoreOwnWords
        self.countUsedLetters = countUsedLetters
        self.scoreUsedLetters = scoreUsedLetters
        self.allAroundScore = allAroundScore
    }

}

struct ActivityItem {
    enum ActivityType: Int {
        case FromBottom = 0, Moving, Choosing
        var description : String {
            switch self {
            // Use Internationalization, as appropriate.
            case .FromBottom: return "0"
            case .Moving: return "1"
            case .Choosing: return "2"
            }
        }
    }
    var type: ActivityType = .FromBottom
    var fromBottomIndex: Int
    var firstMovingItemColRow: Int
    var lastMovingItemColRow: Int
    var countSteps: Int
    var choosedWord: FoundedWord
    init(type: ActivityType, fromBottomIndex: Int = 0, firstMovingItemColRow: Int = 0, lastMovingItemColRow: Int = 0, countSteps: Int = 0, choosedWord: FoundedWord = FoundedWord(), roundIndex: Int = 0) {
        self.type = type
        self.fromBottomIndex = fromBottomIndex
        self.firstMovingItemColRow = firstMovingItemColRow
        self.lastMovingItemColRow = lastMovingItemColRow
        self.countSteps = countSteps
        self.choosedWord = choosedWord
    }
    init(fromString: String) {
        let itemValues = fromString.components(separatedBy: itemInnerSeparator)
        let type: ActivityType = itemValues[0] == "0" ? .FromBottom : itemValues[0] == "1" ? .Moving : .Choosing
        switch type { // type of item
        case .FromBottom:
            var bottomIndex = 0
            if let from = Int(itemValues[1]) {
                bottomIndex = from
            }
            self.init(type: .FromBottom, fromBottomIndex: bottomIndex)
        case .Moving:
            var firstMovingItemColRow = 0
            var lastMovingItemColRow = 0
            var countSteps = 0
            if let first = Int(itemValues[1]) {
                if let last = Int(itemValues[2]) {
                    if let count = Int(itemValues[3]) {
                        firstMovingItemColRow = first
                        lastMovingItemColRow = last
                        countSteps = count
                    }
                }
            }
            self.init(type: .Moving, firstMovingItemColRow: firstMovingItemColRow, lastMovingItemColRow: lastMovingItemColRow, countSteps: countSteps)
            
        case .Choosing:
            let values = itemValues[1].components(separatedBy: itemInnerSeparator)
            var choosedWord = FoundedWord()
            if values.count > 0 {
                let word = values[0]
                var usedLetters = [UsedLetter]()
                for index in 1..<values.count {
                    let item = values[index]
                    if item.count == 3 {
                        if let col = Int(item.subString(startPos: 0, length: 1)) {
                            if let row = Int(item.subString(startPos: 1, length: 1)) {
                                let letter = item.subString(startPos: 2, length: 1)
                                usedLetters.append(UsedLetter(col: col, row: row, letter: letter))
                            }
                        }
                    }
                }
                choosedWord = FoundedWord(word: word, usedLetters: usedLetters)
            }
            self.init(type: .Choosing, choosedWord: choosedWord)
            
        }
    }
}

class WTScene: SKScene, WTGameboardDelegate, WTGameFinishedDelegate {
    
//    struct AllWordsToShow {
//        var word: String
//        var countFounded: Int {
//            didSet {
//                wordLabel.text = self.word + " (\(self.countFounded))"
//            }
//        }
//        var wordLabel: SKLabelNode
//        init(word: String) {
//            self.word = word
//            countFounded = 0
//            wordLabel = SKLabelNode()
//        }
//    }
//    
    struct TouchedNodes {
        var goBack = false
        var goPreviousGame = false
        var goNextGame = false
        var undo = false
        var GCol = NoValue
        var GRow = NoValue
        var col = NoValue
        var row = NoValue
        var shapeIndex = NoValue
        var answer1 = false
        var answer2 = false
        var ownWordsBackground = false
    }
    
    
    var wtSceneDelegate: WTSceneDelegate?
    var wtGameboard: WTGameboard?
//    var wordsToPlay = Array<GameDataModel>()
//    var allWords = String()
    var workingLetters = String()
//    var tilesForGame = [TilesForGame]()
    var tilesForGame = [WTPiece]()
    var indexOfTilesForGame = 0
    var undoTouched = false
//    var playingWords = [String]()
//    var mandatoryWords = [String]()
    var grid: Grid?
    let heightMultiplicator = CGFloat((GV.onIpad ? 0.10 : 0.15))
    var blockSize: CGFloat = 0
    var random: MyRandom?
//    var allWordsToShow = [AllWordsToShow]()
    var time: Int = 0
    var timer = Timer()
    var timeLabel = SKLabelNode(fontNamed: "TimesNewRomanPS-BoldMT")
    var headerLabel = SKLabelNode(fontNamed: "TimesNewRomanPS-BoldMT")
    var goBackLabel = SKLabelNode(fontNamed: "TimesNewRomanPS-BoldMT")
    var goToPreviousGameLabel = SKLabelNode(fontNamed: "TimesNewRomanPS-BoldMT")
    var goToNextGameLabel = SKLabelNode(fontNamed: "TimesNewRomanPS-BoldMT")
    var testCounter = 0
    var firstTouchLocation = CGPoint(x: 0, y: 0)
//    var scoreMandatoryWords = 0
//    var scoreOwnWords = 0
//    var countMandatoryWords = 0
//    var countOwnWords = 0
    var activityItems = [ActivityItem]()
    var roundIndexes = [Int]()
    var new: Bool = true
    var nextGame: Int = NoMore
    var startTouchedNodes = TouchedNodes()

    var ws = [WTPiece]()
    var origPosition: [CGPoint] = Array(repeating: CGPoint(x:0, y: 0), count: 3)
    var origSize: [CGSize] = Array(repeating: CGSize(width:0, height: 0), count: 3)
    var totalScore: Int = 0
    var moved = false
    var ownWordsMoving = false
    var inChoosingOwnWord = false
    var movedIndex = 0
    var countShowingOwnWords = 0
    var ownWordsMovingStartPos = CGPoint(x:0, y:0)
    var firstLineYPosition = CGFloat(0)
    var heightOfLine = CGFloat(0)
    var showingOwnWordsIndex = 0
    let countWordsInRow = 3
    var countShowingRows = 0
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
    let mandatoryWordsHeaderName = "°°°mandatoryWords°°°"
    let ownWordsHeaderName = "°°°ownWords°°°"
    let undoName = "°°°undo°°°"
    let goBackName = "°°°goBack°°°"
    let headerName = "°°°header°°°"
    let timeName = "°°°timeName°°°"
    let gameNumberName = "°°°gameNumber°°°"
    let previousName = "°°°previousGame°°°"
    let nextName = "°°°nextGame°°°"
    let ownWordsBackgroundName = "°°°ownWordsBackgroundName°°°"

    
    override func didMove(to view: SKView) {
        self.name = "WTScene"
        self.view!.isMultipleTouchEnabled = false
        self.blockSize = self.frame.size.width * (GV.onIpad ? 0.70 : 0.90) / CGFloat(12)

        self.backgroundColor = SKColor(red: 223/255, green: 255/255, blue: 216/255, alpha: 0.8)
        GV.allWords = [WordToCheck]()
        getPlayingRecord(new: new, next: nextGame)
//        createHeader()
        createUndo()
        
        showWordsToCollect()
        play()
   }
    /// WTGameFinishedDelegate
    func getResults() -> (WTResults, Bool) {
        return wtGameboard!.getResults()
    }
    
    private func getPlayingRecord(new: Bool, next: Int) {
        var actGames = realm.objects(GameDataModel.self).filter("nowPlaying = TRUE")
        if new {
            let games = realm.objects(GameDataModel.self).filter("gameType = %d and gameStatus = %d", GV.gameType, GameStatusNew)
            /// reset all records with nowPlaying status
            if actGames.count > 0 {
                for actGame in actGames {
                    realm.beginWrite()
                    actGame.nowPlaying = false
                    try! realm.commitWrite()
                }
            }
            if games.count > 0 {
                GV.playingRecord = games[0]
                realm.beginWrite()
                GV.playingRecord.nowPlaying = true
                try! realm.commitWrite()
            }
        } else {
            var first = true
            if actGames.count > 0 {
                for actGame in actGames {
                    if !first {
                        realm.beginWrite()
                        actGame.nowPlaying = false
                        try! realm.commitWrite()
                    }
                    first = false
                }
            } else {
                actGames = realm.objects(GameDataModel.self).filter("gameType = %d and gameStatus = %d", GV.gameType, GameStatusPlaying)
                realm.beginWrite()
                actGames[0].nowPlaying = true
                try! realm.commitWrite()
            }
            let playedNowGame = realm.objects(GameDataModel.self).filter("nowPlaying = TRUE")
            if playedNowGame.count > 0 {
                let actGameNumber = playedNowGame.first!.gameNumber
                switch nextGame {
                case NoMore:
                    GV.playingRecord = playedNowGame[0]
                case PreviousGame:
                    let previousRecords = realm.objects(GameDataModel.self).filter("gameType = %d and gameStatus = %d and gameNumber < %d",
                                                                                  GV.gameType, GameStatusPlaying, actGameNumber)
                    if previousRecords.count == 1 {
                        GV.playingRecord = previousRecords[0]
                    } else if let record = Array(previousRecords).sorted(by: {$0.gameNumber < $1.gameNumber}).last {
                        GV.playingRecord = record
                    } else {
                        GV.playingRecord = playedNowGame.first!
                    }
                case NextGame:
                    let nextRecords = realm.objects(GameDataModel.self).filter("gameType = %d and gameStatus = %d and gameNumber > %d",
                                                                                   GV.gameType, GameStatusPlaying, actGameNumber)
                    if nextRecords.count == 1 {
                        GV.playingRecord = nextRecords[0]
                    } else if let record = Array(nextRecords).sorted(by: {$0.gameNumber < $1.gameNumber}).first {
                        GV.playingRecord = record
                    } else {
                        GV.playingRecord = playedNowGame.first!
                    }

                default:
                    break
                }
                realm.beginWrite()
                playedNowGame.first!.nowPlaying = false
                GV.playingRecord.nowPlaying = true
                try! realm.commitWrite()
            }
            
        }
    }

    public func setDelegate(delegate: WTSceneDelegate) {
        wtSceneDelegate = delegate
    }
    
    public func setGameArt(new: Bool, next: Int) {
        self.new = new
        self.nextGame = next
    }
    
    private func createHeader() {
        if self.childNode(withName: goBackName) == nil {
            let YPosition: CGFloat = self.frame.height * 0.92
            let fontSize = self.frame.size.height * 0.0175
            goBackLabel = SKLabelNode(fontNamed: "CourierNewPS-BoldMT")// Snell Roundhand")
            goBackLabel.text = GV.language.getText(.tcBack)
            goBackLabel.name = String(goBackName)
            goBackLabel.fontSize = fontSize
            goBackLabel.position = CGPoint(x: self.frame.size.width * 0.1, y: YPosition )
            goBackLabel.horizontalAlignmentMode = .left
            goBackLabel.fontColor = SKColor.blue
            self.addChild(goBackLabel)
        }

        if self.childNode(withName: timeName) == nil {
            timeLabel = SKLabelNode(fontNamed: "CourierNewPS-BoldMT") // Snell Roundhand")
            let YPosition: CGFloat = self.frame.height * 0.92
            let xPosition = self.frame.size.width * 0.8
            timeLabel.position = CGPoint(x: xPosition, y: YPosition)
            timeLabel.fontSize = self.frame.size.height * 0.0175
            timeLabel.fontColor = .black
            timeLabel.text = GV.language.getText(.tcTime, values: time.HourMinSec)
            timeLabel.horizontalAlignmentMode = .right
            timeLabel.name = timeName
            self.addChild(timeLabel)
        }

        if self.childNode(withName: headerName) == nil {
            let fontSize = self.frame.size.height * 0.0175
            let YPosition: CGFloat = self.frame.height * 0.90
            let text = GV.language.getText(.tcHeader, values: String(GV.playingRecord.gameNumber + 1), String(0), String(0))
            headerLabel = SKLabelNode(fontNamed: "CourierNewPS-BoldMT")// Snell Roundhand")
            headerLabel.text = text
            headerLabel.name = String(headerName)
            headerLabel.fontSize = fontSize
            headerLabel.position = CGPoint(x: self.frame.size.width * 0.5, y: YPosition)
            headerLabel.horizontalAlignmentMode = .center
            headerLabel.fontColor = SKColor.black
            self.addChild(headerLabel)
        }
        
        if self.childNode(withName: previousName) == nil {
            goToPreviousGameLabel = SKLabelNode(fontNamed: "CourierNewPS-BoldMT") // Snell Roundhand")
            let yPosition = self.frame.height * 0.03
            let xPosition = self.frame.size.width * 0.1
            goToPreviousGameLabel.position = CGPoint(x: xPosition, y: yPosition)
            goToPreviousGameLabel.fontSize = self.frame.size.height * 0.04
            goToPreviousGameLabel.fontColor = .blue
            goToPreviousGameLabel.text = "<"
            goToPreviousGameLabel.horizontalAlignmentMode = .left
            goToPreviousGameLabel.name = previousName
            self.addChild(goToPreviousGameLabel)
        }
        if self.childNode(withName: nextName) == nil {
            goToNextGameLabel = SKLabelNode(fontNamed: "CourierNewPS-BoldMT") // Snell Roundhand")
            let yPosition = self.frame.height * 0.03
            let xPosition = self.frame.size.width * 0.85
            goToNextGameLabel.position = CGPoint(x: xPosition, y: yPosition)
            goToNextGameLabel.fontSize = self.frame.size.height * 0.04
            goToNextGameLabel.fontColor = .blue
            goToNextGameLabel.text = ">"
            goToNextGameLabel.horizontalAlignmentMode = .left
            goToNextGameLabel.name = nextName
            self.addChild(goToNextGameLabel)
        }
        
   }
    
    private func createBackgroundForOwnWords() {
        let ownYPositionMultiplier:CGFloat = 0.80
        firstLineYPosition = self.frame.height * (ownYPositionMultiplier)
        heightOfLine = self.size.height * 0.02
        let minY: CGFloat? = wtGameboard!.children[0].frame.maxY
        let maxY: CGFloat? = self.childNode(withName: ownWordsHeaderName)!.frame.maxY
        var yPos: CGFloat = 0
        var height: CGFloat = 0
        if minY != nil && maxY != nil {
            height = (maxY! - minY!) * 1.1
            yPos = minY! + (maxY! - minY!) * 0.38
            countShowingOwnWords = countWordsInRow * (Int(height / (self.size.height * 0.02)) - 1)
            countShowingRows = countShowingOwnWords / countWordsInRow
        }

        if self.childNode(withName: ownWordsBackgroundName) == nil {
            let texture = SKTexture(imageNamed: "menuBackground.png")
            let ownWordsBackgroundSprite = SKSpriteNode(texture: texture, color: .red, size: CGSize(width: self.size.width, height: height))
            ownWordsBackgroundSprite.position = CGPoint(x: self.size.width * 0.52, y: yPos)
            ownWordsBackgroundSprite.alpha = 0.3
            ownWordsBackgroundSprite.name = ownWordsBackgroundName
            ownWordsBackgroundSprite.alpha = 0.0
            ownWordsBackgroundSprite.isHidden = true
            self.addChild(ownWordsBackgroundSprite)
        }
    }
    
    private func modifyHeader() {
        let text = GV.language.getText(.tcHeader, values: String(GV.playingRecord.gameNumber + 1), String(GV.playingRecord.rounds.count), String(totalScore))
        headerLabel.text = text
    }
    

    func showFoundedWords() {
        var scoreMandatoryWords = 0
        var scoreOwnWords = 0
        let ownWordAlpha:CGFloat = GV.allMandatoryWordsFounded() ? 1.0 : 0.4
//        let countOwnWords = GV.countWords(mandatory: false)
//        if countOwnWords > countShowingOwnWords {
//            showingOwnWordsIndex = countOwnWords - (countOwnWords - countShowingOwnWords) / 3
//        }
        var index = 0
        for actWord in GV.allWords {
            let label = self.childNode(withName: actWord.word) as? SKLabelNode
            if label != nil {
                label!.text = actWord.word + " (\(actWord.countFounded)) "
                if actWord.mandatory {
                    scoreMandatoryWords += actWord.score
                } else {
                    scoreOwnWords += actWord.score
                    label!.alpha = ownWordAlpha
                    if index >= showingOwnWordsIndex && index <= showingOwnWordsIndex + countWordsInRow * countShowingRows - 1 {
                        label!.isHidden = false
                        label!.position.y = firstLineYPosition - CGFloat((index - showingOwnWordsIndex) / 3) * heightOfLine
                    } else {
                        label!.isHidden = true
                    }
                    index += 1
                }
            }
        }
        
//        if GV.countFounded() >
        
        totalScore = scoreMandatoryWords + scoreOwnWords
        if let label = self.childNode(withName: mandatoryWordsHeaderName)! as? SKLabelNode {
            label.text = GV.language.getText(.tcWordsToCollect, values: String(GV.countMandatoryWords), String(GV.countWords(mandatory: true)), String(GV.countWords(mandatory: true, countAll: true)), String(scoreMandatoryWords))
        }
        if let label = self.childNode(withName: ownWordsHeaderName)! as? SKLabelNode {
            label.text = GV.language.getText(.tcOwnWords, values: String(GV.countWords(mandatory: false)), String(GV.countWords(mandatory: false, countAll: true)), String(scoreOwnWords))
            label.alpha = ownWordAlpha
        }
        modifyHeader()

    }
    
    
    func addOwnWord(word: String, creationIndex: Int, check: Bool) {
        if realm.objects(WordListModel.self).filter("word = %@", word.lowercased()).count == 1 {
            if !GV.allWords.contains(where: {$0.word == word}) {
                let myIndex = (creationIndex == NoValue ? indexOfTilesForGame : creationIndex)
                let ownWordToCheck = WordToCheck(word: word, countFounded: 1, mandatory: false, creationIndex: myIndex, score: 0)
                GV.allWords.append(ownWordToCheck)
                createWordLabel(wordToShow: ownWordToCheck, counter: GV.countWords(mandatory: false), own: true)
                if check {
                    wtGameboard!.checkWholeWords()
                }
            }
        }
    }
    
    private func addOwnWord(ownWord: WordToCheck) {
        addOwnWord(word: ownWord.word, creationIndex: ownWord.creationIndex, check: false)
    }
    
    var line = 0

 private func createUndo() {
        undoSprite = SKSpriteNode(imageNamed: "undo.png")
        let yPosition = self.frame.height * 0.92
        let xPosition = self.frame.width * 0.95
        undoSprite.position = CGPoint(x:xPosition, y:yPosition)
        undoSprite.alpha = 0.2
        undoSprite.size = CGSize(width: self.frame.width * 0.08, height: self.frame.width * 0.08)
        undoSprite.name = undoName
        self.addChild(undoSprite)
    }
    
    private func showWordsToCollect() {
        var counter = 1
        let wordList = GV.playingRecord.mandatoryWords.uppercased().components(separatedBy: "°")
        for word in wordList {
//            GV.allWords.append(WordToCheck(word: word, mandatory: true, creationIndex: NoValue, countFounded: 0))
//            var wordToShow = AllWordsToShow(word: word)
//            allWordsToShow.append(wordToShow)
            let wordToShow = WordToCheck(word: word, countFounded: 0, mandatory: true, creationIndex: 0, score: 0)
            createWordLabel(wordToShow: wordToShow, counter: counter, own: false)
            counter += 1
        }
        createLabel(word: GV.language.getText(.tcWordsToCollect, values: String(GV.countWords(mandatory: true)), "0","0", "0"), first: true, name: mandatoryWordsHeaderName)
        createLabel(word: GV.language.getText(.tcOwnWords, values: "0", "0", "0"), first: false, name: ownWordsHeaderName)
    }
    
    private func createWordLabel(wordToShow: WordToCheck, counter: Int, own: Bool) {
        let xPositionMultiplier = [0.2, 0.5, 0.8]
        let mandatoryYPositionMultiplier:CGFloat = 0.86
        let ownYPositionMultiplier:CGFloat = 0.80
        let distance: CGFloat = 0.02
        let label = SKLabelNode(fontNamed: "TimesNewRomanPS-BoldMT")// Snell Roundhand")
        let wordRow = CGFloat((counter - 1) / countWordsInRow)
        let wordColumn = (counter - 1) % countWordsInRow
        let value = wordRow * distance
        var yPosition: CGFloat = 0
        var showWord = true
        if !own {
            yPosition = self.frame.height * (mandatoryYPositionMultiplier - value)
        } else {
            let maxY = wtGameboard!.children[0].frame.maxY
            yPosition = self.frame.height * (ownYPositionMultiplier - value)
            if yPosition <= maxY {
                showWord = false
            }
        }
        let xPosition = self.frame.size.width * CGFloat(xPositionMultiplier[wordColumn])
        label.position = CGPoint(x: xPosition, y: yPosition)
        label.fontSize = self.frame.size.height * 0.0175
        label.fontColor = .black
        label.text = wordToShow.word + " (\(wordToShow.countFounded))"
        label.name = wordToShow.word
        self.addChild(label)
        if !showWord {
            label.isHidden = true
        }
        let countOwnWords = GV.countWords(mandatory: false)
        if countOwnWords > countShowingOwnWords {
            let countShowedRows = countShowingOwnWords / countWordsInRow
            let startRow = countOwnWords / countWordsInRow - countShowedRows + 1
            showingOwnWordsIndex =  startRow * countWordsInRow
            print("showingOwnWordsIndex: \(showingOwnWordsIndex), countOwnWords: \(countOwnWords)")
        }
    }
    
    private func createLabel(word: String, first: Bool, name: String) {
        let label = SKLabelNode(fontNamed: "TimesNewRomanPS-BoldMT") // Snell Roundhand")
        let yPosition = self.frame.height * (first ? 0.88 : 0.82)
        let xPosition = self.frame.size.width * 0.5
        label.position = CGPoint(x: xPosition, y: yPosition)
        label.fontSize = self.frame.size.height * 0.018
        label.fontColor = .black
        label.text = word
        label.name = name
        self.addChild(label)
    }
    
    private func play() {
        if let iTime = Int(GV.playingRecord.time) {
            time = iTime
        } else {
            time = 0
        }
        GV.countMandatoryWords = 0
        createHeader()
        wtGameboard = WTGameboard(size: sizeOfGrid, parentScene: self, delegate: self)
        createBackgroundForOwnWords()
        generateArrayOfWordPieces(new: new)
        indexOfTilesForGame = 0
        ws = Array(repeating: WTPiece(), count: 3)
        for index in 0..<3 {
            origPosition[index] = CGPoint(x:self.frame.width * shapeMultiplicator[index], y:self.frame.height * heightMultiplicator)
        }
        let mandatoryWords = GV.playingRecord.mandatoryWords.components(separatedBy: "°")
        for item in mandatoryWords {
            if item.count > 0 {
                GV.allWords.append(WordToCheck(word: item.uppercased(), countFounded: 0, mandatory: true, creationIndex: 0, score: 0))
                GV.countMandatoryWords += 1
            }
        }
        if !new {
//            wtGameboard!.setRoundInfos(infos: GV.playingRecord.roundInfos)
            wtGameboard!.setRoundInfos()
            let ownWords = GV.playingRecord.ownWords.components(separatedBy: "°")
            for item in ownWords {
                if item.count > 0 {
                    addOwnWord(ownWord: WordToCheck(from: item))
                }
            }
            restoreGameArray()
            wtGameboard!.checkWholeWords()
        } else {
            if GV.playingRecord.rounds.count == 0 {
                realm.beginWrite()
                let rounds = RoundDataModel()
                GV.playingRecord.rounds.append(rounds)
                try! realm.commitWrite()
            }

            ws = Array(repeating: WTPiece(), count: 3)
            roundIndexes.append(0)
            for index in 0..<3 {
                ws[index] = getNextPiece(horizontalPosition: index)
                origSize[index] = ws[index].size
                ws[index].position = origPosition[index]
                ws[index].name = "Pos\(index)"
                self.addChild(ws[index])
            }
        }
        modifyHeader()
        goToPreviousGameLabel.alpha = hasPreviousRecords(playingRecord: GV.playingRecord) ? 1.0 : 0.1
        goToNextGameLabel.alpha = hasNextRecords(playingRecord: GV.playingRecord) ? 1.0 : 0.1
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(countTime(timerX: )), userInfo: nil, repeats: true)
    }
    
    private func hasPreviousRecords(playingRecord: GameDataModel)->Bool {
        return realm.objects(GameDataModel.self).filter("gameType = %d and gameStatus = %d and gameNumber < %d",
            GV.gameType, GameStatusPlaying, playingRecord.gameNumber).count > 0
    }
    
    private func hasNextRecords(playingRecord: GameDataModel)->Bool {
    return realm.objects(GameDataModel.self).filter("gameType = %d and gameStatus = %d and gameNumber > %d",
    GV.gameType, GameStatusPlaying, playingRecord.gameNumber).count > 0
    
    }
    @objc private func countTime(timerX: Timer) {
        time += 1
        timeLabel.text = GV.language.getText(.tcTime, values: time.HourMinSec)
        realm.beginWrite()
        GV.playingRecord.time = String(time)
        try! realm.commitWrite()
    }
    
    private func generateArrayOfWordPieces(new: Bool) {
        if new {
            realm.beginWrite()
            GV.playingRecord.pieces = generateArrayOfWordPieces()
            try! realm.commitWrite()
        }
        tilesForGame.removeAll()
        let piecesToPlay = GV.playingRecord.pieces.components(separatedBy: "°")
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
        var tileForGame: WTPiece
        repeat {
            tileForGame = tilesForGame[indexOfTilesForGame]
            indexOfTilesForGame += 1
        } while tileForGame.isOnGameboard
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
            ws[touchedNodes.shapeIndex].zPosition = 10
            wtGameboard!.clear()
        } else if touchedNodes.GCol.between(min: 0, max: sizeOfGrid - 1) && touchedNodes.GRow.between(min:0, max: sizeOfGrid - 1){
            inChoosingOwnWord = true
            wtGameboard?.startChooseOwnWord(col: touchedNodes.GCol, row: touchedNodes.GRow)
        } else if touchedNodes.ownWordsBackground {
            ownWordsMoving = true
            ownWordsMovingStartPos = firstTouchLocation
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
        } else if ownWordsMoving {
            if abs(touchLocation.y - ownWordsMovingStartPos.y) > self.frame.height * 0.02 {
                if GV.countWords(mandatory: false) > countShowingOwnWords {
//                    let adder = touchLocation.y - ownWordsMovingStartPos.y > 0 ? countWordsInRow : -countWordsInRow
                    print("hier")
                }
            }
        } else {
            if touchedNodes.shapeIndex >= 0 {
                ws[touchedNodes.shapeIndex].position = touchLocation
            }
            let yDistance = (touchLocation - firstTouchLocation).y
            if yDistance > blockSize / 2 && touchedNodes.row >= 0 && touchedNodes.row < sizeOfGrid {
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
    
    var enabled = true
    var gameboardEnabled = true

    private func analyzeNodes(nodes: [SKNode], calledFrom: CalledFrom)->TouchedNodes {
        var touchedNodes = TouchedNodes()
        for node in nodes {
            guard let name = node.name else {
                continue
            }
            if enabled || gameboardEnabled {
                if name == goBackName {
                    touchedNodes.goBack = enabled
                }
                if name == previousName {
                    touchedNodes.goPreviousGame = enabled
                }
                if name == nextName {
                    touchedNodes.goNextGame = enabled
                } else if name == undoName {
                    touchedNodes.undo = enabled
                } else if name.begins(with: "GBD") {
                    touchedNodes.GCol = Int(name.subString(startPos: 4, length:1))!
                    touchedNodes.GRow = Int(name.subString(startPos: 6, length:1))!
                } else if let number = Int(name.subString(startPos: 3, length: name.count - 3)) {
                    if enabled {
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
            }
            if name == answer1Name {
               touchedNodes.answer1 = true
            } else if name == answer2Name {
                touchedNodes.answer2 = true
            } else if name == ownWordsBackgroundName {
                touchedNodes.ownWordsBackground = true
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
        if touchedNodes.answer1 {
            gameboardEnabled = true
            removeNodesWith(name: MyQuestionName)
            self.addChild(createButton(withText: GV.language.getText(.tcNoMoreStepsAnswer2), position:CGPoint(x: self.size.width * 0.5, y: self.size.height * 0.94), name: answer2Name))
        }
        if touchedNodes.answer2 {
            wtGameboard!.clearGreenFieldsForNextRound()
            if !checkFreePlace() {
                let size = CGSize(width: self.frame.width * 0.8, height: self.frame.height * 0.5)
                let position = CGPoint(x: self.frame.midX, y: self.frame.midY)
                let gameFinishedSprite = WTGameFinished(size: size, position: position, delegate: self)
                self.addChild(gameFinishedSprite)
                gameFinishedSprite.showFinish()
                realm.beginWrite()
                GV.playingRecord.gameStatus = GameStatusFinished
                try! realm.commitWrite()
            } else {
                roundIndexes.append(activityItems.count - 1)
                realm.beginWrite()
                let newRound = RoundDataModel()
                newRound.index = activityItems.count - 1
                newRound.gameArray = wtGameboard!.gameArrayToString()
                GV.playingRecord.rounds.append(newRound)
                try! realm.commitWrite()
                modifyHeader()
            }
            enabled = true
            gameboardEnabled = false
            removeNodesWith(name: MyQuestionName)
            removeNodesWith(name: answer2Name)
       }
        if touchedNodes.undo {
            startUndo()
            saveActualState()
        }
        if touchedNodes.goPreviousGame {
            wtSceneDelegate!.gameFinished(start: PreviousGame)
            return
        }
        if touchedNodes.goNextGame {
            wtSceneDelegate!.gameFinished(start: NextGame)
            return
        }
        if inChoosingOwnWord {
            wtGameboard?.endChooseOwnWord(col: touchedNodes.GCol, row: touchedNodes.GRow)
            saveActualState()
        } else if moved {
            let fixed = wtGameboard!.stopShowingSpriteOnGameboard(col: touchedNodes.col, row: touchedNodes.row)
            if fixed {
                ws[movedIndex].zPosition = 1
                ws[movedIndex].setPieceFromPosition(index: movedIndex)
                let activityItem = ActivityItem(type: .FromBottom, fromBottomIndex: ws[movedIndex].getArrayIndex())
                activityItems.append(activityItem)
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

                if !freePlaceFound {
                    let question = MyQuestion(question: .NoMoreSteps, parentSize: self.size)
                    question.position = CGPoint(x:self.size.width * 0.5, y: self.size.height * 0.5)
                    self.addChild(question)
                    enabled = false
                    gameboardEnabled = false
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
                wtSceneDelegate!.gameFinished(start: NoMore)
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
        for item in GV.allWords {
            if !item.mandatory {
                tempOwnWords += item.toString() + "°"
            }
        }
        realm.beginWrite()
        GV.playingRecord.ownWords = tempOwnWords
        GV.playingRecord.pieces = pieces
        GV.playingRecord.gameStatus = GameStatusPlaying
//        var roundIndexesString = ""
//        for index in 0..<roundIndexes.count {
//            roundIndexesString += String(roundIndexes[index]) + "°"
//        }
//        if roundIndexesString.count > 0 {
//            roundIndexesString.removeLast()
//        } else {
//            roundIndexesString.append("0")
//        }
//        GV.playingRecord.roundIndexes = roundIndexesString
//        GV.playingRecord.roundInfos = wtGameboard!.roundInfosToString(all:true)
        var rounds: RoundDataModel
//        if GV.playingRecord.rounds.count == 0 {
//            rounds = RoundDataModel()
//            GV.playingRecord.rounds.append(rounds)
//        }
        rounds = GV.playingRecord.rounds.last!
        rounds.index = roundIndexes.last!
        rounds.infos = wtGameboard!.roundInfosToString(all:false)
        rounds.gameArray  = wtGameboard!.gameArrayToString()
//        GV.playingRecord.roundGameArrays = wtGameboard!.gameArrayToString()
        
        
        var activityItemsString = ""
        if activityItems.count > 0 {
            for index in 0..<activityItems.count {
                let actItem = activityItems[index]
                activityItemsString += actItem.type.description + itemInnerSeparator
                switch activityItems[index].type  {
                case .FromBottom:
                    activityItemsString += String(actItem.fromBottomIndex)
                case .Moving:
                    activityItemsString += String(actItem.firstMovingItemColRow) + itemInnerSeparator
                    activityItemsString += String(actItem.lastMovingItemColRow) + itemInnerSeparator
                    activityItemsString += String(actItem.countSteps)
                case .Choosing:
                    activityItemsString += String(actItem.choosedWord.toString())
                }
                activityItemsString += itemSeparator
            }
            activityItemsString.removeLast()
            GV.playingRecord.activityItems = activityItemsString
        }
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
        if activityItems.count > 0 {
            switch activityItems.last!.type {
            case .FromBottom:
                if GV.playingRecord.rounds.count > 1 && GV.playingRecord.rounds.last!.index == activityItems.count - 1 {
                    realm.beginWrite()
                    GV.playingRecord.rounds.removeLast()
                    try! realm.commitWrite()
                    wtGameboard!.stringToGameArray(string: GV.playingRecord.rounds.last!.gameArray)
                    modifyHeader()
                } else {
//                if roundIndexes.count > 0 {
//                    if roundIndexes.last! == activityItems.count - 1 {
//                        roundIndexes.removeLast()
//                        wtGameboard!.clearGameArray()
//                        fillGameArrayFromActivityItems()
//                    }
//                    wtGameboard!.checkWholeWords()
//                }
//
                    let indexOfLastPiece = activityItems.last!.fromBottomIndex
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
                        if let index = GV.allWords.index(where: {$0.creationIndex > indexOfTilesForGame}) {
                            if !GV.allWords[index].mandatory {
                                let foundedOwnWord = GV.allWords[index].word
                                GV.allWords.remove(at: index)
                                if let label = self.childNode(withName: foundedOwnWord)! as? SKLabelNode {
                                    label.removeFromParent() // This word is no more known
                                }

                            }
                        } else {
                            doing = false
                        }
                    } while doing
                    wtGameboard!.checkWholeWords()
                    activityItems.removeLast()
                    if activityItems.count == 0 {
                        undoSprite.alpha = 0.1
                    }
                }
            case .Moving:
                break
            case .Choosing:
                break
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
        let activityItemsArray = GV.playingRecord.activityItems.components(separatedBy: itemSeparator)
//        if activityItemsArray.count > 1 {
//            if activityItemsArray[0] == "" {
//                activityItemsArray.removeFirst()
//            }
//        }
        if activityItemsArray.count < 1 {
            roundIndexes = [0]
        } else {
            activityItems.removeAll()
            for activityItem in activityItemsArray {
                if activityItem != "" {
                    let itemValue = ActivityItem(fromString: activityItem)
                    activityItems.append(itemValue)
                }
            }
            roundIndexes.removeAll()
            let rounds = GV.playingRecord.rounds
            for round in rounds {
                roundIndexes.append(round.index)
            }
//            let roundIndexesArray = GV.playingRecord.roundIndexes.components(separatedBy: itemSeparator)
//            roundIndexes.removeAll()
//            var first = true
//            if roundIndexesArray.count > 0 {
//                for roundIndexString in roundIndexesArray {
//                    if let roundIndex = Int(roundIndexString) {
//                        if first {
//                            if roundIndex != 0 {
//                                roundIndexes.append(0)
//                                first = false
//                            }
//                        }
//                        if !roundIndexes.contains(where: {$0 == roundIndex}) {
//                            roundIndexes.append(roundIndex)
//                        }
//                    }
//                }
//            }
//            if roundIndexes.count > 0 {
//                GV.actRound = roundIndexes.count - 1
//            } else {
//                GV.actRound = 0
//            }
        }
        if GV.playingRecord.rounds.last!.gameArray.count > 0 {
            wtGameboard!.stringToGameArray(string: GV.playingRecord.rounds.last!.gameArray)
//        wtGameboard!.clearGameArray() // delete all contents from GameArray
//        fillGameArrayFromActivityItems()
//        var wsIndex = 0
        }
        for index in 0..<tilesForGame.count {
            let tileForGame = tilesForGame[index]
            if !tileForGame.isOnGameboard {
                if tileForGame.pieceFromPosition >= 0 {
                    let pieceIndex = tileForGame.pieceFromPosition
                    addPieceAsChild(pieceIndex: pieceIndex, piece: tileForGame)
                } else {
                    indexOfTilesForGame = index
                    break

                }
            }
        }
        for index in 0..<ws.count {
            if ws[index].name == nil {
                var tileForGame: WTPiece
                repeat {
                    tileForGame = tilesForGame[indexOfTilesForGame]
                    indexOfTilesForGame += 1
                } while tileForGame.isOnGameboard
                addPieceAsChild(pieceIndex: index, piece: tileForGame)
                
            }
        }
        if activityItems.count > 0 {
            undoSprite.alpha = 1.0
        }
        if let iTime = Int(GV.playingRecord.time) {
            time = iTime
        } else {
            time = 0
        }
        wtGameboard!.checkWholeWords()
    }
    
    private func generateArrayOfWordPieces()->String {
        let gameType = GV.playingRecord.gameType
        let gameNumber =  GV.playingRecord.gameNumber
        let words = GV.playingRecord.mandatoryWords.components(separatedBy: "°")
        let blockSize = frame.size.width * (GV.onIpad ? 0.70 : 0.90) / CGFloat(12)
        let random = MyRandom(gameType: gameType, gameNumber: gameNumber)
        func getLetters( from: inout [String], archiv: inout [String])->[String] {
            
            if from.count == 0 {
                repeat {
                    let archivIndex = random.getRandomInt(0, max: archiv.count - 1)
                    let item = archiv[archivIndex]
                    archiv.remove(at: archivIndex)
                    from.append(item)
                } while archiv.count > 0
//                for item in archiv {
//                    from.append(item)
//                }
//                archiv.removeAll()
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
//            for index in 0..<word.count - 1 {
//                twoLetterPieces.append(word.subString(startPos: index, length: 2).uppercased())
//            }
//
            for index in 0..<word.count / 2 {
                if !twoLetterPieces.contains(where: {$0 == word.subString(startPos: index * 2, length: 2).uppercased()}) {
                    twoLetterPieces.append(word.subString(startPos: index * 2, length: 2).uppercased())
                }
            }
        }
        for letter in String(GV.language.getText(.tcAlphabet)) {
            if !oneLetterPieces.contains(where: {$0 == String(letter)}) {
                oneLetterPieces.append(String(letter))
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
//        let lengths = [1,1,1,2,2,2,2,3,3,4]
        let lengths = [1,1,1,2,2,2]
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
        } while generateLength < 1000
        var generatedArrayInStringForm = ""
        for tile in tilesForGame {
            generatedArrayInStringForm += tile.toString() + "°"
        }
        return generatedArrayInStringForm
    }
    
    func fillGameArrayFromActivityItems() {
        for (index, item) in activityItems.enumerated() {
            switch item.type {
            case .FromBottom:
                if roundIndexes.contains(index) {
                    wtGameboard!.checkWholeWords()
                    wtGameboard!.clearGreenFieldsForNextRound()
                }
                let tileForGame = tilesForGame[item.fromBottomIndex]
                wtGameboard!.showPieceOnGameArray(piece: tileForGame)
            case .Moving:
                break
            case .Choosing:
                break
            }
        }

    }
    
    private func createButton(withText: String, position: CGPoint, name: String)->SKSpriteNode {
        func createLabel(withText: String, position: CGPoint, fontSize: CGFloat, name: String)->SKLabelNode {
            let label = SKLabelNode()
            label.fontName = "TimesNewRoman"
            label.fontColor = .black
            label.numberOfLines = 0
            label.verticalAlignmentMode = .center
            label.horizontalAlignmentMode = .center
            label.fontSize = self.size.width * 0.03
            label.zPosition = self.zPosition + 1
            label.text = withText
            label.name = name
            label.position = position
            return label
        }

        let texture = SKTexture(imageNamed: "button.png")
        let button = SKSpriteNode(texture: texture, color: .white, size: CGSize(width: self.size.width * 0.4, height: self.size.height * 0.1))
        button.position = position
        button.name = name
        button.addChild(createLabel(withText: withText, position: CGPoint(x:0, y:10), fontSize: self.size.width * 0.03, name: name + "Label"))
        return button
        
    }

    

    
    deinit {
        print("\n THE SCENE \((type(of: self))) WAS REMOVED FROM MEMORY (DEINIT) \n")
    }
}

