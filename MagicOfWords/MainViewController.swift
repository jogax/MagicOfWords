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
            self.showMenu()
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
    
    func displayCloudRecordsViewController() {
        if GV.myUser != nil
        {
            let cloudRecordsViewController = CloudRecordsViewController()
            self.present(cloudRecordsViewController, animated: true, completion: nil)
        }
    }
    
    var showGamesScene: ShowGamesScene?
    func backFromSettingsScene() {
        try! realm.write {
            GV.basicDataRecord.actLanguage = GV.aktLanguage
        }
        showMenu()
//        startMenuScene()
    }
    
    func backToMenuScene(gameNumberSelected: Bool = false, gameNumber: Int = 0) {
        if showGamesScene != nil {
            showGamesScene!.removeFromParent()
            showGamesScene = nil
        }
        if gameNumberSelected {
            startWTScene(new: false, next: .GameNumber, gameNumber: gameNumber)
        } else {
            showMenu()
        }
//        startMenuScene()
    }
    
    func showGames(all: Bool) {
        showGamesScene = ShowGamesScene(size: CGSize(width: view.frame.width, height: view.frame.height))
        showGamesScene!.setDelegate(delegate: self)
        showGamesScene!.setSelect(all: all)
        if let view = self.view as! SKView? {
            view.presentScene(showGamesScene!)
        }
    }
    
    func gameFinished(start: StartType) {
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
    
    func startWTScene(new: Bool, next: StartType, gameNumber: Int) {
        let wtScene = WTScene(size: CGSize(width: view.frame.width, height: view.frame.height))
        if let view = self.view as! SKView? {
            wtScene.setDelegate(delegate: self)
            wtScene.setGameArt(new: new, next: next, gameNumber: gameNumber)
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
//        let settingsScene = SettingsScene(size: CGSize(width: view.frame.width, height: view.frame.height))
//        if let view = self.view as! SKView? {
//            settingsScene.setDelegate(delegate: self)
//            view.presentScene(settingsScene)
//        } else {
//            continueGame()
//        }
        //        createMenuItem(menuInt: .tcEnglish, firstLine: true, isActLanguage: GV.language.getText(.tcEnglishShort) == GV.aktLanguage)
        //        createMenuItem(menuInt: .tcGerman, isActLanguage: GV.language.getText(.tcGermanShort) == GV.aktLanguage)
        //        createMenuItem(menuInt: .tcHungarian, isActLanguage: GV.language.getText(.tcHungarianShort) == GV.aktLanguage)
        //        createMenuItem(menuInt: .tcRussian, isActLanguage: GV.language.getText(.tcRussianShort) == GV.aktLanguage)
        let alertController = UIAlertController(title: GV.language.getText(.tcChooseLanguage),
                                                message: "",
                                                preferredStyle: .alert)
        let englishAction = UIAlertAction(title: GV.language.getText(.tcEnglish), style: .default, handler: {
            alert -> Void in
                GV.language.setLanguage(GV.language.getText(.tcEnglishShort))
                self.showMenu()
            })
        if GV.language.getText(.tcEnglishShort) == GV.aktLanguage {
            englishAction.setValue(UIColor.red, forKey: "TitleTextColor")
        }
        alertController.addAction(englishAction)
        
        let germanAction = UIAlertAction(title: GV.language.getText(.tcGerman), style: .default, handler: {
            alert -> Void in
            GV.language.setLanguage(GV.language.getText(.tcGermanShort))
            self.showMenu()
        })
        if GV.language.getText(.tcGermanShort) == GV.aktLanguage {
            germanAction.setValue(UIColor.red, forKey: "TitleTextColor")
        }
        alertController.addAction(germanAction)
        
        let hungarianAction = UIAlertAction(title: GV.language.getText(.tcHungarian), style: .default, handler: {
            alert -> Void in
            GV.language.setLanguage(GV.language.getText(.tcHungarianShort))
            self.showMenu()
        })
        if GV.language.getText(.tcHungarianShort) == GV.aktLanguage {
            hungarianAction.setValue(UIColor.red, forKey: "TitleTextColor")
        }
        alertController.addAction(hungarianAction)
        
        let russianAction = UIAlertAction(title: GV.language.getText(.tcRussian), style: .default, handler: {
            alert -> Void in
            GV.language.setLanguage(GV.language.getText(.tcRussianShort))
            self.showMenu()
        })
        if GV.language.getText(.tcRussianShort) == GV.aktLanguage {
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
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidLoad()
        myHeight = self.view.frame.size.height
        myWidth = self.view.frame.size.width
        print("\(String(describing: Realm.Configuration.defaultConfiguration.fileURL))")
        #if GENERATEWORDLIST
        _ = WordDBGenerator(mandatory: false)
        print("WordList Generated")
        #endif
        #if GENERATEMANDATORY
        _ = WordDBGenerator(mandatory: true)
        print("Mandatory Generated")
        #endif
        // Get the SKScene from the loaded GKScene
        generateBasicDataRecordIfNeeded()
        showMenu()
//        startMenuScene()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(reachabilityChanged(note:)), name: .reachabilityChanged, object: reachability)
        do{
            try reachability.startNotifier()
        }catch{
            print("could not start reachability notifier")
        }
    }
    
    
    
    
    @objc func reachabilityChanged(note: Notification) {
        
        let reachability = note.object as! Reachability
        
        switch reachability.connection {
        case .wifi:
            GV.connectedToInternet = true
        case .cellular:
            GV.connectedToInternet = true
        case .none:
            GV.connectedToInternet = false
        }
    }
    
    func showMenu() {
        let disabledColor = UIColor(red:204/255, green: 229/255, blue: 255/255,alpha: 1.0)
        let alertController = UIAlertController(title: GV.language.getText(.tcChooseAction),
                                                message: "",
                                                preferredStyle: .alert)
        let countMandatory = realmMandatory.objects(MandatoryModel.self).filter("language = %@", GV.aktLanguage).count
        let countExistingGames = realm.objects(GameDataModel.self).filter("language = %@", GV.aktLanguage).count
        let countContinueGames = realm.objects(GameDataModel.self).filter("language = %@ and gameStatus = %@", GV.aktLanguage, GV.GameStatusPlaying).count
        let newOK = countMandatory - countExistingGames > 0
        let continueOK = countContinueGames > 0
        //--------------------- newGameAction ---------------------
        let newGameAction = UIAlertAction(title: "\(GV.language.getText(.tcNewGame)) (\(countMandatory - countExistingGames)) ", style: .default, handler: { [unowned self]
            alert -> Void in
            if newOK {
                self.startNewGame()
            }
        })
        if !newOK {
            newGameAction.setValue(disabledColor, forKey: "TitleTextColor")
        }
        alertController.addAction(newGameAction)
        //--------------------- continueAction ---------------------
        let continueAction = UIAlertAction(title: "\(GV.language.getText(.tcContinue))", style: .default, handler: { [unowned self]
            alert -> Void in
            if continueOK {
                self.showGames(all: false)
            }
        })
        if !continueOK {
            continueAction.setValue(disabledColor, forKey: "TitleTextColor")
        }
        alertController.addAction(continueAction)
        //--------------------- bestScoreAction ---------------------
        let bestScoreAction = UIAlertAction(title: GV.language.getText(.tcBestScore), style: .default, handler: { [unowned self]
            alert -> Void in
            self.showGames(all: true)
        })
        alertController.addAction(bestScoreAction)
        //--------------------- chooseLanguageAction ---------------------
        let chooseLanguageAction = UIAlertAction(title: GV.language.getText(.tcChooseLanguage), style: .default, handler: { [unowned self]
            alert -> Void in
            self.chooseLanguage()
        })
        alertController.addAction(chooseLanguageAction)
        //--------------------- nickNameAction ---------------------
        let nickNameAction = UIAlertAction(title: GV.language.getText(.tcSetNickName), style: .default, handler: { [unowned self]
            alert -> Void in
            if GV.connectedToInternet {
                self.chooseNickname()
            } else {
                self.showMenu()
            }
        })
        if !GV.connectedToInternet {
            nickNameAction.setValue(disabledColor, forKey: "TitleTextColor")
        }
        alertController.addAction(nickNameAction)
        #if DEBUG
        //--------------------- showRealmCloudAction ---------------------
        let showRealmCloudAction = UIAlertAction(title: GV.language.getText(.tcShowRealmCloud), style: .default, handler: { [unowned self]
            alert -> Void in
            self.displayCloudRecordsViewController()
        })
        alertController.addAction(showRealmCloudAction)
        #endif
        //--------------------- Present alert ---------------------
        present(alertController, animated: true, completion: nil)

    }
    
//    func startMenuScene1(showMenu: Bool = false) {
//        let menuScene = MenuScene(size: CGSize(width: view.frame.width, height: view.frame.height))
//        if let view = self.view as! SKView? {
//            let actGames = realm.objects(GameDataModel.self).filter("nowPlaying = TRUE and language = %@", GV.aktLanguage)
//            if showMenu || actGames.count == 0 {
//                menuScene.setDelegate(delegate: self)
//                view.presentScene(menuScene)
//            } else {
//                continueGame()
//            }
//        }
//    }
    
    private func generateBasicDataRecordIfNeeded() {
        try! realm.write {
            let myName = String(UInt64(Date().timeIntervalSince1970 * 111111))
            //            let toDelete = realm.objects(BasicDataModel.self)
            //            realm.delete(toDelete)
            if realm.objects(BasicDataModel.self).count == 0 {
                GV.basicDataRecord = BasicDataModel()
                GV.basicDataRecord.actLanguage = GV.language.getText(.tcAktLanguage)
                GV.basicDataRecord.myName = myName
                GV.basicDataRecord.myNickname = generateMyNickname()
                realm.add(GV.basicDataRecord)
            } else {
                GV.basicDataRecord = realm.objects(BasicDataModel.self).first!
                if GV.basicDataRecord.myName == "" {
                    GV.basicDataRecord.myName = myName
                    GV.basicDataRecord.myNickname = generateMyNickname()
                }
                GV.language.setLanguage(GV.basicDataRecord.actLanguage)
            }
            //            loginToRealmSync()
        }
    }
    
    func generateMyNickname()->String {
        var nickName = GV.onIpad ? "iPad" : "iPhone"
        let letters = GV.language.getText(.tcNickNameLetters)
        for _ in 0...4 {
            nickName += letters.subString(startPos: Int.random(min: 0, max: letters.count - 1), length: 1)
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
                        try! realmSync?.write {
                            playerActivity![0].nickName = nickName
                            playerActivity![0].keyWord = keyWord
                        }
                        try! realm.write {
                            GV.basicDataRecord.myNickname = nickName
                            GV.basicDataRecord.keyWord = keyWord
                        }
                    } else {
                        if self!.playerActivityByNickName![0].keyWord == nil || self!.playerActivityByNickName![0].keyWord == "" {
                            let alertController = UIAlertController(title: GV.language.getText(.tcNicknameUsed),
                                                                    message: GV.language.getText(.tcNicknameActivating),
                                                                    preferredStyle: .alert)
                            alertController.addAction(UIAlertAction(title: GV.language.getText(.tcOK), style: .default, handler: nil))
                            alertController.addAction(UIAlertAction(title: GV.language.getText(.tcCancel), style: .default, handler: nil))
                            self!.present(alertController, animated: true, completion: nil)
                        } else {
                            if self!.playerActivityByNickName![0].keyWord == keyWord {
                                try! realmSync?.write {
                                    playerActivity![0].nickName = nickName
                                    playerActivity![0].keyWord = keyWord
                                }
                                try! realm.write {
                                    GV.basicDataRecord.myNickname = nickName
                                    GV.basicDataRecord.keyWord = keyWord
                                }
                            } else {
                                let alertController = UIAlertController(title: GV.language.getText(.tcNicknameUsed),
                                                                        message: GV.language.getText(.tcAddKeyWord),
                                                                        preferredStyle: .alert)
                                alertController.addAction(UIAlertAction(title: GV.language.getText(.tcOK), style: .default, handler: nil))
                                alertController.addAction(UIAlertAction(title: GV.language.getText(.tcCancel), style: .default, handler: nil))
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
    
    //    func setIsOnline() {
    ////        let syncConfig: SyncConfiguration = SyncConfiguration(user: GV.myUser!, realmURL: GV.REALM_URL)
    ////        let syncConfig = SyncUser.current!.configuration(realmURL: GV.REALM_URL, user: GV.myUser!)
    ////        let config = SyncUser.current!.configuration(realmURL: GV.REALM_URL, fullSynchronization: false, enableSSLValidation: true, urlPrefix: nil)
    ////        let config = Realm.Configuration(syncConfiguration: syncConfig, objectTypes: [BestScoreSync.self, PlayerActivity.self])
    //        realmSync = try! Realm(configuration: config)
    //        if playerActivity == nil {
    //            playerActivity = realmSync?.objects(PlayerActivity.self).filter("name = %@", GV.basicDataRecord.myName)
    //        }
    //        try! realmSync?.write {
    //            if playerActivity?.count == 0 {
    //                let playerActivityItem = PlayerActivity()
    //                playerActivityItem.name = GV.basicDataRecord.myName
    //                playerActivityItem.nickName = GV.basicDataRecord.myNickname
    //                playerActivityItem.isOnline = true
    //                playerActivityItem.onlineSince = getLocalDate()
    //                playerActivityItem.onlineTime = 0
    //                realmSync?.add(playerActivityItem)
    //            } else {
    //                playerActivity![0].isOnline = true
    //                playerActivity![0].onlineSince = getLocalDate()
    //            }
    //        }
    ////        setNotification()
    //    }
    
    //    func setNotification() {
    //        let playerActivityResult = realmSync?.objects(PlayerActivity.self).filter("name != %@", "xxxx")
    ////        let subscription = playerActivityResult.subscribe()
    ////        var subscribe = realmSync?.objects(PlayerActivity.self).subscribe()
    //        GV.notificationToken = playerActivityResult?.observe {(changes: RealmCollectionChange) in
    //        switch changes {
    //        case .initial:
    //            break
    //        // Results are now populated and can be accessed without blocking the UI
    //        case .update(_, _, _, _):// let deletions, let insertions, let modifications):
    //            break
    //        // Query results have changed, so apply them to the UITableView
    //        case .error(let error):
    //        // An error occurred while opening the Realm file on the background worker thread
    //            fatalError("\(error)")
    //        }
    //        }
    //
    //    }
    
    
    
    
    
    func printFonts() {
        let fontFamilyNames = UIFont.familyNames
        for familyName in fontFamilyNames {
            print("------------------------------")
            print("Font Family Name = [\(familyName)]")
            let names = UIFont.fontNames(forFamilyName: familyName)
            print("Font Names = [\(names)]")
        }
    }
    
    
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
}
