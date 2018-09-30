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


class MainViewController: UIViewController, MenuSceneDelegate, WTSceneDelegate, ShowFinishedGamesSceneDelegate, SettingsSceneDelegate {
    func chooseNickname() {
        let alertController = UIAlertController(title: GV.language.getText(.tcSetNickName), message: "", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: GV.language.getText(.tcSave), style: .default, handler: { [unowned self]
            alert -> Void in
            let textField = alertController.textFields![0] as UITextField
            self.setNickname(nickName: textField.text!)
        }))
        alertController.addAction(UIAlertAction(title: GV.language.getText(.tcCancel), style: .cancel, handler: nil))
        alertController.addTextField(configurationHandler: {(textField : UITextField!) -> Void in
            textField.text = playerActivity![0].nickName
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
    
    var showFinishedGamesScene: ShowFinishedGamesScene?
    func backFromSettingsScene() {
    try! realm.write {
        GV.basicDataRecord.actLanguage = GV.aktLanguage
    }

       startMenuScene()
    }
    
    func backToMenuScene() {
        if showFinishedGamesScene != nil {
            showFinishedGamesScene!.removeFromParent()
            showFinishedGamesScene = nil
        }
        startMenuScene()
    }
    
    func showFinishedGames() {
        showFinishedGamesScene = ShowFinishedGamesScene(size: CGSize(width: view.frame.width, height: view.frame.height))
        showFinishedGamesScene!.setDelegate(delegate: self)
        if let view = self.view as! SKView? {
            view.presentScene(showFinishedGamesScene!)
        }
    }
    
    func gameFinished(start: StartType) {
        switch start {
        case .NoMore: startMenuScene(showMenu: true)
        case .PreviousGame, .NextGame: startWTScene(new: false, next: start)
        case .NewGame: startWTScene(new: true, next: .NoMore)
        }
    }
    
    func wtGame() {
        startWTScene(new: true, next: .NoMore)
    }
    
    func findWords() {
        print("Search Words choosed")
    }
    
    func cancelChooeseGameType() {
        print("cancel choosed")
        startMenuScene()
    }
    
    func xxx() {
        return
    }
    
    func startWTScene(new: Bool, next: StartType) {
        let wtScene = WTScene(size: CGSize(width: view.frame.width, height: view.frame.height))
        if let view = self.view as! SKView? {
            wtScene.setDelegate(delegate: self)
            wtScene.setGameArt(new: new, next: next)
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
        startWTScene(new: true, next: .NoMore)
    }
    
    func continueGame() {
        startWTScene(new: false, next: .NoMore)
    }
    
    func startSettings() {
        let settingsScene = SettingsScene(size: CGSize(width: view.frame.width, height: view.frame.height))
        if let view = self.view as! SKView? {
                settingsScene.setDelegate(delegate: self)
            view.presentScene(settingsScene)
        } else {
            continueGame()
        }
    }
    
    override func viewDidLoad() {
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
        startMenuScene()
    }
    
    func startMenuScene(showMenu: Bool = false) {
        let menuScene = MenuScene(size: CGSize(width: view.frame.width, height: view.frame.height))
        if let view = self.view as! SKView? {
            let actGames = realm.objects(GameDataModel.self).filter("nowPlaying = TRUE and language = %@", GV.aktLanguage)
            if showMenu || actGames.count == 0 {
                menuScene.setDelegate(delegate: self)
                view.presentScene(menuScene)
            } else {
                continueGame()
            }
        }
    }
    
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
            loginToRealmSync()
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
    
//    let syncConfig: SyncConfiguration = SyncConfiguration(user: SyncUser.current!, realmURL: GV.REALM_URL)
 //    var realmSync = try! Realm(configuration: Realm.Configuration(syncConfiguration: syncConfig, objectTypes:[BestScoreSync.self, PlayerActivity.self]))
    
//    var countAllPlayerRecords = realmSync.objects(PlayerActivity.self).count

    private func loginToRealmSync() {
        let userName = "magic-of-words-user"
        let password = "@@@" + userName + "@@@"
        let logInCredentials = SyncCredentials.usernamePassword(username: userName, password: password)
        SyncUser.logIn(with: logInCredentials, server: GV.AUTH_URL, timeout: 5) { user, error in
            var user1 = user
            if user1 == nil {  // create a new Account
                let signUpCredentials = SyncCredentials.usernamePassword(username: userName, password: password, register: true)
                SyncUser.logIn(with: signUpCredentials, server: GV.AUTH_URL, timeout: 5) { user, error in
                    if user1 == nil {
                        user1 = SyncUser.current
                        if user1 == nil {
                            print("Error, user couldn't be created")
                        }
                    } else {
                        let logInCredentials = SyncCredentials.usernamePassword(username: userName, password: password)
                        SyncUser.logIn(with: logInCredentials, server: GV.AUTH_URL) { user, error in
                            if user == nil {
                                print("error after register")
                            } else {
                                
                                GV.myUser = user
                                realm.beginWrite()
                                GV.basicDataRecord.myName = userName
                                //                print(textField.text)
                                try! realm.commitWrite()
                                self.setIsOnline()
                                print("OK after register")
                            }
                        }
                    }
                }
            } else {
                print("OK user exists")
                GV.myUser = user
                self.setIsOnline()
            }
        }
    }
    
    func setNickname(nickName: String) {
        if GV.myUser != nil {
            try! realmSync?.write {
                if playerActivity?.count == 0 {
                } else {
                    playerActivity![0].nickName = nickName
                }
            }

        }
    }
    
    func setIsOnline() {
        let syncConfig: SyncConfiguration = SyncConfiguration(user: GV.myUser!, realmURL: GV.REALM_URL)
//        let syncConfig = SyncUser.current!.configuration(realmURL: GV.REALM_URL, user: GV.myUser!)
//        let config = SyncUser.current!.configuration(realmURL: GV.REALM_URL, fullSynchronization: false, enableSSLValidation: true, urlPrefix: nil)
        let config = Realm.Configuration(syncConfiguration: syncConfig, objectTypes: [BestScoreSync.self, PlayerActivity.self])
        realmSync = try! Realm(configuration: config)
        if playerActivity == nil {
            playerActivity = realmSync?.objects(PlayerActivity.self).filter("name = %@", GV.basicDataRecord.myName)
        }
        try! realmSync?.write {
            if playerActivity?.count == 0 {
                let playerActivityItem = PlayerActivity()
                playerActivityItem.name = GV.basicDataRecord.myName
                playerActivityItem.nickName = GV.basicDataRecord.myNickname
                playerActivityItem.isOnline = true
                playerActivityItem.onlineSince = getLocalDate()
                playerActivityItem.onlineTime = 0
                realmSync?.add(playerActivityItem)
            } else {
                playerActivity![0].isOnline = true
                playerActivity![0].onlineSince = getLocalDate()
            }
        }
//        setNotification()
    }
    
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
