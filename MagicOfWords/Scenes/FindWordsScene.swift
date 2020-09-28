////
////  FindWordsScene.swift
////  MagicOfWords
////
////  Created by Romhanyi Jozsef on 2020. 09. 15..
////  Copyright © 2020. Jozsef Romhanyi. All rights reserved.
////
//
//
//import Foundation
//import Realm
//import RealmSwift
//import SpriteKit
//import GameplayKit
//import AVFoundation
//import UIKit
//
//class MyFoundedWord: MyLabel {
//    var usedWord: UsedWord?
//    var mandatory: Bool = false
//    var founded: Bool = false
//    init(usedWord: UsedWord, mandatory: Bool, prefixValue: Int) {
//        let wordsFontSize = CGFloat(GV.onIpad ? 18 : 11)
////        let wordFont = UIFont(name: "Menlo-Bold", size: CGFloat(GV.onIpad ? 18 : 11))
//
//        self.usedWord = usedWord
//        self.mandatory = mandatory
//        let prefix = (prefixValue < 10 ? "0" : "") + "\(prefixValue). "
//        let myText =  prefix + (mandatory ? GV.questionMark.fill(with: GV.questionMark, toLength: usedWord.word.length) : usedWord.word)
////        let myName = usedWord.word + (mandatory ? GV.mandatoryLabelInName : GV.ownLabelInName)
//        super.init(text: myText, position: CGPoint(x: 0, y: 0), fontName: GV.headerFontName, fontSize: wordsFontSize)
//        self.horizontalAlignmentMode = .left
//        self.nodeType = .MyLabel
//    }
//    
//    public func setQuestionMarks() {
//        var newText = text!.startingSubString(length: 4)
//        for letter in usedWord!.usedLetters {
//            newText += GV.gameArray[letter.col][letter.row].status == .WholeWord ? letter.letter : GV.questionMark
//        }
//        text = newText
//    }
//    
//    required init?(coder aDecoder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//}
//
//
//public struct UsedWord {
//    var word = ""
//    var usedLetters = [UsedLetter]()
//    static func +(lhs: UsedWord, rhs: UsedWord)->UsedWord {
//        return UsedWord(word: lhs.word + rhs.word, usedLetters: lhs.usedLetters + rhs.usedLetters)
//    }
//    public func reversed()->UsedWord {
//        var returnValue = UsedWord()
//        for index in 0..<self.word.length {
//            returnValue.usedLetters.insert(self.usedLetters[index], at: 0)
//        }
//        returnValue.word = String(self.word.reversed())
//        return returnValue
//    }
//    init(word: String, usedLetters: [UsedLetter]) {
//        self.word = word
//        self.usedLetters = usedLetters
//    }
//    init(from: String="") {
//        let parts = from.components(separatedBy: GV.innerSeparator)
//        word = parts[0]
//        for usedLetter in parts[1...] {
//            if let col = Int(usedLetter.char(at: 0)) {
//                if let row = Int(usedLetter.char(at: 1)) {
//                    let letter = usedLetter.char(at: 2)
//                    usedLetters.append(UsedLetter(col: col, row: row, letter: letter))
//                }
//            }
//        }
//    }
//    public mutating func append(_ usedLetter: UsedLetter) {
//        self.word += usedLetter.letter
//        self.usedLetters.append(usedLetter)
//    }
//    public mutating func removeLast() {
//        self.word.removeLast()
//        self.usedLetters.removeLast()
//    }
//    public var count: Int {
//        return self.word.length
//    }
//    static public func ==(lhs: UsedWord, rhs: UsedWord) -> Bool {
//        if lhs.usedLetters.count != rhs.usedLetters.count {
//            return false
//        }
//        for index in 0..<lhs.usedLetters.count {
//            if !(lhs.usedLetters[index] == rhs.usedLetters[index]) {
//                return false
//            }
//        }
//        return lhs.word == rhs.word
//    }
//    
//    public func toString()->String {
//        var returnValue = ""
//        returnValue += word
//        for item in usedLetters {
//            returnValue += GV.innerSeparator + item.toString()
//        }
//        return returnValue
//    }
//}
//
//
//
//public protocol FindWordsSceneProtocol: class {
////    func goBackFromFindWords()
//}
//class ObjectSP {
//    var frame = CGRect(x: 0, y: 0, width: 0, height: 0)
//    var name = ""
//    init(_ frame: CGRect, _ name: String){
//        self.frame = frame
//        self.name = name
//    }
//}
//
//class FindWordsScene: SKScene {
//    var playedGamesRealm = getRealm(type: .PlayedGameRealm)
//    var myDelegate: MainViewController?
//    var blockSize = CGFloat(0)
//    var gameLayer = SKSpriteNode()
//    var mySounds = MySounds()
//
////    var playingLayer = SKSpriteNode()
//    var myFont = UIFont()
//    let myFontName = "ChalkboardSE-Light"
////    let wordFontSizeMpx: CGFloat = GV.onIpad ? 0.020 : 0.02
//    override func didMove(to view: SKView) {
//        headerMpx = GV.onIpad ? 0.03 : 0.05
//    }
//    public func start(delegate: MainViewController) {
////        newWordListRealm = getNewWordList()
//        oldOrientation = GV.actHeight > GV.actWidth
////        setGlobalSizes()
////        wordsFontSize = GV.minSide * wordFontSizeMpx
////        gameLayer.addChild(gameLayer)
//        self.backgroundColor = .green
////        gameLayer.size = CGSize(width: GV.actWidth, height: GV.actHeight)
////        gameLayer.position = CGPoint(x: GV.actWidth * 0.5, y: GV.actHeight * 0.5)
//        gameLayer = SKSpriteNode()
//        setBackground(to: gameLayer)
//        self.addChild(gameLayer)
//        GV.target = self
//        GV.orientationHandler = #selector(handleOrientation)
//        self.size = CGSize(width: GV.actWidth, height: GV.actHeight)
//        myFont = UIFont(name: myFontName, size: GV.actHeight * 0.03)!
//        playedGamesRealm = getRealm(type: .PlayedGameRealm)
//        myDelegate = delegate
//        startNewGame()
//    }
//    
//    var oldOrientation = false
////    var mySounds = MySounds()
//    
//    @objc private func handleOrientation() {
//        if oldOrientation == (GV.actHeight > GV.actWidth) {
//            return
//        }
//        oldOrientation = GV.actHeight > GV.actWidth
//        self.size = CGSize(width: GV.actWidth,height: GV.actHeight)
//        self.view!.frame = CGRect(x: 0, y: 0, width: GV.actWidth, height: GV.actHeight)
////        gameLayer.size = self.size
//        setBackground()
////        gameLayer.setOrientationAllChildren()
////        switch actScreenState {
////        case .Nothing:
////            return
////        case .ChoosePlaingType:
////            setGameMenuSizesAndPositions()
//////        case .ChooseGame:
//////            playGame(size: GV.sizeOfGrid)
////        case .Playing:
////            setPlayingGameSizesAndPositions()
////        }
//    }
//    
////    private func showBackground() {
//////        self.position = UIScreen.main.bounds
////        let backGroundBild = SKSpriteNode(texture: SKTexture(imageNamed: GV.actHeight > GV.actWidth ? "PortraitBG" : "LandscapeBG"), color: .clear, size: self.size)
////        gameLayer.addChild(backGroundBild)
////        let shortSide = max(self.frame.width, self.frame.height)
////        let multiplier = shortSide / min(self.frame.width, self.frame.height)
////        let longSide = shortSide * multiplier
////        backGroundBild.position = CGPoint(x: UIScreen.main.bounds.midX + 100, y: UIScreen.main.bounds.midY)
////        backGroundBild.size = CGSize(width: longSide, height: shortSide)
////        gameLayer.addChild(menuLayer)
////    }
//    
////    var GV.actHeight: CGFloat = 0
////    var GV.actWidth: CGFloat = 0
////    enum ScreenStates: Int {
////        case Nothing = 0, ChoosePlaingType, Playing
////    }
////    var actScreenState: ScreenStates = .Nothing
////
////    var actNames = [Int:String]()
////    private func setGameMenuSizesAndPositions() {
////        let heightMpx: CGFloat = GV.onIpad ? 0.04 : 0.06
////
////        if GV.actHeight > GV.actWidth {
////            let objects: [ObjectSP] = [
////                ObjectSP(CGRect(x: GV.minSide * 0.5, y: GV.maxSide * 0.90, width: GV.minSide * 0.5, height: GV.maxSide * heightMpx), GameHeaderName),
////                ObjectSP(CGRect(x: GV.minSide * 0.5, y: GV.maxSide * 0.85, width: GV.minSide * 0.5, height: GV.maxSide * heightMpx), NewGameButtonName),
////                ObjectSP(CGRect(x: GV.minSide * 0.5, y: GV.maxSide * 0.80, width: GV.minSide * 0.5, height: GV.maxSide * heightMpx), ReplayGameButtonName),
////                ObjectSP(CGRect(x: GV.minSide * 0.5, y: GV.maxSide * 0.30, width: GV.minSide * 0.5, height: GV.maxSide * heightMpx), GoBackName)
////            ]
////            setPosItionsAndSizesOfNodesWithActNames(layer: gameLayer, objects: objects)
////        } else {
////            let yPos1: CGFloat = GV.actHeight - GV.actHeight * (GV.onIpad ? 0.10 : 0.10)
////            let yPos2: CGFloat = GV.actHeight - GV.actHeight * (GV.onIpad ? 0.20 : 0.20)
////            let yPos3: CGFloat = GV.actHeight - GV.actHeight * (GV.onIpad ? 0.32 : 0.32)
////            let yPos4: CGFloat = GV.actHeight - GV.actHeight * (GV.onIpad ? 0.60 : 0.60)
////
////            let objects: [ObjectSP] = [
////                ObjectSP(CGRect(x: GV.actWidth * 0.5, y: yPos1, width: GV.minSide * 0.5, height: GV.maxSide * heightMpx), GameHeaderName),
////                ObjectSP(CGRect(x: GV.actWidth * 0.5, y: yPos2, width: GV.minSide * 0.5, height: GV.maxSide * heightMpx), NewGameButtonName),
////                ObjectSP(CGRect(x: GV.actWidth * 0.5, y: yPos3, width: GV.minSide * 0.5, height: GV.maxSide * heightMpx), ReplayGameButtonName),
////                ObjectSP(CGRect(x: GV.actWidth * 0.5, y: yPos4, width: GV.minSide * 0.5, height: GV.maxSide * heightMpx), GoBackName)
////            ]
////            setPosItionsAndSizesOfNodesWithActNames(layer: gameLayer, objects: objects)
////
////        }
////    }
//    var headerMpx: CGFloat = 0
//
//
////    @objc private func showGamesMenu() {
////        removeChildrenExceptTypes(from: gameLayer, types: [.Background])
////        let gameMenuTitlePosition = PLPosSize(PPos: CGPoint(x: GV.minSide * 0.5, y: GV.maxSide * 0.9),
////                                              LPos: CGPoint(x: GV.maxSide * 0.5, y: GV.minSide * 0.9),
////                                              PSize: nil, LSize: nil)
////        let gameMenuHeader = MyLabel(text: GV.language.getText(.tcSearchWords), position: gameMenuTitlePosition, fontName: GV.headerFontName, fontSize: GV.minSide * headerMpx)
////        gameLayer.addChild(gameMenuHeader)
//////        addButton(to: gameLayer, text: GV.language.getText(.tcPlayGame), action: #selector(startNewGame))
////        let newGameTitlePosition = PLPosSize(PPos: CGPoint(x: GV.minSide * 0.5, y: GV.maxSide * 0.8),
////                                             LPos: CGPoint(x: GV.maxSide * 0.5, y: GV.minSide * 0.8),
////                                             PSize: nil,
////                                             LSize: nil)
////        let newGameTitle = MyLabel(text: GV.language.getText(.tcPlayGame), position: newGameTitlePosition, fontName: GV.headerFontName, fontSize: GV.minSide * headerMpx)
////        gameLayer.addChild(newGameTitle)
////        addShortButtonPL(to: gameLayer, text: "5x5", action: #selector(startNew5x5Game), col: 0, headerNode: newGameTitle, countCols: 6)
////        addShortButtonPL(to: gameLayer, text: "6x6", action: #selector(startNew6x6Game), col: 1, headerNode: newGameTitle, countCols: 6)
////        addShortButtonPL(to: gameLayer, text: "7x7", action: #selector(startNew7x7Game), col: 2, headerNode: newGameTitle, countCols: 6)
////        addShortButtonPL(to: gameLayer, text: "8x8", action: #selector(startNew8x8Game), col: 3, headerNode: newGameTitle, countCols: 6)
////        addShortButtonPL(to: gameLayer, text: "9x9", action: #selector(startNew9x9Game), col: 4, headerNode: newGameTitle, countCols: 6)
////        addShortButtonPL(to: gameLayer, text: "10x10", action: #selector(startNew10x10Game), col: 5, headerNode: newGameTitle, countCols: 6)
////
////        let finishedGameTitlePosition = PLPosSize(PPos: CGPoint(x: GV.minSide * 0.5, y: GV.maxSide * 0.6),
////                                                  LPos: CGPoint(x: GV.maxSide * 0.5, y: GV.minSide * 0.6),
////                                                  PSize: nil,
////                                                  LSize: nil)
////        let finishedGameTitle = MyLabel(text: GV.language.getText(.tcFinishedGame), position: finishedGameTitlePosition, fontName: GV.headerFontName, fontSize: GV.minSide * headerMpx)
////        gameLayer.addChild(finishedGameTitle)
////        addShortButtonPL(to: gameLayer, text: "5x5", action: #selector(startFinished5x5Game), col: 0, headerNode: finishedGameTitle, countCols: 6)
////        addShortButtonPL(to: gameLayer, text: "6x6", action: #selector(startFinished6x6Game), col: 1, headerNode: finishedGameTitle, countCols: 6)
////        addShortButtonPL(to: gameLayer, text: "7x7", action: #selector(startFinished7x7Game), col: 2, headerNode: finishedGameTitle, countCols: 6)
////        addShortButtonPL(to: gameLayer, text: "8x8", action: #selector(startFinished8x8Game), col: 3, headerNode: finishedGameTitle, countCols: 6)
////        addShortButtonPL(to: gameLayer, text: "9x9", action: #selector(startFinished9x9Game), col: 4, headerNode: finishedGameTitle, countCols: 6)
////        addShortButtonPL(to: gameLayer, text: "10x10", action: #selector(startFinished10x10Game), col: 5, headerNode: finishedGameTitle, countCols: 6)
////
//////        addButton(to: gameLayer, text: GV.language.getText(.tcFinishedGame), action: #selector(startFinishedGame))
////        addButtonPL(to: gameLayer, text: GV.language.getText(.tcBack), action: #selector(goBack), line: GoBack)
//////        setGameMenuSizesAndPositions()
////    }
////    
//    private func addShortButtonPL(to: SKSpriteNode, text: String, action: Selector, col: CGFloat, headerNode: SKNode, countCols: CGFloat) {
//        let button = MyButton(fontName: GV.fontName, size: CGSize(width: 100, height: 100))
//        button.zPosition = self.zPosition + 20
//        button.setButtonLabel(title: text, font: UIFont(name: GV.fontName, size: GV.minSide * 0.04)!)
//        button.setButtonAction(target: self, triggerEvent: .TouchUpInside, action: action)
//        let buttonPlace = GV.minSide / (countCols + 1)
//        let buttonWidth = buttonPlace * 0.8
//        let adderP = (GV.minSide * col * 0.15)
//        let adderL = (GV.maxSide * col * 0.15)
//        let headerNodeHeight = headerNode.frame.height
//        button.plPosSize = PLPosSize(PPos: CGPoint(x: GV.minSide * 0.10 + adderP, y: (headerNode.plPosSize?.PPos.y)! - headerNodeHeight),
//                                     LPos: CGPoint(x: GV.maxSide * 0.10 + adderL, y: (headerNode.plPosSize?.LPos.y)! - headerNodeHeight),
//                                     PSize: CGSize(width: buttonWidth, height: GV.maxSide * 0.04),
//                                     LSize: CGSize(width: buttonWidth, height: GV.maxSide * 0.04))
//        button.nodeType = .MyButton
//        button.setActPosSize()
//        button.name = name
//        to.addChild(button)
//
//    }
//    
////    @objc private func startNew5x5Game() {
////        GV.sizeOfGrid = 5
////        startNewGame(new: true)
////    }
////    
////    @objc private func startNew6x6Game() {
////        GV.sizeOfGrid = 6
////        startNewGame(new: true)
////    }
////    
////    @objc private func startNew7x7Game() {
////        GV.sizeOfGrid = 7
////        startNewGame(new: true)
////    }
////    
////    @objc private func startNew8x8Game() {
////        GV.sizeOfGrid = 8
////        startNewGame(new: true)
////    }
////    
////    @objc private func startNew9x9Game() {
////        GV.sizeOfGrid = 9
////        startNewGame(new: true)
////    }
////    
////    @objc private func startNew10x10Game() {
////        GV.sizeOfGrid = 10
////        startNewGame(new: true)
////    }
////    
////    @objc private func startFinished5x5Game() {
////        GV.sizeOfGrid = 5
////        startNewGame(new: false)
////    }
////    
////    @objc private func startFinished6x6Game() {
////        GV.sizeOfGrid = 6
////        startNewGame(new: false)
////    }
////    
////    @objc private func startFinished7x7Game() {
////        GV.sizeOfGrid = 7
////        startNewGame(new: false)
////    }
////    
////    @objc private func startFinished8x8Game() {
////        GV.sizeOfGrid = 8
////        startNewGame(new: false)
////    }
////    
////    @objc private func startFinished9x9Game() {
////        GV.sizeOfGrid = 9
////        startNewGame(new: false)
////    }
////    
////    @objc private func startFinished10x10Game() {
////        GV.sizeOfGrid = 10
////        startNewGame(new: false)
////    }
//    
//    private func addButtonPL(to: SKNode, text: String, action: Selector, line: CGFloat) {
//        let button = MyButton(fontName: GV.fontName, size: CGSize(width: GV.maxSide * 1.1, height: GV.minSide * 0.08))
//        button.zPosition = self.zPosition + 20
//        button.setButtonLabel(title: text, font: UIFont(name: GV.fontName, size: GV.minSide * 0.04)!)
//        button.setButtonAction(target: self, triggerEvent: .TouchUpInside, action: action)
//        if line == GoBack {
//            button.plPosSize = PLPosSize(PPos: CGPoint(x: GV.minSide * 0.5, y: (GV.maxSide * 0.05)),
//                                         LPos: CGPoint(x: GV.maxSide * 0.5, y: (GV.maxSide * 0.05)),
//                                         PSize: CGSize(width: GV.minSide * 0.4, height: GV.maxSide * 0.05),
//                                         LSize: CGSize(width: GV.minSide * 0.4, height: GV.maxSide * 0.05))
//        } else {
//            button.plPosSize = PLPosSize(PPos: CGPoint(x: GV.minSide * 0.5, y: (GV.maxSide * 0.8) - (line * GV.maxSide * 0.06)),
//                                         LPos: CGPoint(x: GV.maxSide * 0.5, y: (GV.minSide * 0.8) - (line * GV.maxSide * 0.06)),
//                                         PSize: CGSize(width: GV.minSide * 0.6, height: GV.maxSide * 0.05),
//                                         LSize: CGSize(width: GV.minSide * 0.6, height: GV.maxSide * 0.05))
//        }
//        button.nodeType = .MyButton
//        button.setActPosSize()
//        button.name = name
//        to.addChild(button)
//    }
//
//    
////    private func addButton(to: SKSpriteNode, text: String, action: Selector, name: String) {
////        let myFont = UIFont(name: GV.headerFontName, size: GV.buttonFontSize)!
////        let button = MyButton(fontName: GV.headerFontName, size: CGSize(width: GV.maxSide * 1.1, height: GV.minSide * 0.08))
////        to.addChild(button)
////        button.setButtonLabel(title: text, font: myFont)
////        button.setButtonAction(target: self, triggerEvent: .TouchUpInside, action: action)
////        button.position = CGPoint(x: GV.actWidth * 0.5, y: (GV.actHeight * 0.2))
////        button.size = CGSize(width: GV.minSide * 0.6, height: GV.maxSide * 0.07)
////        button.zPosition = to.zPosition + 10
////        button.name = name
////    }
////
//    private func setPosItionsAndSizesOfNodesWithActNames(layer: SKNode, objects: [ObjectSP]) {
//        for index in 0..<objects.count {
//            let name = objects[index].name
//            let buttonName = name.contains("Button")
//            let labelName = name.contains("Label")
//            let gridName = name.contains("Grid")
//            if let node = layer.childNode(withName: name) {
//                switch (buttonName, labelName, gridName) {
//                case (true, false, false):
//                    (node as! MyButton).size = objects[index].frame.size
//                    (node as! MyButton).position = objects[index].frame.origin
//                case (false, true, false):
//                    (node as! MyLabel).position = objects[index].frame.origin
//                case (false, false, true):
//                    (node as! Grid).size = objects[index].frame.size
//                    (node as! Grid).position = objects[index].frame.origin
//                default:
//                    break
//                }
//            }
//        }
//    }
//
//
//    
//    let GoBack: CGFloat = 1000
//    
//    @objc private func goBack() {
//        removeChildrenExceptTypes(from: self, types: [.Background])
////        myDelegate!.goBack()
//    }
//    
//    @objc private func startNewGame() {
//        myLabels.removeAll()
//        allWords.removeAll()
//        mandatoryWords.removeAll()
//        let maxGameNumber = 99
//        let startGameNumber = 0
//        var primary = GV.actLanguage + GV.innerSeparator + "*" + GV.innerSeparator + String(GV.sizeOfGrid)
//        playedGamesRealm = getRealm(type: .PlayedGameRealm)
//        let actGame = playedGamesRealm.objects(PlayedGame.self).filter("finished = %d AND primary like %@", false, primary).sorted(byKeyPath: "timeStamp", ascending: false)
//        if actGame.count == 0 {
//            let finishedGames = playedGamesRealm.objects(PlayedGame.self).filter("primary like %@ AND finished = true",
//                                                                                  primary).sorted(byKeyPath: "gameNumber", ascending: false)
//            if finishedGames.count == 0 {
////                GV.sizeOfGrid = 8
//                GV.gameNumber = startGameNumber
//                primary = GV.actLanguage + GV.innerSeparator + String(GV.gameNumber) + GV.innerSeparator + String(GV.sizeOfGrid)
//            } else {
//                let lastPlayed = finishedGames.first!
//                GV.gameNumber = lastPlayed.gameNumber + 1
////                GV.sizeOfGrid = lastPlayed.gameSize
//                if GV.gameNumber > maxGameNumber {
////                    GV.sizeOfGrid += 1
//                    GV.gameNumber = 1
//                }
//                primary = GV.actLanguage + GV.innerSeparator + String(GV.gameNumber) + GV.innerSeparator + String(GV.sizeOfGrid)
//            }
//            let origGame = gamesRealm.objects(Games.self).filter("primary = %@", primary)
//            if origGame.count > 0 {
//                let newGame = PlayedGame()
//                newGame.primary = primary
//                newGame.gameSize = GV.sizeOfGrid
//                newGame.language = GV.actLanguage
//                newGame.gameNumber = origGame.first!.gameNumber
//                newGame.gameArray = origGame.first!.gameArray
//                newGame.wordsToFind = origGame.first!.words
//                newGame.finished = false
//                try! playedGamesRealm.safeWrite {
//                    playedGamesRealm.add(newGame)
//                }
//            }
//        } else {
//            GV.gameNumber = actGame.first!.gameNumber
//        }
//        playingGame()
//    }
//    
//    @objc private func startFinishedGame() {
//
//    }
//    
//    var games: Results<Games>?
//    
//    private func createNewGameArray(size: Int) -> [[WTGameboardItem]] {
//        var gameArray: [[WTGameboardItem]] = []
//        
//        for i in 0..<size {
//            gameArray.append( [WTGameboardItem]() )
//            
//            for j in 0..<GV.sizeOfGrid {
//                gameArray[i].append(WTGameboardItem() )
//                gameArray[i][j].letter = emptyLetter
//            }
//        }
//        return gameArray
//    }
//    
//    private func fillGameArray(gameArray: [[WTGameboardItem]], content: String, toGrid: Grid) {
//        let size = gameArray.count
//        for (index, letter) in content.enumerated() {
//            let col = index / size
//            let row = index % size
//            gameArray[col][row].position = toGrid.gridPosition(col: col, row: row)
//            gameArray[col][row].name = "GBD/\(col)/\(row)"
//            gameArray[col][row].col = col
//            gameArray[col][row].row = row
//            _ = gameArray[col][row].setLetter(letter: String(letter), toStatus: .Used)
//            toGrid.addChild(gameArray[col][row])
//        }
//    }
//    
//    var firstTouchLocation = CGPoint(x: 0, y: 0)
//    var firstTouchTime = Date()
//    var timeIndex = 0
//    var movingShapeStartPosition = CGPoint(x: 0, y: 0)
////    enum GameState: Int {
////        case Choosing = 0, Playing
////    }
//    var choosedWord = UsedWord()
//    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//        choosedWord = UsedWord()
//        let touchLocation = touches.first!.location(in: self)
//        let (OK, col, row) = analyzeNodesAtLocation(location: touchLocation)
//        if OK {
//            choosedWord.append(UsedLetter(col: col, row: row, letter: GV.gameArray[col][row].letter))
//            GV.gameArray[col][row].setStatus(toStatus: .Temporary)
//        }
//    }
//
//    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
//        let touchLocation = touches.first!.location(in: self)
//        let (OK, col, row) = analyzeNodesAtLocation(location: touchLocation)
//        let actLetter = UsedLetter(col: col, row: row, letter: GV.gameArray[col][row].letter)
//        if OK {
//            if choosedWord.count > 1 {
//                if choosedWord.usedLetters[choosedWord.count - 2] == actLetter {
//                    let oldLetter = choosedWord.usedLetters.last!
//                    GV.gameArray[oldLetter.col][oldLetter.row].setStatus(toStatus: .Used)
//                    choosedWord.removeLast()
//                    return
//                }
//            }
//            if !choosedWord.usedLetters.contains(where: {$0.col == col && $0.row == row && $0.letter == GV.gameArray[col][row].letter}) {
//                choosedWord.append(UsedLetter(col:col, row: row, letter: GV.gameArray[col][row].letter))
//                GV.gameArray[col][row].setStatus(toStatus: .Temporary)
//            }
//        }
//    }
//    
//    private func clearTemporaryCells() {
//        iterateGameArray(doing: {(col: Int, row: Int) in
//            if GV.gameArray[col][row].status == .Temporary {
//                GV.gameArray[col][row].setStatus(toStatus: GV.gameArray[col][row].origStatus)
//            }
//        })
//    }
//    
//    enum animationType: Int {
//        case WordIsOK = 0, NoSuchWord, WordIsActiv
//    }
//    var counter = 0
//    var cellsToAnimate = [WTGameboardItem]()
//    private func animateLetters(_ usedWord: UsedWord, type: animationType) {
//        cellsToAnimate.removeAll()
//        var myActions = [SKAction]()
//        switch type {
//        case .WordIsOK:
//            for usedLetter in usedWord.usedLetters {
//                cellsToAnimate.append(GV.gameArray[usedLetter.col][usedLetter.row].copyMe())
//            }
//            var newBlockSize = GV.blockSize
//            var wordSize = CGFloat(0)
//            repeat {
//                wordSize = CGFloat(cellsToAnimate.count) * newBlockSize * 1.3
//                if wordSize > (GV.actWidth * 0.6) {
//                    newBlockSize *= 0.95
//                }
//            } while wordSize > (GV.actWidth * 0.6)
//            for cell in cellsToAnimate {
//                cell.size = CGSize(width: newBlockSize, height: newBlockSize)
//            }
//            let firstPositionX = (GV.actWidth - wordSize) * 0.5
////            let fixPositionY = playingGrid!.frame.minY - newBlockSize
//            let fixPositionY = playingGrid!.frame.maxY + newBlockSize
//
//            for (index, cell) in cellsToAnimate.enumerated() {
//                myActions.removeAll()
//                gameLayer.addChild(cell)
//                cell.setStatus(toStatus: .WholeWord)
////                let path = UIBezierPath()
//                if let particles = SKEmitterNode(fileNamed: "MyFireParticle.sks") {
//                    particles.particleColor = .red
//                    cell.addChild(particles)
//                }
////                path.move(to: toPosition)
////                path.addLine(to: CGPoint(x: firstPositionX + CGFloat(index) * newBlockSize * 1.2, y: fixPositionY))
//                cell.position = playingGrid!.gridPosition(col: cell.col, row: cell.row) + playingGrid!.position
//                myActions.append(SKAction.move(to: CGPoint(x: firstPositionX + CGFloat(index) * newBlockSize * 1.3, y: fixPositionY), duration: 0.8))
//                myActions.append(SKAction.resize(toWidth: newBlockSize * 1.2, height: newBlockSize * 1.2, duration: 0.5))
//                myActions.append(SKAction.resize(toWidth: newBlockSize * 0.8, height: newBlockSize * 0.8, duration: 0.5))
//                myActions.append(SKAction.resize(toWidth: newBlockSize * 1.2, height: newBlockSize * 1.2, duration: 0.5))
//                myActions.append(SKAction.fadeOut(withDuration: 0.2))
//                myActions.append(SKAction.move(to: playingGrid!.gridPosition(col: cell.col, row: cell.row) , duration: 0.2))
//                myActions.append(SKAction.removeFromParent())
//                cell.zPosition = 100
//                let sequence = SKAction.sequence(myActions)
//                cell.run(sequence)
//            }
//        case .NoSuchWord:
//            cellsToAnimate.removeAll()
//            for item in choosedWord.usedLetters {
//                cellsToAnimate.append(GV.gameArray[item.col][item.row])
//            }
//            for cell in cellsToAnimate {
//                myActions.removeAll()
//                cell.setStatus(toStatus: .OrigStatus)
////                myActions.append(SKAction.wait(forDuration: 0.2))
//                for _ in 0...2 {
//                    myActions.append(SKAction.run {
//                        cell.setStatus(toStatus: .Error)
//                    })
//                    myActions.append(SKAction.wait(forDuration: 0.4))
//                    myActions.append(SKAction.run {
//                        cell.setStatus(toStatus: .OrigStatus)
//                    })
//                    myActions.append(SKAction.wait(forDuration: 0.2))
//                }
//                let sequence = SKAction.sequence(myActions)
//                cell.run(sequence)
//            }
//        case .WordIsActiv:
//            cellsToAnimate.removeAll()
//            for item in choosedWord.usedLetters {
//                cellsToAnimate.append(GV.gameArray[item.col][item.row])
//            }
//            for cell in cellsToAnimate {
//                myActions.removeAll()
//                cell.setStatus(toStatus: .OrigStatus)
////                myActions.append(SKAction.wait(forDuration: 0.2))
//                for _ in 0...2 {
//                    myActions.append(SKAction.run {
//                        cell.setStatus(toStatus: .GoldStatus)
//                    })
//                    myActions.append(SKAction.wait(forDuration: 0.4))
//                    myActions.append(SKAction.run {
//                        cell.setStatus(toStatus: .OrigStatus)
//                    })
//                    myActions.append(SKAction.wait(forDuration: 0.2))
//                }
//                let sequence = SKAction.sequence(myActions)
//                cell.run(sequence)
//            }
//        }
//    }
//    
//
//    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
////        let touchLocation = touches.first!.location(in: self)
//        if choosedWord.count > 3 {
//            let foundedWords = realmWordList.objects(WordListModel.self).filter("word = %@", GV.actLanguage + choosedWord.word.lowercased())
//            if foundedWords.count == 1 {
//                if saveChoosedWord() {
//                    animateLetters(choosedWord, type: .WordIsOK)
//                    mySounds.play(.OKWord)
//                    setGameArrayToActualState()
//                } else {
//                    animateLetters(choosedWord, type: .WordIsActiv)
//                    clearTemporaryCells()
//                    mySounds.play(.NoSuchWord)
//                }
//            } else {
//                clearTemporaryCells()
//                animateLetters(choosedWord, type: .NoSuchWord)
//                mySounds.play(.NoSuchWord)
//            }
//            choosedWord = UsedWord()
//        } else {
//            clearTemporaryCells()
//        }
////        var countGreenCells = 0
//        var countGreenWords = 0
//        for myLabel in myLabels {
//            countGreenWords +=  myLabel.founded ? 1 : 0
//        }
//        if countGreenWords == mandatoryWords.count {
//            congratulation()
//        }
//    }
//    
//    private func congratulation() {
//        try! playedGamesRealm.safeWrite {
//            playedGame.finished = true
//        }
//        let myAlert = MyAlertController(title: GV.language.getText(.tcCongratulations),
//                                        message: GV.language.getText(.tcFinishGameMessage),
////                                          size: CGSize(width: GV.actWidth * 0.5, height: GV.actHeight * 0.5),
//                                          target: self,
//                                          type: .Green)
//        myAlert.addAction(text: GV.language.getText(.tcOK), action: #selector(self.startNewGame))
//        myAlert.presentAlert()
//        gameLayer.addChild(myAlert)
//    }
//
//    
//    private func setConnectionTypes(usedLetters: [UsedLetter])->[ConnectionType] {
//        var connectionTypes = Array(repeating: ConnectionType(), count: usedLetters.count)
//        if usedLetters.count > 0 {
//            for index in 0..<usedLetters.count - 1 {
//                if usedLetters[index].row < usedLetters[index + 1].row {
//                    connectionTypes[index].bottom = true
//                    connectionTypes[index + 1].top = true
//                }
//                if usedLetters[index].row > usedLetters[index + 1].row {
//                    connectionTypes[index].top = true
//                    connectionTypes[index + 1].bottom = true
//                }
//                if usedLetters[index].col < usedLetters[index + 1].col {
//                    connectionTypes[index].right = true
//                    connectionTypes[index + 1].left = true
//                }
//                if usedLetters[index].col > usedLetters[index + 1].col {
//                    connectionTypes[index].left = true
//                    connectionTypes[index + 1].right = true
//                }
//            }
//        }
//        return connectionTypes
//    }
//
//    
//    private func analyzeNodesAtLocation(location: CGPoint)->(OK: Bool, col: Int, row: Int) {
//        let nodes = self.nodes(at: location)
//        for node in nodes {
//            if node.name != nil && node.name!.begins(with: "GBD") {
//                let parts = node.name?.components(separatedBy: "/")
//                if parts!.count == 3 {
//                    if let col = Int(parts![1]) {
//                        if let row = Int(parts![2]) {
//                            return(OK: true, col: col, row: row)
//                        }
//                    }
//                }
//            }
//        }
//        return (OK:false, col: 0, row: 0)
//    }
//    
//    var playingGrid: Grid?
//    var positions = [ObjectSP]()
//    var scoreLabel: MyLabel?
//    public func playingGame() {
////        let test = gameLayer
//        let sizeMultiplierIPhone: [CGFloat] = [0, 0, 0, 0, 0, 0.13, 0.11, 0.095, 0.08, 0.07, 0.065]
//        let sizeMultiplierIPad:   [CGFloat] = [0, 0, 0, 0, 0, 0.08, 0.075, 0.070, 0.055, 0.06, 0.05]
//        removeChildrenExceptTypes(from: self, types: [.Background])
//        let sizeMultiplier = GV.onIpad ? sizeMultiplierIPad : sizeMultiplierIPhone
//        let blockSize = GV.minSide * sizeMultiplier[GV.sizeOfGrid]
//        GV.blockSize = blockSize
//        playingGrid = Grid(blockSize: blockSize * 1.1, rows: GV.sizeOfGrid, cols: GV.sizeOfGrid)
//        GV.gameArray = createNewGameArray(size: GV.sizeOfGrid)
//        let gridPosition = PLPosSize(PPos: CGPoint(x: GV.minSide * 0.5, y: GV.maxSide - playingGrid!.size.height * 0.82),
//                                     LPos: CGPoint(x: GV.maxSide - playingGrid!.size.width * 0.65, y: GV.minSide * 0.93 - playingGrid!.size.height * 0.52),
//                                     PSize: playingGrid!.size,
//                                     LSize: playingGrid!.size)
//        let gameHeaderPosition = PLPosSize(PPos: CGPoint(x: GV.minSide * 0.5, y: GV.maxSide * 0.92),
//                                           LPos: CGPoint(x: gridPosition.LPos.x , y: GV.minSide * 0.94))
//        let gameHeader = MyLabel(text: GV.language.getText(.tcSearchWords), position: gameHeaderPosition, fontName: GV.headerFontName, fontSize: GV.minSide * headerMpx)
////        gameLayer.addChild(gameHeader) // index 0
//        gameLayer.addChild(gameHeader)
////        let test = gameLayer
//
//        playingGrid!.plPosSize = gridPosition
//        playingGrid!.setActPosSize()
//        playingGrid!.zPosition = 20
//        gameLayer.addChild(playingGrid!)
//
//        let fixWordsHeaderPosition = PLPosSize(PPos: CGPoint(x: gridPosition.PPos.x, y: gridPosition.PPos.y - playingGrid!.plPosSize!.LSize!.height * 0.6),
//                                               LPos: CGPoint(x: GV.maxSide * 0.18, y: gameHeaderPosition.LPos.y))
//        let fixWordsHeader = MyLabel(text: GV.language.getText(.tcWordsToFind), position: fixWordsHeaderPosition, fontName: GV.headerFontName, fontSize: GV.minSide * headerMpx)
//        gameLayer.addChild(fixWordsHeader)
//        let scoreLabelPosition = PLPosSize(PPos: CGPoint(x: GV.minSide * 0.5, y: GV.maxSide * 0.90),
//                                           LPos: CGPoint(x: gridPosition.LPos.x , y: GV.minSide * 0.92))
//        scoreLabel = MyLabel(text: GV.language.getText(.tcScore, values: String(0)), position: scoreLabelPosition, fontName: GV.headerFontName, fontSize: GV.minSide * headerMpx)
//        gameLayer.addChild(scoreLabel!) // index 0
//
//
//        let primary = GV.actLanguage + GV.innerSeparator + String(GV.gameNumber) + GV.innerSeparator + String(GV.sizeOfGrid)
//        let origGames = gamesRealm.objects(Games.self).filter("primary = %@", primary)
//        if origGames.count > 0 {
//            let origGame = origGames.first!
//            fillGameArray(gameArray: GV.gameArray, content:  origGame.gameArray, toGrid: playingGrid!)
//    //        createWordLabels(game: origGame)
//            let myGame = playedGamesRealm.objects(PlayedGame.self).filter("primary = %@", primary)
//            if myGame.count == 0 {
//                createNewPlayedGame(to: origGame)
//    //            showWordsToFind(playedGame: playedGame)
//            } else {
//                playedGame = myGame.first!
////                try! playedGamesRealm!.safeWrite {
////                    playedGame.myWords = ""
////                }
//            }
//            addButtonPL(to: self, text: GV.language.getText(.tcBack), action: #selector(goBackToMainMenu), line: GoBack)
////            let test = gameLayer
//            possibleLineCountP = abs((gameLayer.children[lastHeaderIndex].plPosSize?.PPos.y)! - (gameLayer.children[buttonIndex].frame.maxY)) / (1.2 * ("A".height(font: wordFont!)))
//            possibleLineCountL = abs((gameLayer.children[lastHeaderIndex].plPosSize?.LPos.y)! - (gameLayer.children[buttonIndex].frame.maxY)) / (1.2 * ("A".height(font: wordFont!)))
//            firstWordPositionYP = ((gameLayer.children[lastHeaderIndex].plPosSize?.PPos.y)!) - GV.maxSide * 0.04
//            firstWordPositionYL = ((gameLayer.children[lastHeaderIndex].plPosSize?.LPos.y)!) - GV.maxSide * 0.04
//            fillMandatoryWords()
//            setGameArrayToActualState()
//        }
////        setPlayingGameSizesAndPositions()
//    }
//    
//    let lastHeaderIndex = 3
//    let buttonIndex = 4
//    let wordFont = UIFont(name: GV.headerFontName, size: GV.wordsFontSize)
//    var firstWordPositionYP: CGFloat = 0
//    var firstWordPositionYL: CGFloat = 0
//    var possibleLineCountP: CGFloat = 0
//    var possibleLineCountL: CGFloat = 0
//
//    private func fillMandatoryWords() {
//        let mandatoryWordsInDB = playedGame.wordsToFind.components(separatedBy: GV.outerSeparator)
//        for wordString in mandatoryWordsInDB {
//            mandatoryWords.append(UsedWord(from: wordString))
//        }
//        mandatoryWords = mandatoryWords.sorted(by: {$0.word.count > $1.word.count || ($0.word.count == $1.word.count && $0.word < $1.word)})
//    }
//    
//    var myLabels = [MyFoundedWord]()
//    var mandatoryWords = [UsedWord]()
//    var allWords = [UsedWord]()
//    
////    private func createWordLabel(UsedWord: UsedWord, mandatory: Bool)->MyLabel {
////        let index = myWords.count + 1
////        let text = (index > 9 ? "" : "0") + String(index) + ". " +
////            (mandatory ? PlaySearchingWords.questionMark.fill(with: GV.questionMark, toLength: UsedWord.word.count) : UsedWord.word)
////        let wordLabel = MyLabel(text: text, position: CGPoint(x: 0, y: 0), fontName: GV.headerFontName, fontSize: wordsFontSize, name: "")
////        wordLabel.name = UsedWord.word + (mandatory ? mandatoryLabelInName : ownLabelInName)
////        wordLabel.horizontalAlignmentMode = .left
////        actNames[actNames.count] = wordLabel.name
////        gameLayer.addChild(wordLabel)
////        return wordLabel
////    }
//    
//    private func addButton(to: SKNode, text: String, action: Selector, line: CGFloat, name: String? = nil) {
//        let button = MyButton(fontName: GV.headerFontName, size: CGSize(width: GV.maxSide * 1.1, height: GV.minSide * 0.08))
//        button.zPosition = self.zPosition + 20
//        button.setButtonLabel(title: text, font: UIFont(name: GV.headerFontName, size: GV.minSide * 0.04)!)
//        button.setButtonAction(target: self, triggerEvent: .TouchUpInside, action: action)
//        if line == GoBack {
//            button.position = CGPoint(x: self.frame.width * 0.5, y: (self.frame.height * 0.2))
//        } else {
//            button.position = CGPoint(x: self.frame.width * 0.5, y: (self.frame.height * 0.8) - (line * GV.maxSide * 0.06))
//        }
//        button.size = CGSize(width: GV.minSide * 0.6, height: GV.maxSide * 0.05)
//        button.name = name
//        to.addChild(button)
//    }
//    
//
//    @objc private func goBackToMainMenu() {
////        self.children.removeAll()
////        myDelegate.goBackFromFindWords()
//    }
////    var mandatoryWordLabels = [MyWordLabel]()
//    
////    private func showWordsToFind(playedGame: PlayedGame) {
////        let wordsToShow = playedGame.wordsToFind.components(separatedBy: GV.outerSeparator).sorted(by: {$0.count > $1.count})
////        for UsedWord in wordsToShow {
////            mandatoryWords.append(UsedWord(from: UsedWord))
////        }
////    }
//    
//    private func setGameArrayToActualState() {
//        var counter = 0
//        let myWordsInDB = playedGame.myWords.components(separatedBy: GV.outerSeparator)
//        iterateGameArray(doing: {(col: Int, row: Int) in
//            GV.gameArray[col][row].resetCountOccurencesInWords()
//        })
//        func setPLPos(counter: Int)->PLPosSize {
//            let colP = counter / Int(possibleLineCountP)
//            let colL = counter / Int(possibleLineCountL)
//            let rowP = counter % Int(possibleLineCountP)
//            let rowL = counter % Int(possibleLineCountL)
//            let wordWidth = CGFloat("A".fill(with: "A", toLength: 15).width(font: wordFont!))
//            let wordHeight = CGFloat("A".height(font: wordFont!))
//            return PLPosSize(PPos: CGPoint(x: (GV.minSide * 0.1) + (CGFloat(colP) * wordWidth), y: firstWordPositionYP - wordHeight * CGFloat(rowP)),
//                             LPos: CGPoint(x: (GV.maxSide * 0.05) + (CGFloat(colL) * wordWidth), y: firstWordPositionYL - wordHeight * CGFloat(rowL)))
//        }
//        for item in mandatoryWords.sorted(by: {$0.word.count > $1.word.count || ($0.word.count > $1.word.count && $0.word < $1.word)}) {
//            if !myLabels.contains(where: {$0.usedWord! == item}) {
////                let label = createWordLabel(UsedWord: item, mandatory: true)
//                let myWord = MyFoundedWord(usedWord: item, mandatory: true, prefixValue: counter + 1)
//                myWord.plPosSize = setPLPos(counter: counter)
//                myWord.setActPosSize()
//                gameLayer.addChild(myWord)
//                myLabels.append(myWord)
//            }
//            counter += 1
//        }
//        if myWordsInDB.count > 0 {
//            for item in myWordsInDB {
//                if item != "" {
//                    let foundedWord = UsedWord(from: item)
//                    if !allWords.contains(where: {$0 == foundedWord}){
//                        allWords.append(foundedWord)
//                    }
//                    for usedLetter in foundedWord.usedLetters {
//                        let cell = GV.gameArray[usedLetter.col][usedLetter.row]
//                        if usedLetter.letter == cell.letter {
//                            cell.setStatus(toStatus: .WholeWord)
//                        }
//                    }
//                    let connectionTypes = setConnectionTypes(usedLetters: foundedWord.usedLetters)
//                    for (index, item) in foundedWord.usedLetters.enumerated() {
//                        GV.gameArray[item.col][item.row].setStatus(toStatus: .WholeWord, connectionType: connectionTypes[index], incrWords: true)
//                    }
// 
//                    if !mandatoryWords.contains(where: {$0 == foundedWord}) {
//                        counter += 1
//                        if !myLabels.filter({!$0.mandatory}).contains(where: {$0.usedWord! == foundedWord}) {
//                            let myWord = MyFoundedWord(usedWord: foundedWord, mandatory: false, prefixValue: counter + 1)
//                            myWord.plPosSize = setPLPos(counter: counter)
//                            myWord.setActPosSize()
//                            gameLayer.addChild(myWord)
//                            myLabels.append(myWord)
//                        } else {
//                            
//                        }
//                    }
//                }
//            }
//            GV.score = 0
//
//            for myWord in myLabels {
//                if myWord.mandatory {
//                    myWord.setQuestionMarks()
//                    if allWords.contains(where: {$0 == myWord.usedWord!}) {
//                        myWord.fontColor = UIColor(red: 7/255, green: 125/255, blue: 21/255, alpha: 1.0)
//                        myWord.founded = true
//                     }
//                } else {
//                    myWord.fontColor = UIColor(red: 115/255, green: 6/255, blue: 66/255, alpha: 1.0)//.red
//                    GV.score += (myWord.usedWord!.word.count - 3) * 50
//                }
//            }
//            scoreLabel!.text = GV.language.getText(.tcScore, values: String(GV.score), String(0))
//        }
//    }
//    
//    private func iterateGameArray(doing: (_ col: Int, _ row: Int)->()) {
//        for col in 0..<GV.sizeOfGrid {
//            for row in 0..<GV.sizeOfGrid {
//                doing(col, row)
//            }
//        }
//    }
//    
//    private func createNewPlayedGame(to origGame: Games) {
//        try! playedGamesRealm.safeWrite {
//            playedGame = PlayedGame()
//            playedGame.primary = origGame.primary
//            playedGame.language = origGame.language
//            playedGame.gameNumber = origGame.gameNumber
//            playedGame.gameSize = origGame.size
//            playedGame.gameArray = origGame.gameArray
//            playedGame.wordsToFind = origGame.words
//            playedGame.timeStamp = NSDate()
//            playedGamesRealm.add(playedGame)
//        }
//    }
//    
////    private func checkChoosedWordInFoundedWordsMyWords()->Bool {
////        var choosedWordIsOK = true
//////        stopChecking:
//////        for foundedWord in allWords {
//////            if foundedWord.usedWord! == choosedWord && !foundedWord.text!.contains(strings: [GV.questionMark]){
//////                choosedWordIsOK = false
//////                break stopChecking
//////            }
//////        }
////        if allWords.contains(where: {$0 == choosedWord}) {
////
////        }
////        return choosedWordIsOK
////    }
//
//    private func saveChoosedWord()->Bool {
//        let returnValue = !allWords.contains(where: {$0 == choosedWord})//checkChoosedWordInFoundedWordsMyWords()
//        if returnValue {
//            let addString = choosedWord.toString()
//            let separator = playedGame.myWords.count == 0 ? "" : GV.outerSeparator
//            try! playedGamesRealm.safeWrite {
//                playedGame.myWords.append(separator + addString)
//                playedGame.timeStamp = Date() as NSDate
//            }
//        }
//        return returnValue
//    }
//    
////    var myFoundedWords = [UsedWord]()
//    
//    
//}
