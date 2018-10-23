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

public protocol ShowFinishedGamesSceneDelegate: class {
    func backToMenuScene()
}
class ShowFinishedGamesScene: SKScene, WTTableViewDelegate {
    let xMultiplierTab: [CGFloat] = [0.3, 0.5, 0.8]
    var myDelegate: ShowFinishedGamesSceneDelegate?
    let OKLabelName = "°°°OKLabel°°°"
    let OKButtonName = "°°°OKButton°°°"
    
    var background = SKSpriteNode(imageNamed: "magier")
    
//    override func didMoveToView(view: SKView) {
//        background.position = CGPoint(x: frame.size.width / 2, y: frame.size.height / 2)
//        addChild(background)
    override func didMove(to view: SKView) {
        background.position = CGPoint(x: frame.size.width / 2, y: frame.size.height / 2)
        let widthMultiplier = background.size.width / background.size.height
        
        background.size = CGSize(width: self.size.height * widthMultiplier, height: self.size.height)
        addChild(background)
//        self.backgroundColor = SKColor(red: 200/255, green: 220/255, blue: 208/255, alpha: 1)
        showFinishedGamesInTableView()
    }
    
    public func setDelegate(delegate: ShowFinishedGamesSceneDelegate) {
        myDelegate = delegate
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if myDelegate == nil {
            return
        }
        showGamesInTableView!.isHidden = true
        showGamesInTableView = nil
        myDelegate!.backToMenuScene()
    }
    
    var showGamesInTableView: WTTableView?
    var gamesForShow = [FinishedGameData]()
    let myFont = UIFont(name: "CourierNewPS-BoldMT", size: GV.onIpad ? 18 : 12)
    
    
    private func showFinishedGamesInTableView() {
        showGamesInTableView = WTTableView()
        gamesForShow = getGamesForShow()
        calculateColumnWidths()
        showGamesInTableView?.setDelegate(delegate: self)
        showGamesInTableView?.register(CustomTableViewCell.self, forCellReuseIdentifier: "cell")
        
        let origin = CGPoint(x: 0.5 * (self.frame.width - title.width(font: myFont!)), y: 100)
        let lineHeight = title.height(font: myFont!)
        let headerframeHeight = lineHeight * 2.2
        var showingWordsHeight = CGFloat(gamesForShow.count) * lineHeight
        if showingWordsHeight  > self.frame.height * 0.9 {
            var counter = CGFloat(gamesForShow.count)
            repeat {
                counter -= 1
                showingWordsHeight = lineHeight * counter
            } while showingWordsHeight + headerframeHeight > self.frame.height * 0.9
        }
        let width = title.width(font: myFont!)
        let size = CGSize(width: width, height: showingWordsHeight + headerframeHeight)
        showGamesInTableView?.frame=CGRect(origin: origin, size: size)
        self.showGamesInTableView?.reloadData()
        
        //        showOwnWordsTableView?.reloadData()
        self.scene?.view?.addSubview(showGamesInTableView!)
    }
    struct FinishedGameData {
        var gameNumber = ""
        var score = ""
        var bestPlayer = ""
        var bestScore = ""
    }
    private func getGamesForShow()->[FinishedGameData] {
        var returnArray: [FinishedGameData] = []
        let finishedGames = realm.objects(GameDataModel.self).filter("gameStatus = %d and language = %@", GV.GameStatusFinished, GV.language.getText(.tcAktLanguage))
        for finishedGame in finishedGames {
            var item = FinishedGameData()
            item.gameNumber = String((finishedGame.gameNumber % 1000) + 1)
            item.score = String(finishedGame.score)
            (item.bestPlayer, item.bestScore) = getDataFromRealmCloud(finishedGame: finishedGame)
            returnArray.append(item)
        }
        return returnArray
    }
    
    var lengthOfGameNumber: Int = 0
    var lengthOfScore: Int = 0
    var lengthOfBestPlayer: Int = 0
    var lengthOfBestScore: Int = 0
    var title = ""
    
