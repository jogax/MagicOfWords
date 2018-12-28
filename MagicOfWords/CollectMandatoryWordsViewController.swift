//
//  CollectMandatoryWords.swift
//  MagicOfWords
//
//  Created by Jozsef Romhanyi on 23/12/2018.
//  Copyright © 2018 Jozsef Romhanyi. All rights reserved.
//

import UIKit
import RealmSwift
import GameplayKit

#if DEBUG

class CollectMandatoryWordsViewController: UIViewController, WTTableViewDelegate {
    var showMandatoryWordsView: WTTableView? = WTTableView()
    var headerLine = ""
    let color = UIColor(red: 240/255, green: 240/255, blue: 240/255, alpha: 1.0)
    var lengthOfNickName = 18
    var lengthOfKeyWord = 12
    var lengthOfIsOnline = 0
    var lengthOfOnlineTime = 10
    var lengthOfGameNumber = 6
    var lengthOfScore = 5
    var lengthOfPlace = 5
    
    
    
    
    //    var lengthOfOnlineSince = 0
    let myFont = UIFont(name: "CourierNewPS-BoldMT", size: GV.onIpad ? 18 : 12)
    
    func didSelectedRow(tableView: UITableView, indexPath: IndexPath) {
        let word = mandatoryWordsTable[indexPath.row]
        try! RealmService.write {
            let wordModel = CommonString()
            wordModel.word = (GV.actLanguage + word).lowercased()
            RealmService.add(wordModel)
            savedMandatoryWords.append(word)
        }
        showMandatoryWords()
    }
    
    func getNumberOfSections() -> Int {
        return 1
    }
    
    func getNumberOfRowsInSections(section: Int) -> Int {
        return mandatoryWordsTable.count
    }
    
    var mandatoryWordsTable = [String]()
    
    func getTableViewCell(tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        let actColor = UIColor.white
        let width = tableView.frame.width
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! CustomTableViewCell
        cell.setFont(font: myFont!)
        cell.setCellSize(size: CGSize(width: width, height: self.view.frame.width * (GV.onIpad ? 0.040 : 0.010)))
        cell.setBGColor(color: UIColor.white) //showWordsBackgroundColor)
        cell.addColumn(text: " " + (mandatoryWordsTable[indexPath.row].fixLength(length: 100, leadingBlanks: false)), color: actColor)
        return cell
    }
    
    func getHeightForRow(tableView: UITableView, indexPath: IndexPath) -> CGFloat {
        return headerLine.height(font: myFont!) * 2
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
    
    //    let realm: Realm
    var allWordsItems: Results<WordListModel>?
    
    var allWordsNotificationToken: NotificationToken?
    
    var allWordsSubscription: SyncSubscription<WordListModel>?
    
    var allWordsSubscriptionToken: NotificationToken?
    //    var OKButton: UIButton?
    
    
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        //        let syncConfig = SyncConfiguration(user: GV.myUser!, realmURL: GV.REALM_URL, isPartial: true)
        //        self.realm = try! Realm(configuration: Realm.Configuration(syncConfiguration: syncConfig, objectTypes:[PlayerActivity.self]))
        //        self.allWordsItems = RealmService.objects(PlayerActivity.self).filter("isOnline == true").sorted(byKeyPath: "nickName", ascending: true)
        //        self.gameRecords = RealmService.objects(BestScoreForGame.self).filter("isOnline == true").sorted(byKeyPath: "nickName", ascending: true)
        //       self.allWordsItems = RealmService.objects(PlayerActivity.self).sorted(byKeyPath: "nickName", ascending: true)
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
        tableviewAdded = false
        getSavedMandatoryWords()
        showMandatoryWordsView!.setDelegate(delegate: self)
        showViewTable()
        getStartingPhrase()
        buttonsCreated = false
        buttonRadius = self.view.frame.width / 25
        
    }
    var inputField: UITextField?
    var tableviewAdded = false
    
    @objc func inputFieldDidChange(_ textField: UITextField) {
        searchPhrase = textField.text!
        showMandatoryWords()
    }

