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

class MainViewController: UIViewController, MenuSceneDelegate, GameTypeSceneDelegate, WTSceneDelegate, LoadingSceneDelegate {
    func startChooseGameType() {
        print("Choose game type choosed")
        let gameTypeScene = GameTypeScene(size: CGSize(width: view.frame.width, height: view.frame.height))
        if let view = self.view as! SKView? {
            gameTypeScene.setDelegate(delegate: self)
            view.presentScene(gameTypeScene)
        }
    }
    
    func loadingFinished() {
        GV.loadingScene = nil
        startMenuScene()
    }
    
    func gameFinished() {
        startMenuScene()
    }
    
    func wtGame() {
        startWTScene(new: true)
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
    
    func startWTScene(new: Bool) {
        let wtScene = WTScene(size: CGSize(width: view.frame.width, height: view.frame.height))
        if let view = self.view as! SKView? {
            wtScene.setDelegate(delegate: self)
            wtScene.setGameArt(new: new)
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
        let basicData = realm.objects(BasicDataModel.self).first!
        let gameType = GameType(rawValue: basicData.gameType)!
        switch gameType {
        case .WordTris:
            startWTScene(new: true)
        case .SearchWords:
            startFindWordsScene()
        case .NoMoreGames:
            break
        }
    }
    
    func continueGame() {
        let basicData = realm.objects(BasicDataModel.self).first!
        let gameType = GameType(rawValue: basicData.gameType)!
        switch gameType {
        case .WordTris:
            startWTScene(new: false)
        case .SearchWords:
            startFindWordsScene()
        case .NoMoreGames:
            break
        }
    }
    
    func startSettings() {
        print("Settings started")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("\(String(describing: Realm.Configuration.defaultConfiguration.fileURL))")
        GV.loadingScene = LoadingScene(size: CGSize(width: view.frame.width, height: view.frame.height))
        if let view = self.view as! SKView? {
            GV.loadingScene!.setDelegate(delegate: self)
            view.presentScene(GV.loadingScene!)
        }
        
            
            // Get the SKScene from the loaded GKScene
    }
    
    func startMenuScene() {
        let menuScene = MenuScene(size: CGSize(width: view.frame.width, height: view.frame.height))
        if let view = self.view as! SKView? {
            menuScene.setDelegate(delegate: self)
            view.presentScene(menuScene)
            
            //            view.ignoresSiblingOrder = true
            
            //            view.showsFPS = true
            //            view.showsNodeCount = true
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

}
