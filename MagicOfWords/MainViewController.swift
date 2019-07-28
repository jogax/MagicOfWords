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
import GameKit
//import SCLAlertView


class MainViewController: UIViewController, WelcomeSceneDelegate, WTSceneDelegate, GCHelperDelegate, ShowGamesSceneDelegate  {
    
    func matchStarted() {
        
    }
    
    func match(_ match: GKMatch, didReceive didReceiveData: Data, fromPlayer: String) {
        
    }
    
    func matchEnded(error: String) {
        
    }
    
    func localPlayerAuthenticated() {
        if GV.basicDataRecord.GameCenterEnabled != GCEnabledType.GameCenterEnabled.rawValue {
            try! realm.safeWrite() {
                GV.basicDataRecord.GameCenterEnabled = GCEnabledType.GameCenterEnabled.rawValue
            }
        }
        GCHelper.shared.getBestScore(completion: {})
//        GCHelper.shared.getAllScores(completion: {})
        startDemoOrMenu()
    }
    
    func continueTimeCount() {
        
    }
    
    func firstPlaceFounded() {
        
    }
    
    func myPlaceFounded() {
        
    }
    
    
    func backFromAnimation() {
        if let view = self.view as! SKView? {
            view.presentScene(nil)
        }
        showBackgroundPicture()
        self.showMenu()
    }
    
    func showHowToPlay(difficulty: Int) {
        if let view = self.view as! SKView? {
            view.presentScene(nil)
        }
        showBackgroundPicture()
        GV.origDifficulty = GV.basicDataRecord.difficulty
        try! realm.safeWrite() {
            GV.basicDataRecord.difficulty = difficulty
        }
        GV.helpInfoRecords = realmHelp.objects(HelpInfo.self).filter("language = %d", GV.actLanguage).sorted(byKeyPath: "counter")
        let gameNumber = difficulty == GameDifficulty.Easy.rawValue ? GV.DemoEasyGameNumber : GV.DemoMediumGameNumber
        if GV.helpInfoRecords!.count > 0 {
            startWTScene(new: true, next: StartType.GameNumber, gameNumber: gameNumber, restart: true, showHelp: true)
        } else {
            self.showMenu()
        }
    }
    
    
//    func chooseNickname() {
//        let alertController = UIAlertController(title: GV.language.getText(.tcSetNickName),
//                                                message: GV.language.getText(.tcAddCodeRecommended),
//                                                preferredStyle: .alert)
//        alertController.addAction(UIAlertAction(title: GV.language.getText(.tcSave), style: .default, handler: { [unowned self]
//            alert -> Void in
//            let nickNameField = alertController.textFields![0] as UITextField
//            let keyWordField = alertController.textFields![1] as UITextField
//            self.setNickname(nickName: nickNameField.text!, keyWord: keyWordField.text!)
////            self.showMenu()
//        }))
//        alertController.addAction(UIAlertAction(title: GV.language.getText(.tcCancel), style: .cancel, handler: { [unowned self]
//            alert -> Void in
//            self.showMenu()
//        }))
//        alertController.addTextField(configurationHandler: {(textField : UITextField!) -> Void in
//            textField.text = playerActivity![0].nickName
//        })
//        alertController.addTextField(configurationHandler: {(textField : UITextField!) -> Void in
//            if GV.basicDataRecord.keyWord == "" {
//                textField.placeholder = GV.language.getText(.tcKeyWord)
//            } else {
//                textField.text = GV.basicDataRecord.keyWord
//            }
//        })
//        self.present(alertController, animated: true, completion: nil)
//
//    }
    #if DEBUG
    func displayCloudRecordsViewController() {
//        if GV.myUser != nil
//        {
//            let cloudRecordsViewController = CloudRecordsViewController()
//            self.present(cloudRecordsViewController, animated: true, completion: nil)
//        }
    }
    
    func displayCreateMandatoryViewController() {
//        if GV.myUser != nil {
//            let createMandatoryViewController = CreateMandatoryWordsViewController()
//            self.present(createMandatoryViewController, animated: true, completion: nil)
//        }
    }
    #endif
    
    func displayCollectMandatoryViewController() {
//        if GV.myUser != nil && GV.expertUser {
//            let collectMandatoryViewController = CollectMandatoryWordsViewController()
//            self.present(collectMandatoryViewController, animated: true, completion: nil)
//        }
    }
    
    var showGamesScene: ShowGamesScene?
    func backFromSettingsScene() {
        try! realm.safeWrite() {
            GV.basicDataRecord.actLanguage = GV.actLanguage
        }
        showMenu()
//        startMenuScene()
    }
    
