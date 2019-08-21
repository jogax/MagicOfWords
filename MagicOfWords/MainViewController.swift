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


class MainViewController: UIViewController, WelcomeSceneDelegate, WTSceneDelegate, GCHelperDelegate, ShowGamesSceneDelegate, GKGameCenterControllerDelegate  {
    func gameCenterViewControllerDidFinish(_ gameCenterViewController: GKGameCenterViewController) {
        gameCenterViewController.dismiss(animated: true, completion: nil)
        showMenu()
    }
    
    
    func matchStarted() {
        
    }
    
    func match(_ match: GKMatch, didReceive didReceiveData: Data, fromPlayer: String) {
        
    }
    
    func matchEnded(error: String) {
        
    }
    func localPlayerNotAuthenticated() {
//        if wtScene == nil {
//            showMenu()
//        }
    }

    func localPlayerAuthenticated() {
        if GV.basicDataRecord.GameCenterEnabled != GCEnabledType.GameCenterEnabled.rawValue {
            try! realm.safeWrite() {
                GV.basicDataRecord.GameCenterEnabled = GCEnabledType.GameCenterEnabled.rawValue
            }
        }
        GCHelper.shared.getBestScore(completion: {
            self.callModifyHeader()
        })
        if wtScene == nil {
            showMenu()
        }
    }
    
