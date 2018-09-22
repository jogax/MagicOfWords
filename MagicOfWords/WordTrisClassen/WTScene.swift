//
//  CollectWordsScene.swift
//  MagicOfWords
//
//  Created by Jozsef Romhanyi on 06/02/2018.
//  Copyright © 2018 Jozsef Romhanyi. All rights reserved.
//

import Foundation
import GameplayKit

public enum StartType: Int {
    case NoMore = 0, PreviousGame, NextGame, NewGame
}


public protocol WTSceneDelegate: class {
    
    /// Method called when Game finished
    func gameFinished(start: StartType)
    
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
    var movingItem: MovingItem
    var choosedWord: FoundedWord
    init(type: ActivityType, fromBottomIndex: Int = 0, movingItem: MovingItem = MovingItem(), countSteps: Int = 0, choosedWord: FoundedWord = FoundedWord(), roundIndex: Int = 0) {
        self.type = type
        self.fromBottomIndex = fromBottomIndex
        self.movingItem = movingItem
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
            let movingItem = MovingItem(from: itemValues[1])
            self.init(type: .Moving, movingItem: movingItem)
            
        case .Choosing:
            let word = itemValues[1]
            let usedLettersString = itemValues[2]
            var choosedWord = FoundedWord()
            if usedLettersString.count > 0 && usedLettersString.count % 3 == 0 {
                var usedLetters = [UsedLetter]()
                var index = 0
                repeat {
                    let col = Int(usedLettersString.subString(startPos: index, length: 1))
                    let row = Int(usedLettersString.subString(startPos: index + 1, length: 1))
                    let letter = usedLettersString.subString(startPos: index + 2, length: 1)
                    if col != nil && row != nil {
                        usedLetters.append(UsedLetter(col: col!, row: row!, letter: letter))
                    }
                    index += 3
                } while usedLettersString.count > index
                choosedWord = FoundedWord(word: word, usedLetters: usedLetters)
            }
            self.init(type: .Choosing, choosedWord: choosedWord)
        }
    }
    
    func toString()->String {
        switch type {
        case .FromBottom:
            return String(self.fromBottomIndex)
        case .Moving:
            return self.movingItem.toString()
        case .Choosing:
            return String(self.choosedWord.toString())
        }
    }
}

let trueString = "1"
let falseString = "0"
let iHour = 3600
let iHalfHour = 1800
let iQuarterHour = 900
let iTenMinutes = 600
let iFiveMinutes = 300



class WTScene: SKScene, WTGameboardDelegate, WTGameFinishedDelegate, WTGameWordListDelegate, WTTableViewDelegate {
    func blinkWords(newWord: SelectedWord, foundedWord: SelectedWord = SelectedWord()) {
        var longWaitAction = SKAction.wait(forDuration: 0.0)
        let duration = 0.3
        if newWord != foundedWord {
            for letter in newWord.usedLetters {
                let myNode = GV.gameArray[letter.col][letter.row]
                let showRedAction = SKAction.run({
                    myNode.setColors(toColor: .myRedColor, toStatus: .noChange)
                })
                let waitAction = SKAction.wait(forDuration: duration)
                let showOrigAction = SKAction.run({
                    myNode.setColorByState()
                })
                var sequence = [SKAction]()
                for _ in 1...3 {
                    sequence.append(showRedAction)
                    sequence.append(waitAction)
                    sequence.append(showOrigAction)
                    sequence.append(waitAction)
                }
                myNode.run(SKAction.sequence(sequence))
            }
            longWaitAction = SKAction.wait(forDuration: 3 * 2 * duration)
        }
        for letter in foundedWord.usedLetters {
            let myNode = GV.gameArray[letter.col][letter.row]
            let showGreenAction = SKAction.run({
                myNode.setColors(toColor: .myDarkGreenColor, toStatus: .noChange)
            })
            let waitAction = SKAction.wait(forDuration: duration)
            let showOrigAction = SKAction.run({
                myNode.setColorByState()
            })
            var sequence = [SKAction]()
            sequence.append(longWaitAction)
            for _ in 1...3 {
                sequence.append(showGreenAction)
                sequence.append(waitAction)
                sequence.append(showOrigAction)
                sequence.append(waitAction)
            }
            myNode.run(SKAction.sequence(sequence))
            
            
        }

    }
    
    func setLettersMoved(fromLetters: [UsedLetter], toLetters: [UsedLetter]) {
        let movingItem = MovingItem(fromLetters: fromLetters, toLetters: toLetters)
        let activityItem = ActivityItem(type: .Moving, movingItem: movingItem)
        activityRoundItem[activityRoundItem.count - 1].activityItems.append(activityItem)
        //        activityItems.append(activityItem)
        saveActualState()
    }
    
    var lengthOfWord: Int = 0
    var lengthOfCnt: Int = 0
    var lengthOfLength: Int = 0
    var lengthOfScore: Int = 0
    var lengthOfMin: Int = 0
    var title = ""

    private func calculateColumnWidths() {
        title = ""
        let text1 = " \(GV.language.getText(.tcWord).fixLength(length: maxLength, center: true))     "
        let text2 = "\(GV.language.getText(.tcCount)) "
        let text3 = "\(GV.language.getText(.tcLength)) "
        let text4 = "\(GV.language.getText(.tcScore)) "
        let text5 = "\(GV.language.getText(.tcMinutes)) "
        title += text1
        title += text2
        title += text3
        title += text4
        title += text5
        lengthOfWord = maxLength
        lengthOfCnt = text2.length
        lengthOfLength = text3.length
        lengthOfScore = text4.length
        lengthOfMin = text5.length
    }
    
    func fillHeaderView(tableView: UITableView, section: Int) -> UIView {
        var text: String = ""
        let lineHeight = title.height(font: myFont!)
        let width = title.width(withConstrainedHeight: 0, font: myFont!)
        let view = UIView()
        switch tableType {
        case .ShowAllWords:
            if section == 0 {
                text = GV.language.getText(.tcCollectedRequiredWords).fixLength(length: title.length, center: true)
            } else {
                text = GV.language.getText(.tcCollectedOwnWords).fixLength(length: title.length, center: true)
            }
        case .ShowWordsOverPosition:
            text = GV.language.getText(.tcWordsOverLetter).fixLength(length: title.length, center: true)
        default:
            break
        }
        let label1 = UILabel(frame: CGRect(x: 0, y: 0, width: width, height: lineHeight))
        label1.font = myFont!
        label1.text = text
        view.addSubview(label1)
        let label2 = UILabel(frame: CGRect(x: 0, y: lineHeight, width: width, height: lineHeight))
        label2.font = myFont!
        label2.text = title
        view.addSubview(label2)
        view.backgroundColor = UIColor(red:240/255, green: 240/255, blue: 240/255, alpha: 1.0)
        return view
    }
    
    func getHeightForHeaderInSection(tableView: UITableView, section: Int)->CGFloat {
        return GV.onIpad ? 48 : 35
    }
    
    func setHeaderView(tableView: UITableView, headerView: UIView, section: Int) {
    }
    

    let showWordsBackgroundColor = UIColor(red:255/255, green: 204/255, blue: 153/255, alpha: 1.0)
    let maxLengthMultiplier: CGFloat = GV.onIpad ? 12 : 8
    let color = UIColor(red: 240/255, green: 240/255, blue: 240/255, alpha: 1.0)

    
    func getTableViewCell(tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! CustomTableViewCell
        cell.setFont(font: myFont!)
        cell.setCellSize(size: CGSize(width: tableView.frame.width * (GV.onIpad ? 0.040 : 0.010), height: self.frame.width * (GV.onIpad ? 0.040 : 0.010)))
        cell.setBGColor(color: UIColor.white) //showWordsBackgroundColor)
        switch tableType {
        case .ShowAllWords:
            if indexPath.section == 0 {
                cell.addColumn(text: "  " + mandatoryWordsForShow[indexPath.row].word.fixLength(length: lengthOfWord, leadingBlanks: false)) // WordColumn
                cell.addColumn(text: String(mandatoryWordsForShow[indexPath.row].counter).fixLength(length: lengthOfCnt), color: color) // Counter column
                cell.addColumn(text: String(mandatoryWordsForShow[indexPath.row].word.length).fixLength(length: lengthOfLength))
                cell.addColumn(text: String(mandatoryWordsForShow[indexPath.row].score).fixLength(length: lengthOfScore), color: color) // Score column
                cell.addColumn(text: "+\(mandatoryWordsForShow[indexPath.row].minutes)".fixLength(length: lengthOfMin))
            } else {
                cell.addColumn(text: "  " + ownWordsForShow[indexPath.row].word.fixLength(length: lengthOfWord, leadingBlanks: false)) // WordColumn
                cell.addColumn(text: String(ownWordsForShow[indexPath.row].counter).fixLength(length: lengthOfCnt), color: color) // Counter column
                cell.addColumn(text: String(ownWordsForShow[indexPath.row].word.length).fixLength(length: lengthOfLength))
                cell.addColumn(text: String(ownWordsForShow[indexPath.row].score).fixLength(length: lengthOfScore), color: color) // Score column
                cell.addColumn(text: "+\(ownWordsForShow[indexPath.row].minutes)".fixLength(length: lengthOfMin))
             }
        case .ShowWordsOverPosition:
            cell.addColumn(text: "  " + wordList[indexPath.row].word.fixLength(length: lengthOfWord + 2, leadingBlanks: false)) // WordColumn
            cell.addColumn(text: String(1).fixLength(length: lengthOfCnt - 1), color: color) // Counter column
            cell.addColumn(text: String(wordList[indexPath.row].word.length).fixLength(length: lengthOfLength - 1))
            cell.addColumn(text: String(wordList[indexPath.row].score).fixLength(length: lengthOfScore + 1), color: color) // Counter column
            cell.addColumn(text: "+\(WTGameWordList.shared.getMinutesForWord(word: wordList[indexPath.row].word))".fixLength(length: lengthOfMin - 1))
        default:
            break
        }
        return cell
    }
    
