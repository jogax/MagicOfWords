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
    
//    private func createShowingItem() {
//        let finishedGames = realm.objects(GameDataModel.self).filter("gameStatus = %d and language = %@", GV.GameStatusFinished, GV.language.getText(.tcAktLanguage))
//        createHeader(text: GV.language.getText(.tcGameNumber), index: 0)
//        createHeader(text: GV.language.getText(.tcScore), index: 1)
//        createHeader(text: GV.language.getText(.tcBestScore), index: 2)
//        var lineNr = 0
//        for finishedGame in finishedGames {
//            createItem(text: String(finishedGame.gameNumber + 1), index: 0, lineNr: lineNr)
//            createItem(text: String(finishedGame.score), index: 1, lineNr: lineNr)
//            createItem(text: String(0), index: 2, lineNr: lineNr)
//            lineNr += 1
//        }
//        createOKButton()
//    }
//
//    private func createHeader(text: String, index: Int) {
//        let label = SKLabelNode(fontNamed: "TimesNewRomanPS-BoldMT")// Snell Roundhand")
//        let yPosition = self.frame.height * 0.80
//        let xPosition = self.frame.size.width * xMultiplierTab[index]
//        label.position = CGPoint(x: xPosition, y: yPosition)
//        label.fontSize = self.frame.size.height * 0.018
//        label.fontSize = UIScreen.main.bounds.height * 0.03
//        label.fontColor = SKColor.blue
//        label.colorBlendFactor = 0.9
//        label.text = text
//        label.zPosition = self.zPosition + 1
//        label.horizontalAlignmentMode = .center
//        label.verticalAlignmentMode = .center
//        //        menuItem.name = String(String(score))
//        self.addChild(label)
//    }
//
//    private func createItem(text: String, index: Int, lineNr: Int) {
//        let label = SKLabelNode(fontNamed: "TimesNewRomanPS-BoldMT")// Snell Roundhand")
//        let yPosition = self.frame.height * (0.75 - CGFloat(lineNr) * 0.04)
//        let xPosition = self.frame.size.width * xMultiplierTab[index]
//        label.position = CGPoint(x: xPosition, y: yPosition)
//        label.fontSize = self.frame.size.height * 0.018
//        label.fontSize = UIScreen.main.bounds.height * 0.03
//        label.fontColor = SKColor.blue
//        label.colorBlendFactor = 0.9
//        label.text = text
//        label.zPosition = self.zPosition + 1
//        label.horizontalAlignmentMode = .center
//        label.verticalAlignmentMode = .center
////        menuItem.name = String(String(score))
//        self.addChild(label)
//    }
//
//    func createOKButton() {
//        let texture = SKTexture(imageNamed: "button.png")
//        let button = SKSpriteNode(texture: texture, color: .white, size: CGSize(width: self.size.width * 0.5, height: self.size.height * 0.2))
//        let yPosition = self.frame.size.height * 0.20
//        button.size = CGSize(width: self.frame.size.width * 0.4, height: self.frame.size.height * 0.1)
//        button.position = CGPoint(x: self.frame.size.width / 2, y: yPosition)
//        button.name = OKButtonName
//        let label = SKLabelNode(fontNamed: "TimesNewRomanPS-BoldMT")// Snell Roundhand")
//        label.fontSize = self.frame.size.height / 30
//        label.position = CGPoint(x:0, y: button.frame.height * 0.1)
//        label.fontColor = SKColor.blue
//        label.colorBlendFactor = 0.9
//        label.text = GV.language.getText(.tcOK)
//        label.zPosition = self.zPosition + 1
//        label.horizontalAlignmentMode = .center
//        label.verticalAlignmentMode = .center
//        label.name = OKLabelName
//        button.addChild(label)
//        self.addChild(button)
//    }
//
//    public func setDelegate(delegate: ShowFinishedGamesSceneDelegate) {
//        myDelegate = delegate
//    }
//
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
//        let firstTouch = touches.first
//        let touchLocation = firstTouch!.location(in: self)
//        let nodes = self.nodes(at: touchLocation)
//        if nodes.count > 0 {
//            for node in nodes {
//                let name = node.name
//                if name != nil {
//                    switch name {
//                    case OKLabelName:
//                        myDelegate!.backToMenuScene()
//                    default: break
//                    }
//                }
//            }
//        }
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
        //        showOwnWordsView.rowHeight = 20
        //        let indexPath = IndexPath(row: 0, section: 0)
        //        let frame = CGRect(x: 0, y: 0, width: self.frame.width * 0.8, height: self.frame.height * 0.4)//showOwnWordsTableView?.rectForRow(at: indexPath)
        
        let origin = CGPoint(x: 0.5 * (self.frame.width - CGFloat(title.length) * maxLengthMultiplier), y: 100)
        let lineHeight = (myFont?.lineHeight)! * (GV.onIpad ? 1.5 : 1.6)
        let headerframeHeight = lineHeight * 2
        var showingWordsHeight = CGFloat(gamesForShow.count) * lineHeight
        if showingWordsHeight  > self.frame.height * 0.9 {
            var counter = CGFloat(gamesForShow.count)
            repeat {
                counter -= 1
                showingWordsHeight = lineHeight * counter
            } while showingWordsHeight + headerframeHeight > self.frame.height * 0.9
        }
        let width = CGFloat(title.length) * maxLengthMultiplier
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
            item.gameNumber = String(finishedGame.gameNumber % 1000)
            item.score = String(finishedGame.score)
            (item.bestPlayer, item.bestScore) = getDataFromRealm(gameNumber: finishedGame.gameNumber)
            returnArray.append(item)
        }
        return returnArray
    }
    
    var lengthOfGameNumber: Int = 0
    var lengthOfScore: Int = 0
    var lengthOfBestPlaer: Int = 0
    var lengthOfBestScore: Int = 0
    var title = ""
    
    private func calculateColumnWidths() {
        title = ""
        let text1 = "\(GV.language.getText(.tcGameNumber)) "
        let text2 = "\(GV.language.getText(.tcScore)) "
        let text3 = "\(GV.language.getText(.tcBestPlayer)) "
        let text4 = "\(GV.language.getText(.tcBestScore)) "
        title += text1
        title += text2
        title += text3
        title += text4
        lengthOfGameNumber = text1.length
        lengthOfScore = text2.length
        lengthOfBestPlaer = text3.length
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
        //        let header = headerView as? UITableViewHeaderFooterView
        //        let fontSize = GV.onIpad ? self.frame.width * 0.018 : self.frame.width * 0.040
        //        header?.textLabel?.font = UIFont(name: "CourierNewPS-BoldMT", size: fontSize) // change it according to ur requirement
        //        header?.textLabel?.textAlignment = .left
        //        header?.textLabel?.textColor = UIColor.black // change it according to ur requirement
        //        header?.backgroundColor = UIColor.red //showWordsBackgroundColor
    }
    
    
    let showWordsBackgroundColor = UIColor(red:255/255, green: 204/255, blue: 153/255, alpha: 1.0)
    let maxLengthMultiplier: CGFloat = GV.onIpad ? 12 : 8
    
    
    func getTableViewCell(tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! CustomTableViewCell
        cell.setFont(font: myFont!)
        cell.setCellSize(size: CGSize(width: tableView.frame.width * (GV.onIpad ? 0.040 : 0.010), height: self.frame.width * (GV.onIpad ? 0.040 : 0.010)))
        cell.setBGColor(color: UIColor.white) //showWordsBackgroundColor)
        cell.addColumn(text: gamesForShow[indexPath.row].gameNumber.fixLength(length: lengthOfGameNumber, center: true)) // WordColumn
        cell.addColumn(text: String(gamesForShow[indexPath.row].score).fixLength(length: lengthOfScore))
        cell.addColumn(text: String(gamesForShow[indexPath.row].bestPlayer).fixLength(length: lengthOfBestPlaer))
        cell.addColumn(text: String(gamesForShow[indexPath.row].bestScore).fixLength(length: lengthOfBestScore)) // Score column
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

    
    private func getDataFromRealm(gameNumber: Int)->(String, String) {
        return ("", "")
    }


}
