//
//  MenuScene.swift
//  MagicOfWords
//
//  Created by Romhanyi Jozsef on 2020. 10. 01..
//  Copyright © 2020. Jozsef Romhanyi. All rights reserved.
//

import Foundation
import Realm
import RealmSwift
import GameKit

public protocol MenuSceneDelegate: class {
    
    /// Method called when Game finished
    func startGameChoosed()
    
}


class MenuScene: SKScene {
    
    let myTitleFont = UIFont(name: GV.actFont, size: GV.onIpad ? 30 : 10)
    let buttonFrameWidth = GV.minSide * 0.5
    let buttonFrameHeight = GV.maxSide * 0.05
    var buttonFrame: CGRect!
    var buttonSize = CGSize(width: CGFloat(0), height: CGFloat(0))
    var myDelegate: MainViewController!
    let linePPosYs: [CGFloat] = [0.8, 0.75, 0.70, 0.65, 0.60, 0.55, 0.50, 0.45, 0.40]
    let lineLPosYs: [CGFloat] = [0.8, 0.70, 0.60, 0.50, 0.40, 0.30, 0.20, 0.10, 0.10]


    public func setDelegate(_ delegate: MainViewController) {
        myDelegate = delegate
    }

    override func didMove(to view: SKView) {
        self.size = CGSize(width: GV.actWidth, height: GV.actHeight)
        buttonFrame = CGRect(x: 0, y: 0, width:buttonFrameWidth, height: buttonFrameHeight)
        buttonSize = CGSize(width:buttonFrameWidth, height: buttonFrameHeight )
        GV.target = self
        GV.orientationHandler = #selector(didRotated)
        self.name = "MenuScene"
        self.view!.isMultipleTouchEnabled = false
        self.view!.subviews.forEach { $0.removeFromSuperview() }
        if self.children.count > 0 {
            for child in self.children {
                child.removeFromParent()
            }
        }
        bgSprite = SKSpriteNode()
        self.addChild(bgSprite!)
        setBackground(to: bgSprite)
        bgSprite!.size = self.frame.size
        showMainMenu()
    //        bgSprite!.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
    //        bgSprite!.color = bgColor
//        bgSprite!.position = CGPoint(x: self.frame.midX, y: self.frame.midY)

    }
    
