//
//  ShowFinishedGamesScene.swift
//  MagicOfWords
//
//  Created by Jozsef Romhanyi on 24/05/2018.
//  Copyright © 2018 Jozsef Romhanyi. All rights reserved.
//

import Foundation
import GameKit
import UIKit
import RealmSwift

public protocol ShowGamesSceneDelegate: class {
    func backToMenuScene(gameNumberSelected: Bool, gameNumber: Int, restart: Bool)
}
class ShowGamesScene: SKScene, WTTableViewDelegate {
    struct FinishedGameData {
        var gameNumber = ""
        var bestPlayer = ""
        var bestScore = ""
        var score = ""
        var finished = false
    }

    let xMultiplierTab: [CGFloat] = [0.3, 0.5, 0.8]
    var myDelegate: ShowGamesSceneDelegate?
    let OKLabelName = "°°°OKLabel°°°"
    let OKButtonName = "°°°OKButton°°°"
    
    var allResultsItems: Results<BestScoreForGame>?
    var background = SKSpriteNode(imageNamed: "magier")
    var notificationToken: NotificationToken?
    var subscriptionToken: NotificationToken?
    var subscription: SyncSubscription<BestScoreForGame>!
//    var showAll = true
    var parentViewController: UIViewController?

//    override func didMoveToView(view: SKView) {
//        background.position = CGPoint(x: frame.size.width / 2, y: frame.size.height / 2)
//        addChild(background)
    
    var initialLoadDone = false

    override func didMove(to view: SKView) {
        background.position = CGPoint(x: frame.size.width / 2, y: frame.size.height / 2)
        let widthMultiplier = background.size.width / background.size.height
        lineHeight =  "A".height(font: myFont!) * 1.25
        background.size = CGSize(width: self.size.height * widthMultiplier, height: self.size.height)
        addChild(background)
//        self.backgroundColor = SKColor(red: 200/255, green: 220/255, blue: 208/255, alpha: 1)
        self.allResultsItems = RealmService.objects(BestScoreForGame.self).filter("combinedPrimary ENDSWITH %@ and gameNumber >= %d and gameNumber <= %d", GV.actLanguage, GV.minGameNumber, GV.maxGameNumber).sorted(byKeyPath: "gameNumber", ascending: true)

        showFinishedGamesInTableView()
    }
    
