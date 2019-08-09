//
//  ShowGameCenterViewController
//  MagicOfWords
//
//  Created by Jozsef Romhanyi on 17/09/2018.
//  Copyright © 2018 Jozsef Romhanyi. All rights reserved.
//

import UIKit
import RealmSwift
import GameplayKit

#if DEBUG

class ShowGameCenterViewController: UIViewController, WTTableViewDelegate {
    var showGameCenterView: WTTableView? = WTTableView()
    var headerLine = ""
    let color = UIColor(red: 230/255, green: 230/255, blue: 240/255, alpha: 1.0)
    var lengthOfAlias = 16
    var lengthOfDevice = 18
    var lengthOfLand = 7
    var lengthOfIsOnline = 0
    var lengthOfOnlineTime = 9
    var lengthOfLastOnline = 18
    var lengthOfOnlineDuration = 8
    var lengthOfVersion = 10
    var lengthOfGameNumber = 6
    var lengthOfScore = 5
    var lengthOfPlace = 5


    
    
    //    var lengthOfOnlineSince = 0
    let myFont = UIFont(name: GV.actLabelFont, size: GV.onIpad ? 18 : 12)
    
    func didTappedButton(tableView: UITableView, indexPath: IndexPath, buttonName: String) {
        
    }
    

    
    func didSelectedRow(tableView: UITableView, indexPath: IndexPath) {
    }

    func getNumberOfSections() -> Int {
        return 1
    }
    
    func getNumberOfRowsInSections(section: Int) -> Int {
        return GV.globalInfoTable.count
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
        cell.setBGColor(color: actColor) //showWordsBackgroundColor)
        let isOnline = GV.globalInfoTable[indexPath.row].isOnline
        let origImage = UIImage(named: isOnline ? "online.png" : "offline.png")!
        let image = origImage.resizeImage(newWidth: cellHeight * 0.6)
        cell.addButton(image: image, xPos: cellHeight * 0.5, callBack: buttonTapped)
        cell.addColumn(text: " " + (GV.globalInfoTable[indexPath.row].alias.fixLength(length: lengthOfAlias - 4, leadingBlanks: false)), color: actColor, xPos: cellHeight * 1.0) // WordColumn
        cell.addColumn(text: (GV.globalInfoTable[indexPath.row].device.fixLength(length: lengthOfDevice, leadingBlanks: false)), color: actColor)
        cell.addColumn(text: (GV.globalInfoTable[indexPath.row].land.fixLength(length: lengthOfLand, leadingBlanks: false)), color: actColor)
        cell.addColumn(text: String(GV.globalInfoTable[indexPath.row].allTime.HourMin).fixLength(length: lengthOfOnlineTime, leadingBlanks: true), color: actColor)
        if GV.onIpad {
            cell.addColumn(text: String(GV.globalInfoTable[indexPath.row].lastDay).fixLength(length: lengthOfLastOnline, leadingBlanks: false), color: actColor)
            cell.addColumn(text: String(GV.globalInfoTable[indexPath.row].lastTime.HourMin).fixLength(length: lengthOfOnlineDuration, leadingBlanks: false), color: actColor)
            cell.addColumn(text: GV.globalInfoTable[indexPath.row].version.fixLength(length: lengthOfVersion, leadingBlanks: false), color: actColor)
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
        var text5 = ""
        var text6 = ""
        var text7 = ""
        text1 = "\(GV.language.getText(.tcPlayer)) ".fixLength(length: lengthOfAlias, center: true)
        text2 = "\(GV.language.getText(.tcDevice)) ".fixLength(length: lengthOfDevice, center: true)
        text3 = "\(GV.language.getText(.tcLand)) ".fixLength(length: lengthOfLand, center: true)
        text4 = "\(GV.language.getText(.tcOnlineTime)) ".fixLength(length: lengthOfOnlineTime, center: true)
        if GV.onIpad {
            text5 = "\(GV.language.getText(.tcLastOnline))".fixLength(length: lengthOfLastOnline, center: true)
            text6 = "\(GV.language.getText(.tcLastOnlineTime))".fixLength(length: lengthOfOnlineDuration, center: true)
            text7 = "\(GV.language.getText(.tcVersion))".fixLength(length: lengthOfVersion, center: true)
        }
        headerLine += text1
        headerLine += text2
        headerLine += text3
        headerLine += text4
        headerLine += text5
        headerLine += text6
        headerLine += text7
        lengthOfIsOnline = text2.length
    }
    
    //    let realm: Realm
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
        view.addSubview(showGameCenterView!)
        showGameCenterView!.setDelegate(delegate: self)
        GCHelper.shared.getAllGlobalInfos(completion: {self.allGlobalDataLoaded()})
        buttonsCreated = false
        buttonRadius = self.view.frame.width / 25

    }
    
