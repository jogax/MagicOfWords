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
    var myDelegate: ShowGamesSceneDelegate?
    let myTitleFont = UIFont(name: GV.actFont, size: GV.onIpad ? 30 : 10)
    var actType = ScoreType.Easy
    var background = SKSpriteNode(imageNamed: "magier")
    var initialLoadDone = false

    override func didMove(to view: SKView) {        
        try! realm.safeWrite() {
            GV.basicDataRecord.showingScoreType = ScoreType.Easy.rawValue
            GV.basicDataRecord.showingTimeScope = TimeScope.All.rawValue
        }
        
        lineHeight =  "A".height(font: myFont!) * 1.25
        self.zPosition = 50
        GCHelper.shared.getScoresForShow(completion: {self.showTable()})
    }
    
    private func showTable() {
        actType = ScoreType(rawValue: GV.basicDataRecord.showingScoreType)!
        gamesForShow.removeAll()
        for item in GV.scoreForShowTable {
            if !item.player.lowercased().begins(with: "jogax") && item.scoreType == actType {
                let type = item.scoreType
                let timeScope = item.timeScope
                let place = gamesForShow.count == 0 ? 1 : gamesForShow.last!.place + 1
                let player = item.player
                let score = item.score
                let me = item.me
                gamesForShow.append(ScoreForShow(scoreType: type, timeScope: timeScope, place: place, player: player, score: score, me: me))
            }
        }
        showFoundedGamesInTableView()
   }
    
    private func createLabel(text: String, target: Selector, lineNr: CGFloat) {
        let width = showGamesInTableView!.frame.width //self.frame.width //text.width(font:myFont!)
        let height = text.height(font:myFont!) * 1.5
        let myX = self.frame.midX - width / 2
        let yPos = showGamesInTableView!.frame.maxY + lineHeight * lineNr * 2
        let label = UILabel(frame: CGRect(x: myX, y: yPos, width: width, height: height))
        label.text = text
        label.font = myFont!
        label.textColor = .blue
        label.textAlignment = .center
        label.backgroundColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.5)
        label.isUserInteractionEnabled = true
        
        let gesture = UITapGestureRecognizer(target: self, action: target)
        label.addGestureRecognizer(gesture)
        view!.addSubview(label)
    }
    
    @objc private func typeLabelClicked() {
        let alert = UIAlertController(title: "",
                                      message: "",
                                      preferredStyle: .alert)
        let easyAction = UIAlertAction(title: GV.language.getText(.tcEasyPlay), style: .default,
                                          handler: {[unowned self] (paramAction:UIAlertAction!) in
                                            try! realm.safeWrite() {
                                                GV.basicDataRecord.showingScoreType = ScoreType.Easy.rawValue
                                            }
                                            GCHelper.shared.getScoresForShow(completion: {self.showTable()})
        })
        alert.addAction(easyAction)
        let mediumAction = UIAlertAction(title: GV.language.getText(.tcMediumPlay), style: .default,
                                       handler: {[unowned self] (paramAction:UIAlertAction!) in
                                        try! realm.safeWrite() {
                                            GV.basicDataRecord.showingScoreType = ScoreType.Medium.rawValue
                                        }
                                        GCHelper.shared.getScoresForShow(completion: {self.showTable()})
        })
        alert.addAction(mediumAction)
        let wordCountAction = UIAlertAction(title: GV.language.getText(.tcWordCount), style: .default,
                                       handler: {[unowned self] (paramAction:UIAlertAction!) in
                                        try! realm.safeWrite() {
                                            GV.basicDataRecord.showingScoreType = ScoreType.WordCount.rawValue
                                        }
                                        GCHelper.shared.getScoresForShow(completion: {self.showTable()})
        })
        alert.addAction(wordCountAction)
        view?.window?.rootViewController?.present(alert, animated: true, completion: nil)
    }
    
    @objc private func timeScopeLabelClicked() {
        let alert = UIAlertController(title: "",
                                      message: "",
                                      preferredStyle: .alert)
        let easyAction = UIAlertAction(title: GV.language.getText(.tcAll), style: .default,
                                       handler: {[unowned self] (paramAction:UIAlertAction!) in
                                        try! realm.safeWrite() {
                                            GV.basicDataRecord.showingTimeScope = TimeScope.All.rawValue
                                        }
                                        GCHelper.shared.getScoresForShow(completion: {self.showTable()})
        })
        alert.addAction(easyAction)
        let mediumAction = UIAlertAction(title: GV.language.getText(.tcWeek), style: .default,
                                         handler: {[unowned self] (paramAction:UIAlertAction!) in
                                            try! realm.safeWrite() {
                                                GV.basicDataRecord.showingTimeScope = TimeScope.Week.rawValue
                                            }
                                            GCHelper.shared.getScoresForShow(completion: {self.showTable()})
        })
        alert.addAction(mediumAction)
        let wordCountAction = UIAlertAction(title: GV.language.getText(.tcToday), style: .default,
                                            handler: {[unowned self] (paramAction:UIAlertAction!) in
                                                try! realm.safeWrite() {
                                                    GV.basicDataRecord.showingTimeScope = TimeScope.Today.rawValue
                                                }
                                                GCHelper.shared.getScoresForShow(completion: {self.showTable()})
        })
        alert.addAction(wordCountAction)
        view?.window?.rootViewController?.present(alert, animated: true, completion: nil)
    }

    public func setDelegate(delegate: ShowGamesSceneDelegate) {
        myDelegate = delegate
    }

    private func removeLabels() {
        if view != nil {
            for subView in view!.subviews as [UIView] {
                if type(of: subView) == UILabel.self {
                    subView.removeFromSuperview()
                }
            }
        }
    }

    @objc public func goBack(gameNumberSelected: Bool = false, gameNumber: Int = 0, restart: Bool = false) {
        removeLabels()
        if showGamesInTableView != nil {
            showGamesInTableView!.isHidden = true
            showGamesInTableView = nil
        }
         if myDelegate == nil {
            return
        }
        myDelegate!.backToMenuScene(gameNumberSelected: gameNumberSelected, gameNumber: gameNumber, restart: restart)
    }

    var showGamesInTableView: WTTableView?
    var gamesForShow = [ScoreForShow]()
    let myFont = UIFont(name: "CourierNewPS-BoldMT", size: GV.onIpad ? 18 : 14)
    var lineHeight: CGFloat = 0
    var realmLoadingCompleted = false

    private func showFoundedGamesInTableView() {
        if showGamesInTableView != nil {
            showGamesInTableView!.removeFromSuperview()
        }
        showGamesInTableView = WTTableView()
        calculateColumnWidths()
        showGamesInTableView?.setDelegate(delegate: self)
        showGamesInTableView?.register(CustomTableViewCell.self, forCellReuseIdentifier: "cell")

        let origin = CGPoint(x: 0.5 * (self.frame.width - title.width(font: myFont!)), y: 0)
        let lineHeight = title.height(font: myFont!)
        let headerframeHeight = lineHeight * 2.2
        var showingWordsHeight = CGFloat(gamesForShow.count) * 1.3 * lineHeight
        if showingWordsHeight  > self.frame.height * 0.5 {
            var counter = CGFloat(gamesForShow.count)
            repeat {
                counter -= 1
                showingWordsHeight = lineHeight * counter
            } while showingWordsHeight + headerframeHeight > self.frame.height * (GV.onIpad ? 0.9 : 0.6)
        }
        let height = showingWordsHeight + headerframeHeight
        let size = CGSize(width: widthOfView, height: height)
        showGamesInTableView?.frame=CGRect(origin: origin, size: size)
        let center = CGPoint(x: 0.5 * view!.frame.width, y: self.view!.frame.height * 0.1 + height / 2)
        self.showGamesInTableView!.center=center
        self.showGamesInTableView!.reloadData()

        self.scene?.view?.addSubview(showGamesInTableView!)
        removeLabels()
//        createChooseTypeLabel(yPos: showGamesInTableView!.frame.maxY + lineHeight * 2)
//        createChooseTimeScopeLabel(yPos: showGamesInTableView!.frame.maxY + 4 * lineHeight)
        createLabel(text: GV.language.getText(.tcChooseWhatYouWant), target: #selector(typeLabelClicked), lineNr: 1)
        createLabel(text: GV.language.getText(.tcChooseTimeScope), target: #selector(timeScopeLabelClicked), lineNr: 2)
        createLabel(text: GV.language.getText(.tcBack), target: #selector(goBack), lineNr: 3)
//        createGoBackLabel(yPos: showGamesInTableView!.frame.maxY + 6 * lineHeight)
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
        actType = ScoreType(rawValue: GV.basicDataRecord.showingScoreType)!
        columns.removeAll()
        let text0 = GV.language.getText(.tcBlank)
        let text1 = GV.language.getText(.tcPlace)
        let text2 = GV.language.getText(.tcPlayerHeader)
        let text3 = GV.language.getText(actType == .WordCount ? .tcCounters : .tcScore)
        let textConstant: TextConstants  = actType == .Easy ? .tcTableOfEasyBestscores : actType == .Medium ? .tcTableOfMediumBestscores : .tcTableOfWordCounts
        let text4 = GV.language.getText(textConstant)
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
        let textColor: UIColor = .black
        let view = UIView()
        let actType = ScoreType(rawValue: GV.basicDataRecord.showingScoreType)
        let label1 = UILabel(frame: CGRect(x: 0, y: 0, width: widthOfView, height: lineHeight))
        label1.font = myFont!
        let textConstant: TextConstants  = actType == .Easy ? .tcTableOfEasyBestscores : actType == .Medium ? .tcTableOfMediumBestscores : .tcTableOfWordCounts
        label1.text = GV.language.getText(textConstant).fixLength(length: title.length, center: true)
        label1.textAlignment = .center
        label1.textColor = textColor
        view.addSubview(label1)
        
        var labelPos: CGFloat = 0

        let lineHeight = (myFont?.lineHeight)!// * (GV.onIpad ? 1.5 : 2.0)
        for column in columns {
            let width = column.text.fixLength(length:column.length).width(font:myFont!)
            let label = UILabel(frame: CGRect(x: labelPos, y: lineHeight, width: width, height: lineHeight))
            labelPos += width
            label.text = column.text.fixLength(length: column.length, leadingBlanks: false)
            label.textColor = textColor
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
        return GV.onIpad ? 48 : 30
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

    func getNumberOfSections() -> Int {
        return 1
    }
    func getNumberOfRowsInSections(section: Int)->Int {
        let returnValue = gamesForShow.count
//        if GV.myPlace > gamesForShow.last!.place {
//            returnValue += 1
//        }
        return returnValue
    }

    func getHeightForRow(tableView: UITableView, indexPath: IndexPath) -> CGFloat {
        return lineHeight//title.height(font: myFont!) * 1.15//1.12
    }
    
}