    @objc private func showMainMenu() {
        removeChildrenExceptTypes(from: bgSprite!, types: [.Background])
        let center0 = PLPosSize(PPos: CGPoint(x: GV.minSide * 0.5, y: GV.maxSide * linePPosYs[0]), LPos: CGPoint(x: GV.maxSide * 0.5, y: GV.minSide * lineLPosYs[0]))
        let gameButton = createMyButton(imageName: "", title: GV.language.getText(.tcStartGame) , size: buttonSize, center: center0, enabled: true)
        bgSprite!.addChild(gameButton)
        let center1 = PLPosSize(PPos: CGPoint(x: GV.minSide * 0.5, y: GV.maxSide * linePPosYs[1]), LPos: CGPoint(x: GV.maxSide * 0.5, y: GV.minSide * lineLPosYs[1]))
        let chooseButton = createMyButton(imageName: "", title: GV.language.getText(.tcChooseGame) , size: buttonSize, center: center1, enabled: true)
        bgSprite!.addChild(chooseButton)
        let center2 = PLPosSize(PPos: CGPoint(x: GV.minSide * 0.5, y: GV.maxSide * linePPosYs[2]), LPos: CGPoint(x: GV.maxSide * 0.5, y: GV.minSide * lineLPosYs[2]))
        let bestScoreButton = createMyButton(imageName: "", title: GV.language.getText(.tcBestScore) , size: buttonSize, center: center2, enabled: true)
        bgSprite!.addChild(bestScoreButton)
        let center3 = PLPosSize(PPos: CGPoint(x: GV.minSide * 0.5, y: GV.maxSide * linePPosYs[3]), LPos: CGPoint(x: GV.maxSide * 0.5, y: GV.minSide * lineLPosYs[3]))
        let languageButton = createMyButton(imageName: "", title: GV.language.getText(.tcChooseLanguage) , size: buttonSize, center: center3, enabled: true)
        bgSprite!.addChild(languageButton)
        let center4 = PLPosSize(PPos: CGPoint(x: GV.minSide * 0.5, y: GV.maxSide * linePPosYs[4]), LPos: CGPoint(x: GV.maxSide * 0.5, y: GV.minSide * lineLPosYs[4]))
        let developerButton = createMyButton(imageName: "", title: GV.language.getText(.tcDeveloperMenu) , size: buttonSize, center: center4, enabled: true)
        bgSprite!.addChild(developerButton)
        gameButton.setButtonAction(target: self, triggerEvent: .TouchUpInside, action: #selector(backToStartGame))
        chooseButton.setButtonAction(target: self, triggerEvent: .TouchUpInside, action: #selector(showChooseGameTypeMenu))
        bestScoreButton.setButtonAction(target: self, triggerEvent: .TouchUpInside, action: #selector(showBestScore))
  }
    
    @objc private func backToStartGame() {
        myDelegate.startGameChoosed()
    }
    
    @objc private func showChooseGameTypeMenu() {
        removeChildrenExceptTypes(from: bgSprite!, types: [.Background])
        let center0 = PLPosSize(PPos: CGPoint(x: GV.minSide * 0.5, y: GV.maxSide * linePPosYs[0]), LPos: CGPoint(x: GV.maxSide * 0.5, y: GV.minSide * lineLPosYs[0]))
        let easyGameButton = createMyButton(imageName: "", title: GV.language.getText(.tcEasyPlay) , size: buttonSize, center: center0, enabled: true)
        bgSprite!.addChild(easyGameButton)
        let center1 = PLPosSize(PPos: CGPoint(x: GV.minSide * 0.5, y: GV.maxSide * linePPosYs[1]), LPos: CGPoint(x: GV.maxSide * 0.5, y: GV.minSide * lineLPosYs[1]))
        let mediumGameButton = createMyButton(imageName: "", title: GV.language.getText(.tcMediumPlay) , size: buttonSize, center: center1, enabled: true)
        bgSprite!.addChild(mediumGameButton)
        let center4 = PLPosSize(PPos: CGPoint(x: GV.minSide * 0.5, y: GV.maxSide * linePPosYs[8]), LPos: CGPoint(x: GV.maxSide * 0.5, y: GV.minSide * lineLPosYs[8]))
        let returnButton = createMyButton(imageName: "", title: GV.language.getText(.tcCancel) , size: buttonSize, center: center4, enabled: true)
        bgSprite!.addChild(returnButton)
        easyGameButton.setButtonAction(target: self, triggerEvent: .TouchUpInside, action: #selector(easyGameChoosed))
        mediumGameButton.setButtonAction(target: self, triggerEvent: .TouchUpInside, action: #selector(mediumGameChoosed))
        returnButton.setButtonAction(target: self, triggerEvent: .TouchUpInside, action: #selector(showMainMenu))
    }
    
    

    @objc private func easyGameChoosed() {
        GV.gameType = .CollectWords
    }

    @objc private func mediumGameChoosed() {
        GV.gameType = .FixLetter
    }

    @objc private func showBestScore() {
        
    }

    private func createMyButton(imageName: String = "", title: String = "", size: CGSize, center: PLPosSize, enabled: Bool, newSize: CGFloat = 0)->MyButton {
        var button: MyButton
        if imageName != "" {
            let image = UIImage(named: imageName)!
            let texture = SKTexture(image: image)
//            let imageSize:CGFloat = 100.0 //image.size.width *  0.8
//            let downImage = resizeImage(image: image, newWidth: imageSize)
//            let downTexture = SKTexture(image: downImage)
            button = MyButton(normalTexture: texture, selectedTexture:texture, disabledTexture: texture)
            button.size = size * (GV.onIpad ? 1.0 : 0.8)
        } else {
            button = MyButton(fontName: myTitleFont!.fontName, size: size)
            button.setButtonLabel(title: title, font: myTitleFont!)
//            let buttonSize = CGSize(width: title.width(font: myTitleFont!) * 1.2, height: buttonFrameHeight)
            button.size = size //buttonSize
        }
        button.plPosSize = center


        button.alpha = enabled ? 1.0 : 0.2
        button.isEnabled = enabled
        button.setActPosSize()
        return button

    }

    
    @objc private func didRotated() {
        
    }
}