    func callModifyHeader() {
        if animationScene != nil {
            return
        }
        if wtScene != nil {
            wtScene!.modifyHeader()
        } else {
            showMenu()
        }
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
            animationScene = nil
        }
        showBackgroundPicture()
        if GV.basicDataRecord.GameCenterEnabled == GCEnabledType.AskForGameCenter.rawValue && GV.connectedToInternet {
            manageGameCenter()
        } else {
            self.showMenu()
        }
    }
    
    func showHowToPlay(difficulty: Int) {
        if let view = self.view as! SKView? {
            view.presentScene(nil)
            animationScene = nil
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
    
    
    #if DEBUG
    func displayGameCenterViewController() {
        let gameCenterViewController = ShowGameCenterViewController()
        self.present(gameCenterViewController, animated: true, completion: nil)
    }
    #endif
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
            wtScene = nil
        }
        showBackgroundPicture()
        switch start {
        case .NoMore: showMenu() //startMenuScene(showMenu: true)
        case .PreviousGame, .NextGame: startWTScene(new: false, next: start, gameNumber: 0)
        case .NewGame: startWTScene(new: true, next: .NoMore, gameNumber: 0)
        case .GameNumber: startWTScene(new: true, next: .NoMore, gameNumber: 0)
        case .SetEasy:
            setDifficulty(difficulty: .Easy)
            startWTScene(new: false, next: .NoMore, gameNumber: 0)
        case .SetMedium:
            setDifficulty(difficulty: .Medium)
            startWTScene(new: false, next: .NoMore, gameNumber: 0)
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
        wtScene = WTScene(size: CGSize(width: view.frame.width, height: view.frame.height))
        if let view = self.view as! SKView? {
            wtScene!.setDelegate(delegate: self)
            wtScene!.setGameArt(new: new, next: next, gameNumber: gameNumber, restart: restart, showHelp: showHelp)
            wtScene!.parentViewController = self
            view.presentScene(wtScene!)
        }
        
    }
    
    func startFindWordsScene() {
        //        let findWordsScene = WTScene(size: CGSize(width: view.frame.width, height: view.frame.height))
        //        if let view = self.view as! SKView? {
        //            wtScene.setDelegate(delegate: self)
        //            view.presentScene(wtScene)
        //        }
        
    }
    
    func startGame() {
        let actPlay = realm.objects(GameDataModel.self).filter("language = %d and gameNumber >= %d and gameNumber <= %d",GV.actLanguage, GV.minGameNumber, GV.maxGameNumber)
        if actPlay.count == 0 {
            let gameNumber = GV.basicDataRecord.difficulty * 1000
            startWTScene(new: true, next: .NoMore, gameNumber: gameNumber)
        } else {
            if actPlay.count > 1 {
                convertIfNeeded()
            }
//            if actPlay.first!.gameStatus == GV.GameStatusFinished {
//                try! realm.safeWrite() {
////                    realm.delete(actPlay)
//                    GV.basicDataRecord.countPlays += 1
//                    GCHelper.shared.sendScoreToGameCenter(score: 0, difficulty: GV.basicDataRecord.difficulty, completion: {})
//                }
//                let gameNumber = GV.basicDataRecord.difficulty * 1000
//                startWTScene(new: true, next: .NoMore, gameNumber: gameNumber)
//            } else {
            let gameNumber = actPlay.first!.gameNumber
            startWTScene(new: false, next: .NoMore, gameNumber: gameNumber)
//            }
        }
    }
    
//    func continueGame() {
//        let gameNumber = GV.basicDataRecord.difficulty * 1000
//        startWTScene(new: false, next: .NoMore, gameNumber: gameNumber)
//    }
    
    func chooseLanguage() {
        func setLanguage(language: String) {
            GV.language.setLanguage(language)
            try! realm.safeWrite() {
                GV.basicDataRecord.actLanguage = language
                GV.basicDataRecord.land = GV.convertLocaleToInt()
                GV.basicDataRecord.deviceInfoSaved = false
            }
            GCHelper.shared.getBestScore(completion: {
                self.callModifyHeader()
            })
            GCHelper.shared.restartGlobalInfosTimer()
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
//    var countMandatory = 0
//    var countExistingGames = 0
//    var countContinueGames = 0
//
//    private func getRecordCounts() {
//        countMandatory = realmMandatory.objects(MandatoryModel.self).filter("language = %@ and gameNumber < 1000", GV.actLanguage).count
//        countExistingGames = realm.objects(GameDataModel.self).filter("language = %@ and gameNumber >= %d and gameNumber <= %d", GV.actLanguage, GV.minGameNumber, GV.maxGameNumber).count
//        countContinueGames = realm.objects(GameDataModel.self).filter("language = %@ and gameNumber >= %d and gameNumber <= %d and (gameStatus = %@ or gameStatus = %@)", GV.actLanguage, GV.minGameNumber, GV.maxGameNumber, GV.GameStatusPlaying, GV.GameStatusContinued).count
//    }
    var oneMinutesTimer: Timer?
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidLoad()
        #if DEBUG
            GV.debug = true
        #endif
        showBackgroundPicture()
        print("\(String(describing: Realm.Configuration.defaultConfiguration.fileURL))")
        myHeight = self.view.frame.size.height
        myWidth = self.view.frame.size.width
        generateBasicDataRecordIfNeeded()
        
        if oneMinutesTimer != nil {
            oneMinutesTimer!.invalidate()
        }
        oneMinutesTimer = Timer.scheduledTimer(timeInterval: 60.0, target: self, selector: #selector(oneMinutesTimer(timerX: )), userInfo: nil, repeats: false)

        convertIfNeeded()
        if !GV.basicDataRecord.startAnimationShown {
            startWelcomeScene()
        } else {
            let timeInterval = GV.basicDataRecord.startAnimationShown ? 0.01 : 1.0
            _ = Timer.scheduledTimer(timeInterval: timeInterval, target: self, selector: #selector(waitForInternet(timerX: )), userInfo: nil, repeats: false)
        }
    }
    
    @objc private func oneMinutesTimer(timerX: Timer) {
        print("oneMinutesTimer actTime: \(Date())")
        try! realm.safeWrite() {
            GV.basicDataRecord.playingTime += 1
            GV.basicDataRecord.playingTimeToday += 1
        }
        if oneMinutesTimer != nil {
            oneMinutesTimer!.invalidate()
        }
        oneMinutesTimer = Timer.scheduledTimer(timeInterval: 60.0, target: self, selector: #selector(oneMinutesTimer(timerX: )), userInfo: nil, repeats: false)
    }
    
    @objc private func waitForInternet(timerX: Timer) {
        if GV.basicDataRecord.GameCenterEnabled == GCEnabledType.AskForGameCenter.rawValue && GV.connectedToInternet {
            manageGameCenter()
        } else {
            startDemoOrMenu()
        }
    }
    
    private func convertIfNeeded() {
//        var bestScore = 0
//        var bestScoreIndex = 0
        var dayAdder = 1
        for languageIndex in 0...3 {
            let language = GV.IntToLanguage[languageIndex]
            for difficulty in GameDifficulty.Easy.rawValue...GameDifficulty.Medium.rawValue {
                let minGameNumber = difficulty * 1000
                let maxGameNumber = minGameNumber + 999
                let myPlayingRecords = realm.objects(GameDataModel.self).filter("language = %@ and combinedKey BEGINSWITH %@ and gameNumber >= %d and gameNumber <= %d", language!, language!, minGameNumber, maxGameNumber)
                if myPlayingRecords.count > 0 {
                    for myPlayingRecord in myPlayingRecords {
                        let combinedKey =  Calendar.current.date(byAdding: .hour, value: -dayAdder, to: Date())!.toString()
                        let newRecord = myPlayingRecord.copy(newCombinedKey: combinedKey)
                        try! realm.safeWrite() {
                            realm.add(newRecord)
                        }
                        dayAdder += 1
                    }
                    try! realm.safeWrite() {
                        realm.delete(myPlayingRecords)
                    }
                }
            }
        }
        
    }
    
    @objc private func startDemoOrMenu() {
        if !GV.basicDataRecord.startAnimationShown {
            startWelcomeScene()
        } else {
            if GV.basicDataRecord.GameCenterEnabled == GCEnabledType.GameCenterEnabled.rawValue && GCHelper.shared.authenticateStatus != GCHelper.AuthenticatingStatus.authenticated && GV.connectedToInternet {
                GCHelper.shared.authenticateLocalUser(theDelegate: self, presentingViewController: self)
                return
            }
//            if countContinueGames > 0 {
            startWTScene(new: false, next: .NoMore, gameNumber: 0)
//            } else {
//                showMenu()
//            }
        }
    }
    var animationScene: WelcomeScene?

    @objc private func startWelcomeScene() {
        animationScene = WelcomeScene(size: CGSize(width: view.frame.width, height: view.frame.height))
        if let view = self.view as! SKView? {
            animationScene!.setDelegate(delegate: self)
            //                wtScene.setGameArt(new: new, next: next, gameNumber: gameNumber, restart: restart)
            //                wtScene.parentViewController = self
            view.presentScene(animationScene!)
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
    }
    
    var wtScene: WTScene?
    var oldConnectedToInternet = false
    
    
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
        if oldConnectedToInternet != GV.connectedToInternet {
            if GV.connectedToInternet {
                if animationScene != nil {
                    _ = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(waitForAnimationsSceneFinishing(timerX: )), userInfo: nil, repeats: false)
                } else if GV.basicDataRecord.GameCenterEnabled == GCEnabledType.GameCenterEnabled.rawValue {
                    GCHelper.shared.authenticateLocalUser(theDelegate: self, presentingViewController: self)
                } else if GV.basicDataRecord.GameCenterEnabled == GCEnabledType.AskForGameCenter.rawValue {
                    manageGameCenter()
                }
            } else {
                
            }
            oldConnectedToInternet = GV.connectedToInternet
        }
    }
    
    @objc private func waitForAnimationsSceneFinishing(timerX: Timer) {
        if animationScene != nil || wtScene != nil {
            _ = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(waitForAnimationsSceneFinishing(timerX: )), userInfo: nil, repeats: false)
        } else if GV.basicDataRecord.GameCenterEnabled == GCEnabledType.GameCenterEnabled.rawValue {
            GCHelper.shared.authenticateLocalUser(theDelegate: self, presentingViewController: self)
        } else if GV.basicDataRecord.GameCenterEnabled == GCEnabledType.AskForGameCenter.rawValue {
            manageGameCenter()
        }
    }

    var alertController: UIAlertController?
    var nickNameAction: UIAlertAction?
    var collectMandatoryAction: UIAlertAction?

    #if DEBUG
    var showGlobalDataAction: UIAlertAction?
    var createMandatoryAction: UIAlertAction?
    #endif
    
    func showMenu() {
//        getRecordCounts()
//        let gameDifficulty = GameDifficulty(rawValue: GV.basicDataRecord.difficulty)
        alertController = UIAlertController(title: GV.language.getText(.tcChooseAction),
                                            message: "", //GV.language.getText(.tcActDifficulty, values: gameDifficulty!.description()),
                                            preferredStyle: .alert)
        
        //--------------------- StartGameAction ---------------------
        let startEasyGameAction = UIAlertAction(title: "\(GV.language.getText(.tcStartGame)) ", style: .default, handler: { [unowned self]
            alert -> Void in
                self.startGame()
        })
        alertController!.addAction(startEasyGameAction)
        //--------------------- bestScoreAction ---------------------
        let bestScoreAction = UIAlertAction(title: GV.language.getText(.tcBestScore), style: .default, handler: { [unowned self]
            alert -> Void in
            self.showGames(all: true)
        })
        if GKLocalPlayer.local.isAuthenticated && GV.basicDataRecord.GameCenterEnabled == GCEnabledType.GameCenterEnabled.rawValue {
            alertController!.addAction(bestScoreAction)
        }
        //--------------------- chooseLanguageAction ---------------------
        let chooseLanguageAction = UIAlertAction(title: GV.language.getText(.tcChooseLanguage), style: .default, handler: { [unowned self]
            alert -> Void in
            self.chooseLanguage()
        })
        alertController!.addAction(chooseLanguageAction)
        //--------------------- showHelpAction ---------------------
        let showHelpAction = UIAlertAction(title: GV.language.getText(.tcShowHelp), style: .default, handler: { [unowned self]
            alert -> Void in
            //            self.showHowToPlay()
            self.startWelcomeScene()
        })
        alertController!.addAction(showHelpAction)

        //--------------------- GameCenter on ---------------------
        var GCTitle = ""
        var chooseGCAction: UIAlertAction
        if GCHelper.shared.authenticateStatus != GCHelper.AuthenticatingStatus.authenticated {
            GCTitle = GV.language.getText(.tcConnectGC)
            chooseGCAction = UIAlertAction(title: GCTitle, style: .default, handler: { [unowned self]
                alert -> Void in
                GCHelper.shared.authenticateLocalUser(theDelegate: self, presentingViewController: self)
            })
            alertController!.addAction(chooseGCAction)
       }

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
        switch GV.basicDataRecord.GameCenterEnabled {
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
                                                    GV.basicDataRecord.GameCenterEnabled = GCEnabledType.GameCenterEnabled.rawValue
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
                                                    try! realm.safeWrite({
                                                        GV.basicDataRecord.GameCenterEnabled = GCEnabledType.GameCenterSupressed.rawValue
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
        if GV.basicDataRecord.GameCenterEnabled == GCEnabledType.GameCenterEnabled.rawValue {
            //                self.createLabelsForBestPlace()
        }
        
    }


    var realmHelpInfo: Realm?
    #if DEBUG
    @objc private func developerMenuChoosed() {
        initiateHelpModel()
        let countContinueGames = realmHelpInfo!.objects(HelpInfo.self).filter("language = %@", GV.actLanguage).count

        let alertController = UIAlertController(title: GV.language.getText(.tcDeveloperMenu),
                                            message: "",
                                            preferredStyle: .alert)
        
        if GV.connectedToInternet && GKLocalPlayer.local.isAuthenticated {
            showGlobalDataAction = UIAlertAction(title: GV.language.getText(.tcShowRealmCloud), style: .default, handler: { [unowned self]
                alert -> Void in
                self.displayGameCenterViewController()
            })
            alertController.addAction(showGlobalDataAction!)
        }
        let showGameCenterAction = UIAlertAction(title: GV.language.getText(.tcShowGameCenter), style: .default, handler: { [unowned self]
            alert -> Void in
                let gcVC = GKGameCenterViewController()
                gcVC.gameCenterDelegate = self
                gcVC.viewState = .leaderboards
                gcVC.leaderboardIdentifier = "myDevice"
                self.present(gcVC, animated: true, completion: nil)
        })
        alertController.addAction(showGameCenterAction)
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
        //--------------------- GameCenter on / off ---------------------
//        var GCTitle = ""
//        var chooseGCAction: UIAlertAction
//        if GCHelper.shared.authenticateStatus == GCHelper.AuthenticatingStatus.authenticated {
//            GCTitle = GV.language.getText(.tcDisconnectGC)
//            chooseGCAction = UIAlertAction(title: GCTitle, style: .default, handler: { /*[unowned self]*/
//                alert -> Void in
//                GCHelper.shared.authenticateStatus = .notAuthenticated
//                try! realm.safeWrite() {
//                    GV.basicDataRecord.GameCenterEnabled = GCEnabledType.GameCenterSupressed.rawValue
//                }
//                self.showMenu()
//            })
//        } else {
//            GCTitle = GV.language.getText(.tcConnectGC)
//            chooseGCAction = UIAlertAction(title: GCTitle, style: .default, handler: { [unowned self]
//                alert -> Void in
//                GCHelper.shared.authenticateLocalUser(theDelegate: self, presentingViewController: self)
//            })
//        }
//        myAlertController.addAction(chooseGCAction)
       //--------------------- showHelpAction ---------------------
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
//        getRecordCounts()
        GCHelper.shared.getBestScore(completion: {})
//        GCHelper.shared.getAllScores(completion: {})
//        self.showMenu()
    }
    
//    private func chooseDifficulty() {
//        var currentDifficultyString = ""
//        switch GV.basicDataRecord.difficulty {
//        case GameDifficulty.Easy.rawValue:      currentDifficultyString = GV.language.getText(.tcSimpleGame)
//        case GameDifficulty.Medium.rawValue:    currentDifficultyString = GV.language.getText(.tcMediumGame)
//        case GameDifficulty.Hard.rawValue:      currentDifficultyString = GV.language.getText(.tcHardGame)
//        case GameDifficulty.VeryHard.rawValue:  currentDifficultyString = GV.language.getText(.tcVeryHardGame)
//        default: break
//        }
//
//        let alertController = UIAlertController(title: GV.language.getText(.tcChooseDifficulty),
//                                                message: "", //GV.language.getText(.tcCurrentDifficulty, values: currentDifficultyString),
//                                                preferredStyle: .alert)
//        let simpleGameAction = UIAlertAction(title: GV.language.getText(.tcSimpleGame), style: .default, handler: {
//            alert -> Void in
//            self.setDifficulty(difficulty: .Easy)
//        })
//        alertController.addAction(simpleGameAction)
//
//        let hardGameAction = UIAlertAction(title: GV.language.getText(.tcMediumGame), style: .default, handler: {
//            alert -> Void in
//            self.setDifficulty(difficulty: .Medium)
//        })
//        alertController.addAction(hardGameAction)
//
//        let cancelAction =  UIAlertAction(title: GV.language.getText(.tcCancel), style: .default, handler: { [unowned self]
//            alert -> Void in
//            self.showMenu()
//        })
//        alertController.addAction(cancelAction)
//
//        present(alertController, animated: true, completion: nil)
//
//
//    }
    
    private func generateBasicDataRecordIfNeeded() {
        func createScoreInfo() {
            try! realm.safeWrite() {
                for _ in 0...3 {
                    let difficultyInfo = ScoreInfoForDifficulty()
                    GV.basicDataRecord.scoreInfos.append(difficultyInfo)
                }
            }
        }
        
        if realm.objects(BasicDataModel.self).count == 0 {
//            minden GC-her felküldött paramétert 10 jegyü timeintervallal kezdeni, hogy ne legyenek azonos értékek!
//            ezt a sendGlobalInfos modul intézze, a leszedést is!
//            let myName = GV.language.getText(.tcPlayer)
            GV.basicDataRecord = BasicDataModel()
            GV.basicDataRecord.actLanguage = GV.language.getText(.tcAktLanguage)
            GV.basicDataRecord.creationTime = Date()
            GV.basicDataRecord.deviceType = UIDevice().getModelCode()
            GV.basicDataRecord.land = GV.convertLocaleToInt()
            GV.basicDataRecord.lastPlayingDay = Date().yearMonthDay

            try! realm.safeWrite() {
                realm.add(GV.basicDataRecord)
            }
            createScoreInfo()
        } else {
            GV.basicDataRecord = realm.objects(BasicDataModel.self).first!
            GV.language.setLanguage(GV.basicDataRecord.actLanguage)
            if GV.basicDataRecord.scoreInfos.count == 0 {
                createScoreInfo()
            }
            if GV.basicDataRecord.deviceType == 0 {
                try! realm.safeWrite() {
                    GV.basicDataRecord.deviceType = UIDevice().getModelCode()
                    GV.basicDataRecord.land = GV.convertLocaleToInt()
                }
            }
            if Date().yearMonthDay != GV.basicDataRecord.lastPlayingDay {
                try! realm.safeWrite() {
                    GV.basicDataRecord.lastPlayingDay = Date().yearMonthDay
                    GV.basicDataRecord.playingTimeToday = 0
                    GV.basicDataRecord.countPlaysToday = 0
                }
            }
       }

        GV.minGameNumber = GV.basicDataRecord.difficulty * 1000
        GV.maxGameNumber = GV.minGameNumber + 999
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
