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
import CloudKit
//import SCLAlertView

class MainViewController: UIViewController, /*WelcomeSceneDelegate, */WTSceneDelegate, GCHelperDelegate, ShowGamesSceneDelegate, GKGameCenterControllerDelegate,  ShowGameCenterViewControllerDelegate,
ShowNewWordsInCloudSceneDelegate {
    func backFromShowGameCenterViewController() {
        showMenu()
    }
    
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
        let alertController = UIAlertController(title: GV.language.getText(.tcLocalPlayerNotAuth),
                                                message: "",
                                                preferredStyle: .alert)
        let OKAction = UIAlertAction(title: GV.language.getText(.tcOK), style: .default, handler:  { [unowned self]
            alert -> Void in
                self.showMenu()
        })
        alertController.addAction(OKAction)
        present(alertController, animated: true, completion: nil)
        if showGamesScene != nil {
            showGamesScene!.goBack()
        }

    }
    
    var tenMinutesTimer: Timer?
    var inMenu = false

    func localPlayerAuthenticated() {
        if GV.basicDataRecord.GameCenterEnabled != GCEnabledType.GameCenterEnabled.rawValue {
            try! realm.safeWrite() {
                GV.basicDataRecord.GameCenterEnabled = GCEnabledType.GameCenterEnabled.rawValue
            }
        }
        GCHelper.shared.getBestScore(completion: {
            self.callModifyHeader()
        })
        tenMinutesTimer = Timer.scheduledTimer(timeInterval: 0.0, target: self, selector: #selector(tenMinutesTimer(timerX: )), userInfo: nil, repeats: false)
        


//        if GV.wtScene == nil {
//            showMenu()
//        } else {
//            if !inMenu {
//                startGame()
//            }
//        }
    }
    
    
    
    func callModifyHeader() {
//        if animationScene != nil {
//            return
//        }
        if GV.wtScene != nil {
            GV.wtScene!.modifyHeader()
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

    #if DEBUG
    func displayGameCenterViewController(dataSource: DataSource) {
        let gameCenterViewController = ShowGameCenterViewController()
        gameCenterViewController.myDelegate = self
        gameCenterViewController.modalPresentationStyle = .overFullScreen
        gameCenterViewController.setDataSource(dataSource: dataSource)
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
        showGamesScene!.setDelegate(delegate: self)
//        showGamesScene!.setSelect(all: all)
        if let view = self.view as! SKView? {
            view.presentScene(showGamesScene!)
        }
    }
    
    func gameFinished(start: StartType) {
        GV.playing = false
//        GV.generateHelpInfo = false
        if let view = self.view as! SKView? {
            view.presentScene(nil)
            wtSceneStarted = false
        }
        changeBackgroundPicture()
        switch start {
        case .NoMore: showMenu() //startMenuScene(showMenu: true)
        case .PreviousGame, .NextGame: startWTScene(new: false, next: start, gameNumber: 0)
        case .NewGame: startWTScene(new: true, next: .NoMore, gameNumber: 0)
        case .GameNumber: startWTScene(new: true, next: .NoMore, gameNumber: 0)
//        case .SetEasy:
//            setDifficulty(difficulty: .Easy)
//            startWTScene(new: false, next: .NoMore, gameNumber: 0)
//        case .SetMedium:
//            setDifficulty(difficulty: .Medium)
//            startWTScene(new: false, next: .NoMore, gameNumber: 0)
        default: break
        }
    }
    
    func wtGame() {
        startWTScene(new: true, next: .NoMore, gameNumber: 0)
    }
    
    override var shouldAutorotate: Bool {
        return true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .portrait
        } else {
            return .all
        }
    }

    override var prefersStatusBarHidden: Bool {
        return false
    }
    
    func findWords() {
        print("Search Words choosed")
    }
    
    func cancelChooeseGameType() {
        print("cancel choosed")
        showMenu()
//        startMenuScene()
    }
    var wtSceneStarted = false
    
    func startWTScene(new: Bool, next: StartType, gameNumber: Int, restart: Bool = false, showHelp: Bool = false) {
//        wtScene = WTScene(size: CGSize(width: view.frame.width, height: view.frame.height))
        if let view = self.view as! SKView? {
//            if !wtSceneStarted {
                GV.wtScene!.setDelegate(delegate: self)
                GV.wtScene!.setGameArt(new: new, next: next, gameNumber: gameNumber, restart: restart)
                GV.wtScene!.parentViewController = self
                view.presentScene(GV.wtScene!)
                wtSceneStarted = true
//            }
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
        let actGame = realm.objects(GameDataModel.self).filter("language = %d and gameType = %d and sizeOfGrid = %d",GV.actLanguage, GV.gameType.rawValue, GV.sizeOfGrid)
        try! realm.safeWrite {
            GV.basicDataRecord.difficulty = GV.gameType.rawValue
            GV.basicDataRecord.sizeOfGrid = GV.sizeOfGrid
        }
        if actGame.isEmpty {
            let gameNumber = GV.basicDataRecord.difficulty * 1000
            startWTScene(new: true, next: .NoMore, gameNumber: gameNumber)
        } else {
            let gameNumber = actGame.first!.gameNumber
            GV.comeBackFromSleeping = false
            startWTScene(new: false, next: .NoMore, gameNumber: gameNumber)
//            }
        }
    }
    
    func chooseGame() {


        alertController = UIAlertController(title: GV.language.getText(.tcChooseAction),
                                            message: "",
                                            preferredStyle: .alert)
        
        //--------------------- StartGameAction ---------------------
        let collectWordsAction = UIAlertAction(title: "\(GV.language.getText(.tcEasyPlay)) ", style: .default, handler: { [unowned self]
            alert -> Void in
            self.inMenu = false
            GV.gameType = .CollectWords
            self.chooseGameSize()
        })
        alertController!.addAction(collectWordsAction)
        //--------------------- Choose Game Type ---------------------
        let fixLettersAction = UIAlertAction(title: "\(GV.language.getText(.tcMediumPlay)) ", style: .default, handler: { [unowned self]
            alert -> Void in
            self.inMenu = false
            GV.gameType = .FixLetter
            self.chooseGameSize()
        })
        alertController!.addAction(fixLettersAction)
        let searchWordsAction = UIAlertAction(title: "\(GV.language.getText(.tcSearchWords)) ", style: .default, handler: { [unowned self]
            alert -> Void in
            self.inMenu = false
            GV.gameType = .SearchWords
            self.chooseGameSize()
        })
        alertController!.addAction(searchWordsAction)

        let cancelAction = UIAlertAction(title: GV.language.getText(.tcCancel), style: .default, handler: {
            alert -> Void in
            self.showMenu()
        })
        alertController!.addAction(cancelAction)
        present(alertController!, animated: true, completion: nil)
        
    }
    
    private func chooseGameSize() {
        alertController = UIAlertController(title: GV.language.getText(.tcChooseGameSize),
                                            message: "",
                                            preferredStyle: .alert)
        
        //--------------------- 5 x 5 ---------------------
        let choose5x5Action = UIAlertAction(title: "5x5", style: .default, handler: { [unowned self]
            alert -> Void in
            self.inMenu = false
            GV.sizeOfGrid = 5
            self.startGame()
        })
        alertController!.addAction(choose5x5Action)
        //--------------------- 6 x 6  ---------------------
        let choose6x6Action = UIAlertAction(title: "6x6", style: .default, handler: { [unowned self]
            alert -> Void in
            self.inMenu = false
            GV.sizeOfGrid = 6
            self.startGame()
        })
        alertController!.addAction(choose6x6Action)
        //--------------------- 7 x 7  ---------------------
        let choose7x7Action = UIAlertAction(title: "7x7", style: .default, handler: { [unowned self]
            alert -> Void in
            self.inMenu = false
            GV.sizeOfGrid = 7
            self.startGame()
        })
        alertController!.addAction(choose7x7Action)
        
        //--------------------- 8 x 8  ---------------------
        let choose8x8Action = UIAlertAction(title: "8x8", style: .default, handler: { [unowned self]
            alert -> Void in
            self.inMenu = false
            GV.sizeOfGrid = 8
            self.startGame()
        })
        alertController!.addAction(choose8x8Action)
        
        //--------------------- 9 x 9  ---------------------
        let choose9x9Action = UIAlertAction(title: "9x9", style: .default, handler: { [unowned self]
            alert -> Void in
            self.inMenu = false
            GV.sizeOfGrid = 9
            self.startGame()
        })
        alertController!.addAction(choose9x9Action)
        
        //--------------------- 10 x 10  ---------------------
        let choose10x10Action = UIAlertAction(title: "10x10", style: .default, handler: { [unowned self]
            alert -> Void in
            self.inMenu = false
            GV.sizeOfGrid = 10
            self.startGame()
        })
        alertController!.addAction(choose10x10Action)
        if GV.onIpad {
            //--------------------- 11 x 11  ---------------------
            let choose11x11Action = UIAlertAction(title: "11x11", style: .default, handler: { [unowned self]
                alert -> Void in
                self.inMenu = false
                GV.sizeOfGrid = 11
                self.startGame()
            })
            alertController!.addAction(choose11x11Action)
            
            //--------------------- 12 x 12  ---------------------
            let choose12x12Action = UIAlertAction(title: "12x12", style: .default, handler: { [unowned self]
                alert -> Void in
                self.inMenu = false
                GV.sizeOfGrid = 12
                self.startGame()
            })
            alertController!.addAction(choose12x12Action)
            
            //--------------------- 13 x 13  ---------------------
            let choose13x13Action = UIAlertAction(title: "13x13", style: .default, handler: { [unowned self]
                alert -> Void in
                self.inMenu = false
                GV.sizeOfGrid = 13
                self.startGame()
            })
            alertController!.addAction(choose13x13Action)
            
            //--------------------- 14 x 14  ---------------------
            let choose14x14Action = UIAlertAction(title: "14x14", style: .default, handler: { [unowned self]
                alert -> Void in
                self.inMenu = false
                GV.sizeOfGrid = 14
                self.startGame()
            })
            alertController!.addAction(choose14x14Action)
            
            //--------------------- 15 x 15  ---------------------
            let choose15x15Action = UIAlertAction(title: "15x15", style: .default, handler: { [unowned self]
                alert -> Void in
                self.inMenu = false
                GV.sizeOfGrid = 15
                self.startGame()
            })
            alertController!.addAction(choose15x15Action)
        }
        let cancelAction = UIAlertAction(title: GV.language.getText(.tcCancel), style: .default, handler: {
            alert -> Void in
            self.showMenu()
        })
        alertController!.addAction(cancelAction)
        present(alertController!, animated: true, completion: nil)
    }
    

    func chooseLanguage() {
        func setLanguage(language: String) {
            GV.language.setLanguage(language)
            try! realm.safeWrite() {
                GV.basicDataRecord.actLanguage = language
                GV.basicDataRecord.land = GV.convertLocaleToInt()
            }
            GCHelper.shared.getBestScore(completion: {[unowned self] in
                self.callModifyHeader()
            })
            GCHelper.shared.restartGlobalInfosTimer()
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
    
        var oneMinutesTimer: Timer?
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidLoad()
//        delete temporary files
        let path = NSTemporaryDirectory()
        let subDirs = FileManager().subpaths(atPath: NSTemporaryDirectory())
        for file in subDirs! {
            print("file: \(file)")
            if file.count > 30 {
                do {
                    try FileManager().removeItem(at: URL(fileURLWithPath: path + file))
                }
                catch {
                    print(error)
                }
            }
        }
//        let subDirsAfter = FileManager().subpaths(atPath: NSTemporaryDirectory())
        GV.mainViewController = self
        setDarkMode()
        GV.wtScene = WTScene(size: CGSize(width: view.frame.width, height: view.frame.height))
        GV.actHeight = UIScreen.main.bounds.height //self.view.frame.size.height
        GV.actWidth = UIScreen.main.bounds.width // self.view.frame.size.width
        GV.sizeOfGrid = 10
        changeBackgroundPicture()
        print("\(String(describing: Realm.Configuration.defaultConfiguration.fileURL))")
        if GV.basicDataRecord.actLanguage == "" { //basicDataRecord not loaded yet
            generateBasicDataRecordIfNeeded()
        }
        
        if oneMinutesTimer != nil {
            oneMinutesTimer!.invalidate()
        }
        oneMinutesTimer = Timer.scheduledTimer(timeInterval: 60.0, target: self, selector: #selector(oneMinutesTimer(timerX: )), userInfo: nil, repeats: false)

        convertIfNeeded()
        checkDeviceRecordInCloud()
        checkReportedWordsInCloud()
        checkNewWordsInCloud()
//        checkMyBonusMalus()
        _ = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(waitForInternet(timerX: )), userInfo: nil, repeats: false)
        let lastPlayed = realm.objects(GameDataModel.self).filter("language = %@ and nowPlaying = true",GV.actLanguage).sorted(byKeyPath: "combinedKey", ascending: false)
        switch lastPlayed.count {
        case 0:
            chooseGame()
        default:
            GV.gameType = GameType(rawValue: lastPlayed[0].gameType)!
            GV.sizeOfGrid = lastPlayed[0].sizeOfGrid
        }

    }
    
    private func checkDeviceRecordInCloud() {
        let actPlayingTime = GV.basicDataRecord.playingTime
        let actPlayingTimeToday = GV.basicDataRecord.playingTimeToday

        var deviceRecordID = String(GV.getTimeIntervalSince20190101())
        if GV.basicDataRecord.deviceRecordInCloudID != "" {
            deviceRecordID = GV.basicDataRecord.deviceRecordInCloudID
        } else {
            try! realm.safeWrite {
                GV.basicDataRecord.deviceRecordInCloudID = deviceRecordID
            }
        }

        let recordID = CKRecord.ID(recordName: deviceRecordID)
        let predicate = NSPredicate(format: "recordID = %@", recordID)
        let query = CKQuery(recordType: "DeviceRecord", predicate: predicate)
        let defaultContainer = CKContainer.default()
        defaultContainer.publicCloudDatabase.perform(query, inZoneWith: nil) { results, error in
            if error != nil {
                print("error in checkDeviceRecordInCloud: \(String(describing: error))")
                return
            }
            var deviceRecord = CKRecord(recordType: "DeviceRecord", recordID: recordID)
            if results!.count == 0 {
//                deviceRecord = CKRecord(recordType: "DeviceRecord", recordID: recordID)
                deviceRecord["deviceType"] = UIDevice().convertIntToModelName(value: UIDevice().getModelCode())
                deviceRecord["land"] = Locale.current.regionCode == nil ? "HU" : Locale.current.regionCode
                deviceRecord["language"] = GV.actLanguage
                deviceRecord["playingTime"] = actPlayingTime
                deviceRecord["lastPlayingTime"] = actPlayingTimeToday
                deviceRecord["lastPlayed"] = Date().yearMonthDay
                deviceRecord["version"] = actVersion
                if GKLocalPlayer.local.playerID != "" {
                    deviceRecord["playerID"] = GKLocalPlayer.local.playerID
                } else {
                    deviceRecord["playerID"] = ""
                }
                deviceRecord["actScoreEasy"] = 0
                deviceRecord["bestScoreEasy"] = 0   
                deviceRecord["actScoreMedium"] = 0
                deviceRecord["bestScoreMedium"] = 0
            } else {
                deviceRecord = results![0]
                deviceRecord["playingTime"] = actPlayingTime
                deviceRecord["lastPlayingTime"] = actPlayingTimeToday
                if deviceRecord["lastPlayed"] != Date().yearMonthDay {
                    deviceRecord["lastPlayed"] = Date().yearMonthDay
                }
                
                if deviceRecord["playerID"] == "" && GKLocalPlayer.local.playerID != "" {
                    deviceRecord["playerID"] = GKLocalPlayer.local.playerID
                }
                deviceRecord["land"] = Locale.current.regionCode == nil ? "HU" : Locale.current.regionCode
                deviceRecord["language"] = GV.actLanguage
                deviceRecord["version"] = actVersion
            }
            defaultContainer.publicCloudDatabase.save(deviceRecord) {
                (record, error) in
                if let error = error {
                    // Insert error handling
                    print("Error by save: \(error)")
                    return
                }
            }
        }

    }
    
    private func checkReportedWordsInCloud() {
        let today = Date()
        let weekAgo = Calendar.current.date(byAdding: .day, value: -1, to: today)!
        let waitingWords = realm.objects(MyReportedWords.self).filter("status = %@ and modifiedAt < %@", GV.waiting, weekAgo)
        if waitingWords.count > 0 {
            try! realm.safeWrite {
                realm.delete(waitingWords)
            }
        }
        let deniedWords = realm.objects(MyReportedWords.self).filter("status = %@", GV.denied)
        if deniedWords.count > 0 {
            for deniedWord in deniedWords {
                let deniedWordID = deniedWord.ID
                let IDInCloud = CKRecord.ID(recordName: deniedWord.ID)
                let container = CKContainer.default()
                container.publicCloudDatabase.delete(withRecordID: IDInCloud) { (recordID, error) in
                        guard let recordID = recordID else {
                        let realm = try! Realm(configuration: Realm.Configuration.defaultConfiguration)
                        let recordToDelete = realm.objects(MyReportedWords.self).filter("ID = %@", deniedWordID)
                        try! realm.safeWrite {
                            realm.delete(recordToDelete)
                        }
                            return
                    }
                    print("Record \(recordID) was successfully deleted")
                    let realm = try! Realm(configuration: Realm.Configuration.defaultConfiguration)
                    let recordToDelete = realm.objects(MyReportedWords.self).filter("ID = %@", deniedWordID)
                    try! realm.safeWrite {
                        realm.delete(recordToDelete)
                    }
                }
            }
        }
        let pendingWords = realm.objects(MyReportedWords.self).filter("status = %@", GV.pending)
        if pendingWords.count > 0 {
            let pendingWord = pendingWords.first!
//            let actWord = pendingWord.word
//            let actBonus = pendingWord.bonus
            let IDInCloud = CKRecord.ID(recordName: pendingWord.ID)
            let pendingWordID = pendingWord.ID
            let predicate = NSPredicate(format: "recordID = %@", IDInCloud)
            let query = CKQuery(recordType: "NewWords", predicate: predicate)
            let container = CKContainer.default()
            container.publicCloudDatabase.perform(query, inZoneWith: nil) { results, error in
                print("count: \(results!.count)")
                if results!.count > 0 {
                    switch results![0].object(forKey: "status") as! String {
                    case GV.accepted:
                        let realm = try! Realm(configuration: Realm.Configuration.defaultConfiguration)
                        let actPendingWord = realm.objects(MyReportedWords.self).filter("ID = %@", pendingWordID)[0]
                        try! realm.safeWrite {
                            actPendingWord.status = GV.accepted
                        }
//                        self.checkMyBonusMalus()
                        let title = GV.language.getText(.tcAcceptedReport, values: String(actPendingWord.word.endingSubString(at: 2).uppercased()))
                        let message = GV.language.getText(.tcAcceptedDescription, values: String(actPendingWord.bonus))
                        let alertController = UIAlertController(title: title,
                                                            message: message,
                                                            preferredStyle: .alert)
                        
                        let acceptedAction = UIAlertAction(title: "\(GV.language.getText(.tcOK)) ", style: .default, handler: {
                            alert -> Void in
                        })
                        alertController.addAction(acceptedAction)
                        DispatchQueue.main.async {
                            self.present(alertController, animated: true, completion: nil)
                        }
                    case GV.pending:
                        print("pending - wait for Developer")
                    case GV.denied:
                        let realm = try! Realm(configuration: Realm.Configuration.defaultConfiguration)
                        let actPendingWord = realm.objects(MyReportedWords.self).filter("ID = %@", pendingWordID)[0]
                        try! realm.safeWrite {
                            actPendingWord.status = GV.denied
                        }
//                        self.checkMyBonusMalus()
                        let title = GV.language.getText(.tcDeniedReport, values: String(actPendingWord.word.endingSubString(at: 2)))
                        let message = GV.language.getText(.tcDeniedDescription)
                        let alertController = UIAlertController(title: title,
                                                            message: message,
                                                            preferredStyle: .alert)
                        
                        let deniedAction = UIAlertAction(title: "\(GV.language.getText(.tcOK)) ", style: .default, handler: {
                            alert -> Void in
                        })
                        alertController.addAction(deniedAction)
                        DispatchQueue.main.async {
                            self.present(alertController, animated: true, completion: nil)
                        }

                    default:
                        print("nothing to do")
                    }
                } else {
                    print("record in Cloud not found! - delete: \(IDInCloud)")
                }
            }
        }
    }
    
    @objc private func alertOK() {
        
    }
    
    private func checkNewWordsInCloud() {
        var lastTimeStamp = Date()
        if realm.objects(WordsFromCloud.self).sorted(byKeyPath: "timeStamp", ascending: false).count > 0 {
            lastTimeStamp = realm.objects(WordsFromCloud.self).sorted(byKeyPath: "timeStamp", ascending: false).first!.timeStamp
        } else {
            lastTimeStamp = Date(year: 2020, month: 1, day: 1, hour: 0, minute: 1)
        }
        let predicate = NSPredicate(format: "status = %@ and lastChanged > %@", GV.accepted, lastTimeStamp as NSDate)
        let query = CKQuery(recordType: "NewWords", predicate: predicate)
        let container = CKContainer.default()
        container.publicCloudDatabase.perform(query, inZoneWith: nil) { results, error in
             if results!.count > 0 {
                for result in results! {
                    if result.modificationDate! > lastTimeStamp {
                        let language = result.object(forKey: "language") as! String
                        let word = result.object(forKey: "word") as! String
                        let modified = result.object(forKey: "lastChanged")
                        let recordToSave = WordsFromCloud()
                        recordToSave.word = language + word
                        recordToSave.timeStamp = modified as! Date
                        let realm = try! Realm(configuration: Realm.Configuration.defaultConfiguration)
                        try! realm.safeWrite {
                            realm.add(recordToSave)
                        }
                    }
                }
            }
        }
    }
    @objc private func oneMinutesTimer(timerX: Timer) {
//        print("oneMinutesTimer actTime: \(Date())")
        try! realm.safeWrite() {
            GV.basicDataRecord.playingTime += 1
            GV.basicDataRecord.playingTimeToday += 1
        }
        if oneMinutesTimer != nil {
            oneMinutesTimer!.invalidate()
        }
        oneMinutesTimer = Timer.scheduledTimer(timeInterval: 60.0, target: self, selector: #selector(oneMinutesTimer(timerX: )), userInfo: nil, repeats: false)
    }
    
    @objc private func tenMinutesTimer(timerX: Timer) {
        checkDeviceRecordInCloud()
        tenMinutesTimer = Timer.scheduledTimer(timeInterval: 600.0, target: self, selector: #selector(tenMinutesTimer(timerX: )), userInfo: nil, repeats: false)
    }
    
    @objc private func waitForInternet(timerX: Timer) {
        if GV.basicDataRecord.GameCenterEnabled == GCEnabledType.AskForGameCenter.rawValue && GV.connectedToInternet {
            manageGameCenter()
        } else {
            startDemoOrMenu()
            startWTScene(new: false, next: .NoMore, gameNumber: 0)
        }
    }
    
    private func convertIfNeeded() {
//        var bestScore = 0
//        var bestScoreIndex = 0
        var dayAdder = 1
        let allRecords = realm.objects(GameDataModel.self).filter("recordVersion = %d", 0)
        if allRecords.count == 0 {
            return
        }
        for languageIndex in 0...3 {
            let language = GV.IntToLanguage[languageIndex]
            for difficulty in GameType.CollectWords.rawValue...GameType.SearchWords.rawValue {
                let minGameNumber = difficulty * 1000
                let maxGameNumber = minGameNumber + 999
                let myPlayingRecords = allRecords.filter("language = %@ and combinedKey BEGINSWITH %@ and gameNumber >= %d and gameNumber <= %d", language!, language!, minGameNumber, maxGameNumber)
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

        for record in allRecords {
            try! realm.safeWrite {
                if record.gameType == -1 {
                    realm.delete(record)
                } else {
                    if record.gameNumber < 1000 {
                        record.gameType = GameType.CollectWords.rawValue
                    } else {
                        record.gameType = GameType.FixLetter.rawValue
                    }
                    if record.combinedKey.toDate() != record.created {
                        record.created = record.combinedKey.toDate()
                    }
                    if record.lastPlayed == nil {
                        record.lastPlayed = record.combinedKey.toDate()
                    }
                    record.sizeOfGrid = GV.sizeOfGridValue[record.rounds.first!.gameArray.count]!
                    record.recordVersion = 1
                }
            }

        }
        
    }
    
    @objc private func startDemoOrMenu() {
//        if !GV.basicDataRecord.startAnimationShown {
//            startWelcomeScene()
//        } else {
            if GV.basicDataRecord.GameCenterEnabled == GCEnabledType.GameCenterEnabled.rawValue && GCHelper.shared.authenticateStatus != GCHelper.AuthenticatingStatus.authenticated && GV.connectedToInternet {
                    GCHelper.shared.authenticateLocalUser(theDelegate: self, presentingViewController: self)
                _ = Timer.scheduledTimer(timeInterval: 5.0, target: self, selector: #selector(startPlaying(timerX: )), userInfo: nil, repeats: false)

                return
            }
//            if countContinueGames > 0 {
            startWTScene(new: false, next: .NoMore, gameNumber: 0)
//            } else {
//                showMenu()
//            }
//        }
    }
    
    @objc func startPlaying(timerX: Timer) {
        if GCHelper.shared.authenticateStatus != GCHelper.AuthenticatingStatus.authenticated {
            startWTScene(new: false, next: .NoMore, gameNumber: 0)
        }
    }
    
//    var animationScene: WelcomeScene?

//    @objc private func startWelcomeScene() {
//        animationScene = WelcomeScene(size: CGSize(width: view.frame.width, height: view.frame.height))
//        if let view = self.view as! SKView? {
//            animationScene!.setDelegate(delegate: self)
//            //                wtScene.setGameArt(new: new, next: next, gameNumber: gameNumber, restart: restart)
//            //                wtScene.parentViewController = self
//            view.presentScene(animationScene!)
//        }
//    }
    
    @objc private func firstButton () {
        print("firstButton tapped")
    }
    
    
    private func changeBackgroundPicture() {

            let uiImage = UIImage(named: GV.actHeight > GV.actWidth ? "backgroundP.png" : "backgroundL.png")
            
            // Get image width and height.
            let imageWidth:CGFloat = GV.actWidth
                
            let imageHeight:CGFloat = GV.actHeight
            
            // Calculate the image view's top left point's x axis position value.
            let xPos = 0
            let yPos = 0
            
            // Create a CGRect object to render the image.
            let imageFrame: CGRect = CGRect(x:CGFloat(xPos), y:CGFloat(yPos), width:imageWidth, height:imageHeight)
            
            // Create a UIView object which use above CGRect object.
            let imageView = UIView(frame: imageFrame)
            
            // Create a UIColor object which use above UIImage object.
            let backgroundColor = UIColor(patternImage: uiImage!)
            
            // Set above image as UIView's background.
            imageView.backgroundColor = backgroundColor
            
            // Add above UIView object as the main view's subview.
        if self.view.subviews.count == 0 {
            self.view.addSubview(imageView)
        } else {
            self.view.subviews[0].removeFromSuperview()
            self.view.insertSubview(imageView, at: 0)
        }

    }
    let callerName = "MainViewController"
    ////
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        GV.deviceHasNotch = UIApplication.shared.hasNotch
        NotificationCenter.default.addObserver(self, selector: #selector(deviceRotated), name: UIDevice.orientationDidChangeNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(reachabilityChanged(note:)), name: .reachabilityChanged, object: reachability)
        do {
            try reachability!.startNotifier()
        }catch{
            print("could not start reachability notifier")
        }
    }
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self, name: UIDevice.orientationDidChangeNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: .reachabilityChanged, object: nil)
    }


    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        GV.actWidth = size.width
        GV.actHeight = size.height
        GV.deviceOrientation = GV.actWidth > GV.actHeight ? .Landscape : .Portrait
//        print("in viewWillTransition ---- to Size: \(size)---------- \(getDeviceOrientation()) at \(Date())")
        if GV.orientationHandler != nil && GV.target != nil {
            _ = GV.target!.perform(GV.orientationHandler!)
        }
    }
    
    @objc func deviceRotated() {
//        showBackgroundPicture()
        if GV.orientationHandler != nil && GV.target != nil {
            _ = GV.target!.perform(GV.orientationHandler!)
        } else {
            changeBackgroundPicture()
        }
    }
    

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
        case .unavailable:
            GV.connectedToInternet = false
        }
        if oldConnectedToInternet != GV.connectedToInternet {
            if GV.connectedToInternet {
                if GV.basicDataRecord.actLanguage == "" { // BsiacDataRecord not loaded yet
                    generateBasicDataRecordIfNeeded()
                }
//                if animationScene != nil {
//                    _ = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(waitForAnimationsSceneFinishing(timerX: )), userInfo: nil, repeats: false)
//                } else
                if GV.basicDataRecord.GameCenterEnabled == GCEnabledType.GameCenterEnabled.rawValue {
                    GCHelper.shared.authenticateLocalUser(theDelegate: self, presentingViewController: self)
                } else if GV.basicDataRecord.GameCenterEnabled == GCEnabledType.AskForGameCenter.rawValue {
                    manageGameCenter()
                }
            } else {
                
            }
            oldConnectedToInternet = GV.connectedToInternet
        }
    }
    
//    @objc private func waitForAnimationsSceneFinishing(timerX: Timer) {
//        if animationScene != nil || GV.wtScene != nil {
//            _ = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(waitForAnimationsSceneFinishing(timerX: )), userInfo: nil, repeats: false)
//        } else if GV.basicDataRecord.GameCenterEnabled == GCEnabledType.GameCenterEnabled.rawValue {
//            GCHelper.shared.authenticateLocalUser(theDelegate: self, presentingViewController: self)
//        } else if GV.basicDataRecord.GameCenterEnabled == GCEnabledType.AskForGameCenter.rawValue {
//            manageGameCenter()
//        }
//    }
//
    var alertController: UIAlertController?
    var nickNameAction: UIAlertAction?
    var collectMandatoryAction: UIAlertAction?

    #if DEBUG
    var showGlobalDataAction: UIAlertAction?
    var createMandatoryAction: UIAlertAction?
    #endif
    
    public func setDarkMode() {
        GV.darkMode = false
        if #available(iOS 12.0, *) {
            GV.darkMode = traitCollection.userInterfaceStyle == .dark ? true : false
        }
    }
    


    
    func showMenu() {
        if GV.playing {
            return
        }
        
        alertController = UIAlertController(title: GV.language.getText(.tcChooseAction),
                                            message: "",
                                            preferredStyle: .alert)
        
        //--------------------- StartGameAction ---------------------
        let startGameAction = UIAlertAction(title: "\(GV.language.getText(.tcStartGame)) ", style: .default, handler: { [unowned self]
            alert -> Void in
            self.inMenu = false
                self.startGame()
        })
        alertController!.addAction(startGameAction)
        //--------------------- Choose Game Type ---------------------
        let chooseGameAction = UIAlertAction(title: "\(GV.language.getText(.tcChooseGame)) ", style: .default, handler: { [unowned self]
            alert -> Void in
            self.inMenu = false
                self.chooseGame()
        })
        alertController!.addAction(chooseGameAction)
        //--------------------- bestScoreAction ---------------------
        let bestScoreAction = UIAlertAction(title: GV.language.getText(.tcBestScore), style: .default, handler: { [unowned self]
            alert -> Void in
            self.inMenu = false
            self.showGames(all: true)
        })
        if GV.connectedToInternet && GKLocalPlayer.local.isAuthenticated /* && GV.basicDataRecord.GameCenterEnabled == GCEnabledType.GameCenterEnabled.rawValue*/ {
            alertController!.addAction(bestScoreAction)
        }
        //--------------------- chooseLanguageAction ---------------------
        let chooseLanguageAction = UIAlertAction(title: GV.language.getText(.tcChooseLanguage), style: .default, handler: { [unowned self]
            alert -> Void in
            self.inMenu = false
            self.chooseLanguage()
        })
        alertController!.addAction(chooseLanguageAction)
        //--------------------- showHelpAction ---------------------
//        let showHelpAction = UIAlertAction(title: GV.language.getText(.tcShowHelp), style: .default, handler: { [unowned self]
//            alert -> Void in
//            //            self.showHowToPlay()
//            self.inMenu = false
//            self.startWelcomeScene()
//        })
//        inMenu = true
//        alertController!.addAction(showHelpAction)

// --------------------- Show GameCenter Question ---------------------
        if GV.basicDataRecord.GameCenterEnabled == GCEnabledType.GameCenterSupressed.rawValue {
            let askForGameCenterAction = UIAlertAction(title: GV.language.getText(.tcConnectGC), style: .default, handler: { [unowned self]
                alert -> Void in
                    if GCHelper.shared.authenticateStatus == GCHelper.AuthenticatingStatus.notAuthenticated {
                        GCHelper.shared.authenticateLocalUser(theDelegate: self, presentingViewController: self)
                    }
                self.inMenu = false
                self.showMenu()
            })
            inMenu = true
            alertController!.addAction(askForGameCenterAction)
        }
//        var GCTitle = ""
//        var chooseGCAction: UIAlertAction
//        if GCHelper.shared.authenticateStatus != GCHelper.AuthenticatingStatus.authenticated {
//            GCTitle = GV.language.getText(.tcConnectGC)
//            chooseGCAction = UIAlertAction(title: GCTitle, style: .default, handler: { [unowned self]
//                alert -> Void in
//                GCHelper.shared.authenticateLocalUser(theDelegate: self, presentingViewController: self)
//            })
//            alertController!.addAction(chooseGCAction)
//       }

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
//        initiateHelpModel()
//        let countContinueGames = realmHelpInfo!.objects(HelpInfo.self).filter("language = %@", GV.actLanguage).count

        let alertController = UIAlertController(title: GV.language.getText(.tcDeveloperMenu),
                                            message: "",
                                            preferredStyle: .alert)
        
        if GV.connectedToInternet && GKLocalPlayer.local.isAuthenticated {
            showGlobalDataAction = UIAlertAction(title: GV.language.getText(.tcShowRealmCloud), style: .default, handler: { [unowned self]
                alert -> Void in
                self.displayGameCenterViewController(dataSource: .GameCenter)
            })
            alertController.addAction(showGlobalDataAction!)
        }
        let showCloudDataAction = UIAlertAction(title: GV.language.getText(.tcShowCloudData), style: .default, handler: { [unowned self]
            alert -> Void in
            self.displayGameCenterViewController(dataSource: .ICloud)
        })
        alertController.addAction(showCloudDataAction)
        
        let showGameCenterAction = UIAlertAction(title: GV.language.getText(.tcShowGameCenter), style: .default, handler: { [unowned self]
            alert -> Void in
                let gcVC = GKGameCenterViewController()
                gcVC.gameCenterDelegate = self
                gcVC.viewState = .leaderboards
                gcVC.leaderboardIdentifier = "myDevice"
                self.present(gcVC, animated: true, completion: nil)
        })
        alertController.addAction(showGameCenterAction)
        let showSavedWordsInCloudAction = UIAlertAction(title: GV.language.getText(.tcShowWordReports), style: .default, handler: { [unowned self]
            alert -> Void in
            self.startShowNewWordsInCloudScene()
        })
        alertController.addAction(showSavedWordsInCloudAction)

        let cancelAction = UIAlertAction(title: GV.language.getText(.tcCancel), style: .default, handler: { [unowned self]
            alert -> Void in
            self.showMenu()
        })
        alertController.addAction(cancelAction)

        present(alertController, animated: true, completion: nil)

    }
    
    var showNewWordsInCloudScene: ShowNewWordsInCloudScene?
    private func startShowNewWordsInCloudScene() {
        showNewWordsInCloudScene = ShowNewWordsInCloudScene(size: CGSize(width: view.frame.width, height: view.frame.height))
        showNewWordsInCloudScene?.setDelegate(delegate: self)
        if let view = self.view as! SKView? {
            view.presentScene(showNewWordsInCloudScene)
        }
    }
    
    
    #endif

    
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
        let cancelAction =  UIAlertAction(title: GV.language.getText(.tcCancel), style: .default, handler: { [unowned self]
            alert -> Void in
            self.showMenu()
        })
        myAlertController.addAction(cancelAction)

        present(myAlertController, animated: true, completion: nil)
    }
    
    private func setGameType(gameType: GameType) {
        try! realm.safeWrite() {
            GV.basicDataRecord.difficulty = gameType.rawValue
        }
        GV.minGameNumber = GV.basicDataRecord.difficulty * 1000
        GV.maxGameNumber = GV.minGameNumber + 999
//        getRecordCounts()
        GCHelper.shared.getBestScore(completion: {self.callModifyHeader()})
//        GCHelper.shared.getAllScores(completion: {})
//        self.showMenu()
    }
    
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
            if GV.basicDataRecord.setMoveModusDuration == 0 {
                try! realm.safeWrite() {
                    GV.basicDataRecord.setMoveModusDuration = 0.5
               }
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
//    private func initiateHelpModel() {
//        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
//        let helpInfoURL = documentsURL.appendingPathComponent("HelpInfo.realm")
//        let config1 = Realm.Configuration(
//            fileURL: helpInfoURL,
//            shouldCompactOnLaunch: { totalBytes, usedBytes in
//                // totalBytes refers to the size of the file on disk in bytes (data + free space)
//                // usedBytes refers to the number of bytes used by data in the file
//                
//                // Compact if the file is over 100MB in size and less than 50% 'used'
//                let oneMB = 10 * 1024 * 1024
//                return (totalBytes > oneMB) && (Double(usedBytes) / Double(totalBytes)) < 0.8
//        },
//            objectTypes: [HelpInfo.self])
//        do {
//            // Realm is compacted on the first open if the configuration block conditions were met.
//            _ = try Realm(configuration: config1)
//        } catch {
//            print("error")
//            // handle error compacting or opening Realm
//        }
//        let helpInfoConfig = Realm.Configuration(
//            fileURL: helpInfoURL,
//            schemaVersion: 0, // new item words
//            // Set the block which will be called automatically when opening a Realm with
//            // a schema version lower than the one set above
//            migrationBlock: { migration, oldSchemaVersion in
//                switch oldSchemaVersion {
////                case 0...3:
////                    migration.deleteData(forType: HelpModel.className())
////                    
//                default: migration.enumerateObjects(ofType: BasicDataModel.className())
//                { oldObject, newObject in
//                    }
//                }
//        },
//            objectTypes: [HelpInfo.self])
//        
//        realmHelpInfo = try! Realm(configuration: helpInfoConfig)
//        
//    }
    
    deinit {
        print("deinit of mainViewController")
    }

}
