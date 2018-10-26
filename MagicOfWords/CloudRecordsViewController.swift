//
//  CloudRecordsViewController.swift
//  MagicOfWords
//
//  Created by Jozsef Romhanyi on 17/09/2018.
//  Copyright © 2018 Jozsef Romhanyi. All rights reserved.
//

import UIKit
import RealmSwift

class CloudRecordsViewController: UIViewController, WTTableViewDelegate {
    var showPlayerActivityView: WTTableView? = WTTableView()
    var headerLine = ""
    let color = UIColor(red: 240/255, green: 240/255, blue: 240/255, alpha: 1.0)
    var lengthOfNickName = 0
    var lengthOfIsOnline = 0
    //    var lengthOfOnlineSince = 0
    var lengthOfOnlineTime = 0
    let myFont = UIFont(name: "CourierNewPS-BoldMT", size: GV.onIpad ? 18 : 12)
    func didSelectedRow(tableView: UITableView, indexPath: IndexPath) {
        
    }

    func getNumberOfSections() -> Int {
        return 2
    }
    
    func getNumberOfRowsInSections(section: Int) -> Int {
        switch section {
        case 0: return playerActivityItems.count
        case 1: return 0
        default: return 0
        }
    }
    
    func getTableViewCell(tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        //        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") ?? UITableViewCell(style: .default, reuseIdentifier: "Cell")
        //        cell.selectionStyle = .none
        //        let  item = playerActivityItems[indexPath.row]
        //        cell.textLabel?.text = item.name + "/" + item.nickName!
        //        //        cell.accessoryType = item.isDone ? UITableViewCellAccessoryType.checkmark : UITableViewCellAccessoryType.none
        //        return cell
        let actColor = (indexPath.row % 2 == 0 ? UIColor.white : color)
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! CustomTableViewCell
        cell.setFont(font: myFont!)
        cell.setCellSize(size: CGSize(width: tableView.frame.width * (GV.onIpad ? 0.040 : 0.010), height: self.view.frame.width * (GV.onIpad ? 0.040 : 0.010)))
        cell.setBGColor(color: UIColor.white) //showWordsBackgroundColor)
        cell.addColumn(text: "  " + (playerActivityItems[indexPath.row].nickName?.fixLength(length: lengthOfNickName - 4, leadingBlanks: false))!, color: actColor) // WordColumn
        cell.addColumn(text: String(playerActivityItems[indexPath.row].isOnline).fixLength(length: lengthOfIsOnline, leadingBlanks: false), color: actColor)
        cell.addColumn(text: String(playerActivityItems[indexPath.row].onlineTime.HourMinSec).fixLength(length: lengthOfOnlineTime, leadingBlanks: false), color: actColor)
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
        lengthOfOnlineTime = 15
        
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
    let playerActivityItems: Results<PlayerActivity>
    var notificationToken: NotificationToken?
    var subscriptionToken: NotificationToken?
    var subscription: SyncSubscription<PlayerActivity>!
    var OKButton: UIButton?
    
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        //        let syncConfig = SyncConfiguration(user: GV.myUser!, realmURL: GV.REALM_URL, isPartial: true)
        //        self.realm = try! Realm(configuration: Realm.Configuration(syncConfiguration: syncConfig, objectTypes:[PlayerActivity.self]))
        self.playerActivityItems = RealmService.objects(PlayerActivity.self).filter("isOnline == true").sorted(byKeyPath: "nickName", ascending: true)
//        self.gameRecords = RealmService.objects(BestScoreForGame.self).filter("isOnline == true").sorted(byKeyPath: "nickName", ascending: true)
        //       self.playerActivityItems = RealmService.objects(PlayerActivity.self).sorted(byKeyPath: "nickName", ascending: true)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    var initialLoadDone = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let myBackgroundImage = UIImageView (frame: UIScreen.main.bounds)
        myBackgroundImage.image = UIImage(named: "magier")
        myBackgroundImage.contentMode = UIView.ContentMode.scaleAspectFill
        self.view.insertSubview(myBackgroundImage, at: 0)
        
        
        view.addSubview(showPlayerActivityView!)
        showPlayerActivityView!.setDelegate(delegate: self)
        createOKButton()
        subscription = playerActivityItems.subscribe(named: "myUserActivitysSortedByNicknameAscOnline")
        subscriptionToken = subscription.observe(\.state) { [weak self]  state in
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
                let size = CGSize(width: self!.headerLine.width(font: self!.myFont!) * 1, height: self!.headerLine.height(font: self!.myFont!) * (CGFloat(self!.playerActivityItems.count + 1)))
                let center = CGPoint(x: 0.5 * self!.view.frame.width, y: 0.5 * self!.view.frame.height)
                self!.showPlayerActivityView!.frame=CGRect(origin: origin, size: size)
                self!.showPlayerActivityView!.center=center
                //        showPlayerActivityView!.frame = self.view.frame
                self!.showPlayerActivityView!.register(CustomTableViewCell.self, forCellReuseIdentifier: "cell")
                print("complete: count records: \(String(describing: self!.playerActivityItems.count))")
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
        notificationToken = playerActivityItems.observe { [weak self] (changes) in
            guard let showPlayerActivityView = self?.showPlayerActivityView else { return }
            switch changes {
            case .initial:
                // Results are now populated and can be accessed without blocking the UI
                //                showPlayerActivityView.reloadData()
                self!.initialLoadDone = true
                print("Initial Data displayed")
            case .update(_, let deletions, let insertions, let modifications):
                if self!.initialLoadDone {
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
        
    }
    
    
    func createOKButton() {
        let buttonFrame = CGRect(x: 0, y: 0, width:self.view.frame.width * 0.2, height: self.view.frame.width * 0.1)
        let center = CGPoint(x:self.view.frame.width * 0.5, y:self.view.frame.height * 0.2)
        let radius = buttonFrame.height * 0.5
        OKButton = createButton(imageName: "OK", title: "OK", frame: buttonFrame, center: center, cornerRadius: radius, enabled: true )
        OKButton?.addTarget(self, action: #selector(self.stopShowingTable), for: .touchUpInside)
        self.view?.addSubview(OKButton!)
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
        button.backgroundColor = color
        button.layer.cornerRadius = cornerRadius
        button.alpha = enabled ? 1.0 : 0.2
        button.isEnabled = enabled
        button.layer.borderWidth = GV.onIpad ? 5 : 3
        button.layer.borderColor = UIColor(red: 220/255, green: 220/255, blue: 220/255, alpha: 1.0).cgColor
        button.frame = frame
        button.center = center
        return button
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}