    func backToMenuScene(gameNumberSelected: Bool = false, gameNumber: Int = 0, restart: Bool) {
//        if showGamesScene != nil {
//            showGamesScene!.removeFromParent()
//            showGamesScene = nil
//        }
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
        GV.playing = false
        GV.generateHelpInfo = false
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
    
    func startWTScene(new: Bool, next: StartType, gameNumber: Int, restart: Bool = false, showHelp: Bool = false) {
        let wtScene = WTScene(size: CGSize(width: view.frame.width, height: view.frame.height))
        if let view = self.view as! SKView? {
            wtScene.setDelegate(delegate: self)
            wtScene.setGameArt(new: new, next: next, gameNumber: gameNumber, restart: restart, showHelp: showHelp)
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
        let gameNumber = GV.basicDataRecord.difficulty * 1000
        startWTScene(new: true, next: .NoMore, gameNumber: gameNumber)
    }
    
    func continueGame() {
        let gameNumber = GV.basicDataRecord.difficulty * 1000
        startWTScene(new: false, next: .NoMore, gameNumber: gameNumber)
    }
    
    func chooseLanguage() {
        func setLanguage(language: String) {
            GV.language.setLanguage(language)
            try! realm.safeWrite() {
                GV.basicDataRecord.actLanguage = language
            }
            GCHelper.shared.getBestScore(completion: {})
            GCHelper.shared.getAllScores(completion: {})
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
        let image = UIImage()
        englishAction.setValue(image, forKey: "image")
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
        let cancelAction = UIAlertAction(title: GV.language.getText(.tcCancel), style: .default, handler: {
            alert -> Void in
            self.showMenu()
        })
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
    }
    
//    override func viewDidLoad() {
    var countMandatory = 0
    var countExistingGames = 0
    var countContinueGames = 0
    
    private func getRecordCounts() {
        countMandatory = realmMandatory.objects(MandatoryModel.self).filter("language = %@ and gameNumber < 1000", GV.actLanguage).count
        countExistingGames = realm.objects(GameDataModel.self).filter("language = %@ and gameNumber >= %d and gameNumber <= %d", GV.actLanguage, GV.minGameNumber, GV.maxGameNumber).count
        countContinueGames = realm.objects(GameDataModel.self).filter("language = %@ and gameNumber >= %d and gameNumber <= %d and (gameStatus = %@ or gameStatus = %@)", GV.actLanguage, GV.minGameNumber, GV.maxGameNumber, GV.GameStatusPlaying, GV.GameStatusContinued).count
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidLoad()
//        realmSync = RealmService
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
        getRecordCounts()
        if GV.basicDataRecord.GameCenterEnabled == GCEnabledType.AskForGameCenter.rawValue {
            manageGameCenter()
        } else {
            startDemoOrMenu()
        }
//        #else
//            if countContinueGames > 0 {
//                startWTScene(new: false, next: .NoMore, gameNumber: 0)
//            } else {
//                showMenu()
//            }
//        #endif
        //------------------------
//        startMenuScene()
    }
    
    @objc private func startDemoOrMenu() {
        if !GV.basicDataRecord.startAnimationShown {
            startWelcomeScene()
        } else {
            if GV.basicDataRecord.GameCenterEnabled == GCEnabledType.GameCenterEnabled.rawValue && GCHelper.shared.authenticateStatus != GCHelper.AuthenticatingStatus.authenticated {
                GCHelper.shared.authenticateLocalUser(theDelegate: self, presentingViewController: self)
                return
            }
            if countContinueGames > 0 {
                startWTScene(new: false, next: .NoMore, gameNumber: 0)
            } else {
                showMenu()
            }
        }
    }

    @objc private func startWelcomeScene(){
        let animationScene = WelcomeScene(size: CGSize(width: view.frame.width, height: view.frame.height))
        if let view = self.view as! SKView? {
            animationScene.setDelegate(delegate: self)
            //                wtScene.setGameArt(new: new, next: next, gameNumber: gameNumber, restart: restart)
            //                wtScene.parentViewController = self
            view.presentScene(animationScene)
        }
    }
    
    @objc private func firstButton () {
        print("firstButton tapped")
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
//        if !GV.callBackExpertUser.contains(where: {$0.myCaller == callerName}) {
//            GV.callBackExpertUser.append(GV.CallBackStruct(caller: callerName, callBackFunction: expertUserChanged))
//        }
//        expertUserChanged()
    }
    
//    public func expertUserChanged() {
//        if GV.expertUser {
//            let title = GV.language.getText(.tcCollectMandatory)
//            if alertController != nil {
//                if alertController!.actions.last!.title != title {
//                    collectMandatoryAction = UIAlertAction(title: title, style: .default, handler: { [unowned self]
//                        alert -> Void in
//                        self.displayCollectMandatoryViewController()
//                    })
//                    collectMandatoryAction!.isEnabled = GV.connectedToInternet && playerActivity != nil
//                    alertController!.addAction(collectMandatoryAction!)
//                }
//            }
//        }
//    }
    
    
    
    
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
        let gameDifficulty = GameDifficulty(rawValue: GV.basicDataRecord.difficulty)
        let disabledColor = UIColor(red:204/255, green: 229/255, blue: 255/255,alpha: 1.0)
        alertController = UIAlertController(title: GV.language.getText(.tcChooseAction),
                                            message: GV.language.getText(.tcMyNickName, values: GV.basicDataRecord.myNickname, gameDifficulty!.description()),
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
        //--------------------- SettingsAction ---------------------------
        let settingsAction = UIAlertAction(title: GV.language.getText(.tcSettings), style: .default, handler: { [unowned self]
            alert -> Void in
            self.showSettingsMenu()
        })
        alertController!.addAction(settingsAction)

        
        //        //--------------------- chooseLanguageAction ---------------------
        //        let chooseLanguageAction = UIAlertAction(title: GV.language.getText(.tcChooseLanguage), style: .default, handler: { [unowned self]
        //            alert -> Void in
        //            self.chooseLanguage()
        //        })
        //        alertController!.addAction(chooseLanguageAction)
        //--------------------- nickNameAction ---------------------
        
//        nickNameAction = UIAlertAction(title: GV.language.getText(.tcSetNickName), style: .default, handler: { [unowned self]
//            alert -> Void in
//            if GV.connectedToInternet && playerActivity != nil && GV.myUser != nil {
//                self.chooseNickname()
//            } else {
//                self.showMenu()
//            }
//        })
//        nickNameAction!.isEnabled = GV.connectedToInternet && playerActivity != nil
//        alertController!.addAction(nickNameAction!)
//        expertUserChanged()
        #if DEBUG
        let developerMenuAction = UIAlertAction(title: GV.language.getText(.tcDeveloperMenu), style: .default, handler: { [unowned self]
            alert -> Void in
            self.developerMenuChoosed()
        })
        alertController!.addAction(developerMenuAction)
        #endif
        //--------------------- Present alert ---------------------
        present(alertController!, animated: true, completion: nil)
        
    }
    
    func manageGameCenter() {
        switch GV.basicDataRecord.GCEnabled {
        case GCEnabledType.GameCenterEnabled.rawValue:
            if GCHelper.shared.authenticateStatus == GCHelper.AuthenticatingStatus.notAuthenticated {
                GCHelper.shared.authenticateLocalUser(theDelegate: self, presentingViewController: self)
//                self.startDemoOrMenu()
            }
        case GCEnabledType.AskForGameCenter.rawValue:
            let alert = UIAlertController(title: GV.language.getText(.tcAskForGameCenter),
                                          message: "",
                                          preferredStyle: .alert)
            let connectAction = UIAlertAction(title: GV.language.getText(.tcConnectGC), style: .default,
                                              handler: {(paramAction:UIAlertAction!) in
                                                try! realm.safeWrite() {
                                                    GV.basicDataRecord.GCEnabled = GCEnabledType.GameCenterEnabled.rawValue
                                                }
                                                self.connectToGameCenter()
//                                                self.startDemoOrMenu()
            })
            
            alert.addAction(connectAction)
            
            let askLaterAction = UIAlertAction(title: GV.language.getText(.tcAskLater), style: .default,
                                               handler: {(paramAction:UIAlertAction!) in
                                                self.startDemoOrMenu()
            })
            
            alert.addAction(askLaterAction)
            let askNoMoreAction = UIAlertAction(title: GV.language.getText(.tcAskNoMore), style: .default,
                                                handler: {(paramAction:UIAlertAction!) in
                                                    try! realm.write({
                                                        GV.basicDataRecord.GCEnabled = GCEnabledType.GameCenterSupressed.rawValue
                                                    })
                                                    self.startDemoOrMenu()
            })
            
            alert.addAction(askNoMoreAction)
            present(alert, animated: true, completion: nil)
        default:
            break
        }
        

    }
    
    func connectToGameCenter() {
        GCHelper.shared.authenticateLocalUser(theDelegate: self, presentingViewController: self)
        if GV.basicDataRecord.GCEnabled == GCEnabledType.GameCenterEnabled.rawValue {
            //                self.createLabelsForBestPlace()
        }
        
    }


//    func showMenuX() {
//        getRecordCounts()
//        let disabledColor = UIColor(red:204/255, green: 229/255, blue: 255/255,alpha: 1.0)
//        alertController = MyAlertController(mainText: GV.language.getText(.tcChooseAction), message: GV.language.getText(.tcMyNickName, values: GV.basicDataRecord.myNickname))
//        myAlert.addAction(text: "OK", target: self, action:#selector(self.OKTapped))
//        myAlert.addAction(text: "cancel", target: self, action:#selector(self.cancelTapped))
//        myAlert.zPosition = 10
//        myAlert.presentAlert(target: bgSprite!)
//        myAlert.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
//
//        alertController = UIAlertController(title: GV.language.getText(.tcChooseAction),
//                                                message: GV.language.getText(.tcMyNickName, values: GV.basicDataRecord.myNickname),
//                                                preferredStyle: .alert)
//
//        let newOK = countMandatory - countExistingGames > 0
//        let continueOK = countContinueGames > 0
//        //--------------------- newGameAction ---------------------
//        let newGameAction = UIAlertAction(title: "\(GV.language.getText(.tcNewGame)) ", style: .default, handler: { [unowned self]
//            alert -> Void in
//            if newOK {
//                self.startNewGame()
//            }
//        })
//        if !newOK {
//            newGameAction.setValue(disabledColor, forKey: "TitleTextColor")
//        }
//        alertController!.addAction(newGameAction)
//        //--------------------- continueAction ---------------------
//        let continueAction = UIAlertAction(title: "\(GV.language.getText(.tcContinue))", style: .default, handler: { [unowned self]
//            alert -> Void in
//            if continueOK {
////                self.showGames(all: false)
//                self.startWTScene(new: false, next: .NoMore, gameNumber: 0)
//            }
//        })
//        if !continueOK {
//            continueAction.isEnabled = false
////            continueAction.setValue(disabledColor, forKey: "TitleTextColor")
//        }
//        alertController!.addAction(continueAction)
//        //--------------------- bestScoreAction ---------------------
//        let bestScoreAction = UIAlertAction(title: GV.language.getText(.tcBestScore), style: .default, handler: { [unowned self]
//            alert -> Void in
//            self.showGames(all: true)
//        })
//        alertController!.addAction(bestScoreAction)
//        //--------------------- SettingsAction ---------------------------
//        let settingsAction = UIAlertAction(title: GV.language.getText(.tcSettings), style: .default, handler: { [unowned self]
//            alert -> Void in
//            self.showSettingsMenu()
//        })
//        alertController!.addAction(settingsAction)
//
////        //--------------------- chooseLanguageAction ---------------------
////        let chooseLanguageAction = UIAlertAction(title: GV.language.getText(.tcChooseLanguage), style: .default, handler: { [unowned self]
////            alert -> Void in
////            self.chooseLanguage()
////        })
////        alertController!.addAction(chooseLanguageAction)
//        //--------------------- nickNameAction ---------------------
//
//        nickNameAction = UIAlertAction(title: GV.language.getText(.tcSetNickName), style: .default, handler: { [unowned self]
//            alert -> Void in
//            if GV.connectedToInternet && playerActivity != nil && GV.myUser != nil {
//                self.chooseNickname()
//            } else {
//                self.showMenu()
//            }
//        })
//        nickNameAction!.isEnabled = GV.connectedToInternet && playerActivity != nil
//        alertController!.addAction(nickNameAction!)
//        expertUserChanged()
//        #if DEBUG
//            let developerMenuAction = UIAlertAction(title: GV.language.getText(.tcDeveloperMenu), style: .default, handler: { [unowned self]
//                alert -> Void in
//                self.developerMenuChoosed()
//            })
//            alertController!.addAction(developerMenuAction)
//        #endif
//        //--------------------- Present alert ---------------------
//        present(alertController!, animated: true, completion: nil)
//
//    }

//    var cloudGameData: Results<GameData>?
//    var cloudGameDataSubscription: SyncSubscription<GameData>?
//    var cloudGameDataToken: NotificationToken?
    var realmHelpInfo: Realm?
    #if DEBUG
    @objc private func developerMenuChoosed() {
        initiateHelpModel()
        let countContinueGames = realmHelpInfo!.objects(HelpInfo.self).filter("language = %@", GV.actLanguage).count

        let alertController = UIAlertController(title: GV.language.getText(.tcDeveloperMenu),
                                            message: "",
                                            preferredStyle: .alert)
        
//        showRealmCloudAction = UIAlertAction(title: GV.language.getText(.tcShowRealmCloud), style: .default, handler: { [unowned self]
//            alert -> Void in
//            self.displayCloudRecordsViewController()
//        })
//        showRealmCloudAction!.isEnabled = GV.connectedToInternet && playerActivity != nil
//        alertController.addAction(showRealmCloudAction!)
//
//        let useGameDataAction = UIAlertAction(title: GV.language.getText(.tcUseCloudGameData), style: .default, handler: { [unowned self]
//            alert -> Void in
//            self.getCloudData()
//        })
//        alertController.addAction(useGameDataAction)
//
        let newGenHelpAction = UIAlertAction(title: GV.language.getText(.tcHelpGenNew), style: .default, handler: { [unowned self]
            alert -> Void in
            self.areYouSure()
        })
        alertController.addAction(newGenHelpAction)
        if countContinueGames > 0 {
            let continueGenHelpAction = UIAlertAction(title: GV.language.getText(.tcHelpGenContinue), style: .default, handler: { [unowned self]
                alert -> Void in
                GV.generateHelpInfo = true
                let gameNumber = GV.basicDataRecord.difficulty == GameDifficulty.Easy.rawValue ? GV.DemoEasyGameNumber : GV.DemoMediumGameNumber
                self.startWTScene(new: true, next: .GameNumber, gameNumber: gameNumber, restart: true, showHelp: true)
            })
            alertController.addAction(continueGenHelpAction)

        }
        let cancelAction = UIAlertAction(title: GV.language.getText(.tcCancel), style: .default, handler: { [unowned self]
            alert -> Void in
            self.showMenu()
        })
        alertController.addAction(cancelAction)

        present(alertController, animated: true, completion: nil)

    }
    
    private func areYouSure() {
        let alertController = UIAlertController(title: GV.language.getText(.tcAreYouSureForNewDemo),
                                                message: GV.language.getText(.tcAreYouSureMessage),
                                                preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: GV.language.getText(.tcCancel), style: .default, handler: { [unowned self]
            alert -> Void in
            self.showMenu()
        })
        alertController.addAction(cancelAction)

        let OKAction = UIAlertAction(title: GV.language.getText(.tcOK), style: .default, handler: { [unowned self]
            alert -> Void in
            GV.generateHelpInfo = true
            let gameNumber = GV.basicDataRecord.difficulty == GameDifficulty.Easy.rawValue ? GV.DemoEasyGameNumber : GV.DemoMediumGameNumber
            self.startWTScene(new: true, next: .GameNumber, gameNumber: gameNumber)
        })
        alertController.addAction(OKAction)
        present(alertController, animated: true, completion: nil)
    }
    
    #endif

//    private func getCloudData() {
//        cloudGameData = realmSync!.objects(GameData.self).filter("combinedKey BEGINSWITH %@", GV.actLanguage)
//        cloudGameDataSubscription = cloudGameData!.subscribe(named: "cloudGameData:\(GV.actLanguage)")
//        cloudGameDataToken = cloudGameDataSubscription!.observe(\.state) { [weak self]  state in
//            if state == .complete {
//                if self!.cloudGameData!.count > 0 {
//                    let alertController = UIAlertController(title: GV.language.getText(.tcChooseGameToGet),
//                                                              message: "",
//                                                              preferredStyle: .alert)
//                    for game in self!.cloudGameData! {
//                        let nickName = game.owner!.nickName
//                        let gameNumber = String(game.gameNumber)
//                        let combinedKey = GV.actLanguage + gameNumber + game.owner!.name
//                        let chooseLanguageAction = UIAlertAction(title: GV.language.getText(.tcGameLine, values: nickName!, String(game.gameNumber + 1)), style: .default, handler: { [/*unowned*/ self]
//                            alert -> Void in
//                            self!.getGame(combinedKey: combinedKey)
//                        })
//                        alertController.addAction(chooseLanguageAction)
//                    }
//                    let cancelAction =  UIAlertAction(title: GV.language.getText(.tcCancel), style: .default, handler: { [/*unowned*/ self]
//                        alert -> Void in
//                        self!.showMenu()
//                    })
//                    alertController.addAction(cancelAction)
//                    self!.present(alertController, animated: true, completion: nil)
//                }
//            }
//        }
//    }
//
//    @objc private func getGame(combinedKey: String) {
//        let cloudGameDataRecord = cloudGameData!.filter("combinedKey = %d", combinedKey).first!
//        let adder = 1000
//        let localGameNumber = cloudGameDataRecord.gameNumber + adder
//        let localCombinedKey = cloudGameDataRecord.language + String(localGameNumber)
//        let localRecords = realm.objects(GameDataModel.self).filter("combinedKey = %d", localCombinedKey)
//        if localRecords.count > 0 {
//            try! realm.safeWrite() {
//                realm.delete(localRecords)
//            }
//        }
//        let localGameData = GameDataModel()
//        localGameData.combinedKey = localCombinedKey
//        localGameData.language = cloudGameDataRecord.language
//        localGameData.gameNumber = localGameNumber
//        localGameData.nowPlaying = false
//        localGameData.gameStatus = cloudGameDataRecord.gameStatus
//        localGameData.mandatoryWords = cloudGameDataRecord.mandatoryWords
//        localGameData.ownWords = cloudGameDataRecord.ownWords
//        localGameData.pieces = cloudGameDataRecord.pieces
//        localGameData.words = cloudGameDataRecord.words
//        localGameData.score = cloudGameDataRecord.score
//        localGameData.time = cloudGameDataRecord.time
//        localGameData.synced = true
//        try! realm.safeWrite() {
//            realm.add(localGameData)
//            for round in cloudGameDataRecord.rounds {
//                let myRound = RoundDataModel()
//                myRound.infos = round.infos
//                myRound.activityItems = round.activityItems
//                myRound.gameArray = round.gameArray
//                myRound.roundScore = round.roundScore
//                localGameData.rounds.append(myRound)
//            }
//        }
//        showMenu()
//    }
//
//
    
    private func showSettingsMenu() {
        let myAlertController = UIAlertController(title: GV.language.getText(.tcSettings),
                                            message: "",
                                            preferredStyle: .alert)
        //--------------------- chooseLanguageAction ---------------------
        let chooseLanguageAction = UIAlertAction(title: GV.language.getText(.tcChooseLanguage), style: .default, handler: { [unowned self]
            alert -> Void in
            self.chooseLanguage()
        })
        myAlertController.addAction(chooseLanguageAction)
        //--------------------- chooseDifficultyAction ---------------------
        let chooseDifficultyAction = UIAlertAction(title: GV.language.getText(.tcChooseDifficulty), style: .default, handler: { [unowned self]
            alert -> Void in
            self.chooseDifficulty()
        })
        myAlertController.addAction(chooseDifficultyAction)
        //--------------------- GameCenter on / off ---------------------
        var GCTitle = ""
        var chooseGCAction: UIAlertAction
        if GCHelper.shared.authenticateStatus == GCHelper.AuthenticatingStatus.authenticated {
            GCTitle = GV.language.getText(.tcDisconnectGC)
            chooseGCAction = UIAlertAction(title: GCTitle, style: .default, handler: { /*[unowned self]*/
                alert -> Void in
                GCHelper.shared.authenticateStatus = .notAuthenticated
                try! realm.safeWrite() {
                    GV.basicDataRecord.GameCenterEnabled = GCEnabledType.GameCenterSupressed.rawValue
                }
                self.showMenu()
            })
        } else {
            GCTitle = GV.language.getText(.tcConnectGC)
            chooseGCAction = UIAlertAction(title: GCTitle, style: .default, handler: { [unowned self]
                alert -> Void in
                GCHelper.shared.authenticateLocalUser(theDelegate: self, presentingViewController: self)
            })
        }
        myAlertController.addAction(chooseGCAction)
       //--------------------- chooseLanguageAction ---------------------
        let showHelpAction = UIAlertAction(title: GV.language.getText(.tcShowHelp), style: .default, handler: { [unowned self]
            alert -> Void in
//            self.showHowToPlay()
            self.startWelcomeScene()
        })
        myAlertController.addAction(showHelpAction)
       //--------------------- choose Style action -----------------------
//        let chooseStyleAction =  UIAlertAction(title: GV.language.getText(.tcChooseStyle), style: .default, handler: { [unowned self]
//            alert -> Void in
//            self.chooseStyle()
//        })
//        myAlertController.addAction(chooseStyleAction)
        //-------------------- generate BestScoreForGame ------------------
//        #if DEBUG
//            let generateListAction =  UIAlertAction(title: GV.language.getText(.tcGenerateBestScore), style: .default, handler: { [unowned self]
//                alert -> Void in
//                self.generateBestScoreList()
//                self.showMenu()
//            })
//            myAlertController.addAction(generateListAction)
//        #endif
        let cancelAction =  UIAlertAction(title: GV.language.getText(.tcCancel), style: .default, handler: { [unowned self]
            alert -> Void in
            self.showMenu()
        })
        myAlertController.addAction(cancelAction)

        present(myAlertController, animated: true, completion: nil)
    }
    
//    var bestScoreItems: Results<BestScoreSync>?
//    var bestScoreNotificationToken: NotificationToken?
//    var bestScoreSubscription: SyncSubscription<BestScoreSync>!
//    var forGameItems: Results<BestScoreForGame>?
//    var forGameNotificationToken: NotificationToken?
//    var forGameSubscription: SyncSubscription<BestScoreForGame>!
//    var bestScoreSubscriptionToken: NotificationToken?
//    var forGameSubscriptionToken: NotificationToken?
    
    

//    private func deactivateSubscriptions() {
//        if forGameSubscription != nil {
//            forGameSubscriptionToken!.invalidate()
//            forGameSubscription!.unsubscribe()
//        }
//        if bestScoreSubscription != nil {
//            bestScoreSubscriptionToken!.invalidate()
//            bestScoreSubscription!.unsubscribe()
//        }
//    }

//    private func generateBestScoreList() {
//        deactivateSubscriptions()
//        bestScoreItems = RealmService.objects(BestScoreSync.self).filter("language = %@ AND score > 0", GV.actLanguage).sorted(byKeyPath: "gameNumber", ascending: true)
//        bestScoreSubscription = bestScoreItems!.subscribe(named: "\(GV.actLanguage)bestScoreQuery")
//        bestScoreSubscriptionToken = bestScoreSubscription.observe(\.state) { [weak self]  state in
//            print("in Subscription!")
//            switch state {
//            case .creating:
//                print("creating")
//            // The subscription has not yet been written to the Realm
//            case .pending:
//                print("pending")
//                // The subscription has been written to the Realm and is waiting
//            // to be processed by the server
//            case .complete:
//                self!.forGameItems = RealmService.objects(BestScoreForGame.self).filter("language = %@", GV.actLanguage).sorted(byKeyPath: "gameNumber", ascending: true)
//                self!.forGameSubscription = self!.forGameItems!.subscribe(named: "\(GV.actLanguage)bestForGameList")
//                self!.forGameSubscriptionToken = self!.forGameSubscription.observe(\.state) { [weak self]  state in
//                    switch state {
//                    case .creating:
//                        print("creating")
//                    // The subscription has not yet been written to the Realm
//                    case .pending:
//                        print("pending")
//                        // The subscription has been written to the Realm and is waiting
//                    // to be processed by the server
//                    case .complete:
//                        print("Both table are complete")
//                        for gameNumber in 0...999 {
//                             if self!.bestScoreItems!.filter("gameNumber = %d", gameNumber).count > 0 {
//                                if self!.forGameItems!.filter("gameNumber = %d", gameNumber).count == 0 {
//                                    let item = self!.bestScoreItems!.filter("gameNumber = %d", gameNumber).sorted(byKeyPath: "score", ascending: false).first!
//                                    let bestScoreForGameItem = BestScoreForGame()
//                                    bestScoreForGameItem.combinedPrimary = String(gameNumber) + item.language
//                                    bestScoreForGameItem.gameNumber = gameNumber
//                                    bestScoreForGameItem.language = item.language
//                                    bestScoreForGameItem.bestScore = item.score
//                                    bestScoreForGameItem.timeStamp = item.timeStamp
//                                    bestScoreForGameItem.owner = item.owner!
//                                    try! RealmService.safeWrite() {
//                                        RealmService.add(bestScoreForGameItem)
//                                    }
//                                }
//                            }
//                        }
//                    case .invalidated:
//                        print("invalidated")
//                    // The subscription has been removed
//                    case .error(let error):
//                        print("error: \(error)")
//                        // An error occurred while processing the subscription
//                    }
//                }
//
//            case .invalidated:
//                print("invalidated")
//            // The subscription has been removed
//            case .error(let error):
//                print("error: \(error)")
//                // An error occurred while processing the subscription
//            }
//            
//        }
//
//    }
//    
    private func setDifficulty(difficulty: GameDifficulty) {
        try! realm.safeWrite() {
            GV.basicDataRecord.difficulty = difficulty.rawValue
        }
        GV.minGameNumber = GV.basicDataRecord.difficulty * 1000
        GV.maxGameNumber = GV.minGameNumber + 999
        getRecordCounts()
        GCHelper.shared.getBestScore(completion: {})
        GCHelper.shared.getAllScores(completion: {})
        self.showMenu()
    }
    
    private func chooseDifficulty() {
        var currentDifficultyString = ""
        switch GV.basicDataRecord.difficulty {
        case GameDifficulty.Easy.rawValue:      currentDifficultyString = GV.language.getText(.tcSimpleGame)
        case GameDifficulty.Medium.rawValue:    currentDifficultyString = GV.language.getText(.tcMediumGame)
        case GameDifficulty.Hard.rawValue:      currentDifficultyString = GV.language.getText(.tcHardGame)
        case GameDifficulty.VeryHard.rawValue:  currentDifficultyString = GV.language.getText(.tcVeryHardGame)
        default: break
        }

        let alertController = UIAlertController(title: GV.language.getText(.tcChooseDifficulty),
                                                message: GV.language.getText(.tcCurrentDifficulty, values: currentDifficultyString),
                                                preferredStyle: .alert)
        let simpleGameAction = UIAlertAction(title: GV.language.getText(.tcSimpleGame), style: .default, handler: {
            alert -> Void in
            self.setDifficulty(difficulty: .Easy)
        })
        alertController.addAction(simpleGameAction)
        
        let hardGameAction = UIAlertAction(title: GV.language.getText(.tcMediumGame), style: .default, handler: {
            alert -> Void in
            self.setDifficulty(difficulty: .Medium)
        })
        alertController.addAction(hardGameAction)

        let cancelAction =  UIAlertAction(title: GV.language.getText(.tcCancel), style: .default, handler: { [unowned self]
            alert -> Void in
            self.showMenu()
        })
        alertController.addAction(cancelAction)

        present(alertController, animated: true, completion: nil)
        

    }
    
//    private func chooseStyle() {
//        func setStyle(style: String) {
//            try! realm.safeWrite() {
//                GV.basicDataRecord.buttonType = style
//            }
//            GV.buttonType = style
//        }
//        let alertController = UIAlertController(title: GV.language.getText(.tcChooseStyle),
//                                                message: "",
//                                                preferredStyle: .alert)
//        let simpleStyleAction = UIAlertAction(title: GV.language.getText(.tcSimpleStyle), style: .default, handler: {
//            alert -> Void in
//            setStyle(style: GV.ButtonTypeSimple)
////            GV.actFont = GV.FontTypeSimple
////            GV.actLabel = GV.LabelFontSimple
//            self.showMenu()
//        })
//        alertController.addAction(simpleStyleAction)
//        
//        let eliteStyleAction = UIAlertAction(title: GV.language.getText(.tcEliteStyle), style: .default, handler: {
//            alert -> Void in
//            setStyle(style: GV.ButtonTypeElite)
////            GV.actFont = GV.FontTypeElite
////            GV.actLabel = GV.LabelFontElite
//            self.showMenu()
//        })
//        alertController.addAction(eliteStyleAction)
//        
//        present(alertController, animated: true, completion: nil)
//
//    }
    
    private func generateBasicDataRecordIfNeeded() {
        if realm.objects(BasicDataModel.self).count == 0 {
            let myName = generateRandomNameFromDeviceID()
            GV.basicDataRecord = BasicDataModel()
            GV.basicDataRecord.actLanguage = GV.language.getText(.tcAktLanguage)
            GV.basicDataRecord.myName = myName
            GV.basicDataRecord.myNickname = generateMyNickname()
            GV.basicDataRecord.creationTime = Date()
            try! realm.safeWrite() {
                realm.add(GV.basicDataRecord)
            }
        } else {
            GV.basicDataRecord = realm.objects(BasicDataModel.self).first!
            GV.language.setLanguage(GV.basicDataRecord.actLanguage)
        }
//        GV.buttonType = GV.basicDataRecord.buttonType
        GV.minGameNumber = GV.basicDataRecord.difficulty * 1000
        GV.maxGameNumber = GV.minGameNumber + 999

//        GV.actFont = GV.basicDataRecord.buttonType == GV.ButtonTypeElite ? GV.FontTypeElite : GV.FontTypeSimple
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
    
//    var playerActivityByNickName: Results<PlayerActivity>?
//    var playerActivityByNickNameSubscription: SyncSubscription<PlayerActivity>?
//    var playerActivityByNickNameToken: NotificationToken?
    
//    func setNickname(nickName: String, keyWord: String) {
//        if playerActivity!.count == 0 {
//            return
//        }
//        if GV.myUser != nil {
//            playerActivity = realmSync!.objects(PlayerActivity.self).filter("name = %@", GV.basicDataRecord.myName)
//            playerActivityByNickName = realmSync?.objects(PlayerActivity.self).filter("nickName = %@ and name != %@", nickName, GV.basicDataRecord.myName)
//            playerActivityByNickNameSubscription = playerActivityByNickName!.subscribe(named: "PlayerActivityByNickName:\(nickName)")
//            playerActivityByNickNameToken = playerActivityByNickNameSubscription!.observe(\.state) { [weak self]  state in
//                if state == .complete {
//                    if self!.playerActivityByNickName!.count == 0 {
//                        try! realmSync?.safeWrite() {
//                            playerActivity![0].nickName = nickName
//                            playerActivity![0].keyWord = keyWord
//                        }
//                        try! realm.safeWrite() {
//                            GV.basicDataRecord.myNickname = nickName
//                            GV.basicDataRecord.keyWord = keyWord
//                        }
//                        self!.showMenu()
//                    } else {
//                        if self!.playerActivityByNickName![0].keyWord == nil || self!.playerActivityByNickName![0].keyWord == "" {
//                            let alertController = UIAlertController(title: GV.language.getText(.tcNicknameUsedwithout, values: nickName),
//                                                                    message: GV.language.getText(.tcNicknameActivating),
//                                                                    preferredStyle: .alert)
//                            alertController.addAction(UIAlertAction(title: GV.language.getText(.tcOK), style: .default, handler: {alert -> Void in
//                                self!.showMenu()
//                                //            self.showMenu()
//                            }))
////                            alertController.addAction(UIAlertAction(title: GV.language.getText(.tcCancel), style: .default, handler: nil))
//                            self!.present(alertController, animated: true, completion: nil)
//                        } else {
//                            if self!.playerActivityByNickName![0].keyWord == keyWord {
//                                try! realmSync?.safeWrite() {
//                                    playerActivity![0].nickName = nickName
//                                    playerActivity![0].keyWord = keyWord
//                                }
//                                try! realm.safeWrite() {
//                                    GV.basicDataRecord.myNickname = nickName
//                                    GV.basicDataRecord.keyWord = keyWord
//                                }
//                                self!.showMenu()
//                            } else {
//                                let alertController = UIAlertController(title: GV.language.getText(.tcNicknameUsed, values: nickName),
//                                                                        message: GV.language.getText(.tcAddKeyWord),
//                                                                        preferredStyle: .alert)
//                                alertController.addAction(UIAlertAction(title: GV.language.getText(.tcOK), style: .default, handler: {
//                                    alert -> Void in
//                                    self!.showMenu()
//                                    //            self.showMenu()
//                                }))
////                                alertController.addAction(UIAlertAction(title: GV.language.getText(.tcCancel), style: .default, handler: nil))
//                                self!.present(alertController, animated: true, completion: nil)
//                            }
//                        }
//                    }
//                    self!.playerActivityByNickNameSubscription!.unsubscribe()
//                    self!.playerActivityByNickNameToken!.invalidate()
//                } else {
////                    print("in MainViewController -> state: \(state)")
//                }
//            }
//        } else {
//
//        }
//     }
    
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
                        if let idx = word.firstIndex(of: " ") {
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
    private func initiateHelpModel() {
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let helpInfoURL = documentsURL.appendingPathComponent("HelpInfo.realm")
        let config1 = Realm.Configuration(
            fileURL: helpInfoURL,
            shouldCompactOnLaunch: { totalBytes, usedBytes in
                // totalBytes refers to the size of the file on disk in bytes (data + free space)
                // usedBytes refers to the number of bytes used by data in the file
                
                // Compact if the file is over 100MB in size and less than 50% 'used'
                let oneMB = 10 * 1024 * 1024
                return (totalBytes > oneMB) && (Double(usedBytes) / Double(totalBytes)) < 0.8
        },
            objectTypes: [HelpInfo.self])
        do {
            // Realm is compacted on the first open if the configuration block conditions were met.
            _ = try Realm(configuration: config1)
        } catch {
            print("error")
            // handle error compacting or opening Realm
        }
        let helpInfoConfig = Realm.Configuration(
            fileURL: helpInfoURL,
            schemaVersion: 0, // new item words
            // Set the block which will be called automatically when opening a Realm with
            // a schema version lower than the one set above
            migrationBlock: { migration, oldSchemaVersion in
                switch oldSchemaVersion {
//                case 0...3:
//                    migration.deleteData(forType: HelpModel.className())
//                    
                default: migration.enumerateObjects(ofType: BasicDataModel.className())
                { oldObject, newObject in
                    }
                }
        },
            objectTypes: [HelpInfo.self])
        
        realmHelpInfo = try! Realm(configuration: helpInfoConfig)
        
    }

}
