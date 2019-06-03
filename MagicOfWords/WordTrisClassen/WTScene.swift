//
//  CollectWordsScene.swift
//  MagicOfWords
//
//  Created by Jozsef Romhanyi on 06/02/2018.
//  Copyright © 2018 Jozsef Romhanyi. All rights reserved.
//

import Foundation
import GameplayKit
import RealmSwift

public enum StartType: Int {
    case NoMore = 0, PreviousGame, NextGame, NewGame, GameNumber
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
                    let col = Int(usedLettersString.subString(at: index, length: 1))
                    let row = Int(usedLettersString.subString(at: index + 1, length: 1))
                    let letter = usedLettersString.subString(at: index + 2, length: 1)
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



class WTScene: SKScene, WTGameboardDelegate, WTGameWordListDelegate, WTTableViewDelegate {
    
    func blinkWords(newWord: SelectedWord, foundedWord: SelectedWord = SelectedWord()) {
        var longWaitAction = SKAction.wait(forDuration: 0.0)
        let duration = 0.4
        for letter in newWord.usedLetters {
            let myNode = GV.gameArray[letter.col][letter.row]
            let showRedAction = SKAction.run({
                myNode.setStatus(toStatus: .Error, calledFrom: "blinkWords - 1")
            })
            let waitAction = SKAction.wait(forDuration: duration)
            let showOrigAction = SKAction.run({
//                myNode.setColorByState()
                myNode.setStatus(toStatus: .OrigStatus, calledFrom: "blinkWords - 2")
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
        for letter in foundedWord.usedLetters {
            let myNode = GV.gameArray[letter.col][letter.row]
            let showGreenAction = SKAction.run({
                myNode.setStatus(toStatus: .DarkGreenStatus, calledFrom: "blinkWords - 3")
            })
            let waitAction = SKAction.wait(forDuration: duration)
            let showOrigAction = SKAction.run({
//                myNode.setColorByState()
                myNode.setStatus(toStatus: .OrigStatus, calledFrom: "blinkWords - 4")
            })
            var sequence = [SKAction]()
            sequence.append(longWaitAction)
            for _ in 1...3 {
                sequence.append(showGreenAction)
                sequence.append(waitAction)
                sequence.append(showOrigAction)
                sequence.append(waitAction)
                
            }
//            myNode.zPosition = 500
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
    enum GameFinishedStatus: Int {
            case OK = 0, TimeOut, NoMoreSteps
        }

    private func calculateColumnWidths(showCount: Bool = true) {
        title = ""
        let fixlength = GV.onIpad ? 15 : 10
        lengthOfWord = maxLength < fixlength ? fixlength : maxLength
        let text1 = " \(GV.language.getText(.tcWord).fixLength(length: lengthOfWord, center: true))     "
        let text2 = showCount ? "\(GV.language.getText(.tcCount)) " : ""
        let text3 = "\(GV.language.getText(.tcLength)) "
        let text4 = "\(GV.language.getText(.tcScore)) "
//        let text5 = showCount ? "\(GV.language.getText(.tcMinutes)) " : ""
        title += text1
        title += text2
        title += text3
        title += text4
//        title += text5
//        lengthOfWord = maxLength
        lengthOfCnt = text2.length
        lengthOfLength = text3.length
        lengthOfScore = text4.length
//        lengthOfMin = text5.length
    }
    
    let myLightBlue = UIColor(red: 204/255, green: 255/255, blue: 255/255, alpha: 1.0)
    let myLightBlue1 = UIColor(red: 204/255, green: 202/255, blue: 255/255, alpha: 1.0)

    func fillHeaderView(tableView: UITableView, section: Int) -> UIView {
        var text: String = ""
        var text0: String = ""
        let lineHeight = title.height(font: myFont!)
        let yPos0: CGFloat = 0
        var yPos1: CGFloat = 0
        var yPos2: CGFloat = lineHeight
        let view = UIView()
        var width:CGFloat = title.width(withConstrainedHeight: 0, font: myFont!)
        var length: Int = 0
        let widthOfChar = "A".width(font: myFont!)
        let lengthOfTableView = Int(tableView.frame.width / widthOfChar) + 1
        switch tableType {
        case .ShowAllWords:
            if section == 0 {
                let suffix = " (\(mandatoryWordsForShow!.countWords)/\(mandatoryWordsForShow!.countAllWords)/\(mandatoryWordsForShow!.score))"
                text = (GV.language.getText(.tcCollectedRequiredWords) + suffix).fixLength(length: lengthOfTableView, center: true)
            } else {
                let suffix = " (\(ownWordsForShow!.countWords)/\(ownWordsForShow!.countAllWords)/\(ownWordsForShow!.score))"
                text = (GV.language.getText(.tcCollectedOwnWords) + suffix).fixLength(length: lengthOfTableView, center: true)
            }
        case .ShowWordsOverPosition:
            text = GV.language.getText(.tcWordsOverLetter).fixLength(length: title.length, center: true)
        case .ShowFoundedWords:
            let header0 = GV.language.getText(.tcSearchingWord, values: searchingWord)
            let header1 = GV.language.getText(.tcShowWordlistHeader, values: String(listOfFoundedWords.count))
            (width, length) = calculateTableViewWidth(header0: header0, header1: header1, header2: title)
            let optimalLength = Int(tableView.frame.width / "A".width(font: myFont!))
            length = length < optimalLength ? optimalLength : length
            text = header1.fixLength(length: length, center: true)
            text0 = header0.fixLength(length: length, center: true)
        default:
            break
        }
        if tableType == .ShowFoundedWords {
             let label0 = UILabel(frame: CGRect(x: 0, y: yPos0, width: width, height: lineHeight))
            label0.font = myFont!
            label0.text = text0
            yPos1 = lineHeight
            yPos2 = 2 * lineHeight
            view.addSubview(label0)
        }
        let label1 = UILabel(frame: CGRect(x: 0, y: yPos1, width: width, height: lineHeight))
        label1.font = myFont!
        label1.text = text
        view.addSubview(label1)
        let label2 = UILabel(frame: CGRect(x: 0, y: yPos2, width: width, height: lineHeight))
        label2.font = myFont!
        label2.text = title
        view.addSubview(label2)
        if tableType == .ShowFoundedWords {
            view.backgroundColor = myLightBlue
        } else {
            view.backgroundColor = UIColor(red:240/255, green: 240/255, blue: 240/255, alpha: 1.0)
        }
        return view
    }
    
    func didSelectedRow(tableView: UITableView, indexPath: IndexPath) {
        
    }
    
    func didTappedButton(tableView: UITableView, indexPath: IndexPath, buttonName: String) {
        
    }
    


    func getHeightForHeaderInSection(tableView: UITableView, section: Int)->CGFloat {
        if tableType == .ShowFoundedWords {
            return GV.onIpad ? 72 : 53
        }
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
        let height = "A".height(font: myFont!)
//        cell.setCellSize(size: CGSize(width: tableView.frame.width /* * (GV.onIpad ? 0.040 : 0.010)*/, height: self.frame.width * (GV.onIpad ? 0.040 : 0.010)))
        cell.setCellSize(size: CGSize(width: 0 /*tableView.frame.width * (GV.onIpad ? 0.040 : 0.010)*/, height: height)) // self.frame.width * (GV.onIpad ? 0.050 : 0.010)))
        if tableType == .ShowFoundedWords {
            cell.setBGColor(color: myLightBlue)
        } else {
            cell.setBGColor(color: UIColor.white) 
        }
        switch tableType {
        case .ShowAllWords:
            if indexPath.section == 0 {
                let wordForShow = mandatoryWordsForShow!.words[indexPath.row]
                cell.addColumn(text: "  " + wordForShow.word.fixLength(length: lengthOfWord, leadingBlanks: false)) // WordColumn
                cell.addColumn(text: String(wordForShow.counter).fixLength(length: lengthOfCnt), color: color) // Counter column
                cell.addColumn(text: String(wordForShow.word.length).fixLength(length: lengthOfLength))
                cell.addColumn(text: String(wordForShow.score).fixLength(length: lengthOfScore), color: color) // Score column
//                cell.addColumn(text: "+\(wordForShow.minutes)".fixLength(length: lengthOfMin))
            } else {
                let wordForShow = ownWordsForShow!.words[indexPath.row]
                cell.addColumn(text: "  " + wordForShow.word.fixLength(length: lengthOfWord, leadingBlanks: false)) // WordColumn
                cell.addColumn(text: String(wordForShow.counter).fixLength(length: lengthOfCnt), color: color) // Counter column
                cell.addColumn(text: String(wordForShow.word.length).fixLength(length: lengthOfLength))
                cell.addColumn(text: String(wordForShow.score).fixLength(length: lengthOfScore), color: color) // Score column
//                cell.addColumn(text: "+\(wordForShow.minutes)".fixLength(length: lengthOfMin))
             }
        case .ShowWordsOverPosition:
            cell.addColumn(text: "  " + wordList[indexPath.row].word.fixLength(length: lengthOfWord + 2, leadingBlanks: false)) // WordColumn
            cell.addColumn(text: String(1).fixLength(length: lengthOfCnt - 1), color: color)
            cell.addColumn(text: String(wordList[indexPath.row].word.length).fixLength(length: lengthOfLength - 1))
            cell.addColumn(text: String(wordList[indexPath.row].score).fixLength(length: lengthOfScore + 1), color: color)
//            cell.addColumn(text: "+\(WTGameWordList.shared.getMinutesForWord(word: wordList[indexPath.row].word))".fixLength(length: lengthOfMin - 1))
        case .ShowFoundedWords:
            cell.addColumn(text: "  " + listOfFoundedWords[indexPath.row].word.fixLength(length: lengthOfWord, leadingBlanks: false), color: myLightBlue)
            cell.addColumn(text: String(listOfFoundedWords[indexPath.row].length).fixLength(length: lengthOfLength), color: myLightBlue)
            cell.addColumn(text: String(listOfFoundedWords[indexPath.row].score).fixLength(length: lengthOfScore), color: myLightBlue)
            let restLength = Int(tableView.frame.width / "A".width(font:myFont!)) - lengthOfWord - lengthOfLength - lengthOfScore
            let spaces = " "
            cell.addColumn(text: spaces.fixLength(length: restLength), color: myLightBlue)
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
        case .ShowFoundedWords:
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
        case .ShowFoundedWords:
            return listOfFoundedWords.count
        default:
            return 0
        }
    }
    
    enum TableType: Int {
        case None = 0, ShowAllWords, ShowWordsOverPosition, ShowFoundedWords
    }
    
    let nameForSpriteWidthWords = "°°°nameForSpriteWidthWords°°°"
    var spriteToShowWords: SKSpriteNode?
    var tableType: TableType = .None
    var wordList = [SelectedWord]()
    var listOfFoundedWords = [LineOfFoundedWords]()
    var showWordsOverPositionTableView: WTTableView?
    var showFoundedWordsTableView: WTTableView?
    var parentViewController: UIViewController?
    

    func showScore(newWord: SelectedWord, totalScore: Int, doAnimate: Bool, changeTime: Int) {
        if doAnimate {
            showWordAndScore(word: newWord, score: totalScore)
        }
        if changeTime != 0 {
            timeForGame.incrementMaxTime(value: changeTime * 60)
        }
//        if changeTime < 0 {
//            timeForGame.decrementMaxTime(value: changeTime * 60)
//        }
//        self.totalScore = totalScore
        showFoundedWords()
        return
    }
    
    private func showWordAndScore(word: SelectedWord, score: Int) {
        let fontSize = GV.onIpad ? self.frame.size.width * 0.02 : self.frame.size.width * 0.04
        let textOnBalloon = word.word + " (" + String(score) + ")"
        let elite = GV.buttonType == GV.ButtonTypeElite
        let balloon = SKSpriteNode(imageNamed: elite ? "bubbleGoldElite" : "BalloonSimple")
        let width = textOnBalloon.width(font: myFont!) * (GV.onIpad ? 2.0 : 1.5)
        let height = textOnBalloon.height(font: myFont!) * 2.5
        balloon.size = CGSize(width: width, height: height)
        balloon.zPosition = 10
//        let atY = score >= 0 ? self.frame.size.height * 0.1 : self.frame.size.height * 0.98
//        let startPos = wtGameboard!.getCellPosition(col: word.usedLetters[0].col, row: word.usedLetters[0].row)
        let startPos = CGPoint(x: self.frame.width * 0.5, y: allWordsButton!.frame.maxY + balloon.size.height * 2)
//        let startPosY = startPos.y
//        let endPosY = score > 0 ? self.frame.size.height * 0.80 : self.frame.size.height * -0.04
        balloon.position = CGPoint(x: startPos.x, y: startPos.y )
        bgSprite!.addChild(balloon)
        let scoreLabel = SKLabelNode(fontNamed: GV.actFont)
        scoreLabel.text = String(score)
//        scoreLabel.verticalAlignmentMode = .center
        scoreLabel.position = CGPoint(x: balloon.size.width * 0, y: -balloon.size.width * 0.40)
        scoreLabel.horizontalAlignmentMode = .center
        scoreLabel.fontSize = fontSize
        scoreLabel.fontColor = SKColor.blue
        let wordLabel = SKLabelNode(fontNamed: GV.actFont)
        wordLabel.text = textOnBalloon
        wordLabel.verticalAlignmentMode = .center
        scoreLabel.position = CGPoint(x: balloon.size.width * 0, y: balloon.size.width * 0.20)
        wordLabel.fontSize = fontSize
        wordLabel.fontColor = SKColor.blue
//        balloon.addChild(scoreLabel)
        balloon.addChild(wordLabel)
        var actions = Array<SKAction>()
        let waitAction = SKAction.wait(forDuration: 0.5)
//        let movingAction = SKAction.move(to: CGPoint(x: self.frame.size.width * 0.5, y: endPosY), duration: 5.0)
        let scaleUpAction = SKAction.scale(by: 2.0, duration: 0.5)
        let scaleDownAction = SKAction.scale(to: 1.0, duration: 0.5)
        let fadeAway = SKAction.fadeOut(withDuration: 0.2)
        let removeNode = SKAction.removeFromParent()
        actions.append(SKAction.sequence([waitAction, scaleUpAction, scaleDownAction, scaleUpAction, scaleDownAction, scaleUpAction, scaleDownAction, fadeAway, removeNode/*movingAction*/]))
//        actions.append(SKAction.sequence([waitAction, fadeAway, removeNode]))
        let group = SKAction.group(actions);
        balloon.run(group)
    }
    
    
    
    struct TouchedNodes {
        var GCol = NoValue
        var GRow = NoValue
        var col = NoValue
        var row = NoValue
        var shapeIndex = NoValue
//        var onGameArray = false
//        var shapeOnGameArray = false
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
//    var allWordsToShow = [AllWordsToShow]()
    var timer: Timer? = Timer()
//    var timeLabel = SKLabelNode()
    var headerLabel = SKLabelNode()
    var myScoreheaderLabel = SKLabelNode()
    var bestScoreHeaderLabel = SKLabelNode()
    var actScoreHeaderLabel = SKLabelNode()
    var scoreLabel = SKLabelNode()
    var goBackLabel = SKLabelNode()
    var goToPreviousGameLabel = SKLabelNode()
    var goToNextGameLabel = SKLabelNode()
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
    var newGameNumber: Int = 0
    var restart: Bool = false
    var showHelp: Bool = false
    var startTouchedNodes = TouchedNodes()
//    var wtGameFinishedSprite = WTGameFinished()

    var pieceArray = [WTPiece]()
    var origPosition: [CGPoint] = Array(repeating: CGPoint(x:0, y: 0), count: 3)
    var origSize: [CGSize] = Array(repeating: CGSize(width:0, height: 0), count: 3)
    var totalScore: Int = 0
    var movedFromBottom = false
//    var ownWordsScrolling = false
    var inChoosingOwnWord = false
    var inDefiningSearchingWord = false
    var movedIndex = 0
    var countShowingOwnWords = 0
    var ownWordsScrollingStartPos = CGPoint(x:0, y:0)
    var firstLineYPosition = CGFloat(0)
    var heightOfLine = CGFloat(0)
    var showingOwnWordsIndex = 0
    let countWordsInRow = 3
    var countShowingRows = 0
    var startShapeIndex = NoValue
    let shapeMultiplicator = [CGFloat(0.25), CGFloat(0.50), CGFloat(0.75)]
    var undoSprite = SKSpriteNode()
    let letterCounts: [Int:[Int]] = [
        1: [1],
        2: [11, 2],
        3: [3, 21, 111],
        4: [31, 22],
        5: [32, 221]
    ]
    let bgColor = SKColor(red: 223/255, green: 255/255, blue: 216/255, alpha: 1.0)
    let mandatoryWordsHeaderName = "°°°mandatoryWords°°°"
    let ownWordsHeaderName = "°°°ownWords°°°"
    let bonusHeaderName = "°°°bonusHeader°°°"
    let undoName = "°°°undo°°°"
    let goBackName = "°°°goBack°°°"
    let headerName = "°°°header°°°"
    let headerLineName = "°°°headerLine°°°"
    let myScoreName = "°°°myScore°°°"
    let bestScoreName = "°°°bestScore°°°"
    let actScoreName = "°°°actScore°°°"
    let timeName = "°°°timeName°°°"
    let gameNumberName = "°°°gameNumber°°°"
    let previousName = "°°°previousGame°°°"
    let nextName = "°°°nextGame°°°"
//    let ownWordsBackgroundName = "°°°ownWordsBackgroundName°°°"
//    let ownWordsButtonName = "°°°ownWordsButtonName°°°"

    var timeIncreaseValues: [Int]?
    var movingSprite: Bool = false
    var bgSprite: SKSpriteNode?
//    var wtGameWordList: WTGameWordList?

    
    override func didMove(to view: SKView) {
//        wtGameWordList = WTGameWordList(delegate: self)
//        timeIncreaseValues = [0, 0, 0, 0, 0, 0, iFiveMinutes, iFiveMinutes, iTenMinutes, iTenMinutes, iQuarterHour]
        self.name = "WTScene"
        self.view!.isMultipleTouchEnabled = false
        self.view!.subviews.forEach { $0.removeFromSuperview() }
        self.blockSize = self.frame.size.width * (GV.onIpad ? 0.70 : 0.90) / CGFloat(12)
        self.bgSprite = SKSpriteNode()
//        bgSprite!.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
//        bgSprite!.color = bgColor
        self.addChild(bgSprite!)
        GV.totalScore = 0
        GV.mandatoryScore = 0
        GV.ownScore = 0
        GV.bonusScore = 0
        if GV.generateHelpInfo {
            initiateHelpModel()
            if !showHelp {
                resetHelpInfo()
            }
        } else if showHelp {
            
        }
        self.backgroundColor = bgColor
        if restart {
            let recordToDelete = realm.objects(GameDataModel.self).filter("language = %@ and gameNumber = %d", GV.actLanguage, newGameNumber)
            if recordToDelete.count == 1 {
                try! realm.safeWrite() {
                    realm.delete(recordToDelete)
                }
            }
        }
//        wtGameboard = WTGameboard(countCols: GV.sizeOfGrid, parentScene: self, delegate: self, yCenter: gameboardCenterY)
        getPlayingRecord(new: new, next: nextGame, gameNumber: newGameNumber, showHelp: showHelp)
        createHeader()
        buttonHeight = self.frame.width * (GV.onIpad ? 0.08 : 0.125)
        buttonSize = CGSize(width: buttonHeight, height: buttonHeight)
        createUndo()
        createGoBackButton()
        WTGameWordList.shared.clear()
        WTGameWordList.shared.setMandatoryWords()
        showWordsToCollect()
        play()
   }
    
    @objc func startNewGame() {
        wtSceneDelegate!.gameFinished(start: .NewGame)
    }
    
//    func generateReadOnly() {
//        let real
//        for gameNumber in 0...999 {
//            getPlayingRecord(new: new, next: nextGame, gameNumber: gameNumber)
//        }
//    }
    
    let timeInitValue = "0°origMaxTime"
    func restartThisGame() {
        actRound = 1
        try! realm.safeWrite() {
    //        GV.playingRecord.ownWords = ""
            GV.playingRecord.pieces = ""
    //        GV.playingRecord.activityItems = ""
            GV.playingRecord.time = timeInitValue
            GV.playingRecord.rounds.removeAll()
            GV.playingRecord.gameStatus = GV.GameStatusNew
            GV.playingRecord.mandatoryWords = ""
        }
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
    private func getPlayingRecord(new: Bool, next: StartType, gameNumber: Int, showHelp: Bool = false) {
        func setMandatoryWords() {
            if GV.playingRecord.mandatoryWords == "" {
                let mandatoryRecord: MandatoryModel? = realmMandatory.objects(MandatoryModel.self).filter("gameNumber = %d and language = %@", GV.playingRecord.gameNumber, GV.actLanguage).first!
                if mandatoryRecord != nil {
                    let components = mandatoryRecord!.mandatoryWords.components(separatedBy: "°")
                    var newString = ""
                    for index in 0...5 {
                        newString += components[index] + "°"
                    }
                    newString.removeLast()
                    try! realm.safeWrite() {
                        GV.playingRecord.mandatoryWords = newString
                    }
                }
            }
        }
        var actGames = realm.objects(GameDataModel.self).filter("nowPlaying = TRUE and language = %@ and gameNumber >= %d and gameNumber <= %d", GV.actLanguage, GV.minGameNumber, GV.maxGameNumber)
        if showHelp {
            if gameNumber >= gameNumberForGenerating {
                let difficulty = GV.basicDataRecord.difficulty
                if GV.generateHelpInfo {
                    GV.helpInfoRecords = realmHelpInfo!.objects(HelpInfo.self).filter("language = %d and difficulty = %d", GV.actLanguage, difficulty).sorted(byKeyPath: "counter")
                } else {
                    GV.helpInfoRecords = realmHelp.objects(HelpInfo.self).filter("language = %d and difficulty = %d", GV.actLanguage, difficulty).sorted(byKeyPath: "counter")
                }
            }
            createPlayingRecord(gameNumber: gameNumber)
        } else if GV.generateHelpInfo && new {
            deleteGameDataRecord(gameNumber: gameNumber)
            createPlayingRecord(gameNumber: gameNumber)
        } else if new {
            let games = realm.objects(GameDataModel.self).filter("gameStatus = %d and language = %@ and gameNumber >= %d and gameNumber <= %d", GV.GameStatusNew, GV.actLanguage, GV.minGameNumber, GV.maxGameNumber).sorted(byKeyPath: "gameNumber", ascending: true)
            /// reset all records with nowPlaying status
//            wtGameWordList = WTGameWordList(delegate: self)
            if games.count > 0 {
                GV.playingRecord = games[0]
                try! realm.safeWrite() {
                    GV.playingRecord.nowPlaying = true
                    GV.playingRecord.time = timeInitValue
                }
            } else {
                var freeGameNumbers = [Int]()
                for number in GV.minGameNumber...GV.maxGameNumber {
                    freeGameNumbers.append(number)
                }
                let playedGames = realm.objects(GameDataModel.self).filter("language = %@ and gameNumber >= %d and gameNumber <= %d", GV.actLanguage, GV.minGameNumber, GV.maxGameNumber).sorted(byKeyPath: "gameNumber", ascending: false)
                for playedGame in playedGames {
                    guard let index = freeGameNumbers.firstIndex(where: {$0 == playedGame.gameNumber}) else {continue}
                    freeGameNumbers.remove(at: index)
                }
                createPlayingRecord(gameNumber: freeGameNumbers.first!)
            }
        } else if next == .GameNumber {
            if actGames.count > 0 {
                for actGame in actGames {
                    try! realm.safeWrite() {
                        actGame.nowPlaying = false
                    }
                }
            }
            let games = realm.objects(GameDataModel.self).filter("combinedKey = %d", GV.actLanguage + String(gameNumber))
            if games.count > 0 {
                GV.playingRecord = games.first!
                try! realm.safeWrite() {
                    GV.playingRecord.nowPlaying = true
                    if GV.playingRecord.gameStatus == GV.GameStatusFinished {
                        GV.playingRecord.gameStatus = GV.GameStatusContinued
                    }
                    if GV.playingRecord.gameStatus == GV.GameStatusContinued {
                        goOnPlaying = true
                    }
                }
            } else {
                createPlayingRecord(gameNumber: gameNumber)
            }
        } else {
            var first = true
            if actGames.count > 0 {
                for actGame in actGames {
                    if !first {
                        try! realm.safeWrite() {
                            actGame.nowPlaying = false
                        }
                    }
                    first = false
                }
            } else {
                actGames = realm.objects(GameDataModel.self).filter("(gameStatus = %d or gameStatus = %d) and language = %@ and gameNumber >= %d and gameNumber <= %d", GV.GameStatusPlaying, GV.GameStatusContinued, GV.actLanguage, GV.minGameNumber, GV.maxGameNumber)
                if actGames.count > 0 {
                    try! realm.safeWrite() {
                        actGames[0].nowPlaying = true
                    }
                }
            }
            let playedNowGame = realm.objects(GameDataModel.self).filter("nowPlaying = TRUE and language = %@ and gameNumber >= %d and gameNumber <= %d", GV.actLanguage, GV.minGameNumber, GV.maxGameNumber)
            var actGameNumber = playedNowGame.first!.gameNumber
            if playedNowGame.count > 0 {
                switch nextGame {
                case .NoMore:
                    break
                case .PreviousGame:
                    let previousRecords = realm.objects(GameDataModel.self).filter("(gameStatus = %d or gameStatus = %d) and gameNumber < %d and language = %@ and gameNumber >= %d and gameNumber <= %d",
                       GV.GameStatusPlaying, GV.GameStatusContinued, actGameNumber, GV.actLanguage, GV.minGameNumber, GV.maxGameNumber)
                    if previousRecords.count == 1 {
                        actGameNumber = previousRecords[0].gameNumber
                    } else if let record = Array(previousRecords).sorted(by: {$0.gameNumber < $1.gameNumber}).last {
                        actGameNumber = record.gameNumber
                    } else {
                        break
                    }
                case .NextGame:
                    let nextRecords = realm.objects(GameDataModel.self).filter("(gameStatus = %d or gameStatus = %d) and gameNumber > %d and language = %@ and gameNumber >= %d and gameNumber <= %d",
                       GV.GameStatusPlaying, GV.GameStatusContinued, actGameNumber, GV.actLanguage, GV.minGameNumber, GV.maxGameNumber)
                    if nextRecords.count == 1 {
                        actGameNumber = nextRecords[0].gameNumber
                    } else if let record = Array(nextRecords).sorted(by: {$0.gameNumber < $1.gameNumber}).first {
                        actGameNumber = record.gameNumber
                    } else {
                        break
                    }

                default:
                    break
                }
                try! realm.safeWrite() {
                    playedNowGame.first!.nowPlaying = false
                    GV.playingRecord = realm.objects(GameDataModel.self).filter("gameNumber = %d and language = %@",
                        actGameNumber, GV.actLanguage).first!
                    GV.playingRecord.nowPlaying = true
                }
            }
        }
        if GV.playingRecord.gameStatus == GV.GameStatusContinued {
            goOnPlaying = true
        }
        setMandatoryWords()
    }
    
    private func createPlayingRecord(gameNumber: Int) {
        var gameNumberForMandatoryRecord = 0
        if GV.generateHelpInfo {
            gameNumberForMandatoryRecord = gameNumberForGenerating
        } else {
            gameNumberForMandatoryRecord = gameNumber - GV.basicDataRecord.difficulty * 1000
        }
        let mandatoryRecord: MandatoryModel? = realmMandatory.objects(MandatoryModel.self).filter("gameNumber = %d and language = %@", gameNumberForMandatoryRecord, GV.actLanguage).first!
        if mandatoryRecord != nil {
            try! realm.safeWrite() {
                let components = mandatoryRecord!.mandatoryWords.components(separatedBy: "°")
                var newString = ""
                for index in 0...5 {
                    newString += components[index] + "°"
                }
                newString.removeLast()
                GV.playingRecord = GameDataModel()
                GV.playingRecord.combinedKey = GV.actLanguage + String(gameNumber)
                GV.playingRecord.mandatoryWords = newString
                GV.playingRecord.gameNumber = gameNumber
                GV.playingRecord.language = GV.actLanguage
                GV.playingRecord.time = timeInitValue
                GV.playingRecord.nowPlaying = true
                realm.add(GV.playingRecord)
            }
        }
    }


    public func setDelegate(delegate: WTSceneDelegate) {
        wtSceneDelegate = delegate
    }
    
    public func setGameArt(new: Bool = false, next: StartType = .NoMore, gameNumber: Int = 0, restart: Bool, showHelp: Bool) {
        self.new = new
        self.nextGame = next
        self.newGameNumber = gameNumber
        self.restart = restart
        self.showHelp = showHelp
    }
    
    let gameNumberLinePosition:CGFloat = 0.93
    let bestScoreLinePosition:CGFloat = 0.91
    let myScoreLinePosition:CGFloat = 0.89
    let bonusPointsLinePosition:CGFloat = 0.86
    let ownWordsLinePosition:CGFloat = 0.84
    let mandatoryWordsLinePosition:CGFloat = 0.82
    let buttonLineCenterY:CGFloat = 0.265
    let mybuttonLineCenterY:CGFloat = 1 - 0.265 // 1 - buttonLineCenterY
    let gameboardCenterY: CGFloat = 0.42
    let pieceArrayCenterY: CGFloat = 0.08
    let scoreLength: Int = 6
    
    private func createHeader() {
        let fontSize = self.frame.size.height * 0.0175 // GV.onIpad ? self.frame.size.width * 0.02 : self.frame.size.width * 0.032
        if bgSprite!.childNode(withName: headerName) == nil {
            let YPosition: CGFloat = self.frame.height * gameNumberLinePosition
            let gameNumber = GV.playingRecord.gameNumber >= gameNumberForGenerating ? "DEMO" : String(GV.playingRecord.gameNumber % 1000)
            let text = GV.language.getText(.tcHeader, values: gameNumber, String(0), timeForGame.time.HourMinSec)
            headerLabel = SKLabelNode(fontNamed: GV.actLabelFont) //"CourierNewPS-BoldMT")// Snell Roundhand")
            headerLabel.text = text
            headerLabel.name = String(headerName)
            headerLabel.fontSize = fontSize
            headerLabel.position = CGPoint(x: self.frame.size.width * 0.5 /*startPosXForHeaderMultiplier*/, y: YPosition)
            headerLabel.horizontalAlignmentMode = .center
            headerLabel.fontColor = SKColor.black
            bgSprite!.addChild(headerLabel)
        }
        
        let myName = GV.basicDataRecord.myNickname
        
        let bestName = "nobody"
        let bestScore = 0
        
        if bgSprite!.childNode(withName: bestScoreName) == nil {
            let YPosition: CGFloat = self.frame.height * bestScoreLinePosition
            //            let text = GV.language.getText(.tcBestScoreHeader, values: bestOnlineRecord!.player, bestOnlineRecord!.score)
            let text = GV.language.getText(.tcBestScoreHeader, values: String(bestScore).fixLength(length:scoreLength), bestName)
            bestScoreHeaderLabel = SKLabelNode(fontNamed: GV.actLabelFont) //"CourierNewPS-BoldMT")// Snell Roundhand")
            bestScoreHeaderLabel.text = text
            bestScoreHeaderLabel.name = String(bestScoreName)
            bestScoreHeaderLabel.fontSize = fontSize
//            bestScoreHeaderLabel.position = CGPoint(x: self.frame.size.width * 0.5, y: YPosition)
            bestScoreHeaderLabel.position = CGPoint(x: headerLabel.frame.minX, y: YPosition)
            bestScoreHeaderLabel.horizontalAlignmentMode = .left
            bestScoreHeaderLabel.fontColor = SKColor.black
            bgSprite!.addChild(bestScoreHeaderLabel)
        }
        
        if bgSprite!.childNode(withName: myScoreName) == nil {
            let YPosition: CGFloat = self.frame.height * myScoreLinePosition
            let text = GV.language.getText(.tcMyScoreHeader, values: String(GV.playingRecord.score).fixLength(length:scoreLength), myName)
            myScoreheaderLabel = SKLabelNode(fontNamed: GV.actLabelFont) //"CourierNewPS-BoldMT")// Snell Roundhand")
            myScoreheaderLabel.text = text
            myScoreheaderLabel.name = String(myScoreName)
            myScoreheaderLabel.fontSize = fontSize
//            myScoreheaderLabel.position = CGPoint(x: self.frame.size.width * 0.5 /*startPosXForHeaderMultiplier*/, y: YPosition)
            myScoreheaderLabel.position = CGPoint(x: headerLabel.frame.minX, y: YPosition)
            myScoreheaderLabel.horizontalAlignmentMode = .left
            myScoreheaderLabel.fontColor = SKColor.black
            bgSprite!.addChild(myScoreheaderLabel)
        }
   }
    
    var headerCreated = false
    var createNextRound = false
    
    override func update(_ currentTime: TimeInterval) {
        if !syncedRecordsOK && realmSync != nil {
            if !waitingForSynceRecords {
                getSyncedRecords()
                waitingForSynceRecords = true
            }
        }
        if createNextRound && GV.nextRoundAnimationFinished {
            try! realm.safeWrite() {
                let roundScore = WTGameWordList.shared.getPointsForLetters()
                GV.playingRecord.rounds.last!.roundScore = roundScore
                let newRound = RoundDataModel()
                newRound.gameArray = self.wtGameboard!.gameArrayToString()
                GV.playingRecord.rounds.append(newRound)
                self.timeForGame.incrementMaxTime(value: iHalfHour)
                WTGameWordList.shared.addNewRound()
                self.activityRoundItem.append(ActivityRound())
                self.activityRoundItem[self.activityRoundItem.count - 1].activityItems = [ActivityItem]()
            }
            createFixLetters()
            saveActualState()
            createNextRound = false
            GV.nextRoundAnimationFinished = false
        }
    }
    
    private func modifyHeader() {
//        var gameNumber = String(GV.playingRecord.gameNumber % 1000 + 1)
        let gameNumber = (GV.playingRecord.gameNumber >= gameNumberForGenerating ? "DEMO" : String(GV.playingRecord.gameNumber % 1000 + 1))
        let headerText = GV.language.getText(.tcHeader, values: gameNumber, String(actRound), timeForGame.time.HourMinSec)
        headerLabel.text = headerText
//        let letterScore = GV.bonusScore
//        let normalScore = GV.mandatoryScore + GV.//WTGameWordList.shared.getScore(forAll: true)
        let score = GV.totalScore
        var place = 0
        if bestPlayersReady {
            place = self.bestPlayers!.filter("score > %@", score).count + 1
        }
        let scoreText = GV.language.getText(.tcMyScoreHeader, values: String(place), String(score).fixLength(length:scoreLength), GV.basicDataRecord.myNickname)
//        let myScorelabel = bgSprite!.childNode(withName: myScoreName) as? SKLabelNode
//        if myScorelabel != nil {
        myScoreheaderLabel.text = scoreText
//        }
 
        if bestScoreForActualGame != nil && bestScoreForActualGame!.count > 0 {
            let bestName = bestScoreForActualGame![0].owner != nil ? bestScoreForActualGame![0].owner!.nickName : ""
            let bestScore = bestScoreForActualGame![0].bestScore
            let bestScoretext = GV.language.getText(.tcBestScoreHeader, values: String(bestScore).fixLength(length:scoreLength), bestName!)
//            let bestScorelabel = bgSprite!.childNode(withName: bestScoreName) as? SKLabelNode
            bestScoreHeaderLabel.text = bestScoretext
        }
    }

//    func scrollOwnWords(up: Bool) {
//        if up {
//            showingOwnWordsIndex += countWordsInRow
//            let countOwnWords = WTGameWordList.shared.getCountWords(mandatory: false)
//            if showingOwnWordsIndex + countShowingOwnWords > countOwnWords {
//                let countShowedRows = countShowingOwnWords / countWordsInRow
//                let startRow = countOwnWords / countWordsInRow - countShowedRows + 1
//                showingOwnWordsIndex =  startRow * countWordsInRow
//            }
//        } else {
//            showingOwnWordsIndex -= countWordsInRow
//            if showingOwnWordsIndex < 0 {
//                showingOwnWordsIndex = 0
//            }
//        }
//        showFoundedWords()
//    }
    func showFoundedWords() {
        let myMandatoryWords = WTGameWordList.shared.getMandatoryWords()
        for actWord in myMandatoryWords {
            let label = bgSprite!.childNode(withName: actWord.word) as? SKLabelNode
            if label != nil {
                label!.text = actWord.word + " (\(actWord.counter)) "
            }
        }
        
        if let label = bgSprite!.childNode(withName: bonusHeaderName)! as? SKLabelNode {
            label.text = GV.language.getText(.tcBonusHeader, values: String(GV.bonusScore))
        }

        if let label = bgSprite!.childNode(withName: mandatoryWordsHeaderName)! as? SKLabelNode {
            label.text = GV.language.getText(.tcWordsToCollect, values: String(GV.mandatoryWords.count), String(WTGameWordList.shared.getCountMandatoryWords(founded: true)),
                String(WTGameWordList.shared.getCountMandatoryWords(founded: false)),
                String(GV.mandatoryScore))
        }
        if let label = bgSprite!.childNode(withName: ownWordsHeaderName)! as? SKLabelNode {
            label.text = GV.language.getText(.tcOwnWords, values: String(WTGameWordList.shared.getCountOwnWords(founded: true)), String(WTGameWordList.shared.getCountOwnWords(founded: false)),
                    String(GV.ownScore))
        }
        modifyHeader()

    }
    
    func addOwnWordNew(word: String, usedLetters: [UsedLetter])->Bool {
        var returnBool = false
        if realmWordList.objects(WordListModel.self).filter("word = %@", GV.actLanguage + word.lowercased()).count == 1 {
            let selectedWord = SelectedWord(word: word, usedLetters: usedLetters)
            let boolValue = WTGameWordList.shared.addWord(selectedWord: selectedWord)
            returnBool = boolValue
        }
//        else {
//            blinkWords(newWord: SelectedWord(word: word, usedLetters: usedLetters))
//        }f
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
        if self.enabled {
            stopShowingTableIfNeeded()
            if timer != nil {
                timer!.invalidate()
                timer = nil
            }
            removeAllSubviews()
            wtSceneDelegate!.gameFinished(start: .NoMore)
        }
    }
    
    var searchingWord = ""
    var wtGameboardMovedBy: CGFloat = 0
    
    @objc func wordListTapped() {
        if !self.enabled {
            return
        }
        sortUp = true
        listOfFoundedWords = [LineOfFoundedWords]()
        searchingWord = ""
        showMyFoundedWords()
        createButtons()
        hideScreen(hide: true)
    }
    var doneButton: UIButton?
    var questionMarkButton: UIButton?
    var starButton: UIButton?
    var retypeButton: UIButton?
    var sortButton: UIButton?
    
    private func createButtons() {
        let radius = showFoundedWordsTableView!.frame.size.width / 12
        let buttonCenterDistance = (showFoundedWordsTableView!.frame.size.width - 2 * radius) / 4
        let buttonFrameWidth = 2 * radius
        let buttonFrame = CGRect(x: 0, y: 0, width:buttonFrameWidth, height: buttonFrameWidth)
        let yPos = showFoundedWordsTableView!.frame.maxY + radius * 1.2
        let xPos1 = showFoundedWordsTableView!.frame.minX + radius
        let center1 = CGPoint(x: xPos1, y:yPos)
        doneButton = createButton(imageName: "hook.png", imageSize: 0.6, title: "", frame: buttonFrame, center: center1, cornerRadius: radius, enabled: enabled)
        doneButton?.addTarget(self, action: #selector(self.doneButtonTapped), for: .touchUpInside)
        self.view?.addSubview(doneButton!)
        let xPos2 = showFoundedWordsTableView!.frame.minX + radius + buttonCenterDistance
        let center2 = CGPoint(x: xPos2, y:yPos)
        questionMarkButton = createButton(imageName: "", title: questionMark, frame: buttonFrame, center: center2, cornerRadius: radius, enabled: enabled)
        questionMarkButton?.addTarget(self, action: #selector(self.questionMarkTapped), for: .touchUpInside)
        self.view?.addSubview(questionMarkButton!)
        let xPos3 = showFoundedWordsTableView!.frame.minX + radius + buttonCenterDistance * 2
        let center3 = CGPoint(x: xPos3, y:yPos)
        starButton = createButton(imageName: "", title: star, frame: buttonFrame, center: center3, cornerRadius: radius, enabled: enabled)
        starButton?.addTarget(self, action: #selector(self.starButtonTapped), for: .touchUpInside)
        self.view?.addSubview(starButton!)
        let xPos4 = showFoundedWordsTableView!.frame.minX + radius + buttonCenterDistance * 3
        let center4 = CGPoint(x: xPos4, y:yPos)
        retypeButton = createButton(imageName: "retype.png", imageSize: 0.6, title: "", frame: buttonFrame, center: center4, cornerRadius: radius, enabled: enabled)
        retypeButton?.addTarget(self, action: #selector(self.retypeButtonTapped), for: .touchUpInside)
        self.view?.addSubview(retypeButton!)
        let xPos5 = showFoundedWordsTableView!.frame.minX + radius + buttonCenterDistance * 4
        let center5 = CGPoint(x: xPos5, y:yPos)
        sortButton = createButton(imageName: "sortdown.png", imageSize: 0.6, title: "", frame: buttonFrame, center: center5, cornerRadius: radius, enabled: enabled)
        sortButton!.addTarget(self, action: #selector(self.sortButtonTapped), for: .touchUpInside)
        self.view?.addSubview(sortButton!)
   }
    
    @objc func doneButtonTapped() {
        hideScreen(hide: false)
        showFoundedWordsTableView?.removeFromSuperview()
        showFoundedWordsTableView = nil
        wtGameboard!.clear()
    }
    
    @objc func questionMarkTapped() {
        sortUp = true
        setSortButtonImage()
        addLetterToSearchingWord(letter: questionMark)
    }
    
    @objc func starButtonTapped() {
        sortUp = true
        setSortButtonImage()
        addLetterToSearchingWord(letter: star)
    }
    
    @objc func retypeButtonTapped() {
        sortUp = true
        setSortButtonImage()
        removeLastLetterFromSearchingWord()
    }
    
    @objc func sortButtonTapped() {
        showFoundedWordsTableView?.removeFromSuperview()
        showFoundedWordsTableView = nil
        sortUp = !sortUp
        setSortButtonImage()
        showSearchResults()
     }
    
    private func setSortButtonImage() {
        var image = UIImage()
        image = UIImage(named: sortUp ? "sortdown.png" : "sortup.png")!
        sortButton!.setImage(image, for: UIControl.State.normal)
    }
    
    private func hideScreen(hide: Bool) {
//  hide the bottom buttons
        timerIsCounting = !hide
        inDefiningSearchingWord = hide
//        let gridSize = wtGameboard!.getGridSize()
//        let gridPosition = wtGameboard!.getGridPosition()
        wtGameboardMovedBy = self.frame.height * 0.15
//        print(origMovedBy)
//        wtGameboardMovedBy = self.frame.height - (gridPosition.y + gridSize.height / 2)
        for row in 0...10 {
            if let child = bgSprite!.childNode(withName: "Row\(row)") {
                child.position.y -= hide ? wtGameboardMovedBy : -wtGameboardMovedBy
            }
        }
        if hide {
            wtGameboard!.position = CGPoint(x: wtGameboard!.position.x, y: wtGameboard!.position.y - wtGameboardMovedBy)
        } else {
            wtGameboard!.position = CGPoint(x: wtGameboard!.position.x, y: wtGameboard!.position.y + wtGameboardMovedBy)
            doneButton!.removeFromSuperview()
            questionMarkButton!.removeFromSuperview()
            starButton!.removeFromSuperview()
            retypeButton!.removeFromSuperview()
            sortButton!.removeFromSuperview()
            doneButton = nil
            questionMarkButton = nil
            starButton = nil
            retypeButton = nil
            sortButton = nil
        }
        pieceArray[0].isHidden = hide
        pieceArray[1].isHidden = hide
        pieceArray[2].isHidden = hide
        goToPreviousGameButton!.isHidden = hide
        goToNextGameButton!.isHidden = hide
        searchButton!.isHidden = hide
        allWordsButton!.isHidden = hide
        goBackButton!.isHidden = hide
        searchButton!.isHidden = hide
//        if undoButton != nil {
//            undoButton!.isHidden = hide
//        }
   }
    
    private func addLetterToSearchingWord(letter: String) {
        searchingWord += letter
        showFoundedWordsTableView?.removeFromSuperview()
        showFoundedWordsTableView = nil
        showSearchResults()
    }

    private func removeLastLetterFromSearchingWord() {
        if searchingWord.length > 0 {
            searchingWord.removeLast()
        }
        showFoundedWordsTableView?.removeFromSuperview()
        showFoundedWordsTableView = nil
        showSearchResults()
    }
    
    var sortUp = true
    let star = "*"
    let questionMark = "?"
    var searchingParts = [String]()
    var beginswith = ""
    var endswith = ""
    var containsParts = [String]()
    
    private func filterWordList()->Results<WordListModel>? {

//        var containsIndex = 0
        searchingParts = [String]()
        beginswith = GV.actLanguage
        endswith = ""
        containsParts = [String]()
        var actString = ""
//        if searchingWord.begins(with: star) {
//            searchingWord.removeFirst()
//            return nil
//        }
        for pos in 0..<searchingWord.length {
            let actSearchingChar = searchingWord.lowercased().char(at: pos)
            if actSearchingChar == questionMark {
                if actString.count > 0 && actString.char(at: 0) != questionMark {
                    searchingParts.append(actString)
                    actString = ""
                }
                actString += questionMark
                continue
            }
            if actSearchingChar == star {
                if actString.count > 0 && actString.firstChar() != star {
                    searchingParts.append(actString)
                    actString = star
                }
                if actString.count == 0 {
                    actString = star
                }
                continue
            }
            if actSearchingChar != star && actSearchingChar != questionMark {
                if actString.count > 0 && (actString.char(at:0) == star || actString.char(at:0) == questionMark) {
                    searchingParts.append(actString)
                    actString = ""
                }
                actString += actSearchingChar
                continue
            }
        }
        if actString != "" {
            searchingParts.append(actString)
        }
//        print("searchingParts:")
        if searchingParts.count == 0 {
            return nil
        }
//        var index = 0
//        for part in searchingParts {
//            print("index: \(index):\(part)")
//            index += 1
//        }
        if searchingParts.first!.firstChar() != star && searchingParts.first!.firstChar() != questionMark {
            beginswith += searchingParts.first!
        }
        if searchingParts.count > 1 && searchingParts.last!.firstChar() != star && searchingParts.last!.firstChar() != questionMark {
            endswith += searchingParts.last!
        }
        for (ind, part) in searchingParts.enumerated() {
            if ind > 0 && ind < searchingParts.count - 1 && part.char(at: 0) != star && part.char(at: 0) != questionMark {
                containsParts.append(part)
            }
        }
//        print("beginswith:\(beginswith)")
//        print("endswith:\(endswith)")
        var results: Results<WordListModel>?
        if searchingWord.length > 1 {
            if containsParts.count > 0 {
                results = realmWordList.objects(WordListModel.self).filter("word BEGINSWITH %@ and word CONTAINS %@", beginswith, containsParts[0])
            } else if endswith.length > 0 {
                results = realmWordList.objects(WordListModel.self).filter("word BEGINSWITH %@ and word ENDSWITH %@", beginswith, endswith)
            } else {
                results = realmWordList.objects(WordListModel.self).filter("word BEGINSWITH %@", beginswith)
            }
        }
        
        return results
    }
    
    private func wordFilter(word: String)->LineOfFoundedWords? {
        if word.length > 18 {
            return nil
        }
        if /*word == "молоко" || word == "молочко" */ word == "kutyaharapás" {
            print(word)
        }
        var starSearchingActiv = false
//        var lastStarPosition = 0
//        let beginswith = searchingParts[0]
        var wordIndex = 0
        for part in searchingParts {
            if word.length < wordIndex {
                return nil
            }
            if wordIndex + part.length > word.length {
                return nil
            }
            if part.firstChar() == star {
                wordIndex += 1
                starSearchingActiv = true
            } else if part.firstChar() == questionMark {
                wordIndex += part.length
            } else {
                if starSearchingActiv {
                    if let index = word.index(from: wordIndex, of: part) {
                        wordIndex = index + part.length
                        starSearchingActiv = false
                        continue
                    } else {
                        return nil
                    }
                }
                if word.subString(at: wordIndex, length: part.length) == part {
                    wordIndex += part.length
                    continue
                } else {
                    return nil
                }
            }
        }
        if !starSearchingActiv && wordIndex != word.length {
            return nil
        }
        let returnValue = LineOfFoundedWords(word)
        return returnValue
    }

    private func showSearchResults() {
        listOfFoundedWords = [LineOfFoundedWords]()
        let filteredWordList = filterWordList()
        if filteredWordList != nil {
            for word in filteredWordList! {
                if let OKWord = wordFilter(word: word.word.subString(at: 2, length: word.word.length - 2)) {
                    listOfFoundedWords.append(OKWord)
                }
            }
        }
        if sortUp {
            listOfFoundedWords = listOfFoundedWords.sorted(by: {$0.length < $1.length || ($0.length == $1.length && $0.word < $1.word)})
        } else {
            listOfFoundedWords = listOfFoundedWords.sorted(by: {$0.length > $1.length || ($0.length == $1.length && $0.word > $1.word)})
        }
        showMyFoundedWords()
    }
    
    func getSearchingWord() {
        searchingWord = ""
    }
    
    func showMyFoundedWords() {
//        if listOfFoundedWords.count == 0 {
//            return
//        }
        tableType = .ShowFoundedWords
        showFoundedWordsTableView = WTTableView()

        timerIsCounting = false
        maxLength = 0
        for word in listOfFoundedWords {
            maxLength = word.length > maxLength ? word.length : maxLength
        }
        calculateColumnWidths(showCount: false)
        let header1 = GV.language.getText(.tcShowWordlistHeader, values: String(listOfFoundedWords.count))
        let header0 = GV.language.getText(.tcSearchingWord, values: searchingWord)
        showFoundedWordsTableView?.backgroundColor = myLightBlue
//        maxLength = maxLength > header1.length ? maxLength : header1.length
        showFoundedWordsTableView?.setDelegate(delegate: self)
        showFoundedWordsTableView?.register(CustomTableViewCell.self, forCellReuseIdentifier: "cell")
        let lineHeight = title.height(font: myFont!)
        let headerframeHeight = lineHeight * 3.2
        var showingWordsHeight = CGFloat(listOfFoundedWords.count) * lineHeight * 1.1
        let maxHeight = (GV.onIpad ? 0.37 : 0.35) * self.frame.height
        if showingWordsHeight  > maxHeight {
            var counter = CGFloat(listOfFoundedWords.count)
            repeat {
                counter -= 1
                showingWordsHeight = lineHeight * counter
            } while showingWordsHeight + headerframeHeight > maxHeight
        }
        if maxLength < title.length {
            maxLength = title.length
        }
//        let optimalWidth = self.frame.width * 0.4
        var width: CGFloat = 0
        (width, _) = calculateTableViewWidth(header0: header0, header1: header1, header2: title)
//        width = width < optimalWidth ? optimalWidth : width
        let size = CGSize(width: width, height: maxHeight)//showingWordsHeight + headerframeHeight)
        let origin = CGPoint(x: 0.5 * (self.frame.width - width), y: self.frame.height * 0.035)
        showFoundedWordsTableView?.frame=CGRect(origin: origin, size: size)
        self.showFoundedWordsTableView?.reloadData()
        
        //        showOwnWordsTableView?.reloadData()
        self.scene?.view?.addSubview(showFoundedWordsTableView!)
        
    }
    
    private func calculateTableViewWidth(header0: String, header1: String, header2: String)->(width: CGFloat, length:Int) {
        var header = header0
        if header1.length > header.length {
            header = header1
        }
        if header2.length > header.length {
            header = header2
        }

        return ((header + " ").width(font: myFont!), header.length)
    }


    @objc func goPreviousGame() {
        if self.enabled {
            stopShowingTableIfNeeded()
            if timer != nil {
                timer!.invalidate()
                timer = nil
            }
            removeAllSubviews()
            wtSceneDelegate!.gameFinished(start: .PreviousGame)
        }
    }
    
    @objc func goNextGame() {
        if self.enabled {
            stopShowingTableIfNeeded()
            if timer != nil {
                timer!.invalidate()
                timer = nil
            }
            removeAllSubviews()
            wtSceneDelegate!.gameFinished(start: .NextGame)
        }
    }
    
    @objc func showAllWordsInTableView() {
        if self.enabled {
            if GV.generateHelpInfo {
                saveHelpInfo(action: .ShowMyWordsButton)
            }
            stopShowingTableIfNeeded()
            showOwnWordsInTableView()
            showingWordsInTable = true
        }
    }
    
    var searchButton: MyButton?
    var saveDataButton: MyButton?
    var allWordsButton: MyButton?
    var finishButton: MyButton?
    var undoButton: MyButton?
    var goBackButton: MyButton?
    var goToPreviousGameButton: MyButton?
    var goToNextGameButton: MyButton?
    
    var buttonHeight = CGFloat(0)
    var buttonSize = CGSize(width: CGFloat(0), height: CGFloat(0))
    
    func hideButtons(hide: Bool) {
        goToPreviousGameButton!.isEnabled = !hide
        goToNextGameButton!.isEnabled = !hide
//        undoButton!.isEnabled = !hide
        allWordsButton!.isEnabled = !hide
        finishButton!.isEnabled = !hide
        goBackButton!.isEnabled = !hide
        searchButton!.isEnabled = !hide
        if hide {
            goToPreviousGameButton!.alpha = 0.2
            goToNextGameButton!.alpha = 0.2
//            undoButton!.alpha = 0.2
            allWordsButton!.alpha = 0.2
            finishButton!.alpha = 0.2
            goBackButton!.alpha = 0.2
            searchButton!.alpha = 0.2
        } else {
            goToPreviousGameButton!.alpha = 1.0
            goToNextGameButton!.alpha = 1.0
//            undoButton!.alpha = 1.0
            allWordsButton!.alpha = 1.0
            finishButton!.alpha = 1.0
            goBackButton!.alpha = 1.0
            searchButton!.alpha = 1.0
        }

    }

    func createGoToPreviousGameButton(enabled: Bool) {
        if goToPreviousGameButton != nil {
            goToPreviousGameButton?.removeFromParent()
            goToPreviousGameButton = nil
        }
//        let frame = CGRect(x: 0, y: 0, width: buttonHeight, height: buttonHeight)
        let center = CGPoint(x:self.frame.width * firstButtonColumn, y:self.frame.height * lastButtonLine)
//        let radius = self.frame.width * 0.045
        let hasFrame = GV.buttonType == GV.ButtonTypeSimple
        let imageName = hasFrame ? "LeftSimple" : "LeftElite"
        goToPreviousGameButton = createMyButton(imageName: imageName, size: buttonSize, center: center, enabled: enabled, newSize: buttonHeight)
        goToPreviousGameButton!.setButtonAction(target: self, triggerEvent:.TouchUpInside, action: #selector(self.goPreviousGame))
        goToPreviousGameButton!.name = imageName
        goToPreviousGameButton!.zPosition = 10
//        goToPreviousGameButton = createButton(imageName: imageName, title: "", frame: frame, center: center, cornerRadius: radius, enabled: enabled, hasFrame: hasFrame)
//        goToPreviousGameButton?.addTarget(self, action: #selector(self.goPreviousGame), for: .touchUpInside)
        bgSprite!.addChild(goToPreviousGameButton!)
//        self.view?.addSubview(goToPreviousGameButton!)
    }
    func createGoToNextGameButton(enabled: Bool) {
        if goToNextGameButton != nil {
            goToNextGameButton?.removeFromParent()
            goToNextGameButton = nil
        }
//        let frame = CGRect(x: 0, y: 0, width: buttonHeight, height: buttonHeight)
        let center = CGPoint(x:self.frame.width * lastButtonColumn, y:self.frame.height * lastButtonLine)
//        let radius = self.frame.width * 0.045
        let hasFrame = GV.buttonType == GV.ButtonTypeSimple
        let imageName = hasFrame ? "RightSimple" : "RightElite"
        goToNextGameButton = createMyButton(imageName: imageName, size: buttonSize, center: center, enabled: enabled, newSize: buttonHeight)
        goToNextGameButton!.setButtonAction(target: self, triggerEvent:.TouchUpInside, action: #selector(self.goNextGame))
        goToNextGameButton!.name = imageName
        goToNextGameButton!.zPosition = 10
//        goToNextGameButton = createButton(imageName: imageName, title: "", frame: frame, center: center, cornerRadius: radius, enabled: enabled, hasFrame: hasFrame )
//        goToNextGameButton?.addTarget(self, action: #selector(self.goNextGame), for: .touchUpInside)
        bgSprite!.addChild(goToNextGameButton!)
    }
    
    private func createAllWordsButton() {
        if allWordsButton != nil {
            allWordsButton?.removeFromParent()
            allWordsButton = nil
        }
        var ownHeaderYPos = CGFloat(0)
//        let ownHeader: SKNode = (bgSprite!.childNode(withName: ownWordsHeaderName) as! SKLabelNode)
        let title = GV.language.getText(.tcShowAllWords)
        let wordLength = title.width(font: myTitleFont!)
//        let wordHeight = title.height(font: myTitleFont!)
        let size = CGSize(width:wordLength * 1.5, height: buttonHeight)
        ownHeaderYPos = self.frame.height * mybuttonLineCenterY// - ownHeader.frame.maxY + frame.height
        allWordsButtonCenter = CGPoint(x:self.frame.width * 0.55, y: ownHeaderYPos) //self.frame.height * 0.20)
//        let radius = frame.height * 0.5
        allWordsButton = createMyButton(title: title, size: size, center: allWordsButtonCenter, enabled: true )
        allWordsButton!.setButtonAction(target: self, triggerEvent:.TouchUpInside, action: #selector(showAllWordsInTableView))
//        allWordsButton?.addTarget(self, action: #selector(self.showAllWordsInTableView), for: .touchUpInside)
        allWordsButton!.zPosition = 10
        bgSprite!.addChild(allWordsButton!)
    }
    
    private func createMyButton(imageName: String = "", title: String = "", size: CGSize, center: CGPoint, enabled: Bool, newSize: CGFloat = 0)->MyButton {
        var button: MyButton
        if imageName != "" {
            let image = UIImage(named: imageName)!
            let texture = SKTexture(image: image)
            let imageSize = image.size.width * 0.9
            let downImage = resizeImage(image: image, newWidth: imageSize)
            let downTexture = SKTexture(image: downImage)
            button = MyButton(normalTexture: texture, selectedTexture:downTexture, disabledTexture: texture)
        } else {
            button = MyButton(fontName: myTitleFont!.fontName, size: size)
            button.setButtonLabel(title: title, font: myTitleFont!)
       }
        button.position = center
        button.size = size

        button.alpha = enabled ? 1.0 : 0.2
        button.isEnabled = enabled
//        if hasFrame {
//            button.layer.borderWidth = GV.onIpad ? 5 : 3
//            button.layer.borderColor = UIColor(red: 220/255, green: 220/255, blue: 220/255, alpha: 1.0).cgColor
//        }
//        button.frame = frame
//        button.center = center
        return button

    }
    
    private func createFinishButton() {
        if finishButton != nil {
            finishButton?.removeFromParent()
            finishButton = nil
        }
        let title = GV.language.getText(.tcFinishGame)
        let wordLength = title.width(font: myTitleFont!)
//        let wordHeight = title.height(font: myTitleFont!)
        let size = CGSize(width:wordLength * 1.2, height: buttonHeight)
        let ownHeaderYPos = self.frame.height * mybuttonLineCenterY// - ownHeader.frame.maxY + frame.height
        let finishButtonCenter = CGPoint(x:self.frame.width * 0.2, y: ownHeaderYPos) //self.frame.height * 0.20)
//        let radius = frame.height * 0.5
        finishButton = createMyButton(title: title, size: size, center: finishButtonCenter, enabled: true )
        finishButton!.isHidden = goOnPlaying ? false : true
        finishButton!.setButtonAction(target: self, triggerEvent:.TouchUpInside, action: #selector(finishButtonTapped))

//        myButton!.addTarget(self, action: #selector(self.finishButtonTapped), for: .touchUpInside)
//        finishButton?.layer.zPosition = -100
//        finishButton = myButton
        finishButton!.zPosition = self.zPosition + 1
        bgSprite!.addChild(finishButton!)
    }
    
    @objc private func finishButtonTapped() {
        if self.enabled {
            showGameFinished(status: .OK)
            saveHelpInfo(action: .FinishButton)
        }
    }
    

    
    var allWordsButtonCenter = CGPoint(x:0, y:0)
    
    private func createSearchButton() {
        if searchButton != nil {
            searchButton!.removeFromParent()
            searchButton = nil
        }
        let size = CGSize(width: buttonHeight, height: buttonHeight)
//        let freePlaceWidth = self.frame.width - allWordsButton!.frame.maxX
        let center = CGPoint(x: allWordsButton!.frame.maxX + (self.frame.width - allWordsButton!.frame.maxX) * 0.5, y: allWordsButtonCenter.y)
//        let radius = self.frame.width * 0.04
//        let image = UIImage(named: "search")
        let newSize = allWordsButton!.size.height
        let myButton = createMyButton(imageName: "search", size: size, center: center, enabled: true, newSize: newSize)
        myButton.setButtonAction(target: self, triggerEvent:.TouchUpInside, action: #selector(wordListTapped))
        //        allWordsButton?.addTarget(self, action: #selector(self.showAllWordsInTableView), for: .touchUpInside)
        myButton.zPosition = self.zPosition + 1
        searchButton = myButton
//        searchButton!.addTarget(self, action: #selector(self.wordListTapped), for: .touchUpInside)
        bgSprite!.addChild(searchButton!)
    }
    
    private func createSaveDataButton() {
        if !(playerActivity != nil && playerActivity!.count > 0 && playerActivity![0].maySaveInfos) {
            return
        }
        if saveDataButton != nil {
            saveDataButton!.removeFromParent()
            saveDataButton = nil
        }
        let size = CGSize(width: buttonHeight, height: buttonHeight)
        //        let freePlaceWidth = self.frame.width - allWordsButton!.frame.maxX
        let center = CGPoint(x: self.frame.width * 0.07, y: self.frame.height * 0.925)
        let newSize = allWordsButton!.size.height
        let myButton = createMyButton(imageName: "save", size: size, center: center, enabled: true, newSize: newSize)
        myButton.setButtonAction(target: self, triggerEvent:.TouchUpInside, action: #selector(saveDataButtonTapped))
        //        allWordsButton?.addTarget(self, action: #selector(self.showAllWordsInTableView), for: .touchUpInside)
        myButton.zPosition = self.zPosition + 1
        saveDataButton = myButton
        //        searchButton!.addTarget(self, action: #selector(self.wordListTapped), for: .touchUpInside)
        bgSprite!.addChild(saveDataButton!)

    }
    var savedGameData: Results<GameData>?
    var savedGameDataSubscription: SyncSubscription<GameData>?
    var savedGameDataToken: NotificationToken?
    
    

    @objc public func saveDataButtonTapped() {
        let saveDataRecord = GameData()
        let ownerName = playerActivity![0].name
        let combinedKey = GV.playingRecord.combinedKey + ownerName
        savedGameData = realmSync!.objects(GameData.self).filter("combinedKey = %@", combinedKey)
        savedGameDataSubscription = savedGameData!.subscribe(named: "savedGameData:\(combinedKey)")
        savedGameDataToken = savedGameDataSubscription!.observe(\.state) { [weak self]  state in
            if state == .complete {
                if self!.savedGameData!.count > 0 {
                    try! RealmService.safeWrite() {
                        for round in self!.savedGameData![0].rounds {
                            RealmService.delete(round)
                        }
                        RealmService.delete(self!.savedGameData!)
                    }
                }
                saveDataRecord.combinedKey = combinedKey
                saveDataRecord.language = GV.playingRecord.language
                saveDataRecord.gameNumber = GV.playingRecord.gameNumber
                saveDataRecord.gameStatus = GV.playingRecord.gameStatus
                saveDataRecord.mandatoryWords = GV.playingRecord.mandatoryWords
                saveDataRecord.ownWords = GV.playingRecord.ownWords
                saveDataRecord.pieces = GV.playingRecord.pieces
                saveDataRecord.words = GV.playingRecord.words
                saveDataRecord.score = GV.playingRecord.score
                saveDataRecord.time = GV.playingRecord.time
                saveDataRecord.owner = playerActivity![0]
                try! RealmService.safeWrite() {
                    RealmService.add(saveDataRecord)
                    for round in GV.playingRecord.rounds {
                        let myRound = RoundData()
                        myRound.infos = round.infos
                        myRound.activityItems = round.activityItems
                        myRound.gameArray = round.gameArray
                        myRound.roundScore = round.roundScore
                        saveDataRecord.rounds.append(myRound)
                    }
                }
            }
        }
    }

    let buttonYPosition: CGFloat = 0.145
    private func createGoBackButton() {
        if goBackButton != nil {
            goBackButton?.removeFromParent()
            goBackButton = nil
        }
//        let frame = CGRect(x: 0, y: 0, width: buttonHeight, height: buttonHeight)
        let center = CGPoint(x:self.frame.width * firstButtonColumn, y:self.frame.height * firstButtonLine)
//        let radius = self.frame.width * 0.04
        let hasFrame = GV.buttonType == GV.ButtonTypeSimple
        let imageName = hasFrame ? "BackSimple" : "BackElite"
        goBackButton = createMyButton(imageName: imageName, size: buttonSize, center: center, enabled: true, newSize: buttonHeight)
        goBackButton!.setButtonAction(target: self, triggerEvent:.TouchUpInside, action: #selector(self.goBackTapped))
        goBackButton!.name = imageName
        goBackButton!.zPosition = 10
        bgSprite!.addChild(goBackButton!)
    }
    
    var firstButtonColumn: CGFloat = 0.1
    var lastButtonColumn: CGFloat = 0.92
    var firstButtonLine: CGFloat = 0.86
    var lastButtonLine: CGFloat = 0.08
    
    private func createUndo() {
        if undoButton != nil {
            undoButton?.removeFromParent()
            undoButton = nil
        }
        if activityRoundItem.count == 0 {
            activityRoundItem.append(ActivityRound())
            activityRoundItem[activityRoundItem.count - 1].activityItems = [ActivityItem]()
        }
        let hasFrame = GV.buttonType == GV.ButtonTypeSimple
        let imageName = hasFrame ? "UndoSimple" : "UndoElite"
        let center = CGPoint(x: self.frame.width * lastButtonColumn, y: self.frame.height * firstButtonLine)
        let size = CGSize(width: buttonHeight, height: buttonHeight)
        let newSize = buttonHeight
        undoButton = createMyButton(imageName: imageName, size: size, center: center, enabled: false, newSize: newSize)
        undoButton!.setButtonAction(target: self, triggerEvent:.TouchUpInside, action: #selector(self.undoTapped))
        undoButton!.name = imageName
        undoButton!.zPosition = 10
        bgSprite!.addChild(undoButton!)
    }
    
    private func setUndoButton(enabled: Bool) {
        undoButton!.alpha = enabled ? 1.0 : 0.2
        undoButton!.isEnabled = enabled
    }
    
    private func createButton(imageName: String, imageSize: CGFloat = 1.0, title: String, frame: CGRect, center: CGPoint, cornerRadius: CGFloat, enabled: Bool, color: UIColor? = nil, hasFrame: Bool = true)->UIButton {
        let button = UIButton()
        if imageName.length > 0 {
            let image = resizeImage(image: UIImage(named: imageName)!, newWidth: frame.width * imageSize)
            button.setImage(image, for: UIControl.State.normal)
        }
        if title.length > 0 {
            button.setTitle(title, for: .normal)
            button.setTitleColor(UIColor.black, for: .normal)
            button.titleLabel?.font = myTitleFont
        }
        button.backgroundColor = color == nil ? bgColor : color
        button.layer.cornerRadius = cornerRadius
        button.alpha = enabled ? 1.0 : 0.2
        button.isEnabled = enabled
        if hasFrame {
            button.layer.borderWidth = GV.onIpad ? 5 : 3
            button.layer.borderColor = UIColor(red: 220/255, green: 220/255, blue: 220/255, alpha: 1.0).cgColor
        }
        button.frame = frame
        button.center = center
        return button
    }
    
    func resizeImage(image: UIImage, newWidth: CGFloat, resizeBoth: Bool = true) -> UIImage {
        
        let scale = newWidth / image.size.width
        let newHeight = resizeBoth ? image.size.height * scale : image.size.height
        UIGraphicsBeginImageContext(CGSize(width: newWidth, height: newHeight))
        image.draw(in: CGRect(x: 0, y: 0, width: newWidth, height: newHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage!
    }
    
    private func showWordsToCollect() {
//        var counter = 1
//        let wordList = GV.playingRecord.mandatoryWords.uppercased().components(separatedBy: "°")
        
        createLabel(word: GV.language.getText(.tcBonusHeader, values:
            String(WTGameWordList.shared.getCountWords(mandatory: false)),
                                              String(WTGameWordList.shared.getCountOwnWords(founded: false)),
                                              //                    String(WTGameWordList.shared.getScore(mandatory: false))), first: false, name: ownWordsHeaderName)
            String(0)),
                    linePosition: bonusPointsLinePosition, name: bonusHeaderName)
        createLabel(word: GV.language.getText(.tcOwnWords, values:
            String(WTGameWordList.shared.getCountOwnWords(founded:true)),
            String(WTGameWordList.shared.getCountOwnWords(founded: false)),
//                    String(WTGameWordList.shared.getScore(mandatory: false))), first: false, name: ownWordsHeaderName)
            String(0)),
                    linePosition: ownWordsLinePosition, name: ownWordsHeaderName)
        createLabel(word: GV.language.getText(.tcWordsToCollect, values: String(WTGameWordList.shared.getCountWords(mandatory: true)), "0","0", "0"), linePosition: mandatoryWordsLinePosition, name: mandatoryWordsHeaderName)
        let wordList = WTGameWordList.shared.getMandatoryWords()
        for (counter, word) in wordList.enumerated() {
            //            GV.allWords.append(WordToCheck(word: word, mandatory: true, creationIndex: NoValue, countFounded: 0))
            //            var wordToShow = AllWordsToShow(word: word)
            //            allWordsToShow.append(wordToShow)
            //            let wordToShow = WordToCheck(word: word.word, countFounded: 0, mandatory: true, creationIndex: 0, score: 0)
            createWordLabel(wordToShow: word, counter: counter)
            //            counter += 1
        }
   }
    
    private func createWordLabel(wordToShow: WordWithCounter, counter: Int) {
        let xPositionMultiplier = [0.2, 0.5, 0.8]
        let mandatoryYPositionMultiplier = mandatoryWordsLinePosition
//        let ownYPositionMultiplier:CGFloat = 0.80 // orig
        let distance: CGFloat = 0.02
        let label = SKLabelNode(fontNamed: GV.actFont)// Snell Roundhand")
        let wordRow = CGFloat(counter / countWordsInRow)
        let wordColumn = counter % countWordsInRow
        let value = (wordRow + 1) * distance
        var yPosition: CGFloat = 0

        yPosition = self.frame.height * (mandatoryYPositionMultiplier - value)
        let xPosition = self.frame.size.width * CGFloat(xPositionMultiplier[wordColumn])
        label.position = CGPoint(x: xPosition, y: yPosition)
        label.fontSize = self.frame.size.height * 0.0175
        label.fontColor = .black
        label.text = wordToShow.word + " (\(wordToShow.counter))"
        label.name = wordToShow.word
        label.zPosition = self.zPosition + 10
        bgSprite!.addChild(label)
//        if !showWord {
//            label.isHidden = true
//        }
//        setOwnWordsIndex()
    }
    
    private func createLabel(word: String, linePosition: CGFloat, name: String) {
//        let ownYPosition: [CGFloat] = [0.02, 0.04, 0.06]
        let label = SKLabelNode(fontNamed: GV.actFont) // Snell Roundhand")
//        let yIndex = (WTGameWordList.shared.getCountWords(mandatory: true) / countWordsInRow) - 2
        let yPosition = self.frame.height * linePosition //(first ? 0 : 0.06))
        let xPosition = self.frame.size.width * 0.5
        label.position = CGPoint(x: xPosition, y: yPosition)
        label.fontSize = self.frame.size.height * 0.0175
        label.fontColor = .black
        label.text = word
        label.name = name
        bgSprite!.addChild(label)
    }
    
//    var random: MyRandom?
    
    @objc private func OKTapped() {
        print("OK")
    }
    
    @objc private func cancelTapped() {
        print("cancel")
    }
    private func play() {
        GV.playing = true
        timerIsCounting = true
        headerCreated = false
        gameNumberForGenerating = GV.basicDataRecord.difficulty == GameDifficulty.Easy.rawValue ? GV.DemoEasyGameNumber : GV.DemoMediumGameNumber
        WTGameWordList.shared.setDelegate(delegate: self)
        timeForGame = TimeForGame(from: GV.playingRecord.time)
        myTimer = MyTimer(time: timeForGame)
        wtGameboard = WTGameboard(countCols: GV.sizeOfGrid, parentScene: self, delegate: self, yCenter: gameboardCenterY)
        createFixLetters()
        if GV.playingRecord.gameStatus == GV.GameStatusContinued {
            goOnPlaying = true
        }
        generateArrayOfWordPieces(new: new)
        indexOfTilesForGame = 0
        pieceArray = Array(repeating: WTPiece(), count: 3)
        for index in 0..<3 {
            origPosition[index] = CGPoint(x:self.frame.width * shapeMultiplicator[index], y:self.frame.height * pieceArrayCenterY)
        }
        if !new {
            wtGameboard!.setRoundInfos()
            WTGameWordList.shared.restoreFromPlayingRecord()
            restoreGameArray()
            showFoundedWords()
        } else {
            if GV.playingRecord.rounds.count == 0 {
                actRound = 1
                try! realm.safeWrite() {
                    let rounds = RoundDataModel()
                    GV.playingRecord.rounds.append(rounds)
                }
            }

            pieceArray = Array(repeating: WTPiece(), count: 3)
//            roundIndexes.append(0)
            for index in 0..<3 {
                pieceArray[index] = getNextPiece(/*horizontalPosition: index*/)
                origSize[index] = pieceArray[index].size
                pieceArray[index].position = origPosition[index]
                pieceArray[index].name = "Pos\(index)"
                pieceArray[index].setPieceFromPosition(index: index)
                bgSprite!.addChild(pieceArray[index])
            }
        }

        createGoToPreviousGameButton(enabled: hasPreviousRecords(playingRecord: GV.playingRecord))
        createGoToNextGameButton(enabled: hasNextRecords(playingRecord: GV.playingRecord))
        createAllWordsButton()
        createFinishButton()
        createSearchButton()
        createSaveDataButton()
//        saveActualState()
        
        if timer != nil {
            timer!.invalidate()
        }
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(countTime(timerX: )), userInfo: nil, repeats: true)
        countTime(timerX: Timer())
        if showHelp {
            showHelpDemo()
        }
    }
    
    var bestPlayerNickname = ""
    var bestScore = 0
    var actPlayer = ""
    var actScore = 0
    var lastPosition = CGPoint(x: 0, y: 0)
//    let convertValue: CGFloat = 1000
    
    private func createFixLetters() {
        if GV.basicDataRecord.difficulty != GameDifficulty.Medium.rawValue {
            return
        }
//        if GV.playingRecord.gameNumber == demoGameNumber - 1 {
//            return
//        }
        var fixLetters = [UsedLetter]()
        let gameNumber = GV.playingRecord.gameNumber % 1000
        let roundCount = GV.playingRecord.rounds.count == 0 ? 1 : GV.playingRecord.rounds.count
        let random = MyRandom(gameNumber: gameNumber, modifier: (roundCount - 1) * 15)
        let countOfFixLetters = 8 + roundCount * 4
        let countOfLetters = countOfFixLetters + 4 * Int(gameNumber / 100)
        var remainigLength = countOfLetters
        var myLengths = [Int]()
        repeat {
            if remainigLength > 15 {
                let newLength = random.getRandomInt(5, max: 6)
                myLengths.append(newLength)
                remainigLength -= newLength
            } else if remainigLength < 10 {
                myLengths.append(remainigLength)
                break
            } else {
                myLengths.append(5)
                myLengths.append(remainigLength - 5)
                break
            }
        } while true
        var myLetters = ""
        for length in myLengths {
            let likeValue = String(repeating: "?", count: length)
            let words = realmMandatoryList.objects(MandatoryListModel.self).filter("language = %@ and word LIKE %d", GV.actLanguage, likeValue)
            myLetters += words[random.getRandomInt(0, max: words.count)].word
            print("createFixLetters: \(myLetters)")
        }
        var inputWord = ""
        let items = myLetters.components(separatedBy: "ß")
        if items.count > 1 {
            for item in items {
                inputWord += item.uppercased() + "ß"
            }
            inputWord.removeLast()
        } else {
            inputWord = myLetters.uppercased()
        }
        myLetters = inputWord

        var letterIndex = 0
        for _ in 1...countOfLetters / 4 {
            var col = 0
            var row = 0
            var positionExists = false
            repeat {
                col = random.getRandomInt(0, max: 4)
                row = random.getRandomInt(0, max: 4)
                positionExists = false
                for usedLetter in fixLetters {
                    if usedLetter.col == col && usedLetter.row == row {
                        positionExists = true
                    }
                }
                if GV.gameArray[col][row].status != .Empty ||
                   GV.gameArray[9 - col][row].status != .Empty ||
                   GV.gameArray[col][9 - row].status != .Empty ||
                   GV.gameArray[9 - col][9 - row].status != .Empty
                {
                    positionExists = true
                }
            } while positionExists
            fixLetters.append(UsedLetter(col:col, row: row, letter: myLetters.char(at:letterIndex)))
            fixLetters.append(UsedLetter(col: 9 - col, row: row, letter: myLetters.char(at: letterIndex + 1)))
            fixLetters.append(UsedLetter(col: col, row: 9 - row, letter: myLetters.char(at:letterIndex + 2)))
            fixLetters.append(UsedLetter(col: 9 - col, row: 9 - row, letter: myLetters.char(at: letterIndex + 3)))
            letterIndex += 4
        }
        wtGameboard!.addFixLettersToGamearray(fixLetters: fixLetters)
    }

    private func showHelpDemo() {
        hideButtons(hide: true)
        gameFinished = false
        let generateHelpInfo = GV.generateHelpInfo
        GV.generateHelpInfo = false
        let duration = 0.0//1
        let texture = SKTexture(imageNamed: "finger1")
        let fingerSprite = SKSpriteNode(texture: texture)
        var fingerActions = [SKAction]()
        fingerSprite.zPosition = 1001
        var lastTouchedPosition = CGPoint(x: 0, y: 0)
        enum ActionType: Int {
            case TouchesBegan, TouchesMoved, TouchesEnded, NoMore
        }
        let multiplier: CGFloat = 0.1
        let width = self.frame.width * multiplier
        let fingerSize = CGSize(width: width, height: width)
        var startPosition = CGPoint(x: self.frame.midX, y: self.frame.minY)
        fingerSprite.size = fingerSize
        fingerSprite.position = startPosition
        fingerSprite.zPosition = 100
        let gridStartPosition = CGPoint(x: wtGameboard!.grid!.frame.minX, y:wtGameboard!.grid!.frame.minY)
        let gridSize = wtGameboard!.grid!.frame.width
        let blockSize = wtGameboard!.blockSize! * 0.5
        let fingerPositionModifier = CGPoint(x: blockSize, y: blockSize)
        var startFromGamearray = false
        var countMoves = 0
        var stopIndex = 10000
        let stopCounter = 10000
//----------------------------------------------------------------------------
        func addTouchAction(type: ActionType, touchPosition: CGPoint, touchedNodes: TouchedNodes, letters: String = "", duration: Double, counter: Int = 0, index: Int = 0) {
            fingerActions.append(SKAction.move(to: touchPosition - fingerPositionModifier, duration: duration))
            switch type {
             case .TouchesBegan:
                let beganAction = SKAction.run({
                    if counter >= stopCounter {
                        print("hier at \(counter), letters: \(letters)")
                    }
                    self.myTouchesBegan(location: touchPosition, touchedNodes: touchedNodes)
               })
                fingerActions.append(beganAction)
            case .TouchesMoved:
                let moveAction = SKAction.run({
                    if counter == stopCounter && index > 1400 {
                        print("hier at counter: \(counter), index: \(index), touchedNodes: \(touchedNodes)")
                    }
                    self.myTouchesMoved(location: touchPosition, touchedNodes: touchedNodes)
                    
                })
                fingerActions.append(moveAction)
            case .TouchesEnded:
                let endedAction = SKAction.run({
//                    if counter == 89 {
//                        print("at \(counter)")
//                    }
                    let OK = self.myTouchesEnded(location: touchPosition, touchedNodes: touchedNodes, checkLetters: letters)
                    if !OK {
                        print("error by replay at: \(counter), letters: \(letters)")
                    }
                })
                fingerActions.append(endedAction)
                lastTouchedPosition = touchPosition
            default:
                break
            }
        }
//----------------------------------------------------------------------------
        func addButtonTouchedAction(button: MyButton) {
            let waitAction = SKAction.wait(forDuration: 0.025)
            let zielPosition = button.position
            let point = zielPosition - lastTouchedPosition
            let distance = point.length()
            let counter = Int(distance / 10)
            let xAdder = point.x / CGFloat(counter)
            let yAdder = point.y / CGFloat(counter)
            for index in 0..<counter {
                if button == undoButton {
                    let enableAction = SKAction.run({
                        self.setUndoButton(enabled: true)
                    })
                    fingerActions.append(enableAction)
                }
                fingerActions.append(SKAction.move(to: CGPoint(x: lastTouchedPosition.x + CGFloat(index) * xAdder,
                                                               y: lastTouchedPosition.y + CGFloat(index) * yAdder) - fingerPositionModifier, duration: duration))
                fingerActions.append(waitAction)
            }
            let buttonAction = SKAction.run({
                button.myTouchesEnded(touchLocation: zielPosition)
                if button == self.undoButton {
                    self.setUndoButton(enabled: false)
                }
            })
            fingerActions.append(buttonAction)
            fingerActions.append(waitAction)
        }
//----------------------------------------------------------------------------
        enum AlertType: Int {
            case ContinueGameEasyAlert = 0, ContinueGameMediumAlert, FinishGameEasyAlert, FinishGameMediumAlert, OKFixLettersSolvedAlert, OKMandatorySolvedAlert, NoMoreStepsAlert, FinishGameAlert
        }
//----------------------------------------------------------------------------
        func addAlertTouched(alertType: AlertType, action: Selector) {
            var zielPosition: CGPoint?
            switch alertType {
            case .ContinueGameEasyAlert:
                createCongratulationsAlert(congratulationType: .GameFinished, easy: true)
                zielPosition = congratulationsAlert!.getPositionForAction(action: action)
            case .ContinueGameMediumAlert:
                createCongratulationsAlert(congratulationType: .GameFinished, easy: false)
                zielPosition = congratulationsAlert!.getPositionForAction(action: action)
            case .FinishGameEasyAlert:
                createCongratulationsAlert(congratulationType: .GameFinished, easy: true)
                zielPosition = congratulationsAlert!.getPositionForAction(action: action)
            case .FinishGameMediumAlert:
                createCongratulationsAlert(congratulationType: .GameFinished, easy: false)
                zielPosition = congratulationsAlert!.getPositionForAction(action: action)
            case .OKFixLettersSolvedAlert:
                createCongratulationsAlert(congratulationType: .SolvedOnlyFixLetters, easy: false)
                zielPosition = congratulationsAlert!.getPositionForAction(action: action)
            case .OKMandatorySolvedAlert:
                createCongratulationsAlert(congratulationType: .SolvedOnlyMandatoryWords, easy: false)
                zielPosition = congratulationsAlert!.getPositionForAction(action: action)
            case .NoMoreStepsAlert:
                createNoMoreStepsAlert()
                zielPosition = noMoreStepsAlert!.getPositionForAction(action: action)
            case .FinishGameAlert:
                createFinishGameAlert(status: .OK)
                zielPosition = finishGameAlert!.getPositionForAction(action: action)
            }
            let point = zielPosition! - lastTouchedPosition
            let distance = point.length()
            let counter = Int(distance / 10)
            let xAdder = point.x / CGFloat(counter)
            let yAdder = point.y / CGFloat(counter)
            fingerActions.append(SKAction.wait(forDuration: 1.0))
            for index in 0..<counter {
                fingerActions.append(SKAction.move(to: CGPoint(x: lastTouchedPosition.x + CGFloat(index) * xAdder,
                                                               y: lastTouchedPosition.y + CGFloat(index) * yAdder) - fingerPositionModifier, duration: duration))
                fingerActions.append(SKAction.wait(forDuration: 0.05))
            }
            let beganAction = SKAction.run({
                switch alertType {
                case .ContinueGameEasyAlert: self.congratulationsAlert!.myTouchesBegan(touchLocation: zielPosition!, absolutLocation: true)
                case .ContinueGameMediumAlert: self.congratulationsAlert!.myTouchesBegan(touchLocation: zielPosition!, absolutLocation: true)
                case .FinishGameEasyAlert: self.congratulationsAlert!.myTouchesBegan(touchLocation: zielPosition!, absolutLocation: true)
                case .FinishGameMediumAlert: self.congratulationsAlert!.myTouchesBegan(touchLocation: zielPosition!, absolutLocation: true)
                case .OKFixLettersSolvedAlert: self.congratulationsAlert!.myTouchesBegan(touchLocation: zielPosition!, absolutLocation: true)
                case .OKMandatorySolvedAlert: self.congratulationsAlert!.myTouchesBegan(touchLocation: zielPosition!, absolutLocation: true)
                case .NoMoreStepsAlert: self.noMoreStepsAlert!.myTouchesBegan(touchLocation: zielPosition!, absolutLocation: true)
                case .FinishGameAlert: self.finishGameAlert!.myTouchesBegan(touchLocation: zielPosition!, absolutLocation: true)
                }
            })
            let endedAction = SKAction.run({
                switch alertType {
                case .ContinueGameEasyAlert: self.congratulationsAlert!.myTouchesEnded(touchLocation: zielPosition!, absolutLocation: true)
                case .ContinueGameMediumAlert: self.congratulationsAlert!.myTouchesEnded(touchLocation: zielPosition!, absolutLocation: true)
                case .FinishGameEasyAlert: self.congratulationsAlert!.myTouchesEnded(touchLocation: zielPosition!, absolutLocation: true)
                case .FinishGameMediumAlert: self.congratulationsAlert!.myTouchesEnded(touchLocation: zielPosition!, absolutLocation: true)
                case .OKFixLettersSolvedAlert: self.congratulationsAlert!.myTouchesEnded(touchLocation: zielPosition!, absolutLocation: true)
                case .OKMandatorySolvedAlert: self.congratulationsAlert!.myTouchesEnded(touchLocation: zielPosition!, absolutLocation: true)
                case .NoMoreStepsAlert:
                    self.noMoreStepsAlert!.myTouchesEnded(touchLocation: zielPosition!, absolutLocation: true)
                case .FinishGameAlert:
                    self.finishGameAlert!.myTouchesEnded(touchLocation: zielPosition!, absolutLocation: true)
                    self.gameFinished = true

                }
            })
            fingerActions.append(beganAction)
            fingerActions.append(SKAction.wait(forDuration: 0.5))
            fingerActions.append(endedAction)
            if alertType == .NoMoreStepsAlert && action == #selector(self.nextRoundTapped) {
                fingerActions.append(SKAction.wait(forDuration: 8.0))
            } else {
                fingerActions.append(SKAction.wait(forDuration: 0.5))
            }
        }
//----------------------------------------------------------------------------
        var slow = true
        var lastActionWasMarkingWord = false
//        let firstAction = SKAction.run({
//            self.undoButton!.isEnabled = false
//            self.undoButton!.alpha = 0.2
//        })
//        fingerActions.append(firstAction)
        setUndoButton(enabled: false)
        for (index, record) in GV.helpInfoRecords!.enumerated() {
            let countMoves = record.movedInfo.components(separatedBy: "°").count
            var duration: Double = (slow ? 0.25 : 0.05) / Double(countMoves)
            func getAbsPosition(relPosX: CGFloat, relPosY: CGFloat)->CGPoint {
                return gridStartPosition + CGPoint(x: relPosX, y: relPosY) * gridSize
            }
            func callTouchAction(info: String, type: ActionType, index: Int = 0, letters: String = "") {
                let data = MovedInfoData(from: info)
                let onGameArray = data.onGameArray
                let touchPosition = getAbsPosition(relPosX: data.relPosX, relPosY: data.relPosY)
                var touchedNodes = analyzeNodes(touchLocation: touchPosition)
                if onGameArray {
                    touchedNodes.col = data.col
                    touchedNodes.row = data.row
                    touchedNodes.GRow = data.GRow
                }
                addTouchAction(type: type, touchPosition: touchPosition, touchedNodes: touchedNodes, letters: letters, duration: duration, counter: record.counter, index: index)
            }
//            if record.counter == 9 {
//                print("hier")
//            }

            switch record.typeOfTouch {
//                FromBottom = 0, FromGameArray, Undo, AllWords, Continue, Finish
            case TypeOfTouch.FromBottom.rawValue, TypeOfTouch.FromGameArray.rawValue:
                startFromGamearray = true
                if slow {
                    lastActionWasMarkingWord = record.letters.endsWith(LettersColor.Green.rawValue) ? true : lastActionWasMarkingWord
                    slow = lastActionWasMarkingWord ? false : slow
                }
                if record.beganInfo != "" {
                   if record.typeOfTouch == TypeOfTouch.FromBottom.rawValue {
                        let shapeIndex = Int(record.beganInfo)
                        startShapeIndex = shapeIndex!
                        let touchPosition = pieceArray[shapeIndex!].position
                        let touchedNodes = analyzeNodes(touchLocation: touchPosition)
                        addTouchAction(type: .TouchesBegan, touchPosition: touchPosition, touchedNodes: touchedNodes,duration: Double(duration), counter: record.counter)
                    } else {
                        startShapeIndex = NoValue
                    callTouchAction(info: record.beganInfo, type: .TouchesBegan, letters: record.letters)
                    }
                    let moves = record.movedInfo.components(separatedBy: "°")
                    var countMoves = 0
                    for (index, move) in moves.enumerated() {
                        if move.length > 0 {
                            callTouchAction(info: move, type: .TouchesMoved, index: index)
                            countMoves += 1
                        }
                    }
                    if countMoves == 0 && record.typeOfTouch == TypeOfTouch.FromBottom.rawValue {
                        let touchPosition = pieceArray[startShapeIndex].position
                        let touchedNodes = analyzeNodes(touchLocation: touchPosition)
                        addTouchAction(type: .TouchesEnded, touchPosition: touchPosition, touchedNodes: touchedNodes, letters: record.letters, duration: Double(duration), counter: record.counter)
                    } else {
                        callTouchAction(info: record.endedInfo, type: .TouchesEnded, letters: record.letters)
                    }
                }
            case TypeOfTouch.UndoButton.rawValue:
                addButtonTouchedAction(button: undoButton!)
            case TypeOfTouch.ShowMyWordsButton.rawValue:
                addButtonTouchedAction(button: allWordsButton!)
            case TypeOfTouch.FinishButton.rawValue:
                addButtonTouchedAction(button: finishButton!)
            case TypeOfTouch.ContinueGameEasy.rawValue:
                addAlertTouched(alertType: .ContinueGameEasyAlert, action: #selector(self.continueEasyAction))
            case TypeOfTouch.ContinueGameMedium.rawValue:
                addAlertTouched(alertType: .ContinueGameMediumAlert, action: #selector(self.continueMediumAction))
            case TypeOfTouch.ContinueGameEasy.rawValue:
                addAlertTouched(alertType: .ContinueGameEasyAlert, action: #selector(self.continueEasyAction))
            case TypeOfTouch.ContinueGameMedium.rawValue:
                addAlertTouched(alertType: .ContinueGameMediumAlert, action: #selector(self.continueMediumAction))
            case TypeOfTouch.FinishGameEasy.rawValue:
                 addAlertTouched(alertType: .FinishGameEasyAlert, action: #selector(self.finishEasyAction))
            case TypeOfTouch.FinishGameMedium.rawValue:
                addAlertTouched(alertType: .FinishGameMediumAlert, action: #selector(self.finishMediumAction))
            case TypeOfTouch.OKFixLettersSolved.rawValue:
                addAlertTouched(alertType: .OKFixLettersSolvedAlert, action: #selector(self.fixLettersOKAction))
            case TypeOfTouch.OKMandatorySolved.rawValue:
                addAlertTouched(alertType: .OKMandatorySolvedAlert, action: #selector(self.mandatoryOKAction))
            case TypeOfTouch.NoMoreStepsBack.rawValue:
                addAlertTouched(alertType: .NoMoreStepsAlert, action: #selector(self.startUndoTapped))
            case TypeOfTouch.NoMoreStepsNext.rawValue:
                addAlertTouched(alertType: .NoMoreStepsAlert, action: #selector(self.nextRoundTapped))
            case TypeOfTouch.NoMoreStepsCont.rawValue:
                addAlertTouched(alertType: .NoMoreStepsAlert, action: #selector(self.noActionTapped))
            case TypeOfTouch.FinishGame.rawValue:
                addAlertTouched(alertType: .FinishGameAlert, action: #selector(self.finishButtonTapped2))
            default:
                continue
            }
            if generateHelpInfo && index == stopIndex {
                let deleteAction = SKAction.run({
                    let recordsToDelete = self.realmHelpInfo!.objects(HelpInfo.self).filter("language = %@ and counter > %d", GV.actLanguage, stopIndex)
                    if recordsToDelete.count > 0 {
                        try! self.realmHelpInfo!.safeWrite() {
                            self.realmHelpInfo!.delete(recordsToDelete)
                        }
                    }
                })
                fingerActions.append(deleteAction)
                break
            }
        }
        let removeAction = SKAction.run ({
            GV.generateHelpInfo = generateHelpInfo
        })
        fingerActions.append(removeAction)
        if !generateHelpInfo {
            let lastWaitAction = SKAction.wait(forDuration: 3)
            fingerActions.append(lastWaitAction)
            let lastAction = SKAction.run({
                if self.gameFinished {
                    try! realm.safeWrite() {
                        GV.basicDataRecord.startAnimationShown = true
                    }
                    let title = GV.language.getText(.tcDemoFinishedTitle)
                    let message = GV.language.getText(.tcDemoFinishedMessage)
                    let newGameText = GV.language.getText(.tcDemoFinishedStartNewGame)
                    let menuText = GV.language.getText(.tcDemoFinishedGoToMenu)
                    let myAlert = MyAlertController(title: title, message: message, target: self, type: .Green)
                    myAlert.addAction(text: newGameText, action: #selector(self.startNewGame))
                    myAlert.addAction(text: menuText, action: #selector(self.goBackTapped))
                    myAlert.presentAlert()
                    myAlert.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
                    fingerSprite.removeFromParent()
                    self.bgSprite!.addChild(myAlert)
                }
            })
            fingerActions.append(lastAction)
        } else {
            let lastAction = SKAction.run({
                fingerSprite.removeFromParent()
                self.hideButtons(hide: false)
                self.setUndoButton(enabled: true)
            })
            fingerActions.append(lastAction)
        }
        let sequence = SKAction.sequence(fingerActions)
        fingerSprite.run(SKAction.sequence([sequence]))
        bgSprite!.addChild(fingerSprite)
    }
    
    var gameFinished = false
    
    private func hasPreviousRecords(playingRecord: GameDataModel)->Bool {
        return realm.objects(GameDataModel.self).filter("(gameStatus = %d or gameStatus = %d) and gameNumber < %d and language = %@",
            GV.GameStatusPlaying, GV.GameStatusContinued, playingRecord.gameNumber, GV.actLanguage).count > 0
    }
    
    private func hasNextRecords(playingRecord: GameDataModel)->Bool {
        return realm.objects(GameDataModel.self).filter("(gameStatus = %d or gameStatus = %d) and gameNumber > %d and language = %@",
            GV.GameStatusPlaying, GV.GameStatusContinued, playingRecord.gameNumber, GV.actLanguage).count > 0
    }
    
    @objc private func countTime(timerX: Timer) {
        let state = UIApplication.shared.applicationState
        if state == .background {
//            print("App in Background")
        } else if state == .active && timerIsCounting {
            timeForGame.incrementTime()
        }
        let texts = headerLabel.text!.components(separatedBy:":")
        var newText = ""
        for (index, text) in texts.enumerated() {
            if index < 3 {
                newText += text + ":"
            } else {
                newText += " \(timeForGame.time.HourMinSec)"
            }
        }
        headerLabel.text = newText
        
        
//        timeLabel.text = GV.language.getText(.tcTime, values: timeForGame.time.HourMinSec)
        try! realm.safeWrite() {
            GV.playingRecord.time = timeForGame.toString()
        }
//        if myTimer!.update(time: timeForGame) {
//            timer!.invalidate()
//            timer = nil
//            showGameFinished(status: .TimeOut)
//        }
    }
    
    var realmHelpInfo: Realm?
    
    private func initiateHelpModel() {
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let helpInfoURL = documentsURL.appendingPathComponent("HelpInfo.realm")
        let config1 = Realm.Configuration(
            fileURL: helpInfoURL,
            shouldCompactOnLaunch: { totalBytes, usedBytes in
                // totalBytes refers to the size of the file on disk in bytes (data + free space)
                // usedBytes refers to the number of bytes used by data in the file
                
                // Compact if the file is over 100MB in size and less than 50% 'used'
                let oneMB = 10 * 1024 * 1024
                return (totalBytes > oneMB) && (Double(usedBytes) / Double(totalBytes)) < 0.8
        },
            objectTypes: [HelpInfo.self])
        do {
            // Realm is compacted on the first open if the configuration block conditions were met.
            _ = try Realm(configuration: config1)
        } catch {
            print("error")
            // handle error compacting or opening Realm
        }
        let helpInfoConfig = Realm.Configuration(
            fileURL: helpInfoURL,
            schemaVersion: 0, // new item words
            // Set the block which will be called automatically when opening a Realm with
            // a schema version lower than the one set above
            migrationBlock: { migration, oldSchemaVersion in
                switch oldSchemaVersion {
//                case 0...3:
//                    migration.deleteData(forType: HelpModel.className())
//
                default: migration.enumerateObjects(ofType: BasicDataModel.className())
                    { oldObject, newObject in
                    }
                }
            },
            objectTypes: [HelpInfo.self])
        
        realmHelpInfo = try! Realm(configuration: helpInfoConfig)

    }
    
    private func resetHelpInfo() {
        let difficulty = GV.basicDataRecord.difficulty
        let records = realmHelpInfo!.objects(HelpInfo.self).filter("language = %@ and difficulty = %d", GV.actLanguage, difficulty)
        if records.count > 0 {
            try! realmHelpInfo!.safeWrite() {
                realmHelpInfo!.delete(records)
            }
        }
    }
    var lastCol = NoValue
    var lastRow = NoValue
    var countOfMoves = 0
    var helpInfo = HelpInfo()
    
    let UndoButtonHelpInfo = "UndoButton"
    let ShowMyWordsButtonHelpInfo = "ShowMyWordsButton"
    let FinishButtonHelpInfo = "FinishButton"
    let FinishGameHelpInfo = "FinishGame"
    let ContinueGameEasyHelpInfo = "ContinueGameEasy"
    let ContinueGameMediumHelpInfo = "ContinueGameMedium"
    let FinishGameEasyHelpInfo = "FinishGameEasy"
    let FinishGameMediumHelpInfo = "FinishGameMedium"
    let OKMandatorySolvedHelpInfo = "OKMandatorySolved"
    let OKFixLettersEasyHelpInfo = "OKFixLettersEasy"
    let NoMoreStepsBackHelpInfo = "NoMoreStepsBack"
    let NoMoreStepsNextHelpInfo = "NoMoreStepsNext"
    let NoMoreStepsContHelpInfo = "NoMoreStepsCont"


    
    private func saveHelpInfo(action: TypeOfTouch) {
        if !GV.generateHelpInfo {
            return
        }
        let records = realmHelpInfo!.objects(HelpInfo.self).filter("language = %@ and difficulty = %d", GV.actLanguage, GV.basicDataRecord.difficulty).sorted(byKeyPath: "counter")
        let counter = records.count > 0 ? records.last!.counter + 1 : 1
        let sDifficulty = String(GV.basicDataRecord.difficulty)
        let helpInfo = HelpInfo()
        helpInfo.difficulty = GV.basicDataRecord.difficulty
        helpInfo.typeOfTouch = action.rawValue
        helpInfo.combinedKey = GV.actLanguage + "°" + String(counter) + "°" + sDifficulty
        helpInfo.language = GV.actLanguage
        helpInfo.counter = counter
        switch action {
        case .UndoButton: helpInfo.letters = UndoButtonHelpInfo
        case .ShowMyWordsButton: helpInfo.letters = ShowMyWordsButtonHelpInfo
        case .FinishButton: helpInfo.letters = FinishButtonHelpInfo
        case .ContinueGameEasy: helpInfo.letters = ContinueGameEasyHelpInfo
        case .ContinueGameMedium: helpInfo.letters = ContinueGameMediumHelpInfo
        case .FinishGameEasy: helpInfo.letters = FinishGameEasyHelpInfo
        case .FinishGameMedium: helpInfo.letters = FinishGameMediumHelpInfo
        case .OKFixLettersSolved: helpInfo.letters = OKFixLettersEasyHelpInfo
        case .OKMandatorySolved: helpInfo.letters = OKMandatorySolvedHelpInfo
        case .NoMoreStepsBack: helpInfo.letters = NoMoreStepsBackHelpInfo
        case .NoMoreStepsNext: helpInfo.letters = NoMoreStepsNextHelpInfo
        case .NoMoreStepsCont: helpInfo.letters = NoMoreStepsContHelpInfo
        case .FinishGame: helpInfo.letters = FinishGameHelpInfo
        default: break
        }
        try! realmHelpInfo!.safeWrite() {
            realmHelpInfo!.add(helpInfo)
        }
    }
    private func saveArrayOfPieces() {
//        tilesForGame.removeAll()
        let piecesToPlay = GV.playingRecord.pieces.components(separatedBy: "°")
        for index in tilesForGame.count..<piecesToPlay.count {
            if index >= tilesForGame.count {
                let piece = piecesToPlay[index]
                if piece.count > 0 {
                    let tile = WTPiece(from: piece, parent: self, blockSize: blockSize, arrayIndex: index)
                    tilesForGame.append(tile)
                    tilesForGame.last!.setArrayIndex(index: index)
                }
            }
        }
   }
    
    private func generateArrayOfWordPieces(new: Bool) {
        if new || GV.playingRecord.pieces.count == 0 {
            try! realm.safeWrite() {
            //                GV.playingRecord.randomCounts = 0
                GV.playingRecord.words = ""
            //                random = MyRandom()
            }
            // ----------------------
//            _ = generateArrayOfWordPieces(first: true)
//            for _ in 0...9 {
//                _ = generateArrayOfWordPieces(first: false)
//            }
//            try! realm.safeWrite() {
//                GV.playingRecord.words = ""
//            }
            let pieces = generateArrayOfWordPieces(first: true)
            try! realm.safeWrite() {
                GV.playingRecord.pieces = pieces
            }
        }
        saveArrayOfPieces()
    }
    
    private func getNextPiece(/*horizontalPosition: Int*/)->WTPiece {
//        blockSize = self.frame.size.width * (GV.onIpad ? 0.70 : 0.90) / CGFloat(12)
        var tileForGame: WTPiece
        repeat {
            if indexOfTilesForGame == tilesForGame.count {
                let pieces = generateArrayOfWordPieces(first:false)
                 try! realm.safeWrite() {
                    GV.playingRecord.pieces = pieces
                }
                saveArrayOfPieces()
            }
            
            tileForGame = tilesForGame[indexOfTilesForGame]
            indexOfTilesForGame += 1
        } while tileForGame.isOnGameboard
//        indexOfTilesForGame = indexOfTilesForGame >= tilesForGame.count ? 0 : indexOfTilesForGame
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
            self.hideButtons(hide: false)
        }
    }
    
    var firstTouchedCol = 0
    var firstTouchedRow = 0
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if showHelp && !GV.generateHelpInfo {
            return
        }
        startShapeIndex = -1
        let touchLocation = touches.first!.location(in: self)
        let touchedNodes = analyzeNodes(touchLocation: touchLocation)
        myTouchesBegan(location: touchLocation, touchedNodes: touchedNodes)
    }
    var relativPosition = CGPoint(x: 0, y: 0)
    
    private func myTouchesBegan(location: CGPoint, touchedNodes: TouchedNodes) {
        self.scene?.alpha = 1.0
        if wtSceneDelegate == nil {
            return
        }
        movedFromBottom = false
        inChoosingOwnWord = false
//        ownWordsScrolling = false
//        let firstTouch = touches.first
        firstTouchLocation = location//firstTouch!.location(in: self)
//      ----------------------------------
        if GV.generateHelpInfo {
            relativPosition = (firstTouchLocation - CGPoint(x: wtGameboard!.grid!.frame.minX, y: wtGameboard!.grid!.frame.minY)) / wtGameboard!.grid!.frame.width
            helpInfo = HelpInfo()
            var counter = 0
            let info = realmHelpInfo!.objects(HelpInfo.self).filter("language = %@ and difficulty = %d", GV.actLanguage, GV.basicDataRecord.difficulty).sorted(byKeyPath: "counter", ascending: true)
            if info.count > 0 {
                counter = info.last!.counter + 1
            }
//            let counter =  realmHelpInfo!.objects(HelpInfo.self).filter("language = %@", GV.actLanguage).sorted(byKeyPath: "counter", ascending: true).last!.counter + 1
            
            let sDifficulty = String(GV.basicDataRecord.difficulty)
            helpInfo.difficulty = GV.basicDataRecord.difficulty
            helpInfo.combinedKey = GV.actLanguage + "°" + String(counter) + "°" + sDifficulty
            helpInfo.language = GV.actLanguage
            helpInfo.counter = counter
        }
//      ----------------------------------
        #if SHOWFINGER
        let texture = SKTexture(imageNamed: "finger")
        finger = SKSpriteNode(texture: texture)
        let sizeDivider = GV.onIpad ? CGFloat(6) : CGFloat(12)
        finger?.size = CGSize(width: (finger?.size.width)! / sizeDivider, height: (finger?.size.height)! / sizeDivider)
        finger?.position = firstTouchLocation + CGPoint(x: 0, y: fingerAdder)
        bgSprite!.addChild(finger!)
        #endif
        stopShowingTableIfNeeded()
        
        if inDefiningSearchingWord {
            //            let origLocation = CGPoint(x: touchLocation.x, y: touchLocation.y + wtGameboardMovedBy)
            //            touchedNodes = analyzeNodes(touchLocation: origLocation, calledFrom: .stop)
            if (touchedNodes.col >= 0 && touchedNodes.col < 10) && (touchedNodes.GRow >= 0 && touchedNodes.GRow < 10) {
                firstTouchedCol = touchedNodes.col
                firstTouchedRow = touchedNodes.GRow
                var choosedLetter = GV.gameArray[touchedNodes.col][touchedNodes.GRow].letter
                choosedLetter = choosedLetter == " " ? "" : choosedLetter
                addLetterToSearchingWord(letter: choosedLetter)           }
        } else if touchedNodes.shapeIndex > NoValue {
            startShapeIndex = touchedNodes.shapeIndex
            pieceArray[touchedNodes.shapeIndex].zPosition = 10
            wtGameboard!.clear()
            if GV.generateHelpInfo {
                helpInfo.typeOfTouch = TypeOfTouch.FromBottom.rawValue
                helpInfo.beganInfo = "\(touchedNodes.shapeIndex)"
                var letters = ""
                for letter in pieceArray[touchedNodes.shapeIndex].letters {
                    letters += letter
                }
                helpInfo.letters = letters
            }
        } else if touchedNodes.GCol.between(min: 0, max: GV.sizeOfGrid - 1) && touchedNodes.GRow.between(min:0, max: GV.sizeOfGrid - 1){
            inChoosingOwnWord = true
            wtGameboard?.startChooseOwnWord(col: touchedNodes.GCol, row: touchedNodes.GRow)
            if GV.generateHelpInfo {
                helpInfo.typeOfTouch = TypeOfTouch.FromGameArray.rawValue
                let beganInfoData = MovedInfoData(onGameArray: true, relPosX: relativPosition.x, relPosY: relativPosition.y, col: touchedNodes.GCol, row: touchedNodes.GRow, GRow: touchedNodes.GRow).toString()
                helpInfo.beganInfo = "\(beganInfoData)"
            }
        }

    }
    
    public func setMovingSprite() {
        movingSprite = true
    }
    
    struct MovedInfoData {
        var onGameArray = false
        var relPosX: CGFloat = 0
        var relPosY: CGFloat = 0
        var col = NoValue
        var row = NoValue
        var GRow = NoValue
        init(onGameArray: Bool = false, relPosX: CGFloat = 0, relPosY: CGFloat = 0, col: Int = NoValue, row: Int = NoValue, GRow: Int = NoValue) {
            self.onGameArray = onGameArray
            self.relPosX = relPosX
            self.relPosY = relPosY
            self.col = col
            self.row = row
            self.GRow = GRow
        }
        init(from: String) {
            let values = from.components(separatedBy: "/")
            self.onGameArray = Int(values[0]) == 0 ? false : true
            self.relPosX = CGFloat(Float(values[1])!)
            self.relPosY = CGFloat(Float(values[2])!)
            self.col = Int(values[3])!
            self.row = Int(values[4])!
            self.GRow = Int(values[5])!
        }
        func toString()->String {
            return "\(onGameArray ? "1" : "0")/\(relPosX.nDecimals(n: 3))/\(relPosY.nDecimals(n: 3))/\(col)/\(row)/\(GRow)"
        }
    }
    
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if showHelp && !GV.generateHelpInfo {
            return
        }
        let touchLocation = touches.first!.location(in: self)
        let touchedNodes = analyzeNodes(touchLocation: touchLocation)
        myTouchesMoved(location: touchLocation, touchedNodes: touchedNodes)
    }
    
    private func myTouchesMoved(location: CGPoint, touchedNodes: TouchedNodes) {
        if wtSceneDelegate == nil {
            return
        }

        let touchLocation = location //firstTouch!.location(in: self)
        if GV.generateHelpInfo {
            relativPosition = (touchLocation - CGPoint(x: wtGameboard!.grid!.frame.minX, y: wtGameboard!.grid!.frame.minY)) / wtGameboard!.grid!.frame.width
        }

        #if SHOWFINGER
        finger?.position = touchLocation + CGPoint(x: 0, y: fingerAdder)
        #endif
//        let nodes = self.nodes(at: touchLocation)
//        let nodes1 = self.nodes(at: CGPoint(x: touchLocation.x, y: touchLocation.y + blockSize * 0.11))
//        let touchedNodes = analyzeNodes(touchLocation: touchLocation, calledFrom: .Move)
        var onGameArray = true
        if inDefiningSearchingWord {
            //            let origLocation = CGPoint(x: touchLocation.x, y: touchLocation.y + wtGameboardMovedBy)
            //            touchedNodes = analyzeNodes(touchLocation: origLocation, calledFrom: .stop)
            if (touchedNodes.col >= 0 && touchedNodes.col < 10) && (touchedNodes.GRow >= 0 && touchedNodes.GRow < 10) {
                if firstTouchedCol != touchedNodes.col || firstTouchedRow != touchedNodes.GRow {
                    var choosedLetter = GV.gameArray[touchedNodes.col][touchedNodes.GRow].letter
                    choosedLetter = choosedLetter == " " ? "" : choosedLetter
                    addLetterToSearchingWord(letter: choosedLetter)
                    firstTouchedCol = touchedNodes.col
                    firstTouchedRow = touchedNodes.GRow
                }
            }
        } else if movedFromBottom {
            // only by from Bottom
            let sprite = pieceArray[movedIndex]
            sprite.position = touchLocation + CGPoint(x: 0, y: blockSize * WSGameboardSizeMultiplier)
            sprite.alpha = 0.0
            if wtGameboard!.moveSpriteOnGameboard(col: touchedNodes.col, row: touchedNodes.row, GRow: touchedNodes.GRow) {  // true says moving finished
                if touchedNodes.row == GV.sizeOfGrid { // when at bottom
                    sprite.alpha = 1.0
                    onGameArray = false
                }
            }
            if GV.generateHelpInfo {
                let movedInfoData = MovedInfoData(onGameArray: onGameArray, relPosX: relativPosition.x, relPosY: relativPosition.y, col: touchedNodes.col, row: touchedNodes.row, GRow: touchedNodes.GRow).toString() + "°"
                helpInfo.movedInfo += movedInfoData
            }

        } else if inChoosingOwnWord {
            if movingSprite {
//                if wtGameboard!.moveSpriteOnGameboard(col: touchedNodes.col, row: touchedNodes.row + 2, GRow: touchedNodes.GRow) {
//                    _ = wtGameboard!.moveSpriteOnGameboard(col: touchedNodes.col, row: touchedNodes.row + 1, GRow: touchedNodes.GRow)
//                }
            } else if touchedNodes.GCol >= 0 && touchedNodes.GCol < GV.sizeOfGrid && touchedNodes.GRow >= 0 && touchedNodes.GRow < GV.sizeOfGrid {
//                myTimer!.startTimeMessing()
                movingSprite = (wtGameboard?.moveChooseOwnWord(col: touchedNodes.GCol, row: touchedNodes.GRow))!
//                myTimer!.showLastTime()
            }
            if movingSprite {
                if wtGameboard!.moveSpriteOnGameboard(col: touchedNodes.col, row: touchedNodes.row + 2, GRow: touchedNodes.GRow) {
//                    _ = wtGameboard!.moveSpriteOnGameboard(col: touchedNodes.col, row: touchedNodes.row + 1, GRow: touchedNodes.GRow)
                }
                onGameArray = true
            }
            if GV.generateHelpInfo {
                let movedInfoData = MovedInfoData(onGameArray: onGameArray, relPosX: relativPosition.x, relPosY: relativPosition.y, col: touchedNodes.col, row: touchedNodes.row, GRow: touchedNodes.GRow).toString() + "°"
                helpInfo.movedInfo += movedInfoData
            }
        } else  {
            if touchedNodes.shapeIndex >= 0 {
                pieceArray[touchedNodes.shapeIndex].position = touchLocation
            }
            let distanceMultipler = CGFloat(0.1)
            let yDistance = abs((touchLocation - firstTouchLocation).y)
            if yDistance > (blockSize * distanceMultipler) && touchedNodes.row >= 0 && touchedNodes.row < GV.sizeOfGrid {
                if touchedNodes.shapeIndex >= 0 {
                    movedFromBottom = wtGameboard!.startShowingSpriteOnGameboard(shape: pieceArray[touchedNodes.shapeIndex], col: touchedNodes.col, row: touchedNodes.row) //, shapePos: touchedNodes.shapeIndex)
                    movedIndex = touchedNodes.shapeIndex
                }
            } else {
                onGameArray = false
            }
            if GV.generateHelpInfo {
                let movedInfoData = MovedInfoData(onGameArray: onGameArray, relPosX: relativPosition.x, relPosY: relativPosition.y, col: touchedNodes.col, row: touchedNodes.row, GRow: touchedNodes.GRow).toString() + "°"
                helpInfo.movedInfo += movedInfoData
            }
        }
    
    }
    
    enum CalledFrom: Int {
        case Start = 0, Move, Stop
    }
    
    var enabled = true
    var gameboardEnabled = true

    private func analyzeNodes(touchLocation: CGPoint)->TouchedNodes {
        let nodes = self.nodes(at: touchLocation)
        var touchedNodes = TouchedNodes()
        for node in nodes {
            guard let name = node.name else {
                continue
            }
            if enabled || gameboardEnabled {
                if name.begins(with: "GBD") {
                    touchedNodes.GCol = Int(name.subString(at: 4, length:1))!
                    touchedNodes.GRow = Int(name.subString(at: 6, length:1))!
                } else if let number = Int(name.subString(at: 3, length: name.count - 3)) {
                    if enabled {
                        let nameStartedWith = name.subString(at: 0, length: 3)
                        if startShapeIndex >= 0 {
                            touchedNodes.shapeIndex = startShapeIndex
                        }
                        if nameStartedWith == "Col" {
                            touchedNodes.col = number
                        } else if nameStartedWith == "Row" {
                            touchedNodes.row = number
                        } else if nameStartedWith == "Pos" {
                            if startShapeIndex == -1 {
                                touchedNodes.shapeIndex = number
                            } else {
                                touchedNodes.shapeIndex = startShapeIndex
                            }
                        }
                    }
                }
            }
        }
        return touchedNodes
    }
    let answer1Name = "Answer1"
    let answer2Name = "Answer2"
    let MyQuestionName = "MyQuestion"

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if showHelp && !GV.generateHelpInfo {
            return
        }
        let touchLocation = touches.first!.location(in: self)
        let touchedNodes = analyzeNodes(touchLocation: touchLocation)
        _ = myTouchesEnded(location: touchLocation, touchedNodes: touchedNodes)
    }
    
    
    private func myTouchesEnded(location: CGPoint, touchedNodes: TouchedNodes, checkLetters: String = "")->Bool {
        if wtSceneDelegate == nil {
            return false
        }
        var returnBool = false
        var lettersForCheck = ""
        if GV.generateHelpInfo {
            relativPosition = (location - CGPoint(x: wtGameboard!.grid!.frame.minX, y: wtGameboard!.grid!.frame.minY)) / wtGameboard!.grid!.frame.width
        }
        let touchLocation = location //firstTouch!.location(in: self)
        #if SHOWFINGER
        finger?.removeFromParent()
        #endif
//        let nodes = self.nodes(at: touchLocation)
        let lastIndex = pieceArray.count - 1
//        let nodes1 = self.nodes(at: CGPoint(x: touchLocation.x, y: touchLocation.y + blockSize * 0.11))
        if inDefiningSearchingWord {
//            let origLocation = CGPoint(x: touchLocation.x, y: touchLocation.y + wtGameboardMovedBy)
//            touchedNodes = analyzeNodes(touchLocation: origLocation, calledFrom: .stop)
            if (touchedNodes.col >= 0 && touchedNodes.col < 10) && (touchedNodes.GRow >= 0 && touchedNodes.GRow < 10) {
                if firstTouchedCol != touchedNodes.col || firstTouchedRow != touchedNodes.GRow {
                    var choosedLetter = GV.gameArray[touchedNodes.col][touchedNodes.GRow].letter
                    choosedLetter = choosedLetter == " " ? "" : choosedLetter
                    addLetterToSearchingWord(letter: choosedLetter)
                }
            }
            firstTouchedCol = -1
            firstTouchedRow = -1
        } else if inChoosingOwnWord {
            var letters = ""
            var word: FoundedWord?
            var saveRecord = false
            if movingSprite {
                movingSprite = false
                let row = touchedNodes.row + 2 == 10 ? 9 : touchedNodes.row + 2
                (_, letters) = wtGameboard!.stopShowingSpriteOnGameboard(col: touchedNodes.col, row: row, fromBottom: false)
                if letters != "" {
                    lettersForCheck = letters + "/" + LettersColor.Red.rawValue
                    saveRecord = true
                }
            } else {
                word = wtGameboard!.endChooseOwnWord(col: touchedNodes.GCol, row: touchedNodes.GRow)
                if word != nil {
                    let activityItem = ActivityItem(type: .Choosing, choosedWord: word!)
                    activityRoundItem[activityRoundItem.count - 1].activityItems.append(activityItem)
                    lettersForCheck = word!.word + "/" + LettersColor.Green.rawValue
                    returnBool = checkLetters == "" || checkLetters == lettersForCheck
                    saveActualState()
                    saveToRealmCloud()
                    saveRecord = true
                } else {
                    
                }
            }
            returnBool = checkLetters == "" || checkLetters == lettersForCheck
            if GV.generateHelpInfo {
                let endedInfoData = MovedInfoData(onGameArray: true, relPosX: relativPosition.x, relPosY: relativPosition.y, col: touchedNodes.col, row: touchedNodes.row, GRow: touchedNodes.GRow).toString()
                helpInfo.endedInfo = endedInfoData
                if helpInfo.movedInfo.length > 0 {
                    helpInfo.movedInfo.removeLast()
                }
                helpInfo.letters = lettersForCheck
                if saveRecord {
                    try! realmHelpInfo!.safeWrite() {
                        realmHelpInfo!.add(helpInfo)
                    }
                }
            }

        } else if movedFromBottom {
            for piece in pieceArray {
                piece.zPosition = 1
            }
            let (fixed, letters) = wtGameboard!.stopShowingSpriteOnGameboard(col: touchedNodes.col, row: touchedNodes.row, fromBottom: true)
            if fixed {
 //                pieceArray[movedIndex].zPosition = 1
                pieceArray[movedIndex].setPieceFromPosition(index: movedIndex)
                let activityItem = ActivityItem(type: .FromBottom, fromBottomIndex: pieceArray[movedIndex].getArrayIndex())
                if activityRoundItem.count == 0 {
                    activityRoundItem.append(ActivityRound())
                }
                if activityRoundItem.last!.activityItems.count == 0 {
                    activityRoundItem[activityRoundItem.count - 1].activityItems = [ActivityItem]()
                }
                activityRoundItem[activityRoundItem.count - 1].activityItems.append(activityItem)
//                activityItems.append(activityItem)
//                setUndoButton(enabled: true)
//                undoSprite.alpha = 1.0
//                let fixedName = "Pos\(movedIndex)"
//                removeNodesWith(name: fixedName)
                for index in 0...lastIndex {
                    removeNodesWith(name: "Pos\(String(index))")
                }
                if movedIndex < lastIndex {
                    for index in movedIndex..<lastIndex {
                        pieceArray[index] = pieceArray[index + 1]
                        pieceArray[index].name = "Pos\(String(index))"
                        pieceArray[index].position = origPosition[index]
                        pieceArray[index].setPieceFromPosition(index: index)
                        origSize[index] = pieceArray[index].size
                    }
                }
                pieceArray[lastIndex] = getNextPiece(/*horizontalPosition: lastIndex*/)
                pieceArray[lastIndex].position = origPosition[lastIndex]
                pieceArray[lastIndex].name = "Pos\(lastIndex)"
                pieceArray[lastIndex].setPieceFromPosition(index: lastIndex)
                for index in 0...lastIndex {
                    bgSprite!.addChild(pieceArray[index])
                }
                lettersForCheck = letters + "/" + LettersColor.Red.rawValue
                returnBool = checkLetters == "" || checkLetters == lettersForCheck
                if GV.generateHelpInfo {
                    let movedInfoData = MovedInfoData(onGameArray: true, relPosX: relativPosition.x, relPosY: relativPosition.y, col: touchedNodes.col, row: touchedNodes.row, GRow: touchedNodes.GRow).toString()
                    helpInfo.endedInfo = movedInfoData
                    helpInfo.movedInfo.removeLast()
                    helpInfo.letters = lettersForCheck
                    if helpInfo.beganInfo == "" {
                        print("Hier at error: at fixed, counter: \(helpInfo.counter)")
                        helpInfo.beganInfo = String(movedIndex)
                    }
                    try! realmHelpInfo!.safeWrite() {
                        realmHelpInfo!.add(helpInfo)
                    }
                }
               saveActualState()
            } else {
                pieceArray[movedIndex].position = origPosition[movedIndex]
//                pieceArray[movedIndex].scale(to: origSize[movedIndex])
                pieceArray[movedIndex].alpha = 1
            }
            movedFromBottom = false
        } else if self.nodes(at: touchLocation).count > 0 {
            if touchedNodes.shapeIndex >= 0 && startShapeIndex == touchedNodes.shapeIndex {
                var letters = ""
                for letter in pieceArray[touchedNodes.shapeIndex].letters {
                    letters += letter
                }
                returnBool = letters == checkLetters
                pieceArray[touchedNodes.shapeIndex].rotate()
                pieceArray[touchedNodes.shapeIndex].position = origPosition[touchedNodes.shapeIndex]
                if GV.generateHelpInfo {
                    let endedInfoData = MovedInfoData(onGameArray: false, relPosX: relativPosition.x, relPosY: relativPosition.y, col: touchedNodes.col, row: touchedNodes.row, GRow: touchedNodes.GRow).toString()
                    helpInfo.endedInfo += endedInfoData
                    helpInfo.movedInfo = ""
                    helpInfo.letters = letters
                    try! realmHelpInfo!.safeWrite() {
                        realmHelpInfo!.add(helpInfo)
                    }
                }
            } else {
                if !goBackButton!.isEnabled {
                    self.hideButtons(hide: false)
                }
            }
        } else {
            print("hier")
        }

        startShapeIndex = -1
        _ = checkFreePlace(showAlert: true)
        checkIfGameFinished()
        return returnBool
    }
    var bestScoreSync: Results<BestScoreSync>?
    var notificationToken: NotificationToken?
    var bestScoreSubscriptionToken: NotificationToken?
    var forGameSubscriptionToken: NotificationToken?
    var bestScoreSyncSubscription: SyncSubscription<BestScoreSync>?
    var bestScoreForActualGame: Results<BestScoreForGame>?
    var bestScoreForActualGameToken: NotificationToken?
    var bestScoreForActualGameSubscription: SyncSubscription<BestScoreForGame>?
    var syncedRecordsOK = false
    var waitingForSynceRecords = false
//    var answer1Button: UIButton?
    var bestPlayers: Results<BestScoreSync>?
    var bestPlayersSubscription: SyncSubscription<BestScoreSync>?
    var bestPlayersSubscriptionToken: NotificationToken?
    var bestPlayersReady = false

    @objc private func startNextRound() {
        self.modifyHeader()
//        let roundScore = WTGameWordList.shared.getPointsForLetters()
        self.wtGameboard!.clearGreenFieldsForNextRound()
        actRound = GV.playingRecord.rounds.count + 1
        createNextRound = true
        self.enabled = true
        self.gameboardEnabled = false
        self.removeNodesWith(name: self.MyQuestionName)
        self.removeNodesWith(name: self.answer2Name)
    }

    private func getSyncedRecords() {
        if realmSync != nil {
            let gameNumber = GV.playingRecord.gameNumber % 10000 + 1
            let language = GV.language.getText(.tcAktLanguage)
            let myName = GV.basicDataRecord.myName
            let combinedPrimarySync = String(gameNumber) + language + myName
            let combinedPrimaryForGame = String(gameNumber) + language
            
            bestPlayers = realmSync!.objects(BestScoreSync.self).filter("combinedPrimary BEGINSWITH %@", combinedPrimaryForGame).sorted(byKeyPath: "score", ascending: false)
            bestPlayersSubscription = bestPlayers!.subscribe(named: "BestList:\(combinedPrimaryForGame)")
            bestPlayersSubscriptionToken = bestPlayersSubscription!.observe(\.state) { [weak self]  state in
                if state == .complete {
                    self!.bestPlayersReady = true
                    self!.modifyHeader()
                } else {
                    print("state: \(state)")
                }
            }
            
            bestScoreSync = realmSync!.objects(BestScoreSync.self).filter("combinedPrimary = %@", combinedPrimarySync)
            bestScoreSyncSubscription = bestScoreSync!.subscribe(named: "MyScoreRecord:\(combinedPrimarySync)")
            bestScoreSubscriptionToken = bestScoreSyncSubscription!.observe(\.state) { [weak self]  state in
                //                    print("in Subscription!")
                if state == .complete {
                    if self!.bestScoreSync!.count == 0 && !GV.debug {
                        try! realmSync!.write {
                            let bestScoreSyncRecord = BestScoreSync()
                            bestScoreSyncRecord.gameNumber = gameNumber
                            bestScoreSyncRecord.language = language
                            bestScoreSyncRecord.playerName = myName
                            bestScoreSyncRecord.combinedPrimary = combinedPrimarySync
                            bestScoreSyncRecord.finished = false
                            bestScoreSyncRecord.score = 0
                            bestScoreSyncRecord.usedTime = 0
                            bestScoreSyncRecord.owner = playerActivity?[0]
                            bestScoreSyncRecord.timeStamp = Date()
                            bestScoreSyncRecord.creationTime = Date()
                            realmSync!.add(bestScoreSyncRecord)
                        }
                    }
                } else {
//                    print("state: \(state)")
                }
                
            }
            bestScoreForActualGame = realmSync!.objects(BestScoreForGame.self).filter("combinedPrimary = %@", combinedPrimaryForGame)
            bestScoreForActualGameSubscription = bestScoreForActualGame!.subscribe(named: "ForGameRecord:\(combinedPrimaryForGame)")
            forGameSubscriptionToken = bestScoreForActualGameSubscription!.observe(\.state) { [weak self]  state in
                //                print("in Subscription!")
                if state == .complete {
                    if !GV.debug {
                        
                        if self!.bestScoreForActualGame!.count == 0 {
                            try! realmSync!.write{
                                let bestScoreForActualGameRecord = BestScoreForGame()
                                bestScoreForActualGameRecord.gameNumber = gameNumber
                                bestScoreForActualGameRecord.language = language
                                bestScoreForActualGameRecord.combinedPrimary = combinedPrimaryForGame
                                bestScoreForActualGameRecord.bestScore = 0
                                bestScoreForActualGameRecord.owner = playerActivity?[0]
                                realmSync!.add(bestScoreForActualGameRecord)
                                
                            }
                        } else {
                            if self!.bestScoreForActualGame![0].owner == nil {
                                try! realmSync!.write {
                                    self!.bestScoreForActualGame![0].owner = playerActivity![0]
                                }
                            }
                        }
                    }
                    self!.syncedRecordsOK = self!.bestScoreForActualGame!.count > 0
                    self!.waitingForSynceRecords = !self!.syncedRecordsOK
                    self!.bestScoreForActualGameToken = self!.bestScoreForActualGame!.observe { [weak self] (changes) in
                        switch changes {
                        case .initial:
                            // Results are now populated and can be accessed without blocking the UI
                            //                showPlayerActivityView.reloadData()
                            self!.modifyHeader()
//                            print("Initial Data displayed")
                        case .update(_, _, _, let modifications):
                            if modifications.count > 0 {
//                                print("modified: \(self!.bestScoreForActualGame![0].bestScore)")
                                self!.modifyHeader()
                            }
                        case .error(let error):
                            // An error occurred while opening the Realm file on the background worker thread
                            fatalError("\(error)")
                        }
                    }
                    
                } else {
                    print("state: \(state)")
                }
            }
        }
    }

    private func saveToRealmCloud() {
        if GV.debug || !(GV.playingRecord.gameNumber < 1000) {
            return
        }
        if GV.connectedToInternet {
            if self.syncedRecordsOK {
                try! realmSync!.safeWrite() {
                    self.bestScoreSync![0].score = GV.totalScore
                    self.bestScoreSync![0].usedTime = self.timeForGame.time
                    self.bestScoreSync![0].timeStamp = Date()
                    self.bestScoreSync![0].finished = GV.playingRecord.gameStatus == GV.GameStatusFinished ? true : false
                    if GV.totalScore > self.bestScoreForActualGame![0].bestScore {
                        self.bestScoreForActualGame![0].bestScore = GV.totalScore
                        self.bestScoreForActualGame![0].timeStamp = Date()
                        self.bestScoreForActualGame![0].owner = playerActivity?[0]
                    }
                }
                try! realm.safeWrite() {
                    GV.playingRecord.synced = true
                }
            }
        } else {
            try! realm.safeWrite() {
                GV.playingRecord.synced = false
            }
        }
    }
    
    enum CongratulationType: Int {
        case SolvedOnlyFixLetters = 0, SolvedOnlyMandatoryWords, GameFinished
    }
    
    private func checkIfGameFinished() {
        let allFixLettersUsed: Bool = wtGameboard!.checkFixLetters()
        let allMandatoryWordsSolved: Bool = WTGameWordList.shared.gameFinished()
        switch (allMandatoryWordsSolved, allFixLettersUsed) {
        case (false, false): // nothing is solved
            if goOnPlaying {
                self.saveToRealmCloud()
                finishButton!.isHidden = true
                goOnPlaying = false
                try! realm.safeWrite() {
                    GV.playingRecord.gameStatus = GV.GameStatusPlaying
                    GV.playingRecord.allFixIndicated = false
                    GV.playingRecord.allMandatoryIndicated = false
                }
            }
        case (false, true): // all Fixletters used
            if GV.basicDataRecord.difficulty != GameDifficulty.Easy.rawValue {
                goOnPlaying = false
                if !GV.playingRecord.allFixIndicated {
                    congratulations(congratulationType: .SolvedOnlyFixLetters)
                }
                try! realm.safeWrite() {
                    GV.playingRecord.allFixIndicated = true
                    GV.playingRecord.allMandatoryIndicated = false
                }
                finishButton!.isHidden = true
                saveToRealmCloud()
            }
        case (true, false): // all mandatory words solved
            goOnPlaying = false
            if !GV.playingRecord.allMandatoryIndicated {
                congratulations(congratulationType: .SolvedOnlyMandatoryWords)
            }
            try! realm.safeWrite() {
                GV.playingRecord.allFixIndicated = false
                GV.playingRecord.allMandatoryIndicated = true
            }
            finishButton!.isHidden = true
            saveToRealmCloud()
        case (true, true): // game finished
            if !goOnPlaying {
                congratulations(congratulationType: .GameFinished)
                saveToRealmCloud()
            }
            try! realm.safeWrite() {
                GV.playingRecord.allFixIndicated = true
                GV.playingRecord.allMandatoryIndicated = true
            }
        }
    }
    
    var goOnPlaying = false
    var congratulationsAlert: MyAlertController?
    var finishGameAlert: MyAlertController?
    
    private func congratulations(congratulationType: CongratulationType) {
        finishButton!.isHidden = false
        createCongratulationsAlert(congratulationType: congratulationType, easy: GV.basicDataRecord.difficulty == GameDifficulty.Easy.rawValue)
        bgSprite!.addChild(congratulationsAlert!)
        self.enabled = false
        self.gameboardEnabled = false


 //        let subViewPosition = UIAlertController.subviews[0].view.frame
//        self.parentViewController!.present(alertController, animated: true, completion: nil)
    }
    
    private func createCongratulationsAlert(congratulationType: CongratulationType, easy: Bool) {
        var title = ""
        var message = ""
        var finishTitle = ""
        var showMessage = true
 
        switch congratulationType {
        case .SolvedOnlyFixLetters:
                title = GV.language.getText(.tcCongratulationsFix1)
                message = GV.language.getText(.tcCongratulationsFix2)
                showMessage = GV.basicDataRecord.difficulty == GameDifficulty.Medium.rawValue ? true : false
        case .SolvedOnlyMandatoryWords:
            title = GV.language.getText(.tcCongratulationsMandatory1)
            message = GV.language.getText(.tcCongratulationsMandatory2)
        case .GameFinished:
            if easy {
                title = GV.language.getText(.tcCongratulationsEasy1)
            } else {
                title = GV.language.getText(.tcCongratulations1)
            }
            message = GV.language.getText(.tcCongratulations2)
            finishTitle = GV.language.getText(.tcFinishGame)
        }
        if showMessage {
            let continueTitle = GV.language.getText(.tcContinuePlaying)
            let OKTitle =  GV.language.getText(.tcOK)
            let myAlert = MyAlertController(title: title, message: message, target: self, type: .Green)
            if congratulationType == .GameFinished {
                if easy {
                    myAlert.addAction(text: continueTitle, action: #selector(self.continueEasyAction))
                    myAlert.addAction(text: finishTitle, action: #selector(self.finishEasyAction))
                } else {
                    myAlert.addAction(text: continueTitle, action: #selector(self.continueMediumAction))
                    myAlert.addAction(text: finishTitle, action: #selector(self.finishMediumAction))
                }
            } else {
                if congratulationType == .SolvedOnlyFixLetters {
                    myAlert.addAction(text: OKTitle, action: #selector(self.fixLettersOKAction))
                } else {
                    myAlert.addAction(text: OKTitle, action: #selector(self.mandatoryOKAction))
                }
            }
            myAlert.presentAlert()
            myAlert.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
            congratulationsAlert = myAlert
        }
    }
    
    @objc private func continueEasyAction () {
        self.enabled = true
        self.gameboardEnabled = true
        saveHelpInfo(action: .ContinueGameEasy)
        self.gameboardEnabled = true
        self.goOnPlaying = true
        try! realm.safeWrite() {
            GV.playingRecord.gameStatus = GV.GameStatusContinued
        }
    }
    
    @objc private func continueMediumAction () {
        self.enabled = true
        self.gameboardEnabled = true
        saveHelpInfo(action: .ContinueGameMedium)
        self.gameboardEnabled = true
        self.goOnPlaying = true
        try! realm.safeWrite() {
            GV.playingRecord.gameStatus = GV.GameStatusContinued
        }
    }
    @objc private func fixLettersOKAction () {
        self.enabled = true
        self.gameboardEnabled = true
        saveHelpInfo(action: .OKFixLettersSolved)
        self.gameboardEnabled = true
        try! realm.safeWrite() {
            GV.playingRecord.gameStatus = GV.GameStatusPlaying
        }
    }
    
    @objc private func mandatoryOKAction () {
        self.enabled = true
        self.gameboardEnabled = true
        saveHelpInfo(action: .OKMandatorySolved)
        self.gameboardEnabled = true
        try! realm.safeWrite() {
            GV.playingRecord.gameStatus = GV.GameStatusPlaying
        }
    }
        
    @objc private func finishEasyAction () {
        self.enabled = true
        self.gameboardEnabled = true
        saveHelpInfo(action: .FinishGameEasy)
        self.gameboardEnabled = true
        self.finishButtonTapped()
        self.saveToRealmCloud()
    }
    
    @objc private func finishMediumAction () {
        self.enabled = true
        self.gameboardEnabled = true
        saveHelpInfo(action: .FinishGameMedium)
        self.gameboardEnabled = true
        self.finishButtonTapped()
        self.saveToRealmCloud()
    }
    var gameFinishedStatus: GameFinishedStatus = .OK
    
    private func showGameFinished(status: GameFinishedStatus) {
        gameFinishedStatus = status
        if bestScoreForActualGame != nil && bestScoreForActualGame!.count > 0 && bestPlayersReady {
            let bestName = bestScoreForActualGame![0].owner!.nickName
            let bestScore = bestScoreForActualGame![0].bestScore
            let bestScoretext = GV.language.getText(.tcBestScoreHeader, values: String(bestScore).fixLength(length:scoreLength), bestName!)
            let bestScorelabel = bgSprite!.childNode(withName: bestScoreName) as? SKLabelNode
            bestScorelabel!.text = bestScoretext
        }
        createFinishGameAlert(status: status)
        bgSprite!.addChild(finishGameAlert!)

//        let action1 =  UIAlertAction(title: action1Title, style: .default, handler: {alert -> Void in
//            self.gameboardEnabled = true
//            if status == .OK {
//                try! realm.safeWrite() {
//                    GV.playingRecord.gameStatus = GV.GameStatusFinished
//                }
//                self.startNewGame()
//            } else {
//                self.restartThisGame()
//            }
//        })
//        let action2 =  UIAlertAction(title: action2Title, style: .default, handler: {alert -> Void in
//            self.gameboardEnabled = true
//        })
//        alertController.addAction(action1)
//        alertController.addAction(action2)
//        self.parentViewController!.present(alertController, animated: true, completion: nil)
    }
    
    private func createFinishGameAlert(status: GameFinishedStatus) {
        var title = ""
        var message = ""
        var action1Title = ""
        let action2Title = GV.language.getText(.tcBack)
        if gameFinishedStatus == .OK {
            title = GV.language.getText(.tcGameFinished1)
            message = GV.language.getText(.tcGameFinished2)
            action1Title = GV.language.getText(.tcFinishGame)
        } else {
            title = GV.language.getText(.tcTaskNotCompletedWithNoMoreSteps)
            message = GV.language.getText(.tcWillBeRestarted)
            action1Title = GV.language.getText(.tcRestartGame)
        }
        let myAlert = MyAlertController(title: title, message: message, target: self, type: .Red)
        //        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        myAlert.addAction(text: action1Title, action: #selector(finishButtonTapped2))
        myAlert.addAction(text: action2Title, action: #selector(goBackButtonTapped2))
        myAlert.presentAlert()
        myAlert.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
        finishGameAlert = myAlert
    }
    
    @objc private func finishButtonTapped2() {
        gameboardEnabled = true
        enabled = true
        if gameFinishedStatus == .OK {
            saveHelpInfo(action: .FinishGame)
            try! realm.safeWrite() {
                GV.playingRecord.gameStatus = GV.GameStatusFinished
            }
            if !showHelp {
                self.startNewGame()
            }
        } else {
            self.restartThisGame()
        }
    }
    
    @objc private func goBackButtonTapped2() {
        saveHelpInfo(action: .ContinueGameEasy)
        gameboardEnabled = true
        enabled = true
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
        if GV.playingRecord.rounds.count == 0 {
            actRound = 1
        }
        try! realm.safeWrite() {
//            GV.playingRecord.ownWords = tempOwnWords
            GV.playingRecord.score = GV.totalScore
            GV.playingRecord.pieces = pieces
            GV.playingRecord.gameStatus = goOnPlaying ? GV.GameStatusContinued : GV.GameStatusPlaying
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
    
    private func checkFreePlace(showAlert: Bool)->Bool {
        var placeFound = true
        for piece in pieceArray {
            for rotateIndex in 0..<4 {
                placeFound = wtGameboard!.checkFreePlaceForPiece(piece: piece, rotateIndex: rotateIndex)
                if placeFound {break}
            }
            if placeFound {break}
        }
        if !placeFound {
            let greenWordsCount = WTGameWordList.shared.getCountWordsInLastRound()
            if greenWordsCount > 0 {
                createNoMoreStepsAlert()
                bgSprite!.addChild(noMoreStepsAlert!)
                self.enabled = false
                self.gameboardEnabled = false
            } else {
                showGameFinished(status: .NoMoreSteps)
            }
        }
        return placeFound
    }

    var noMoreStepsAlert: MyAlertController?

    private func createNoMoreStepsAlert() {
        let myAlert = MyAlertController(title: GV.language.getText(.tcNoMoreStepsQuestion1),
                                        message: GV.language.getText(.tcChooseAction) , target: self, type: .Gold)
        myAlert.addAction(text: GV.language.getText(.tcBack), action:#selector(self.startUndoTapped))
        myAlert.addAction(text: GV.language.getText(.tcNoMoreStepsAnswer2), action:#selector(self.nextRoundTapped))
        myAlert.addAction(text: GV.language.getText(.tcNoMoreStepsAnswer3), action:#selector(self.noActionTapped))
        myAlert.presentAlert()
        myAlert.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
        noMoreStepsAlert = myAlert
    }
    
    @objc private func noActionTapped() {
        self.enabled = true
        saveHelpInfo(action: .NoMoreStepsCont)
    }
    
    @objc private func nextRoundTapped() {
        self.enabled = true
        saveHelpInfo(action: .NoMoreStepsNext)
        stopShowingTableIfNeeded()
        startNextRound()
        modifyHeader()
    }
    
    @objc private func startUndoTapped() {
        self.enabled = true
        saveHelpInfo(action: .NoMoreStepsBack)
        startUndo()
    }
    
    private func removeNodesWith(name: String) {
        while bgSprite!.childNode(withName: name) != nil {
            bgSprite!.childNode(withName: name)!.removeFromParent()
        }
    }
    
    var gameNumberForGenerating = 10000
    
    private func deleteGameDataRecord(gameNumber: Int) {
        let recordToDelete = realm.objects(GameDataModel.self).filter("gameNumber = %d and language = %d", gameNumber, GV.actLanguage)
        if recordToDelete.count == 1 {
            try! realm.safeWrite() {
                realm.delete(recordToDelete)
            }
        }
    }
    

    var actRound = 1
    
    private func startUndo() {
        if !self.enabled {
            return
        }
        func movePieceToPosition(from: WTPiece, to: Int, remove: Bool = false) {
            if remove {
                pieceArray[to].removeFromParent()
                pieceArray[to].reset()
            }
            pieceArray[to] = from
            pieceArray[to].name = "Pos\(String(to))"
            pieceArray[to].position = origPosition[to]
            pieceArray[to].setPieceFromPosition(index: to)
            origSize[to] = pieceArray[to].size
        }
        
        if GV.generateHelpInfo {
            saveHelpInfo(action: .UndoButton)
        }
        if activityRoundItem[activityRoundItem.count - 1].activityItems.count == 0 {
            actRound = GV.playingRecord.rounds.count - 1
            if activityRoundItem.count > 0 {
                try! realm.safeWrite() {
                    GV.playingRecord.rounds.removeLast()
                }
                activityRoundItem.removeLast()
                timeForGame.decrementMaxTime(value: iHalfHour)
                GV.totalScore = 0
                GV.mandatoryScore = 0
                GV.ownScore = 0
                GV.bonusScore = 0
                wtGameboard!.setRoundInfos()
                WTGameWordList.shared.reset()
                WTGameWordList.shared.restoreFromPlayingRecord()
                restoreGameArray()
                modifyHeader()
            }
        } else {
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
                        movePieceToPosition(from: pieceArray[1], to: 2, remove: true)
                        movePieceToPosition(from: pieceArray[0], to: 1)
                        movePieceToPosition(from: tileForGame, to: 0)
                        tileForGame.alpha = 1.0
                        removeNodesWith(name: pieceArray[0].name!)
                        bgSprite!.addChild(pieceArray[0])
                    case 1:
                        movePieceToPosition(from: pieceArray[1], to: 2, remove: true)
                        movePieceToPosition(from: tileForGame, to: 1)
                        tileForGame.alpha = 1.0
                        removeNodesWith(name: pieceArray[1].name!)
                        bgSprite!.addChild(pieceArray[1])
                    case 2:
                        movePieceToPosition(from: tileForGame, to: 2, remove: true)
                        tileForGame.alpha = 1.0
                        removeNodesWith(name: pieceArray[2].name!)
                        bgSprite!.addChild(pieceArray[2])
                    default: break
                    }
                } else {
                    var countTilesOnGameboard = 0
                    for tile in tilesForGame {
                        countTilesOnGameboard += tile.isOnGameboard ? 1 : 0
                    }
                    if countTilesOnGameboard == 0 {
                        wtGameboard!.clearGameArray()
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
                checkIfGameFinished()
//                saveActualState()
//                saveToRealmCloud()
                activityRoundItem[activityRoundItem.count - 1].activityItems.removeLast()
                modifyHeader()
            }
            saveActualState()
            saveToRealmCloud()
        }
        if activityRoundItem[activityRoundItem.count - 1].activityItems.count == 0 && activityRoundItem.count == 1 {
            if GV.generateHelpInfo {
                resetHelpInfo()
            }
            setUndoButton(enabled: false)
            wtGameboard!.clearGameArray()
        }
            
    }
    
    private func printTileForGame(_ index: Int) {
        let tileForGame = tilesForGame[index]
        print(tileForGame.toString())
    }
    
    func restoreGameArray() {
        func addPieceAsChild(pieceIndex: Int, piece: WTPiece) {
            pieceArray[pieceIndex] = piece
            pieceArray[pieceIndex].position = origPosition[pieceIndex]
            origSize[pieceIndex] = piece.size
            pieceArray[pieceIndex].name = "Pos\(pieceIndex)"
            removeNodesWith(name: "Pos\(pieceIndex)")             // remove the piece from this position, if exists
            bgSprite!.addChild(pieceArray[pieceIndex])
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
            actRound = GV.playingRecord.rounds.count
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
        if indexOfTilesForGame == 0 {
            indexOfTilesForGame = tilesForGame.count
            let pieces = generateArrayOfWordPieces(first:false)
            try! realm.safeWrite() {
                GV.playingRecord.pieces = pieces
            }
            saveArrayOfPieces()
        }
        for index in 0..<pieceArray.count {
            if pieceArray[index].name == nil {
                var tileForGame: WTPiece
                repeat {
                    tileForGame = tilesForGame[indexOfTilesForGame]
                    indexOfTilesForGame += 1
                } while tileForGame.isOnGameboard
                addPieceAsChild(pieceIndex: index, piece: tileForGame)
                
            }
        }
        if activityRoundItem.count == 0 {
            activityRoundItem.append(ActivityRound())
            activityRoundItem[activityRoundItem.count - 1].activityItems = [ActivityItem]()
        }
        if activityRoundItem[0].activityItems.count > 0 && !showHelp {
            setUndoButton(enabled: true)
        }
        timeForGame = TimeForGame(from: GV.playingRecord.time)
//        wtGameboard!.checkWholeWords()
    }
    
    private func generateArrayOfWordPieces(first: Bool)->String {
        let gameNumberForRandom = (GV.generateHelpInfo || showHelp) ? gameNumberForGenerating : GV.playingRecord.gameNumber % 1000
        let originalGameNumber = GV.generateHelpInfo || showHelp ? gameNumberForGenerating : GV.playingRecord.gameNumber
        let random = MyRandom(gameNumber: gameNumberForRandom, modifier: GV.playingRecord.words.count)
        var tileType = MyShapes.NotUsed
        var letters = [String]()
        var generateLength = 0
        var typesWithLen1 = [MyShapes]()
        var typesWithLen2 = [MyShapes]()
        var typesWithLen3 = [MyShapes]()
        var typesWithLen4 = [MyShapes]()
        var usedWords = [String]()
        var wordsString = ""
        var pieceString = ""
        var letterCounters = [String: Int]()

        for index in 0..<MyShapes.count - 1 {
            guard let type = MyShapes(rawValue: index) else {
                return ""
            }
            if type == .NotUsed {
                break
            }
            let length: Int = myForms[type]![0].points.count
            switch length {
            case 1: typesWithLen1.append(type)
            case 2: typesWithLen2.append(type)
            case 3: typesWithLen3.append(type)
            case 4: typesWithLen4.append(type)
            default: break
            }
        }
        
        wordsString = GV.playingRecord.words
        if wordsString.length > 0 {
            usedWords = wordsString.components(separatedBy: itemSeparator)
            wordsString += itemSeparator
        }
        let myLetters = GV.language.getText(.tcAlphabet)
        for letter in myLetters {
            letterCounters[String(letter)] = 0
        }

        func splittingWord(word: String) {
            var inputWord = ""
            let items = word.components(separatedBy: "ß")
            if items.count > 1 {
                for item in items {
                    inputWord += item.uppercased() + "ß"
                }
                inputWord.removeLast()
            } else {
                inputWord = word.uppercased()
            }
            for letter in inputWord {
                letterCounters[String(letter)]! += 1
            }
            usedWords.append(inputWord)
            wordsString += inputWord + "°"
            repeat {
                var letters = [String]()
                let randomLength = inputWord.length > 3 ? 3 : inputWord.length
                let tileLength = random.getRandomInt(1, max: randomLength)
                for _ in 0..<tileLength {
                    letters.append(inputWord.firstChar())
                    inputWord = inputWord.endingSubString(at: 1)
                }

                switch tileLength {
                case 1: tileType = typesWithLen1[random.getRandomInt(0, max: typesWithLen1.count - 1)]
                case 2: tileType = typesWithLen2[random.getRandomInt(0, max: typesWithLen2.count - 1)]
                case 3: tileType = typesWithLen3[random.getRandomInt(0, max: typesWithLen3.count - 1)]
                default: continue
                }
                let rotateIndex = random.getRandomInt(0, max: 3)

                let tileForGameItem = WTPiece(type: tileType, rotateIndex: rotateIndex, parent: self, blockSize: blockSize, letters: letters)
                for letter in letters {
                    pieceString += letter
                }
                pieceString += "°"
                let newIndex = random.getRandomInt(0, max: tilesForGame.count)
                if newIndex == tilesForGame.count || !first || usedWords.count > 6 /*|| GV.playingRecord.gameNumber % 1000 == 0 */{
                    tilesForGame.append(tileForGameItem)
                } else {
                    tilesForGame.insert(tileForGameItem, at: newIndex)
                }

            } while inputWord.length > 0
        }
        if first {
            let actRecord = realmMandatory.objects(MandatoryModel.self).filter("combinedKey = %d", GV.actLanguage + String(gameNumberForRandom))[0]
            let words = actRecord.mandatoryWords.components(separatedBy: itemSeparator)
            for word in words {
//                print(word)
                splittingWord(word: word)
            }
            
        } else {
            for word in usedWords {
                for letter in word.uppercased() {
                    if let _ = letterCounters[String(letter)] {
                        letterCounters[String(letter)]! += 1
                    }
                }
            }
        }
//        let number = GV.playingRecord.gameNumber + 50
//        var allRecords = realmMandatoryList.objects(MandatoryListModel.self).filter("word BEGINSWITH %d", GV.actLanguage)
//        myTimer!.startTimeMessing()
        for _ in 1...(first ? 4 : 10) {
            var letters = [String]()
            let sortedLetterCounters = letterCounters.sorted(by: { $0.0 < $1.0 })
            var minValue = 1000
            for item in sortedLetterCounters {
                if item.value < minValue {
                    minValue = item.value
                }
            }
            
            for item in sortedLetterCounters {
                if item.value == minValue {
                    letters.append(item.key)
                }
            }
            var index = 0
            var counter = 0
            var allRecords: Results<MandatoryListModel>
            repeat {
                allRecords = realmMandatoryList.objects(MandatoryListModel.self).filter("language = %d", GV.actLanguage).filter("word CONTAINS %@", letters[index].lowercased())
                counter = allRecords.count
                if counter < 10 {
                    letters.remove(at: index)
                } else {
                    index += 1
                }
            } while counter < 10
            var countRepeats = 0
            var word = ""
            repeat {
                let wordIndex = random.getRandomInt(0, max: counter - 1)
                word = allRecords[wordIndex].word
                countRepeats += 1
                if usedWords.contains(where: {$0 == word}) {
                    print("word \(word) used")
                }
            } while usedWords.contains(where: {$0 == word}) && countRepeats < counter
             splittingWord(word: word)
            
//            print("letters: \(letters), word: \(word)")
            
         }
//        myTimer!.showWholeTime(text: "after generating")
        var generatedArrayInStringForm = ""
        for tile in tilesForGame {
            generatedArrayInStringForm += tile.toString() + "°"
        }
        wordsString.removeLast()
        print("wordString: \(wordsString)")
        try! realm.safeWrite() {
            GV.playingRecord.words = wordsString
        }
        var word = ""
        for (index, tile) in tilesForGame.enumerated() {
            tile.setArrayIndex(index: index)
            for letter in tile.letters {
                word += letter
            }
            word += index < tilesForGame.count - 1 ?  "-" : ""
        }
        print("letters: \(word)")
        return generatedArrayInStringForm

    }

    private func createButton(withText: String, position: CGPoint, name: String, buttonSize: CGSize? = nil)->SKSpriteNode {
        func createLabel(withText: String, position: CGPoint, fontSize: CGFloat, name: String)->SKLabelNode {
            let label = SKLabelNode()
            label.fontName = GV.actFont
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
        button.zPosition = 1
        button.addChild(createLabel(withText: withText, position: CGPoint(x:0, y:10), fontSize: self.size.width * 0.03, name: name + "Label"))
        return button
        
    }

    
    var showOwnWordsTableView: WTTableView?
    struct WordsForShow {
        var words = [FoundedWordWithCounter]()
        var countWords = 0
        var countAllWords = 0
        var score = 0
        init(words: [FoundedWordWithCounter]) {
            self.words = words
            countWords = words.count
            for item in words {
                countAllWords += item.counter
                self.score += item.score
            }
        }
    }
    var ownWordsForShow: WordsForShow?
    var mandatoryWordsForShow: WordsForShow?
    var maxLength = 0
    var showingWordsInTable = false
    let myFont = UIFont(name: GV.actLabelFont /*"CourierNewPS-BoldMT"*/, size: GV.onIpad ? 18 : 15)
    let myTitleFont = UIFont(name: GV.actFont, size: GV.onIpad ? 30 : 18)

    private func showOwnWordsInTableView() {
        tableType = .ShowAllWords
        showOwnWordsTableView = WTTableView()
        timerIsCounting = false
        var maxLength1 = 0
        var words: [FoundedWordWithCounter]
        (words, maxLength) = WTGameWordList.shared.getWordsForShow(mandatory: true)
        mandatoryWordsForShow = WordsForShow(words: words)
        (words, maxLength1) = WTGameWordList.shared.getWordsForShow(mandatory: false)
        ownWordsForShow = WordsForShow(words: words)
        maxLength = maxLength1 > maxLength ? maxLength1 : maxLength
        calculateColumnWidths()
        showOwnWordsTableView?.setDelegate(delegate: self)
        showOwnWordsTableView?.register(CustomTableViewCell.self, forCellReuseIdentifier: "cell")
        let origin = CGPoint(x: 0.5 * (self.frame.width - title.width(font: myFont!)), y: self.frame.height * 0.08)
        let lineHeight = title.height(font:myFont!)
        let headerframeHeight = lineHeight * 4.6
        var showingWordsHeight = CGFloat(ownWordsForShow!.words.count + mandatoryWordsForShow!.words.count) * lineHeight
        if showingWordsHeight  > self.frame.height * 0.8 {
            var counter = CGFloat(ownWordsForShow!.words.count)
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
//        self.scene?.alpha = 0.2
        self.scene?.view?.addSubview(showOwnWordsTableView!)
        self.hideButtons(hide: true)
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
    private func printGameArray() {
        let line = "____________________________________________"
        for row in 0..<10 {
            var infoLine = "|"
            for col in 0..<10 {
                let char = GV.gameArray[col][row].letter
                var greenMark = emptyLetter
                if GV.gameArray[col][row].status == .WholeWord {
                    greenMark = "*"
                }
                if GV.gameArray[col][row].doubleUsed {
                    greenMark = "!"
                }
                infoLine += greenMark + (char == "" ? "!" : char) + greenMark + "|"
            }
            print(infoLine)
        }
        print(line)
    }

}

