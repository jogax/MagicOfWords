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
    var lengthOfNickName = 0
    var lengthOfKeyWord = 0
    var lengthOfIsOnline = 0
    var lengthOfGameNumber = 0
    var lengthOfScore = 0
    //    var lengthOfOnlineSince = 0
    var lengthOfOnlineTime = 0
    let myFont = UIFont(name: "CourierNewPS-BoldMT", size: GV.onIpad ? 18 : 12)
    var tableType: TableType = .Players
    func didSelectedRow(tableView: UITableView, indexPath: IndexPath) {
        
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
            return playerActivityItems!.count
        case .BestScoreSync:
            return bestScoreItems!.count
        case .BestScoreForGame:
            return 0
        }
    }
    
    func getTableViewCell(tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        let actColor = (indexPath.row % 2 == 0 ? UIColor.white : color)
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! CustomTableViewCell
        cell.setFont(font: myFont!)
        cell.setCellSize(size: CGSize(width: tableView.frame.width * (GV.onIpad ? 0.040 : 0.010), height: self.view.frame.width * (GV.onIpad ? 0.040 : 0.010)))
        cell.setBGColor(color: UIColor.white) //showWordsBackgroundColor)
        switch tableType {
        case .Players:
            cell.addColumn(text: "  " + (playerActivityItems![indexPath.row].nickName!.fixLength(length: lengthOfNickName - 4, leadingBlanks: false)), color: actColor) // WordColumn
            cell.addColumn(text: (playerActivityItems![indexPath.row].keyWord!.fixLength(length: lengthOfKeyWord, leadingBlanks: false)), color: actColor)
            cell.addColumn(text: String(playerActivityItems![indexPath.row].isOnline).fixLength(length: lengthOfIsOnline, leadingBlanks: false), color: actColor)
            cell.addColumn(text: String(playerActivityItems![indexPath.row].onlineTime.HourMinSec).fixLength(length: lengthOfOnlineTime, leadingBlanks: false), color: actColor)
        case .BestScoreSync:
            cell.addColumn(text: "  " + String(bestScoreItems![indexPath.row].gameNumber).fixLength(length: lengthOfGameNumber, leadingBlanks: false), color: actColor)
            cell.addColumn(text: (bestScoreItems![indexPath.row].owner!.nickName?.fixLength(length: lengthOfNickName - 4, leadingBlanks: false))!, color: actColor) // WordColumn
            cell.addColumn(text: String(bestScoreItems![indexPath.row].score).fixLength(length: lengthOfScore, leadingBlanks: false), color: actColor)
        default: break
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
        lengthOfNickName = 22
        lengthOfKeyWord = 12
        lengthOfOnlineTime = 15
        lengthOfGameNumber = 4
        lengthOfScore = 5
        
        headerLine = ""
        let text1 = "\(GV.language.getText(.tcNickName)) ".fixLength(length: lengthOfNickName, center: true)
        let text2 = "\(GV.language.getText(.tcIsOnline)) "
        let text3 = "\(GV.language.getText(.tcOnlineTime)) "
        headerLine += text1.fixLength(length: lengthOfNickName, center: true)
        headerLine += text2
        headerLine += text3
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
    
    private func createButton(imageName: String, title: String, frame: CGRect, center: CGPoint, cornerRadius: CGFloat, enabled: Bool)->UIButton {
        let button = UIButton()
        if imageName.length > 0 {
            let image = UIImage(named: imageName)
            button.setImage(image, for: UIControl.State.normal)
        }
        if title.length > 0 {
            button.setTitle(title, for: .normal)
            button.setTitleColor(UIColor.black, for: .normal)
            button.titleLabel?.font = UIFont(name: "TimesNewRomanPS-BoldMT", size: GV.onIpad ? 30 : 18)
            
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
    let myTitleFont = UIFont(name: "TimesNewRomanPS-BoldMT", size: GV.onIpad ? 30 : 18)
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
        doneButton = createButton(imageName: "hook.png", imageSize: 0.5, title: "", frame: buttonFrame, center: center1, enabled: enabled)
        doneButton?.addTarget(self, action: #selector(self.stopShowingTable), for: .touchUpInside)
        self.view?.addSubview(doneButton!)
        let xPos2 = showPlayerActivityView!.frame.minX + buttonRadius + buttonCenterDistance
        let center2 = CGPoint(x: xPos2, y:yPos)
        playersButton = createButton(imageName: "", title: playersTitle, frame: buttonFrame, center: center2, cornerRadius: buttonRadius, enabled: enabled)
        playersButton?.addTarget(self, action: #selector(self.playersButtonTapped), for: .touchUpInside)
        self.view?.addSubview(playersButton!)
        let xPos3 = showPlayerActivityView!.frame.minX + buttonRadius + buttonCenterDistance * 2
        let center3 = CGPoint(x: xPos3, y:yPos)
        scoreButton = createButton(imageName: "", title: allTitle, frame: buttonFrame, center: center3, cornerRadius: buttonRadius, enabled: enabled)
        scoreButton?.addTarget(self, action: #selector(self.scoreButtonTapped), for: .touchUpInside)
        self.view?.addSubview(scoreButton!)
        let xPos4 = showPlayerActivityView!.frame.minX + buttonRadius + buttonCenterDistance * 3
        let center4 = CGPoint(x: xPos4, y:yPos)
        bestButton = createButton(imageName: "", imageSize: 0.6, title: bestTitle, frame: buttonFrame, center: center4, enabled: enabled)
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
        self.tableType = tableType
        showPlayerActivityView!.removeFromSuperview()
        showPlayerActivityView = nil
        showPlayerActivityView = WTTableView()
        showPlayerActivityView!.setDelegate(delegate: self)
    }
    
    @objc func playersButtonTapped() {
        sortUp = true
        setNewTableView(tableType: .Players)
        showPlayerActivity()
//        setSortButtonImage()
//        addLetterToSearchingWord(letter: questionMark)
    }
    
    @objc func scoreButtonTapped() {
        setNewTableView(tableType: .BestScoreSync)
        sortUp = true
        showScores()
    }
    
    @objc func bestButtonTapped() {
        sortUp = true
//        setSortButtonImage()
//        removeLastLetterFromSearchingWord()
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
        self.playerActivityItems = RealmService.objects(PlayerActivity.self).filter("isOnline == true").sorted(byKeyPath: "nickName", ascending: true)
        playerSubscription = playerActivityItems!.subscribe(named: "pleyerActivityQuery")
        playerSubscriptionToken = playerSubscription!.observe(\.state) { [weak self]  state in
            print("in Subscription!")
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
                let maxHeight = self!.view.frame.height * 0.8
                let calculatedHeight = self!.headerLine.height(font: self!.myFont!) * (CGFloat(self!.playerActivityItems!.count + 1))
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

                self!.showPlayerActivityView!.register(CustomTableViewCell.self, forCellReuseIdentifier: "cell")
                print("complete: count records: \(String(describing: self!.playerActivityItems!.count))")
                self!.playerNotificationToken = self!.playerActivityItems!.observe { [weak self] (changes) in
                    self!.view.addSubview(self!.showPlayerActivityView!)
                    guard let showPlayerActivityView = self?.showPlayerActivityView else { return }
                    switch changes {
                    case .initial:
                        // Results are now populated and can be accessed without blocking the UI
                        //                showPlayerActivityView.reloadData()
                        self!.initialLoadDone = true
                    //                print("Initial Data displayed")
                    case .update(_, let deletions, let insertions, let modifications):
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
            }
        }
        
    }
    
    private func showScores() {
        if playerSubscription != nil {
            playerSubscriptionToken!.invalidate()
            playerSubscription!.unsubscribe()
        }
        if bestScoreSubscription != nil {
            bestScoreSubscriptionToken!.invalidate()
            bestScoreSubscription!.unsubscribe()
        }
        bestScoreItems = RealmService.objects(BestScoreSync.self).filter("language = %@ AND score > 0", GV.actLanguage).sorted(byKeyPath: "gameNumber", ascending: true)
        bestScoreSubscription = bestScoreItems!.subscribe(named: "bestScoreQuery")
        bestScoreSubscriptionToken = bestScoreSubscription.observe(\.state) { [weak self]  state in
            print("in Subscription!")
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
                let origin = CGPoint(x: 0, y: 0)
                let maxHeight = self!.view.frame.height * 0.8
                let calculatedHeight = self!.headerLine.height(font: self!.myFont!) * (CGFloat(self!.bestScoreItems!.count + 1))
                let height = maxHeight > calculatedHeight ? calculatedHeight : maxHeight
                let size = CGSize(width: self!.headerLine.width(font: self!.myFont!) * 1, height: height)
                let center = CGPoint(x: 0.5 * self!.view.frame.width, y: 0.5 * self!.view.frame.height)
                self!.showPlayerActivityView!.frame=CGRect(origin: origin, size: size)
                self!.showPlayerActivityView!.center=center
                self!.modifyButtonsPosition()
                self!.showPlayerActivityView!.register(CustomTableViewCell.self, forCellReuseIdentifier: "cell")
                print("complete: count records: \(String(describing: self!.bestScoreItems!.count))")
                self!.bestScoreNotificationToken = self!.bestScoreItems!.observe { [weak self] (changes) in
                    guard let showPlayerActivityView = self?.showPlayerActivityView else { return }
                    
                    switch changes {
                    case .initial:
                        // Results are now populated and can be accessed without blocking the UI
                        showPlayerActivityView.reloadData()
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
