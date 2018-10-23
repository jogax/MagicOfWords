////
////  MenuScene.swift
////  Szómágia
////
////  Created by Jozsef Romhanyi on 30/01/2018.
////  Copyright © 2018 Jozsef Romhanyi. All rights reserved.
////
//
//import Foundation
//import GameKit
//
//public protocol MenuSceneDelegate: class {
//
//    func startNewGame()
//    func continueGame()
//    func showFinishedGames()
//    func displayCloudRecordsViewController()
//    //    func startChooseGameType()
//    func startSettings()
//    func chooseNickname()
//}
//
//
//
//
//class MenuScene: SKScene {
//    var menuSceneDelegate: MenuSceneDelegate?
//    let enabledAlpha: CGFloat = 1.0
//    let disabledAlpha: CGFloat = 0.4
//    var nickNameItem: SKLabelNode?
//    var showRealmCloudItem: SKLabelNode?
//
//    override func didMove(to view: SKView) {
////        let callerName = "MenuScene"
////        let alertController = UIAlertController(title: GV.language.getText(.tcChooseAction),
////                                                message: "",
////                                                preferredStyle: .alert)
////        var count = realm.objects(GameDataModel.self).filter("gameStatus != %d and language = %@", GV.GameStatusNew, GV.aktLanguage).count
////        if count > 0 {
////            alertController.addAction(UIAlertAction(title: GV.language.getText(.tcNewGame), style: .default, handler: { [unowned self]
////            alert -> Void in
////                self.menuSceneDelegate!.startNewGame()
////            }))
////        }
////        count = realm.objects(GameDataModel.self).filter("gameStatus = %d and language = %@", GV.GameStatusPlaying, GV.aktLanguage).count
////        if count > 0 {
////            alertController.addAction(UIAlertAction(title: GV.language.getText(.tcContinue), style: .default, handler: { [unowned self]
////                alert -> Void in
////                self.menuSceneDelegate!.continueGame()
////            }))
////        }
////        alertController.addAction(UIAlertAction(title: GV.language.getText(.tcBestScore), style: .default, handler: { [unowned self]
////            alert -> Void in
////            self.menuSceneDelegate!.showFinishedGames()
////        }))
////        alertController.addAction(UIAlertAction(title: GV.language.getText(.tcChooseLanguage), style: .default, handler: { [unowned self]
////            alert -> Void in
////            self.menuSceneDelegate!.startSettings()
////        }))
////        alertController.addAction(UIAlertAction(title: GV.language.getText(.tcSetNickName), style: .default, handler: { [unowned self]
////            alert -> Void in
////            self.menuSceneDelegate!.chooseNickname()
////        }))
////   #if DEBUG
////        alertController.addAction(UIAlertAction(title: GV.language.getText(.tcShowRealmCloud), style: .default, handler: { [unowned self]
////            alert -> Void in
////            self.menuSceneDelegate!.displayCloudRecordsViewController()
////        }))
////    #endif
////      self.view.present(alertController, animated: true, completion: nil)
//
////        let actLanguage = GV.language.getText(.tcAktLanguage)
////        self.backgroundColor = SKColor(red: 255/255, green: 220/255, blue: 208/255, alpha: 1)
////        var count = realmMandatory.objects(MandatoryModel.self).filter("language = %@", actLanguage).count
////        let count1 = realm.objects(GameDataModel.self).filter("gameStatus != %d and language = %@", GV.GameStatusNew, GV.aktLanguage).count
////        _ = createMenuItem(menuInt: .tcNewGame, firstLine: true, count: count - count1)
////        count = realm.objects(GameDataModel.self).filter("gameStatus = %d and language = %@", GV.GameStatusPlaying, GV.aktLanguage).count
////        _ = createMenuItem(menuInt: .tcContinue, count: count)
////        count = realm.objects(GameDataModel.self).filter("gameStatus = %d and language = %@", GV.GameStatusFinished, GV.aktLanguage).count
////        _ = createMenuItem(menuInt: .tcFinished, count: count)
////        //        createMenuItem(menuInt: .tcSettings, showValue: true, touchbar: false)
////        _ = createMenuItem(menuInt: .tcChooseLanguage, showValue: false, touchbar: true)
////        nickNameItem = createMenuItem(menuInt: .tcSetNickName, showValue: false, touchbar: /*GV.myUser != nil*/ GV.connectedToInternet)
////        #if DEBUG
////        showRealmCloudItem = createMenuItem(menuInt: .tcShowRealmCloud, showValue: false, touchbar: GV.myUser != nil)
////        #endif
////        if !GV.callBackMyUser.contains(where: {$0.myCaller == callerName}) {
////            GV.callBackMyUser.append(GV.CallBackStruct(caller: callerName, callBackFunction: callBackFunc()))
////        }
//    }
//
//    public func callBackFunc() {
//        nickNameItem!.alpha = enabledAlpha
//        nickNameItem!.name = String(TextConstants.tcSetNickName.rawValue)
//        showRealmCloudItem!.alpha = enabledAlpha
//        showRealmCloudItem!.name = String(TextConstants.tcShowRealmCloud.rawValue)
//        print("callBack OK")
//    }
//    public func setDelegate(delegate: MenuSceneDelegate) {
//        menuSceneDelegate = delegate
//    }
//    var line = 0
//
//    func createMenuItem(menuInt: TextConstants, firstLine: Bool = false, count: Int = NoValue, showValue: Bool = true, touchbar: Bool = true)->SKLabelNode {
//        let texture = SKTexture(imageNamed: "button.png")
//        let button = SKSpriteNode(texture: texture, color: .white, size: CGSize(width: self.size.width * 0.5, height: self.size.height * 0.2))
//        line = firstLine ? 1 : line + 1
//        let startYPosition = self.frame.size.height * 0.80
//        button.size = CGSize(width: self.frame.size.width * 0.8, height: self.frame.size.height * 0.1)
//        button.position = CGPoint(x: self.frame.size.width / 2, y: startYPosition - (CGFloat(line) * self.frame.size.height * 0.1) )
//        button.name = String("button\(menuInt.rawValue)")
//        let menuItem = SKLabelNode(fontNamed: "TimesNewRomanPS-BoldMT")// Snell Roundhand")
//        menuItem.fontSize = self.frame.size.height / 30
//        menuItem.position = CGPoint(x:0, y: button.frame.height * 0.1)
//        menuItem.fontColor = SKColor.blue
//        menuItem.alpha = ((showValue && count > 0) || (!showValue && touchbar)) ? enabledAlpha : disabledAlpha
//        menuItem.colorBlendFactor = 0.9
//        menuItem.text = GV.language.getText(menuInt, values: showValue ? "(\(count))" : "")
//        menuItem.zPosition = self.zPosition + 1
//        menuItem.horizontalAlignmentMode = .center
//        menuItem.verticalAlignmentMode = .center
//        menuItem.name = String(menuInt.rawValue) + (touchbar ? "" : "noTouch")
//        button.addChild(menuItem)
//        self.addChild(button)
//        return menuItem
//    }
//    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
//        if menuSceneDelegate == nil {
//            return
//        }
//        let firstTouch = touches.first
//        let touchLocation = firstTouch!.location(in: self)
//        let nodes = self.nodes(at: touchLocation)
//        if nodes.count > 0 {
//            for node in nodes {
//                let name = node.name
//                if name != nil && node.alpha == enabledAlpha {
//                    switch name {
//                    case String(TextConstants.tcNewGame.rawValue):
//                        menuSceneDelegate!.startNewGame()
//                    case String(TextConstants.tcContinue.rawValue):
//                        menuSceneDelegate!.continueGame()
//
//                    case String(TextConstants.tcFinished.rawValue):
//                        menuSceneDelegate!.showFinishedGames()
//
//                    case String(TextConstants.tcChooseLanguage.rawValue):
//                        menuSceneDelegate!.startSettings()
//
//                    case String(TextConstants.tcShowRealmCloud.rawValue):
//                        menuSceneDelegate!.displayCloudRecordsViewController()
//
//                    case String(TextConstants.tcSetNickName.rawValue):
//                        menuSceneDelegate!.chooseNickname()
//
//                    default: break
//                    }
//                }
//            }
//        }
//    }
//    deinit {
//        print("\n THE SCENE \((type(of: self))) WAS REMOVED FROM MEMORY (DEINIT) \n")
//    }
//
//
//}
//
