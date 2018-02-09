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

class MainViewController: UIViewController, MenuSceneDelegate, GameTypeSceneDelegate, CollectWordsSceneDelegate, LoadingSceneDelegate {
    func loadingFinished() {
        GV.loadingScene = nil
        startMenuScene()
    }
    
    func gameFinished() {
        startMenuScene()
    }
    
    func collectWordsGame() {
        print("Collect Words choosed")
        startCollectWordsScene()
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
    
    func startCollectWordsScene() {
        let collectWordsScene = CollectWordsScene(size: CGSize(width: view.frame.width, height: view.frame.height))
        if let view = self.view as! SKView? {
            collectWordsScene.setDelegate(delegate: self)
            view.presentScene(collectWordsScene)
        }

    }
    
    func startNewGame() {
        print("Start new game")
        let gameTypeScene = GameTypeScene(size: CGSize(width: view.frame.width, height: view.frame.height))
        if let view = self.view as! SKView? {
            gameTypeScene.setDelegate(delegate: self)
            view.presentScene(gameTypeScene)
        }
        
    }
    
    func continueGame() {
        print("Continue a game")
    }
    
    func startSettings() {
        print("Settings started")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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

}
