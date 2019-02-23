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
    let savePhrase = " saved"
    //    var lengthOfOnlineSince = 0
    let myFont = UIFont(name: "CourierNewPS-BoldMT", size: GV.onIpad ? 20 : 12.5)
    enum WillDo: Int {
        case Nothing = 0, Substract, Add, Delete
    }
    private func modifyAfterButtonTapping(indexPath: IndexPath, willDo: WillDo) {
        if playerActivity != nil {
            let actItem = allWordsTable[choosedLength][indexPath.row]
            let components = actItem.components(separatedBy: " ")
            let word = components[0]
            let name = playerActivity![0].name
            var newPhrase = word
            let combinedKey = name + "°" + GV.actLanguage + "°" + word
            if RealmService.objects(ModifiedWordsModel.self).filter("combinedKey = %@", combinedKey).count == 0 {
                let modifiedWords = ModifiedWordsModel()
                modifiedWords.combinedKey = combinedKey
                modifiedWords.language = GV.actLanguage
                modifiedWords.word = word
                modifiedWords.willDo = willDo.rawValue
                modifiedWords.owner = playerActivity![0]
                try! RealmService.write {
                    RealmService.add(modifiedWords)
                }
                switch willDo {
                case .Substract: newPhrase += GV.language.getText(.tcIWillSeparate)
                case .Add:       newPhrase += GV.language.getText(.tcIWillAdd)
                case .Delete:    newPhrase += GV.language.getText(.tcIWillDelete)
                default: break
                }
            } else {
//                let modifiedWords = RealmService.objects(ModifiedWordsModel.self).filter("combinedKey = %@", combinedKey)
                switch willDo {
                case .Substract: break
                case .Add:       newPhrase += GV.language.getText(.tcChoosedWord)
                case .Delete:    break
                default: break
                }
                try! RealmService.write {
                    RealmService.delete(RealmService.objects(ModifiedWordsModel.self).filter("combinedKey = %@", combinedKey))
                }

            }
            allWordsTable[choosedLength][indexPath.row] = newPhrase
            showMandatoryWordsView!.reloadData()
        }
    }
    
    // minus Button
    @objc public func didTapped1Button(indexPath: IndexPath) {
        modifyAfterButtonTapping(indexPath: indexPath, willDo: .Substract)
    }

    // Plus Button
    @objc public func didTapped2Button(indexPath: IndexPath) {
        modifyAfterButtonTapping(indexPath: indexPath, willDo: .Add)
    }
    
    // Trashcan Button
    @objc public func didTapped3Button(indexPath: IndexPath) {
        modifyAfterButtonTapping(indexPath: indexPath, willDo: .Delete)
    }

   func didSelectedRow(tableView: UITableView, indexPath: IndexPath) {
//        var word = mandatoryWordsTable[indexPath.row]
//        try! RealmService.write() {
//            let wordModel = CommonString()
//            if word.length > savePhrase.length && word.ends(with: savePhrase) {
//                word = word.startingSubString(length: word.length - savePhrase.length).lowercased()
//
//                let toDelete = RealmService.objects(CommonString.self).filter("word = %@", GV.actLanguage + word).first!
//                savedMandatoryWords.removeAll { $0 == toDelete.word.endingSubString(at:2) }
//                RealmService.delete(toDelete)
//                mandatoryWordsTable[indexPath.row] = word.endingSubString(at: 2)
//                wordLengths[word.length - 4] -= 1
//                wordLengths[0] -= 1
//            } else {
//                wordModel.word = (GV.actLanguage + word).lowercased()
//                RealmService.add(wordModel)
//                savedMandatoryWords.append(word)
//                wordLengths[word.length - 4] += 1
//                wordLengths[0] += 1
//            }
//        }
//        print("wordLengths: \(wordLengths)")
//        showMandatoryWordsView!.reloadData()
    }
    
    func getNumberOfSections() -> Int {
        return 1
    }
    
    func getNumberOfRowsInSections(section: Int) -> Int {
        var returnValue = 0
        if allWordsTable.count > 0 {
            returnValue = allWordsTable[choosedLength].count
        }
        return returnValue
        
    }
    
    var mandatoryWordCountTable = [Int]()
    var allWordsTable = [[String]]()
    
    func getTableViewCell(tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        let actColor = UIColor.white
        let width = tableView.frame.width
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! CustomTableViewCell
        cell.setFont(font: myFont!)
        cell.setCellSize(size: CGSize(width: width, height: self.view.frame.width * (GV.onIpad ? 0.040 : 0.020)))
        cell.setBGColor(color: UIColor.white)
        cell.setIndexPath(indexPath: indexPath)
        
        let cellNumber = String(indexPath.row + 1).fixLength(length: 5)
        cell.addColumn(text: " " + cellNumber.uppercased() + ":", color: actColor)
        let cellText = allWordsTable[choosedLength][indexPath.row]
        var minusAdded = false
        cell.addColumn(text: cellText.uppercased().fixLength(length: 20, leadingBlanks: false), color: actColor)
        if cellText.contains(strings: [GV.language.getText(.tcIWillDelete)]) {
            cell.addColumn(text: "   ", color: actColor)
        } else {
            if cellText.contains(strings: [GV.language.getText(.tcChoosedWord)]) {
                let origImage = UIImage(named: "Minus")!
                minusAdded = true
                let image = origImage.resizeImage(newWidth: origImage.size.height * 0.5)
                cell.addButton(image: image, callBack: didTapped1Button) //UIImage(named: "Minus.png"))
            } else if cellText.contains(strings: [GV.language.getText(.tcIWillAdd)]) {
                let origImage = UIImage(named: "Minus")!
                minusAdded = true
                let image = origImage.resizeImage(newWidth: origImage.size.height * 0.5)
                cell.addButton(image: image, callBack: didTapped1Button) //UIImage(named: "Minus.png"))
            } else {
                let origImage = UIImage(named: "Plus")!
                let image = origImage.resizeImage(newWidth: origImage.size.height * 0.5)
                cell.addButton(image: image, callBack: didTapped2Button)
            }
        }
        cell.addColumn(text: "  ", color: actColor)
        if !minusAdded {
            var origImage = UIImage(named: "Delete")!
            if cellText.contains(strings: [GV.language.getText(.tcIWillDelete)]) {
                origImage = UIImage(named: "UnDelete")!
            }
            let image = origImage.resizeImage(newWidth: origImage.size.height * 0.5)
            cell.addButton(image: image, callBack: didTapped3Button)        
        }
        return cell
    }
    
    func getHeightForRow(tableView: UITableView, indexPath: IndexPath) -> CGFloat {
        return headerLine.height(font: myFont!) * 3
    }
    
    func setHeaderView(tableView: UITableView, headerView: UIView, section: Int) {
    }
    
    func fillHeaderView(tableView: UITableView, section: Int) -> UIView {
        let counter = String(choosedLength)
        let headerLine = "   \(GV.language.getText(.tcCountLetters, values: counter))"
        let lineHeight = headerLine.height(font: myFont!)
//        if wordLengths.count > 0 {
//            title = " all: \(wordLengths[0]), 5: \(wordLengths[1]), 6: \(wordLengths[2]), 7: \(wordLengths[3]), 8: \(wordLengths[4]), 9: \(wordLengths[5]), 10: \(wordLengths[6])"
//        }
        let allWordsCount = String(allWordsTable[choosedLength].count)
        let mandatoryCount = String(mandatoryWordCountTable[choosedLength])
        let title = "   \(GV.language.getText(.tcAllWords, values: allWordsCount, mandatoryCount))"
        let width = title.width(withConstrainedHeight: 0, font: myFont!) * 2
        let view = UIView()
        let label1 = UILabel(frame: CGRect(x: 0, y: 0, width: width, height: lineHeight + 1.5))
        label1.font = myFont!
        label1.text = headerLine
        view.addSubview(label1)
        let label2 = UILabel(frame: CGRect(x: 0, y: lineHeight * 1.0, width: width, height: lineHeight * 1.5))
        label2.font = myFont!
        label2.text = title
        view.addSubview(label2)
        view.backgroundColor = UIColor(red:240/255, green: 240/255, blue: 240/255, alpha: 1.0)
        return view
    }
    
    func getHeightForHeaderInSection(tableView: UITableView, section: Int) -> CGFloat {
        return headerLine.height(font: myFont!) * 3
    }
    
    //    let realm: Realm
    var allWordsItems: Results<WordListModel>?
    
    var allWordsNotificationToken: NotificationToken?
    
    var allWordsSubscription: SyncSubscription<WordListModel>?
    
    var allWordsSubscriptionToken: NotificationToken?

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
        startIndicator()
        let myBackgroundImage = UIImageView (frame: UIScreen.main.bounds)
        myBackgroundImage.image = UIImage(named: "magier")
        myBackgroundImage.contentMode = UIView.ContentMode.scaleAspectFill
        self.view.insertSubview(myBackgroundImage, at: 0)
        tableviewAdded = false
