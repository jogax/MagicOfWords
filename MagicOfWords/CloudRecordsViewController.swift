//
//  CloudRecordsViewController.swift
//  MagicOfWords
//
//  Created by Jozsef Romhanyi on 17/09/2018.
//  Copyright © 2018 Jozsef Romhanyi. All rights reserved.
//

import UIKit
import RealmSwift
import GameplayKit

#if DEBUG

class CloudRecordsViewController: UIViewController, WTTableViewDelegate {
    var showPlayerActivityView: WTTableView? = WTTableView()
    var headerLine = ""
    let color = UIColor(red: 240/255, green: 240/255, blue: 240/255, alpha: 1.0)
    var lengthOfNickName = 16
    var lengthOfKeyWord = 9
    var lengthOfComment = 9
    var lengthOfIsOnline = 0
    var lengthOfOnlineTime = 9
    var lengthOfGameNumber = 6
    var lengthOfScore = 5
    var lengthOfPlace = 5


    
    
    //    var lengthOfOnlineSince = 0
    let myFont = UIFont(name: GV.actLabelFont, size: GV.onIpad ? 18 : 12)
    var tableType: TableType = .Players
    
    func didTappedButton(tableView: UITableView, indexPath: IndexPath, buttonName: String) {
        
    }
    

    
    func didSelectedRow(tableView: UITableView, indexPath: IndexPath) {
        let nickName = bestScoreTable[indexPath.row].nickName
//        for deleting a complete user from Realm Cloud
        if nickName == "xxx" {
//            let playerActivityWithNickName = RealmService.objects(PlayerActivity.self).filter("nickName = %@", nickName).first!
//            let name = playerActivityWithNickName.name
//            let bestScoreItems = RealmService.objects(BestScoreForGame.self)
//            try! RealmService.safeWrite() {
//                for item in bestScoreItems {
//                    let actName = item.owner!.name
//                    if actName == name {
//                        RealmService.delete(item)
//                    }
//                }
//                let scoreItems = RealmService.objects(BestScoreSync.self).filter("playerName = %@", name)
//                for item in scoreItems {
//                    RealmService.delete(item)
//                }
//                RealmService.delete(playerActivityWithNickName)
//            }
//            print("name: \(name), count: \(bestScoreItems.count)")
//
        } else {
            let oldBestScoreTable = bestScoreTable
            bestScoreTable.removeAll()
            for item in oldBestScoreTable {
                if item.nickName == nickName {
                    bestScoreTable.append(item)
                }
            }
            setTableviewSize()
            showPlayerActivityView!.reloadData()
        }
    }

    func getNumberOfSections() -> Int {
        switch tableType {
        case .Players:
            return 1
        case .BestScoreSync:
            return 1
        case .BestScoreForGame:
            return 1
        }
    }
    
    func getNumberOfRowsInSections(section: Int) -> Int {
        switch tableType {
        case .Players:
            return playerTable.count
        case .BestScoreSync:
            return bestScoreTable.count
        case .BestScoreForGame:
            return bestScoreTable.count
        }
    }
    
    @objc public func buttonTapped(indexPath: IndexPath) {
        
    }
    