    func getNumberOfSections() -> Int {
        switch tableType {
        case .ShowAllWords:
            return 2
        case .ShowWordsOverPosition:
            return 1
        case .None:
            return 0
        }
    }
    
    func getHeightForRow(tableView: UITableView, indexPath: IndexPath)->CGFloat {
        return title.height(font: myFont!)
    }
    
    func getNumberOfRowsInSections(section: Int)->Int {
        switch tableType {
        case .ShowAllWords:
            switch section {
            case 0: return WTGameWordList.shared.getCountWords(mandatory: true)
            case 1: return WTGameWordList.shared.getCountWords(mandatory: false)
            default: return 0
            }
        case .ShowWordsOverPosition:
            return wordList.count
        default:
            return 0
        }
    }
    
    enum TableType: Int {
        case None = 0, ShowAllWords, ShowWordsOverPosition
    }
    
    
    let nameForSpriteWidthWords = "°°°nameForSpriteWidthWords°°°"
    var spriteToShowWords: SKSpriteNode?
    var tableType: TableType = .None
    var wordList = [SelectedWord]()
    var showWordsOverPositionTableView: WTTableView?
    

    func showScore(newWord: SelectedWord, newScore: Int, totalScore: Int, doAnimate: Bool, changeTime: Int) {
        if doAnimate {
            showWordAndScore(word: newWord, score: newScore)
        }
        if changeTime != 0 {
            timeForGame.incrementMaxTime(value: changeTime * 60)
        }
//        if changeTime < 0 {
//            timeForGame.decrementMaxTime(value: changeTime * 60)
//        }
       self.totalScore = totalScore
        showFoundedWords()
        return
    }
    
    private func showWordAndScore(word: SelectedWord, score: Int) {
        let fontSize = GV.onIpad ? self.frame.size.width * 0.02 : self.frame.size.width * 0.04
        let textOnBalloon = word.word + " (" + String(score) + ")"
        
        let balloon = SKSpriteNode(imageNamed: "balloon.png")
        let widthMultiplier: CGFloat = 0.1 + CGFloat(textOnBalloon.length) * (GV.onIpad ? 0.015 : 0.030)
        balloon.size = CGSize(width: self.frame.size.width * widthMultiplier, height: self.frame.size.width * 0.10)
        balloon.zPosition = 100
//        let startPosY = score >= 0 ? self.frame.size.height * 0.1 : self.frame.size.height * 0.98
        let startPos = wtGameboard!.getCellPosition(col: word.usedLetters[0].col, row: word.usedLetters[0].row)
//        let startPosY = startPos.y
        let endPosY = score > 0 ? self.frame.size.height * 0.80 : self.frame.size.height * -0.04
        balloon.position = CGPoint(x: startPos.x, y: startPos.y )
        self.addChild(balloon)
        let scoreLabel = SKLabelNode(fontNamed: "TimesNewRomanPS-BoldMT")
        scoreLabel.text = String(score)
//        scoreLabel.verticalAlignmentMode = .center
        scoreLabel.position = CGPoint(x: balloon.size.width * 0, y: -balloon.size.width * 0.40)
        scoreLabel.horizontalAlignmentMode = .center
        scoreLabel.fontSize = fontSize
        scoreLabel.fontColor = SKColor.blue
        let wordLabel = SKLabelNode(fontNamed: "TimesNewRomanPS-BoldMT")
        wordLabel.text = textOnBalloon
        wordLabel.verticalAlignmentMode = .center
        scoreLabel.position = CGPoint(x: balloon.size.width * 0, y: balloon.size.width * 0.20)
        wordLabel.fontSize = fontSize
        wordLabel.fontColor = SKColor.blue
//        balloon.addChild(scoreLabel)
        balloon.addChild(wordLabel)
        var actions = Array<SKAction>()
        let waitAction = SKAction.wait(forDuration: 1.0)
        let movingAction = SKAction.move(to: CGPoint(x: self.frame.size.width * 0.5, y: endPosY), duration: 3.0)
        let fadeAway = SKAction.fadeOut(withDuration: 2.5)
        let removeNode = SKAction.removeFromParent()
        actions.append(SKAction.sequence([waitAction, movingAction]))
        actions.append(SKAction.sequence([waitAction, fadeAway, removeNode]))
        let group = SKAction.group(actions);
        balloon.run(group)
    }
    
    
    
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
//        var ownWordsBackground = false
        var gameFinishedOKButton = false
        var showOwnWordsButton = false
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
    var myTimer: MyTimer?
    var timeForGame = TimeForGame()
    var timerIsCounting = false
    let heightMultiplicator = CGFloat((GV.onIpad ? 0.10 : 0.15))
    var blockSize: CGFloat = 0
    var random: MyRandom?
//    var allWordsToShow = [AllWordsToShow]()
    var timer: Timer? = Timer()
    var timeLabel = SKLabelNode(fontNamed: "TimesNewRomanPS-BoldMT")
    var headerLabel = SKLabelNode(fontNamed: "TimesNewRomanPS-BoldMT")
    var goBackLabel = SKLabelNode(fontNamed: "TimesNewRomanPS-BoldMT")
    var goToPreviousGameLabel = SKLabelNode(fontNamed: "TimesNewRomanPS-BoldMT")
    var goToNextGameLabel = SKLabelNode(fontNamed: "TimesNewRomanPS-BoldMT")
    var firstTouchLocation = CGPoint(x: 0, y: 0)
//    var scoreMandatoryWords = 0
//    var scoreOwnWords = 0
//    var countMandatoryWords = 0
//    var countOwnWords = 0
    struct ActivityRound {
        var activityItems = [ActivityItem]()
        init () {
            
        }
    }
    var activityRoundItem = [ActivityRound]()
//    var activityItems = [ActivityItem]()
//    var roundIndexes = [Int]()
    var new: Bool = true
    var nextGame: StartType = .NoMore
    var startTouchedNodes = TouchedNodes()
    var wtGameFinishedSprite = WTGameFinished()

    var ws = [WTPiece]()
    var origPosition: [CGPoint] = Array(repeating: CGPoint(x:0, y: 0), count: 3)
    var origSize: [CGSize] = Array(repeating: CGSize(width:0, height: 0), count: 3)
    var totalScore: Int = 0
    var moved = false
//    var ownWordsScrolling = false
    var inChoosingOwnWord = false
    var movedIndex = 0
    var countShowingOwnWords = 0
    var ownWordsScrollingStartPos = CGPoint(x:0, y:0)
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
    let bgColor = SKColor(red: 223/255, green: 255/255, blue: 216/255, alpha: 0.8)
    let mandatoryWordsHeaderName = "°°°mandatoryWords°°°"
    let ownWordsHeaderName = "°°°ownWords°°°"
    let undoName = "°°°undo°°°"
    let goBackName = "°°°goBack°°°"
    let headerName = "°°°header°°°"
    let timeName = "°°°timeName°°°"
    let gameNumberName = "°°°gameNumber°°°"
    let previousName = "°°°previousGame°°°"
    let nextName = "°°°nextGame°°°"
//    let ownWordsBackgroundName = "°°°ownWordsBackgroundName°°°"
    let ownWordsButtonName = "°°°ownWordsButtonName°°°"

    var timeIncreaseValues: [Int]?
    var movingSprite: Bool = false
//    var wtGameWordList: WTGameWordList?

    
    override func didMove(to view: SKView) {
//        wtGameWordList = WTGameWordList(delegate: self)
//        timeIncreaseValues = [0, 0, 0, 0, 0, 0, iFiveMinutes, iFiveMinutes, iTenMinutes, iTenMinutes, iQuarterHour]
        self.name = "WTScene"
        self.view!.isMultipleTouchEnabled = false
        self.view!.subviews.forEach { $0.removeFromSuperview() }
        self.blockSize = self.frame.size.width * (GV.onIpad ? 0.70 : 0.90) / CGFloat(12)
        self.wtGameFinishedSprite = WTGameFinished()
        self.addChild(wtGameFinishedSprite)
        self.backgroundColor = bgColor
//        GV.allWords = [WordToCheck]()
        getPlayingRecord(new: new, next: .NextGame)
//        createHeader()
//        createUndo(enabled: true)
        createGoBackButton()
        wtGameFinishedSprite.setDelegate(delegate: self)
        WTGameWordList.shared.clear()
        WTGameWordList.shared.setMandatoryWords()
        showWordsToCollect()
        play()
   }
    
//    func setCountMandatoryWords() {
//        let mandatoryWords = GV.playingRecord.mandatoryWords.components(separatedBy: "°")
//        for item in mandatoryWords {
//            if item.count > 0 {
//                GV.allWords.append(WordToCheck(word: item.uppercased(), countFounded: 0, mandatory: true, creationIndex: 0, score: 0))
//            }
//        }
//        GV.countMandatoryWords = mandatoryWords.count
//    }
//
    func startNewGame() {
        wtSceneDelegate!.gameFinished(start: .NewGame)
    }
    
