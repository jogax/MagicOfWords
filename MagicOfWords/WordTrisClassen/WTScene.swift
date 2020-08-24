//
//  CollectWordsScene.swift
//  MagicOfWords
//
//  Created by Jozsef Romhanyi on 06/02/2018.
//  Copyright © 2018 Jozsef Romhanyi. All rights reserved.
//

import CloudKit
import Foundation
import GameplayKit
import RealmSwift
import GameKit
import AVFoundation


public enum StartType: Int {
    case NoMore = 0, PreviousGame, NextGame, NewGame, GameNumber, SetEasy, SetMedium
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
var wtGameboard: WTGameboard?

var bgSprite: SKSpriteNode?


class WTScene: SKScene, WTGameboardDelegate, WTGameWordListDelegate, WTTableViewDelegate {
    var bonusForReportProLetter:Int = 1000

    func blinkWords(newWord: SelectedWord, foundedWord: SelectedWord = SelectedWord()) {
        var longWaitAction = SKAction.wait(forDuration: 0.0)
        let duration = 0.3
        for (letterIndex, letter) in newWord.usedLetters.enumerated() {
            let myNode = GV.gameArray[letter.col][letter.row]
            let showRedAction = SKAction.run({
                myNode.setStatus(toStatus: .Error)
            })
            let waitAction = SKAction.wait(forDuration: duration)
            let showOrigAction = SKAction.run({
//                myNode.setColorByState()
                myNode.setStatus(toStatus: .OrigStatus)
            })
            var sequence = [SKAction]()
            for index in 1...3 {
                sequence.append(showRedAction)
                sequence.append(waitAction)
                sequence.append(showOrigAction)
                sequence.append(waitAction)
                if index == 3 && foundedWord.usedLetters.count == 0 && letterIndex == newWord.usedLetters.count - 1 {
//                    when a missing word, after last action, open a dialog "do you want to send this word..."
                    let alertAction = SKAction.run({
                        GV.wordToSend = newWord.word.lowercased()
                        let title = GV.language.getText(.tcShouldReport, values: newWord.word)
                        var multiplier = 0
                        for i in 1...newWord.word.count {
                            multiplier += i
                        }
                        let reportedWord = realm.objects(MyReportedWords.self).filter("word = %@", GV.actLanguage + GV.wordToSend)
                        if reportedWord.count == 0 {
                            let myReportedWord = MyReportedWords()
                            myReportedWord.ID = String(GV.getTimeIntervalSince20190101())
                            myReportedWord.word = GV.actLanguage + GV.wordToSend
                            myReportedWord.counter = 1
                            myReportedWord.status = GV.waiting
                            myReportedWord.modifiedAt = Date()
                            try! realm.safeWrite() {
                                realm.add(myReportedWord)
                            }
                            return
                        } else if reportedWord[0].counter == 1 {
                            try! realm.safeWrite() {
                                reportedWord[0].counter = 2
                                reportedWord[0].modifiedAt = Date()
                            }
                            return
                        } else if reportedWord[0].counter == 2 && reportedWord[0].status != GV.waiting  {
                            return
                        } else {
                            GV.wordToSend = newWord.word.lowercased()
                            GV.bonusForReport = multiplier * self.bonusForReportProLetter
                            let message = GV.language.getText(.tcReportDescription, values: String(GV.bonusForReport))
                            let myAlert = MyAlertController(title: title, message: message, target: self, type: .White)
                            myAlert.addAction(text: GV.language.getText(.tcYes), action: #selector(self.sendWordToCloud))
                            myAlert.addAction(text: GV.language.getText(.tcCancel), action: #selector(self.deleteFromRealm))
                            myAlert.presentAlert()
                            bgSprite!.addChild(myAlert)
                        }
                    })
                    sequence.append(alertAction)
                }

            }
            GV.blinkingNodes.append(myNode)
            GV.countBlinkingNodes += 1
            myNode.run(SKAction.sequence(sequence), withKey: "RedBlink")
        }
        longWaitAction = SKAction.wait(forDuration: 3 * 2 * duration)
        for letter in foundedWord.usedLetters {
            let myNode = GV.gameArray[letter.col][letter.row]
            let showGreenAction = SKAction.run({
                myNode.setStatus(toStatus: .DarkGreenStatus)
            })
            let waitAction = SKAction.wait(forDuration: duration)
            let showOrigAction = SKAction.run({
//                myNode.setColorByState()
                myNode.setStatus(toStatus: .OrigStatus)
            })
            var sequence = [SKAction]()
            sequence.append(longWaitAction)
            for _ in 1...3 {
                sequence.append(showGreenAction)
                sequence.append(waitAction)
                sequence.append(showOrigAction)
                sequence.append(waitAction)
            }
            myNode.run(SKAction.sequence(sequence), withKey: "GreenBlink")
        }

    }
    
    @objc private func sendWordToCloud() {
//        check if word is reported
        let realm: Realm = try! Realm(configuration: Realm.Configuration.defaultConfiguration)
        let reportedWord = realm.objects(MyReportedWords.self).filter("word = %@", GV.actLanguage + GV.wordToSend)
        if reportedWord.count == 0 || reportedWord[0].status != GV.waiting {
            return
        }
        try! realm.safeWrite() {
            reportedWord[0].status = GV.pending
            reportedWord[0].bonus = GV.bonusForReport
            reportedWord[0].modifiedAt = Date()
        }
        let myContainer = CKContainer.default()
        let publicDatabase = myContainer.publicCloudDatabase
        let newWordsRecordID = CKRecord.ID(recordName: reportedWord[0].ID)
        let newWordsRecord = CKRecord(recordType: "NewWords", recordID: newWordsRecordID)
        newWordsRecord["language"] = GV.actLanguage
        newWordsRecord["word"] = GV.wordToSend
        newWordsRecord["status"] = GV.pending // accepted - OK, declined - not OK
        publicDatabase.save(newWordsRecord) {
            (record, error) in
            if let error = error {
                // Insert error handling
                print("Error by save in WTScene1: \(error)")
                return
            }
            let title = GV.language.getText(.tcWordReportedTitle)
            let message = GV.language.getText(.tcWordReportedMessage)
            let myAlert = MyAlertController(title: title, message: message, target: self, type: .White)
            myAlert.addAction(text: GV.language.getText(.tcOK), action: #selector(self.noOperation))
            myAlert.presentAlert()
            bgSprite!.addChild(myAlert)

        }
        GV.wordToSend = ""
    }
    
    @objc private func deleteFromRealm() {
        let realm: Realm = try! Realm(configuration: Realm.Configuration.defaultConfiguration)
        let reportedWord = realm.objects(MyReportedWords.self).filter("word = %@", GV.actLanguage + GV.wordToSend)
        if reportedWord.count == 0 || reportedWord[0].status != GV.waiting {
            return
        }
        try! realm.safeWrite {
            realm.delete(reportedWord[0])
        }
        GV.wordToSend = ""
    }
    
    @objc private func noOperation() {
        
    }
    

    func setLettersMoved(fromLetters: [UsedLetter], toLetters: [UsedLetter]) {
        let movingItem = MovingItem(fromLetters: fromLetters, toLetters: toLetters)
        let activityItem = ActivityItem(type: .Moving, movingItem: movingItem)
        activityRoundItem[activityRoundItem.count - 1].activityItems.append(activityItem)
        //        activityItems.append(activityItem)
        saveActualState()
    }
    
    public class var shared: WTScene {
        struct Static {
            static let instance = WTScene()
        }
        return Static.instance
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
        lengthOfWord = globalMaxLength < fixlength ? fixlength : globalMaxLength
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
        lengthOfLength = text3.length + (showCount ? 0 : 4)
        lengthOfScore = text4.length
//        lengthOfMin = text5.length
    }
    
    let myLightBlue = UIColor(red: 204/255, green: 255/255, blue: 255/255, alpha: 1.0)
    let myLightBlue1 = UIColor(red: 204/255, green: 202/255, blue: 255/255, alpha: 1.0)

    func fillHeaderView(tableView: UITableView, section: Int) -> UIView {
        let textColor:UIColor = .black
        var text: String = ""
        var text0: String = ""
        let lineHeight = title.height(font: myFont!)
        let yPos0: CGFloat = 0
        var yPos1: CGFloat = 0
        var yPos2: CGFloat = lineHeight
        let view = UIView()
        var width:CGFloat = title.width(font: myFont!)
        var length: Int = 0
        let widthOfChar = "A".width(font: myFont!)
        let lengthOfTableView = Int(tableView.frame.width / widthOfChar) + 1
        switch tableType {
        case .ShowAllWords:
            let suffix = " (\(GV.countOfWords)/\(ownWordsForShow!.countWords)/\(ownWordsForShow!.score))"
            text = (GV.language.getText(.tcCollectedOwnWords) + suffix).fixLength(length: lengthOfTableView, center: true)
            if text.width(font: myFont!) > width {
                width = text.width(font: myFont!)
            }
        case .ShowWordsOverPosition:
            text = GV.language.getText(.tcWordsOverLetter, values: GV.actLetter).fixLength(length: title.length, center: true)
        case .ShowFoundedWords:
            let header0 = GV.language.getText(.tcSearchingWord, values: searchingWord)
            let header1 = GV.language.getText(.tcShowWordlistHeader, values: String(listOfFoundedWords.count))
            (width, length) = calculateTableViewWidth(header0: header0, header1: header1, header2: title)
            let optimalLength = Int(tableView.frame.width / "A".width(font: myFont!))
            length = length < optimalLength ? optimalLength : length
            text = header1.fixLength(length: length, center: true)
            text0 = header0.fixLength(length: length, center: true)
        case .ShowHints:
            let length = Int(tableView.frame.width / "W".width(font: myFont!))
            text = hintHeaderLine.fixLength(length: length + 4, center: true)
            if title.length < text.length {
                width = text.width(font: myFont!)
            }
        default:
            break
        }
        if tableType == .ShowFoundedWords {
             let label0 = UILabel(frame: CGRect(x: 0, y: yPos0, width: width, height: lineHeight))
            label0.font = myFont!
            label0.text = text0
            label0.textColor = .black
            yPos1 = lineHeight
            yPos2 = 2 * lineHeight
            view.addSubview(label0)
        }
        let label1 = UILabel(frame: CGRect(x: 0, y: yPos1, width: width, height: lineHeight))
        label1.font = myFont!
        label1.text = text
        label1.textColor = textColor
        view.addSubview(label1)
        let label2 = UILabel(frame: CGRect(x: 0, y: yPos2, width: width, height: lineHeight))
        label2.font = myFont!
        label2.text = title
        label2.textColor = textColor
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

    
    public func getTableViewCell(tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
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
            let wordForShow = ownWordsForShow!.words[indexPath.row]
            cell.addColumn(text: "  " + wordForShow.word.fixLength(length: lengthOfWord, leadingBlanks: false)) // WordColumn
            cell.addColumn(text: String(wordForShow.counter).fixLength(length: lengthOfCnt), color: color) // Counter column
            cell.addColumn(text: String(wordForShow.word.length).fixLength(length: lengthOfLength))
            cell.addColumn(text: String(wordForShow.score).fixLength(length: lengthOfScore), color: color) // Score column
        case .ShowWordsOverPosition:
            cell.addColumn(text: "  " + wordList[indexPath.row].word.fixLength(length: lengthOfWord + 2, leadingBlanks: false)) // WordColumn
            cell.addColumn(text: String(1).fixLength(length: lengthOfCnt - 1), color: color)
            cell.addColumn(text: String(wordList[indexPath.row].word.length).fixLength(length: lengthOfLength - 1))
            cell.addColumn(text: String(wordList[indexPath.row].score).fixLength(length: lengthOfScore + 1), color: color)
//            cell.addColumn(text: "+\(WTGameWordList.shared.getMinutesForWord(word: wordList[indexPath.row].word))".fixLength(length: lengthOfMin - 1))
        case .ShowFoundedWords:
            cell.addColumn(text: "  " + listOfFoundedWords[indexPath.row].word.uppercased().fixLength(length: lengthOfWord, leadingBlanks: false), color: myLightBlue)
            cell.addColumn(text: String(listOfFoundedWords[indexPath.row].length).fixLength(length: lengthOfLength), color: myLightBlue)
            cell.addColumn(text: String(listOfFoundedWords[indexPath.row].score).fixLength(length: lengthOfScore), color: myLightBlue)
            let restLength = Int(tableView.frame.width / "A".width(font:myFont!)) - lengthOfWord - lengthOfLength - lengthOfScore
            let spaces = " "
            cell.addColumn(text: spaces.fixLength(length: restLength), color: myLightBlue)
        case .ShowHints:
            var actColor = UIColor.white
            let item = hintsTableForShow[indexPath.row]
            switch item.type {
            case .WithFixLetter: actColor = UIColor(red: 248/255, green: 209/255, blue: 255/255, alpha: 1.0)
            case .WithRedLetter: actColor = UIColor(red: 242/255, green: 170/255, blue: 159/255, alpha: 1.0)
            case .WithGreenLetter: actColor = UIColor(red: 153/255, green: 249/255, blue: 114/255, alpha: 1.0)
            }
            cell.addColumn(text: "   " + item.hint.fixLength(length: lengthOfWord, leadingBlanks: false), color: actColor)
            let lengthText = "\(item.hint.count) (\(item.count))"
            cell.addColumn(text: lengthText.fixLength(length: lengthOfLength), color: actColor)
            cell.addColumn(text: String(item.score).fixLength(length: lengthOfScore), color: actColor)
            let restLength = Int(tableView.frame.width / "A".width(font:myFont!)) - lengthOfWord - lengthOfLength - lengthOfScore
            let spaces = " "
            cell.addColumn(text: spaces.fixLength(length: restLength), color: actColor)
        default:
            break
        }
        return cell
    }
    
    func getNumberOfSections() -> Int {
        return 1
//        switch tableType {
//        case .ShowAllWords:
//            return 2
//        case .ShowWordsOverPosition:
//            return 1
//        case .ShowFoundedWords:
//            return 1
//        case .None:
//            return 0
//        }
    }
    
    func getHeightForRow(tableView: UITableView, indexPath: IndexPath)->CGFloat {
        return title.height(font: myFont!)
    }
    
    func getNumberOfRowsInSections(section: Int)->Int {
        switch tableType {
        case .ShowAllWords:
            return WTGameWordList.shared.getCountWords()
//            switch section {
//            case 0: return WTGameWordList.shared.getCountWords(mandatory: true)
//            case 1: return WTGameWordList.shared.getCountWords(mandatory: false)
//            default: return 0
//            }
        case .ShowWordsOverPosition:
            return wordList.count
        case .ShowFoundedWords:
            return listOfFoundedWords.count
        case .ShowHints:
            return GV.hintTable.count
        default:
            return 0
        }
    }
    
    enum TableType: Int {
        case None = 0, ShowAllWords, ShowWordsOverPosition, ShowFoundedWords, ShowHints
    }
    
    let nameForSpriteWidthWords = "°°°nameForSpriteWidthWords°°°"
    var spriteToShowWords: SKSpriteNode?
    var tableType: TableType = .None
    var wordList = [SelectedWord]()
    var listOfFoundedWords = [LineOfFoundedWords]()
    var showWordsOverPositionTableView: WTTableView?
    var showFoundedWordsTableView: WTTableView?
    var parentViewController: UIViewController?
    

    func showScore(newWord: SelectedWord, minus: Bool = false, doAnimate: Bool) {
        if doAnimate {
            showWordAndScore(word: newWord, minus: minus)
        }
//        if changeTime != 0 {
//            timeForGame.incrementMaxTime(value: changeTime * 60)
//        }
//        if changeTime < 0 {
//            timeForGame.decrementMaxTime(value: changeTime * 60)
//        }
//        self.totalScore = totalScore
        showFoundedWords()
        return
    }
    
    private func showWordAndScore(word: SelectedWord, minus: Bool) {
        let fontSize = GV.onIpad ? self.frame.size.width * 0.02 : self.frame.size.width * 0.04
        let textOnBalloon = word.word + " (" + (minus ? "-" : "") + String(word.score) + ")"
//        let elite = GV.buttonType == GV.ButtonTypeElite
        let balloon = SKSpriteNode(imageNamed: "bubbleGoldElite")
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
        scoreLabel.text = String(word.score)
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
        let waitAction = SKAction.wait(forDuration: 0.1)
//        let movingAction = SKAction.move(to: CGPoint(x: self.frame.size.width * 0.5, y: endPosY), duration: 5.0)
        let scaleUpAction = SKAction.scale(by: 1.5, duration: 0.5)
        let scaleDownAction = SKAction.scale(to: 1.0, duration: 0.5)
        let fadeAway = SKAction.fadeOut(withDuration: 0.2)
        let removeNode = SKAction.removeFromParent()
        actions.append(SKAction.sequence([waitAction, scaleUpAction, scaleDownAction,
                                          scaleUpAction, scaleDownAction, scaleUpAction, scaleDownAction,
                                          fadeAway, removeNode/*movingAction*/]))
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
    }
    
    
    var wtSceneDelegate: WTSceneDelegate?
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
    var gameTypeLabel: MyLabel!
    var headerLabel: MyLabel!
    var versionLabel: MyLabel!
    var myWordsHeaderLabel: MyLabel!
    var myScoreHeaderLabel: MyLabel!
    var bestScoreHeaderLabel: MyLabel!
    var actScoreHeaderLabel: MyLabel!
    var scoreLabel: MyLabel!
    var goBackLabel: MyLabel!
    var goToPreviousGameLabel: MyLabel!
    var goToNextGameLabel: MyLabel!
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
//    var showHelp: Bool = false
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
//    let bonusHeaderName = "°°°bonusHeader°°°"
    let undoName = "°°°undo°°°"
    let goBackName = "°°°goBack°°°"
    let headerLine = "°°°header°°°"
    let versionLabelName = "°°°versionLabel°°°"
    let headerLineName = "°°°headerLine°°°"
    let myScoreName = "°°°myScore°°°"
    let myWordsName = "°°°myWords°°°"
    let gameTypeName = "°°°gameType°°°"
    let bestScoreName = "°°°bestScore°°°"
    let actScoreName = "°°°actScore°°°"
    let timeName = "°°°timeName°°°"
    let gameNumberName = "°°°gameNumber°°°"
    let previousName = "°°°previousGame°°°"
    let nextName = "°°°nextGame°°°"
    let myAlertName = "°°°myAlertName°°°"
//    let ownWordsBackgroundName = "°°°ownWordsBackgroundName°°°"
//    let ownWordsButtonName = "°°°ownWordsButtonName°°°"

    var timeIncreaseValues: [Int]?
    var movingSprite: Bool = false
//    var bgSprite: SKSpriteNode?
//    var wtGameWordList: WTGameWordList?

    
    override func didMove(to view: SKView) {
        GV.target = self
        GV.orientationHandler = #selector(didRotated)
        if GV.comeBackFromSleeping {
            GV.comeBackFromSleeping = false
            return
        }
//        wtGameWordList = WTGameWordList(delegate: self)
//        timeIncreaseValues = [0, 0, 0, 0, 0, 0, iFiveMinutes, iFiveMinutes, iTenMinutes, iTenMinutes, iQuarterHour]
        self.name = "WTScene"
        self.view!.isMultipleTouchEnabled = false
        self.view!.subviews.forEach { $0.removeFromSuperview() }
        self.blockSize = self.frame.size.width * (GV.onIpad ? 0.70 : 0.90) / CGFloat(12)
        self.tilesForGame.removeAll()
//        self.gameNumberForGenerating = GV.basicDataRecord.difficulty == GameDifficulty.Easy.rawValue ? GV.DemoEasyGameNumber : GV.DemoMediumGameNumber
        if self.children.count > 0 {
            for child in self.children {
                child.removeFromParent()
            }
        }
        bgSprite = SKSpriteNode()
//        bgSprite!.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
//        bgSprite!.color = bgColor
        self.addChild(bgSprite!)
        GV.totalScore = 0
//        GV.mandatoryScore = 0
        GV.ownScore = 0
        GV.countBlinkingNodes = 0
        inDefiningSearchingWord = false
        GV.blinkingNodes.removeAll()
        setBackground()
        getPlayingRecord(next: nextGame, gameNumber: newGameNumber)
        buttonHeight = GV.minSide * (GV.onIpad ? 0.08 : 0.125)
        buttonSize = CGSize(width: buttonHeight, height: buttonHeight)
        createUndo()
        createGoBackButton()
        createGoToPreviousGameButton(enabled: hasRecords(before: true))
        createGoToNextGameButton(enabled: hasRecords(before: false))
        createMusicOnOffButton()
        //        createTippButton()
        createAllWordsButton()
        createHintButton()
        createFinishButton()
        createSearchButton()
//        createDifficultyButtons(number: calculatePlace())
        createHeader()
        WTGameWordList.shared.clear()
        GCHelper.shared.getAllScores(completion: {
            [unowned self] in self.modifyHeader()
        })
//        searchWords(lettersToSearch: ["a", "b", "m", "a", "g", "l", "f", "a", "r"])
        play()
//        if new {
//            let easy = GV.basicDataRecord.difficulty == GameDifficulty.Easy.rawValue
//            let title = GV.language.getText(easy ? .tcChooseGoalForWords : .tcChooseGoalForLetters)
//            let message = GV.language.getText(easy ? .tcGoalMessageForWords : .tcGoalMessageForLetters)
//            let myAlert = MyAlertController(title: title, message: message, target: self, type: .Green)
//            if easy {
//                myAlert.addAction(text: "100", action: #selector(self.startEasy100))
//                myAlert.addAction(text: "250", action: #selector(self.startEasy250))
//                myAlert.addAction(text: "500", action: #selector(self.startEasy500))
//                myAlert.addAction(text: "750", action: #selector(self.startEasy750))
//                myAlert.addAction(text: "1000", action: #selector(self.startEasy1000))
//            } else {
//                myAlert.addAction(text: "50", action: #selector(self.startMedium50))
//                myAlert.addAction(text: "100", action: #selector(self.startMedium100))
//                myAlert.addAction(text: "150", action: #selector(self.startMedium150))
//                myAlert.addAction(text: "200", action: #selector(self.startMedium200))
//                myAlert.addAction(text: "250", action: #selector(self.startMedium250))
//            }
//            myAlert.presentAlert()
//            myAlert.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
//            myAlert.name = self.myAlertName
//            self.bgSprite!.addChild(myAlert)
//        }
   }
    
    @objc private func didRotated() {
        self.size = CGSize(width: GV.actWidth,height: GV.actHeight)
        self.view!.frame = CGRect(x: 0, y: 0, width: GV.actWidth, height: GV.actHeight)
        bgSprite!.size = self.size
        setBackground()
        bgSprite!.setPosAndSizeForAllChildren()
    }
    let BackgroundName = "BackgroundName"
    
    private func setBackground() {
        let background = SKSpriteNode(imageNamed: GV.actHeight > GV.actWidth ? "backgroundP" : "backgroundL")
        background.size = frame.size
        background.position = CGPoint(x: frame.midX, y: frame.midY)
        background.zPosition = -50
        background.nodeType = .Background
        background.name = BackgroundName
        removeChildrenWithTypes(from: bgSprite!, types: [.Background])
        bgSprite!.addChild(background)
    }
    private func setCountWords(count: Int, type: GameDifficulty) {
        try! realm.safeWrite() {
            if type == .Easy {
                GV.playingRecord.countOfWordsMaxValue = count
                GV.countOfWordsMaxValue = count
            } else {
                GV.playingRecord.countOfLettersMaxValue = count
                GV.countOfLettersMaxValue = count
            }
        }
        modifyHeader()
    }

    private func goBackToWTScene(start: StartType) {
        wtSceneDelegate!.gameFinished(start: start)
    }
    
    
    @objc func startNewGame() {
        goBackToWTScene(start: .NewGame)
    }
    
    let timeInitValue = "0°origMaxTime"
    func restartThisGame() {
        actRound = 1
        try! realm.safeWrite() {
            GV.playingRecord.pieces = ""
            GV.playingRecord.time = timeInitValue
            GV.playingRecord.rounds.removeAll()
            GV.playingRecord.gameStatus = GV.GameStatusNew
            GV.playingRecord.mandatoryWords = ""
        }
        goBackToWTScene(start: .NewGame)
        //        wtSceneDelegate!.gameFinished(start: .NewGame)
    }
    
    private func getPlayingRecord(next: StartType, gameNumber: Int/*, showHelp: Bool = false*/) {
        func setMandatoryWords() {
            if GV.playingRecord.mandatoryWords == "" {
                let mandatoryRecord: MandatoryModel? = realmMandatory.objects(MandatoryModel.self).filter("gameNumber = %d and language = %@", GV.playingRecord.gameNumber, GV.actLanguage).first!
                if mandatoryRecord != nil {
                    let components = mandatoryRecord!.mandatoryWords.components(separatedBy: itemSeparator)
                    var newString = ""
                    for index in 0...5 {
                        newString += components[index] + itemSeparator
                    }
                    newString.removeLast()
                    try! realm.safeWrite() {
                        GV.playingRecord.mandatoryWords = newString
                    }
                }
            }
        }
        
        let demoGames = realm.objects(GameDataModel.self).filter("language = %@ and gameNumber >= %d", GV.actLanguage, 9999)
        if demoGames.count > 0 {
            try! realm.safeWrite() {
                realm.delete(demoGames)
            }
        }
        
        let actGames = realm.objects(GameDataModel.self).filter("language = %@ and gameNumber >= %d and gameNumber <= %d", GV.actLanguage, GV.minGameNumber, GV.maxGameNumber).sorted(byKeyPath: "score", ascending: false)
        
        if actGames.count == 0 {
            new = true
        }
        let nowPlaying = actGames.filter("nowPlaying = true")
        if nowPlaying.count > 1 {
            for item in nowPlaying {
                if item.combinedKey != nowPlaying.last!.combinedKey {
                    try! realm.safeWrite() {
                        item.nowPlaying = false
                    }
                }
            }
        } else if nowPlaying.count == 0 && actGames.count > 0 {
            try! realm.safeWrite() {
                actGames.last!.nowPlaying = true
            }
        }

//        if showHelp {
//            if gameNumber >= gameNumberForGenerating {
//                let difficulty = GV.basicDataRecord.difficulty
//                if GV.generateHelpInfo {
//                    GV.helpInfoRecords = realmHelpInfo!.objects(HelpInfo.self).filter("language = %d and difficulty = %d", GV.actLanguage, difficulty).sorted(byKeyPath: "counter")
//                } else {
//                    GV.helpInfoRecords = realmHelp.objects(HelpInfo.self).filter("language = %d and difficulty = %d", GV.actLanguage, difficulty).sorted(byKeyPath: "counter")
//                }
//            }
//            createPlayingRecord(gameNumber: gameNumber)
//        } else if GV.generateHelpInfo && new {
//            deleteGameDataRecord(gameNumber: gameNumber)
//            createPlayingRecord(gameNumber: gameNumber)
//        } else
        if new {
            let emptyRecords = realm.objects(GameDataModel.self).filter("language = %@ and gameNumber >= %d and gameNumber <= %d and score = 0", GV.actLanguage, GV.minGameNumber, GV.maxGameNumber)
            if emptyRecords.count > 0 {
                try! realm.safeWrite() {
                    realm.delete(emptyRecords)
                }
            }
            let date = Date() // now
            let cal = Calendar.current
            let day = cal.ordinality(of: .day, in: .year, for: date)
            let random = MyRandom(gameNumber: 500, modifier: day! * 100 + GV.basicDataRecord.countPlaysToday)
            try! realm.safeWrite() {
                GV.basicDataRecord.countPlaysToday += 1
            }
            let gameNumber = random.getRandomInt(GV.minGameNumber, max: GV.maxGameNumber)
            createPlayingRecord(gameNumber: gameNumber)
            
        } else {
            if next == .PreviousGame && hasRecords(before: true) {
                for (index, game) in actGames.enumerated() {
                    if game.nowPlaying == true && index > 0 {
                        try! realm.safeWrite() {
                            game.nowPlaying = false
                            actGames[index - 1].nowPlaying = true
                            GV.playingRecord = actGames[index - 1]
                        }
                    }
                    
                }
            } else if next == .NextGame && hasRecords(before: false) {
                for (index, game) in actGames.enumerated() {
                    if game.nowPlaying == true && index + 1 < actGames.count {
                        try! realm.safeWrite() {
                            game.nowPlaying = false
                            actGames[index + 1].nowPlaying = true
                            GV.playingRecord = actGames[index + 1]
                        }
                        break
                    }
                }
            } else {
                GV.playingRecord = nowPlaying.last!
            }
            let sizeOfGrid: [Int:Int] = [0:10, 50:5, 72:6, 98:7, 128:8, 162:9, 200:10]
            if GV.playingRecord.rounds.count > 0 {
                GV.sizeOfGrid = sizeOfGrid[GV.playingRecord.rounds.first!.gameArray.count]!
            }
            try! realm.safeWrite() {
                if GV.playingRecord.countOfWordsMaxValue == 0 {
                    GV.playingRecord.countOfWordsMaxValue = 1000
                }
                if GV.playingRecord.countOfLettersMaxValue == 0 {
                    GV.playingRecord.countOfLettersMaxValue = 250
                }
            }
            GV.countOfWordsMaxValue = GV.playingRecord.countOfWordsMaxValue
            GV.countOfLettersMaxValue = GV.playingRecord.countOfLettersMaxValue
        }
        if GV.playingRecord.gameStatus == GV.GameStatusContinued {
            goOnPlaying = true
        }
        setMandatoryWords()
    }
    
    private func calculatePlace()->Int {
//        if showHelp {
//            return 1
//        }
        let actGames = realm.objects(GameDataModel.self).filter("language = %@ and gameNumber >= %d and gameNumber <= %d", GV.actLanguage, GV.minGameNumber, GV.maxGameNumber).sorted(byKeyPath: "score", ascending: false)
        for (index, record) in actGames.enumerated() {
            if record.combinedKey == GV.playingRecord.combinedKey {
                return index + 1
            }
        }
        return 0
    }
    
    private func createPlayingRecord(gameNumber: Int) {
        let gameNumberForMandatoryRecord = gameNumber % 1000
        let mandatoryRecord: MandatoryModel? = realmMandatory.objects(MandatoryModel.self).filter("gameNumber = %d and language = %@", gameNumberForMandatoryRecord, GV.actLanguage).first!
        if mandatoryRecord != nil {
            try! realm.safeWrite() {
                let oldRecords = realm.objects(GameDataModel.self).filter("language = %@ and gameNumber >= %d and gameNumber <= %d and nowPlaying = true", GV.actLanguage, GV.minGameNumber, GV.maxGameNumber)
                for oldRecord in oldRecords {
                    oldRecord.nowPlaying = false
                }
                let components = mandatoryRecord!.mandatoryWords.components(separatedBy: itemSeparator)
                var newString = ""
                for index in 0...5 {
                    newString += components[index] + itemSeparator
                }
                newString.removeLast()
                GV.playingRecord = GameDataModel()
                GV.playingRecord.combinedKey = Date().toString()//GV.actLanguage + String(gameNumber)
                GV.playingRecord.mandatoryWords = newString
                GV.playingRecord.gameNumber = gameNumber
                GV.playingRecord.language = GV.actLanguage
                GV.playingRecord.time = timeInitValue
                GV.playingRecord.nowPlaying = true
                realm.add(GV.playingRecord)
            }
        }
//        hideButtons(hide: false)
    }


    public func setDelegate(delegate: WTSceneDelegate) {
        wtSceneDelegate = delegate
    }
    
    public func setGameArt(new: Bool = false, next: StartType = .NoMore, gameNumber: Int = 0, restart: Bool/*, showHelp: Bool*/) {
        self.new = new
        self.nextGame = next
        self.newGameNumber = gameNumber
        self.restart = restart
    }
    

    let ownWordsLinePosition:CGFloat = 0.84
    let mandatoryWordsLinePosition:CGFloat = 0.82
    let buttonLineCenterY:CGFloat = 0.265
    let mybuttonLineCenterY:CGFloat = 1 - 0.265 // 1 - buttonLineCenterY
    let gameboardCenterY: CGFloat = GV.onIpad ? 0.43 : 0.46
    let pieceArrayCenterY: CGFloat = GV.onIpad ? 0.08 : 0.1
    let scoreLength: Int = 6
    
    private func createVersion() {

    }
    
    private func createHeader() {
        var widthMpx = CGFloat(0)
        var heightMpx = CGFloat(0)
        let lineAdderP = GV.maxSide * 0.02
        let lineAdderL = GV.minSide * 0.025
        let fontSize = GV.maxSide * 0.0175 // GV.onIpad ? self.frame.size.width * 0.02 : self.frame.size.width * 0.032
        if bgSprite!.childNode(withName: versionLabelName) == nil {
            let versionText = GV.language.getText(.tcActVersion, values: actVersion)
            widthMpx = GV.onIpad ? 0.02 : 0.02
            heightMpx = GV.onIpad ? 0.02 : 0.020
            let plPos = PLPosSize(PPos: CGPoint(x: GV.actWidth * widthMpx, y: GV.actHeight * heightMpx), LPos: CGPoint(x: GV.actWidth * widthMpx, y: GV.actHeight * heightMpx))
            versionLabel = MyLabel(text: versionText, position: plPos, fontName: GV.actLabelFont, fontSize: fontSize)
//            versionLabel.text = versionText
            versionLabel.name = String(versionLabelName)
//            versionLabel.fontSize = fontSize
//            versionLabel.position = CGPoint(x: self.frame.size.width * (GV.onIpad ? 0.0175 : 0.02), y: self.frame.size.height * (GV.onIpad ? 0.010 : 0.020))
            versionLabel.horizontalAlignmentMode = .left
            versionLabel.fontColor = SKColor(red: 0, green: 0, blue: 0, alpha: 0.5)
            bgSprite!.addChild(versionLabel)
        }
        
        if bgSprite!.childNode(withName: gameTypeName) == nil {
//            let gameTypeLinePosition:CGFloat = 0.93
            let pX: CGFloat = GV.minSide * 0.5
            let pY: CGFloat = GV.maxSide * (GV.deviceHasNotch ? 0.93 : 0.97)
            let lX: CGFloat = GV.maxSide * 0.25
            let lY: CGFloat = GV.minSide * (GV.deviceHasNotch ? 0.93 : 0.97)
            let plPos = PLPosSize(PPos: CGPoint(x: pX, y: pY), LPos: CGPoint(x: lX, y: lY))
            let text = GV.language.getText((GV.basicDataRecord.difficulty == GameDifficulty.Easy.rawValue ? .tcEasyPlay : .tcMediumPlay), values: "\(GV.sizeOfGrid)x\(GV.sizeOfGrid)")
            gameTypeLabel = MyLabel(text: text, position: plPos, fontName: GV.actLabelFont, fontSize: fontSize * 1.2)
            gameTypeLabel.name = gameTypeName
            gameTypeLabel.fontColor = .black
            gameTypeLabel.zPosition = self.zPosition + 10
            bgSprite!.addChild(gameTypeLabel)
        }

        let firstLineYP = (gameTypeLabel.plPosSize?.PPos.y)!
        let firstLineYL = (gameTypeLabel.plPosSize?.LPos.y)!

        if bgSprite!.childNode(withName: headerLine) == nil {
            let pX: CGFloat = GV.minSide * 0.5
            let pY: CGFloat = firstLineYP - lineAdderP
            let lX: CGFloat = GV.maxSide * 0.25
            let lY: CGFloat = firstLineYL - lineAdderL
            //            let gameNumber = GV.playingRecord.gameNumber >= GV.DemoEasyGameNumber ? "DEMO" : String(""/*GV.playingRecord.gameNumber % 1000 + 1*/)
            let text = GV.language.getText(.tcHeader, values: String(1), timeForGame.time.HourMinSec)
            let plPos = PLPosSize(PPos: CGPoint(x: pX, y: pY), LPos: CGPoint(x: lX, y: lY))
            headerLabel = MyLabel(text: text, position: plPos, fontName: GV.actLabelFont, fontSize: fontSize)
            headerLabel.name = String(headerLine)
            headerLabel.horizontalAlignmentMode = .center
            headerLabel.fontColor = .black
            bgSprite!.addChild(headerLabel)
        }
                
        let bestName = "nobody"
        let bestScore = 0
        
        if bgSprite!.childNode(withName: myWordsName) == nil {
//            let myWordsLinePosition: CGFloat = 0.90
            let pX: CGFloat = headerLabel.plPosSize!.PPos.x - headerLabel.frame.width / 2
            let pY: CGFloat = firstLineYP - 2 * lineAdderP
            let lX: CGFloat = headerLabel.plPosSize!.LPos.x - headerLabel.frame.width / 2
            let lY: CGFloat = firstLineYL - 2 * lineAdderL
            let plPos = PLPosSize(PPos: CGPoint(x: pX, y: pY), LPos: CGPoint(x: lX, y: lY))
//            let is1000Words = GV.basicDataRecord.difficulty == GameDifficulty.Easy.rawValue
            var text = ""
//            if is1000Words {
                text = GV.language.getText(.tcMyWordsHeader1000, values: String(GV.countOfWords), String(GV.countOfWordsMaxValue))
//            } else {
//                text = GV.language.getText(.tcMyWordsHeader250, values: String(GV.countOfLetters), String(GV.countOfLettersMaxValue))
//            }
            myWordsHeaderLabel = MyLabel(text: text, position: plPos, fontName: GV.actLabelFont, fontSize: fontSize)
            myWordsHeaderLabel.name = String(myWordsName)
            myWordsHeaderLabel.horizontalAlignmentMode = .left
            myWordsHeaderLabel.fontColor = SKColor.black
            bgSprite!.addChild(myWordsHeaderLabel)
        }
        

        if bgSprite!.childNode(withName: bestScoreName) == nil {
            let pX: CGFloat = headerLabel.plPosSize!.PPos.x - headerLabel.frame.width / 2
            let pY: CGFloat = firstLineYP - 3 * lineAdderP
            let lX: CGFloat = headerLabel.plPosSize!.LPos.x - headerLabel.frame.width / 2
            let lY: CGFloat = firstLineYL - 3 * lineAdderL
            let plPos = PLPosSize(PPos: CGPoint(x: pX, y: pY), LPos: CGPoint(x: lX, y: lY))
            let text = GV.language.getText(.tcBestScoreHeader, values: String(1).fixLength(length: 5), String(bestScore).fixLength(length:scoreLength), bestName)
//            bestScoreHeaderLabel = SKLabelNode(fontNamed: GV.actLabelFont) //"CourierNewPS-BoldMT")// Snell Roundhand")
            bestScoreHeaderLabel = MyLabel(text: text, position: plPos, fontName: GV.actLabelFont, fontSize: fontSize)
            bestScoreHeaderLabel.name = String(bestScoreName)
            bestScoreHeaderLabel.fontSize = fontSize
            bestScoreHeaderLabel.horizontalAlignmentMode = .left
            bestScoreHeaderLabel.fontColor = SKColor.black
            bgSprite!.addChild(bestScoreHeaderLabel)
        }
        
        if bgSprite!.childNode(withName: myScoreName) == nil {
//            let myScoreLinePosition:CGFloat = 0.86
            let pX: CGFloat = headerLabel.plPosSize!.PPos.x - headerLabel.frame.width / 2
            let pY: CGFloat = firstLineYP - 4 * lineAdderP
            let lX: CGFloat = headerLabel.plPosSize!.LPos.x - headerLabel.frame.width / 2
            let lY: CGFloat = firstLineYL - 4 * lineAdderL
            let plPos = PLPosSize(PPos: CGPoint(x: pX, y: pY), LPos: CGPoint(x: lX, y: lY))
            let text = GV.language.getText(.tcMyScoreHeader, values: String(GV.playingRecord.score).fixLength(length:scoreLength), GKLocalPlayer.local.alias)
            myScoreHeaderLabel = MyLabel(text: text, position: plPos, fontName: GV.actLabelFont, fontSize: fontSize)
            myScoreHeaderLabel.name = String(myScoreName)
            myScoreHeaderLabel.horizontalAlignmentMode = .left
            myScoreHeaderLabel.fontColor = SKColor.black
            bgSprite!.addChild(myScoreHeaderLabel)
        }
        
        bgSprite!.setPosAndSizeForAllChildren()
        
        modifyHeader()
   }

    public func modifyHeader() {
//        let gameNumber = (GV.playingRecord.gameNumber >= GV.DemoEasyGameNumber ? "DEMO" : String(""/*GV.playingRecord.gameNumber % 1000 + 1*/))
        let headerText = GV.language.getText(.tcHeader, values: String(actRound), timeForGame.time.HourMinSec)
        headerLabel.text = headerText
        let score = GV.totalScore
//        var myScore = 0
//        var bestScore = 0
//        var bestName = 0
//        var myRank = 0
        var (bestScore, bestName, myRank, _) = GV.basicDataRecord.getBestScore()
        let rank = score >= bestScore ? myRank : calculateRankForScore(score: score)
        // if bestscore in GC is my and < as my actual score, set bestscore to actualscore
        if bestName == GKLocalPlayer.local.alias && bestScore < score {
            bestScore = score
        }
        let bestScoreLength = String(bestScore).count
        let rankLength = String(rank).length
        let is1000Words = GV.basicDataRecord.difficulty == GameDifficulty.Easy.rawValue
        var myWordsText = ""
        if is1000Words {
            myWordsText = GV.language.getText(.tcMyWordsHeader1000, values: String(GV.countOfWords), String(GV.countOfWordsMaxValue))
        } else {
            myWordsText = GV.language.getText(.tcMyWordsHeader250, values: String(GV.countOfLetters), String(GV.countOfLettersMaxValue))
        }
        let scoreText = GV.language.getText(.tcMyScoreHeader, values: String(rank).fixLength(length: rankLength), String(score).fixLength(length:bestScoreLength), GKLocalPlayer.local.alias)
        let bestScoreText = GV.language.getText(.tcBestScoreHeader, values: String(1).fixLength(length: rankLength),String(bestScore).fixLength(length:bestScoreLength), bestName)
        myWordsHeaderLabel.text = myWordsText
        myScoreHeaderLabel.text = scoreText
        bestScoreHeaderLabel.text = bestScoreText
        let scoreWidth = scoreText.width(font: myFont!)
        let bestScoreWidth = bestScoreText.width(font: myFont!)
        let labelWidth = scoreWidth > bestScoreWidth ? scoreWidth : bestScoreWidth
        let myScoreNewPosition = CGPoint(x: self.frame.midX - labelWidth / 2, y: myScoreHeaderLabel.position.y)
        let bestScoreNewPosition = CGPoint(x: self.frame.midX - labelWidth / 2, y: bestScoreHeaderLabel.position.y)
        let myWordsNewPosition = CGPoint(x: self.frame.midX - labelWidth / 2, y: myWordsHeaderLabel.position.y)
        myScoreHeaderLabel.position = myScoreNewPosition
        bestScoreHeaderLabel.position = bestScoreNewPosition
        myWordsHeaderLabel.position = myWordsNewPosition
    }
    
    private func calculateRankForScore(score: Int)->Int {
        var lastRank = 0
        for (rank, actScore) in GV.scoreTable.enumerated()  {
            if score >= actScore {
                return rank + 1
            }
            lastRank = rank
        }
        return lastRank + 2
    }

    
    var headerCreated = false
    var createNextRound = false
    var oldHintsCreated = false
    var oldHintCount = 0
    
    
    override func update(_ currentTime: TimeInterval) {
        let duration = 0.1
        if createNextRound && GV.nextRoundAnimationFinished {
            afterNextRoundAnimation()
        }
        if hintButton != nil {
            let hintCount = GV.hintTable.count
            if oldHintCount != hintCount {
                hintButton!.setButtonLabel(title: String(hintCount), font: hintFont!)
                oldHintCount = hintCount
            }
            if oldHintsCreated != hintsCreated {
                if GV.hintTable.count > 0 {
                    hintButton!.alpha = 1.0
                    hintButton!.isEnabled = true
                }
                if hintsCreated {
                    if GV.hintTable.count > 0 {
                        let origPos = hintButton!.position
                        let jumpUpAction = SKAction.move(to: CGPoint(x: hintButton!.position.x, y: hintButton!.position.y + hintButton!.size.height / 2), duration: duration)
                        let waitAction = SKAction.wait(forDuration: 0.05)
                        let jumpDownAction = SKAction.move(to: origPos, duration: duration)
                        hintButton!.run(SKAction.sequence([jumpUpAction, waitAction, jumpDownAction]))
                    } else {
                        hintButton!.alpha = 0.2
                        hintButton!.isEnabled = false
                    }
                }
                oldHintsCreated = hintsCreated
            }
        }
//        if (hintsCreated || GV.hintTable.count > 0) {
//            hintButton!.alpha = 1.0
//            hintButton!.isEnabled = true
//        } else {
//            hintButton!.alpha = 0.2
//            hintButton!.isEnabled = false
//        }
    }
    
    private func afterNextRoundAnimation() {
        try! realm.safeWrite() {
            let roundScore = WTGameWordList.shared.getPointsForLetters()
            GV.playingRecord.rounds.last!.roundScore = roundScore
            let newRound = RoundDataModel()
            newRound.gameArray = wtGameboard!.gameArrayToString()
            GV.playingRecord.rounds.append(newRound)
            self.timeForGame.incrementMaxTime(value: iHalfHour)
            WTGameWordList.shared.addNewRound()
            self.activityRoundItem.append(ActivityRound())
            self.activityRoundItem[self.activityRoundItem.count - 1].activityItems = [ActivityItem]()
        }
        createFixLetters()
        
//        movePiecesToGameArray()
//        HintEngine.shared.createHints()
        createHintsInBackground()
        saveActualState()
        createNextRound = false
        GV.nextRoundAnimationFinished = false
    }
    

    func showFoundedWords() {
    }
    
    func addOwnWordNew(word: String, usedLetters: [UsedLetter])->Bool {
        let letter1 = "е" // cirillic "e"
        let letter2 = "ё" // cirillic "ё"
        let lowercasedWord = word.lowercased()
        var returnBool = false
        if realmWordList.objects(WordListModel.self).filter("word = %@", GV.actLanguage + lowercasedWord).count == 1 {
            let selectedWord = SelectedWord(word: word, usedLetters: usedLetters)
            let boolValue = WTGameWordList.shared.addWord(selectedWord: selectedWord, doAnimate: true, round: GV.playingRecord.rounds.count)
            returnBool = boolValue
        } else if realm.objects(WordsFromCloud.self).filter("word = %@", GV.actLanguage + lowercasedWord).count == 1 {
            let selectedWord = SelectedWord(word: word, usedLetters: usedLetters)
            let boolValue = WTGameWordList.shared.addWord(selectedWord: selectedWord, doAnimate: true, round: GV.playingRecord.rounds.count)
            returnBool = boolValue
        } else if GV.actLanguage == "ru" && lowercasedWord.firstIndex(where: {$0 == "е"}) != nil {
            for (index, char) in lowercasedWord.enumerated() {
                var newWord = ""
                if String(char) == letter1 {
                    if index == 0 {
                        newWord = letter2 + lowercasedWord.subString(at: index + 1, length: word.length - index - 1)
                    } else {
                        newWord = lowercasedWord.subString(at:0, length: index) + letter2 + lowercasedWord.subString(at:index + 1, length: word.length - index - 1)
                    }
                    if realmWordList.objects(WordListModel.self).filter("word = %@", GV.actLanguage + newWord).count == 1 {
                        let selectedWord = SelectedWord(word: word, usedLetters: usedLetters)
                        let boolValue = WTGameWordList.shared.addWord(selectedWord: selectedWord, doAnimate: true, round: GV.playingRecord.rounds.count)
                        returnBool = boolValue
                    } else {
                        blinkWords(newWord: SelectedWord(word: word, usedLetters: usedLetters))
                    }
                }
            }
        } else {
            blinkWords(newWord: SelectedWord(word: word, usedLetters: usedLetters))
        }
        
        if !returnBool {
//            blinkWords(newWord: SelectedWord(word: word, usedLetters: usedLetters))
            if GV.gameArray[usedLetters[0].col][usedLetters[0].row].action(forKey: "GreenBlink") == nil {
//                print("should send")
            }
        } else {
//            HintEngine.shared.createHints()
            createHintsInBackground()
            if GV.basicDataRecord.difficulty == GameDifficulty.Easy.rawValue  && GV.countOfWords >= GV.countOfWordsMaxValue {
                setCountWords(count: GV.countOfWordsMaxValue + 100, type: GameDifficulty.Easy)
//                congratulations(congratulationType: .AllWordsCollected)
            }
            if GV.basicDataRecord.difficulty == GameDifficulty.Medium.rawValue  && GV.countOfLetters >= GV.countOfLettersMaxValue {
                setCountWords(count: GV.countOfLettersMaxValue + 50, type: GameDifficulty.Medium)
//                congratulations(congratulationType: .AllLettersCollected)
            }
            saveActualState()
        }
        return returnBool
    }
        
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
        switchMusicOnOff(stop: true)
        if self.enabled {
            stopShowingTableIfNeeded()
            if timer != nil {
                timer!.invalidate()
                timer = nil
            }
            goBackToWTScene(start: .NoMore)
//            wtSceneDelegate!.gameFinished(start: .NoMore)
        }
    }
    
    var searchingWord = ""
    var wtGameboardMovedBy: CGFloat = 0
    
    @objc func searchButtonTappod() {
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
        finishButton!.isHidden = hide
        if startEasyGameButton != nil {
            startEasyGameButton!.isHidden = hide
        }
        if startMediumGameButton != nil {
            startMediumGameButton!.isHidden = hide
        }
        musicOnOffButton!.isHidden = hide
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
    
    private func filterWordList()->(Results<WordListModel>?, Results<WordsFromCloud>?) {

        searchingParts = [String]()
        beginswith = GV.actLanguage
        endswith = ""
        containsParts = [String]()
        let results1 = realmWordList.objects(WordListModel.self).filter("word LIKE %@", GV.actLanguage + searchingWord.lowercased())
        let results2 = realm.objects(WordsFromCloud.self).filter("word LIKE %@", GV.actLanguage + searchingWord.lowercased())
        return (results1, results2)
    }
    
    private func showSearchResults() {
        listOfFoundedWords = [LineOfFoundedWords]()
        let (filteredWordList1, filteredWordList2) = filterWordList()
        if filteredWordList1 != nil {
            for word in filteredWordList1! {
                let OKWord = LineOfFoundedWords(word.word.subString(at: 2, length: word.word.length - 2))  //wordFilter(word: word.word.subString(at: 2, length: word.word.length - 2)) {
                listOfFoundedWords.append(OKWord)
            }
        }
        if filteredWordList2 != nil {
            for word in filteredWordList2! {
                let OKWord = LineOfFoundedWords(word.word.subString(at: 2, length: word.word.length - 2))  //wordFilter(word: word.word.subString(at: 2, length: word.word.length - 2)) {
                listOfFoundedWords.append(OKWord)
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
        globalMaxLength = 0
        for word in listOfFoundedWords {
            globalMaxLength = word.length > globalMaxLength ? word.length : globalMaxLength
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
        if globalMaxLength < title.length {
            globalMaxLength = title.length
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
//            removeAllSubviews()
            goBackToWTScene(start: .PreviousGame)
//            wtSceneDelegate!.gameFinished(start: .PreviousGame)
        }
    }
    
    @objc func goNextGame() {
        if self.enabled {
            stopShowingTableIfNeeded()
            if timer != nil {
                timer!.invalidate()
                timer = nil
            }
            goBackToWTScene(start: .NextGame)
//            removeAllSubviews()
//            wtSceneDelegate!.gameFinished(start: .NextGame)
        }
    }
    
    @objc func showAllWordsInTableView() {
        if self.enabled {
//            if GV.generateHelpInfo {
//                saveHelpInfo(action: .ShowMyWordsButton)
//            }
            stopShowingTableIfNeeded()
            showOwnWordsInTableView()
            showingInTableViewActive = true
        }
    }
    
    @objc private func showHintTable() {
//        HintEngine.shared.createHints()
        saveActualState()
        stopShowingTableIfNeeded()
        showHintsInTableView()

    }
        

    
    var saveDataButton: MyButton?
    var finishButton: MyButton?
    var allWordsButton: MyButton?
    var hintButton: MyButton?
    var searchButton: MyButton?
    var undoButton: MyButton?
    var goBackButton: MyButton?
    var goToPreviousGameButton: MyButton?
    var goToNextGameButton: MyButton?
    
    var buttonHeight = CGFloat(0)
    var buttonSize = CGSize(width: CGFloat(0), height: CGFloat(0))
    
    func hideButtons(hide: Bool) {
        if goToPreviousGameButton != nil {
            goToPreviousGameButton!.isEnabled = hide ? false : hasRecords(before: true)
        }
        if goToNextGameButton != nil {
            goToNextGameButton!.isEnabled = hide ? false : hasRecords(before: false)
        }
        hintButton!.isEnabled = !hide
        allWordsButton!.isEnabled = !hide
        finishButton!.isEnabled = !hide
        goBackButton!.isEnabled = !hide
        searchButton!.isEnabled = !hide
        if startEasyGameButton != nil {
            startEasyGameButton!.isEnabled = !hide
        }
        if startMediumGameButton != nil {
            startMediumGameButton!.isEnabled = !hide
        }
        if hide {
            goToPreviousGameButton!.alpha = 0.2
            goToNextGameButton!.alpha = 0.2
            hintButton!.alpha = 0.2
            allWordsButton!.alpha = 0.2
            finishButton!.alpha = 0.2
            goBackButton!.alpha = 0.2
            searchButton!.alpha = 0.2
            if startEasyGameButton != nil {
                startEasyGameButton!.alpha = 0.2
            }
            if startMediumGameButton != nil {
                startMediumGameButton!.alpha = 0.2
            }
        } else {
            goToPreviousGameButton!.alpha = hasRecords(before: true) ? 1.0 : 0.2
            goToNextGameButton!.alpha = hasRecords(before: false) ? 1.0 : 0.2
            hintButton!.alpha = 1.0
            allWordsButton!.alpha = 1.0
            finishButton!.alpha = 1.0
            goBackButton!.alpha = 1.0
            searchButton!.alpha = 1.0
            if startEasyGameButton != nil {
                startEasyGameButton!.alpha = 1.0
            }
            if startMediumGameButton != nil {
                startMediumGameButton!.alpha = 1.0
            }
        }

    }

    private func createGoToPreviousGameButton(enabled: Bool) {
        if goToPreviousGameButton != nil {
            goToPreviousGameButton?.removeFromParent()
            goToPreviousGameButton = nil
        }

        let center = PLPosSize(PPos: CGPoint(x: GV.minSide * firstButtonColumn, y: GV.maxSide * lastButtonLine),
                               LPos: CGPoint(x: GV.maxSide * firstButtonColumn, y: GV.minSide * lastButtonLine))
        let imageName = "LeftElite"
        goToPreviousGameButton = createMyButton(imageName: imageName, size: buttonSize, center: center, enabled: enabled, newSize: buttonHeight)
        goToPreviousGameButton!.setButtonAction(target: self, triggerEvent:.TouchUpInside, action: #selector(self.goPreviousGame))
        goToPreviousGameButton!.name = imageName
        goToPreviousGameButton!.zPosition = 10
        bgSprite!.addChild(goToPreviousGameButton!)
    }
    
    private func createGoToNextGameButton(enabled: Bool) {
        if goToNextGameButton != nil {
            goToNextGameButton?.removeFromParent()
            goToNextGameButton = nil
        }
//        let frame = CGRect(x: 0, y: 0, width: buttonHeight, height: buttonHeight)
        let center = PLPosSize(PPos: CGPoint(x:GV.minSide * lastButtonColumn, y: GV.maxSide * lastButtonLine),
                               LPos: CGPoint(x:GV.maxSide * lastButtonColumn, y: GV.minSide * lastButtonLine))
        ()
//        let radius = self.frame.width * 0.045
//        let hasFrame = GV.buttonType == GV.ButtonTypeSimple
        let imageName = "RightElite"
        goToNextGameButton = createMyButton(imageName: imageName, size: buttonSize, center: center, enabled: enabled, newSize: buttonHeight)
        goToNextGameButton!.setButtonAction(target: self, triggerEvent:.TouchUpInside, action: #selector(self.goNextGame))
        goToNextGameButton!.name = imageName
        goToNextGameButton!.zPosition = 10
//        goToNextGameButton = createButton(imageName: imageName, title: "", frame: frame, center: center, cornerRadius: radius, enabled: enabled, hasFrame: hasFrame )
//        goToNextGameButton?.addTarget(self, action: #selector(self.goNextGame), for: .touchUpInside)
        bgSprite!.addChild(goToNextGameButton!)
    }
    
    var musicOnOffButton: MyButton?
    
    private func createMusicOnOffButton() {
        if musicOnOffButton != nil {
            musicOnOffButton!.removeFromParent()
            musicOnOffButton = nil
        }
        let center = PLPosSize(PPos: CGPoint(x:GV.minSide * lastButtonColumn, y:GV.maxSide * musicOnOffLine),
                               LPos: CGPoint(x:GV.maxSide * lastButtonColumn, y:GV.minSide * musicOnOffLine))
        let imageName = GV.basicDataRecord.musicOn ? "MusicOn" : "MusicOff"
        musicOnOffButton = createMyButton(imageName: imageName, size: buttonSize, center: center, enabled: enabled, newSize: buttonHeight)
        musicOnOffButton!.setButtonAction(target: self, triggerEvent:.TouchUpInside, action: #selector(self.switchMusicOnOff))
        musicOnOffButton!.name = imageName
        musicOnOffButton!.zPosition = 10
        bgSprite!.addChild(musicOnOffButton!)
    }
    
    @objc public func switchMusicOnOff(stop: Bool = false) {
        if stop && !GV.basicDataRecord.musicOn {
            return
        }
        if !stop {
            try! realm.safeWrite() {
                GV.basicDataRecord.musicOn = !GV.basicDataRecord.musicOn
            }
        }
        createMusicOnOffButton()
        if player != nil {
            if GV.basicDataRecord.musicOn && !stop {
                player!.play()
            } else {
                player!.stop()
            }
        }
        playingMusic = false
    }
    
    private func createAllWordsButton() {
        if allWordsButton != nil {
            allWordsButton?.removeFromParent()
            allWordsButton = nil
        }
//        var ownHeaderYPos = CGFloat(0)
//        let ownHeader: SKNode = (bgSprite!.childNode(withName: ownWordsHeaderName) as! SKLabelNode)
        let title = GV.language.getText(.tcShowAllWords)
        let wordLength = title.width(font: myTitleFont!)
//        let wordHeight = title.height(font: myTitleFont!)
        let size = CGSize(width:wordLength * 1.5, height: buttonHeight)
//        ownHeaderYPos = self.frame.height * mybuttonLineCenterY// - ownHeader.frame.maxY + frame.height
        allWordsButtonCenter = PLPosSize(PPos: CGPoint(x:GV.minSide * 0.45, y: GV.maxSide * mybuttonLineCenterY),
                                         LPos: CGPoint(x:GV.maxSide * 0.45, y: GV.minSide * mybuttonLineCenterY))
             //self.frame.height * 0.20)
//        let radius = frame.height * 0.5
        allWordsButton = createMyButton(title: title, size: size, center: allWordsButtonCenter, enabled: true )
        allWordsButton!.setButtonAction(target: self, triggerEvent:.TouchUpInside, action: #selector(showAllWordsInTableView))
//        allWordsButton?.addTarget(self, action: #selector(self.showAllWordsInTableView), for: .touchUpInside)
        allWordsButton!.zPosition = 10
        bgSprite!.addChild(allWordsButton!)
    }
    let hintFont = UIFont(name: GV.actLabelFont /*"CourierNewPS-BoldMT"*/, size: GV.onIpad ? 18 : 10)

    private func createHintButton() {
        if hintButton != nil {
            hintButton?.removeFromParent()
            hintButton = nil
        }
        let center = PLPosSize(PPos: CGPoint(x:GV.minSide * 0.70, y:GV.maxSide * mybuttonLineCenterY),
                               LPos: CGPoint(x:GV.maxSide * 0.70, y:GV.minSide * mybuttonLineCenterY))
            
        
        let imageName = "Tipp"
        hintButton = createMyButton(imageName: imageName, size: buttonSize, center: center, enabled: enabled, newSize: buttonHeight)
        hintButton!.setButtonAction(target: self, triggerEvent:.TouchUpInside, action: #selector(self.showHintTable))
        hintButton!.name = imageName
        hintButton!.zPosition = 10
        hintButton!.setButtonLabel(title: "0", font: hintFont!)
        bgSprite!.addChild(hintButton!)
        
    }
    
    private func createMyButton(imageName: String = "", title: String = "", size: CGSize, center: PLPosSize, enabled: Bool, newSize: CGFloat = 0)->MyButton {
        var button: MyButton
        if imageName != "" {
            let image = UIImage(named: imageName)!
            let texture = SKTexture(image: image)
//            let imageSize:CGFloat = 100.0 //image.size.width *  0.8
//            let downImage = resizeImage(image: image, newWidth: imageSize)
//            let downTexture = SKTexture(image: downImage)
            button = MyButton(normalTexture: texture, selectedTexture:texture, disabledTexture: texture)
            button.size = size * (GV.onIpad ? 1.0 : 0.8)
        } else {
            button = MyButton(fontName: myTitleFont!.fontName, size: size)
            button.setButtonLabel(title: title, font: myTitleFont!)
            let buttonSize = CGSize(width: title.width(font: myTitleFont!) * 1.2, height: buttonHeight)
            button.size = buttonSize
        }
        button.plPosSize = center


        button.alpha = enabled ? 1.0 : 0.2
        button.isEnabled = enabled
        button.setActPosSize()
        return button

    }
    
    private func createFinishButton() {
        if finishButton != nil {
            finishButton?.removeFromParent()
            finishButton = nil
        }
        let title = GV.language.getText(.tcNewGame)
        let wordLength = title.width(font: myTitleFont!)
//        let wordHeight = title.height(font: myTitleFont!)
        let size = CGSize(width:wordLength * 1.2, height: buttonHeight)
        let finishButtonCenter = PLPosSize(PPos: CGPoint(x:GV.minSide * 0.15, y: GV.maxSide * mybuttonLineCenterY),
                                           LPos: CGPoint(x:GV.maxSide * 0.15, y: GV.minSide * mybuttonLineCenterY))
            //self.frame.height * 0.20)
//        let radius = frame.height * 0.5
        finishButton = createMyButton(title: title, size: size, center: finishButtonCenter, enabled: true )
        finishButton!.isHidden = false //goOnPlaying ? false : true
        finishButton!.setButtonAction(target: self, triggerEvent:.TouchUpInside, action: #selector(finishButtonTapped))

//        myButton!.addTarget(self, action: #selector(self.finishButtonTapped), for: .touchUpInside)
//        finishButton?.layer.zPosition = -100
//        finishButton = myButton
        finishButton!.zPosition = self.zPosition + 1
        bgSprite!.addChild(finishButton!)
    }
    
    private func modifyfinishButton() {
        switch gameStatus {
        case .Playing:
            finishButton!.removeAllActions()
            let colorBackAction = SKAction.colorize(with: .clear, colorBlendFactor: 0, duration: 0)
            finishButton!.run(colorBackAction)
            colorIndex = 0
            finishButton!.setButtonAction(target: self, triggerEvent:.TouchUpInside, action: #selector(finishButtonTapped))
            finishButton!.setButtonLabel(title: GV.language.getText(.tcNewGame), font: myTitleFont!)
        case .NextRondPossible:
            finishButton!.setButtonAction(target: self, triggerEvent:.TouchUpInside, action: #selector(nextRoundTapped))
            finishButton!.setButtonLabel(title: GV.language.getText(.tcNextRound), font: myTitleFont!)
            animateFinishButton()
        case .Finish:
            finishButton!.setButtonAction(target: self, triggerEvent:.TouchUpInside, action: #selector(finishButtonTapped))
            finishButton!.setButtonLabel(title: GV.language.getText(.tcFinishGame), font: myTitleFont!)
            animateFinishButton()
        }
    }
    let color1 = UIColor(rgb: 0xBDFAF8, alpha: 1.0)
    let color2 = UIColor(rgb: 0xFABDF9, alpha: 1.0)
    let color3 = UIColor(rgb: 0xBFFA88, alpha: 1.0)
    let color4 = UIColor(rgb: 0xFFC4C4, alpha: 1.0)
    let color5 = UIColor(rgb: 0x4EFF36, alpha: 1.0)
    var colorIndex = 0
    
    private func animateFinishButton() {
        let animateColors: [UIColor] = [color1, color2, color3, color4, color5]
        if !finishButton!.hasActions() {
            var actions = Array<SKAction>()
            let waitAction = SKAction.wait(forDuration: 1.0)
            let colorAction = SKAction.colorize(with: animateColors[colorIndex], colorBlendFactor: 1.0, duration: 0)
            colorIndex = colorIndex == animateColors.count - 1 ? 0 : colorIndex + 1
            let scaleUpAction = SKAction.scale(by: 1.2, duration: 0.5)
            let scaleDownAction = SKAction.scale(to: 1.0, duration: 0.5)
//            let colorBackAction = SKAction.colorize(with: .clear, colorBlendFactor: 0, duration: 0)
            let restartAction = SKAction.run ({
                self.finishButton!.removeAllActions()
                self.modifyfinishButton()
            })
            actions.append(SKAction.sequence([colorAction, scaleUpAction, scaleDownAction, waitAction, restartAction]))
            let group = SKAction.group(actions)
            finishButton!.run(group)

        }
    }

    @objc private func finishButtonTapped() {
        if self.enabled {
            showGameFinished(status: .OK)
//            saveHelpInfo(action: .FinishButton)
        }
    }
    

    
    var allWordsButtonCenter: PLPosSize!
    
    private func createSearchButton() {
        if searchButton != nil {
            searchButton!.removeFromParent()
            searchButton = nil
        }
        let size = CGSize(width: buttonHeight, height: buttonHeight)
//        let freePlaceWidth = self.frame.width - allWordsButton!.frame.maxX
        let center = PLPosSize(PPos: CGPoint(x: self.frame.width * lastButtonColumn, y: allWordsButtonCenter.PPos.y),
                               LPos: CGPoint(x: self.frame.width * lastButtonColumn, y: allWordsButtonCenter.LPos.y))
//        let radius = self.frame.width * 0.04
//        let image = UIImage(named: "search")
        let newSize = allWordsButton!.size.height
        let myButton = createMyButton(imageName: "search", size: size, center: center, enabled: true, newSize: newSize)
        myButton.setButtonAction(target: self, triggerEvent:.TouchUpInside, action: #selector(searchButtonTappod))
        //        allWordsButton?.addTarget(self, action: #selector(self.showAllWordsInTableView), for: .touchUpInside)
        myButton.zPosition = self.zPosition + 1
        searchButton = myButton
//        searchButton!.addTarget(self, action: #selector(self.searchButtonTappod), for: .touchUpInside)
        bgSprite!.addChild(searchButton!)
    }
    
//    private func createTippButton() {
//        if tippButton != nil {
//            tippButton?.removeFromParent()
//            tippButton = nil
//        }
//        let xPosition = self.self.frame.width * (GV.onIpad ? 0.75 : 0.5)
//        let yPosition = self.frame.height * (GV.onIpad ? mybuttonLineCenterY : lastButtonLine)
//        let center = CGPoint(x: xPosition, y: yPosition)
//        let size = CGSize(width: buttonHeight, height: buttonHeight)
//        let imageName = "Tipp"
//        tippButton = createMyButton(imageName: imageName, size: size, center: center, enabled: enabled, newSize: buttonHeight)
//        tippButton!.setButtonAction(target: self, triggerEvent:.TouchUpInside, action: #selector(self.showTipps))
//        tippButton!.name = imageName
//        tippButton!.zPosition = 10
//        bgSprite!.addChild(tippButton!)
//    }
//
//    @objc private func showTipps() {
//        //        let freeLetters = findFreeLetters()
//    }
//    private func findFreeLetters()->(redLetters:[String], freePositions:[(Int, Int)]) {
//
//    }

    

    
    let buttonYPosition: CGFloat = 0.145
    private func createGoBackButton() {
        if goBackButton != nil {
            goBackButton?.removeFromParent()
            goBackButton = nil
        }
//        let frame = CGRect(x: 0, y: 0, width: buttonHeight, height: buttonHeight)
        let center = PLPosSize(PPos: CGPoint(x:GV.minSide * firstButtonColumn, y:GV.maxSide * firstButtonLine),
                               LPos: CGPoint(x:GV.maxSide * firstButtonColumn, y:GV.minSide * firstButtonLine))
            
//        let radius = self.frame.width * 0.04
//        let hasFrame = GV.buttonType == GV.ButtonTypeSimple
        let imageName = "BackElite"
        goBackButton = createMyButton(imageName: imageName, size: buttonSize, center: center, enabled: true, newSize: buttonHeight)
        goBackButton!.setButtonAction(target: self, triggerEvent:.TouchUpInside, action: #selector(self.goBackTapped))
        goBackButton!.name = imageName
        goBackButton!.zPosition = 10
        bgSprite!.addChild(goBackButton!)
    }
    
    var startEasyGameButton: MyButton?
    var startMediumGameButton: MyButton?
    var easyLabel: SKLabelNode?
    var mediumLabel: SKLabelNode?
    
    
    var player: AVAudioPlayer?
    var playingMusic = false
    
    func playSound() {
        if playingMusic {
            return
        }
        guard let url = Bundle.main.url(forResource: "MagicOfWords", withExtension: "mp3") else { return }
        
        do {
            if #available(iOS 10.0, *) {
                try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            } else {
                // Fallback on earlier versions
            }
            if AVAudioSession.sharedInstance().isOtherAudioPlaying {
                return
            }
            try AVAudioSession.sharedInstance().setActive(true)
            do {
               try AVAudioSession.sharedInstance().setCategory(.ambient)
               try AVAudioSession.sharedInstance().setActive(true, options: .notifyOthersOnDeactivation)
            } catch {
               NSLog(error.localizedDescription)
            }
            /* The following line is required for the player to work on iOS 11. Change the file type accordingly*/
            player = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileType.mp3.rawValue)
            
            /* iOS 10 and earlier require the following line:
             player = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileTypeMPEGLayer3) */
            
            guard let player = player else { return }
            player.volume = 0.2
            player.numberOfLoops = -1
            if GV.basicDataRecord.musicOn {
                player.play()
                playingMusic = true
            } 
            
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    @objc private func startEasyGame() {
        stopShowingTableIfNeeded()
        if timer != nil {
            timer!.invalidate()
            timer = nil
        }
        goBackToWTScene(start: .SetEasy)
//        removeAllSubviews()
//        wtSceneDelegate!.gameFinished(start: .SetEasy)
    }
    
    @objc private func startMediumGame() {
        stopShowingTableIfNeeded()
        if timer != nil {
            timer!.invalidate()
            timer = nil
        }
        goBackToWTScene(start: .SetMedium)
//        removeAllSubviews()
//        wtSceneDelegate!.gameFinished(start: .SetMedium)
    }
    
    let firstButtonColumn: CGFloat = 0.08
    var lastButtonColumn: CGFloat = 0.92
    var musicOnOffLine: CGFloat = 0.94
    var firstButtonLine: CGFloat = 0.84
    var secondButtonLine: CGFloat = 0.80
    var lastButtonLine: CGFloat = GV.onIpad ? 0.09 : 0.18
    
    private func createUndo() {
        if undoButton != nil {
            undoButton?.removeFromParent()
            undoButton = nil
        }
        if activityRoundItem.count == 0 {
            activityRoundItem.append(ActivityRound())
            activityRoundItem[activityRoundItem.count - 1].activityItems = [ActivityItem]()
        }
//        let hasFrame = GV.buttonType == GV.ButtonTypeSimple
        let imageName = "UndoElite"
        let center = PLPosSize(PPos: CGPoint(x: GV.minSide * lastButtonColumn, y: GV.maxSide * firstButtonLine),
                               LPos: CGPoint(x: GV.maxSide * lastButtonColumn, y: GV.minSide * firstButtonLine))
            
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
//        let subDirs = FileManager().subpaths(atPath: NSTemporaryDirectory())
//        print("Dir: \(String(describing: subDirs))")
        playSound()
        GV.playing = true
        timerIsCounting = true
        headerCreated = false
        GV.countOfWords = 0
        GV.countOfLetters = 0
        hintsCreated = true
//        gameNumberForGenerating = GV.basicDataRecord.difficulty == GameDifficulty.Easy.rawValue ? GV.DemoEasyGameNumber : GV.DemoMediumGameNumber
//        gameNumberForGenerating = newGameNumber
        WTGameWordList.shared.setDelegate(delegate: self)
        timeForGame = TimeForGame(from: GV.playingRecord.time)
        myTimer = MyTimer(time: timeForGame)
        wtGameboard = WTGameboard(countCols: GV.sizeOfGrid, parentScene: self, delegate: self, yCenter: gameboardCenterY)
        if GV.playingRecord.gameStatus == GV.GameStatusContinued {
            goOnPlaying = true
        }
        generateArrayOfWordPieces(new: new)
        indexOfTilesForGame = 0
        pieceArray = Array(repeating: WTPiece(), count: 3)
        for index in 0..<3 {
            origPosition[index] = CGPoint(x:self.frame.width * shapeMultiplicator[index], y:self.frame.height * pieceArrayCenterY)
        }
//        GV.hintTable.removeAll()
        if !new {
            wtGameboard!.setRoundInfos()
            if GV.playingRecord.rounds.count == 1 && GV.playingRecord.rounds[0].gameArray == "" {
                createFixLetters()
            } else {
                WTGameWordList.shared.restoreFromPlayingRecord()
                restoreGameArray()
                showFoundedWords()
                modifyHeader()
                let countFixLetters =  wtGameboard!.checkFixLetters()
                var targetLetterCount = startValueForFixLetters + GV.playingRecord.rounds.count
                targetLetterCount = (targetLetterCount > maxLetterCountForFixLetters) ? maxLetterCountForFixLetters : targetLetterCount
                if targetLetterCount > countFixLetters {
//                    less fixLetters as should be --> must be generated
                    createFixLetters()
                }
            }
        } else {
            if GV.playingRecord.rounds.count == 0 {
                actRound = 1
                try! realm.safeWrite() {
                    let rounds = RoundDataModel()
                    GV.playingRecord.rounds.append(rounds)
                }
            }
            activityRoundItem = [ActivityRound]()
            createFixLetters()
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
//        saveActualState()
//        fillTippIndexes()
        
//        movePiecesToGameArray()
//        HintEngine.shared.createHints()
        createHintsInBackground()
        saveActualState()
        
        if timer != nil {
            timer!.invalidate()
        }
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(countTime(timerX: )), userInfo: nil, repeats: true)
        countTime(timerX: Timer())
//        setGameStatus()
    }
    
    private func movePiecesToGameArray() {
        #if GALINA
            return
        #endif
        var words = GV.playingRecord.words.components(separatedBy: itemSeparator)
        var wordIndex = 0
        let pieceFromPosition = 0
        let movedIndex = 0
        let random = MyRandom(gameNumber: GV.playingRecord.gameNumber % 1000, modifier: (GV.playingRecord.rounds.count == 0 ? 1 : GV.playingRecord.rounds.count - 1) * 22)
        let gameArraySize = GV.sizeOfGrid - 1

        
        func moveWordToGameArray() {
            let actWord = words[wordIndex]
            wordIndex += 1
            var remainingLength = actWord.length
            repeat {
                let piece = pieceArray[pieceFromPosition]
                let form = myForms[piece.myType]![piece.rotateIndex]
                var placeIsOK = true
                func getFreePosition()->(col: Int, row: Int) {
                    var randomCol = 0
                    var randomRow = 0
                    repeat {
                        placeIsOK = true
                        randomCol = random.getRandomInt(0, max: gameArraySize)
                        randomRow = random.getRandomInt(0, max: gameArraySize)
                        if GV.gameArray[randomCol][randomRow].status != .Empty {
                            placeIsOK = false
                            continue
                        }
                    } while !placeIsOK
                    return (col: randomCol, row: randomRow)
                }
                var gameArrayPositions = [GameArrayPositions]()
                for index in 0..<form.points.count {
                    let (col, row) = getFreePosition()
                    let letter = piece.letters[index]
                    if GV.gameArray[col][row].status != .Empty {
                        print("error at col: \(col), row: \(row)")
                    }
                    _ = GV.gameArray[col][row].setLetter(letter: letter, toStatus: .Used, calledFrom: "movePiecesToGameArray")
                    gameArrayPositions.append(GameArrayPositions(col:col,row: row))
                }
                remainingLength -= form.points.count
                piece.setGameArrayPositions(gameArrayPositions: gameArrayPositions)
                piece.isOnGameboard = true
                piece.pieceFromPosition = pieceFromPosition
                let activityItem = ActivityItem(type: .FromBottom, fromBottomIndex: pieceArray[pieceFromPosition].getArrayIndex())
                if activityRoundItem.count == 0 {
                    activityRoundItem.append(ActivityRound())
                }
                if activityRoundItem.last!.activityItems.count == 0 {
                    activityRoundItem[activityRoundItem.count - 1].activityItems = [ActivityItem]()
                }
                activityRoundItem[activityRoundItem.count - 1].activityItems.append(activityItem)
                setUndoButton(enabled: true)
                let lastIndex = pieceArray.count - 1
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
                words = GV.playingRecord.words.components(separatedBy: itemSeparator)
                for index in 0...lastIndex {
                    bgSprite!.addChild(pieceArray[index])
                }
            } while remainingLength > 0
//            GV.hintTable.append(actWord)
        }
        while wtGameboard!.getCountFreePlaces() > countRemainingFreePlaces {
            moveWordToGameArray()
        }
    }
    
    let countRemainingFreePlaces = 36
    
    private func fillTippIndexes() {
        tippIndexes = [:]
        let words = GV.playingRecord.words.components(separatedBy: itemSeparator)
        let pieces = GV.playingRecord.pieces.components(separatedBy: itemSeparator)
        var firstWord = ""
        var tippsFromFirst = false
        for piece in pieces {
            if piece != "" {
                let items = piece.components(separatedBy: "/")
                firstWord += items[2]
                if firstWord == words[0] {
                    tippsFromFirst = true
                    break
                }
                if firstWord.length >= words[0].length {
                    break
                }
            }
        }
        let lengthOfFirstSixWords = (words[0] + words[1] + words[2] + words[3] + words[4] + words[5]).length
        var lengthOfPieces = 0
        var startPieceIndex = 0
        var startWordIndex = 0
        if !tippsFromFirst {
            for piece in pieces {
                let items = piece.components(separatedBy: "/")
                lengthOfPieces += items[2].count
                startPieceIndex += 1
                if lengthOfPieces == lengthOfFirstSixWords {
                    break
                }
            }
            startWordIndex = 6
        }
        var wordIndex = startWordIndex
        var searchWord = ""
        for (pieceIndex, piece) in pieces.enumerated() {
            if tippsFromFirst || pieceIndex >= startPieceIndex {
                if piece != "" {
                    let items = piece.components(separatedBy: "/")
                    searchWord += items[2]
                    if searchWord == words[wordIndex] {
                        tippIndexes[pieceIndex] = wordIndex
                        searchWord = ""
                        wordIndex += 1
                    }
                }
            }
        }            
    }
    
    var tippIndexes: [Int:Int] = [:]
    
//    private var helpRecordIndex = 0
//    private var helpDemoSpeedSlow = false
//    private var showHelpDemoActive = false
//    private var lastHelpDemoStepReady = false
//    private var generateHelpInfoActive = false
//    private var helpDemoDuration = 0.0
    private var fingerActions = [SKAction]()
    private var lastTouchedPosition = CGPoint(x: 0, y: 0)
    private var fingerSprite: SKSpriteNode?
    private var startPosition = CGPoint(x: 0, y: 0)
    private var fingerPositionModifier = CGPoint(x: 0, y: 0)
    private var gridStartPosition = CGPoint(x: 0, y: 0)
    private var gridSize: CGFloat = 0.0
    
    enum ActionType: Int {
        case TouchesBegan, TouchesMoved, TouchesEnded, NoMore
    }
    
    var bestPlayerNickname = ""
    var bestScore = 0
    var actPlayer = ""
    var actScore = 0
    var lastPosition = CGPoint(x: 0, y: 0)
    let startValueForFixLetters = 7 // Starts with startValue fixLetters
    let maxLetterCountForFixLetters = 20

    private func createFixLetters() {
        if GV.basicDataRecord.difficulty != GameDifficulty.Medium.rawValue {
            return
        }
        var fixLetters = [UsedLetter]()
//        let lettersProRound = [8, 8, 10, 10, 12, 12, 12, 12, 14, 14, 14, 14, 16, 16, 16, 16, 18, 18, 18, 18, 20]
//        let useLettersProRound = GV.playingRecord.created > Date(year: 2019, month: 9, day: 1)
        let gameNumber = GV.playingRecord.gameNumber % 1000
//        let adderValue = 2
        let roundCount = GV.playingRecord.rounds.count == 0 ? 1 : GV.playingRecord.rounds.count
        let random = MyRandom(gameNumber: gameNumber, modifier: (roundCount - 1) * 15)
//        let countLettersOnGameboard = wtGameboard!.getCountLetters()
        let countActFixLetters = wtGameboard!.checkFixLetters()
        var targetLetterCount = startValueForFixLetters + GV.playingRecord.rounds.count
        targetLetterCount = (targetLetterCount > maxLetterCountForFixLetters) ? maxLetterCountForFixLetters : targetLetterCount
        let countOfLetters = targetLetterCount - countActFixLetters
        var remainigLength = countOfLetters
        if remainigLength < 1 {
            return
        }
        var myLengths = [Int]()
        repeat {
            let newLength = random.getRandomInt(5, max: 10)
            myLengths.append(newLength)
            remainigLength -= newLength
        } while remainigLength > 0
        var myLetters = ""
        for length in myLengths {
            let likeValue = String(repeating: "?", count: length)
            let words = realmMandatoryList.objects(HintModel.self).filter("language = %@ and word LIKE %d", GV.actLanguage, likeValue)
            myLetters += words[random.getRandomInt(0, max: words.count - 1)].word
        }
//        print (myLetters)
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
        myLetters = inputWord.subString(at:0, length: countOfLetters)

        var letterIndex = 0
        let Q1: Int8 = 1
        let Q2: Int8 = 2
        let Q3: Int8 = 4
        let Q4: Int8 = 8
        var OKPositions = [(col: Int, row: Int, quoters: Int8)]()
        var countFreePlaces = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
//            Analyse gameArray for free places
        for col in 0...4 {
            for row in 0...4 {
                var quoters: Int8 = 0
                quoters |= GV.gameArray[col][row].status == .Empty ? Q1 : 0
                quoters |= GV.gameArray[9 - col][row].status == .Empty ? Q2 : 0
                quoters |= GV.gameArray[col][9 - row].status == .Empty ? Q3 : 0
                quoters |= GV.gameArray[9 - col][9 - row].status == .Empty ? Q4 : 0
                OKPositions.append((col, row, quoters))
                if quoters > 0 {
                    countFreePlaces[Int(quoters)] += 1
                }
            }
        }
        var OKPositionsSorted = OKPositions.sorted(by: {$0.quoters > $1.quoters})
        repeat {
            var counter = 0
            var countFreePlacesIndex = 16
            repeat {
                countFreePlacesIndex -= 1
                counter = countFreePlaces[countFreePlacesIndex] - 1
            } while counter < 0 && countFreePlacesIndex > 0
            if counter < 0 {
                var usedPositions = [(col:Int, row:Int)]()
                repeat {
                    let col = random.getRandomInt(0, max: 9)
                    let row = random.getRandomInt(0, max: 9)
                    let item = GV.gameArray[col][row]
                    if usedPositions.firstIndex(where: {$0.col == col && $0.row == row}) == nil && item.status == .Used && !item.fixItem {
                        fixLetters.append(UsedLetter(col:col, row: row, letter: GV.gameArray[col][row].letter))
                        usedPositions.append((col: col, row:row))
                        letterIndex += 1
                    }
                } while letterIndex < countOfLetters
                break
            }
            let positionIndex = random.getRandomInt(0, max: counter)
            let col = OKPositionsSorted[positionIndex].col
            let row = OKPositionsSorted[positionIndex].row
            let actQouterInfo = OKPositionsSorted[positionIndex].quoters
            countFreePlaces[countFreePlacesIndex] -= 1
            OKPositionsSorted.remove(at:positionIndex)
            if actQouterInfo & Q1 != 0 {
                fixLetters.append(UsedLetter(col:col, row: row, letter: myLetters.char(at:letterIndex)))
                letterIndex += 1
            }
            if letterIndex < countOfLetters && actQouterInfo & Q2 != 0 {
                fixLetters.append(UsedLetter(col: 9 - col, row: row, letter: myLetters.char(at: letterIndex)))
                letterIndex += 1
            }
            if letterIndex < countOfLetters && actQouterInfo & Q3 != 0 {
                fixLetters.append(UsedLetter(col: col, row: 9 - row, letter: myLetters.char(at: letterIndex)))
                letterIndex += 1
            }
            if letterIndex < countOfLetters  && actQouterInfo & Q4 != 0 {
                fixLetters.append(UsedLetter(col: 9 - col, row: 9 - row, letter: myLetters.char(at: letterIndex)))
                letterIndex += 1
            }
        } while letterIndex < countOfLetters
        wtGameboard!.addFixLettersToGamearray(fixLetters: fixLetters)
        saveActualState()
    }
    
    var gameFinished = false
    
    private func hasRecords(before: Bool)->Bool {
        let allRecords = realm.objects(GameDataModel.self).filter("gameNumber >= %d and gameNumber < %d and language = %@",
              GV.minGameNumber, GV.maxGameNumber, GV.actLanguage).sorted(byKeyPath: "score", ascending: false)
        if allRecords.count > 1 {
            if before && allRecords[0].nowPlaying || !before && allRecords.last!.nowPlaying {
                return false
            } else {
                return true
            }
        } else {
            return false
        }
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
            if index < 2 {
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
    
//    var realmHelpInfo: Realm?
    
//    private func initiateHelpModel() {
//        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
//        let helpInfoURL = documentsURL.appendingPathComponent("HelpInfo.realm")
//        let config1 = Realm.Configuration(
//            fileURL: helpInfoURL,
//            shouldCompactOnLaunch: { totalBytes, usedBytes in
//                // totalBytes refers to the size of the file on disk in bytes (data + free space)
//                // usedBytes refers to the number of bytes used by data in the file
//
//                // Compact if the file is over 100MB in size and less than 50% 'used'
//                let oneMB = 10 * 1024 * 1024
//                return (totalBytes > oneMB) && (Double(usedBytes) / Double(totalBytes)) < 0.8
//        },
//            objectTypes: [HelpInfo.self])
//        do {
//            // Realm is compacted on the first open if the configuration block conditions were met.
//            _ = try Realm(configuration: config1)
//        } catch {
//            print("error")
//            // handle error compacting or opening Realm
//        }
//        let helpInfoConfig = Realm.Configuration(
//            fileURL: helpInfoURL,
//            schemaVersion: 0, // new item words
//            // Set the block which will be called automatically when opening a Realm with
//            // a schema version lower than the one set above
//            migrationBlock: { migration, oldSchemaVersion in
//                switch oldSchemaVersion {
////                case 0...3:
////                    migration.deleteData(forType: HelpModel.className())
////
//                default: migration.enumerateObjects(ofType: BasicDataModel.className())
//                    { oldObject, newObject in
//                    }
//                }
//            },
//            objectTypes: [HelpInfo.self])
//
//        realmHelpInfo = try! Realm(configuration: helpInfoConfig)
//
//    }
    
//    private func resetHelpInfo() {
//        let difficulty = GV.basicDataRecord.difficulty
//        let records = realmHelpInfo!.objects(HelpInfo.self).filter("language = %@ and difficulty = %d", GV.actLanguage, difficulty)
//        if records.count > 0 {
//            try! realmHelpInfo!.safeWrite() {
//                realmHelpInfo!.delete(records)
//            }
//        }
//    }
    var lastCol = NoValue
    var lastRow = NoValue
    var countOfMoves = 0
//    var helpInfo = HelpInfo()
    
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


    
//    private func saveHelpInfo(action: TypeOfTouch) {
//        if !GV.generateHelpInfo {
//            return
//        }
//        let records = realmHelpInfo!.objects(HelpInfo.self).filter("language = %@ and difficulty = %d", GV.actLanguage, GV.basicDataRecord.difficulty).sorted(byKeyPath: "counter")
//        let counter = records.count > 0 ? records.last!.counter + 1 : 1
//        let sDifficulty = String(GV.basicDataRecord.difficulty)
//        let helpInfo = HelpInfo()
//        helpInfo.difficulty = GV.basicDataRecord.difficulty
//        helpInfo.typeOfTouch = action.rawValue
//        helpInfo.combinedKey = GV.actLanguage + itemSeparator + String(counter) + itemSeparator + sDifficulty
//        helpInfo.language = GV.actLanguage
//        helpInfo.counter = counter
//        switch action {
//        case .UndoButton: helpInfo.letters = UndoButtonHelpInfo
//        case .ShowMyWordsButton: helpInfo.letters = ShowMyWordsButtonHelpInfo
//        case .FinishButton: helpInfo.letters = FinishButtonHelpInfo
//        case .ContinueGameEasy: helpInfo.letters = ContinueGameEasyHelpInfo
//        case .ContinueGameMedium: helpInfo.letters = ContinueGameMediumHelpInfo
//        case .FinishGameEasy: helpInfo.letters = FinishGameEasyHelpInfo
//        case .FinishGameMedium: helpInfo.letters = FinishGameMediumHelpInfo
//        case .OKFixLettersSolved: helpInfo.letters = OKFixLettersEasyHelpInfo
//        case .OKMandatorySolved: helpInfo.letters = OKMandatorySolvedHelpInfo
//        case .NoMoreStepsBack: helpInfo.letters = NoMoreStepsBackHelpInfo
//        case .NoMoreStepsNext: helpInfo.letters = NoMoreStepsNextHelpInfo
//        case .NoMoreStepsCont: helpInfo.letters = NoMoreStepsContHelpInfo
//        case .FinishGame: helpInfo.letters = FinishGameHelpInfo
//        default: break
//        }
//        try! realmHelpInfo!.safeWrite() {
//            realmHelpInfo!.add(helpInfo)
//        }
//    }
    private func saveArrayOfPieces() {
//        tilesForGame.removeAll()
        let piecesToPlay = GV.playingRecord.pieces.components(separatedBy: itemSeparator)
        if tilesForGame.count < piecesToPlay.count {
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
   }
    
    private func generateArrayOfWordPieces(new: Bool) {
        if new || GV.playingRecord.pieces.count == 0 {
            try! realm.safeWrite() {
                GV.playingRecord.words = ""
            }
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
                fillTippIndexes()
            }
            tileForGame = tilesForGame[indexOfTilesForGame]
            indexOfTilesForGame += 1
        } while tileForGame.isOnGameboard
//        indexOfTilesForGame = indexOfTilesForGame >= tilesForGame.count ? 0 : indexOfTilesForGame
        let actIndex: Int? = tippIndexes[indexOfTilesForGame]
        if actIndex != nil {
//            let myWords = GV.playingRecord.words.components(separatedBy: itemSeparator)
//            print("word for tipp: \(myWords[actIndex! - 1]), indexOfTilesForGame: \(indexOfTilesForGame)")
            if actIndex! > 0 {
//                showTipp(tipp: myWords[actIndex! - 1])
            }
        }
        return tileForGame

    }
    
    private func showTipp(tipp: String) {
        let fontSize = GV.onIpad ? self.frame.size.width * 0.02 : self.frame.size.width * 0.04
        let textOnBalloon = GV.language.getText(.tcTipp, values: tipp)
        let balloon = SKSpriteNode(imageNamed: "bubbleGoldElite")
        let width = textOnBalloon.width(font: myFont!) * (GV.onIpad ? 2.0 : 1.5)
        let height = textOnBalloon.height(font: myFont!) * 2.5
        balloon.size = CGSize(width: width, height: height)
        balloon.zPosition = 10
//        let atY = score >= 0 ? self.frame.size.height * 0.1 : self.frame.size.height * 0.98
//        let startPos = wtGameboard!.getCellPosition(col: word.usedLetters[0].col, row: word.usedLetters[0].row)
        let startPos = CGPoint(x: self.frame.width * 0.5, y: self.frame.height * 0.2)
//        let startPosY = startPos.y
//        let endPosY = score > 0 ? self.frame.size.height * 0.80 : self.frame.size.height * -0.04
        balloon.position = CGPoint(x: startPos.x, y: startPos.y )
        bgSprite!.addChild(balloon)
        let wordLabel = SKLabelNode(fontNamed: GV.actFont)
        wordLabel.text = textOnBalloon
        wordLabel.verticalAlignmentMode = .center
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
    #if SHOWFINGER
    var finger: SKSpriteNode?
    var fingerAdder: CGFloat = -20
    #endif
    
    private func stopShowingTableIfNeeded() {
        if showingInTableViewActive /* && !touchedNodes.showOwnWordsButton */ {
            WTGameWordList.shared.stopShowingWords()
            showingInTableViewActive = false
            switch tableType {
            case .ShowAllWords:
                showOwnWordsTablSeView!.removeFromSuperview()
            case .ShowFoundedWords:
                showFoundedWordsTableView!.removeFromSuperview()
            case .ShowHints:
                showHintsTableView!.removeFromSuperview()
            case .ShowWordsOverPosition:
                showWordsOverPositionTableView!.removeFromSuperview()
            default:
                break
            }
            timerIsCounting = true
            self.hideButtons(hide: false)
        }
    }
    
    var firstTouchedCol = 0
    var firstTouchedRow = 0
    
    private func stopBlinkingNodesIfNeeded( ) {
         if GV.countBlinkingNodes > 0 {
            for myNode in GV.blinkingNodes {
                if myNode.hasActions() {
                    myNode.removeAllActions()
                    let showOrigAction = SKAction.run({
                        myNode.setStatus(toStatus: .OrigStatus)
                    })
                    myNode.run(showOrigAction)
                }
            }
            GV.blinkingNodes.removeAll()
            GV.countBlinkingNodes = 0
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//        if showHelp && !GV.generateHelpInfo {
//            return
//        }
        stopBlinkingNodesIfNeeded()
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
        #if SHOWFINGER
        if finger != nil {
            finger?.removeFromParent()
            finger = nil
        }
        #endif
        movedFromBottom = false
        inChoosingOwnWord = false
//        ownWordsScrolling = false
//        let firstTouch = touches.first
        firstTouchLocation = location//firstTouch!.location(in: self)
//      ----------------------------------
//        if GV.generateHelpInfo {
//            relativPosition = (firstTouchLocation - CGPoint(x: wtGameboard!.grid!.frame.minX, y: wtGameboard!.grid!.frame.minY)) / wtGameboard!.grid!.frame.width
//            helpInfo = HelpInfo()
//            var counter = 0
//            let info = realmHelpInfo!.objects(HelpInfo.self).filter("language = %@ and difficulty = %d", GV.actLanguage, GV.basicDataRecord.difficulty).sorted(byKeyPath: "counter", ascending: true)
//            if info.count > 0 {
//                counter = info.last!.counter + 1
//            }
////            let counter =  realmHelpInfo!.objects(HelpInfo.self).filter("language = %@", GV.actLanguage).sorted(byKeyPath: "counter", ascending: true).last!.counter + 1
//
//            let sDifficulty = String(GV.basicDataRecord.difficulty)
//            helpInfo.difficulty = GV.basicDataRecord.difficulty
//            helpInfo.combinedKey = GV.actLanguage + itemSeparator + String(counter) + itemSeparator + sDifficulty
//            helpInfo.language = GV.actLanguage
//            helpInfo.counter = counter
//        }
//      ----------------------------------
        #if SHOWFINGER
        let texture = SKTexture(imageNamed: "finger")
        finger = SKSpriteNode(texture: texture)
        let sizeDivider = GV.onIpad ? CGFloat(6) : CGFloat(12)
        finger?.size = CGSize(width: (finger?.size.width)! / sizeDivider, height: (finger?.size.height)! / sizeDivider)
        finger?.position = firstTouchLocation + CGPoint(x: 0, y: fingerAdder)
        finger?.zPosition = 1000
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
//            if GV.generateHelpInfo {
//                helpInfo.typeOfTouch = TypeOfTouch.FromBottom.rawValue
//                helpInfo.beganInfo = "\(touchedNodes.shapeIndex)"
//                var letters = ""
//                for letter in pieceArray[touchedNodes.shapeIndex].letters {
//                    letters += letter
//                }
//                helpInfo.letters = letters
//            }
        } else if touchedNodes.GCol.between(min: 0, max: GV.sizeOfGrid - 1) && touchedNodes.GRow.between(min:0, max: GV.sizeOfGrid - 1) {
            touchedPosition = touchedNodes
            timerForSetMovingModus = Timer.scheduledTimer(timeInterval: GV.basicDataRecord.setMoveModusDuration, target: self, selector: #selector(setMoveModus(timerX: )), userInfo: nil, repeats: false)
            inChoosingOwnWord = true
            wtGameboard?.startChooseOwnWord(col: touchedNodes.GCol, row: touchedNodes.GRow)
//            if GV.generateHelpInfo {
//                helpInfo.typeOfTouch = TypeOfTouch.FromGameArray.rawValue
//                let beganInfoData = MovedInfoData(onGameArray: true, relPosX: relativPosition.x, relPosY: relativPosition.y, col: touchedNodes.GCol, row: touchedNodes.GRow, GRow: touchedNodes.GRow).toString()
//                helpInfo.beganInfo = "\(beganInfoData)"
//            }
        }

    }
    
    var touchedPosition = TouchedNodes()
    var movesForbidden = false

    @objc private func setMoveModus(timerX: Timer) {
        let duration = 0.1
        let col = touchedPosition.GCol
        let row = touchedPosition.GRow
        let myNode = GV.gameArray[col][row]
        if !myNode.moveable {
            return
        }
        movesForbidden = true
        let origZPosition = myNode.zPosition
        let newSize = myNode.size * (GV.onIpad ? 2.0 : 3.0)
        let origSize = myNode.size
        let makeBiggerAction = SKAction.resize(toWidth: newSize.width, height: newSize.height, duration: duration)
        let makeSmallerAction = SKAction.resize(toWidth: origSize.width, height: origSize.height, duration: 0)
        let waitAction = SKAction.wait(forDuration: duration)
        let setMoveModusAction = SKAction.run({
            self.movingSprite = wtGameboard!.setMoveModusBecauseOfTimer(col: col, row: row)
        })
        let setMaxZPositionAction = SKAction.run({
            myNode.zPosition = 1000
        })
        let setOrigZPositionAction = SKAction.run({
            myNode.zPosition = origZPosition
        })
        let enableMovesAction = SKAction.run({
            self.movesForbidden = false
        })
        var sequence = [SKAction]()
        sequence.append(setMaxZPositionAction)
        sequence.append(makeBiggerAction)
        sequence.append(waitAction)
        sequence.append(makeSmallerAction)
        sequence.append(setMoveModusAction)
        sequence.append(setOrigZPositionAction)
        sequence.append(enableMovesAction)
        myNode.run(SKAction.sequence(sequence))
    }

    
    var timerForSetMovingModus: Timer?
    
//    public func setMovingSprite() {
//        movingSprite = true
//    }
    
//    struct MovedInfoData {
//        var onGameArray = false
//        var relPosX: CGFloat = 0
//        var relPosY: CGFloat = 0
//        var col = NoValue
//        var row = NoValue
//        var GRow = NoValue
//        init(onGameArray: Bool = false, relPosX: CGFloat = 0, relPosY: CGFloat = 0, col: Int = NoValue, row: Int = NoValue, GRow: Int = NoValue) {
//            self.onGameArray = onGameArray
//            self.relPosX = relPosX
//            self.relPosY = relPosY
//            self.col = col
//            self.row = row
//            self.GRow = GRow
//        }
//        init(from: String) {
//            let values = from.components(separatedBy: "/")
//            self.onGameArray = Int(values[0]) == 0 ? false : true
//            self.relPosX = CGFloat(Float(values[1])!)
//            self.relPosY = CGFloat(Float(values[2])!)
//            self.col = Int(values[3])!
//            self.row = Int(values[4])!
//            self.GRow = Int(values[5])!
//        }
//        func toString()->String {
//            return "\(onGameArray ? "1" : "0")/\(relPosX.nDecimals(n: 3))/\(relPosY.nDecimals(n: 3))/\(col)/\(row)/\(GRow)"
//        }
//    }
    
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
//        if showHelp && !GV.generateHelpInfo {
//            return
//        }
        let touchLocation = touches.first!.location(in: self)
        let touchedNodes = analyzeNodes(touchLocation: touchLocation)
        myTouchesMoved(location: touchLocation, touchedNodes: touchedNodes)
    }
    
    private func myTouchesMoved(location: CGPoint, touchedNodes: TouchedNodes) {
        if wtSceneDelegate == nil {
            return
        }
        if movesForbidden {
            return
        }

        let touchLocation = location //firstTouch!.location(in: self)
//        if GV.generateHelpInfo {
//            relativPosition = (touchLocation - CGPoint(x: wtGameboard!.grid!.frame.minX, y: wtGameboard!.grid!.frame.minY)) / wtGameboard!.grid!.frame.width
//        }

        #if SHOWFINGER
        finger?.position = touchLocation + CGPoint(x: 0, y: fingerAdder)
        #endif
//        let nodes = self.nodes(at: touchLocation)
//        let nodes1 = self.nodes(at: CGPoint(x: touchLocation.x, y: touchLocation.y + blockSize * 0.11))
//        let touchedNodes = analyzeNodes(touchLocation: touchLocation, calledFrom: .Move)
//        var onGameArray = true
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
//                    onGameArray = false
                }
            }

        } else if inChoosingOwnWord {
            
            if abs((firstTouchLocation - location).length()) > 20 && timerForSetMovingModus != nil {
                timerForSetMovingModus!.invalidate()
                timerForSetMovingModus = nil
            }
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
//                onGameArray = true
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
//                onGameArray = false
            }
//            if GV.generateHelpInfo {
//                let movedInfoData = MovedInfoData(onGameArray: onGameArray, relPosX: relativPosition.x, relPosY: relativPosition.y, col: touchedNodes.col, row: touchedNodes.row, GRow: touchedNodes.GRow).toString() + itemSeparator
//                helpInfo.movedInfo += movedInfoData
//            }
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
//        if showHelp && !GV.generateHelpInfo {
//            return
//        }
        let touchLocation = touches.first!.location(in: self)
        let touchedNodes = analyzeNodes(touchLocation: touchLocation)
        _ = myTouchesEnded(location: touchLocation, touchedNodes: touchedNodes)
    }
    
    
    private func myTouchesEnded(location: CGPoint, touchedNodes: TouchedNodes, checkLetters: String = "")->Bool {
         if timerForSetMovingModus != nil {
            timerForSetMovingModus!.invalidate()
            timerForSetMovingModus = nil
        }

        if wtSceneDelegate == nil {
            return false
        }
        var returnBool = false
        var lettersForCheck = ""
//        if GV.generateHelpInfo {
//            relativPosition = (location - CGPoint(x: wtGameboard!.grid!.frame.minX, y: wtGameboard!.grid!.frame.minY)) / wtGameboard!.grid!.frame.width
//        }
        let touchLocation = location //firstTouch!.location(in: self)
        #if SHOWFINGER
        finger?.removeFromParent()
        finger = nil
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
//            var saveRecord = false
            if movingSprite {
                movingSprite = false
                let row = touchedNodes.row + 2 == 10 ? 9 : touchedNodes.row + 2
                (_, letters) = wtGameboard!.stopShowingSpriteOnGameboard(col: touchedNodes.col, row: row, fromBottom: false)
                if letters != "" {
                    lettersForCheck = letters + "/" + LettersColor.Red.rawValue
//                    saveRecord = true
                }
            } else {
                word = wtGameboard!.endChooseOwnWord(col: touchedNodes.GCol, row: touchedNodes.GRow)
                if word != nil {
                    let activityItem = ActivityItem(type: .Choosing, choosedWord: word!)
                    activityRoundItem[activityRoundItem.count - 1].activityItems.append(activityItem)
                    lettersForCheck = word!.word + "/" + LettersColor.Green.rawValue
                    returnBool = checkLetters == "" || checkLetters == lettersForCheck
                    saveActualState()
                    saveToGameCenter()
                    setUndoButton(enabled: true)
//                    saveRecord = true
                    modifyHeader()
                } else {
                    
                }
            }
            returnBool = checkLetters == "" || checkLetters == lettersForCheck
//            if GV.generateHelpInfo {
//                let endedInfoData = MovedInfoData(onGameArray: true, relPosX: relativPosition.x, relPosY: relativPosition.y, col: touchedNodes.col, row: touchedNodes.row, GRow: touchedNodes.GRow).toString()
//                helpInfo.endedInfo = endedInfoData
//                if helpInfo.movedInfo.length > 0 {
//                    helpInfo.movedInfo.removeLast()
//                }
//                helpInfo.letters = lettersForCheck
//                if saveRecord {
//                    try! realmHelpInfo!.safeWrite() {
//                        realmHelpInfo!.add(helpInfo)
//                    }
//                }
//            }

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
                setUndoButton(enabled: true)
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
//                if GV.generateHelpInfo {
//                    let movedInfoData = MovedInfoData(onGameArray: true, relPosX: relativPosition.x, relPosY: relativPosition.y, col: touchedNodes.col, row: touchedNodes.row, GRow: touchedNodes.GRow).toString()
//                    helpInfo.endedInfo = movedInfoData
//                    helpInfo.movedInfo.removeLast()
//                    helpInfo.letters = lettersForCheck
//                    if helpInfo.beganInfo == "" {
//                        print("Hier at error: at fixed, counter: \(helpInfo.counter)")
//                        helpInfo.beganInfo = String(movedIndex)
//                    }
//                    try! realmHelpInfo!.safeWrite() {
//                        realmHelpInfo!.add(helpInfo)
//                    }
//                }
//               HintEngine.shared.createHints()
                createHintsInBackground()
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
//                if GV.generateHelpInfo {
//                    let endedInfoData = MovedInfoData(onGameArray: false, relPosX: relativPosition.x, relPosY: relativPosition.y, col: touchedNodes.col, row: touchedNodes.row, GRow: touchedNodes.GRow).toString()
//                    helpInfo.endedInfo += endedInfoData
//                    helpInfo.movedInfo = ""
//                    helpInfo.letters = letters
//                    try! realmHelpInfo!.safeWrite() {
//                        realmHelpInfo!.add(helpInfo)
//                    }
//                }
            } else {
                if !goBackButton!.isEnabled {
                    self.hideButtons(hide: false)
                }
            }
        } else {
//            print("hier")
        }
//        xxx goToPreviousGameButton

        startShapeIndex = -1
        checkFreePlace()
        return returnBool
    }
    @objc private func startNextRound() {
        self.modifyHeader()
//        let roundScore = WTGameWordList.shared.getPointsForLetters()
        wtGameboard!.clearGreenFieldsForNextRound()
        actRound = GV.playingRecord.rounds.count + 1
        createNextRound = true
        self.enabled = true
        self.gameboardEnabled = false
        self.removeNodesWith(name: self.MyQuestionName)
        self.removeNodesWith(name: self.answer2Name)
    }
    
    var hintsCreated = false
    var hintEngine = HintEngine()
    
    private func createHintsInBackground() {
//        if !hintsCreated {
//            return
//        }
        let gameNumber = GV.playingRecord.gameNumber
        let round = GV.playingRecord.rounds.count
        let globalQueue = DispatchQueue.global()
        globalQueue.async {
            self.hintEngine = HintEngine()
            self.hintsCreated = false
            self.hintEngine.createHints(gameNumber: gameNumber, round: round)
            self.hintsCreated = true
        }

    }

    private func saveToGameCenter() {
//        if GV.debug {
//            return
//        }
        if GV.playingRecord.gameNumber > 9999 {
            return
        }
        
        if GV.basicDataRecord.GameCenterEnabled != GCEnabledType.GameCenterEnabled.rawValue {
            GCHelper.shared.sendScoreToGameCenter(score: GV.totalScore, difficulty: GV.basicDataRecord.difficulty, completion: {self.modifyHeader()})
            GCHelper.shared.getBestScore(completion: {[unowned self] in self.modifyHeader()})
        }
        let difficulty = GV.basicDataRecord.difficulty
        let actPlayingTime = GV.basicDataRecord.playingTime
        let actPlayingTimeToday = GV.basicDataRecord.playingTimeToday

        var deviceRecordID = String(GV.getTimeIntervalSince20190101())
        if GV.basicDataRecord.deviceRecordInCloudID != "" {
            deviceRecordID = GV.basicDataRecord.deviceRecordInCloudID
        } else {
            try! realm.safeWrite {
                GV.basicDataRecord.deviceRecordInCloudID = deviceRecordID
            }
        }
//        Saving to iCloud
        let recordID = CKRecord.ID(recordName: deviceRecordID)
        let predicate = NSPredicate(format: "recordID = %@", recordID)
        let query = CKQuery(recordType: "DeviceRecord", predicate: predicate)
        let container = CKContainer.default()
        container.publicCloudDatabase.perform(query, inZoneWith: nil) { results, error in
            if error != nil {
                return
            }
            if results != nil && results!.count > 0 {
                let deviceRecord = results![0]
                deviceRecord["playingTime"] = actPlayingTime
                deviceRecord["lastPlayingTime"] = actPlayingTimeToday
                if deviceRecord["lastPlayed"] != Date().yearMonthDay {
                    deviceRecord["lastPlayed"] = Date().yearMonthDay
                }
                switch difficulty {
                case GameDifficulty.Easy.rawValue:
                    if deviceRecord["bestScoreEasy"] == nil {
                        deviceRecord["bestScoreEasy"] = GV.totalScore
                    } else if (deviceRecord["bestScoreEasy"] as! Int64) < GV.totalScore {
                        deviceRecord["bestScoreEasy"] = GV.totalScore
                    }
                    deviceRecord["actScoreEasy"] = GV.totalScore
                case GameDifficulty.Medium.rawValue:
                    if deviceRecord["bestScoreMedium"] == nil {
                        deviceRecord["bestScoreMedium"] = GV.totalScore
                    } else if (deviceRecord["bestScoreMedium"] as! Int64) < GV.totalScore {
                        deviceRecord["bestScoreMedium"] = GV.totalScore
                    }
                    deviceRecord["actScoreMedium"] = GV.totalScore
                default: break
                }
                
                container.publicCloudDatabase.save(deviceRecord) {
                    (record, error) in
                    if let error = error {
                        // Insert error handling
                        print("Error by save in WTScene2: \(error)")
                        return
                    }
                }
            }
        }
    }
    
    enum CongratulationType: Int {
        case GameFinished, AllWordsCollected, AllLettersCollected
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
    
    public func goBackground() {
        if showFoundedWordsTableView != nil {
            doneButton!.removeFromSuperview()
            questionMarkButton!.removeFromSuperview()
            starButton!.removeFromSuperview()
            retypeButton!.removeFromSuperview()
            sortButton!.removeFromSuperview()
            showFoundedWordsTableView!.removeFromSuperview()
            showFoundedWordsTableView = nil
        }

    }
    
    private func createCongratulationsAlert(congratulationType: CongratulationType, easy: Bool) {
        var title = ""
        var message = ""
//        var finishTitle = ""
//        let showMessage = true
        let myRank = calculateRankForScore(score: GV.ownScore)
        switch congratulationType {
        case .AllWordsCollected:
            title = GV.language.getText(.tcCongratulationsAllWords, values: String(GV.countOfWords), String(GV.ownScore), String(myRank))
            message = GV.language.getText(.tcCongratulationsMessageEasy, values: String(GV.countOfWordsMaxValue + 100))
        case .AllLettersCollected:
            title = GV.language.getText(.tcCongratulationsAllLetters, values: String(GV.countOfLetters), String(GV.ownScore), String(myRank))
            message = GV.language.getText(.tcCongratulationsMessageMedium, values: String(GV.countOfLettersMaxValue + 50))
        default:
            break
        }
//        saveToFinishedGames()
//        let continueTitle = GV.language.getText(.tcContinuePlaying)
        let newTitle = GV.language.getText(.tcNewGame)
        let continueTitle = GV.language.getText(.tcContinueGame)
        let myAlert = MyAlertController(title: title, message: message, target: self, type: .Green)
        myAlert.addAction(text: continueTitle, action: #selector(self.continueAction))
        myAlert.addAction(text: newTitle, action: #selector(self.newAction))
        myAlert.presentAlert()
        myAlert.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
        congratulationsAlert = myAlert
        congratulationsAlert!.name = myAlertName
    }
    
    private func saveToFinishedGames() {
        let finishedGame = FinishedGames()
        let (bestScore, bestName, _, _) = GV.basicDataRecord.getBestScore()
        finishedGame.language = GV.actLanguage
        finishedGame.difficulty = GV.basicDataRecord.difficulty
        finishedGame.countFixedLetters = GV.countOfLetters
        finishedGame.countWords = GV.countOfWords
        finishedGame.myScore = GV.ownScore
        finishedGame.bestScore = bestScore
        finishedGame.bestPlayer = bestName
        finishedGame.myPlace = calculateRankForScore(score: GV.ownScore)
        try! realm.safeWrite() {
            realm.add(finishedGame)
        }
    }
    
//    @objc private func continueMediumAction () {
//        self.enabled = true
//        self.gameboardEnabled = true
//        saveHelpInfo(action: .ContinueGameMedium)
//        self.gameboardEnabled = true
//        self.goOnPlaying = true
//        try! realm.safeWrite() {
//            GV.playingRecord.gameStatus = GV.GameStatusContinued
//        }
//    }

    @objc private func newAction () {
        saveToFinishedGames()
        try! realm.safeWrite() {
            realm.delete(GV.playingRecord)
        }
        newGameButtonTapped()
    }
        
    @objc private func continueAction () {
        if GV.basicDataRecord.difficulty == GameDifficulty.Easy.rawValue {
            setCountWords(count: GV.countOfWordsMaxValue + 100, type: GameDifficulty.Easy)
        }
        if GV.basicDataRecord.difficulty == GameDifficulty.Medium.rawValue {
            setCountWords(count: GV.countOfLettersMaxValue + 50, type: GameDifficulty.Medium)
        }
        saveActualState()
        self.enabled = true
        self.gameboardEnabled = true

    }
        
//    @objc private func finishEasyAction () {
//        self.enabled = true
//        self.gameboardEnabled = true
//        saveHelpInfo(action: .FinishGameEasy)
//        self.gameboardEnabled = true
//        self.finishButtonTapped()
//        self.saveToGameCenter()
//    }
    
//    @objc private func finishMediumAction () {
//        self.enabled = true
//        self.gameboardEnabled = true
//        saveHelpInfo(action: .FinishGameMedium)
//        self.gameboardEnabled = true
//        self.finishButtonTapped()
//        self.saveToGameCenter()
//    }
    var gameFinishedStatus: GameFinishedStatus = .OK
    
    private func showGameFinished(status: GameFinishedStatus) {
        gameFinishedStatus = status
//        if bestScoreForActualGame != nil && bestScoreForActualGame!.count > 0 && bestPlayersReady {
//            let bestName = bestScoreForActualGame![0].owner!.nickName
//            let bestScore = bestScoreForActualGame![0].bestScore
//            let bestScoretext = GV.language.getText(.tcBestScoreHeader, values: String(bestScore).fixLength(length:scoreLength), bestName!)
//            let bestScorelabel = bgSprite!.childNode(withName: bestScoreName) as? SKLabelNode
//            bestScorelabel!.text = bestScoretext
//        }
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
//        var actionTitle = ""
//        let action2Title = GV.language.getText(.tcBack)
        var myAlert: MyAlertController!
        if gameFinishedStatus == .OK {
            title = GV.language.getText(.tcGameFinished1)
            message = GV.language.getText(.tcGameFinished2)
            myAlert = MyAlertController(title: title, message: message, target: self, type: .Red)
            if GV.basicDataRecord.difficulty != GameDifficulty.Medium.rawValue {
                myAlert.addAction(text: GV.language.getText(.tcNewGame5), action: #selector(newGame5ButtonTapped))
                myAlert.addAction(text: GV.language.getText(.tcNewGame6), action: #selector(newGame6ButtonTapped))
                myAlert.addAction(text: GV.language.getText(.tcNewGame7), action: #selector(newGame7ButtonTapped))
                myAlert.addAction(text: GV.language.getText(.tcNewGame8), action: #selector(newGame8ButtonTapped))
                myAlert.addAction(text: GV.language.getText(.tcNewGame9), action: #selector(newGame9ButtonTapped))
                myAlert.addAction(text: GV.language.getText(.tcNewGame10), action: #selector(newGame10ButtonTapped))
            } else {
                myAlert.addAction(text: GV.language.getText(.tcNewGame), action: #selector(newGameButtonTapped))
            }
        } else {
            title = GV.language.getText(.tcTaskNotCompletedWithNoMoreSteps)
            message = GV.language.getText(.tcWillBeRestarted)
            myAlert = MyAlertController(title: title, message: message, target: self, type: .Red)
            myAlert.addAction(text: GV.language.getText(.tcNewGame), action: #selector(newGameButtonTapped))

//            actionTitle = GV.language.getText(.tcRestartGame)
        }
//        let myAlert = MyAlertController(title: title, message: message, target: self, type: .Red)
        //        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
//        myAlert.addAction(text: action1Title, action: #selector(newGameButtonTapped))
//        myAlert.addAction(text: action2Title, action: #selector(goBackButtonTapped2))
        myAlert.presentAlert()
        myAlert.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
        finishGameAlert = myAlert
        finishGameAlert!.name = myAlertName
    }
    
    @objc private func newGameButtonTapped() {
        gameboardEnabled = true
        enabled = true
        if gameFinishedStatus == .OK {
            self.startNewGame()
        } else {
            self.restartThisGame()
        }
    }
    
    @objc private func newGame5ButtonTapped() {
        GV.sizeOfGrid = 5
        newGameButtonTapped()
    }
    
    @objc private func newGame6ButtonTapped() {
        GV.sizeOfGrid = 6
        newGameButtonTapped()
    }
    
    @objc private func newGame7ButtonTapped() {
        GV.sizeOfGrid = 7
        newGameButtonTapped()
    }
    
    @objc private func newGame8ButtonTapped() {
        GV.sizeOfGrid = 8
        newGameButtonTapped()
    }
    
    @objc private func newGame9ButtonTapped() {
        GV.sizeOfGrid = 9
        newGameButtonTapped()
    }
    
    @objc private func newGame10ButtonTapped() {
        GV.sizeOfGrid = 10
        newGameButtonTapped()
    }
    
    @objc private func goBackButtonTapped2() {
//        saveHelpInfo(action: .ContinueGameEasy)
        gameboardEnabled = true
        enabled = true
    }
    
    private func saveActualState() {
        var pieces = ""
        for tile in tilesForGame {
            pieces += tile.toString() + itemSeparator
        }
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
//            GV.playingRecord.allWordsString = WTGameWordList.shared.allWordsToString()
//            GV.playingRecord.wordsInRoundString = WTGameWordList.shared.wordsInRoundToString()
            
            var activityItemsString = ""
            if activityRoundItem.count == 0 {
                activityRoundItem.append(ActivityRound())
                activityRoundItem[activityRoundItem.count - 1].activityItems = [ActivityItem]()
            }
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
//        modifyDifficultyLabels(number: calculatePlace())
    }
    
    enum GameStatus: Int {
        case Playing = 0, NextRondPossible, Finish
    }
    
    var gameStatus: GameStatus = .Playing
    
    private func setGameStatus() {
        for piece in pieceArray {
            for rotateIndex in 0..<4 {
                if wtGameboard!.checkFreePlaceForPiece(piece: piece, rotateIndex: rotateIndex) {
                    gameStatus = .Playing
                    return
                }
            }
        }
        let greenWordsCount = WTGameWordList.shared.getCountWordsInLastRound()
        if greenWordsCount > 0 {
            gameStatus = .NextRondPossible
        } else {
            gameStatus = .Finish
        }
        modifyfinishButton()
    }
    
    private func checkFreePlace() {
        setGameStatus()
        switch  gameStatus {
        case .Playing: return
        case .NextRondPossible:
            return
        case .Finish:
            return
        }

    }

    var noMoreStepsAlert: MyAlertController?

    @objc private func nextRoundTapped() {
        self.enabled = true
//        saveHelpInfo(action: .NoMoreStepsNext)
        stopShowingTableIfNeeded()
        startNextRound()
        modifyHeader()
        gameStatus = .Playing
        modifyfinishButton()
    }
    
    @objc private func startUndoTapped() {
        self.enabled = true
//        saveHelpInfo(action: .NoMoreStepsBack)
        startUndo()
    }
    
    private func removeNodesWith(name: String) {
        while bgSprite!.childNode(withName: name) != nil {
            bgSprite!.childNode(withName: name)!.removeFromParent()
        }
    }
    
//    var gameNumberForGenerating = 10000
    
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
        if GV.countBlinkingNodes > 0 {
            stopBlinkingNodesIfNeeded()
//            return
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

//        if GV.generateHelpInfo {
//            saveHelpInfo(action: .UndoButton)
//        }
        if activityRoundItem[activityRoundItem.count - 1].activityItems.count == 0 {
            actRound = GV.playingRecord.rounds.count - 1
            if activityRoundItem.count > 0 {
                try! realm.safeWrite() {
                    GV.playingRecord.rounds.removeLast()
                }
                activityRoundItem.removeLast()
                timeForGame.decrementMaxTime(value: iHalfHour)
                GV.totalScore = 0
//                GV.mandatoryScore = 0
                GV.ownScore = 0
//                GV.bonusScore = 0
                wtGameboard!.setRoundInfos()
                WTGameWordList.shared.reset()
                WTGameWordList.shared.restoreFromPlayingRecord()
                restoreGameArray()
                modifyHeader()
//                checkIfGameFinished(showAlert: false)
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
//                    HintEngine.shared.createHints()
                    createHintsInBackground()
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
//                checkIfGameFinished()
//                saveActualState()
//                saveToGameCenter()
                activityRoundItem[activityRoundItem.count - 1].activityItems.removeLast()
                modifyHeader()
            }
            saveActualState()
//            HintEngine.shared.createHints()
            createHintsInBackground()
            saveToGameCenter()
        }
        if activityRoundItem[activityRoundItem.count - 1].activityItems.count == 0 && activityRoundItem.count == 1 {
//            if GV.generateHelpInfo {
//                resetHelpInfo()
//            }
            setUndoButton(enabled: false)
            GV.totalScore = 0
            wtGameboard!.clearGameArray()
        }
        setGameStatus()
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
        wtGameboard!.clearGameArray(all: true)
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
        if activityRoundItem[0].activityItems.count > 0 {
            setUndoButton(enabled: true)
        }
        timeForGame = TimeForGame(from: GV.playingRecord.time)
//        wtGameboard!.checkWholeWords()
    }
    
    private func generateArrayOfWordPieces(first: Bool)->String {
        let date = Date()
        let calendar = Calendar.current
        let theDayOfMonth = calendar.component(.day, from: date)
        let gameNumberForSelect = GV.playingRecord.gameNumber % 1000
        let gameNumberForRandom = GV.playingRecord.gameNumber * theDayOfMonth
        let random = MyRandom(gameNumber: gameNumberForRandom, modifier: GV.playingRecord.words.count)
        var tileType = MyShapes.NotUsed
//        var letters = [String]()
//        var generateLength = 0
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
        var countSplittedWords = usedWords.count
        var countPieces = tilesForGame.count
        func splittingWord(word: String) {
            var inputWord = ""
            countSplittedWords += 1
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
                if letterCounters[String(letter)] == nil {
                    letterCounters[String(letter)] = 0
                }
                letterCounters[String(letter)]! += 1
            }
            usedWords.append(inputWord)
            wordsString += inputWord + itemSeparator
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
                pieceString += itemSeparator
                let newIndex = tilesForGame.count
                if newIndex == tilesForGame.count || !first || usedWords.count > 6 /*|| GV.playingRecord.gameNumber % 1000 == 0 */{
                    tilesForGame.append(tileForGameItem)
                } else {
                    tilesForGame.insert(tileForGameItem, at: newIndex)
                }
                countPieces += 1

            } while inputWord.length > 0
        }
        if first {
            let actRecord = realmMandatory.objects(MandatoryModel.self).filter("combinedKey = %d", GV.actLanguage + String(gameNumberForSelect))[0]
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
            var allRecords: Results<HintModel>
//            var allRecords: Results<HintsModel>
            repeat {
                allRecords = realmMandatoryList.objects(HintModel.self).filter("language = %d", GV.actLanguage).filter("word CONTAINS %@", letters[index].lowercased())
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
            generatedArrayInStringForm += tile.toString() + itemSeparator
        }
        wordsString.removeLast()
//        print("wordString: \(wordsString)")
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
//        print("letters: \(word)")
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

    
    var showOwnWordsTablSeView: WTTableView?
    var showHintsTableView: WTTableView?
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
    var globalMaxLength = 0
    var showingInTableViewActive = false
    let myFont = UIFont(name: GV.actLabelFont /*"CourierNewPS-BoldMT"*/, size: GV.onIpad ? 18 : 15)
    let myTitleFont = UIFont(name: GV.actFont, size: GV.onIpad ? 30 : 15)

    private func showOwnWordsInTableView() {
        tableType = .ShowAllWords
        showOwnWordsTablSeView = WTTableView()
        timerIsCounting = false
        var words: [FoundedWordWithCounter]
        (words, globalMaxLength) = WTGameWordList.shared.getWordsForShow()
        ownWordsForShow = WordsForShow(words: words)
        calculateColumnWidths()
        let suffix = " (\(GV.countOfWords)/\(ownWordsForShow!.countWords)/\(ownWordsForShow!.score))"
        let headerText = (GV.language.getText(.tcCollectedOwnWords) + suffix)
        let actWidth = max(title.width(font: myFont!), headerText.width(font: myFont!)) * 1.2

        showOwnWordsTablSeView?.setDelegate(delegate: self)
        showOwnWordsTablSeView?.register(CustomTableViewCell.self, forCellReuseIdentifier: "cell")
        let origin = CGPoint(x: 0.5 * (self.frame.width - actWidth), y: self.frame.height * 0.08)
        let lineHeight = title.height(font:myFont!)
        let headerframeHeight = lineHeight * 2.3
        var showingWordsHeight = CGFloat(ownWordsForShow!.words.count) * lineHeight
        if showingWordsHeight  > self.frame.height * 0.8 {
            var counter = CGFloat(ownWordsForShow!.words.count)
            repeat {
                counter -= 1
                showingWordsHeight = lineHeight * counter
            } while showingWordsHeight + headerframeHeight > self.frame.height * 0.8
        }
        if globalMaxLength < GV.language.getText(.tcWord).count {
            globalMaxLength = GV.language.getText(.tcWord).count
        }
        let size = CGSize(width: actWidth, height: showingWordsHeight + headerframeHeight)
        showOwnWordsTablSeView?.frame=CGRect(origin: origin, size: size)
        self.showOwnWordsTablSeView?.reloadData()
//        self.scene?.alpha = 0.2
        self.scene?.view?.addSubview(showOwnWordsTablSeView!)
        self.hideButtons(hide: true)
    }
    
//    private func getHintsForShow()->([String], Int) {
//        var returnArray = [String]()
//        var returnValue = 0
//        for item in GV.hintTable {
//            returnValue = returnValue < item.hint.length ? item.hint.length : returnValue
//            returnArray.append(hint)
//        }
//        return (returnArray, returnValue)
//    }
//
    var hintsTableForShow = [HintForShow]()
    var hintHeaderLine = ""
    private func showHintsInTableView() {
        tableType = .ShowHints
        showHintsTableView = WTTableView()
        showingInTableViewActive = true
        timerIsCounting = false
        globalMaxLength = 0

        hintsTableForShow.removeAll()
        let sortedTable = GV.hintTable.sorted(by: {$0.type.rawValue < $1.type.rawValue ||
            ($0.type.rawValue == $1.type.rawValue && $0.hint.length > $1.hint.length) ||
            ($0.type.rawValue == $1.type.rawValue && $0.hint.length == $1.hint.length && $0.hint < $1.hint)})
        for item in sortedTable {
            let score = WTGameWordList.shared.getScoreForWord(word: item.hint)
            if item.hint.length > globalMaxLength {
                globalMaxLength = item.hint.length
            }
            hintsTableForShow.append(HintForShow(hint: item.hint, score: score, type: item.type, count: item.count))
        }
//        ownWordsForShow = WordsForShow(words: words)
        calculateColumnWidths(showCount: false)
        hintHeaderLine = (GV.language.getText(.tcHintsHeader))
        let actWidth = max(title.width(font: myFont!), hintHeaderLine.width(font: myFont!)) * 1.1

        showHintsTableView?.setDelegate(delegate: self)
        showHintsTableView?.register(CustomTableViewCell.self, forCellReuseIdentifier: "cell")
        let origin = CGPoint(x: 0.5 * (self.frame.width - actWidth), y: self.frame.height * 0.08)
        let lineHeight = title.height(font:myFont!)
        let headerframeHeight = lineHeight * 2.3
        var showingWordsHeight = CGFloat(hintsTableForShow.count) * lineHeight
        if showingWordsHeight  > self.frame.height * 0.8 {
            var counter = CGFloat(hintsTableForShow.count)
            repeat {
                counter -= 1
                showingWordsHeight = lineHeight * counter
            } while showingWordsHeight + headerframeHeight > self.frame.height * 0.8
        }
        if globalMaxLength < GV.language.getText(.tcWord).count {
            globalMaxLength = GV.language.getText(.tcWord).count
        }
        let size = CGSize(width: actWidth, height: showingWordsHeight + headerframeHeight)
        showHintsTableView?.frame=CGRect(origin: origin, size: size)
        self.showHintsTableView?.reloadData()
//        self.scene?.alpha = 0.2
        self.scene?.view?.addSubview(showHintsTableView!)
        self.hideButtons(hide: true)
    }
    
    func startShowingWordsOverPosition(wordList: [SelectedWord]) {
        if wordList.count == 0 {
            return
        }
        tableType = .ShowWordsOverPosition
        showWordsOverPositionTableView = WTTableView()
        showingInTableViewActive = true
        self.wordList = wordList
        timerIsCounting = false
        globalMaxLength = 0
        for selectedWord in wordList {
            let word = selectedWord.word
            globalMaxLength = word.length > globalMaxLength ? word.length : globalMaxLength
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
        if globalMaxLength < title.length {
            globalMaxLength = title.length
        }
        let width = title.width(font: myFont!)
        let size = CGSize(width: width, height: showingWordsHeight + headerframeHeight)
        showWordsOverPositionTableView?.frame=CGRect(origin: origin, size: size)
        self.showWordsOverPositionTableView?.reloadData()
        
        //        showOwnWordsTableView?.reloadData()
        self.scene?.view?.addSubview(showWordsOverPositionTableView!)
        
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
    
    private func searchWords(lettersToSearch: [String]) {
        let filter1 = "word like %@ and word BEGINSWITH %@"
        let filter2 = " and word CONTAINS %@"
        let filter = filter1 + filter2 + filter2 + filter2 + filter2 + filter2
        let founded = realmWordList.objects(WordListModel.self).filter(filter, "????????", "hu", "hu", "a", "a", "f", "l", "m")
        for item in founded {
            var counter = 0
            for char in item.word.subString(at: 2, length: item.word.length - 2) {
                if lettersToSearch.contains(String(char)) {
                    counter += 1
                }
            }
            if counter == item.word.length - 2 {
                print(item.word)
            }
        }
        print(founded.count)
    }


    deinit {
        print("\n THE SCENE \((type(of: self))) WAS REMOVED FROM MEMORY (DEINIT) \n")
    }
    
}