    public func setDelegate(delegate: ShowGamesSceneDelegate, controller: UIViewController) {
        myDelegate = delegate
        parentViewController = controller
    }
    
//    public func setSelect(all: Bool) {
//        self.showAll = all
//    }
//    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        let subscribes = RealmService.subscriptions()
        for subscribe in subscribes {
            subscribe.unsubscribe()
        }
        goBack(gameNumberSelected: false, gameNumber: 0)
    }
    
    private func goBack(gameNumberSelected: Bool, gameNumber: Int, restart: Bool = false) {
        showGamesInTableView!.isHidden = true
        showGamesInTableView = nil
//        subscription.unsubscribe()
         if myDelegate == nil {
            return
        }
        myDelegate!.backToMenuScene(gameNumberSelected: gameNumberSelected, gameNumber: gameNumber, restart: restart)
    }
    
    var showGamesInTableView: WTTableView?
    var gamesForShow = [FinishedGameData]()
    let myFont = UIFont(name: "CourierNewPS-BoldMT", size: GV.onIpad ? 18 : 12)
    var lineHeight: CGFloat = 0
    var realmLoadingCompleted = false
    
    private func showFinishedGamesInTableView() {
        showGamesInTableView = WTTableView()

        calculateColumnWidths()
        showGamesInTableView?.setDelegate(delegate: self)
//        showGamesInTableView?.register(CustomTableViewCell.self, forCellReuseIdentifier: "cell")
        
        let origin = CGPoint(x: 0.5 * (self.frame.width - title.width(font: myFont!)), y: 100)
//        let lineHeight = title.height(font: myFont!)
        let headerframeHeight = lineHeight * 2.2
        var showingWordsHeight = CGFloat(gamesForShow.count) * lineHeight
        if showingWordsHeight  > self.frame.height * 0.9 {
            var counter = CGFloat(gamesForShow.count)
            repeat {
                counter -= 1
                showingWordsHeight = lineHeight * counter
            } while showingWordsHeight + headerframeHeight > self.frame.height * 0.6
        }
        let width = title.width(font: myFont!)
        let size = CGSize(width: width, height: showingWordsHeight + headerframeHeight)
        showGamesInTableView?.frame=CGRect(origin: origin, size: size)
        let center = CGPoint(x: 0.5 * view!.frame.width, y: 0.5 * self.view!.frame.height)
        self.showGamesInTableView!.center=center
        self.showGamesInTableView?.reloadData()
        
        self.scene?.view?.addSubview(showGamesInTableView!)
        subscription = allResultsItems!.subscribe(named: "allResultsNew_\(GV.actLanguage)_\(GV.minGameNumber)")
        subscriptionToken = subscription.observe(\.state) { [weak self]  state in
            print("in ShowGamesScene at showFinishedGame -> state: \(state)")
           if state == .complete {
            #if DEBUG
                self!.checkContinuity()
            #endif
                self!.gamesForShow = self!.getGamesForShow()
                self!.calculateColumnWidths()
                let origin = CGPoint(x: 0, y: 0)
                //        let origin = CGPoint(x: 0.5 * (self.view.frame.width - (headerLine.width(font: myFont!))), y: 200)
//                let heightOfLine =  self!.title.height(font: self!.myFont!) * 1.12
            var height = self!.lineHeight * CGFloat(self!.gamesForShow.count + 2)
            height = height > self!.frame.height * 0.8 ? self!.frame.height * 0.8 : height
            let size = CGSize(width: self!.title.width(font: self!.myFont!) * 1, height: height)
                self!.showGamesInTableView!.frame=CGRect(origin: origin, size: size)

                //        showPlayerActivityView!.frame = self.view.frame
            let center = CGPoint(x: 0.5 * self!.view!.frame.width, y: 0.5 * self!.view!.frame.height)
            self!.showGamesInTableView!.center=center
                self!.showGamesInTableView!.register(CustomTableViewCell.self, forCellReuseIdentifier: "cell")
                self!.realmLoadingCompleted = true
            self!.notificationToken = self!.allResultsItems!.observe { [weak self] (changes) in
//                print("changes: \(changes)")
                if !self!.realmLoadingCompleted {
                    print("return -> realmLoadingCompleted not completed")
                    return
                }
                guard (self?.showGamesInTableView) != nil else { return }
                switch changes {
                case .initial:
                    // Results are now populated and can be accessed without blocking the UI
                    //                showPlayerActivityView.reloadData()
                    self!.initialLoadDone = true
                    self!.showGamesInTableView!.reloadData()
                    print("Initial Data displayed")
//                case .update(_, let deletions, let insertions, let modifications):
                case .update(_, _, _, _):
//                    print("deletions: \(deletions), insertions: \(insertions), modifications: \(modifications)")
                    self!.gamesForShow = self!.getGamesForShow()
                case .error(let error):
                    // An error occurred while opening the Realm file on the background worker thread
                    fatalError("\(error)")
                }
            }

            } else {
            }
        }

    }
    var timer = Timer()
    var missingRecords = [Int]()
    
    private func checkContinuity() {
        var checkGameNumber = 0
        for record in allResultsItems! {
            repeat {
                if record.gameNumber < 1000 {
                    checkGameNumber += 1
                    if record.gameNumber != checkGameNumber {
                        missingRecords.append(checkGameNumber)
                        print("GameNumber : \(checkGameNumber) will be corrected")
                    } else {
                        break
                    }
                } else {
                    break
                }
            } while true
        }
        if missingRecords.count > 0 {
            timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(insertBestPlayer(timerX: )), userInfo: nil, repeats: false)
        }
    }
    
    @objc public func insertBestPlayer(timerX: Timer) {
        if missingRecords.count > 0 {
            if goOn {
                    setBestPlayerFor(gameNumber: missingRecords[0])
                    missingRecords.removeFirst()
                    goOn = false
            }
            timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(insertBestPlayer(timerX: )), userInfo: nil, repeats: false)
        }
    }
    
    var goOn = true
    var bestPlayers: Results<BestScoreSync>?
    var bestPlayersSubscription: SyncSubscription<BestScoreSync>?
    var bestPlayersSubscriptionToken: NotificationToken?
    
    private func setBestPlayerFor(gameNumber: Int) {
        let language = GV.basicDataRecord.actLanguage
        let combinedPrimary = String(gameNumber) + language
        bestPlayers = realmSync!.objects(BestScoreSync.self).filter("combinedPrimary BEGINSWITH %@", combinedPrimary).sorted(byKeyPath: "score", ascending: false)
        if bestPlayersSubscription != nil {
            bestPlayersSubscriptionToken!.invalidate()
            bestPlayersSubscription!.unsubscribe()
        }
        bestPlayersSubscription = bestPlayers!.subscribe(named: "BestListCorrection:\(combinedPrimary)")
        bestPlayersSubscriptionToken = bestPlayersSubscription!.observe(\.state) { [weak self]  state in
//            print("in ShowGamesScene at setBestPlayerFor -> state: \(state)")
            if state == .complete {
                let bestPlayer = BestScoreForGame()
                bestPlayer.combinedPrimary = combinedPrimary
                bestPlayer.gameNumber = gameNumber
                bestPlayer.language = language
                bestPlayer.bestScore = self!.bestPlayers![0].score
                bestPlayer.timeStamp = Date()
                bestPlayer.owner = self!.bestPlayers![0].owner
                try! realmSync!.safeWrite() {
                    realmSync!.add(bestPlayer)
                }
                self!.goOn = true
                print("GameNumber : \(gameNumber) corrected")
             } else {
//                print("state: \(state)")
            }
        }

    }
    private func getGamesForShow()->[FinishedGameData] {
        let notExists:String = "---"
        var returnArray = [FinishedGameData]()
        var games: Results<GameDataModel>
        games = realm.objects(GameDataModel.self).filter("language = %@ and gameNumber >= %d and gameNumber <= %d", GV.language.getText(.tcAktLanguage), GV.minGameNumber, GV.maxGameNumber).sorted(byKeyPath: "gameNumber", ascending: true)
        for game in games {
            if game.gameStatus == GV.GameStatusNew {
                continue
            }
            var item = FinishedGameData()
            item.gameNumber = String((game.gameNumber % 1000) + 1)
//            let combinedKey = String(game.gameNumber + 1) + game.language
            item.score = String(game.score)
            item.bestPlayer = notExists
            item.bestScore = notExists
            item.finished = game.gameStatus == GV.GameStatusFinished
//            item.place = RealmService.objects(BestScoreSync.self).filter("combinedPrimary beginswith %@ and score > %d", combinedKey, game.score).count + 1
            returnArray.append(item)
        }
        for bestGame in allResultsItems! {
            if let index =  returnArray.firstIndex(where: {Int($0.gameNumber) == bestGame.gameNumber % 1000}) {
                if bestGame.owner != nil {
                    if bestGame.bestScore < Int(returnArray[index].score)! {
                        if !GV.debug {
                            try! realmSync!.safeWrite() {
                                bestGame.bestScore = Int(returnArray[index].score)!
                                bestGame.owner = playerActivity!.first!
                            }
                        }
                    }
                    returnArray[index].bestPlayer = bestGame.owner!.nickName!
                    returnArray[index].bestScore = String(bestGame.bestScore)
                }
            } else {
                var item = FinishedGameData()
                item.gameNumber = String(bestGame.gameNumber)
                item.score = notExists
                item.bestScore  = String(bestGame.bestScore)
                item.bestPlayer = bestGame.owner == nil ? "" : bestGame.owner!.nickName!
                returnArray.append(item)
            }
        }
        return returnArray.sorted(by:{Int($0.gameNumber)! < Int($1.gameNumber)!})
    }
    
    var lengthOfGameNumber: Int = 0
    var lengthOfBestPlayer: Int = 0
    var lengthOfMyScore: Int = 0
    var title = ""
    
    private func calculateColumnWidths() {
        title = ""
        let text1 = "  \(GV.language.getText(.tcGameNumber)) "
        let text2 = " \(GV.language.getText(.tcBestPlayerHeader)) ".fixLength(length: 20, center: true)
        let text3 = " \(GV.language.getText(.tcMyHeader)) ".fixLength(length:15, center: true)
        title += text1
        title += text2
        title += text3
        lengthOfGameNumber = text1.length
        lengthOfBestPlayer = text2.length
        lengthOfMyScore = text3.length
   }
    func fillHeaderView(tableView: UITableView, section: Int) -> UIView {
        switch section {
        case 0:
            let view = UIView()
            //            let fontSize = GV.onIpad ? self.frame.width * 0.020 : self.frame.width * 0.040
            //            let myFont = UIFont(name: "CourierNewPS-BoldMT", size: fontSize) // change it according to ur requirement
            let lineHeight = (myFont?.lineHeight)!// * (GV.onIpad ? 1.5 : 2.0)
            let width = CGFloat(title.width(font: myFont!)) //lineHeight * CGFloat(title.length)
            //            view.frame = CGRect(x: 50, y: 0, width: width, height: 2 * lineHeight)
            let label1 = UILabel(frame: CGRect(x: 0, y: 0, width: width, height: lineHeight))
            label1.font = myFont!
            label1.text = GV.language.getText(.tcTableOfBestscores).fixLength(length: title.length, center: true)
            view.addSubview(label1)
            let label2 = UILabel(frame: CGRect(x: 0, y: lineHeight, width: width, height: lineHeight))
            label2.font = myFont!
            label2.text = title
            view.addSubview(label2)
            view.backgroundColor = UIColor(red:240/255, green: 240/255, blue: 240/255, alpha: 1.0)
            return view
        default: return UIView()
        }
    }
    
    func didTappedButton(tableView: UITableView, indexPath: IndexPath, buttonName: String) {
        
    }
    

    
    func didSelectedRow(tableView: UITableView, indexPath: IndexPath) {
        if let number = Int(gamesForShow[indexPath.row].gameNumber) {
            let gameNumber = number - 1
            let combinedKey = GV.actLanguage + String(gameNumber)
            let choosedGame = realm.objects(GameDataModel.self).filter("combinedKey = %@", combinedKey)
            if choosedGame.count == 1 && choosedGame.first!.gameStatus == GV.GameStatusFinished {
                let alertController = UIAlertController(title: GV.language.getText(.tcGameIsFinished, values: String(number)),
                                                        message: GV.language.getText(.tcRestartGameQuestion),
                                                        preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: GV.language.getText(.tcRestart), style: .default, handler: { [unowned self]
                    alert -> Void in
                    self.goBack(gameNumberSelected: true, gameNumber: gameNumber, restart: true)
                }))
                alertController.addAction(UIAlertAction(title: GV.language.getText(.tcContinue), style: .default, handler: { [unowned self]
                    alert -> Void in
                    self.goBack(gameNumberSelected: true, gameNumber: gameNumber, restart: false)
                }))

                alertController.addAction(UIAlertAction(title: GV.language.getText(.tcCancel), style: .cancel, handler: nil))
                self.parentViewController!.present(alertController, animated: true, completion: nil)
            } else {
                goBack(gameNumberSelected: true, gameNumber: gameNumber, restart: false)
            }
        }
    }
    
    func getHeightForHeaderInSection(tableView: UITableView, section: Int)->CGFloat {
        return GV.onIpad ? 48 : 28
    }
    func setHeaderView(tableView: UITableView, headerView: UIView, section: Int) {
    }
    
    
    let showWordsBackgroundColor = UIColor(red:255/255, green: 204/255, blue: 153/255, alpha: 1.0)
    let maxLengthMultiplier: CGFloat = GV.onIpad ? 12 : 8
    
    
    func getTableViewCell(tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
//        let color = UIColor(red: 240/255, green: 240/255, blue: 240/255,alpha: 1.0)
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! CustomTableViewCell
        cell.setFont(font: myFont!)
        cell.setCellSize(size: CGSize(width: tableView.frame.width * (GV.onIpad ? 0.040 : 0.010), height: lineHeight/*self.frame.height * (GV.onIpad ? 0.040 : 0.010)*/))
        cell.setBGColor(color: UIColor.white) //showWordsBackgroundColor)
        cell.addColumn(text: (gamesForShow[indexPath.row].gameNumber).fixLength(length: lengthOfGameNumber - 2)) // GameNumber
        cell.addColumn(text: String(gamesForShow[indexPath.row].bestPlayer).fixLength(length: 12)/*, color: color*/) // Best Player
        cell.addColumn(text: String(gamesForShow[indexPath.row].bestScore).fixLength(length: 7)) // Best Score
        cell.addColumn(text: String(gamesForShow[indexPath.row].score).fixLength(length: 8)/*, color: color*/) // My Score
//        cell.addColumn(text: String(gamesForShow[indexPath.row].place).fixLength(length: 4) )
        if gamesForShow[indexPath.row].finished {
//            let image = UIImage(named: "hook")
            let image = UIImage(named: "hook")!.resizeImage(newWidth: lineHeight)
            cell.addButton(image: image, callBack: buttonTapped)
        }
        return cell
    }
    
    @objc public func buttonTapped(indexPath: IndexPath) {
        
    }
    
    func getNumberOfSections() -> Int {
        return 1
    }
    func getNumberOfRowsInSections(section: Int)->Int {
        switch section {
        case 0: return gamesForShow.count
        default: return 0
        }
    }

    func getHeightForRow(tableView: UITableView, indexPath: IndexPath) -> CGFloat {
        return lineHeight//title.height(font: myFont!) * 1.15//1.12
    }
    

