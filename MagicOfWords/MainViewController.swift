//
//  GameViewController.swift
//  Szómágia
//
//  Created by Jozsef Romhanyi on 29/01/2018.
//  Copyright © 2018 Jozsef Romhanyi. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit
import RealmSwift
import Reachability
import Security


class MainViewController: UIViewController, /*MenuSceneDelegate,*/ WTSceneDelegate, ShowGamesSceneDelegate /*SettingsSceneDelegate*/ {
    
    func chooseNickname() {
        let alertController = UIAlertController(title: GV.language.getText(.tcSetNickName),
                                                message: GV.language.getText(.tcAddCodeRecommended),
                                                preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: GV.language.getText(.tcSave), style: .default, handler: { [unowned self]
            alert -> Void in
            let nickNameField = alertController.textFields![0] as UITextField
            let keyWordField = alertController.textFields![1] as UITextField
            self.setNickname(nickName: nickNameField.text!, keyWord: keyWordField.text!)
//            self.showMenu()
        }))
        alertController.addAction(UIAlertAction(title: GV.language.getText(.tcCancel), style: .cancel, handler: { [unowned self]
            alert -> Void in
            self.showMenu()
        }))
        alertController.addTextField(configurationHandler: {(textField : UITextField!) -> Void in
            textField.text = playerActivity![0].nickName
        })
        alertController.addTextField(configurationHandler: {(textField : UITextField!) -> Void in
            if GV.basicDataRecord.keyWord == "" {
                textField.placeholder = GV.language.getText(.tcKeyWord)
            } else {
                textField.text = GV.basicDataRecord.keyWord
            }
        })
        self.present(alertController, animated: true, completion: nil)
        
    }
    #if DEBUG
    func displayCloudRecordsViewController() {
        if GV.myUser != nil
        {
            let cloudRecordsViewController = CloudRecordsViewController()
            self.present(cloudRecordsViewController, animated: true, completion: nil)
        }
    }
    
    func displayCreateMandatoryViewController() {
        if GV.myUser != nil {
            let createMandatoryViewController = CreateMandatoryWordsViewController()
            self.present(createMandatoryViewController, animated: true, completion: nil)
        }
    }
    #endif
    
    func displayCollectMandatoryViewController() {
        if GV.myUser != nil && GV.expertUser {
            let collectMandatoryViewController = CollectMandatoryWordsViewController()
            self.present(collectMandatoryViewController, animated: true, completion: nil)
        }
    }
    
    var showGamesScene: ShowGamesScene?
    func backFromSettingsScene() {
        try! realm.write() {
            GV.basicDataRecord.actLanguage = GV.actLanguage
        }
        showMenu()
//        startMenuScene()
    }
    
    func backToMenuScene(gameNumberSelected: Bool = false, gameNumber: Int = 0, restart: Bool) {
        if showGamesScene != nil {
            showGamesScene!.removeFromParent()
            showGamesScene = nil
        }
        if gameNumberSelected {
            startWTScene(new: false, next: .GameNumber, gameNumber: gameNumber, restart: restart)
        } else {
            showMenu()
        }
//        startMenuScene()
    }
    
    func showGames(all: Bool) {
        showGamesScene = ShowGamesScene(size: CGSize(width: view.frame.width, height: view.frame.height))
        showGamesScene!.setDelegate(delegate: self, controller: self)
//        showGamesScene!.setSelect(all: all)
        if let view = self.view as! SKView? {
            view.presentScene(showGamesScene!)
        }
    }
    
    func gameFinished(start: StartType) {
        if let view = self.view as! SKView? {
            view.presentScene(nil)
        }
        showBackgroundPicture()
        switch start {
        case .NoMore: showMenu() //startMenuScene(showMenu: true)
        case .PreviousGame, .NextGame: startWTScene(new: false, next: start, gameNumber: 0)
        case .NewGame: startWTScene(new: true, next: .NoMore, gameNumber: 0)
        case .GameNumber: startWTScene(new: true, next: .NoMore, gameNumber: 0)
        }
    }
    
    func wtGame() {
        startWTScene(new: true, next: .NoMore, gameNumber: 0)
    }
    
    func findWords() {
        print("Search Words choosed")
    }
    
    func cancelChooeseGameType() {
        print("cancel choosed")
        showMenu()
//        startMenuScene()
    }
    
    func xxx() {
        return
    }
    
    func startWTScene(new: Bool, next: StartType, gameNumber: Int, restart: Bool = false) {
        let wtScene = WTScene(size: CGSize(width: view.frame.width, height: view.frame.height))
        if let view = self.view as! SKView? {
            wtScene.setDelegate(delegate: self)
            wtScene.setGameArt(new: new, next: next, gameNumber: gameNumber, restart: restart)
            wtScene.parentViewController = self
            view.presentScene(wtScene)
        }
        
    }
    
    func startFindWordsScene() {
        //        let findWordsScene = WTScene(size: CGSize(width: view.frame.width, height: view.frame.height))
        //        if let view = self.view as! SKView? {
        //            wtScene.setDelegate(delegate: self)
        //            view.presentScene(wtScene)
        //        }
        
    }
    
    func startNewGame() {
        startWTScene(new: true, next: .NoMore, gameNumber: 0)
    }
    
    func continueGame() {
        startWTScene(new: false, next: .NoMore, gameNumber: 0)
    }
    
    func chooseLanguage() {
        func setLanguage(language: String) {
            GV.language.setLanguage(language)
            try! realm.write() {
                GV.basicDataRecord.actLanguage = language
            }
             self.showMenu()
        }
        let alertController = UIAlertController(title: GV.language.getText(.tcChooseLanguage),
                                                message: "",
                                                preferredStyle: .alert)
        let englishAction = UIAlertAction(title: GV.language.getText(.tcEnglish), style: .default, handler: {
            alert -> Void in
            setLanguage(language: GV.language.getText(.tcEnglishShort))
            })
        if GV.language.getText(.tcEnglishShort) == GV.actLanguage {
            englishAction.setValue(UIColor.red, forKey: "TitleTextColor")
        }
        alertController.addAction(englishAction)
        
        let germanAction = UIAlertAction(title: GV.language.getText(.tcGerman), style: .default, handler: {
            alert -> Void in
            setLanguage(language: GV.language.getText(.tcGermanShort))
        })
        if GV.language.getText(.tcGermanShort) == GV.actLanguage {
            germanAction.setValue(UIColor.red, forKey: "TitleTextColor")
        }
        alertController.addAction(germanAction)
        
        let hungarianAction = UIAlertAction(title: GV.language.getText(.tcHungarian), style: .default, handler: {
            alert -> Void in
            setLanguage(language: GV.language.getText(.tcHungarianShort))
        })
        if GV.language.getText(.tcHungarianShort) == GV.actLanguage {
            hungarianAction.setValue(UIColor.red, forKey: "TitleTextColor")
        }
        alertController.addAction(hungarianAction)
        
        let russianAction = UIAlertAction(title: GV.language.getText(.tcRussian), style: .default, handler: {
            alert -> Void in
            setLanguage(language: GV.language.getText(.tcRussianShort))
        })
        if GV.language.getText(.tcRussianShort) == GV.actLanguage {
            russianAction.setValue(UIColor.red, forKey: "TitleTextColor")
        }
        alertController.addAction(russianAction)
        let subview = (alertController.view.subviews.first?.subviews.first?.subviews.first!)! as UIView
        subview.layer.cornerRadius = 15
        subview.backgroundColor = UIColor(red: (255/255.0), green: (224/255.0), blue: (224/255.0), alpha: 1.0)

        present(alertController, animated: true, completion: nil)
//        GV.language.setLanguage(GV.language.getText(.tcEnglishShort))
        //                    case String(TextConstants.tcGerman.rawValue):
        //                        GV.language.setLanguage(GV.language.getText(.tcGermanShort))
        //
        //                    case String(TextConstants.tcHungarian.rawValue):
        //                        GV.language.setLanguage(GV.language.getText(.tcHungarianShort))
        //
        //                    case String(TextConstants.tcRussian.rawValue):
        //                        GV.language.setLanguage(GV.language.getText(.tcRussianShort))
        //
        //                   case String(TextConstants.tcCancel.rawValue):
        //                        settingsSceneDelegate!.backFromSettingsScene()
        //
    }
    