    func getTableViewCell(tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        let actColor = (indexPath.row % 2 == 0 ? UIColor.white : color)
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! CustomTableViewCell
        let cellWidth = tableView.frame.width
        let cellHeight = headerLine.height(font: myFont!) * 1.0
        cell.setFont(font: myFont!)
        cell.setCellSize(size: CGSize(width: cellWidth, height: cellHeight))
//        cell.setCellSize(size: CGSize(width: tableView.frame.width * (GV.onIpad ? 0.040 : 0.010), height: self.view.frame.width * (GV.onIpad ? 0.040 : 0.010)))
        cell.setBGColor(color: UIColor.white) //showWordsBackgroundColor)
        switch tableType {
        case .Players:
            let isOnline = playerTable[indexPath.row].isOnline
            let origImage = UIImage(named: isOnline ? "online.png" : "offline.png")!
            let image = origImage.resizeImage(newWidth: cellHeight * 0.6)
            cell.addButton(image: image, xPos: cellHeight * 0.5, callBack: buttonTapped)
            cell.addColumn(text: " " + (playerTable[indexPath.row].nickName.fixLength(length: lengthOfNickName - 4, leadingBlanks: false)), color: actColor, xPos: cellHeight * 1.0) // WordColumn
            cell.addColumn(text: (playerTable[indexPath.row].keyWord.fixLength(length: lengthOfKeyWord, leadingBlanks: false)), color: actColor)
//            cell.addColumn(text: String(playerTable[indexPath.row].isOnline).fixLength(length: lengthOfIsOnline, leadingBlanks: false), color: actColor)
            cell.addColumn(text: (playerTable[indexPath.row].comment.fixLength(length: 10, leadingBlanks: false)), color: actColor)
            cell.addColumn(text: String(playerTable[indexPath.row].onlineTime.HourMinSec).fixLength(length: lengthOfOnlineTime, leadingBlanks: true), color: actColor)
        case .BestScoreSync:
            let actColor = (bestScoreTable[indexPath.row].gameNumber % 2 == 0 ? UIColor.white : color)
           cell.addColumn(text: "  " + String(bestScoreTable[indexPath.row].gameNumber).fixLength(length: lengthOfGameNumber, leadingBlanks: false), color: actColor)
            cell.addColumn(text: String(bestScoreTable[indexPath.row].place).fixLength(length: lengthOfPlace, leadingBlanks: false), color: actColor)
            cell.addColumn(text: String(bestScoreTable[indexPath.row].score).fixLength(length: lengthOfScore, leadingBlanks: false), color: actColor)
            cell.addColumn(text: (bestScoreTable[indexPath.row].nickName.fixLength(length: lengthOfNickName, leadingBlanks: false)), color: actColor) // WordColumn
        case .BestScoreForGame:
            let actColor = (bestScoreTable[indexPath.row].gameNumber % 2 == 0 ? UIColor.white : color)
            cell.addColumn(text: "  " + String(bestScoreTable[indexPath.row].gameNumber).fixLength(length: lengthOfGameNumber - 2, leadingBlanks: false), color: actColor)
            cell.addColumn(text: String(bestScoreTable[indexPath.row].score).fixLength(length: lengthOfScore + 4, leadingBlanks: false), color: actColor)
            cell.addColumn(text: (bestScoreTable[indexPath.row].nickName.fixLength(length: lengthOfNickName, leadingBlanks: false)), color: actColor) // WordColumn
        }
        return cell
    }
    
    func getHeightForRow(tableView: UITableView, indexPath: IndexPath) -> CGFloat {
        return headerLine.height(font: myFont!)
    }
    
    func setHeaderView(tableView: UITableView, headerView: UIView, section: Int) {
    }
    
    func fillHeaderView(tableView: UITableView, section: Int) -> UIView {
        let lineHeight = headerLine.height(font: myFont!)
        let width = headerLine.width(withConstrainedHeight: 0, font: myFont!)
        let view = UIView()
        let label1 = UILabel(frame: CGRect(x: 0, y: 0, width: width, height: lineHeight))
        label1.font = myFont!
        label1.text = headerLine
        view.addSubview(label1)
        let label2 = UILabel(frame: CGRect(x: 0, y: lineHeight, width: width, height: lineHeight))
        label2.font = myFont!
        label2.text = title
        view.addSubview(label2)
        view.backgroundColor = UIColor(red:240/255, green: 240/255, blue: 240/255, alpha: 1.0)
        return view
    }
    
    func getHeightForHeaderInSection(tableView: UITableView, section: Int) -> CGFloat {
        return headerLine.height(font: myFont!)
    }
    
    private func calculateColumnWidths() {
        
        headerLine = ""
        var text1 = ""
        var text2 = ""
        var text3 = ""
        var text4 = ""
        switch tableType {
        case .Players:
            text1 = "\(GV.language.getText(.tcNickName)) ".fixLength(length: lengthOfNickName, center: true)
            text2 = "\(GV.language.getText(.tcKeywordHeader)) ".fixLength(length: lengthOfKeyWord, center: true)
            text3 = "\(GV.language.getText(.tcComment)) ".fixLength(length: lengthOfComment, center: true)
            text4 = "\(GV.language.getText(.tcOnlineTime)) ".fixLength(length: lengthOfOnlineTime, center: true)
        case .BestScoreSync:
            text1 = "\(GV.language.getText(.tcGameNumber))".fixLength(length: lengthOfGameNumber, center: true)
            text2 = "\(GV.language.getText(.tcPlace)) ".fixLength(length: lengthOfPlace, center: true)
            text3 = "\(GV.language.getText(.tcScore)) ".fixLength(length: lengthOfScore, center: true)
            text4 = "\(GV.language.getText(.tcNickName)) ".fixLength(length: lengthOfNickName, center: true)
        case .BestScoreForGame:
            text1 = "\(GV.language.getText(.tcGameNumber))".fixLength(length: lengthOfGameNumber, center: true)
//            text2 = "\(GV.language.getText(.tcPlace)) ".fixLength(length: lengthOfPlace, center: true)
            text3 = "\(GV.language.getText(.tcScore)) ".fixLength(length: lengthOfScore, center: true)
            text4 = "\(GV.language.getText(.tcNickName)) ".fixLength(length: lengthOfNickName, center: true)
        }
        headerLine += text1
        headerLine += text2
        headerLine += text3
        headerLine += text4
        lengthOfIsOnline = text2.length
    }
    