//    private func getDataFromRealmCloud(finishedGame: GameDataModel)->(String, String) {
//        var bestPlayerName = ""
//        var bestScore = ""
//        if GV.myUser != nil {
//            var bestScoreForGame: Results<BestScoreForGame>?
////            var bestScoreForGameToken: NotificationToken?
//            var bestScoreForGameSubscription: SyncSubscription<BestScoreForGame>?
//            var forGameSubscriptionToken: NotificationToken?
//            let combinedPrimaryForGame = String((finishedGame.gameNumber % 1000) + 1) + finishedGame.language
//            bestScoreForGame = realmSync!.objects(BestScoreForGame.self).filter("combinedPrimary = %@", combinedPrimaryForGame)
//            bestScoreForGameSubscription = bestScoreForGame!.subscribe(named: "FinishedRecord:\(combinedPrimaryForGame)")
//            forGameSubscriptionToken = bestScoreForGameSubscription!.observe(\.state) { state in
//                if state == .complete {
//                    if bestScoreForGame!.count > 0 {
//                        bestPlayerName = bestScoreForGame![0].owner!.nickName!
//                        bestScore = String(bestScoreForGame![0].bestScore)
//                    }
//                    bestScoreForGameSubscription!.unsubscribe()
//
//                } else {
//                    print("state: \(state)")
//                    bestScoreForGameSubscription!.unsubscribe()
//                }
//            }
//        }
//        return (bestPlayerName, bestScore)
//    }


}
