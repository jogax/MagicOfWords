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

class MainViewController: UIViewController, MenuSceneDelegate, GameTypeSceneDelegate{
    func createWordsGame() {
        print("Create Words choosed")
    }
    
    func findWords() {
        print("Search Words choosed")
    }
    
    func importWords() {
        
        let url = NSURL(string:"http://www.desiquintans.com/downloads/nounlist/nounlist.txt")!
        let request = URLRequest(url: url as URL)
        NSURLConnection.sendAsynchronousRequest(request, queue: OperationQueue.current!) { (response, data, error) -> Void in
            if error != nil {
                print(error!)
            } else {
                if let textFile = NSString(data: data!, encoding: String.Encoding.utf8.rawValue) {
                    let myStrings = textFile.components(separatedBy: .newlines)
                    print("\(myStrings.count)")
                    print("\(myStrings[0..<10])")
                    print("\(myStrings[1000..<1050])")
               }
            }
        }
        
    }
    func cancelChooeseGameType() {
        print("cancel choosed")
        startMenuScene()
    }
    
    func xxx() {
        return
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
}