    @objc private func allGlobalDataLoaded() {
        showPlayerActivity()
    }
    
    @objc func stopShowingTable() {
        showGameCenterView!.isHidden = true
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
    let myTitleFont = UIFont(name: GV.actFont, size: GV.onIpad ? 30 : 10)
    var sortUp = true
    var buttonsCreated = false

//    private func createButtons() {
//        let buttonCenterDistance = (showGameCenterView!.frame.size.width - 2 * buttonRadius) / 4
//        let buttonFrameWidth = 2 * buttonRadius
//        let buttonFrame = CGRect(x: 0, y: 0, width:buttonFrameWidth, height: buttonFrameWidth)
//        let yPos = showGameCenterView!.frame.maxY + buttonRadius * 1.2
//        let xPos1 = showGameCenterView!.frame.minX + buttonRadius
//        let center1 = CGPoint(x: xPos1, y:yPos)
//        doneButton = createButton(imageName: "hook.png", imageSize: 0.05, title: "", frame: buttonFrame, center: center1, enabled: enabled)
//        doneButton?.addTarget(self, action: #selector(self.stopShowingTable), for: .touchUpInside)
//        self.view?.addSubview(doneButton!)
//        let xPos2 = showGameCenterView!.frame.minX + buttonRadius + buttonCenterDistance
//        let center2 = CGPoint(x: xPos2, y:yPos)
//        playersButton = createButton(imageName: "players.png", imageSize: 0.05, title: "", frame: buttonFrame, center: center2, enabled: enabled)
//        playersButton?.addTarget(self, action: #selector(self.playersButtonTapped), for: .touchUpInside)
//        self.view?.addSubview(playersButton!)
//        let xPos3 = showGameCenterView!.frame.minX + buttonRadius + buttonCenterDistance * 2
//        let center3 = CGPoint(x: xPos3, y:yPos)
//        scoreButton = createButton(imageName: "bestScores.png", imageSize: 0.05, title: "", frame: buttonFrame, center: center3, enabled: enabled)
//        scoreButton?.addTarget(self, action: #selector(self.scoreButtonTapped), for: .touchUpInside)
//        self.view?.addSubview(scoreButton!)
//        let xPos4 = showGameCenterView!.frame.minX + buttonRadius + buttonCenterDistance * 3
//        let center4 = CGPoint(x: xPos4, y:yPos)
//        bestButton = createButton(imageName: "firstplaces.png", imageSize: 0.05, title: "", frame: buttonFrame, center: center4, enabled: enabled)
//        bestButton?.addTarget(self, action: #selector(self.bestButtonTapped), for: .touchUpInside)
//        self.view?.addSubview(bestButton!)
//        let xPos5 = showGameCenterView!.frame.minX + buttonRadius + buttonCenterDistance * 4
//        let center5 = CGPoint(x: xPos5, y:yPos)
//        sortButton = createButton(imageName: "sortdown.png", imageSize: 0.5, title: "", frame: buttonFrame, center: center5, enabled: enabled)
//        sortButton!.addTarget(self, action: #selector(self.sortButtonTapped), for: .touchUpInside)
//        self.view?.addSubview(sortButton!)
//        self.buttonsCreated = true
//    }
    
    private func modifyButtonsPosition() {
        let height = showGameCenterView!.frame.height * 0.5
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
    
    private func setNewTableView() {
        sortUp = true
        initialLoadDone = false
        showGameCenterView!.removeFromSuperview()
        showGameCenterView = nil
        showGameCenterView = WTTableView()
        showGameCenterView!.setDelegate(delegate: self)
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
        calculateColumnWidths()
        let origin = CGPoint(x: 0, y: 0)
        let maxHeight = view.frame.height * 0.8
        let calculatedHeight = headerLine.height(font: myFont!) * (CGFloat(GV.globalInfoTable.count + 1))
        let height = maxHeight > calculatedHeight ? calculatedHeight : maxHeight
        let size = CGSize(width: CGFloat(headerLine.width(font: myFont!) * 1), height:height)
        let center = CGPoint(x: 0.5 * view.frame.width, y: 0.5 * view.frame.height)
        showGameCenterView!.frame=CGRect(origin: origin, size: size)
        showGameCenterView!.center=center
        //        showGameCenterView!.frame = self.view.frame
//        if !buttonsCreated {
//            createButton()
//        }
//        modifyButtonsPosition()
        showGameCenterView!.register(CustomTableViewCell.self, forCellReuseIdentifier: "cell")
        showGameCenterView!.reloadData()
    }

    
    private func setTableviewSize() {
        let origin = CGPoint(x: 0, y: 0)
        let maxHeight = view.frame.height * 0.8
        let calculatedHeight = headerLine.height(font: myFont!) * (CGFloat(GV.globalInfoTable.count + 1))
        let height = maxHeight > calculatedHeight ? calculatedHeight : maxHeight
        let size = CGSize(width: headerLine.width(font: myFont!) * 1, height: height)
        let center = CGPoint(x: 0.5 * view.frame.width, y: 0.5 * view.frame.height)
        showGameCenterView!.frame=CGRect(origin: origin, size: size)
        showGameCenterView!.center=center
        modifyButtonsPosition()
    }
    
//    private func showBestScoreForGame() {
//        deactivateSubscriptions()
//        forGameItems = RealmService.objects(BestScoreForGame.self).filter("language = %@ AND gameNumber >= %d AND gameNumber <= %d", GV.actLanguage, GV.minGameNumber, GV.maxGameNumber).sorted(byKeyPath: "gameNumber", ascending: true)
//        forGameSubscription = forGameItems!.subscribe(named: "\(GV.actLanguage)bestForGameQuery")
//        forGameSubscriptionToken = forGameSubscription.observe(\.state) { [weak self]  state in
//            switch state {
//            case .creating:
//                print("creating")
//            // The subscription has not yet been written to the Realm
//            case .pending:
//                print("pending")
//                // The subscription has been written to the Realm and is waiting
//            // to be processed by the server
//            case .complete:
//                self!.view.addSubview(self!.showGameCenterView!)
//                self!.calculateColumnWidths()
//                self!.generateTableData()
//                self!.setTableviewSize()
//                self!.showGameCenterView!.register(CustomTableViewCell.self, forCellReuseIdentifier: "cell")
//                self!.showGameCenterView!.reloadData()
////                print("complete: count records: \(String(describing: self!.forGameItems!.count))")
//                self!.bestScoreNotificationToken = self!.forGameItems!.observe { [weak self] (changes) in
//                    guard let showGameCenterView = self?.showGameCenterView else { return }
//                    
//                    switch changes {
//                    case .initial:
//                        self!.initialLoadDone = true
//                    case .update(_, let deletions, let insertions, let modifications):
//                        if self!.initialLoadDone && self!.tableType == .BestScoreSync {
//                            // Query results have changed, so apply them to the UITableView
//                            if insertions.count > 0 {
//                                showGameCenterView.frame.size.height += CGFloat(insertions.count) * self!.headerLine.height(font: self!.myFont!)
//                            }
//                            if deletions.count > 0 {
//                                showGameCenterView.frame.size.height -= CGFloat(deletions.count) * self!.headerLine.height(font: self!.myFont!)
//                            }
//                            showGameCenterView.beginUpdates()
//                            showGameCenterView.insertRows(at: insertions.map({ IndexPath(row: $0, section: 0) }),
//                                                              with: .automatic)
//                            showGameCenterView.deleteRows(at: deletions.map({ IndexPath(row: $0, section: 0)}),
//                                                              with: .automatic)
//                            showGameCenterView.reloadRows(at: modifications.map({ IndexPath(row: $0, section: 0) }),
//                                                              with: .automatic)
//                            showGameCenterView.endUpdates()
//                        }
//                    case .error(let error):
//                        // An error occurred while opening the Realm file on the background worker thread
//                        fatalError("\(error)")
//                    }
//                }
//                
//                // The subscription has been processed by the server and all objects
//            // matching the query are in the local Realm
//            case .invalidated:
//                print("invalidated")
//            // The subscription has been removed
//            case .error(let error):
//                print("error: \(error)")
//                // An error occurred while processing the subscription
//            }        }
//        
//        
//    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}
#endif
