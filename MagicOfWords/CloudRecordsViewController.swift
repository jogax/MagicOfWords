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
    let showPlayerActivityView = WTTableView()
    var headerLine = ""
    let color = UIColor(red: 240/255, green: 240/255, blue: 240/255, alpha: 1.0)
    var lengthOfNickName = 0
    var lengthOfIsOnline = 0
    var lengthOfOnlineSince = 0
    var lengthOfOnlineTime = 0
    let myFont = UIFont(name: "CourierNewPS-BoldMT", size: GV.onIpad ? 18 : 10)
    
    func getNumberOfSections() -> Int {
        return 1
    }
    
    func getNumberOfRowsInSections(section: Int) -> Int {
        return playerActivityItems.count
    }
    
    func getTableViewCell(tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") ?? UITableViewCell(style: .default, reuseIdentifier: "Cell")
//        cell.selectionStyle = .none
//        let  item = playerActivityItems[indexPath.row]
//        cell.textLabel?.text = item.name + "/" + item.nickName!
//        //        cell.accessoryType = item.isDone ? UITableViewCellAccessoryType.checkmark : UITableViewCellAccessoryType.none
//        return cell
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! CustomTableViewCell
        cell.setFont(font: myFont!)
        cell.setCellSize(size: CGSize(width: tableView.frame.width * (GV.onIpad ? 0.040 : 0.010), height: self.view.frame.width * (GV.onIpad ? 0.040 : 0.010)))
        cell.setBGColor(color: UIColor.white) //showWordsBackgroundColor)
        cell.addColumn(text: " " + (playerActivityItems[indexPath.row].nickName?.fixLength(length: lengthOfNickName, leadingBlanks: false))!) // WordColumn
        cell.addColumn(text: String(playerActivityItems[indexPath.row].isOnline).fixLength(length: lengthOfIsOnline), color: color) // Counter column
        if playerActivityItems[indexPath.row].onlineSince == nil {
            cell.addColumn(text: "".fixLength(length: 16))
        } else {
            cell.addColumn(text: ((playerActivityItems[indexPath.row].onlineSince?.description)?.subString(startPos: 0, length: 16))!)
        }
        cell.addColumn(text: String(playerActivityItems[indexPath.row].onlineTime.HourMinSec).fixLength(length: lengthOfOnlineTime), color: color) // Score column
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
        let text1 = " \(GV.language.getText(.tcNickName)) "
        let text2 = "\(GV.language.getText(.tcIsOnline)) "
        let text3 = "\(GV.language.getText(.tcOnlineSince)) "
        let text4 = "\(GV.language.getText(.tcOnlineTime)) "
        headerLine += text1.fixLength(length: 18, center: true)
        headerLine += text2
        headerLine += text3
        headerLine += text4
        lengthOfNickName = 18
        lengthOfIsOnline = text2.length
        lengthOfOnlineSince = 18
        lengthOfOnlineTime = text4.length
    }

    let realm: Realm
    let playerActivityItems: Results<PlayerActivity>
    var notificationToken: NotificationToken?
    var subscriptionToken: NotificationToken?
    var subscription: SyncSubscription<PlayerActivity>!

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        let syncConfig = SyncConfiguration(user: GV.myUser!, realmURL: GV.REALM_URL, isPartial: true)
        self.realm = try! Realm(configuration: Realm.Configuration(syncConfiguration: syncConfig, objectTypes:[PlayerActivity.self]))
        self.playerActivityItems = realm.objects(PlayerActivity.self).sorted(byKeyPath: "name", ascending: false)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(rightBarButtonDidClick))
//        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addButtonDidClick))
//        title = "To Do Item"
        view.addSubview(showPlayerActivityView)
        calculateColumnWidths()
//        let origin = CGPoint(x: 0.5 * (self.view.frame.width - (headerLine.width(font: myFont!))), y: self.view.frame.height * 0.08)
        let origin = CGPoint(x: 0.5 * (self.view.frame.width - (headerLine.width(font: myFont!))), y: 100)
        let size = CGSize(width: headerLine.width(font: myFont!), height: headerLine.height(font: myFont!))
        showPlayerActivityView.frame=CGRect(origin: origin, size: size)
        showPlayerActivityView.frame = self.view.frame
        showPlayerActivityView.setDelegate(delegate: self)
        showPlayerActivityView.register(CustomTableViewCell.self, forCellReuseIdentifier: "cell")
        subscription = playerActivityItems.subscribe(named: "myUserActivitys")
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
                showPlayerActivityView.reloadData()
            case .update(_, let deletions, let insertions, let modifications):
                // Query results have changed, so apply them to the UITableView
                showPlayerActivityView.beginUpdates()
                showPlayerActivityView.insertRows(at: insertions.map({ IndexPath(row: $0, section: 0) }),
                                     with: .automatic)
                showPlayerActivityView.deleteRows(at: deletions.map({ IndexPath(row: $0, section: 0)}),
                                     with: .automatic)
                showPlayerActivityView.reloadRows(at: modifications.map({ IndexPath(row: $0, section: 0) }),
                                     with: .automatic)
                showPlayerActivityView.endUpdates()
            case .error(let error):
                // An error occurred while opening the Realm file on the background worker thread
                fatalError("\(error)")
            }
        }    }
    
//    @objc func addButtonDidClick() {
//        let alertController = UIAlertController(title: "Add Item", message: "", preferredStyle: .alert)
//
//        alertController.addAction(UIAlertAction(title: "Save", style: .default, handler: {
//            alert -> Void in
//            let textField = alertController.textFields![0] as UITextField
//            let item = Item()
//            item.body = textField.text ?? ""
//            try! self.realm.write {
//                self.realm.add(item)
//            }
//            // do something with textField
//        }))
//        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
//        alertController.addTextField(configurationHandler: {(textField : UITextField!) -> Void in
//            textField.placeholder = "New Item Text"
//        })
//        self.present(alertController, animated: true, completion: nil)
//    }
    
//    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
//        guard editingStyle == .delete else { return }
//        let item = items[indexPath.row]
//        try! realm.write {
//            realm.delete(item)
//        }
//    }
//
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") ?? UITableViewCell(style: .default, reuseIdentifier: "Cell")
//        cell.selectionStyle = .none
//        let  item = playerActivityItems[indexPath.row]
//        cell.textLabel?.text = item.name + "/" + item.nickName!
////        cell.accessoryType = item.isDone ? UITableViewCellAccessoryType.checkmark : UITableViewCellAccessoryType.none
//        return cell
//    }
//
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return playerActivityItems.count
//    }
//
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        let item = items[indexPath.row]
//        try! realm.write {
//            item.isDone = !item.isDone
//        }
//    }
//
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
//    @objc func rightBarButtonDidClick() {
//        let alertController = UIAlertController(title: "Logout", message: "", preferredStyle: .alert)
//        alertController.addAction(UIAlertAction(title: "Yes, Logout", style: .destructive, handler: {
//            alert -> Void in
//            SyncUser.current?.logOut()
//            self.navigationController?.setViewControllers([WelcomeViewController()], animated: true)
//        }))
//        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
//        self.present(alertController, animated: true, completion: nil)
//    }
//
//    deinit {
//        notificationToken?.invalidate()
//    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
