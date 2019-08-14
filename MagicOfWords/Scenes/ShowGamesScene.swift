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
//        let width = title.width(font: myFont!)
        let size = CGSize(width: widthOfView, height: showingWordsHeight + headerframeHeight)
        showGamesInTableView?.frame=CGRect(origin: origin, size: size)
        let center = CGPoint(x: 0.5 * view!.frame.width, y: 0.5 * self.view!.frame.height)
        self.showGamesInTableView!.center=center
        self.showGamesInTableView!.reloadData()

        self.scene?.view?.addSubview(showGamesInTableView!)
    }
    var timer = Timer()
    var missingRecords = [Int]()

    var goOn = true
    

    var title = ""
    
    struct ColumnLengths {
        var text = ""
        var length = 0
        init(text: String, length: Int){
            self.text = text
            self.length = length
        }
    }
    
    var columns = [ColumnLengths]()

    private func calculateColumnWidths() {
        let text0 = GV.language.getText(.tcBlank)
        let text1 = GV.language.getText(.tcPlace)
        let text2 = GV.language.getText(.tcPlayerHeader)
        let text3 = GV.language.getText(.tcScore)
        let text4 = GV.language.getText(.tcTableOfBestscores)
        let lengthOfBlanks = text0.length
        var lengthOfPlace = text1.length
        var lengthOfPlayer = text2.length
        var lengthOfScore = text3.length
        
        for item in gamesForShow {
            let name = item.player + GV.language.getText(.tcMe)
            lengthOfPlace = String(item.place).length > lengthOfPlace ? String(item.place).length : lengthOfPlace
            lengthOfPlayer = name.length > lengthOfPlayer ? name.length : lengthOfPlayer
            lengthOfScore = String(item.score).length > lengthOfScore ? String(item.score).length : lengthOfScore
        }
        columns.append(ColumnLengths(text: text0, length: lengthOfBlanks + 2))
        columns.append(ColumnLengths(text: text1, length: lengthOfPlace + 2))
        columns.append(ColumnLengths(text: text2, length: lengthOfPlayer + 2))
        columns.append(ColumnLengths(text: text3, length: lengthOfScore + 2))
        widthOfView = 0
        for column in columns {
            widthOfView += column.text.fixLength(length: column.length).width(font:myFont!)
        }
        if text4.width(font: myFont!) > widthOfView {
            widthOfView = text4.width(font: myFont!)
        }
   }
    var widthOfView:CGFloat = 0
    
    func fillHeaderView(tableView: UITableView, section: Int) -> UIView {
        let view = UIView()
        
        let label1 = UILabel(frame: CGRect(x: 0, y: 0, width: widthOfView, height: lineHeight))
        label1.font = myFont!
        label1.text = GV.language.getText(.tcTableOfBestscores).fixLength(length: title.length, center: true)
        label1.textAlignment = .center
        view.addSubview(label1)
        
        var labelPos: CGFloat = 0

        let lineHeight = (myFont?.lineHeight)!// * (GV.onIpad ? 1.5 : 2.0)
        for column in columns {
            let width = column.text.fixLength(length:column.length).width(font:myFont!)
            let label = UILabel(frame: CGRect(x: labelPos, y: lineHeight, width: width, height: lineHeight))
            labelPos += width
            label.text = column.text.fixLength(length: column.length, leadingBlanks: false)
            label.font = myFont!
//            widthOfView += width
            view.addSubview(label)
        }
//        let width = CGFloat(title.width(font: myFont!)) //lineHeight * CGFloat(title.length)
        //            view.frame = CGRect(x: 50, y: 0, width: width, height: 2 * lineHeight)
//        let label2 = UILabel(frame: CGRect(x: 0, y: lineHeight, width: width, height: lineHeight))
//        label2.font = myFont!
//        label2.text = title
//        view.addSubview(subView)
        view.backgroundColor = UIColor(red:240/255, green: 240/255, blue: 240/255, alpha: 1.0)
        return view
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
        let text0 = GV.language.getText(.tcBlank)
        cell.addColumn(text: text0, color: cellColor)
        let text1 = String(gamesForShow[indexPath.row].place).fixLength(length: columns[1].length)
        cell.addColumn(text: text1, color: cellColor) // GameNumber
        let text2 = "  " + (playerName).fixLength(length: columns[2].length - 2, leadingBlanks: false)
        cell.addColumn(text: text2, color: cellColor)
        let text3 = (String(gamesForShow[indexPath.row].score)).fixLength(length: columns[3].length)
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
