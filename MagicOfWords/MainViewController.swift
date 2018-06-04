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
    func backFromSettingsScene() {
    try! realm.write {
        GV.basicDataRecord.actLanguage = GV.aktLanguage
    }

       startMenuScene()
    }
    
    func backToMenuScene() {
        startMenuScene()
    }
    
    func showFinishedGames() {
        let showFinishedGamesScene = ShowFinishedGamesScene(size: CGSize(width: view.frame.width, height: view.frame.height))
        showFinishedGamesScene.setDelegate(delegate: self)
        if let view = self.view as! SKView? {
            view.presentScene(showFinishedGamesScene)
        }
    }
    
//    func startChooseGameType() {
//        print("Choose game type choosed")
//        let gameTypeScene = GameTypeScene(size: CGSize(width: view.frame.width, height: view.frame.height))
//        if let view = self.view as! SKView? {
//            gameTypeScene.setDelegate(delegate: self)
//            view.presentScene(gameTypeScene)
//        }
//    }
    
//    func loadingFinished() {
//        basicData = realm.objects(BasicDataModel.self)[0]
//
//        if let view = self.view as! SKView? {
//            view.presentScene(nil)
//        }
////        GV.loadingScene = nil
//        startMenuScene()
////        if basicData!.myName == "" {
////            getName()
////        } else {
////            loginToRealmSync(new: false, userName: basicData!.myName)
//////            startMenuScene()
////        }
//    }
    
    private func loginToRealmSync(new: Bool, userName: String) {
        let password = "@@@" + userName + "@@@"
        let logInCredentials = SyncCredentials.usernamePassword(username: userName, password: password)
        SyncUser.logIn(with: logInCredentials, server: GV.AUTH_URL) { user, error in
            if user == nil {  // create a new Account
                let signUpCredentials = SyncCredentials.usernamePassword(username: userName, password: password, register: true)
                SyncUser.logIn(with: signUpCredentials, server: GV.AUTH_URL) { user, error in
                    if user == nil {
                        print("Error, user couldn't be created")
                    } else {
                        let logInCredentials = SyncCredentials.usernamePassword(username: userName, password: password)
                        SyncUser.logIn(with: logInCredentials, server: GV.AUTH_URL) { user, error in
                            if user == nil {
                                print("error after register")
                            } else {
                                realm.beginWrite()
                                GV.basicDataRecord.myName = userName
                                //                print(textField.text)
                                try! realm.commitWrite()
                                self.startMenuScene()

                                print("OK after register")
                            }
                        }
                    }
                }
            } else {
                if new {
                    self.getName(exists: true)
                } else {
                    self.startMenuScene()
                }
            }
        }
        

    }
    
    //Create Account
    
    //Log in
    func getName(exists: Bool = false) {
        if exists {
            print("hier")
        } else {
            let alertController = UIAlertController(title: GV.language.getText(.tcChooseName), message: "", preferredStyle: .alert)

            alertController.addAction(UIAlertAction(title: GV.language.getText(.tcReady), style: .default, handler: { //[unowned self]
                alert -> Void in
                let textField = alertController.textFields![0] as UITextField
                self.loginToRealmSync(new: true, userName: textField.text!)
    //            self.startMenuScene()
             }))
            alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            alertController.addTextField(configurationHandler: {(textField : UITextField!) -> Void in
                textField.placeholder = "New Item Text"
            })
            self.present(alertController, animated: true, completion: nil)
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
            if realm.objects(BasicDataModel.self).count == 0 {
                GV.basicDataRecord = BasicDataModel()
                GV.basicDataRecord.actLanguage = GV.language.getText(.tcAktLanguage)
                realm.add(GV.basicDataRecord)
            } else {
                GV.basicDataRecord = realm.objects(BasicDataModel.self).first!
                GV.language.setLanguage(GV.basicDataRecord.actLanguage)
            }
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
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
}