//        updateCommonString()
//        getSavedMandatoryWords()
        showMandatoryWordsView!.setDelegate(delegate: self)
        showViewTable()
//        getStartingPhrase()
        buttonsCreated = false
        buttonRadius = self.view.frame.width / 25
        createButtons()
        fillAllWordsTable()
    }
//    var inputField: UITextField?
    private func startIndicator() {
        let actInd: UIActivityIndicatorView = UIActivityIndicatorView()
        actInd.frame = CGRect(x:0.0, y:0.0, width:40.0, height:40.0)
        actInd.center = self.view.center
        actInd.hidesWhenStopped = true
        actInd.style =
            UIActivityIndicatorView.Style.whiteLarge
        self.view.addSubview(actInd)
        actInd.startAnimating()

    }
    var tableviewAdded = false
    
//    @objc func inputFieldDidChange(_ textField: UITextField) {
//        fillAllWordsTable()
//    }
    var readMandatoryItems: Results<Mandatory>?
    var readMandatorySubscription: SyncSubscription<Mandatory>?

    
    private func updateCommonString() {
        readMandatoryItems = RealmService.objects(Mandatory.self).sorted(byKeyPath: "language")
//        mandatoryItems = RealmService.objects(Mandatory.self).sorted(byKeyPath: "language",ascending: true)
        readMandatorySubscription = readMandatoryItems!.subscribe(named: "mandatoryQuery3")
        mandatorySubscriptionToken = readMandatorySubscription!.observe(\.state) { [weak self]  state in
            switch state {
            case .creating:
                print("creating")
            // The subscription has not yet been written to the Realm
            case .pending:
                print("pending")
                // The subscription has been written to the Realm and is waiting
            // to be processed by the server
            case .complete:
                for mandatoryLine in self!.readMandatoryItems! {
                    let words = mandatoryLine.mandatoryWords.components(separatedBy: "°")
                    for word in words {
                        let commonString = CommonString()
                        commonString.word = mandatoryLine.language + word
                        if RealmService.objects(CommonString.self).filter("word = %@", mandatoryLine.language + word).count == 0 {
                            try! RealmService.write() {
                                RealmService.add(commonString)
                            }
                        }
                    }
                }
            
//                exit(0)
            default:
                print("state: \(state)")
            }
        }
    }

        
    
    @objc func stopShowingTable() {
        showMandatoryWordsView!.isHidden = true
        dismiss(animated: true, completion: {
            print("Dismissed")
        })
    }
    
    var enabled = true

    
    let bgColor = SKColor(red: 223/255, green: 255/255, blue: 216/255, alpha: 0.8)
    let playersTitle = "Player"
    let allTitle = "All"
    let bestTitle = "Best"
    let myTitleFont = UIFont(name: "TimesNewRomanPS-BoldMT", size: GV.onIpad ? 30 : 18)
    var sortUp = true
    var buttonsCreated = false
    var buttonTable = [UIButton]()
    var actButtonIndex = 1
    let buttonNames = ["", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12", "13", "14", "15"]
    let buttonXPositons = [15, 20, 25, 30, 35, 40, 45, 50, 55, 60, 65, 70, 75,80]

    private func createButtons() {
//        let buttonCenterDistanceX = (showMandatoryWordsView!.frame.size.width - 2 * buttonRadius) / 4
//        let buttonCenterDistanceY = (showMandatoryWordsView!.frame.size.height - 2 * buttonRadius) / 4
        let buttonFrameWidth = 2 * buttonRadius
        for index in 0..<buttonNames.count {
            let buttonFrame = CGRect(x: 0, y: 0, width:buttonFrameWidth, height: buttonFrameWidth)
            let yPos = showMandatoryWordsView!.frame.maxY + buttonRadius * (index % 2 == 0 ? 1.2 : 2.8)
            let xPos = showMandatoryWordsView!.frame.minX + buttonRadius * CGFloat(index + 1) * 1.5
            let center = CGPoint(x: xPos, y: yPos)
            var button: UIButton
            if index == 0 {
                button = createButton(imageName: "hook.png", imageSize: 0.05, title: "", frame: buttonFrame, center: center, enabled: enabled)
                button.addTarget(self, action: #selector(self.stopShowingTable), for: .touchUpInside)
            } else {
                let title = buttonNames[index]
                button = createButton(imageName: "", title: title, frame: buttonFrame, center: center, enabled: enabled)
                switch index + 2 {
                case 3: button.addTarget(self, action: #selector(no3ButtonTapped), for: .touchUpInside)
                case 4: button.addTarget(self, action: #selector(no4ButtonTapped), for: .touchUpInside)
                case 5: button.addTarget(self, action: #selector(no5ButtonTapped), for: .touchUpInside)
                case 6: button.addTarget(self, action: #selector(no6ButtonTapped), for: .touchUpInside)
                case 7: button.addTarget(self, action: #selector(no7ButtonTapped), for: .touchUpInside)
                case 8: button.addTarget(self, action: #selector(no8ButtonTapped), for: .touchUpInside)
                case 9: button.addTarget(self, action: #selector(no9ButtonTapped), for: .touchUpInside)
                case 10: button.addTarget(self, action: #selector(no10ButtonTapped), for: .touchUpInside)
                case 11: button.addTarget(self, action: #selector(no11ButtonTapped), for: .touchUpInside)
                case 12: button.addTarget(self, action: #selector(no12ButtonTapped), for: .touchUpInside)
                case 13: button.addTarget(self, action: #selector(no13ButtonTapped), for: .touchUpInside)
                case 14: button.addTarget(self, action: #selector(no14ButtonTapped), for: .touchUpInside)
                case 15: button.addTarget(self, action: #selector(no15ButtonTapped), for: .touchUpInside)
                default: continue
                }
            }
            self.view?.addSubview(button)
        }
        self.buttonsCreated = true
    }
    
    
    private func modifyButtonsPosition() {
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
            let image = UIImage(named: imageName)!.resizeImage(newWidth: view.frame.width * imageSize)
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
    
    var choosedLength = 0
    @objc func no3ButtonTapped() {
        choosedLength = 3
        showMandatoryWordsView!.reloadData()
    }
    @objc func no4ButtonTapped() {
        choosedLength = 4
        showMandatoryWordsView!.reloadData()
    }

    @objc func no5ButtonTapped() {
        choosedLength = 5
        showMandatoryWordsView!.reloadData()
    }
    
    @objc func no6ButtonTapped() {
        choosedLength = 6
        showMandatoryWordsView!.reloadData()
    }
    
    @objc func no7ButtonTapped() {
        choosedLength = 7
        showMandatoryWordsView!.reloadData()
    }
    
    @objc func no8ButtonTapped() {
        choosedLength = 8
        showMandatoryWordsView!.reloadData()
    }
    
    @objc func no9ButtonTapped() {
        choosedLength = 9
        showMandatoryWordsView!.reloadData()
    }
    
    @objc func no10ButtonTapped() {
        choosedLength = 10
        showMandatoryWordsView!.reloadData()
    }
    
    @objc func no11ButtonTapped() {
        choosedLength = 11
        showMandatoryWordsView!.reloadData()
    }
    
    @objc func no12ButtonTapped() {
        choosedLength = 12
        showMandatoryWordsView!.reloadData()
    }
    
    @objc func no13ButtonTapped() {
        choosedLength = 13
        showMandatoryWordsView!.reloadData()
    }
    
    @objc func no14ButtonTapped() {
        choosedLength = 14
        showMandatoryWordsView!.reloadData()
    }
    
    @objc func no15ButtonTapped() {
        choosedLength = 15
        showMandatoryWordsView!.reloadData()
    }
    
    @objc func bestButtonTapped() {
//        setNewTableView(tableType: .BestScoreForGame)
//        showBestScoreForGame()
    }
//
    @objc func sortButtonTapped() {
        //        showMandatoryWordsView?.removeFromSuperview()
        //        showMandatoryWordsView = nil
        //        sortUp = !sortUp
        //        setSortButtonImage()
        //        showSearchResults()
    }
    
//    func resizeImage(image: UIImage, newWidth: CGFloat) -> UIImage {
//
//        let scale = newWidth / image.size.width
//        let newHeight = image.size.height * scale
//        UIGraphicsBeginImageContext(CGSize(width: newWidth, height: newHeight))
//        image.draw(in: CGRect(x: 0, y: 0, width: newWidth, height: newHeight))
//        let newImage = UIGraphicsGetImageFromCurrentImageContext()
//        UIGraphicsEndImageContext()
//
//        return newImage!
//    }
    
    var searchPhrase: String = ""
    
    private func showViewTable() {
        if !tableviewAdded {
            let origin = CGPoint(x: 0, y: 0)
            let height = view.frame.height * (GV.onIpad ? 0.8 : 0.8)
            let width = view.frame.width * (GV.onIpad ? 0.8 : 0.9)
            let size = CGSize(width: width, height: height)
            let center = CGPoint(x: 0.5 * view.frame.width, y: 0.45 * view.frame.height)
            showMandatoryWordsView!.frame=CGRect(origin: origin, size: size)
            showMandatoryWordsView!.center=center
//            createButtons()
//            modifyButtonsPosition()

            showMandatoryWordsView!.register(CustomTableViewCell.self, forCellReuseIdentifier: "cell")
            view.addSubview(showMandatoryWordsView!)
            _ = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(checkTable(timerX: )), userInfo: nil, repeats: false)
//            let indexPath = IndexPath(row: GV.basicDataRecord.showingRow, section: 0)
//            showMandatoryWordsView!.scrollToRow(at: indexPath, at: .top, animated: true)
            tableviewAdded = true
        }
    }
    var lastHighestRow = 0

    @objc private func checkTable(timerX: Timer) {
        let indexPaths = showMandatoryWordsView!.indexPathsForVisibleRows
        if indexPaths!.count > 0 {
            let actHighestRow = indexPaths![0].row + 2
            if lastHighestRow != actHighestRow {
                lastHighestRow = actHighestRow
                try! realm.write() {
                    GV.basicDataRecord.showingRow = actHighestRow
                }
            }
        }
        _ = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(checkTable(timerX: )), userInfo: nil, repeats: false)
    }

    
    var searchLength = 0
    var showAll = true
    var modifiedItems: Results<ModifiedWordsModel>?
    var modifiedSubscription: SyncSubscription<ModifiedWordsModel>?
    var modifiedSubscriptionToken: NotificationToken?

    private func fillAllWordsTable() {
        let language = GV.actLanguage
        mandatoryWordCountTable = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
        allWordsTable = [[String](), [String](), [String](), [String](), [String](), [String](),
                         [String](), [String](), [String](), [String](), [String](), [String](),
                         [String](), [String](), [String](), [String](), [String]()]
        let allWordsItems = realmWordList.objects(WordListModel.self).filter("word beginsWith %@", language).sorted(byKeyPath: "word")
            let searchKey = "°" + GV.actLanguage + "°"
            modifiedItems = RealmService.objects(ModifiedWordsModel.self).filter("combinedKey CONTAINS %@", searchKey).sorted(byKeyPath: "word", ascending: true)
            modifiedSubscription = modifiedItems!.subscribe(named: "\(GV.actLanguage)ModifiedWordsQueryNew")
            modifiedSubscriptionToken = modifiedSubscription!.observe(\.state) { [weak self]  state in
                switch state {
                case .creating:
                    print("creating")
                // The subscription has not yet been written to the Realm
                case .pending:
                    print("pending")
                    // The subscription has been written to the Realm and is waiting
                // to be processed by the server
                case .complete:
                    let name = playerActivity![0].name
                    for item in allWordsItems {
                        let word = item.word.endingSubString(at: 2)
                        let length = word.length
                        if length > 2 && length < 16 {
                            var suffix = ""
                            if realmMandatoryList.objects(MandatoryListModel.self).filter("word = %@", word).count > 0 {
                                suffix = GV.language.getText(.tcChoosedWord)
                                self!.mandatoryWordCountTable[length] += 1
                            }
                            if self!.modifiedItems!.filter("combinedKey BEGINSWITH %@ and language = %@ and word = %@",
                                                           name, GV.actLanguage, word).count > 0 {
                                let modifiedItem = self!.modifiedItems!.filter("combinedKey BEGINSWITH %@ and language = %@ and word = %@",
                                                                               name, GV.actLanguage, word)[0]
                                let willDo:WillDo = WillDo(rawValue: modifiedItem.willDo)!
                                switch willDo {
                                case WillDo.Substract: suffix = ""
                                case WillDo.Add: suffix = GV.language.getText(.tcIWillAdd)
                                case WillDo.Delete: suffix = GV.language.getText(.tcIWillDelete)
                                default: break
                                }
                            }
                        
                            self!.allWordsTable[length].append(word + suffix)
                        }
                    }

                default:
                    print("state: \(state)")
                }
            }
 
    
//        for item in allWordsItems {
//            let word = item.word.endingSubString(at: 2)
//            let length = word.length
//            if length > 2 && length < 16 {
//                var suffix = ""
//                if realmMandatoryList.objects(MandatoryListModel.self).filter("word = %@", word).count > 0 {
//                    suffix = GV.language.getText(.tcChoosedWord)
//                    mandatoryWordCountTable[length] += 1
//                }
//                if modifiedItems!.contains(where: {$0.word == word}) {
//                    print("hier tu was")
//                }
//                allWordsTable[length].append(word + suffix)
//            }
//        showMandatoryWordsView!.reloadData()
        
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
    
//    private func readTextFile() {
//        let language = GV.actLanguage
//        let wordFileURL = Bundle.main.path(forResource: "\(language)Mandatory", ofType: "txt")
//        // Read from the file Words
//        var wordsFile = ""
//        do {
//            wordsFile = try String(contentsOfFile: wordFileURL!, encoding: String.Encoding.utf8)
//        } catch let error as NSError {
//            print("Failed reading from URL: \(String(describing: wordFileURL)), Error: " + error.localizedDescription)
//        }
//        let wordList = wordsFile.components(separatedBy: .newlines)
//        let finished = "-----"
//        if wordList.last! == finished || wordList[wordList.count - 2] == finished {
//            print("done")
//        } else {
//            for word1 in wordList {
//                let word = word1.lowercased()
//                if word.length < 5 {
////                    print("word is too short: \(word)")
//                } else if word.length > 10 {
////                    print("word is too long: \(word)")
//                } else if realmWordList.objects(WordListModel.self).filter("word = %@", language + word).count == 1 {
//                    let wordModel = CommonString()
//                    wordModel.word = language + word
//                    if !savedMandatoryWords.contains(where: {$0 == word}) {
//                        try! RealmService.write() {
//                            print("new word founded: \(word)")
//                            RealmService.add(wordModel)
//                            savedMandatoryWords.append(word)
//                        }
//                    } else {
////                        print("word is in RealmCloud: \(word)")
//                    }
//                } else {
////                    print("word not exists: \(word)")
//                }
//            }
//        }
//    }
    
    var mandatoryItems: Results<CommonString>?
    var mandatorySubscription: SyncSubscription<CommonString>?
    var mandatorySubscriptionToken: NotificationToken?
    var wordLengths = [0,0,0,0,0,0,0,0,0,0,0]
    
    private func getSavedMandatoryWords() {
        mandatoryItems = RealmService.objects(CommonString.self).filter("word BEGINSWITH %@", GV.actLanguage).sorted(byKeyPath: "word", ascending: true)
        mandatorySubscription = mandatoryItems!.subscribe(named: "\(GV.actLanguage)mandatoryQuery")
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
                        if word == "" {
                            try! RealmService.write() {
                                RealmService.delete(item)
                            }
                        } else {
                            self!.savedMandatoryWords.append(word)
                            self!.wordLengths[word.length - 4] += 1
                            self!.wordLengths[0] += 1
//                            print("\(word)")
                        }
                    }
                }
//                print("wordLengths: \(self!.wordLengths)")
//                self!.readTextFile()
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
