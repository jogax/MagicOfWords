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
    let xMultiplierTab: [CGFloat] = [0.3, 0.5, 0.8]
    var myDelegate: ShowGamesSceneDelegate?
    let OKLabelName = "°°°OKLabel°°°"
    let OKButtonName = "°°°OKButton°°°"

//    var allResultsItems: Results<BestScoreForGame>?
    var background = SKSpriteNode(imageNamed: "magier")
//    var notificationToken: NotificationToken?
//    var subscriptionToken: NotificationToken?
//    var subscription: SyncSubscription<BestScoreForGame>!
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
        GCHelper.shared.getScoresForShow(completion: {
            self.scoresLoaded()
        })
    }
    
    private func scoresLoaded() {
        gamesForShow = GV.scoreForShowTable
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
//        let subscribes = RealmService.subscriptions()
//        for subscribe in subscribes {
//            subscribe.unsubscribe()
//        }
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
    var gamesForShow = [ScoreForShow]()
    let myFont = UIFont(name: "CourierNewPS-BoldMT", size: GV.onIpad ? 18 : 12)
    var lineHeight: CGFloat = 0
    var realmLoadingCompleted = false

    private func showFinishedGamesInTableView() {
        showGamesInTableView = WTTableView()

        calculateColumnWidths()
        showGamesInTableView?.setDelegate(delegate: self)
        showGamesInTableView?.register(CustomTableViewCell.self, forCellReuseIdentifier: "cell")

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
        self.showGamesInTableView!.reloadData()

        self.scene?.view?.addSubview(showGamesInTableView!)
    }
    var timer = Timer()
    var missingRecords = [Int]()

    var goOn = true

    var lengthOfPlace: Int = 0
    var lengthOfPlayer: Int = 0
    var lengthOfScore: Int = 0
    var title = ""

    private func calculateColumnWidths() {
        title = ""
        let text1 = "  \(GV.language.getText(.tcPlace)) "
        let text2 = " \(GV.language.getText(.tcPlayerHeader)) ".fixLength(length: 20, center: true)
        let text3 = " \(GV.language.getText(.tcScore)) ".fixLength(length:15, center: true)
        title += text1
        title += text2
        title += text3
        lengthOfPlace = text1.length
        lengthOfPlayer = text2.length
        lengthOfScore = text3.length
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

    func didSelectedRow(tableView: UITableView, indexPath: IndexPath) {
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
        var cellColor = UIColor.white
        var playerName = gamesForShow[indexPath.row].player
        if playerName == GKLocalPlayer.local.alias {
            cellColor = UIColor.white
            playerName += GV.language.getText(.tcMe)
        }
        let text1 = String(gamesForShow[indexPath.row].place).fixLength(length: lengthOfPlace - 2)
        cell.addColumn(text: text1, color: cellColor) // GameNumber
        let text2 = ("   " + playerName).fixLength(length: 20, leadingBlanks: false)
        cell.addColumn(text: text2, color: cellColor)
        let text3 = ("  " + String(gamesForShow[indexPath.row].score)).fixLength(length: 9)
        cell.addColumn(text: text3, color: cellColor) // My Score
//        cell.addColumn(text: String(gamesForShow[indexPath.row].place).fixLength(length: 4) )
        return cell
    }

    @objc public func buttonTapped(indexPath: IndexPath) {

    }

    func getNumberOfSections() -> Int {
        return 1
    }
    func getNumberOfRowsInSections(section: Int)->Int {
        var returnValue = gamesForShow.count
        if GV.myPlace > gamesForShow.last!.place {
            returnValue += 1
        }
        return returnValue
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