    //    let realm: Realm
    var bestScoreItems: Results<BestScoreSync>?
    var forGameItems: Results<BestScoreForGame>?
    var playerActivityItems: Results<PlayerActivity>?
    
    var playerNotificationToken: NotificationToken?
    var bestScoreNotificationToken: NotificationToken?
    var forGameNotificationToken: NotificationToken?
    
    var playerSubscription: SyncSubscription<PlayerActivity>?
    var bestScoreSubscription: SyncSubscription<BestScoreSync>!
    var forGameSubscription: SyncSubscription<BestScoreForGame>!

    var playerSubscriptionToken: NotificationToken?
    var bestScoreSubscriptionToken: NotificationToken?
    var forGameSubscriptionToken: NotificationToken?
//    var OKButton: UIButton?
    
    
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        //        let syncConfig = SyncConfiguration(user: GV.myUser!, realmURL: GV.REALM_URL, isPartial: true)
        //        self.realm = try! Realm(configuration: Realm.Configuration(syncConfiguration: syncConfig, objectTypes:[PlayerActivity.self]))
//        self.playerActivityItems = RealmService.objects(PlayerActivity.self).filter("isOnline == true").sorted(byKeyPath: "nickName", ascending: true)
//        self.gameRecords = RealmService.objects(BestScoreForGame.self).filter("isOnline == true").sorted(byKeyPath: "nickName", ascending: true)
        //       self.playerActivityItems = RealmService.objects(PlayerActivity.self).sorted(byKeyPath: "nickName", ascending: true)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    var initialLoadDone = false
    var buttonRadius = CGFloat(0)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let myBackgroundImage = UIImageView (frame: UIScreen.main.bounds)
        myBackgroundImage.image = UIImage(named: "magier")
        myBackgroundImage.contentMode = UIView.ContentMode.scaleAspectFill
        self.view.insertSubview(myBackgroundImage, at: 0)
        view.addSubview(showPlayerActivityView!)
        showPlayerActivityView!.setDelegate(delegate: self)
        showPlayerActivity()
        buttonsCreated = false
        buttonRadius = self.view.frame.width / 25

    }
    
    @objc func stopShowingTable() {
        showPlayerActivityView!.isHidden = true
        dismiss(animated: true, completion: {
            print("Dismissed")
        })
    }
    
    var enabled = true
    var doneButton: UIButton?
    var playersButton: UIButton?
    var scoreButton: UIButton?
    var bestButton: UIButton?
    var sortButton: UIButton?
    let bgColor = SKColor(red: 223/255, green: 255/255, blue: 216/255, alpha: 0.8)
    let playersTitle = "Player"
    let allTitle = "All"
    let bestTitle = "Best"
    let myTitleFont = UIFont(name: GV.actFont, size: GV.onIpad ? 30 : 18)
    var sortUp = true
    var buttonsCreated = false
    enum TableType: Int {
        case Players = 0, BestScoreSync, BestScoreForGame
    }


    private func createButtons() {
        let buttonCenterDistance = (showPlayerActivityView!.frame.size.width - 2 * buttonRadius) / 4
        let buttonFrameWidth = 2 * buttonRadius
        let buttonFrame = CGRect(x: 0, y: 0, width:buttonFrameWidth, height: buttonFrameWidth)
        let yPos = showPlayerActivityView!.frame.maxY + buttonRadius * 1.2
        let xPos1 = showPlayerActivityView!.frame.minX + buttonRadius
        let center1 = CGPoint(x: xPos1, y:yPos)
        doneButton = createButton(imageName: "hook.png", imageSize: 0.05, title: "", frame: buttonFrame, center: center1, enabled: enabled)
        doneButton?.addTarget(self, action: #selector(self.stopShowingTable), for: .touchUpInside)
        self.view?.addSubview(doneButton!)
        let xPos2 = showPlayerActivityView!.frame.minX + buttonRadius + buttonCenterDistance
        let center2 = CGPoint(x: xPos2, y:yPos)
        playersButton = createButton(imageName: "players.png", imageSize: 0.05, title: "", frame: buttonFrame, center: center2, enabled: enabled)
        playersButton?.addTarget(self, action: #selector(self.playersButtonTapped), for: .touchUpInside)
        self.view?.addSubview(playersButton!)
        let xPos3 = showPlayerActivityView!.frame.minX + buttonRadius + buttonCenterDistance * 2
        let center3 = CGPoint(x: xPos3, y:yPos)
        scoreButton = createButton(imageName: "bestScores.png", imageSize: 0.05, title: "", frame: buttonFrame, center: center3, enabled: enabled)
        scoreButton?.addTarget(self, action: #selector(self.scoreButtonTapped), for: .touchUpInside)
        self.view?.addSubview(scoreButton!)
        let xPos4 = showPlayerActivityView!.frame.minX + buttonRadius + buttonCenterDistance * 3
        let center4 = CGPoint(x: xPos4, y:yPos)
        bestButton = createButton(imageName: "firstplaces.png", imageSize: 0.05, title: "", frame: buttonFrame, center: center4, enabled: enabled)
        bestButton?.addTarget(self, action: #selector(self.bestButtonTapped), for: .touchUpInside)
        self.view?.addSubview(bestButton!)
        let xPos5 = showPlayerActivityView!.frame.minX + buttonRadius + buttonCenterDistance * 4
        let center5 = CGPoint(x: xPos5, y:yPos)
        sortButton = createButton(imageName: "sortdown.png", imageSize: 0.5, title: "", frame: buttonFrame, center: center5, enabled: enabled)
        sortButton!.addTarget(self, action: #selector(self.sortButtonTapped), for: .touchUpInside)
        self.view?.addSubview(sortButton!)
        self.buttonsCreated = true
    }
    
    private func modifyButtonsPosition() {
        let height = showPlayerActivityView!.frame.height * 0.5
        let center = self.view.frame.midY
        let calculatedYPos = center + height + self.buttonRadius * 1.2
        doneButton!.center = CGPoint(x: doneButton!.center.x, y: calculatedYPos)
        playersButton!.center = CGPoint(x: playersButton!.center.x, y: calculatedYPos)
        scoreButton!.center = CGPoint(x: scoreButton!.center.x, y: calculatedYPos)
        bestButton!.center = CGPoint(x: bestButton!.center.x, y: calculatedYPos)
        sortButton!.center = CGPoint(x: sortButton!.center.x, y: calculatedYPos)
    }
    
    private func createButton(imageName: String, title: String, frame: CGRect, center: CGPoint, cornerRadius: CGFloat, enabled: Bool)->UIButton {
        let button = UIButton()
        if imageName.length > 0 {
            let image = UIImage(named: imageName)
            button.setImage(image, for: UIControl.State.normal)
        }
        if title.length > 0 {
            button.setTitle(title, for: .normal)
            button.setTitleColor(UIColor.black, for: .normal)
            button.titleLabel?.font = UIFont(name: GV.actFont, size: GV.onIpad ? 30 : 18)
            
        }
        button.backgroundColor = bgColor
        button.layer.cornerRadius = cornerRadius
        button.alpha = enabled ? 1.0 : 0.2
        button.isEnabled = enabled
        button.layer.borderWidth = GV.onIpad ? 5 : 3
        button.layer.borderColor = UIColor(red: 220/255, green: 220/255, blue: 220/255, alpha: 1.0).cgColor
        button.frame = frame
        button.center = center
        return button
    }
    


    private func createButton(imageName: String, imageSize: CGFloat = 1.0, title: String, frame: CGRect, center: CGPoint, enabled: Bool, color: UIColor? = nil)->UIButton {
        let button = UIButton()
        if imageName.length > 0 {
            let image = resizeImage(image: UIImage(named: imageName)!, newWidth: view.frame.width * imageSize)
            button.setImage(image, for: UIControl.State.normal)
        }
        if title.length > 0 {
            button.setTitle(title, for: .normal)
            button.setTitleColor(UIColor.black, for: .normal)
            button.titleLabel?.font = myTitleFont
        }
        button.backgroundColor = color == nil ? bgColor : color
        button.layer.cornerRadius = buttonRadius
        button.alpha = enabled ? 1.0 : 0.2
        button.isEnabled = enabled
        button.layer.borderWidth = GV.onIpad ? 5 : 3
        button.layer.borderColor = UIColor(red: 220/255, green: 220/255, blue: 220/255, alpha: 1.0).cgColor
        button.frame = frame
        button.center = center
        return button
    }
    
    private func setNewTableView(tableType: TableType) {
        sortUp = true
        initialLoadDone = false
        self.tableType = tableType
        showPlayerActivityView!.removeFromSuperview()
        showPlayerActivityView = nil
        showPlayerActivityView = WTTableView()
        showPlayerActivityView!.setDelegate(delegate: self)
    }
    
    @objc func playersButtonTapped() {
        unsubscribeSubscriptions()
        setNewTableView(tableType: .Players)
        showPlayerActivity()
    }
    
    @objc func scoreButtonTapped() {
        unsubscribeSubscriptions()
        setNewTableView(tableType: .BestScoreSync)
        showBestScoreSync()
    }
    
    @objc func bestButtonTapped() {
        unsubscribeSubscriptions()
        setNewTableView(tableType: .BestScoreForGame)
        showBestScoreForGame()
    }
    
    private func unsubscribeSubscriptions() {
        let subscriptions = realmSync!.subscriptions()
        for subscription in subscriptions {
            subscription.unsubscribe()
        }
    }
    
    @objc func sortButtonTapped() {
//        showPlayerActivityView?.removeFromSuperview()
//        showPlayerActivityView = nil
//        sortUp = !sortUp
//        setSortButtonImage()
//        showSearchResults()
    }

    func resizeImage(image: UIImage, newWidth: CGFloat) -> UIImage {
        
        let scale = newWidth / image.size.width
        let newHeight = image.size.height * scale
        UIGraphicsBeginImageContext(CGSize(width: newWidth, height: newHeight))
        image.draw(in: CGRect(x: 0, y: 0, width: newWidth, height: newHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
    
    private func showPlayerActivity() {
        deactivateSubscriptions()
        let sort = "myCommentar"
        self.playerActivityItems = RealmService.objects(PlayerActivity.self).filter("keyWord != %@ AND !(nickName BEGINSWITH %d)", "SimJogaxKey", "Sim").sorted(byKeyPath: sort, ascending: true)
        playerSubscription = playerActivityItems!.subscribe(named: "playerActivitySortedBy1:\(sort)")
        playerSubscriptionToken = playerSubscription!.observe(\.state) { [weak self]  state in
//                print("in Subscription!")
            switch state {
            case .creating:
                print("creating")
            // The subscription has not yet been written to the Realm
            case .pending:
                print("pending")
                // The subscription has been written to the Realm and is waiting
            // to be processed by the server
            case .complete:
                self!.calculateColumnWidths()
                let origin = CGPoint(x: 0, y: 0)
                //        let origin = CGPoint(x: 0.5 * (self.view.frame.width - (headerLine.width(font: myFont!))), y: 200)
                self!.generatePlayerData()
                let maxHeight = self!.view.frame.height * 0.8
                let calculatedHeight = self!.headerLine.height(font: self!.myFont!) * (CGFloat(self!.playerTable.count + 1))
                let height = maxHeight > calculatedHeight ? calculatedHeight : maxHeight
                let size = CGSize(width: self!.headerLine.width(font: self!.myFont!) * 1, height:height)
                let center = CGPoint(x: 0.5 * self!.view.frame.width, y: 0.5 * self!.view.frame.height)
                self!.showPlayerActivityView!.frame=CGRect(origin: origin, size: size)
                self!.showPlayerActivityView!.center=center
                //        showPlayerActivityView!.frame = self.view.frame
                if !self!.buttonsCreated {
                    self!.createButtons()
                }
                self!.modifyButtonsPosition()
//                self!.generatePlayerData()
                self!.showPlayerActivityView!.register(CustomTableViewCell.self, forCellReuseIdentifier: "cell")
                self!.showPlayerActivityView!.reloadData()
                print("complete: count records: \(String(describing: self!.playerActivityItems!.count))")
                self!.playerNotificationToken = self!.playerActivityItems!.observe { [weak self] (changes) in
                    self!.view.addSubview(self!.showPlayerActivityView!)
                    guard let showPlayerActivityView = self?.showPlayerActivityView else { return }
                    switch changes {
                    case .initial:
                        // Results are now populated and can be accessed without blocking the UI
                        showPlayerActivityView.reloadData()
                        self!.initialLoadDone = true
                    //                print("Initial Data displayed")
                    case .update(_, let deletions, let insertions, _):
                        if self!.initialLoadDone && self!.tableType == .Players {
                            // Query results have changed, so apply them to the UITableView
                            if insertions.count > 0 {
                                showPlayerActivityView.frame.size.height += CGFloat(insertions.count) * self!.headerLine.height(font: self!.myFont!)
                                self!.modifyButtonsPosition()
                            }
                            if deletions.count > 0 {
                                showPlayerActivityView.frame.size.height -= CGFloat(deletions.count) * self!.headerLine.height(font: self!.myFont!)
                                self!.modifyButtonsPosition()
                           }
                            self!.generatePlayerData()
                            self!.showPlayerActivityView!.reloadData()

//                            showPlayerActivityView.beginUpdates()
//                            showPlayerActivityView.insertRows(at: insertions.map({ IndexPath(row: $0, section: 0) }),
//                                                              with: .automatic)
//                            showPlayerActivityView.deleteRows(at: deletions.map({ IndexPath(row: $0, section: 0)}),
//                                                              with: .automatic)
//                            showPlayerActivityView.reloadRows(at: modifications.map({ IndexPath(row: $0, section: 0) }),
//                                                              with: .automatic)
//                            showPlayerActivityView.endUpdates()
                        }
                    case .error(let error):
                        // An error occurred while opening the Realm file on the background worker thread
                        fatalError("\(error)")
                    }
                }
                
                // The subscription has been processed by the server and all objects
            // matching the query are in the local Realm
            case .invalidated:
                print("invalitdated")
            // The subscription has been removed
            case .error(let error):
                print("error: \(error)")
                // An error occurred while processing the subscription
            }
        }
    }
    struct PlayerData {
        var nickName = ""
        var keyWord = ""
        var comment = ""
        var isOnline = false
        var onlineTime = 0
    }
    var playerTable = [PlayerData]()
    

    private func generatePlayerData() {
        var countOnlineUser = 0
        playerTable.removeAll()
        let users = playerActivityItems!.sorted(byKeyPath: "myCommentar")
        for user in users {
            var playerData = PlayerData()
            playerData.nickName = user.nickName!
            playerData.keyWord = user.keyWord == nil ? "" : user.keyWord!
            playerData.comment = user.myCommentar == nil ? "" : user.myCommentar!
            if playerData.comment.beginsWith ("Apl ") {
                continue
            }
            if user.lastTouched != nil {
                playerData.isOnline = user.isOnline && getLocalDate().timeIntervalSince(user.lastTouched!) <= 128
            } else {
                playerData.isOnline = false
                try! RealmService.safeWrite() {
                    user.isOnline = false
                }
            }
            playerData.onlineTime = user.onlineTime
            if playerData.isOnline {
                playerTable.insert(playerData, at:countOnlineUser)
                countOnlineUser += 1
            } else {
                playerTable.append(playerData)
            }
         }
    }
    
    private func showBestScoreSync() {
        deactivateSubscriptions()
        bestScoreItems = RealmService.objects(BestScoreSync.self).filter("language = %@ AND gameNumber >= %d AND gameNumber <= %d AND score > 0", GV.actLanguage, GV.minGameNumber, GV.maxGameNumber).sorted(byKeyPath: "gameNumber", ascending: true)
        bestScoreSubscription = bestScoreItems!.subscribe(named: "bestScoreQuery")
        bestScoreSubscriptionToken = bestScoreSubscription.observe(\.state) { [weak self]  state in
//            print("in Subscription!")
            switch state {
            case .creating:
                print("creating")
            // The subscription has not yet been written to the Realm
            case .pending:
                print("pending")
                // The subscription has been written to the Realm and is waiting
            // to be processed by the server
            case .complete:
                self!.view.addSubview(self!.showPlayerActivityView!)
                self!.generateTableData()
                self!.calculateColumnWidths()
                let origin = CGPoint(x: 0, y: 0)
                let maxHeight = self!.view.frame.height * 0.8
                let calculatedHeight = self!.headerLine.height(font: self!.myFont!) * (CGFloat(self!.bestScoreTable.count + 1))
                let height = maxHeight > calculatedHeight ? calculatedHeight : maxHeight
                let size = CGSize(width: self!.headerLine.width(font: self!.myFont!) * 1, height: height)
                let center = CGPoint(x: 0.5 * self!.view.frame.width, y: 0.5 * self!.view.frame.height)
                self!.showPlayerActivityView!.frame=CGRect(origin: origin, size: size)
                self!.showPlayerActivityView!.center=center
                self!.modifyButtonsPosition()
                self!.showPlayerActivityView!.register(CustomTableViewCell.self, forCellReuseIdentifier: "cell")
                self!.showPlayerActivityView!.reloadData()
                print("complete: count records: \(String(describing: self!.bestScoreItems!.count))")
                self!.bestScoreNotificationToken = self!.bestScoreItems!.observe { [weak self] (changes) in
                    guard let showPlayerActivityView = self?.showPlayerActivityView else { return }
                    
                    switch changes {
                    case .initial:
                        self!.initialLoadDone = true
                    case .update(_, let deletions, let insertions, let modifications):
                        if self!.initialLoadDone && self!.tableType == .BestScoreSync {
                            // Query results have changed, so apply them to the UITableView
                            if insertions.count > 0 {
                                showPlayerActivityView.frame.size.height += CGFloat(insertions.count) * self!.headerLine.height(font: self!.myFont!)
                            }
                            if deletions.count > 0 {
                                showPlayerActivityView.frame.size.height -= CGFloat(deletions.count) * self!.headerLine.height(font: self!.myFont!)
                            }
                            showPlayerActivityView.beginUpdates()
                            showPlayerActivityView.insertRows(at: insertions.map({ IndexPath(row: $0, section: 0) }),
                                                              with: .automatic)
                            showPlayerActivityView.deleteRows(at: deletions.map({ IndexPath(row: $0, section: 0)}),
                                                              with: .automatic)
                            showPlayerActivityView.reloadRows(at: modifications.map({ IndexPath(row: $0, section: 0) }),
                                                              with: .automatic)
                            showPlayerActivityView.endUpdates()
                        }
                    case .error(let error):
                        // An error occurred while opening the Realm file on the background worker thread
                        fatalError("\(error)")
                    }
                }
                
                // The subscription has been processed by the server and all objects
            // matching the query are in the local Realm
            case .invalidated:
                print("invalitdated")
            // The subscription has been removed
            case .error(let error):
                print("error: \(error)")
                // An error occurred while processing the subscription
            }        }
        

    }
    
    struct BestScoreData {
        var gameNumber = 0
        var place = 0
        var score = 0
        var nickName = ""
    }
    var bestScoreTable = [BestScoreData]()
    
    private func generateTableData() {
        bestScoreTable.removeAll()
        switch tableType {
        case .BestScoreSync:
            if bestScoreItems!.count > 0 {
                for actGameNumber in GV.minGameNumber...GV.maxGameNumber {
                    let scoreItems = bestScoreItems!.filter("gameNumber = %d", actGameNumber).sorted(byKeyPath: "score", ascending: false)
                    for (place, item) in scoreItems.enumerated() {
                        var bestScoreData = BestScoreData()
                        bestScoreData.gameNumber = actGameNumber
                        bestScoreData.place = place + 1
                        bestScoreData.score = item.score
                        if item.owner != nil {
                            bestScoreData.nickName = item.owner!.nickName!
                        }
                        bestScoreTable.append(bestScoreData)
                    }
                }
            }
        case .BestScoreForGame:
            if forGameItems!.count > 0 {
                var generateRecord = false
                for actGameNumber in GV.minGameNumber...GV.maxGameNumber {
                    if forGameItems!.filter("gameNumber = %d", actGameNumber).count > 0 {
                        let item = forGameItems!.filter("gameNumber = %d", actGameNumber).first!
                        var bestScoreData = BestScoreData()
                        bestScoreData.gameNumber = actGameNumber
                        bestScoreData.score = item.bestScore
                        if item.owner == nil {
                            generateRecord = true
                            try! RealmService.safeWrite() {
    //                            RealmService.delete(item)
                            }
                        } else {
                            bestScoreData.nickName = item.owner!.nickName!
                            bestScoreTable.append(bestScoreData)
                        }
                    } else {
                        generateRecord = true
                    }
                    if generateRecord {
                        let items = RealmService.objects(BestScoreSync.self).filter("gameNumber = %d", actGameNumber).sorted(byKeyPath: "score", ascending: false)
                        if items.count > 0 {
                            let item = items.first!
                            let bestScoreForGameItem = BestScoreForGame()
                            bestScoreForGameItem.combinedPrimary = String(actGameNumber) + item.language
                            bestScoreForGameItem.gameNumber = actGameNumber
                            bestScoreForGameItem.language = item.language
                            bestScoreForGameItem.bestScore = item.score
                            bestScoreForGameItem.timeStamp = item.timeStamp
                            bestScoreForGameItem.owner = item.owner!
                            try! RealmService.safeWrite() {
                                RealmService.add(bestScoreForGameItem)
                            }
                        }
                    }
                }
            }
            default:
                break
            }
    }
    
    private func deactivateSubscriptions() {
//        if playerSubscription != nil {
//            playerSubscriptionToken!.invalidate()
//            playerSubscription!.unsubscribe()
//        }
//        if bestScoreSubscription != nil {
//            bestScoreSubscriptionToken!.invalidate()
//            bestScoreSubscription!.unsubscribe()
//        }
    }
    
    private func setTableviewSize() {
        let origin = CGPoint(x: 0, y: 0)
        let maxHeight = view.frame.height * 0.8
        let calculatedHeight = headerLine.height(font: myFont!) * (CGFloat(bestScoreTable.count + 1))
        let height = maxHeight > calculatedHeight ? calculatedHeight : maxHeight
        let size = CGSize(width: headerLine.width(font: myFont!) * 1, height: height)
        let center = CGPoint(x: 0.5 * view.frame.width, y: 0.5 * view.frame.height)
        showPlayerActivityView!.frame=CGRect(origin: origin, size: size)
        showPlayerActivityView!.center=center
        modifyButtonsPosition()
    }
    
    private func showBestScoreForGame() {
        deactivateSubscriptions()
        forGameItems = RealmService.objects(BestScoreForGame.self).filter("language = %@ AND gameNumber >= %d AND gameNumber <= %d", GV.actLanguage, GV.minGameNumber, GV.maxGameNumber).sorted(byKeyPath: "gameNumber", ascending: true)
        forGameSubscription = forGameItems!.subscribe(named: "\(GV.actLanguage)bestForGameQuery")
        forGameSubscriptionToken = forGameSubscription.observe(\.state) { [weak self]  state in
            switch state {
            case .creating:
                print("creating")
            // The subscription has not yet been written to the Realm
            case .pending:
                print("pending")
                // The subscription has been written to the Realm and is waiting
            // to be processed by the server
            case .complete:
                self!.view.addSubview(self!.showPlayerActivityView!)
                self!.calculateColumnWidths()
                self!.generateTableData()
                self!.setTableviewSize()
//                let origin = CGPoint(x: 0, y: 0)
//                let maxHeight = self!.view.frame.height * 0.8
//                let calculatedHeight = self!.headerLine.height(font: self!.myFont!) * (CGFloat(self!.bestScoreTable.count + 1))
//                let height = maxHeight > calculatedHeight ? calculatedHeight : maxHeight
//                let size = CGSize(width: self!.headerLine.width(font: self!.myFont!) * 1, height: height)
//                let center = CGPoint(x: 0.5 * self!.view.frame.width, y: 0.5 * self!.view.frame.height)
//                self!.showPlayerActivityView!.frame=CGRect(origin: origin, size: size)
//                self!.showPlayerActivityView!.center=center
//                self!.modifyButtonsPosition()
                self!.showPlayerActivityView!.register(CustomTableViewCell.self, forCellReuseIdentifier: "cell")
                self!.showPlayerActivityView!.reloadData()
                print("complete: count records: \(String(describing: self!.forGameItems!.count))")
                self!.bestScoreNotificationToken = self!.forGameItems!.observe { [weak self] (changes) in
                    guard let showPlayerActivityView = self?.showPlayerActivityView else { return }
                    
                    switch changes {
                    case .initial:
                        self!.initialLoadDone = true
                    case .update(_, let deletions, let insertions, let modifications):
                        if self!.initialLoadDone && self!.tableType == .BestScoreSync {
                            // Query results have changed, so apply them to the UITableView
                            if insertions.count > 0 {
                                showPlayerActivityView.frame.size.height += CGFloat(insertions.count) * self!.headerLine.height(font: self!.myFont!)
                            }
                            if deletions.count > 0 {
                                showPlayerActivityView.frame.size.height -= CGFloat(deletions.count) * self!.headerLine.height(font: self!.myFont!)
                            }
                            showPlayerActivityView.beginUpdates()
                            showPlayerActivityView.insertRows(at: insertions.map({ IndexPath(row: $0, section: 0) }),
                                                              with: .automatic)
                            showPlayerActivityView.deleteRows(at: deletions.map({ IndexPath(row: $0, section: 0)}),
                                                              with: .automatic)
                            showPlayerActivityView.reloadRows(at: modifications.map({ IndexPath(row: $0, section: 0) }),
                                                              with: .automatic)
                            showPlayerActivityView.endUpdates()
                        }
                    case .error(let error):
                        // An error occurred while opening the Realm file on the background worker thread
                        fatalError("\(error)")
                    }
                }
                
                // The subscription has been processed by the server and all objects
            // matching the query are in the local Realm
            case .invalidated:
                print("invalitdated")
            // The subscription has been removed
            case .error(let error):
                print("error: \(error)")
                // An error occurred while processing the subscription
            }        }
        
        
    }
        
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}
#endif