    private func calculateColumnWidths() {
        title = ""
        let text1 = "  \(GV.language.getText(.tcGameNumber)) "
        let text2 = " \(GV.language.getText(.tcScore)) "
        let text3 = " \(GV.language.getText(.tcBestPlayer)) "
        let text4 = " \(GV.language.getText(.tcBestScore)) "
        title += text1
        title += text2
        title += text3
        title += text4
        lengthOfGameNumber = text1.length
        lengthOfScore = text2.length
        lengthOfBestPlayer = text3.length
        lengthOfBestScore = text4.length
    }
    func fillHeaderView(tableView: UITableView, section: Int) -> UIView {
        switch section {
        case 0:
            let view = UIView()
            //            let fontSize = GV.onIpad ? self.frame.width * 0.020 : self.frame.width * 0.040
            //            let myFont = UIFont(name: "CourierNewPS-BoldMT", size: fontSize) // change it according to ur requirement
            let lineHeight = (myFont?.lineHeight)!// * (GV.onIpad ? 1.5 : 2.0)
            let width = lineHeight * CGFloat(title.length)
            //            view.frame = CGRect(x: 50, y: 0, width: width, height: 2 * lineHeight)
            let label1 = UILabel(frame: CGRect(x: 0, y: 0, width: width, height: lineHeight))
            label1.font = myFont!
            label1.text = GV.language.getText(.tcCollectedOwnWords).fixLength(length: title.length, center: true)
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
    
    func getHeightForHeaderInSection(tableView: UITableView, section: Int)->CGFloat {
        return GV.onIpad ? 48 : 28
    }
    func setHeaderView(tableView: UITableView, headerView: UIView, section: Int) {
    }
    
    
    let showWordsBackgroundColor = UIColor(red:255/255, green: 204/255, blue: 153/255, alpha: 1.0)
    let maxLengthMultiplier: CGFloat = GV.onIpad ? 12 : 8
    
    
    func getTableViewCell(tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        let color = UIColor(red: 240/255, green: 240/255, blue: 240/255,alpha: 1.0)
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! CustomTableViewCell
        cell.setFont(font: myFont!)
        cell.setCellSize(size: CGSize(width: tableView.frame.width * (GV.onIpad ? 0.040 : 0.010), height: self.frame.width * (GV.onIpad ? 0.040 : 0.010)))
        cell.setBGColor(color: UIColor.white) //showWordsBackgroundColor)
        cell.addColumn(text: (gamesForShow[indexPath.row].gameNumber).fixLength(length: lengthOfGameNumber - 2)) // GameNumber
        cell.addColumn(text: String(gamesForShow[indexPath.row].score).fixLength(length: lengthOfScore), color: color) // My Score
        cell.addColumn(text: String(gamesForShow[indexPath.row].bestPlayer).fixLength(length: lengthOfBestPlayer - 1)) // Best Player
        cell.addColumn(text: String(gamesForShow[indexPath.row].bestScore).fixLength(length: lengthOfBestScore - 2), color: color) // Best Score
        cell.addButton(image: UIImage())
        return cell
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
        return title.height(font: myFont!)
    }
    

    private func getDataFromRealmCloud(finishedGame: GameDataModel)->(String, String) {
        var bestPlayerName = ""
        var bestScore = ""
        if GV.myUser != nil {
            var bestScoreForGame: Results<BestScoreForGame>?
//            var bestScoreForGameToken: NotificationToken?
            var bestScoreForGameSubscription: SyncSubscription<BestScoreForGame>?
            var forGameSubscriptionToken: NotificationToken?
            let combinedPrimaryForGame = String((finishedGame.gameNumber % 1000) + 1) + finishedGame.language
            bestScoreForGame = realmSync!.objects(BestScoreForGame.self).filter("combinedPrimary = %@", combinedPrimaryForGame)
            bestScoreForGameSubscription = bestScoreForGame!.subscribe(named: "FinishedRecord:\(combinedPrimaryForGame)")
            forGameSubscriptionToken = bestScoreForGameSubscription!.observe(\.state) { state in
                if state == .complete {
                    if bestScoreForGame!.count > 0 {
                        bestPlayerName = bestScoreForGame![0].owner!.nickName!
                        bestScore = String(bestScoreForGame![0].bestScore)
                    }
                    bestScoreForGameSubscription!.unsubscribe()

                } else {
                    print("state: \(state)")
                    bestScoreForGameSubscription!.unsubscribe()
                }
            }
        }
        return (bestPlayerName, bestScore)
    }


}
