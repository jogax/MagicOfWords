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

class MainViewController: UIViewController, MenuSceneDelegate, GameTypeSceneDelegate, CollectWordsSceneDelegate {
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
        importWords()
        startMenuScene()
        
            
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
    func importWords() {
        // File location
        if realm.objects(WordListModel.self).count > 0 {
            return
        }
        let language = GV.language.getText(.tcAktLanguage)
        let fileURL = Bundle.main.path(forResource: "\(language)Words", ofType: "txt")
        // Read from the file
        var textFile = ""
        do {
            textFile = try String(contentsOfFile: fileURL!, encoding: String.Encoding.utf8)
        } catch let error as NSError {
            print("Failed reading from URL: \(String(describing: fileURL)), Error: " + error.localizedDescription)
        }
        let myStrings = textFile.components(separatedBy: .newlines)
        for string in myStrings {
            if realm.objects(WordListModel.self).filter("word = '\(string)'").count == 0 {
                realm.beginWrite()
                let wordListModel = WordListModel()
                wordListModel.length = string.count
                wordListModel.language = language
                wordListModel.word = string
                realm.add(wordListModel)
                try! realm.commitWrite()
            }
        }
    }

}
