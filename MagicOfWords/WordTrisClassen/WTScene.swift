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
        let text5 = showCount ? "\(GV.language.getText(.tcMinutes)) " : ""
        title += text1
        title += text2
        title += text3
        title += text4
        title += text5
//        lengthOfWord = maxLength
        lengthOfCnt = text2.length
        lengthOfLength = text3.length
        lengthOfScore = text4.length
        lengthOfMin = text5.length
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
                cell.addColumn(text: "+\(wordForShow.minutes)".fixLength(length: lengthOfMin))
            } else {
                let wordForShow = ownWordsForShow!.words[indexPath.row]
                cell.addColumn(text: "  " + wordForShow.word.fixLength(length: lengthOfWord, leadingBlanks: false)) // WordColumn
                cell.addColumn(text: String(wordForShow.counter).fixLength(length: lengthOfCnt), color: color) // Counter column
                cell.addColumn(text: String(wordForShow.word.length).fixLength(length: lengthOfLength))
                cell.addColumn(text: String(wordForShow.score).fixLength(length: lengthOfScore), color: color) // Score column
                cell.addColumn(text: "+\(wordForShow.minutes)".fixLength(length: lengthOfMin))
             }
        case .ShowWordsOverPosition:
            cell.addColumn(text: "  " + wordList[indexPath.row].word.fixLength(length: lengthOfWord + 2, leadingBlanks: false)) // WordColumn
            cell.addColumn(text: String(1).fixLength(length: lengthOfCnt - 1), color: color)
            cell.addColumn(text: String(wordList[indexPath.row].word.length).fixLength(length: lengthOfLength - 1))
            cell.addColumn(text: String(wordList[indexPath.row].score).fixLength(length: lengthOfScore + 1), color: color)
            cell.addColumn(text: "+\(WTGameWordList.shared.getMinutesForWord(word: wordList[indexPath.row].word))".fixLength(length: lengthOfMin - 1))
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
        self.addChild(balloon)
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
//        var goPreviousGame = false
//        var goNextGame = false
        var GCol = NoValue
        var GRow = NoValue
        var col = NoValue
        var row = NoValue
        var shapeIndex = NoValue
//        var answer1 = false
//        var answer2 = false
//        var ownWordsBackground = false
//        var gameFinishedOKButton = false
//        var showOwnWordsButton = false
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
    var timeLabel = SKLabelNode()
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
    var startTouchedNodes = TouchedNodes()