//    override func viewDidLoad() {
    var countMandatory = 0
    var countExistingGames = 0
    var countContinueGames = 0
    
    private func getRecordCounts() {
        countMandatory = realmMandatory.objects(MandatoryModel.self).filter("language = %@", GV.actLanguage).count
        countExistingGames = realm.objects(GameDataModel.self).filter("language = %@", GV.actLanguage).count
        countContinueGames = realm.objects(GameDataModel.self).filter("language = %@ and (gameStatus = %@ or gameStatus = %@)", GV.actLanguage, GV.GameStatusPlaying, GV.GameStatusContinued).count
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidLoad()
        #if DEBUG
            GV.debug = true
        #endif
        showBackgroundPicture()
//        printDEWordsSorted()
        print("\(String(describing: Realm.Configuration.defaultConfiguration.fileURL))")
//       readNewTextFile()
//        printOrigDEData()
        myHeight = self.view.frame.size.height
        myWidth = self.view.frame.size.width
        #if CREATEMANDATORY
        _ = WordDBGenerator(mandatory: true, create: true)
        #endif

        #if CREATEWORDLIST
        _ = WordDBGenerator(mandatory: false, create: true)
        #endif
        
       #if GENERATEWORDLIST
        _ = WordDBGenerator(mandatory: false)
        print("WordList Generated")
        #endif
        #if GENERATEMANDATORY
        _ = WordDBGenerator(mandatory: true)
        print("Mandatory Generated")
        #endif
//        readNewTextFile()
        // Get the SKScene from the loaded GKScene
        //-------------------------
        generateBasicDataRecordIfNeeded()
       if countContinueGames > 0 {
            startWTScene(new: false, next: .NoMore, gameNumber: 0)
        } else {
            showMenu()
        }
        //------------------------
//        startMenuScene()
    }
    
    
    private func showBackgroundPicture() {
        let backgroundImage = UIImageView(frame: UIScreen.main.bounds)
        backgroundImage.image = UIImage(named: "magier.png")
        backgroundImage.contentMode = UIView.ContentMode.scaleAspectFill
        self.view.insertSubview(backgroundImage, at: 0)
    }
    let callerName = "MainViewController"
    ////
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(reachabilityChanged(note:)), name: .reachabilityChanged, object: reachability)
        do {
            try reachability.startNotifier()
        }catch{
            print("could not start reachability notifier")
        }
        if !GV.callBackExpertUser.contains(where: {$0.myCaller == callerName}) {
            GV.callBackExpertUser.append(GV.CallBackStruct(caller: callerName, callBackFunction: expertUserChanged))
        }
        expertUserChanged()
    }
    
    public func expertUserChanged() {
        if GV.expertUser {
            let title = GV.language.getText(.tcCollectMandatory)
            if alertController!.actions.last!.title != title {
                collectMandatoryAction = UIAlertAction(title: title, style: .default, handler: { [unowned self]
                    alert -> Void in
                    self.displayCollectMandatoryViewController()
                })
                collectMandatoryAction!.isEnabled = GV.connectedToInternet && playerActivity != nil
                alertController!.addAction(collectMandatoryAction!)
            }
        } 
    }
    
    
    
    
    @objc func reachabilityChanged(note: Notification) {
        
        let reachability = note.object as! Reachability
        
        switch reachability.connection {
        case .wifi:
            GV.connectedToInternet = true
            if nickNameAction != nil {
                nickNameAction!.isEnabled = true
            }
            if GV.expertUser {
                collectMandatoryAction!.isEnabled = true
            }
            #if DEBUG
            if showRealmCloudAction != nil {
                showRealmCloudAction!.isEnabled = true
//                createMandatoryAction!.isEnabled = true
            }
           #endif
        case .cellular:
            GV.connectedToInternet = true
            if nickNameAction != nil {
                nickNameAction!.isEnabled = true
            }
            if GV.expertUser {
                collectMandatoryAction!.isEnabled = true
            }
            #if DEBUG
            if showRealmCloudAction != nil {
                showRealmCloudAction!.isEnabled = true
//                createMandatoryAction!.isEnabled = true
            }
            #endif
        case .none:
            GV.connectedToInternet = false
            if nickNameAction != nil {
                nickNameAction!.isEnabled = false
            }
            if GV.expertUser {
                collectMandatoryAction!.isEnabled = false
            }

            #if DEBUG
            if showRealmCloudAction != nil {
                showRealmCloudAction!.isEnabled = false
//                createMandatoryAction!.isEnabled = false
            }
            #endif
        }
    }

    var alertController: UIAlertController?
    var nickNameAction: UIAlertAction?
    var collectMandatoryAction: UIAlertAction?

    #if DEBUG
    var showRealmCloudAction: UIAlertAction?
    var createMandatoryAction: UIAlertAction?
    #endif
    

    func showMenu() {
        getRecordCounts()
        let disabledColor = UIColor(red:204/255, green: 229/255, blue: 255/255,alpha: 1.0)
        alertController = UIAlertController(title: GV.language.getText(.tcChooseAction),
                                                message: GV.language.getText(.tcMyNickName, values: GV.basicDataRecord.myNickname),
                                                preferredStyle: .alert)

        let newOK = countMandatory - countExistingGames > 0
        let continueOK = countContinueGames > 0
        //--------------------- newGameAction ---------------------
        let newGameAction = UIAlertAction(title: "\(GV.language.getText(.tcNewGame)) ", style: .default, handler: { [unowned self]
            alert -> Void in
            if newOK {
                self.startNewGame()
            }
        })
        if !newOK {
            newGameAction.setValue(disabledColor, forKey: "TitleTextColor")
        }
        alertController!.addAction(newGameAction)
        //--------------------- continueAction ---------------------
        let continueAction = UIAlertAction(title: "\(GV.language.getText(.tcContinue))", style: .default, handler: { [unowned self]
            alert -> Void in
            if continueOK {
//                self.showGames(all: false)
                self.startWTScene(new: false, next: .NoMore, gameNumber: 0)
            }
        })
        if !continueOK {
            continueAction.isEnabled = false
//            continueAction.setValue(disabledColor, forKey: "TitleTextColor")
        }
        alertController!.addAction(continueAction)
        //--------------------- bestScoreAction ---------------------
        let bestScoreAction = UIAlertAction(title: GV.language.getText(.tcBestScore), style: .default, handler: { [unowned self]
            alert -> Void in
            self.showGames(all: true)
        })
        alertController!.addAction(bestScoreAction)
        //--------------------- chooseLanguageAction ---------------------
        let chooseLanguageAction = UIAlertAction(title: GV.language.getText(.tcChooseLanguage), style: .default, handler: { [unowned self]
            alert -> Void in
            self.chooseLanguage()
        })
        alertController!.addAction(chooseLanguageAction)
        //--------------------- nickNameAction ---------------------
        
        nickNameAction = UIAlertAction(title: GV.language.getText(.tcSetNickName), style: .default, handler: { [unowned self]
            alert -> Void in
            if GV.connectedToInternet && playerActivity != nil {
                self.chooseNickname()
            } else {
                self.showMenu()
            }
        })
        nickNameAction!.isEnabled = GV.connectedToInternet && playerActivity != nil
        alertController!.addAction(nickNameAction!)
        expertUserChanged()
        #if DEBUG
        //--------------------- showRealmCloudAction ---------------------
            showRealmCloudAction = UIAlertAction(title: GV.language.getText(.tcShowRealmCloud), style: .default, handler: { [unowned self]
                alert -> Void in
                self.displayCloudRecordsViewController()
            })
            showRealmCloudAction!.isEnabled = GV.connectedToInternet && playerActivity != nil
            alertController!.addAction(showRealmCloudAction!)
//            collectMandatoryAction = UIAlertAction(title: GV.language.getText(.tcCollectMandatory), style: .default, handler: { [unowned self]
//                alert -> Void in
//                self.displayCollectMandatoryViewController()
//            })
//            collectMandatoryAction!.isEnabled = GV.connectedToInternet && playerActivity != nil
//            alertController!.addAction(collectMandatoryAction!)

//            createMandatoryAction = UIAlertAction(title: GV.language.getText(.tcCreateMandatory), style: .default, handler: { [unowned self]
//            alert -> Void in
//                self.displayCreateMandatoryViewController()
//            })
//            createMandatoryAction!.isEnabled = GV.connectedToInternet && playerActivity != nil
//            alertController!.addAction(createMandatoryAction!)

        #endif
        //--------------------- Present alert ---------------------
        present(alertController!, animated: true, completion: nil)

    }
    
    private func generateBasicDataRecordIfNeeded() {
        if realm.objects(BasicDataModel.self).count == 0 {
            let myName = generateRandomNameFromDeviceID()
            GV.basicDataRecord = BasicDataModel()
            GV.basicDataRecord.actLanguage = GV.language.getText(.tcAktLanguage)
            GV.basicDataRecord.myName = myName
            GV.basicDataRecord.myNickname = generateMyNickname()
            GV.basicDataRecord.creationTime = Date()
            try! realm.write() {
                realm.add(GV.basicDataRecord)
            }
        } else {
            GV.basicDataRecord = realm.objects(BasicDataModel.self).first!
            GV.language.setLanguage(GV.basicDataRecord.actLanguage)
        }
    }
    
    
    private func generateRandomNameFromDeviceID()->String {
        let deviceName = UIDevice().deviceID
        let random = MyRandom(forName: true)
        var modifiedID = ""
        for char in deviceName {
            if String(char) != "-" {
                modifiedID += String(char)
            }
        }
        var index = 0
        var randomizedID = ""
        var counter = 0
        repeat {
            let input = modifiedID.subString(at: index, length: 2)
            let scanner = Scanner(string: input)
            var value: UInt64 = 0
            
            if scanner.scanHexInt64(&value) {
                let adder = random.getRandomInt(1, max: 255)
                let newValue = (Int(value) + adder) % 256
                randomizedID += String(format:"%02X", newValue)
                counter += 1
                if counter % 2 == 0 {
                    randomizedID += "-"
                }
           }
           index += 2
        } while index < modifiedID.length
        
        
        randomizedID.removeLast()
        return randomizedID
    }
    
    func generateMyNickname()->String {
        var nickName = GV.onSimulator ? "Sim" : (GV.onIpad ? "Pd" : "Ph")
        let letters = GV.language.getText(.tcNickNameLetters)
        for _ in 0...4 {
            nickName += letters.subString(at: Int.random(min: 0, max: letters.count - 1), length: 1)
        }
        for _ in 0...4 {
            nickName += String(Int.random(min: 0, max: 9))
        }
        return nickName
    }
    
    var playerActivityByNickName: Results<PlayerActivity>?
    var playerActivityByNickNameSubscription: SyncSubscription<PlayerActivity>?
    var playerActivityByNickNameToken: NotificationToken?
    
    func setNickname(nickName: String, keyWord: String) {
        if playerActivity!.count == 0 {
            return
        }
        if GV.myUser != nil {
            playerActivity = realmSync!.objects(PlayerActivity.self).filter("name = %@", GV.basicDataRecord.myName)
            playerActivityByNickName = realmSync?.objects(PlayerActivity.self).filter("nickName = %@ and name != %@", nickName, GV.basicDataRecord.myName)
            playerActivityByNickNameSubscription = playerActivityByNickName!.subscribe(named: "PlayerActivityByNickName:\(nickName)")
            playerActivityByNickNameToken = playerActivityByNickNameSubscription!.observe(\.state) { [weak self]  state in
                if state == .complete {
                    if self!.playerActivityByNickName!.count == 0 {
                        try! realmSync?.write() {
                            playerActivity![0].nickName = nickName
                            playerActivity![0].keyWord = keyWord
                        }
                        try! realm.write() {
                            GV.basicDataRecord.myNickname = nickName
                            GV.basicDataRecord.keyWord = keyWord
                        }
                        self!.showMenu()
                    } else {
                        if self!.playerActivityByNickName![0].keyWord == nil || self!.playerActivityByNickName![0].keyWord == "" {
                            let alertController = UIAlertController(title: GV.language.getText(.tcNicknameUsedwithout, values: nickName),
                                                                    message: GV.language.getText(.tcNicknameActivating),
                                                                    preferredStyle: .alert)
                            alertController.addAction(UIAlertAction(title: GV.language.getText(.tcOK), style: .default, handler: {alert -> Void in
                                self!.showMenu()
                                //            self.showMenu()
                            }))
//                            alertController.addAction(UIAlertAction(title: GV.language.getText(.tcCancel), style: .default, handler: nil))
                            self!.present(alertController, animated: true, completion: nil)
                        } else {
                            if self!.playerActivityByNickName![0].keyWord == keyWord {
                                try! realmSync?.write() {
                                    playerActivity![0].nickName = nickName
                                    playerActivity![0].keyWord = keyWord
                                }
                                try! realm.write() {
                                    GV.basicDataRecord.myNickname = nickName
                                    GV.basicDataRecord.keyWord = keyWord
                                }
                                self!.showMenu()
                            } else {
                                let alertController = UIAlertController(title: GV.language.getText(.tcNicknameUsed, values: nickName),
                                                                        message: GV.language.getText(.tcAddKeyWord),
                                                                        preferredStyle: .alert)
                                alertController.addAction(UIAlertAction(title: GV.language.getText(.tcOK), style: .default, handler: {
                                    alert -> Void in
                                    self!.showMenu()
                                    //            self.showMenu()
                                }))
//                                alertController.addAction(UIAlertAction(title: GV.language.getText(.tcCancel), style: .default, handler: nil))
                                self!.present(alertController, animated: true, completion: nil)
                            }
                        }
                    }
                    self!.playerActivityByNickNameSubscription!.unsubscribe()
                    self!.playerActivityByNickNameToken!.invalidate()
                } else {
                    print("state: \(state)")
                }
            }
        } else {
            
        }
     }
    
    func printFonts() {
        let fontFamilyNames = UIFont.familyNames
        for familyName in fontFamilyNames {
            print("------------------------------")
            print("Font Family Name = [\(familyName)]")
            let names = UIFont.fontNames(forFamilyName: familyName)
            print("Font Names = [\(names)]")
        }
    }
    
    private func readNewTextFile() {
        let wordFileURL = Bundle.main.path(forResource: "deutschWords", ofType: "txt")
//        let outFileUrl = Bundle.main.path(forResource: "deutschWordsOut", ofType: "txt")
        let fileName = "deutschWordsOut.txt"
        let url = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(fileName)

//        if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
//
//            let fileURL = dir.appendingPathComponent(file)
//
            //writing
        
            //reading
            var wordsFile = ""
            do {
                wordsFile = try String(contentsOfFile: wordFileURL!, encoding: String.Encoding.macOSRoman)
            } catch let error as NSError {
                print("Failed reading from URL: \(String(describing: wordFileURL)), Error: " + error.localizedDescription)
            }
            let wordList = wordsFile.components(separatedBy: .newlines)
            var text = ""
            for word in wordList {
                if word.subString(at: 0, length: 1) != "#" {
                    let firstCharUpper = word.subString(at: 0, length: 1).uppercased()
                    if word.subString(at: 0, length: 1) == firstCharUpper {
                        if let idx = word.index(of: " ") {
                            let newWord = word[..<idx] + "\r\n"
                            text += newWord
                       }
                    }
                }
             }
        let data = Data(text.utf8)
        do {
            try data.write(to: url, options: .atomic)
        } catch {
            print(error)
        }

    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    func printDEWordsSorted() {
        let deWords = realmWordList.objects(WordListModel.self).filter("word BEGINSWITH de").sorted(byKeyPath: "word", ascending: true)
        for deWord in deWords {
            print(deWord.word.subString(at: 2, length: deWord.word.length - 2))
        }
    }
    func printOrigDEData() {
        let dataFileURL = Bundle.main.path(forResource: "deutschWords", ofType: "txt")
        var gameDataFile = ""
        do {
            gameDataFile = try String(contentsOfFile: dataFileURL!, encoding: String.Encoding.utf8)
        } catch let error as NSError {
            print("Failed reading from URL: \(String(describing: dataFileURL)), Error: " + error.localizedDescription)
        }
        let myLines = gameDataFile.components(separatedBy: .newlines)
        for line in myLines {
            if !line.begins(with: "#") {
                if line.subString(at: 0, length: 1).uppercased() == line.subString(at: 0, length: 1) {
                    print(line)
                }
            }
        }
        
    }
    func checkMandatoryWords() {
        for language in ["en", "de","hu","ru"] {
            let mandatoryRecords = realmMandatory.objects(MandatoryModel.self).filter("language = %@",language)
            for mandatoryRecord in mandatoryRecords {
                let words = mandatoryRecord.mandatoryWords.components(separatedBy: "°")
                if words.count != 8 {
                    print("words count NOK: \(words) ================================")
                }
                for word in words {
                    if word.length < 5 {
                        print("word too short: \(word) -----------------------------")
                    } else if word.length > 12 {
                        print("word too long: \(word) -----------------------------")
                    }
                    let toSearch = "\(language)\(word.lowercased())"
                    if realmWordList.objects(WordListModel.self).filter("word = %@", toSearch).count == 0 {
                        print("\(word) --> not found in Database!")
                    }
                    
                }
            }
        }
    }

}
