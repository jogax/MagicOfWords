////
////  GameTypeScene.swift
////  Szómágia
////
////  Created by Jozsef Romhanyi on 31/01/2018.
////  Copyright © 2018 Jozsef Romhanyi. All rights reserved.
////
//
//import Foundation
//import GameplayKit
//public protocol GameTypeSceneDelegate: class {
//    
//    /// Method called when Create Words choosed
//    func wtGame()
//    /// Method called when Search Words choosed
//    func findWords()
//    /// Method called when Choose Game Type cancelled
//    func cancelChooeseGameType()
//}
//class GameTypeScene: SKScene {
//    var gameTypeSceneDelegate: GameTypeSceneDelegate?
//    
//    override func didMove(to view: SKView) {
//        self.backgroundColor = SKColor(red: 141/255, green: 182/255, blue: 0/255, alpha: 1)
//        createMenuItem(menuInt: .tcWordTris, firstLine: true)
//        createMenuItem(menuInt: .tcSearchWords)
//        createMenuItem(menuInt: .tcCancel)
//    }
//    public func setDelegate(delegate: GameTypeSceneDelegate) {
//        gameTypeSceneDelegate = delegate
//    }
//    var line = 0
//    func createMenuItem(menuInt: TextConstants, firstLine: Bool = false) {
//        line = firstLine ? 1 : line + 1
//        let menuItem = SKLabelNode(fontNamed: "Noteworthy")// Snell Roundhand")
//        let startYPosition = self.frame.size.height * 0.80
//        menuItem.text = GV.language.getText(menuInt)
//        menuItem.name = String(menuInt.rawValue)
//        menuItem.fontSize = self.frame.size.height / 30
//        menuItem.position = CGPoint(x: self.frame.size.width / 2, y: startYPosition - (CGFloat(line) * 45) )
//        menuItem.fontColor = SKColor.blue
//        menuItem.color = UIColor.brown
//        self.addChild(menuItem)
//    }
//    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
//        if gameTypeSceneDelegate == nil {
//            return
//        }
//        let firstTouch = touches.first
//        let touchLocation = firstTouch!.location(in: self)
//        let nodes = self.nodes(at: touchLocation)
//        if nodes.count > 0 {
//            if let name = nodes.first!.name {
//                switch name {
//                case String(TextConstants.tcWordTris.rawValue):
//                    saveChoosedType(gameType: .WordTris)
////                    let gameTypeRecord = realm.objects(GameTypeModel.self).filter("gameType = %@", GameType.WordTris.rawValue)[0]
////                    GV.gameNumber = gameTypeRecord.gameNumber
////                    GV.gameType = gameTypeRecord.gameType
////                    gameTypeSceneDelegate!.cancelChooeseGameType()
//                case String(TextConstants.tcSearchWords.rawValue):
//                    saveChoosedType(gameType: .SearchWords)
//                    let gameTypeRecord = realm.objects(GameTypeModel.self).filter("gameType = %@", GameType.SearchWords.rawValue)[0]
//                    GV.gameNumber = gameTypeRecord.gameNumber
//                    GV.gameType = gameTypeRecord.gameType
//                    gameTypeSceneDelegate!.cancelChooeseGameType()
//                case String(TextConstants.tcCancel.rawValue):
//                    gameTypeSceneDelegate!.cancelChooeseGameType()
//
//                    
//                default: break
//                }
//            }
//        }
//    }
//    
//    private func saveChoosedType(gameType: GameType) {
//        realm.beginWrite()
//            let basicDataModel = realm.objects(BasicDataModel.self).first!
//            basicDataModel.gameType = gameType.rawValue
//        try! realm.commitWrite()
//    }
//    
//    deinit {
//        print("\n THE SCENE \((type(of: self))) WAS REMOVED FROM MEMORY (DEINIT) \n")
//    }
//}
//