//    var wtGameFinishedSprite = WTGameFinished()

    var pieceArray = [WTPiece]()
    var origPosition: [CGPoint] = Array(repeating: CGPoint(x:0, y: 0), count: 3)
    var origSize: [CGSize] = Array(repeating: CGSize(width:0, height: 0), count: 3)
    var totalScore: Int = 0
    var moved = false
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
    var startShapeIndex = 0
    let shapeMultiplicator = [CGFloat(0.25), CGFloat(0.50), CGFloat(0.75)]
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
//    var wtGameWordList: WTGameWordList?

    
    override func didMove(to view: SKView) {
//        wtGameWordList = WTGameWordList(delegate: self)
//        timeIncreaseValues = [0, 0, 0, 0, 0, 0, iFiveMinutes, iFiveMinutes, iTenMinutes, iTenMinutes, iQuarterHour]
        self.name = "WTScene"
        self.view!.isMultipleTouchEnabled = false
        self.view!.subviews.forEach { $0.removeFromSuperview() }
        self.blockSize = self.frame.size.width * (GV.onIpad ? 0.70 : 0.90) / CGFloat(12)
        GV.totalScore = 0
        GV.mandatoryScore = 0
        GV.ownScore = 0
        GV.bonusScore = 0
//        self.wtGameFinishedSprite = WTGameFinished()
//        self.addChild(wtGameFinishedSprite)
        self.backgroundColor = bgColor
//        generateReadOnly()
//        exit(0)
        if restart {
            let recordToDelete = realm.objects(GameDataModel.self).filter("language = %@ and gameNumber = %d", GV.actLanguage, newGameNumber)
            if recordToDelete.count == 1 {
                try! realm.safeWrite() {
                    realm.delete(recordToDelete)
                }
            }
        }

        getPlayingRecord(new: new, next: nextGame, gameNumber: newGameNumber)
        createHeader()
        buttonHeight = self.frame.width * (GV.onIpad ? 0.08 : 0.125)
        createUndo(enabled: false)
        createGoBackButton()
//        wtGameFinishedSprite.setDelegate(delegate: self)
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
    private func getPlayingRecord(new: Bool, next: StartType, gameNumber: Int) {
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
        var actGames = realm.objects(GameDataModel.self).filter("nowPlaying = TRUE and language = %@", GV.actLanguage)
        if new {
            let games = realm.objects(GameDataModel.self).filter("gameStatus = %d and language = %@", GV.GameStatusNew, GV.actLanguage).sorted(byKeyPath: "gameNumber", ascending: true)
            /// reset all records with nowPlaying status
            if actGames.count > 0 {
                try! realm.safeWrite() {
                    for actGame in actGames {
                        actGame.nowPlaying = false
                    }
                }
            }
//            wtGameWordList = WTGameWordList(delegate: self)
            if games.count > 0 {
                GV.playingRecord = games[0]
                try! realm.safeWrite() {
                    GV.playingRecord.nowPlaying = true
                    GV.playingRecord.time = timeInitValue
                }
            } else {
                var freeGameNumbers = [Int]()
                for number in 0...999 {
                    freeGameNumbers.append(number)
                }
                let playedGames = realm.objects(GameDataModel.self).filter("language = %@", GV.actLanguage).sorted(byKeyPath: "gameNumber", ascending: false)
                for playedGame in playedGames {
                    if playedGame.gameNumber < 1000 {
                        freeGameNumbers.remove(at: playedGame.gameNumber)
                    }
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
                actGames = realm.objects(GameDataModel.self).filter("(gameStatus = %d or gameStatus = %d) and language = %@", GV.GameStatusPlaying, GV.GameStatusContinued, GV.actLanguage)
                if actGames.count > 0 {
                    try! realm.safeWrite() {
                        actGames[0].nowPlaying = true
                    }
                }
            }
            let playedNowGame = realm.objects(GameDataModel.self).filter("nowPlaying = TRUE and language = %@", GV.actLanguage)
            var actGameNumber = playedNowGame.first!.gameNumber
            if playedNowGame.count > 0 {
                switch nextGame {
                case .NoMore:
                    break
                case .PreviousGame:
                    let previousRecords = realm.objects(GameDataModel.self).filter("(gameStatus = %d or gameStatus = %d) and gameNumber < %d and language = %@",
                       GV.GameStatusPlaying, GV.GameStatusContinued, actGameNumber, GV.actLanguage)
                    if previousRecords.count == 1 {
                        actGameNumber = previousRecords[0].gameNumber
                    } else if let record = Array(previousRecords).sorted(by: {$0.gameNumber < $1.gameNumber}).last {
                        actGameNumber = record.gameNumber
                    } else {
                        break
                    }
                case .NextGame:
                    let nextRecords = realm.objects(GameDataModel.self).filter("(gameStatus = %d or gameStatus = %d) and gameNumber > %d and language = %@",
                       GV.GameStatusPlaying, GV.GameStatusContinued, actGameNumber, GV.actLanguage)
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
        let mandatoryRecord: MandatoryModel? = realmMandatory.objects(MandatoryModel.self).filter("gameNumber = %d and language = %@", gameNumber, GV.actLanguage).first!
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
    
    public func setGameArt(new: Bool = false, next: StartType = .NoMore, gameNumber: Int = 0, restart: Bool) {
        self.new = new
        self.nextGame = next
        self.newGameNumber = gameNumber
        self.restart = restart
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
    
    private func createHeader() {
        let fontSize = self.frame.size.height * 0.0175 // GV.onIpad ? self.frame.size.width * 0.02 : self.frame.size.width * 0.032
        if self.childNode(withName: timeName) == nil {
            timeLabel = SKLabelNode(fontNamed: GV.actLabelFont) //"CourierNewPS-BoldMT") // Snell Roundhand")
            let YPosition: CGFloat = self.frame.height * gameNumberLinePosition
            let xPosition = self.frame.size.width * 0.90
            timeLabel.position = CGPoint(x: xPosition, y: YPosition)
            timeLabel.fontSize = fontSize
            timeLabel.fontColor = .black
            timeLabel.text = GV.language.getText(.tcTime, values: timeForGame.time.HourMinSec)
            timeLabel.horizontalAlignmentMode = .right
            timeLabel.name = timeName
            self.addChild(timeLabel)
        }

        let startPosXForHeaderMultiplier: CGFloat = 0.15
        if self.childNode(withName: headerName) == nil {
            let YPosition: CGFloat = self.frame.height * gameNumberLinePosition
            let gameNumber = GV.playingRecord.gameNumber
            let text = GV.language.getText(.tcHeader, values: String(gameNumber), String(0))
            headerLabel = SKLabelNode(fontNamed: GV.actLabelFont) //"CourierNewPS-BoldMT")// Snell Roundhand")
            headerLabel.text = text
            headerLabel.name = String(headerName)
            headerLabel.fontSize = fontSize
            headerLabel.position = CGPoint(x: self.frame.size.width * startPosXForHeaderMultiplier, y: YPosition)
            headerLabel.horizontalAlignmentMode = .left
            headerLabel.fontColor = SKColor.black
            self.addChild(headerLabel)
        }
        
        let myName = GV.basicDataRecord.myNickname
        
        let bestName = "nobody"
        let bestScore = 0
        
        if self.childNode(withName: bestScoreName) == nil {
            let YPosition: CGFloat = self.frame.height * bestScoreLinePosition
            //            let text = GV.language.getText(.tcBestScoreHeader, values: bestOnlineRecord!.player, bestOnlineRecord!.score)
            let text = GV.language.getText(.tcBestScoreHeader, values: String(bestScore).fixLength(length:15), bestName)
            bestScoreHeaderLabel = SKLabelNode(fontNamed: GV.actLabelFont) //"CourierNewPS-BoldMT")// Snell Roundhand")
            bestScoreHeaderLabel.text = text
            bestScoreHeaderLabel.name = String(bestScoreName)
            bestScoreHeaderLabel.fontSize = fontSize
            bestScoreHeaderLabel.position = CGPoint(x: self.frame.size.width * /*xPosMultiplierForScore*/ startPosXForHeaderMultiplier, y: YPosition)
            bestScoreHeaderLabel.horizontalAlignmentMode = .left
            bestScoreHeaderLabel.fontColor = SKColor.black
            self.addChild(bestScoreHeaderLabel)
        }
        
        if self.childNode(withName: myScoreName) == nil {
            let YPosition: CGFloat = self.frame.height * myScoreLinePosition
            let text = GV.language.getText(.tcMyScoreHeader, values: String(GV.playingRecord.score).fixLength(length:15), myName)
            myScoreheaderLabel = SKLabelNode(fontNamed: GV.actLabelFont) //"CourierNewPS-BoldMT")// Snell Roundhand")
            myScoreheaderLabel.text = text
            myScoreheaderLabel.name = String(myScoreName)
            myScoreheaderLabel.fontSize = fontSize
            myScoreheaderLabel.position = CGPoint(x: self.frame.size.width * /*xPosMultiplierForScore*/ startPosXForHeaderMultiplier, y: YPosition)
            myScoreheaderLabel.horizontalAlignmentMode = .left
            myScoreheaderLabel.fontColor = SKColor.black
            self.addChild(myScoreheaderLabel)
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
            createNextRound = false
            GV.nextRoundAnimationFinished = false
        }
    }
    
    private func modifyHeader() {
        let gameNumber = GV.playingRecord.gameNumber
        let headerText = GV.language.getText(.tcHeader, values: String(gameNumber + 1), String(actRound))
        headerLabel.text = headerText
//        let letterScore = GV.bonusScore
//        let normalScore = GV.mandatoryScore + GV.//WTGameWordList.shared.getScore(forAll: true)
        let score = GV.totalScore
        var place = 0
        if bestPlayersReady {
            place = self.bestPlayers!.filter("score > %@", score).count + 1
        }
        let scoreText = GV.language.getText(.tcMyScoreHeader, values: String(place), String(score).fixLength(length:6), GV.basicDataRecord.myNickname)
        let myScorelabel = self.childNode(withName: myScoreName) as? SKLabelNode
        if myScorelabel != nil {
            myScorelabel!.text = scoreText
        }
 
        if bestScoreForActualGame != nil && bestScoreForActualGame!.count > 0 {
            let bestName = bestScoreForActualGame![0].owner != nil ? bestScoreForActualGame![0].owner!.nickName : ""
            let bestScore = bestScoreForActualGame![0].bestScore
            let bestScoretext = GV.language.getText(.tcBestScoreHeader, values: String(bestScore).fixLength(length:6), bestName!)
            let bestScorelabel = self.childNode(withName: bestScoreName) as? SKLabelNode
            bestScorelabel!.text = bestScoretext
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
            let label = self.childNode(withName: actWord.word) as? SKLabelNode
            if label != nil {
                label!.text = actWord.word + " (\(actWord.counter)) "
            }
        }
        
        if let label = self.childNode(withName: bonusHeaderName)! as? SKLabelNode {
            label.text = GV.language.getText(.tcBonusHeader, values: String(GV.bonusScore))
        }

        if let label = self.childNode(withName: mandatoryWordsHeaderName)! as? SKLabelNode {
            label.text = GV.language.getText(.tcWordsToCollect, values: String(WTGameWordList.shared.getCountWords(mandatory: true)), String(WTGameWordList.shared.getCountFoundedWords(mandatory: true, countFoundedMandatory: true)),
                String(WTGameWordList.shared.getCountFoundedWords(mandatory: true, countAll: true)),
                String(GV.mandatoryScore))
        }
        if let label = self.childNode(withName: ownWordsHeaderName)! as? SKLabelNode {
                label.text = GV.language.getText(.tcOwnWords, values: String(WTGameWordList.shared.getCountWords(mandatory: false)), String(WTGameWordList.shared.getCountFoundedWords(mandatory: false, countAll: true)),
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
        stopShowingTableIfNeeded()
        if timer != nil {
            timer!.invalidate()
            timer = nil
        }
        removeAllSubviews()
        wtSceneDelegate!.gameFinished(start: .NoMore)
    }
    
    var searchingWord = ""
    var wtGameboardMovedBy: CGFloat = 0
    
    @objc func wordListTapped() {
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
            if let child = self.childNode(withName: "Row\(row)") {
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
        if undoButton != nil {
            undoButton!.isHidden = hide
        }
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
            let actSearchingChar = searchingWord.lowercased().char(from: pos)
            if actSearchingChar == questionMark {
                if actString.count > 0 && actString.char(from: 0) != questionMark {
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
                if actString.count > 0 && (actString.char(from:0) == star || actString.char(from:0) == questionMark) {
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
            if ind > 0 && ind < searchingParts.count - 1 && part.char(from: 0) != star && part.char(from: 0) != questionMark {
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
        stopShowingTableIfNeeded()
        if timer != nil {
            timer!.invalidate()
            timer = nil
        }
        removeAllSubviews()
        wtSceneDelegate!.gameFinished(start: .PreviousGame)
    }
    
    @objc func goNextGame() {
        stopShowingTableIfNeeded()
        if timer != nil {
            timer!.invalidate()
            timer = nil
        }
        removeAllSubviews()
        wtSceneDelegate!.gameFinished(start: .NextGame)
    }
    
    @objc func showAllWordsInTableView() {
        #if HELPGEN
            saveHelpInfo(allWordsButtonTouched:true)
        #endif
        stopShowingTableIfNeeded()
        showOwnWordsInTableView()
        showingWordsInTable = true
    }
    
    var searchButton: MyButton?
    var saveDataButton: MyButton?
    var allWordsButton: MyButton?
    var finishButton: MyButton?

    var goToPreviousGameButton: UIButton?
    var goToNextGameButton: UIButton?
    var undoButton: UIButton?
    var goBackButton: UIButton?
    var buttonHeight = CGFloat(0)
    
    func hideButtons(hide: Bool) {
        goToPreviousGameButton!.isEnabled = !hide
        goToNextGameButton!.isEnabled = !hide
        undoButton!.isEnabled = !hide
        allWordsButton!.isEnabled = !hide
        finishButton!.isEnabled = !hide
        goBackButton!.isEnabled = !hide
        searchButton!.isEnabled = !hide
        if hide {
            goToPreviousGameButton!.alpha = 0.2
            goToNextGameButton!.alpha = 0.2
            undoButton!.alpha = 0.2
            allWordsButton!.alpha = 0.2
            finishButton!.alpha = 0.2
            goBackButton!.alpha = 0.2
            searchButton!.alpha = 0.2
        } else {
            goToPreviousGameButton!.alpha = 1.0
            goToNextGameButton!.alpha = 1.0
            undoButton!.alpha = 1.0
            allWordsButton!.alpha = 1.0
            finishButton!.alpha = 1.0
            goBackButton!.alpha = 1.0
            searchButton!.alpha = 1.0
        }

    }

    func createGoToPreviousGameButton(enabled: Bool) {
        if goToPreviousGameButton != nil {
            goToPreviousGameButton?.removeFromSuperview()
            goToPreviousGameButton = nil
        }
        let frame = CGRect(x: 0, y: 0, width: buttonHeight, height: buttonHeight)
        let center = CGPoint(x:self.frame.width * 0.08, y:self.frame.height * 0.92)
        let radius = self.frame.width * 0.045
        let hasFrame = GV.buttonType == GV.ButtonTypeSimple
        let imageName = hasFrame ? "LeftSimple" : "LeftElite"
        goToPreviousGameButton = createButton(imageName: imageName, title: "", frame: frame, center: center, cornerRadius: radius, enabled: enabled, hasFrame: hasFrame)
        goToPreviousGameButton?.addTarget(self, action: #selector(self.goPreviousGame), for: .touchUpInside)
        self.view?.addSubview(goToPreviousGameButton!)
        self.view?.addSubview(goToPreviousGameButton!)
    }
    func createGoToNextGameButton(enabled: Bool) {
        if goToNextGameButton != nil {
            goToNextGameButton?.removeFromSuperview()
            goToNextGameButton = nil
        }
        let frame = CGRect(x: 0, y: 0, width: buttonHeight, height: buttonHeight)
        let center = CGPoint(x:self.frame.width * 0.92, y:self.frame.height * 0.92)
        let radius = self.frame.width * 0.045
        let hasFrame = GV.buttonType == GV.ButtonTypeSimple
        let imageName = hasFrame ? "RightSimple" : "RightElite"
        goToNextGameButton = createButton(imageName: imageName, title: "", frame: frame, center: center, cornerRadius: radius, enabled: enabled, hasFrame: hasFrame )
        goToNextGameButton?.addTarget(self, action: #selector(self.goNextGame), for: .touchUpInside)
        self.view?.addSubview(goToNextGameButton!)
    }
    
    private func createShowAllWordsButton() {
        if allWordsButton != nil {
            allWordsButton?.removeFromParent()
            allWordsButton = nil
        }
        var ownHeaderYPos = CGFloat(0)
//        let ownHeader: SKNode = (self.childNode(withName: ownWordsHeaderName) as! SKLabelNode)
        let title = GV.language.getText(.tcShowAllWords)
        let wordLength = title.width(font: myTitleFont!)
//        let wordHeight = title.height(font: myTitleFont!)
        let size = CGSize(width:wordLength * 1.5, height: buttonHeight)
        ownHeaderYPos = self.frame.height * mybuttonLineCenterY// - ownHeader.frame.maxY + frame.height
        allWordsButtonCenter = CGPoint(x:self.frame.width * 0.6, y: ownHeaderYPos) //self.frame.height * 0.20)
//        let radius = frame.height * 0.5
        let myButton = createMyButton(title: title, size: size, center: allWordsButtonCenter, enabled: true )
        myButton.setButtonAction(target: self, triggerEvent:.TouchUpInside, action: #selector(showAllWordsInTableView))
//        allWordsButton?.addTarget(self, action: #selector(self.showAllWordsInTableView), for: .touchUpInside)
        myButton.zPosition = self.zPosition + 1
        allWordsButton = myButton
        self.addChild(allWordsButton!)
    }
    
    private func createMyButton(imageName: String = "", title: String = "", size: CGSize, center: CGPoint, enabled: Bool, newSize: CGFloat = 0)->MyButton {
        var button: MyButton
        if imageName != "" {
            let texture = SKTexture(imageNamed: imageName)
            button = MyButton(normalTexture: texture, selectedTexture:texture, disabledTexture: texture)
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
        let myButton = createMyButton(title: title, size: size, center: finishButtonCenter, enabled: true )
        myButton.isHidden = goOnPlaying ? false : true
        myButton.setButtonAction(target: self, triggerEvent:.TouchUpInside, action: #selector(finishButtonTapped))

//        myButton!.addTarget(self, action: #selector(self.finishButtonTapped), for: .touchUpInside)
//        finishButton?.layer.zPosition = -100
        finishButton = myButton
        self.addChild(myButton)
    }
    
    @objc private func finishButtonTapped() {
        showGameFinished(status: .OK)
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
        self.addChild(searchButton!)
    }
    
    private func createSaveDataButton() {
        if !(playerActivity![0].maySaveInfos) {
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
        self.addChild(saveDataButton!)

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
            goBackButton?.removeFromSuperview()
            goBackButton = nil
        }
        let frame = CGRect(x: 0, y: 0, width: buttonHeight, height: buttonHeight)
        let center = CGPoint(x:self.frame.width * 0.10, y:self.frame.height * buttonYPosition)
        let radius = self.frame.width * 0.04
        let hasFrame = GV.buttonType == GV.ButtonTypeSimple
        let imageName = hasFrame ? "BackSimple" : "BackElite"
        goBackButton = createButton(imageName: imageName, imageSize: 1.5, title: "", frame: frame, center: center, cornerRadius: radius, enabled: true, hasFrame: hasFrame)
        goBackButton!.addTarget(self, action: #selector(self.goBackTapped), for: .touchUpInside)
        self.view?.addSubview(goBackButton!)
    }
    
    private func createUndo(enabled: Bool) {
        if undoButton != nil {
            undoButton?.removeFromSuperview()
            undoButton = nil
        }
        if activityRoundItem.count == 0 {
            activityRoundItem.append(ActivityRound())
            activityRoundItem[activityRoundItem.count - 1].activityItems = [ActivityItem]()
        }
        let enabled = activityRoundItem[0].activityItems.count > 0
        let frame = CGRect(x: 0, y: 0, width: buttonHeight, height: buttonHeight)
        let center = CGPoint(x:self.frame.width * 0.90, y:self.frame.height * buttonYPosition)
        let radius = self.frame.width * 0.04
        let hasFrame = GV.buttonType == GV.ButtonTypeSimple
        let imageName = hasFrame ? "UndoSimple" : "UndoElite"
        undoButton = createButton(imageName: imageName, imageSize: 1.5, title: "", frame: frame, center: center, cornerRadius: radius, enabled: enabled, hasFrame: hasFrame)
        undoButton?.addTarget(self, action: #selector(self.undoTapped), for: .touchUpInside)
        self.view?.addSubview(undoButton!)
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
                                              String(WTGameWordList.shared.getCountFoundedWords(mandatory: false, countAll: true)),
                                              //                    String(WTGameWordList.shared.getScore(mandatory: false))), first: false, name: ownWordsHeaderName)
            String(0)),
                    linePosition: bonusPointsLinePosition, name: bonusHeaderName)
        createLabel(word: GV.language.getText(.tcOwnWords, values:
            String(WTGameWordList.shared.getCountWords(mandatory: false)),
            String(WTGameWordList.shared.getCountFoundedWords(mandatory: false, countAll: true)),
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
        self.addChild(label)
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
        self.addChild(label)
    }
    
//    var random: MyRandom?

    private func play() {
        GV.playing = true
        timerIsCounting = true
        headerCreated = false
        WTGameWordList.shared.setDelegate(delegate: self)
        timeForGame = TimeForGame(from: GV.playingRecord.time)
//        createHeader()
        myTimer = MyTimer(time: timeForGame)
//        addChild(myTimer!)
        wtGameboard = WTGameboard(countCols: GV.sizeOfGrid, parentScene: self, delegate: self, yCenter: gameboardCenterY)
        if GV.playingRecord.gameStatus == GV.GameStatusContinued {
            goOnPlaying = true
        }
        generateArrayOfWordPieces(new: new)
        indexOfTilesForGame = 0
//        getOnlineRecords()
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
                pieceArray[index] = getNextPiece(horizontalPosition: index)
                origSize[index] = pieceArray[index].size
                pieceArray[index].position = origPosition[index]
                pieceArray[index].name = "Pos\(index)"
                self.addChild(pieceArray[index])
            }
        }
        #if HELPGEN
            if GV.playingRecord.gameNumber == 0 {
                initiateHelpModel()
            }
        #endif
//        modifyHeader()
        createGoToPreviousGameButton(enabled: hasPreviousRecords(playingRecord: GV.playingRecord))
        createGoToNextGameButton(enabled: hasNextRecords(playingRecord: GV.playingRecord))
        createShowAllWordsButton()
        createFinishButton()
        createSearchButton()
        createSaveDataButton()
        
        if timer != nil {
            timer!.invalidate()
        }
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(countTime(timerX: )), userInfo: nil, repeats: true)
        countTime(timerX: Timer())
    }
    
    var bestPlayerNickname = ""
    var bestScore = 0
    var actPlayer = ""
    var actScore = 0
    
//    let bestOnlineRecords: Results<BestScoreSync>
//    var notificationToken: NotificationToken?
//    var subscriptionToken: NotificationToken?
//    var subscription: SyncSubscription<bestOnlineRecords>!
    
    
//    private func getOnlineRecords() {
//        let gameNumber = GV.playingRecord.gameNumber % 1000 + 1
//        bestOnlineRecords = realmSync!.objects(BestScoreSync.self).filter("CombinedPrimary BEGINSWITH %@", "\(gameNumber)\(GV.aktLanguage)").sorted(byKeyPath: "score", ascending: false)
//        subscription = bestOnlineRecords.subscribe(named: "myBestScores")
//        subscriptionToken = subscription.observe(\.state) { [weak self]  state in
//            print("in Subscription!")
//            switch state {
//            case .creating:
//                print("creating")
//            // The subscription has not yet been written to the Realm
//            case .pending:
//                print("pending")
//                // The subscription has been written to the Realm and is waiting
//            // to be processed by the server
//            case .complete:
//                print("complete: count records: \(String(describing: self!.bestOnlineRecords.count))")
//                // The subscription has been processed by the server and all objects
//            // matching the query are in the local Realm
//            case .invalidated:
//                print("invalitdated")
//            // The subscription has been removed
//            case .error(let error):
//                print("error: \(error)")
//                // An error occurred while processing the subscription
//            }
//        }
////        notificationToken = bestOnlineRecords.observe { [weak self] (changes) in
////            switch changes {
////            case .initial:
////                // Results are now populated and can be accessed without blocking the UI
////                let bestPlayer = self!.bestOnlineRecords.first!.playerName
////                bestPlayerNickname =
////            case .update(_, let deletions, let insertions, let modifications):
////                // Query results have changed, so apply them to the UITableView
////                if insertions.count > 0 {
////                    bestOnlineRecords.frame.size.height += CGFloat(insertions.count) * self!.headerLine.height(font: self!.myFont!)
////                }
////                bestOnlineRecords.beginUpdates()
////                showPlayerActivityView.insertRows(at: insertions.map({ IndexPath(row: $0, section: 0) }),
////                                                  with: .automatic)
////                showPlayerActivityView.deleteRows(at: deletions.map({ IndexPath(row: $0, section: 0)}),
////                                                  with: .automatic)
////                showPlayerActivityView.reloadRows(at: modifications.map({ IndexPath(row: $0, section: 0) }),
////                                                  with: .automatic)
////                showPlayerActivityView.endUpdates()
////            case .error(let error):
////                // An error occurred while opening the Realm file on the background worker thread
////                fatalError("\(error)")
////            }
////        }
//    }
    
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
        timeLabel.text = GV.language.getText(.tcTime, values: timeForGame.time.HourMinSec)
        try! realm.safeWrite() {
            GV.playingRecord.time = timeForGame.toString()
        }
//        if myTimer!.update(time: timeForGame) {
//            timer!.invalidate()
//            timer = nil
//            showGameFinished(status: .TimeOut)
//        }
    }
    
    var helpInfo: Realm?
    
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
            objectTypes: [HelpModel.self])
        do {
            // Realm is compacted on the first open if the configuration block conditions were met.
            _ = try Realm(configuration: config1)
        } catch {
            print("error")
            // handle error compacting or opening Realm
        }
        let helpInfoConfig = Realm.Configuration(
            fileURL: helpInfoURL,
            schemaVersion: 4, // new item words
            // Set the block which will be called automatically when opening a Realm with
            // a schema version lower than the one set above
            migrationBlock: { migration, oldSchemaVersion in
                switch oldSchemaVersion {
                case 0:
                    migration.enumerateObjects(ofType: HelpModel.className()) { oldObject, newObject in
                        newObject!["pieces"] = oldObject!["helpString"]
                    }
                case 1...3:
                    migration.deleteData(forType: HelpModel.className())

                default: migration.enumerateObjects(ofType: BasicDataModel.className())
                { oldObject, newObject in
                    }
                }
        },
            objectTypes: [HelpModel.self])
        
        helpInfo = try! Realm(configuration: helpInfoConfig)

    }
    
    private func resetHelpInfo() {
        if GV.playingRecord.gameNumber != 0 {
            return
        }
        let records = helpInfo!.objects(HelpModel.self).filter("language = %@", GV.actLanguage)
        if records.count > 0 {
            try! helpInfo!.safeWrite() {
                helpInfo!.delete(records)
            }
        }
    }
//    var lastColIndex = NoValue
//    var lastRowIndex = NoValue
    
    private func saveHelpInfo(touchLocation: CGPoint = CGPoint(x:CGFloat(0), y:CGFloat(0)), touchedNodes: TouchedNodes = TouchedNodes(), calledFrom: CalledFrom = .start, undoButtonTouched: Bool=false, allWordsButtonTouched: Bool=false) {
        if GV.playingRecord.gameNumber != 0 {
            return
        }
        let records = helpInfo!.objects(HelpModel.self).filter("language = %@", GV.actLanguage).sorted(byKeyPath: "counter", ascending: true)
        var lastRecord = HelpModel()
        var counter = 0
        if records.count > 0 {
            lastRecord = records.last!
            counter = records.last!.counter
        }
        
        var bottomIndex = touchedNodes.shapeIndex
        var bottomPieceTouched = bottomIndex > NoValue
        var colIndex = touchedNodes.GCol
        var rowIndex = touchedNodes.GRow
        var onGameArray = true
        
        if bottomPieceTouched {
            if (touchLocation - pieceArray[bottomIndex].position).length() < blockSize {
                colIndex = NoValue
                rowIndex = NoValue
                onGameArray = false
            } else {
                colIndex = touchedNodes.col
                rowIndex = touchedNodes.row
                bottomPieceTouched = false
                bottomIndex = NoValue
            }
        }

        let helpModel = HelpModel()
        helpModel.combinedKey = GV.actLanguage + String(counter + 1)
        helpModel.language = GV.actLanguage
        helpModel.counter = counter + 1
        helpModel.typeOfTouch = calledFrom.rawValue
        helpModel.bottomPieceTouched = bottomPieceTouched
        helpModel.onGameArray = onGameArray
        helpModel.bottomIndex = bottomIndex
        helpModel.colIndex = colIndex
        helpModel.rowIndex = rowIndex
        helpModel.undoButtonTouched = undoButtonTouched
        helpModel.allWordsButtonTouched = allWordsButtonTouched
        if undoButtonTouched || allWordsButtonTouched || calledFrom != CalledFrom.move || (calledFrom == CalledFrom.move && (lastRecord.bottomPieceTouched != helpModel.bottomPieceTouched || lastRecord.bottomIndex != helpModel.bottomIndex || lastRecord.onGameArray != helpModel.onGameArray || lastRecord.colIndex != helpModel.colIndex || lastRecord.rowIndex != helpModel.rowIndex)) {
            print("helpModel: language: \(helpModel.language), counter: \(helpModel.counter), typeOfTouch: \(helpModel.typeOfTouch), bottomPieceTouched:\(helpModel.bottomPieceTouched), onGameArray:\(onGameArray), bottomIndex: \(bottomIndex), colIndex: \(colIndex), rowIndex: \(rowIndex),  ")

            try! helpInfo!.safeWrite() {
                helpInfo!.add(helpModel)
            }
        }
    }
    private func saveArrayOfPieces() {
        tilesForGame.removeAll()
        let piecesToPlay = GV.playingRecord.pieces.components(separatedBy: "°")
        for index in 0..<piecesToPlay.count {
            let piece = piecesToPlay[index]
            if piece.count > 0 {
                let tile = WTPiece(from: piece, parent: self, blockSize: blockSize, arrayIndex: index)
                tilesForGame.append(tile)
                tilesForGame.last!.addArrayIndex(index: index)
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
            let pieces = generateArrayOfWordPieces(first: true)
             try! realm.safeWrite() {
                GV.playingRecord.pieces = pieces
            }
       }
       saveArrayOfPieces()
    }
    
    private func getNextPiece(horizontalPosition: Int)->WTPiece {
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
        }
    }
    
    var firstTouchedCol = 0
    var firstTouchedRow = 0
    
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
//        if touchedNodes.gameFinishedOKButton {
//            wtGameFinishedSprite.OKButtonPressed()
//        }
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
        } else if touchedNodes.GCol.between(min: 0, max: GV.sizeOfGrid - 1) && touchedNodes.GRow.between(min:0, max: GV.sizeOfGrid - 1){
            inChoosingOwnWord = true
            wtGameboard?.startChooseOwnWord(col: touchedNodes.GCol, row: touchedNodes.GRow)
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
        } else if moved {
            let sprite = pieceArray[movedIndex]
            sprite.position = touchLocation + CGPoint(x: 0, y: blockSize * WSGameboardSizeMultiplier)
            sprite.alpha = 0.0
            if wtGameboard!.moveSpriteOnGameboard(col: touchedNodes.col, row: touchedNodes.row, GRow: touchedNodes.GRow) {  // true says moving finished
                if touchedNodes.row == GV.sizeOfGrid { // when at bottom
                    sprite.alpha = 1.0
                }
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
            }
        } else  {
            if touchedNodes.shapeIndex >= 0 {
                pieceArray[touchedNodes.shapeIndex].position = touchLocation
            }
            let yDistance = (touchLocation - firstTouchLocation).y
            if yDistance > blockSize / 2 && touchedNodes.row >= 0 && touchedNodes.row < GV.sizeOfGrid {
                if touchedNodes.shapeIndex >= 0 {
                    moved = wtGameboard!.startShowingSpriteOnGameboard(shape: pieceArray[touchedNodes.shapeIndex], col: touchedNodes.col, row: touchedNodes.row) //, shapePos: touchedNodes.shapeIndex)
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
        #if HELPGEN
        saveHelpInfo(touchLocation: touchLocation, touchedNodes: touchedNodes, calledFrom: calledFrom)
        #endif
        return touchedNodes
    }
    let answer1Name = "Answer1"
    let answer2Name = "Answer2"
    let MyQuestionName = "MyQuestion"

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
        let lastPosition = pieceArray.count - 1
//        let nodes1 = self.nodes(at: CGPoint(x: touchLocation.x, y: touchLocation.y + blockSize * 0.11))
        let touchedNodes = analyzeNodes(touchLocation: touchLocation, calledFrom: .stop)
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
                    saveToRealmCloud()
                }
            }
        } else if moved {
            for piece in pieceArray {
                piece.zPosition = 1
            }
            let fixed = wtGameboard!.stopShowingSpriteOnGameboard(col: touchedNodes.col, row: touchedNodes.row, fromBottom: true)
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
//                if activityRoundItem.count > 0 {
//                    if activityRoundItem.last!.activityItems.count == 0 {
//                        activityRoundItem[activityRoundItem.count - 1].activityItems = [ActivityItem]()
//                    }
//                } else {
//                    activityRoundItem.append(ActivityRound())
//                    activityRoundItem[activityRoundItem.count - 1].activityItems = [ActivityItem]()
//                }
                activityRoundItem[activityRoundItem.count - 1].activityItems.append(activityItem)
//                activityItems.append(activityItem)
                createUndo(enabled: true)
//                undoSprite.alpha = 1.0
//                let fixedName = "Pos\(movedIndex)"
//                removeNodesWith(name: fixedName)
                if movedIndex < lastPosition {
                    for index in movedIndex..<lastPosition {
                        pieceArray[index] = pieceArray[index + 1]
                        removeNodesWith(name: "Pos\(String(index + 1))")
                        pieceArray[index].name = "Pos\(String(index))"
                        pieceArray[index].position = origPosition[index]
                        pieceArray[index].setPieceFromPosition(index: index)
                        origSize[index] = pieceArray[index].size
                        self.addChild(pieceArray[index])
                    }
                }
                pieceArray[lastPosition] = getNextPiece(horizontalPosition: lastPosition)
                pieceArray[lastPosition].position = origPosition[lastPosition]
                pieceArray[lastPosition].name = "Pos\(lastPosition)"
                pieceArray[lastPosition].setPieceFromPosition(index: lastPosition)
                removeNodesWith(name: pieceArray[lastPosition].name!)
                self.addChild(pieceArray[lastPosition])
                
               saveActualState()
            } else {
                pieceArray[movedIndex].position = origPosition[movedIndex]
//                pieceArray[movedIndex].scale(to: origSize[movedIndex])
                pieceArray[movedIndex].alpha = 1
            }
            moved = false
        } else if self.nodes(at: touchLocation).count > 0 {
            if touchedNodes.shapeIndex >= 0 && startShapeIndex == touchedNodes.shapeIndex {
                    pieceArray[touchedNodes.shapeIndex].rotate()
                    pieceArray[touchedNodes.shapeIndex].position = origPosition[touchedNodes.shapeIndex]
            } else {
                if !goBackButton!.isEnabled {
                    self.hideButtons(hide: false)
                }
            }
        }
//        let freePlaceFound = checkFreePlace(showAlert: true)
        
        //                checkIfGameFinished()

        startShapeIndex = -1
        _ = checkFreePlace(showAlert: true)
        checkIfGameFinished()
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
//        if !self.checkFreePlace(showAlert: false) {
//            self.showGameFinished(status: .NoMoreSteps)
//        } else {
            actRound = GV.playingRecord.rounds.count + 1
            createNextRound = true
//            try! realm.safeWrite() {
//                GV.playingRecord.rounds.last!.roundScore = roundScore
//                let newRound = RoundDataModel()
//                //                newRound.index = activityItems.count - 1
//                newRound.gameArray = self.wtGameboard!.gameArrayToString()
//                GV.playingRecord.rounds.append(newRound)
//                self.timeForGame.incrementMaxTime(value: iHalfHour)
//                WTGameWordList.shared.addNewRound()
//                self.activityRoundItem.append(ActivityRound())
//                self.activityRoundItem[self.activityRoundItem.count - 1].activityItems = [ActivityItem]()
//            }
//         }
        self.enabled = true
        self.gameboardEnabled = false
        self.removeNodesWith(name: self.MyQuestionName)
        self.removeNodesWith(name: self.answer2Name)
    }

    private func getSyncedRecords() {
        if realmSync != nil {
            let gameNumber = GV.playingRecord.gameNumber % 1000 + 1
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
        if GV.debug {
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
    private func checkIfGameFinished() {
//        if GV.allMandatoryWordsFounded() {
        if WTGameWordList.shared.gameFinished() {
            if !goOnPlaying {
                congratulations()
                saveToRealmCloud()
            }
        } else {
            if goOnPlaying {
                self.saveToRealmCloud()
                finishButton!.isHidden = true
                goOnPlaying = false
                try! realm.safeWrite() {
                    GV.playingRecord.gameStatus = GV.GameStatusPlaying
                }
            }
        }
    }
    
    var goOnPlaying = false
    
    private func congratulations() {
        finishButton!.isHidden = false
        let title = GV.language.getText(.tcCongratulations1)
        let message = GV.language.getText(.tcCongratulations2)
        let continueTitle = GV.language.getText(.tcContinuePlaying)
        let finishTitle = GV.language.getText(.tcFinishGame)
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let continueAction =  UIAlertAction(title: continueTitle, style: .default, handler: {alert -> Void in
            self.gameboardEnabled = true
            self.goOnPlaying = true
//            self.saveHelpInfo(touchLocation:)
            try! realm.safeWrite() {
                GV.playingRecord.gameStatus = GV.GameStatusContinued
            }
        })
        let finishAction =  UIAlertAction(title: finishTitle, style: .default, handler: {alert -> Void in
            self.gameboardEnabled = true
            self.finishButtonTapped()
            self.saveToRealmCloud()
        })
        alertController.addAction(continueAction)
        alertController.addAction(finishAction)
 //        let subViewPosition = UIAlertController.subviews[0].view.frame
        self.parentViewController!.present(alertController, animated: true, completion: nil)
    }
    
    private func showGameFinished(status: GameFinishedStatus) {

        if bestScoreForActualGame != nil && bestScoreForActualGame!.count > 0 && bestPlayersReady {
            let bestName = bestScoreForActualGame![0].owner!.nickName
            let bestScore = bestScoreForActualGame![0].bestScore
            let bestScoretext = GV.language.getText(.tcBestScoreHeader, values: String(bestScore).fixLength(length:6), bestName!)
            let bestScorelabel = self.childNode(withName: bestScoreName) as? SKLabelNode
            bestScorelabel!.text = bestScoretext
        }
        var title = ""
        var message = ""
        var action1Title = ""
        let action2Title = GV.language.getText(.tcBack)
        if status == .OK {
            title = GV.language.getText(.tcGameFinished1)
            message = GV.language.getText(.tcGameFinished2)
            action1Title = GV.language.getText(.tcFinishGame)
        } else {
            title = GV.language.getText(.tcTaskNotCompletedWithNoMoreSteps)
            message = GV.language.getText(.tcWillBeRestarted)
            action1Title = GV.language.getText(.tcRestartGame)
        }
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action1 =  UIAlertAction(title: action1Title, style: .default, handler: {alert -> Void in
            self.gameboardEnabled = true
            if status == .OK {
                try! realm.safeWrite() {
                    GV.playingRecord.gameStatus = GV.GameStatusFinished
                }
                self.startNewGame()
            } else {
                self.restartThisGame()
            }
        })
        let action2 =  UIAlertAction(title: action2Title, style: .default, handler: {alert -> Void in
            self.gameboardEnabled = true
        })
        alertController.addAction(action1)
        alertController.addAction(action2)
        self.parentViewController!.present(alertController, animated: true, completion: nil)
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
                let answer1Action =  UIAlertAction(title: GV.language.getText(.tcBack), style: .default, handler: {alert -> Void in
                    self.startUndo()
                })
                let answer2Action = UIAlertAction(title: GV.language.getText(.tcNoMoreStepsAnswer2), style: .default, handler: {alert -> Void in
                    self.stopShowingTableIfNeeded()
                    self.startNextRound()
                    self.modifyHeader()
                })
                let answer3Action = UIAlertAction(title: GV.language.getText(.tcNoMoreStepsAnswer3), style: .default, handler: {alert -> Void in
                })
                let alertController = UIAlertController(title: GV.language.getText(.tcNoMoreStepsQuestion1),
                                                        message: "", //GV.language.getText(.tcNoMoreStepsQuestion2),
                                                        preferredStyle: .alert)
                alertController.addAction(answer1Action)
                alertController.addAction(answer2Action)
                alertController.addAction(answer3Action)
                self.parentViewController!.present(alertController, animated: true, completion: nil)
            } else {
                showGameFinished(status: .NoMoreSteps)
            }
        }
        return placeFound
    }
    
    private func removeNodesWith(name: String) {
        while self.childNode(withName: name) != nil {
            self.childNode(withName: name)!.removeFromParent()
        }
    }
    var actRound = 1
    
    private func startUndo() {
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
        func restartGame() {
            let gameNumber = GV.playingRecord.gameNumber
            let recordToDelete = realm.objects(GameDataModel.self).filter("language = %@ and gameNumber = %d", GV.actLanguage, gameNumber)
            if recordToDelete.count == 1 {
                try! realm.safeWrite() {
                    realm.delete(recordToDelete)
                }
            }
            tilesForGame = [WTPiece]()
            indexOfTilesForGame = 0
            createPlayingRecord(gameNumber: gameNumber)
            generateArrayOfWordPieces(new: new)
            restoreGameArray()
            createUndo(enabled: false)
        }
        #if HELPGEN
            saveHelpInfo(undoButtonTouched:true)
        #endif
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
                        self.addChild(pieceArray[0])
                    case 1:
                        movePieceToPosition(from: pieceArray[1], to: 2, remove: true)
                        movePieceToPosition(from: tileForGame, to: 1)
                        tileForGame.alpha = 1.0
                        removeNodesWith(name: pieceArray[1].name!)
                        self.addChild(pieceArray[1])
                    case 2:
                        movePieceToPosition(from: tileForGame, to: 2, remove: true)
                        tileForGame.alpha = 1.0
                        removeNodesWith(name: pieceArray[2].name!)
                        self.addChild(pieceArray[2])
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
            #if HELPGEN
            resetHelpInfo()
            #endif
            undoButton!.alpha = 0.2
            undoButton!.isEnabled = false
            wtGameboard!.clearGameArray()
        }
            
    }
    
    func restoreGameArray() {
        func addPieceAsChild(pieceIndex: Int, piece: WTPiece) {
            pieceArray[pieceIndex] = piece
            pieceArray[pieceIndex].position = origPosition[pieceIndex]
            origSize[pieceIndex] = piece.size
            pieceArray[pieceIndex].name = "Pos\(pieceIndex)"
            removeNodesWith(name: "Pos\(pieceIndex)")             // remove the piece from this position, if exists
            self.addChild(pieceArray[pieceIndex])
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
        if activityRoundItem[0].activityItems.count > 0 {
//            undoSprite.alpha = 1.0
            createUndo(enabled: true)
        }
        timeForGame = TimeForGame(from: GV.playingRecord.time)
//        wtGameboard!.checkWholeWords()
    }
    
    private func generateArrayOfWordPieces(first: Bool)->String {
        let random = MyRandom(gameNumber: GV.playingRecord.gameNumber, modifier: GV.playingRecord.words.count)
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
            var inputWord = word.uppercased()
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
                if newIndex == tilesForGame.count || !first || usedWords.count > 6 || GV.playingRecord.gameNumber == 0 {
                    tilesForGame.append(tileForGameItem)
                } else {
                    tilesForGame.insert(tileForGameItem, at: newIndex)
                }

            } while inputWord.length > 0
        }
        if first {
            let actRecord = realmMandatory.objects(MandatoryModel.self).filter("combinedKey = %d", GV.actLanguage + String(GV.playingRecord.gameNumber))[0]
            let words = actRecord.mandatoryWords.components(separatedBy: itemSeparator)
            for word in words {
//                print(word)
                splittingWord(word: word)
            }
            
        } else {
            for word in usedWords {
                for letter in word.uppercased() {
                    letterCounters[String(letter)]! += 1
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
                index += 1
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

    
//    func searchLetter(letter: String) {
//        for tile in tilesForGame {
//            if tile.letters.contains(where: {$0 == letter}) {
//                print("index: \(tile.arrayIndex), letters: \(tile.letters)")
//            }
//        }
//    }
//    
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
        self.scene?.alpha = 0.2
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
                if GV.gameArray[col][row].status == .wholeWord {
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