    private func getStartingPhrase() {
        let width = (self.view?.frame.width)! * 0.8
        let height = (self.view?.frame.height)! * 0.03
        let yPos = (self.view?.frame.height)! * 0.7
        inputField = UITextField (frame:CGRect(x:0, y:0, width:width, height: height))
        inputField!.center = CGPoint(x:(self.view?.center.x)!, y: yPos)
        inputField!.font = myFont
        inputField!.borderStyle = UITextField.BorderStyle.line
        inputField!.addTarget(self, action: #selector(inputFieldDidChange(_:)), for: .editingChanged)
        
        // Set UITextField background colour
        inputField!.backgroundColor = UIColor.white
        
        // Set UITextField text color
        inputField!.textColor = UIColor.black
        inputField!.placeholder = "search..."
        self.view?.addSubview(inputField!)
    }
    
    @objc func stopShowingTable() {
        showMandatoryWordsView!.isHidden = true
        dismiss(animated: true, completion: {
            print("Dismissed")
        })
    }
    
    var enabled = true
    var doneButton: UIButton?
    var no5Button: UIButton?
    var no6Button: UIButton?
    var no7Button: UIButton?
    var no8Button: UIButton?
    var no9Button: UIButton?
    var no10Button: UIButton?
    let bgColor = SKColor(red: 223/255, green: 255/255, blue: 216/255, alpha: 0.8)
    let playersTitle = "Player"
    let allTitle = "All"
    let bestTitle = "Best"
    let myTitleFont = UIFont(name: "TimesNewRomanPS-BoldMT", size: GV.onIpad ? 30 : 18)
    var sortUp = true
    var buttonsCreated = false
    
    
    private func createButtons() {
        let buttonCenterDistance = (showMandatoryWordsView!.frame.size.width - 2 * buttonRadius) / 4
        let buttonFrameWidth = 2 * buttonRadius
        let buttonFrame = CGRect(x: 0, y: 0, width:buttonFrameWidth, height: buttonFrameWidth)
        let yPos = showMandatoryWordsView!.frame.maxY + buttonRadius * 1.2
        let xPos1 = showMandatoryWordsView!.frame.minX + buttonRadius
        let center1 = CGPoint(x: xPos1, y:yPos)
        doneButton = createButton(imageName: "hook.png", imageSize: 0.05, title: "", frame: buttonFrame, center: center1, enabled: enabled)
        doneButton?.addTarget(self, action: #selector(self.stopShowingTable), for: .touchUpInside)
        self.view?.addSubview(doneButton!)
        let xPos2 = showMandatoryWordsView!.frame.minX + buttonRadius + buttonCenterDistance
        let center2 = CGPoint(x: xPos2, y:yPos)
        no5Button = createButton(imageName: "", title: "5", frame: buttonFrame, center: center2, enabled: enabled)
        no5Button?.addTarget(self, action: #selector(self.no5ButtonTapped), for: .touchUpInside)
        self.view?.addSubview(no5Button!)
        let xPos3 = showMandatoryWordsView!.frame.minX + buttonRadius + buttonCenterDistance * 2
        let center3 = CGPoint(x: xPos3, y:yPos)
        no6Button = createButton(imageName: "", title: "6", frame: buttonFrame, center: center3, enabled: enabled)
        no6Button?.addTarget(self, action: #selector(self.no6ButtonTapped), for: .touchUpInside)
        self.view?.addSubview(no6Button!)
        let xPos4 = showMandatoryWordsView!.frame.minX + buttonRadius + buttonCenterDistance * 3
        let center4 = CGPoint(x: xPos4, y:yPos)
        no7Button = createButton(imageName: "", title: "7", frame: buttonFrame, center: center4, enabled: enabled)
        no7Button?.addTarget(self, action: #selector(self.no7ButtonTapped), for: .touchUpInside)
        self.view?.addSubview(no7Button!)
        let xPos5 = showMandatoryWordsView!.frame.minX + buttonRadius + buttonCenterDistance * 4
        let center5 = CGPoint(x: xPos5, y:yPos)
        no8Button = createButton(imageName: "", title: "8", frame: buttonFrame, center: center5, enabled: enabled)
        no8Button!.addTarget(self, action: #selector(self.no8ButtonTapped), for: .touchUpInside)
        self.view?.addSubview(no8Button!)
        let xPos6 = showMandatoryWordsView!.frame.minX + buttonRadius + buttonCenterDistance * 4
        let center6 = CGPoint(x: xPos6, y:yPos)
        no9Button = createButton(imageName: "", title: "9", frame: buttonFrame, center: center6, enabled: enabled)
        no9Button!.addTarget(self, action: #selector(self.no9ButtonTapped), for: .touchUpInside)
        self.view?.addSubview(no9Button!)
        let xPos7 = showMandatoryWordsView!.frame.minX + buttonRadius + buttonCenterDistance * 4
        let center7 = CGPoint(x: xPos7, y:yPos)
        no10Button = createButton(imageName: "", title: "10", frame: buttonFrame, center: center7, enabled: enabled)
        no10Button!.addTarget(self, action: #selector(self.no10ButtonTapped), for: .touchUpInside)
        self.view?.addSubview(no10Button!)
        self.buttonsCreated = true
    }
    
    private func modifyButtonsPosition() {
        let height = showMandatoryWordsView!.frame.height * 0.5
        let center = self.view.frame.midY
        let calculatedYPos = center + height + self.buttonRadius * 1.2
        doneButton!.center = CGPoint(x: doneButton!.center.x, y: calculatedYPos)
        no5Button!.center = CGPoint(x: no5Button!.center.x, y: calculatedYPos)
        no6Button!.center = CGPoint(x: no6Button!.center.x, y: calculatedYPos)
        no7Button!.center = CGPoint(x: no7Button!.center.x, y: calculatedYPos)
        no8Button!.center = CGPoint(x: no8Button!.center.x, y: calculatedYPos)
        no9Button!.center = CGPoint(x: no9Button!.center.x, y: calculatedYPos)
        no10Button!.center = CGPoint(x: no10Button!.center.x, y: calculatedYPos)
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
    
//    private func setNewTableView(tableType: TableType) {
//        sortUp = true
//        initialLoadDone = false
//        self.tableType = tableType
//        showMandatoryWordsView!.removeFromSuperview()
//        showMandatoryWordsView = nil
//        showMandatoryWordsView = WTTableView()
//        showMandatoryWordsView!.setDelegate(delegate: self)
//    }
    
    @objc func no5ButtonTapped() {
        showMandatoryWords()
    }
    
    @objc func no6ButtonTapped() {
        showMandatoryWords()
    }
    
    @objc func no7ButtonTapped() {
        showMandatoryWords()
    }
    
    @objc func no8ButtonTapped() {
        showMandatoryWords()
    }
    
    @objc func no9ButtonTapped() {
        showMandatoryWords()
    }
    
    @objc func no10ButtonTapped() {
        showMandatoryWords()
    }
    
//    @objc func bestButtonTapped() {
//        setNewTableView(tableType: .BestScoreForGame)
//        showBestScoreForGame()
//    }
//
    @objc func sortButtonTapped() {
        //        showMandatoryWordsView?.removeFromSuperview()
        //        showMandatoryWordsView = nil
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
    
    var searchPhrase: String = ""
    
    private func showViewTable() {
        if !tableviewAdded {
            let origin = CGPoint(x: 0, y: 0)
            let height = view.frame.height * 0.6
            let width = view.frame.width * 0.5
            let size = CGSize(width: width, height: height)
            let center = CGPoint(x: 0.5 * view.frame.width, y: 0.35 * view.frame.height)
            showMandatoryWordsView!.frame=CGRect(origin: origin, size: size)
            showMandatoryWordsView!.center=center
            createButtons()
            modifyButtonsPosition()
            showMandatoryWordsView!.register(CustomTableViewCell.self, forCellReuseIdentifier: "cell")
            view.addSubview(showMandatoryWordsView!)
            tableviewAdded = true
        }
    }
    
    private func showMandatoryWords() {
        mandatoryWordsTable = [String]()
        let language = GV.actLanguage
        if searchPhrase.length > 0 {
            allWordsItems = realmWordList.objects(WordListModel.self).filter("word beginsWith %@", language + searchPhrase.lowercased())
            for item in allWordsItems! {
                let word = String(item.word.endingSubString(at:2))
                if word.length > 4 && word.length < 11 {
                    if !savedMandatoryWords.contains(word) {
                        mandatoryWordsTable.append(String(word))
                    }
                }
            }
        }
        showMandatoryWordsView!.reloadData()
    }
    struct PlayerData {
        var nickName = ""
        var keyWord = ""
        var isOnline = false
        var onlineTime = 0
    }
    var playerTable = [PlayerData]()
    
    
    struct BestScoreData {
        var gameNumber = 0
        var place = 0
        var score = 0
        var nickName = ""
    }
    var bestScoreTable = [BestScoreData]()
    
    
    private func setTableviewSize() {
        let origin = CGPoint(x: 0, y: 0)
        let maxHeight = view.frame.height * 0.8
        let calculatedHeight = headerLine.height(font: myFont!) * (CGFloat(bestScoreTable.count + 1))
        let height = maxHeight > calculatedHeight ? calculatedHeight : maxHeight
        let size = CGSize(width: headerLine.width(font: myFont!) * 1, height: height)
        let center = CGPoint(x: 0.5 * view.frame.width, y: 0.5 * view.frame.height)
        showMandatoryWordsView!.frame=CGRect(origin: origin, size: size)
        showMandatoryWordsView!.center=center
        modifyButtonsPosition()
    }
    
    
    private func readTextFile() {
        let language = GV.actLanguage
        let wordFileURL = Bundle.main.path(forResource: "\(language)Mandatory", ofType: "txt")
        // Read from the file Words
        var wordsFile = ""
        do {
            wordsFile = try String(contentsOfFile: wordFileURL!, encoding: String.Encoding.utf8)
        } catch let error as NSError {
            print("Failed reading from URL: \(String(describing: wordFileURL)), Error: " + error.localizedDescription)
        }
        let wordList = wordsFile.components(separatedBy: .newlines)
        let finished = "-----"
        if wordList.last! == finished || wordList[wordList.count - 2] == finished {
            print("done")
        } else {
            for word in wordList {
                if word.length < 5 {
                    print("word is too short: \(word)")
                } else if word.length > 10 {
                    print("word is too long: \(word)")
                } else if realmWordList.objects(WordListModel.self).filter("word = %@", language + word.lowercased()).count == 1 {
                    let wordModel = CommonString()
                    wordModel.word = (language + word).lowercased()
                    if !savedMandatoryWords.contains(where: {$0 == word}) {
                        try! RealmService.write {
                            RealmService.add(wordModel)
                            savedMandatoryWords.append(word)
                        }
                    } else {
                        print("word is in RealmCloud: \(word)")
                    }
                } else {
                    print("word not exists: \(word)")
                }
            }
        }
    }
    
    var mandatoryItems: Results<CommonString>?
    var mandatorySubscription: SyncSubscription<CommonString>?
    var mandatorySubscriptionToken: NotificationToken?
    
    private func getSavedMandatoryWords() {
        mandatoryItems = RealmService.objects(CommonString.self).filter("word BEGINSWITH %@", GV.actLanguage).sorted(byKeyPath: "word", ascending: true)
        mandatorySubscription = mandatoryItems!.subscribe(named: "mandatoryQuery")
        mandatorySubscriptionToken = mandatorySubscription!.observe(\.state) { [weak self]  state in
            switch state {
            case .creating:
                print("creating")
            // The subscription has not yet been written to the Realm
            case .pending:
                print("pending")
                // The subscription has been written to the Realm and is waiting
            // to be processed by the server
            case .complete:
                self!.savedMandatoryWords.removeAll()
                for item in self!.mandatoryItems! {
                    let word = item.word.endingSubString(at:2)
                    if word.length > 4 {
                        self!.savedMandatoryWords.append(item.word.endingSubString(at:2))
                    }
                }
                self!.readTextFile()
            default:
                print("state: \(state)")
            }
        }
    }
    var savedMandatoryWords = [String]()
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}
#endif