    func restartThisGame() {
        realm.beginWrite()
//        GV.playingRecord.ownWords = ""
        GV.playingRecord.pieces = ""
//        GV.playingRecord.activityItems = ""
        GV.playingRecord.time = "0°origMaxTime"
        GV.playingRecord.rounds.removeAll()
        GV.playingRecord.gameStatus = GV.GameStatusNew
        try! realm.commitWrite()
        wtSceneDelegate!.gameFinished(start: .NewGame)
    }
    
//    private func clearAllWords() {
//        var indexesToRemove = [Int]()
//        for index in 0..<GV.allWords.count {
//            if !GV.allWords[index].mandatory {
//                indexesToRemove.append(index)
//            }
//        }
//        let indexesSorted = indexesToRemove.sorted(by: {$0 > $1})
//        for index in indexesSorted {
//            GV.allWords.remove(at:index)
//        }
//    }
//
    private func getPlayingRecord(new: Bool, next: StartType) {
        var actGames = realm.objects(GameDataModel.self).filter("nowPlaying = TRUE and language = %@", GV.aktLanguage)
        if new {
            let games = realm.objects(GameDataModel.self).filter("gameStatus = %d and language = %@", GV.GameStatusNew, GV.aktLanguage)
            /// reset all records with nowPlaying status
            if actGames.count > 0 {
                try! realm.write {
                    for actGame in actGames {
                        actGame.nowPlaying = false
                    }
                }
            }
//            wtGameWordList = WTGameWordList(delegate: self)
            if games.count > 0 {
                GV.playingRecord = games[0]
                realm.beginWrite()
                GV.playingRecord.nowPlaying = true
                GV.playingRecord.time = "0"
                try! realm.commitWrite()
            } else {
                let newGameNumber = realm.objects(GameDataModel.self).filter("language = %@", GV.aktLanguage).count + GV.gameNumberAdder[GV.aktLanguage]!
                let mandatoryRecord: MandatoryModel? = realmMandatory.objects(MandatoryModel.self).filter("gameNumber = %d and language = %@", newGameNumber, GV.aktLanguage).first!
                if mandatoryRecord != nil {
                    try! realm.write {
                        GV.playingRecord = GameDataModel()
                        GV.playingRecord.mandatoryWords = mandatoryRecord!.mandatoryWords
                        GV.playingRecord.gameNumber = mandatoryRecord!.gameNumber
                        GV.playingRecord.language = GV.aktLanguage
                        GV.playingRecord.time = "0"
                        realm.add(GV.playingRecord)
                    }
                }
            }
        } else {
            var first = true
            if actGames.count > 0 {
                for actGame in actGames {
                    if !first {
                        try! realm.write {
                            actGame.nowPlaying = false
                        }
                    }
                    first = false
                }
            } else {
                actGames = realm.objects(GameDataModel.self).filter("gameStatus = %d and language = %@", GV.GameStatusPlaying, GV.aktLanguage)
                if actGames.count > 0 {
                    try! realm.write {
                        actGames[0].nowPlaying = true
                    }
                }
            }
            let playedNowGame = realm.objects(GameDataModel.self).filter("nowPlaying = TRUE and language = %@", GV.aktLanguage)
            if playedNowGame.count > 0 {
                let actGameNumber = playedNowGame.first!.gameNumber
                switch nextGame {
                case .NoMore:
                    GV.playingRecord = playedNowGame[0]
                case .PreviousGame:
                    let previousRecords = realm.objects(GameDataModel.self).filter("gameStatus = %d and gameNumber < %d",
                                                                                  GV.GameStatusPlaying, actGameNumber)
                    if previousRecords.count == 1 {
                        GV.playingRecord = previousRecords[0]
                    } else if let record = Array(previousRecords).sorted(by: {$0.gameNumber < $1.gameNumber}).last {
                        GV.playingRecord = record
                    } else {
                        GV.playingRecord = playedNowGame.first!
                    }
                case .NextGame:
                    let nextRecords = realm.objects(GameDataModel.self).filter(" gameStatus = %d and gameNumber > %d",
                                                                                   GV.GameStatusPlaying, actGameNumber)
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
    
    public func setGameArt(new: Bool, next: StartType) {
        self.new = new
        self.nextGame = next
    }
    
    private func createHeader() {
        if self.childNode(withName: timeName) == nil {
            timeLabel = SKLabelNode(fontNamed: "CourierNewPS-BoldMT") // Snell Roundhand")
            let YPosition: CGFloat = self.frame.height * 0.92
            let xPosition = self.frame.size.width * 0.8
            timeLabel.position = CGPoint(x: xPosition, y: YPosition)
            timeLabel.fontSize = self.frame.size.height * 0.0175
            timeLabel.fontColor = .black
            timeLabel.text = GV.language.getText(.tcTime, values: timeForGame.time.HourMinSec)
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
        
        
   }
    
    override func update(_ currentTime: TimeInterval) {
        if checkIfGameFinished() {
//            self.view?.isUserInteractionEnabled = false
        }
    }
    
    private func modifyHeader() {
        let gameNumber = GV.playingRecord.gameNumber - GV.gameNumberAdder[GV.aktLanguage]!
        let text = GV.language.getText(.tcHeader, values: String(gameNumber + 1), String(GV.playingRecord.rounds.count), String(totalScore))
        headerLabel.text = text
    }

    func scrollOwnWords(up: Bool) {
        if up {
            showingOwnWordsIndex += countWordsInRow
            let countOwnWords = WTGameWordList.shared.getCountWords(mandatory: false)
            if showingOwnWordsIndex + countShowingOwnWords > countOwnWords {
                let countShowedRows = countShowingOwnWords / countWordsInRow
                let startRow = countOwnWords / countWordsInRow - countShowedRows + 1
                showingOwnWordsIndex =  startRow * countWordsInRow
            }
        } else {
            showingOwnWordsIndex -= countWordsInRow
            if showingOwnWordsIndex < 0 {
                showingOwnWordsIndex = 0
            }
        }
        showFoundedWords()
    }
    func showFoundedWords() {
        let myMandatoryWords = WTGameWordList.shared.getMandatoryWords()
        for actWord in myMandatoryWords {
            let label = self.childNode(withName: actWord.word) as? SKLabelNode
            if label != nil {
                label!.text = actWord.word + " (\(actWord.counter)) "
            }
        }

        if let label = self.childNode(withName: mandatoryWordsHeaderName)! as? SKLabelNode {
            label.text = GV.language.getText(.tcWordsToCollect, values: String(WTGameWordList.shared.getCountWords(mandatory: true)), String(WTGameWordList.shared.getCountFoundedWords(mandatory: true, countFoundedMandatory: true)),
                String(WTGameWordList.shared.getCountFoundedWords(mandatory: true, countAll: true)),
                String(WTGameWordList.shared.getScore(mandatory: true)))
        }
        if let label = self.childNode(withName: ownWordsHeaderName)! as? SKLabelNode {
                label.text = GV.language.getText(.tcOwnWords, values: String(WTGameWordList.shared.getCountWords(mandatory: false)), String(WTGameWordList.shared.getCountFoundedWords(mandatory: false, countAll: true)),
                    String(WTGameWordList.shared.getScore(mandatory: false)))
        }
        modifyHeader()

    }
    
    func addOwnWordNew(word: String, usedLetters: [UsedLetter])->Bool {
        var returnBool = false
        if realmWordList.objects(WordListModel.self).filter("word = %@", GV.aktLanguage + word.lowercased()).count == 1 {
            let selectedWord = SelectedWord(word: word, usedLetters: usedLetters)
            let boolValue = WTGameWordList.shared.addWord(selectedWord: selectedWord)
            returnBool = boolValue
        }
//        else {
//            blinkWords(newWord: SelectedWord(word: word, usedLetters: usedLetters))
//        }
        if !returnBool {
            blinkWords(newWord: SelectedWord(word: word, usedLetters: usedLetters))
        }
        return returnBool
    }
    
//    private func addOwnWord(ownWord: WordToCheck) {
//        _ = addOwnWordOld(word: ownWord.word, creationIndex: ownWord.creationIndex, check: false)
//    }
    
    private func removeAllSubviews() {
        for subView in self.view!.subviews {
            subView.removeFromSuperview()
        }
    }
    var line = 0
    @objc func undoTapped() {
        stopShowingTableIfNeeded()
        startUndo()
    }
    @objc func goBackTapped() {
        stopShowingTableIfNeeded()
        timer!.invalidate()
        timer = nil
        removeAllSubviews()
        wtSceneDelegate!.gameFinished(start: .NoMore)
    }
    @objc func goPreviousGame() {
        stopShowingTableIfNeeded()
        timer!.invalidate()
        timer = nil
        removeAllSubviews()
        wtSceneDelegate!.gameFinished(start: .PreviousGame)
    }
    
    @objc func showAllWordsInTableView() {
        stopShowingTableIfNeeded()
        showOwnWordsInTableView()
        showingWordsInTable = true
    }

    @objc func goNextGame() {
        stopShowingTableIfNeeded()
        timer!.invalidate()
        timer = nil
        removeAllSubviews()
        wtSceneDelegate!.gameFinished(start: .NextGame)
    }
    var goToPreviousGameButton: UIButton?
    var goToNextGameButton: UIButton?
    var undoButton: UIButton?
    var allWordsButton: UIButton?
    var goBackButton: UIButton?

    func createGoToPreviousGameButton(enabled: Bool) {
        if goToPreviousGameButton != nil {
            goToPreviousGameButton?.removeFromSuperview()
            goToPreviousGameButton = nil
        }
        let frame = CGRect(x: 0, y: 0, width:self.frame.width * 0.09, height: self.frame.width * 0.09)
        let center = CGPoint(x:self.frame.width * 0.08, y:self.frame.height * 0.92)
        let radius = self.frame.width * 0.045
        goToPreviousGameButton = createButton(imageName: "previousGame", title: "", frame: frame, center: center, cornerRadius: radius, enabled: enabled )
        goToPreviousGameButton?.addTarget(self, action: #selector(self.goPreviousGame), for: .touchUpInside)
        self.view?.addSubview(goToPreviousGameButton!)
        self.view?.addSubview(goToPreviousGameButton!)
    }
    func createGoToNextGameButton(enabled: Bool) {
        if goToNextGameButton != nil {
            goToNextGameButton?.removeFromSuperview()
            goToNextGameButton = nil
        }
        let frame = CGRect(x: 0, y: 0, width:self.frame.width * 0.09, height: self.frame.width * 0.09)
        let center = CGPoint(x:self.frame.width * 0.92, y:self.frame.height * 0.92)
        let radius = self.frame.width * 0.045
        goToNextGameButton = createButton(imageName: "nextGame", title: "", frame: frame, center: center, cornerRadius: radius, enabled: enabled )
        goToNextGameButton?.addTarget(self, action: #selector(self.goNextGame), for: .touchUpInside)
        self.view?.addSubview(goToNextGameButton!)
    }
    
    func createShowAllWordsButton() {
        if allWordsButton != nil {
            allWordsButton?.removeFromSuperview()
            allWordsButton = nil
        }
        var ownHeaderYPos = CGFloat(0)
        let ownHeader: SKNode = (self.childNode(withName: ownWordsHeaderName) as! SKLabelNode)
        let title = GV.language.getText(.tcShowAllWords)
        let wordLength = title.width(font: myTitleFont!)
        let wordHeight = title.height(font: myTitleFont!)
        let frame = CGRect(x: 0, y: 0, width:wordLength * 1.2, height: wordHeight * 2)
        ownHeaderYPos = self.frame.height - ownHeader.frame.midY + frame.height
        let center = CGPoint(x:self.frame.width * 0.5, y: ownHeaderYPos) //self.frame.height * 0.20)
        let radius = frame.height * 0.5
        allWordsButton = createButton(imageName: "", title: title, frame: frame, center: center, cornerRadius: radius, enabled: true )
        allWordsButton?.addTarget(self, action: #selector(self.showAllWordsInTableView), for: .touchUpInside)
        allWordsButton?.layer.zPosition = -100
        self.view?.addSubview(allWordsButton!)
    }

    private func createGoBackButton() {
        if goBackButton != nil {
            goBackButton?.removeFromSuperview()
            goBackButton = nil
        }
        let frame = CGRect(x: 0, y: 0, width:self.frame.width * 0.08, height: self.frame.width * 0.08)
        let center = CGPoint(x:self.frame.width * 0.05, y:self.frame.height * 0.08)
        let radius = self.frame.width * 0.04
        goBackButton = createButton(imageName: "back", title: "", frame: frame, center: center, cornerRadius: radius, enabled: true)
        goBackButton!.addTarget(self, action: #selector(self.goBackTapped), for: .touchUpInside)
        self.view?.addSubview(goBackButton!)
    }
    
    private func createUndo(enabled: Bool) {
        if undoButton != nil {
            undoButton?.removeFromSuperview()
            undoButton = nil
        }
        let enabled = activityRoundItem[0].activityItems.count > 0
        let frame = CGRect(x: 0, y: 0, width:self.frame.width * 0.08, height: self.frame.width * 0.08)
        let center = CGPoint(x:self.frame.width * 0.95, y:self.frame.height * 0.08)
        let radius = self.frame.width * 0.04
        undoButton = createButton(imageName: "undo", title: "", frame: frame, center: center, cornerRadius: radius, enabled: enabled)
        undoButton?.addTarget(self, action: #selector(self.undoTapped), for: .touchUpInside)
        self.view?.addSubview(undoButton!)
    }
    
    private func createButton(imageName: String, title: String, frame: CGRect, center: CGPoint, cornerRadius: CGFloat, enabled: Bool)->UIButton {
        let button = UIButton()
        if imageName.length > 0 {
            let image = UIImage(named: imageName)
            button.setImage(image, for: UIControlState.normal)
        }
        if title.length > 0 {
            button.setTitle(title, for: .normal)
            button.setTitleColor(UIColor.black, for: .normal)
            button.titleLabel?.font = myTitleFont
        }
        button.backgroundColor = bgColor
        button.layer.cornerRadius = cornerRadius
        button.alpha = enabled ? 1.0 : 0.2
        button.isEnabled = enabled
        button.layer.borderWidth = GV.onIpad ? 5 : 3
        button.layer.borderColor = UIColor(red: 220/255, green: 220/255, blue: 220/255, alpha: 1.0).cgColor
        button.frame = frame
        button.center = center
        return button
    }
    
    private func showWordsToCollect() {
        var counter = 1
//        let wordList = GV.playingRecord.mandatoryWords.uppercased().components(separatedBy: "°")
        let wordList = WTGameWordList.shared.getMandatoryWords()
        for word in wordList {
//            GV.allWords.append(WordToCheck(word: word, mandatory: true, creationIndex: NoValue, countFounded: 0))
//            var wordToShow = AllWordsToShow(word: word)
//            allWordsToShow.append(wordToShow)
//            let wordToShow = WordToCheck(word: word.word, countFounded: 0, mandatory: true, creationIndex: 0, score: 0)
            createWordLabel(wordToShow: word, counter: counter)
            counter += 1
        }
        createLabel(word: GV.language.getText(.tcWordsToCollect, values: String(WTGameWordList.shared.getCountWords(mandatory: true)), "0","0", "0"), first: true, name: mandatoryWordsHeaderName)
        createLabel(word: GV.language.getText(.tcOwnWords, values:
                    String(WTGameWordList.shared.getCountWords(mandatory: false)),
                    String(WTGameWordList.shared.getCountFoundedWords(mandatory: false, countAll: true)),
                    String(WTGameWordList.shared.getScore(mandatory: false))), first: false, name: ownWordsHeaderName)

    }
    
    private func createWordLabel(wordToShow: WordWithCounter, counter: Int) {
        let xPositionMultiplier = [0.2, 0.5, 0.8]
        let mandatoryYPositionMultiplier:CGFloat = 0.86
//        let ownYPositionMultiplier:CGFloat = 0.80 // orig
        let distance: CGFloat = 0.02
        let label = SKLabelNode(fontNamed: "TimesNewRomanPS-BoldMT")// Snell Roundhand")
        let wordRow = CGFloat((counter - 1) / countWordsInRow)
        let wordColumn = (counter - 1) % countWordsInRow
        let value = wordRow * distance
        var yPosition: CGFloat = 0
//        let showWord = true
//        if !own {
            yPosition = self.frame.height * (mandatoryYPositionMultiplier - value)
//        }
//        else {
//            let minY = wtGameboard!.children[0].frame.maxY
//            var maxY:CGFloat = 0
//            let ownHeader: SKNode? = self.childNode(withName: ownWordsHeaderName)
//            if ownHeader != nil {
//                let headerPosY = ownHeader!.position.y
//                maxY = headerPosY
//            }
//
//            yPosition = self.frame.height * (ownYPositionMultiplier - value)
//            if yPosition <= minY || yPosition >= maxY{
//                showWord = false
//            }
//        }
        let xPosition = self.frame.size.width * CGFloat(xPositionMultiplier[wordColumn])
        label.position = CGPoint(x: xPosition, y: yPosition)
        label.fontSize = self.frame.size.height * 0.0175
        label.fontColor = .black
        label.text = wordToShow.word + " (\(wordToShow.counter))"
        label.name = wordToShow.word
        label.zPosition = self.zPosition + 10
        self.addChild(label)
//        if !showWord {
//            label.isHidden = true
//        }
//        setOwnWordsIndex()
    }
    
//    private func setOwnWordsIndex() {
//        let countOwnWords = WTGameWordList.shared.getCountWords(mandatory: false)
//        if countOwnWords > countShowingOwnWords {
//            let countShowedRows = countShowingOwnWords / countWordsInRow
//            let startRow = countOwnWords / countWordsInRow - countShowedRows + 1
//            showingOwnWordsIndex =  startRow * countWordsInRow
//        }
//    }
//    
    private func createLabel(word: String, first: Bool, name: String) {
        let ownYPosition: [CGFloat] = [0.82, 0.80, 0.78]
        let label = SKLabelNode(fontNamed: "TimesNewRomanPS-BoldMT") // Snell Roundhand")
        let yIndex = (WTGameWordList.shared.getCountWords(mandatory: true) / countWordsInRow) - 2
        let yPosition = self.frame.height * (first ? 0.88 : ownYPosition[yIndex])
        let xPosition = self.frame.size.width * 0.5
        label.position = CGPoint(x: xPosition, y: yPosition)
        label.fontSize = self.frame.size.height * 0.018
        label.fontColor = .black
        label.text = word
        label.name = name
        self.addChild(label)
    }
    
    private func play() {
        timerIsCounting = true
        WTGameWordList.shared.setDelegate(delegate: self)
        timeForGame = TimeForGame(from: GV.playingRecord.time)
        createHeader()
        myTimer = MyTimer(time: timeForGame)
        addChild(myTimer!)
        wtGameboard = WTGameboard(size: sizeOfGrid, parentScene: self, delegate: self)
        generateArrayOfWordPieces(new: new)
        indexOfTilesForGame = 0
        ws = Array(repeating: WTPiece(), count: 3)
        for index in 0..<3 {
            origPosition[index] = CGPoint(x:self.frame.width * shapeMultiplicator[index], y:self.frame.height * heightMultiplicator)
        }
        if !new {
            wtGameboard!.setRoundInfos()
            WTGameWordList.shared.setDelegate(delegate: self)
            WTGameWordList.shared.restoreFromPlayingRecord()
            restoreGameArray()
        } else {
            if GV.playingRecord.rounds.count == 0 {
                try! realm.write {
                    let rounds = RoundDataModel()
                    GV.playingRecord.rounds.append(rounds)
                }
            }

            ws = Array(repeating: WTPiece(), count: 3)
//            roundIndexes.append(0)
            for index in 0..<3 {
                ws[index] = getNextPiece(horizontalPosition: index)
                origSize[index] = ws[index].size
                ws[index].position = origPosition[index]
                ws[index].name = "Pos\(index)"
                self.addChild(ws[index])
            }
        }
        modifyHeader()
        createGoToPreviousGameButton(enabled: hasPreviousRecords(playingRecord: GV.playingRecord))
        createGoToNextGameButton(enabled: hasNextRecords(playingRecord: GV.playingRecord))
        createShowAllWordsButton()
//        if  hasPreviousRecords(playingRecord: GV.playingRecord) {
//
//            goToPreviousGameButton.alpha = 1.0
//            goToPreviousGameButton.isEnabled = true
//        } else {
//            goToPreviousGameButton.alpha = 0.2
//            goToPreviousGameButton.isEnabled = false
//        }
        
        if timer != nil {
            timer!.invalidate()
        }
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(countTime(timerX: )), userInfo: nil, repeats: true)
        countTime(timerX: Timer())
    }
    
    private func hasPreviousRecords(playingRecord: GameDataModel)->Bool {
        return realm.objects(GameDataModel.self).filter("gameStatus = %d and gameNumber < %d and language = %@",
            GV.GameStatusPlaying, playingRecord.gameNumber, GV.aktLanguage).count > 0
    }
    
    private func hasNextRecords(playingRecord: GameDataModel)->Bool {
        return realm.objects(GameDataModel.self).filter("gameStatus = %d and gameNumber > %d and language = %@",
            GV.GameStatusPlaying, playingRecord.gameNumber, GV.aktLanguage).count > 0
    }
    
    @objc private func countTime(timerX: Timer) {
        let state = UIApplication.shared.applicationState
        if state == .background {
//            print("App in Background")
        } else if state == .active && timerIsCounting {
            timeForGame.incrementTime()
        }
        timeLabel.text = GV.language.getText(.tcTime, values: timeForGame.remainingTime.HourMinSec)
        realm.beginWrite()
        GV.playingRecord.time = timeForGame.toString()
        try! realm.commitWrite()
        if myTimer!.update(time: timeForGame) {
            timer!.invalidate()
            timer = nil
            showGameFinished(status: .TimeOut)
        }
    }
    
    private func generateArrayOfWordPieces(new: Bool) {
        if new || GV.playingRecord.pieces.count == 0 {
            try! realm.write {
                GV.playingRecord.pieces = generateArrayOfWordPieces()
            }
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
    #if SHOWFINGER
    var finger: SKSpriteNode?
    var fingerAdder: CGFloat = -20
    #endif
    
    private func stopShowingTableIfNeeded() {
        if showingWordsInTable /* && !touchedNodes.showOwnWordsButton */ {
            WTGameWordList.shared.stopShowingWords()
            showingWordsInTable = false
            if tableType == .ShowAllWords {
                showOwnWordsTableView?.removeFromSuperview()
            } else {
                showWordsOverPositionTableView?.removeFromSuperview()
            }
            timerIsCounting = true
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        startShapeIndex = -1
        self.scene?.alpha = 1.0
        if wtSceneDelegate == nil {
            return
        }
        moved = false
        inChoosingOwnWord = false
//        ownWordsScrolling = false
        let firstTouch = touches.first
        firstTouchLocation = firstTouch!.location(in: self)
//        let nodes = self.nodes(at: firstTouchLocation)
//        let nodes1 = self.nodes(at: CGPoint(x: firstTouchLocation.x, y: firstTouchLocation.y + blockSize * 0.11))
//        let touchedNodes = analyzeNodes(nodes: nodes, nodes1: nodes1, calledFrom: .start)
        #if SHOWFINGER
        let texture = SKTexture(imageNamed: "finger")
        finger = SKSpriteNode(texture: texture)
        let sizeDivider = GV.onIpad ? CGFloat(6) : CGFloat(12)
        finger?.size = CGSize(width: (finger?.size.width)! / sizeDivider, height: (finger?.size.height)! / sizeDivider)
        finger?.position = firstTouchLocation + CGPoint(x: 0, y: fingerAdder)
        self.addChild(finger!)
        #endif
        stopShowingTableIfNeeded()
        let touchedNodes = analyzeNodes(touchLocation: firstTouchLocation, calledFrom: .start)
//        if touchedNodes.undo {
//            undoTouched = true
//        }
        if touchedNodes.gameFinishedOKButton {
            wtGameFinishedSprite.OKButtonPressed()
        }
        if touchedNodes.shapeIndex > NoValue {
            startShapeIndex = touchedNodes.shapeIndex
            ws[touchedNodes.shapeIndex].zPosition = 10
            wtGameboard!.clear()
        } else if touchedNodes.GCol.between(min: 0, max: sizeOfGrid - 1) && touchedNodes.GRow.between(min:0, max: sizeOfGrid - 1){
            inChoosingOwnWord = true
            wtGameboard?.startChooseOwnWord(col: touchedNodes.GCol, row: touchedNodes.GRow)
//        } else if touchedNodes.ownWordsBackground {
//            ownWordsScrolling = true
//            ownWordsScrollingStartPos = firstTouchLocation
        }

    }
    
    func setMovingSprite() {
        movingSprite = true
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if wtSceneDelegate == nil {
            return
        }
        let firstTouch = touches.first
        let touchLocation = firstTouch!.location(in: self)
        #if SHOWFINGER
        finger?.position = touchLocation + CGPoint(x: 0, y: fingerAdder)
        #endif
//        let nodes = self.nodes(at: touchLocation)
//        let nodes1 = self.nodes(at: CGPoint(x: touchLocation.x, y: touchLocation.y + blockSize * 0.11))
        let touchedNodes = analyzeNodes(touchLocation: touchLocation, calledFrom: .move)
        if moved {
            let sprite = ws[movedIndex]
            sprite.position = touchLocation + CGPoint(x: 0, y: blockSize * WSGameboardSizeMultiplier)
            sprite.alpha = 0.0
            if wtGameboard!.moveSpriteOnGameboard(col: touchedNodes.col, row: touchedNodes.row, GRow: touchedNodes.GRow) {  // true says moving finished
                if touchedNodes.row == sizeOfGrid { // when at bottom
                    sprite.alpha = 1.0
                }
            }

        } else if inChoosingOwnWord {
            if movingSprite {
//                if wtGameboard!.moveSpriteOnGameboard(col: touchedNodes.col, row: touchedNodes.row + 2, GRow: touchedNodes.GRow) {
//                    _ = wtGameboard!.moveSpriteOnGameboard(col: touchedNodes.col, row: touchedNodes.row + 1, GRow: touchedNodes.GRow)
//                }
            } else if touchedNodes.GCol >= 0 && touchedNodes.GCol < sizeOfGrid && touchedNodes.GRow >= 0 && touchedNodes.GRow < sizeOfGrid {
                movingSprite = (wtGameboard?.moveChooseOwnWord(col: touchedNodes.GCol, row: touchedNodes.GRow))!
            }
            if movingSprite {
                if wtGameboard!.moveSpriteOnGameboard(col: touchedNodes.col, row: touchedNodes.row + 2, GRow: touchedNodes.GRow) {
//                    _ = wtGameboard!.moveSpriteOnGameboard(col: touchedNodes.col, row: touchedNodes.row + 1, GRow: touchedNodes.GRow)
                }
            }
        } else  {
            if touchedNodes.shapeIndex >= 0 {
                ws[touchedNodes.shapeIndex].position = touchLocation
            }
            let yDistance = (touchLocation - firstTouchLocation).y
            if yDistance > blockSize / 2 && touchedNodes.row >= 0 && touchedNodes.row < sizeOfGrid {
                if touchedNodes.shapeIndex >= 0 {
                    moved = wtGameboard!.startShowingSpriteOnGameboard(shape: ws[touchedNodes.shapeIndex], col: touchedNodes.col, row: touchedNodes.row) //, shapePos: touchedNodes.shapeIndex)
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

//    private func analyzeNodes(nodes: [SKNode], nodes1: [SKNode], calledFrom: CalledFrom)->TouchedNodes {
    private func analyzeNodes(touchLocation: CGPoint, calledFrom: CalledFrom)->TouchedNodes {
        let nodes = self.nodes(at: touchLocation)
        var touchedNodes = TouchedNodes()
        for node in nodes {
            guard let name = node.name else {
                continue
            }
            if enabled || gameboardEnabled {
//                if name == goBackName {
//                    touchedNodes.goBack = enabled
//                }
//                if name == previousName {
//                    touchedNodes.goPreviousGame = enabled
//                }
//                if name == nextName {
//                    touchedNodes.goNextGame = enabled
//                } else if name == undoName {
//                    touchedNodes.undo = enabled
//                } else
                if name == GameFinishedOKName {
                    touchedNodes.gameFinishedOKButton = true
                } else if name == ownWordsButtonName {
                    touchedNodes.showOwnWordsButton = true
                } else if name.begins(with: "GBD") {
                    touchedNodes.GCol = Int(name.subString(startPos: 4, length:1))!
                    touchedNodes.GRow = Int(name.subString(startPos: 6, length:1))!
                } else if let number = Int(name.subString(startPos: 3, length: name.count - 3)) {
                    if enabled {
                        let nameStartedWith = name.subString(startPos: 0, length: 3)
                        if startShapeIndex >= 0 {
                            touchedNodes.shapeIndex = startShapeIndex
                        }
                        if nameStartedWith == "Col" {
                            touchedNodes.col = number
                        } else if nameStartedWith == "Row" {
                            touchedNodes.row = number
                        } else if nameStartedWith == "Pos" {
                            touchedNodes.shapeIndex = number
                        }
                    }
                }
            }
            if name == answer1Name {
               touchedNodes.answer1 = true
            } else if name == answer2Name {
                touchedNodes.answer2 = true
//            } else if name == ownWordsBackgroundName {
//                touchedNodes.ownWordsBackground = true
            }
        }
//        if touchedNodes.GRow == -1 {
//            for node in nodes1 {
//                guard let name = node.name else {
//                    continue
//                }
//                if name.begins(with: "GBD") {
//                    touchedNodes.GRow = Int(name.subString(startPos: 6, length:1))!
//                }
//            }
//        }
        return touchedNodes
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if wtSceneDelegate == nil {
            return
        }
        let firstTouch = touches.first
        let touchLocation = firstTouch!.location(in: self)
        #if SHOWFINGER
        finger?.removeFromParent()
        #endif
//        let nodes = self.nodes(at: touchLocation)
        let lastPosition = ws.count - 1
//        let nodes1 = self.nodes(at: CGPoint(x: touchLocation.x, y: touchLocation.y + blockSize * 0.11))
        let touchedNodes = analyzeNodes(touchLocation: touchLocation, calledFrom: .stop)
        if touchedNodes.answer1 {
            gameboardEnabled = true
            removeNodesWith(name: MyQuestionName)
            self.addChild(createButton(withText: GV.language.getText(.tcNoMoreStepsAnswer2), position:CGPoint(x: self.size.width * 0.5, y: self.size.height * 0.94), name: answer2Name))
        }
        if touchedNodes.answer2 {
            wtGameboard!.clearGreenFieldsForNextRound()
            if !checkFreePlace() {
                showGameFinished(status: .NoMoreSteps)
            } else {
//                roundIndexes.append(activityItems.count - 1)
                realm.beginWrite()
                let newRound = RoundDataModel()
//                newRound.index = activityItems.count - 1
                newRound.gameArray = wtGameboard!.gameArrayToString()
                GV.playingRecord.rounds.append(newRound)
                timeForGame.incrementMaxTime(value: iHalfHour)
                WTGameWordList.shared.addNewRound()
                activityRoundItem.append(ActivityRound())
                activityRoundItem[activityRoundItem.count - 1].activityItems = [ActivityItem]()
                try! realm.commitWrite()
                modifyHeader()
            }
            enabled = true
            gameboardEnabled = false
            removeNodesWith(name: MyQuestionName)
            removeNodesWith(name: answer2Name)
       }
        if inChoosingOwnWord {
            if movingSprite {
                movingSprite = false
                let row = touchedNodes.row + 2 == 10 ? 9 : touchedNodes.row + 2
                _ = wtGameboard!.stopShowingSpriteOnGameboard(col: touchedNodes.col, row: row, fromBottom: false)
            } else {
                let word = wtGameboard!.endChooseOwnWord(col: touchedNodes.GCol, row: touchedNodes.GRow)
                if word != nil {
                    let activityItem = ActivityItem(type: .Choosing, choosedWord: word!)
                    activityRoundItem[activityRoundItem.count - 1].activityItems.append(activityItem)
    //                activityItems.append(activityItem)
                    saveActualState()
                }
            }
        } else if moved {
            let fixed = wtGameboard!.stopShowingSpriteOnGameboard(col: touchedNodes.col, row: touchedNodes.row, fromBottom: true)
            if fixed {
                ws[movedIndex].zPosition = 1
                ws[movedIndex].setPieceFromPosition(index: movedIndex)
                let activityItem = ActivityItem(type: .FromBottom, fromBottomIndex: ws[movedIndex].getArrayIndex())
                if activityRoundItem.count > 0 {
                    if activityRoundItem.last!.activityItems.count == 0 {
                        activityRoundItem[activityRoundItem.count - 1].activityItems = [ActivityItem]()
                    }
                } else {
                    activityRoundItem.append(ActivityRound())
                    activityRoundItem[activityRoundItem.count - 1].activityItems = [ActivityItem]()
                }
                activityRoundItem[activityRoundItem.count - 1].activityItems.append(activityItem)
//                activityItems.append(activityItem)
                createUndo(enabled: true)
//                undoSprite.alpha = 1.0
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
//                checkIfGameFinished()
                if !freePlaceFound {
                    let question = MyQuestion(question: .NoMoreSteps, parentSize: self.size)
                    question.position = CGPoint(x:self.size.width * 0.5, y: self.size.height * 0.5)
                    self.addChild(question)
                    enabled = false
                }
               saveActualState()
            } else {
                ws[movedIndex].position = origPosition[movedIndex]
//                ws[movedIndex].scale(to: origSize[movedIndex])
                ws[movedIndex].alpha = 1
            }
            moved = false
        } else if self.nodes(at: touchLocation).count > 0 {
            if touchedNodes.shapeIndex >= 0 && startShapeIndex == touchedNodes.shapeIndex {
                    ws[touchedNodes.shapeIndex].rotate()
                    ws[touchedNodes.shapeIndex].position = origPosition[touchedNodes.shapeIndex]
            }
        }
        startShapeIndex = -1
//        checkIfGameFinished()
    }
    
    private func checkIfGameFinished()->Bool {
//        if GV.allMandatoryWordsFounded() {
        if WTGameWordList.shared.gameFinished() {
            realm.beginWrite()
            GV.playingRecord.score = WTGameWordList.shared.getScore(forAll: true)
            GV.playingRecord.gameStatus = GV.GameStatusFinished
            GV.playingRecord.nowPlaying = false
            GV.playingRecord.pieces = ""
//            GV.playingRecord.activityItems = ""
            GV.playingRecord.time = "0"
            GV.playingRecord.rounds.removeAll()
            try! realm.commitWrite()
            enabled = false
            wtGameFinishedSprite.showFinish(status: .OK)
            return true
        }
        return false
    }
    
    private func showGameFinished(status: GameFinisheStatus) {
        enabled = false
        wtGameFinishedSprite.showFinish(status: status)
        realm.beginWrite()
        GV.playingRecord.gameStatus = GV.GameStatusFinished
        try! realm.commitWrite()
    }
    
    private func saveActualState() {
        var pieces = ""
        for tile in tilesForGame {
            pieces += tile.toString() + "°"
        }
//        var tempOwnWords = ""
//        for item in GV.allWords {
//            if !item.mandatory {
//                tempOwnWords += item.toString() + "°"
//            }
//        }
        try! realm.write {
//            GV.playingRecord.ownWords = tempOwnWords
            GV.playingRecord.pieces = pieces
            GV.playingRecord.gameStatus = GV.GameStatusPlaying
            var rounds: RoundDataModel
            if GV.playingRecord.rounds.count == 0 {
                let rounds = RoundDataModel()
                GV.playingRecord.rounds.append(rounds)
            }
            rounds = GV.playingRecord.rounds.last!
//            rounds.index = roundIndexes.last!
//            rounds.infos = wtGameboard!.roundInfosToString(all:false)
            rounds.infos = WTGameWordList.shared.toStringLastRound()
            rounds.gameArray  = wtGameboard!.gameArrayToString()
    //        GV.playingRecord.roundGameArrays = wtGameboard!.gameArrayToString()
            
            
            var activityItemsString = ""
            let actCount = activityRoundItem[activityRoundItem.count - 1].activityItems.count
            if actCount > 0 {
                for index in 0..<actCount {
                    let actItem = activityRoundItem[activityRoundItem.count - 1].activityItems[index]
                    activityItemsString += actItem.type.description + itemInnerSeparator
                    switch actItem.type  {
                    case .FromBottom:
                        activityItemsString += String(actItem.fromBottomIndex)
                    case .Moving:
                        activityItemsString += actItem.movingItem.toString()
                    case .Choosing:
                        activityItemsString += String(actItem.choosedWord.toString())
                    }
                    activityItemsString += itemSeparator
                }
                activityItemsString.removeLast()
                rounds.activityItems = activityItemsString
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
        if activityRoundItem[activityRoundItem.count - 1].activityItems.count == 0 {
            try! realm.write() {
                if activityRoundItem.count > 0 {
                    GV.playingRecord.rounds.removeLast()
                    timeForGame.decrementMaxTime(value: iHalfHour)
                    wtGameboard!.stringToGameArray(string: GV.playingRecord.rounds.last!.gameArray)
//                    WTGameWordList.shared.getPreviousRound()
                    activityRoundItem.removeLast()
                    modifyHeader()
                } else {
                    createUndo(enabled: false)
//                    undoSprite.alpha = 0.1
                }
            }

        } else if activityRoundItem[activityRoundItem.count - 1].activityItems.count > 0 {
            switch activityRoundItem[activityRoundItem.count - 1].activityItems.last!.type {
            case .FromBottom:
                let indexOfLastPiece = activityRoundItem[activityRoundItem.count - 1].activityItems.last!.fromBottomIndex
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
//                    wtGameboard!.checkWholeWords()
                activityRoundItem[activityRoundItem.count - 1].activityItems.removeLast()
            case .Moving:
//                var multiplier = 1
                let item = activityRoundItem[activityRoundItem.count - 1].activityItems.last!
//                print(item.toString())
                wtGameboard!.moveItemToOrigPlace(movedItem: item.movingItem)
                activityRoundItem[activityRoundItem.count - 1].activityItems.removeLast()
//                wtGameboard!.checkWholeWords()
                modifyHeader()
            case .Choosing:
                let actItem = activityRoundItem[activityRoundItem.count - 1].activityItems.last!
                let selectedWord = SelectedWord(word: actItem.choosedWord.word, usedLetters: actItem.choosedWord.usedLetters)
                WTGameWordList.shared.removeLastWord(selectedWord: selectedWord)
//                if let index = GV.allWords.index(where: {$0.word == actItem.choosedWord.word}) {
//                    GV.allWords.remove(at: index)
//                }
//                if let label = self.childNode(withName: actItem.choosedWord.word)! as? SKLabelNode {
//                    label.removeFromParent() // This word is no more known
//                }
//                var lengthOfWord = actItem.choosedWord.word.count
//                lengthOfWord = lengthOfWord > 10 ? 11 : lengthOfWord
//                myTimer!.decreaseMaxTime(value: timeIncreaseValues![lengthOfWord])
//                wtGameboard!.checkWholeWords()
                activityRoundItem[activityRoundItem.count - 1].activityItems.removeLast()
//                showLastOwnWords()
                modifyHeader()
            }
        }
        if activityRoundItem[activityRoundItem.count - 1].activityItems.count == 0 {
            createUndo(enabled: false)
//            undoSprite.alpha = 0.1
        }
            
    }
    
    func restoreGameArray() {
        func addPieceAsChild(pieceIndex: Int, piece: WTPiece) {
            // remove the piece from this position, if exists
            removeNodesWith(name: "Pos\(pieceIndex)")
            ws[pieceIndex] = piece
            ws[pieceIndex].position = origPosition[pieceIndex]
            origSize[pieceIndex] = piece.size
            ws[pieceIndex].name = "Pos\(pieceIndex)"
            self.addChild(ws[pieceIndex])
        }
        activityRoundItem = [ActivityRound]()
        for round in GV.playingRecord.rounds {
            activityRoundItem.append(ActivityRound())
            activityRoundItem[activityRoundItem.count - 1].activityItems = [ActivityItem]()
            let activityItemsArray = round.activityItems.components(separatedBy: itemSeparator)
            for activityItem in activityItemsArray {
                if activityItem != "" {
                    let itemValue = ActivityItem(fromString: activityItem)
                    activityRoundItem[activityRoundItem.count - 1].activityItems.append(itemValue)
                }
            }
        }
        if GV.playingRecord.rounds.count > 0 {
            if GV.playingRecord.rounds.last!.gameArray.count > 0 {
                wtGameboard!.stringToGameArray(string: GV.playingRecord.rounds.last!.gameArray)
            }
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
        if activityRoundItem[0].activityItems.count > 0 {
//            undoSprite.alpha = 1.0
            createUndo(enabled: true)
        }
        timeForGame = TimeForGame(from: GV.playingRecord.time)
//        wtGameboard!.checkWholeWords()
    }
    
//    private func generateArrayOfWordPiecesOld()->String {
//        let gameNumber =  GV.playingRecord.gameNumber
//        let words = GV.playingRecord.mandatoryWords.components(separatedBy: "°")
//        let blockSize = frame.size.width * (GV.onIpad ? 0.70 : 0.90) / CGFloat(12)
//        let random = MyRandom(gameNumber: gameNumber)
//        func getLetters( from: inout [String], archiv: inout [String])->[String] {
//            
//            if from.count == 0 {
//                repeat {
//                    let archivIndex = random.getRandomInt(0, max: archiv.count - 1)
//                    let item = archiv[archivIndex]
//                    archiv.remove(at: archivIndex)
//                    from.append(item)
//                } while archiv.count > 0
////                for item in archiv {
////                    from.append(item)
////                }
////                archiv.removeAll()
//            }
//            let index = random.getRandomInt(0, max: from.count - 1)
//            let temp = from[index]
//            var piece = [String]()
//            piece.append(temp.subString(startPos:0, length: 1))
//            if temp.count == 2 {
//                piece.append(temp.subString(startPos:1, length: 1))
//            }
//            archiv.append(temp)
//            from.remove(at: index)
//            return piece
//        }
//        tilesForGame.removeAll()
//        var oneLetterPieces = [String]()
//        var oneLetterPiecesArchiv = [String]()
//        var twoLetterPieces = [String]()
//        var twoLetterPiecesArchiv = [String]()
//        for word in words {
//            for letter in word {
//                oneLetterPieces.append(String(letter).uppercased())
//            }
////            for index in 0..<word.count - 1 {
////                twoLetterPieces.append(word.subString(startPos: index, length: 2).uppercased())
////            }
////
//            for index in 0..<word.count / 2 {
//                if !twoLetterPieces.contains(where: {$0 == word.subString(startPos: index * 2, length: 2).uppercased()}) {
//                    twoLetterPieces.append(word.subString(startPos: index * 2, length: 2).uppercased())
//                }
//            }
//        }
//        for letter in String(GV.language.getText(.tcAlphabet)) {
//            if !oneLetterPieces.contains(where: {$0 == String(letter)}) {
//                oneLetterPieces.append(String(letter))
//            }
//        }
//        var typesWithLen1 = [MyShapes]()
//        var typesWithLen2 = [MyShapes]()
//        var typesWithLen3 = [MyShapes]()
//        var typesWithLen4 = [MyShapes]()
//        
//        for index in 0..<MyShapes.count - 1 {
//            guard let type = MyShapes(rawValue: index) else {
//                return ""
//            }
//            let length = myForms[type]![0].count
//            switch length {
//            case 1: typesWithLen1.append(type)
//            case 2: typesWithLen2.append(type)
//            case 3: typesWithLen3.append(type)
//            case 4: typesWithLen4.append(type)
//            default: break
//            }
//        }
////        let lengths = [1,1,1,1,1,2,2,2,2,2,2,3,3,4]
//        let lengths = [1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,3]
////        let lengths = [1,1,2,2,3,3,3,3]
//        var generateLength = 0
//        repeat {
//            let tileLength = lengths[random.getRandomInt(0, max: lengths.count - 1)]
//            var tileType = MyShapes.NotUsed
//            var letters = [String]()
//            switch tileLength {
//            case 1: tileType = typesWithLen1[0]
//            letters += getLetters(from: &oneLetterPieces, archiv: &oneLetterPiecesArchiv)
//            case 2: tileType = typesWithLen2[0]
//            letters += getLetters(from: &twoLetterPieces, archiv: &twoLetterPiecesArchiv)
//            case 3: tileType = typesWithLen3[random.getRandomInt(0, max: typesWithLen3.count - 1)]
//            letters += getLetters(from: &twoLetterPieces, archiv: &twoLetterPiecesArchiv)
//            letters += getLetters(from: &oneLetterPieces, archiv: &oneLetterPiecesArchiv)
//            case 4: tileType = typesWithLen4[random.getRandomInt(0, max: typesWithLen4.count - 1)]
//            letters += getLetters(from: &twoLetterPieces, archiv: &twoLetterPiecesArchiv)
//            letters += getLetters(from: &twoLetterPieces, archiv: &twoLetterPiecesArchiv)
//            default: break
//            }
//            let rotateIndex = random.getRandomInt(0, max: 3)
//            
//            //            let tileForGameItem = TilesForGame(type: tileType, rotateIndex: rotateIndex, letters: letters)
//            let tileForGameItem = WTPiece(type: tileType, rotateIndex: rotateIndex, parent: self, blockSize: blockSize, letters: letters)
//            tilesForGame.append(tileForGameItem)
//            generateLength += tileLength
//        } while generateLength < 1000
//        var generatedArrayInStringForm = ""
//        for tile in tilesForGame {
//            generatedArrayInStringForm += tile.toString() + "°"
//        }
//        return generatedArrayInStringForm
//    }
//
    private func generateArrayOfWordPieces()->String {
        let gameNumber =  GV.playingRecord.gameNumber
        let words = GV.playingRecord.mandatoryWords.components(separatedBy: "°")
        let blockSize = frame.size.width * (GV.onIpad ? 0.70 : 0.90) / CGFloat(12)
        let random = MyRandom(gameNumber: gameNumber)
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
        var letterFrequencyTable = [String:Int]()
        var mandatoryLetterFrequencyTable = [String:Int]()
        var countMandatoryLetters = 0
        let letterFrequencyRecords = realmWordList.objects(WordListModel.self).filter("word BEGINSWITH %@", GV.language.getText(.tcAktLanguage) + GV.frequencyString)
        // calculating letterFrequency
        for record in letterFrequencyRecords {
            let separatedValues = record.word.components(separatedBy: itemSeparator)
            letterFrequencyTable[separatedValues[1].uppercased()] = Int(Double(separatedValues[2])!)
        }
        // fill mandatoryLetterFrequencyTable with 0 for all letters
        for (letter, _) in letterFrequencyTable {
            mandatoryLetterFrequencyTable[letter] = 0
        }
        for word in words {
            countMandatoryLetters += word.length
            for letter in word.uppercased() {
                mandatoryLetterFrequencyTable[String(letter)]! += 1
            }
        }
        var allProcent = 0
        for (letter, origValue) in mandatoryLetterFrequencyTable {
            let absValue = Double(origValue) //Double(mandatoryLetterFrequencyTable[letter]!)
            let procentValue = Int(round(100.0 * absValue / Double(countMandatoryLetters)))
            let newValue = procentValue > letterFrequencyTable[letter]! ?
                (procentValue > 25 ? 25 : procentValue) :
                letterFrequencyTable[letter]! * (procentValue == 0 ? 2 : 1)
            mandatoryLetterFrequencyTable[letter] = newValue
            allProcent += newValue
        }
        
        for word in words {
            for index in 0..<word.count / 2 {
                if !twoLetterPieces.contains(where: {$0 == word.subString(startPos: index * 2, length: 2).uppercased()}) {
                    twoLetterPieces.append(word.subString(startPos: index * 2, length: 2).uppercased())
                    for letter in twoLetterPieces.last! {
                        if mandatoryLetterFrequencyTable[String(letter)]! > 0 {
                            mandatoryLetterFrequencyTable[String(letter)]! -= 1
                        }
                    }
                }
            }
        }
        for (letter, counter) in mandatoryLetterFrequencyTable {
            for _ in 0..<counter {
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
        var lengths = [Int]()
        for index in 1...100 {
            switch index {
            case 1...45: lengths.append(1)
            case 46...96: lengths.append(2)
            case 97...99: lengths.append(3)
            default:      lengths.append(4)
            }
        }
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

    private func createButton(withText: String, position: CGPoint, name: String, buttonSize: CGSize? = nil)->SKSpriteNode {
        func createLabel(withText: String, position: CGPoint, fontSize: CGFloat, name: String)->SKLabelNode {
            let label = SKLabelNode()
            label.fontName = "TimesNewRomanPS-BoldMT"
            label.fontColor = .black
//            label.numberOfLines = 0
            label.verticalAlignmentMode = .center
            label.horizontalAlignmentMode = .center
            label.fontSize = self.size.width * 0.04
            label.zPosition = self.zPosition + 1
            label.text = withText
            label.name = name
            label.position = position
            return label
        }
        let mySize = CGSize(width: buttonSize == nil ? self.size.width * 0.4 : buttonSize!.width,
                            height: buttonSize == nil ? self.size.height * 0.1 : buttonSize!.height)
        let texture = SKTexture(imageNamed: "button.png")
        let button = SKSpriteNode(texture: texture, color: .white, size: mySize)
        button.position = position
        button.name = name
        button.addChild(createLabel(withText: withText, position: CGPoint(x:0, y:10), fontSize: self.size.width * 0.03, name: name + "Label"))
        return button
        
    }

    
    func searchLetter(letter: String) {
        for tile in tilesForGame {
            if tile.letters.contains(where: {$0 == letter}) {
                print("index: \(tile.arrayIndex), letters: \(tile.letters)")
            }
        }
    }
    
    var showOwnWordsTableView: WTTableView?
    var ownWordsForShow = [FoundedWordWithCounter]()
    var mandatoryWordsForShow = [FoundedWordWithCounter]()
    var maxLength = 0
    var showingWordsInTable = false
    let myFont = UIFont(name: "CourierNewPS-BoldMT", size: GV.onIpad ? 18 : 15)
    let myTitleFont = UIFont(name: "TimesNewRomanPS-BoldMT", size: GV.onIpad ? 30 : 18)

    private func showOwnWordsInTableView() {
        tableType = .ShowAllWords
        showOwnWordsTableView = WTTableView()
        timerIsCounting = false
        var maxLength1 = 0
        (mandatoryWordsForShow, maxLength) = WTGameWordList.shared.getWordsForShow(mandatory: true)
        (ownWordsForShow, maxLength1) = WTGameWordList.shared.getWordsForShow(mandatory: false)
        maxLength = maxLength1 > maxLength ? maxLength1 : maxLength
        calculateColumnWidths()
        showOwnWordsTableView?.setDelegate(delegate: self)
        showOwnWordsTableView?.register(CustomTableViewCell.self, forCellReuseIdentifier: "cell")
        let origin = CGPoint(x: 0.5 * (self.frame.width - title.width(font: myFont!)), y: self.frame.height * 0.08)
        let lineHeight = title.height(font:myFont!)
        let headerframeHeight = lineHeight * 4.6
        var showingWordsHeight = CGFloat(ownWordsForShow.count + mandatoryWordsForShow.count) * lineHeight
        if showingWordsHeight  > self.frame.height * 0.8 {
            var counter = CGFloat(ownWordsForShow.count)
            repeat {
                counter -= 1
                showingWordsHeight = lineHeight * counter
            } while showingWordsHeight + headerframeHeight > self.frame.height * 0.8
        }
        if maxLength < GV.language.getText(.tcWord).count {
            maxLength = GV.language.getText(.tcWord).count
        }
        let width = title.width(font: myFont!)
        let size = CGSize(width: width, height: showingWordsHeight + headerframeHeight)
        showOwnWordsTableView?.frame=CGRect(origin: origin, size: size)
        self.showOwnWordsTableView?.reloadData()
        self.scene?.alpha = 0.2
        self.scene?.view?.addSubview(showOwnWordsTableView!)
    }
    
    func startShowingWordsOverPosition(wordList: [SelectedWord]) {
        if wordList.count == 0 {
            return
        }
        tableType = .ShowWordsOverPosition
        showWordsOverPositionTableView = WTTableView()
        showingWordsInTable = true
        self.wordList = wordList
        timerIsCounting = false
        maxLength = 0
        for selectedWord in wordList {
            let word = selectedWord.word
            maxLength = word.length > maxLength ? word.length : maxLength
        }
        calculateColumnWidths()
        showWordsOverPositionTableView?.setDelegate(delegate: self)
        showWordsOverPositionTableView?.register(CustomTableViewCell.self, forCellReuseIdentifier: "cell")
        let origin = CGPoint(x: 0.5 * (self.frame.width - title.width(font: myFont!)), y: self.frame.height * 0.08)
        let lineHeight = title.height(font: myFont!)
        let headerframeHeight = lineHeight * 2.2
        var showingWordsHeight = CGFloat(wordList.count) * lineHeight
        if showingWordsHeight  > self.frame.height * 0.9 {
            var counter = CGFloat(wordList.count)
            repeat {
                counter -= 1
                showingWordsHeight = lineHeight * counter
            } while showingWordsHeight + headerframeHeight > self.frame.height * 0.9
        }
        if maxLength < title.length {
            maxLength = title.length
        }
        let width = title.width(font: myFont!)
        let size = CGSize(width: width, height: showingWordsHeight + headerframeHeight)
        showWordsOverPositionTableView?.frame=CGRect(origin: origin, size: size)
        self.showWordsOverPositionTableView?.reloadData()
        
        //        showOwnWordsTableView?.reloadData()
        self.scene?.view?.addSubview(showWordsOverPositionTableView!)
        
    }

    

    

    
    deinit {
        print("\n THE SCENE \((type(of: self))) WAS REMOVED FROM MEMORY (DEINIT) \n")
    }
}

