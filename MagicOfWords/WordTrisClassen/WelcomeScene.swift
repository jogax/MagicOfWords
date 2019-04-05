//
//  WelcomeScene.swift
//  MagicOfWords
//
//  Created by Jozsef Romhanyi on 20/03/2019.
//  Copyright © 2019 Jozsef Romhanyi. All rights reserved.
//

import Foundation
import GameplayKit
import RealmSwift

public protocol WelcomeSceneDelegate: class {
    
    /// Method called when Game finished
    func backFromAnimation()
    func showHowToPlay()
    
}


class WelcomeScene: SKScene {
    func gameFinished(start: StartType) {
        GV.playing = false
        if let view = self.view {
            view.presentScene(nil)
        }
        myDelegate!.backFromAnimation()
    }
    
    let bgColor = SKColor(red: 223/255, green: 255/255, blue: 216/255, alpha: 0.8)
    var myDelegate: WelcomeSceneDelegate?
    let myTitleFont = UIFont(name: GV.actFont, size: GV.onIpad ? 30 : 18)

    override func didMove(to view: SKView) {
        self.name = "WelcomaAnimation"
        self.view!.isMultipleTouchEnabled = false
        self.view!.subviews.forEach { $0.removeFromSuperview() }
        var size = CGSize(width: self.frame.height * 0.10, height: self.frame.height * 0.05)
        let text1 = GV.language.getText(.tcShowMe)
        size.width = text1.width(font: myTitleFont!) * 1.4
        self.backgroundColor = bgColor
        let buttonCenter1 = CGPoint(x:self.frame.midX * 0.5, y: self.frame.height * 0.05)
        let myButton1 = createMyButton(title: text1, size: size, center: buttonCenter1, enabled: true)
        myButton1.setButtonAction(target: self, triggerEvent:.TouchUpInside, action: #selector(ShowMeButtonTapped))
        myButton1.zPosition = self.zPosition + 1
        self.addChild(myButton1)
        let buttonCenter2 = CGPoint(x:self.frame.midX * 1.5, y: self.frame.height * 0.05)
        let text2 = GV.language.getText(.tcLater)
        size.width = text2.width(font: myTitleFont!) * 1.4
        let myButton2 = createMyButton(title: text2, size: size, center: buttonCenter2, enabled: true)
        myButton2.setButtonAction(target: self, triggerEvent:.TouchUpInside, action: #selector(laterButtonTapped))
        myButton2.zPosition = self.zPosition + 1
        self.addChild(myButton2)
        blockSize = self.frame.width * (GV.onIpad ? 0.02 : 0.02)
        animateTexts()
    }
    
    var letterTable = [[SKLabelNode]]()
    var blockSize: CGFloat = 0
    var firstLinePosY: CGFloat = 0
    var lastPosY: CGFloat = 0

    private func animateTexts() {
        firstLinePosY = self.frame.height * 0.9
        var text = GV.language.getText(.tcWelcomeText1)
        animate(text: text, wait: 0)
        var wait = text.filter { $0 == "/" }.count + 1
        text = GV.language.getText(.tcWelcomeText2)
        animate(text: text, wait: CGFloat(wait))
        wait += text.filter { $0 == "/" }.count + 1
        text = GV.language.getText(.tcWelcomeText3)
        animate(text: text, wait: CGFloat(wait))
    }

    private func animate(text: String, wait: CGFloat) {
        var actions = Array<SKAction>()
        var waiting = wait

        
        letterTable.removeAll()
        getLetters(text: text)
        firstLinePosY = lastPosY > 0 ? lastPosY - self.frame.height * 0.05 : firstLinePosY

        for (lineIndex, lineTable) in letterTable.enumerated() {
            let startPosX = (self.frame.width - blockSize * 1.1 * CGFloat(lineTable.count)) / 2 - blockSize / 2
            for (index, item) in lineTable.enumerated() {
                if item.text != " " {
                    let toPositionX = startPosX + CGFloat(index + 1) * blockSize * 1.1
                    let toPositionY = firstLinePosY - 1.4 * (CGFloat(lineIndex) * blockSize)
                    lastPosY = toPositionY
                    let waitAction = SKAction.wait(forDuration: TimeInterval(waiting))
                    waiting += 0.05
                    let moveAction = SKAction.move(to: CGPoint(x: toPositionX, y: toPositionY), duration: 1.0)
                    let fadeInAction = SKAction.fadeIn(withDuration: 0.0)
                    actions.append(SKAction.sequence([waitAction, fadeInAction, moveAction]))
                    self.addChild(item)
                    item.run(SKAction.sequence([waitAction, fadeInAction, moveAction]))
                }
            }
        }
    }
    
    private func getLetters(text: String) {
//        let text = GV.language.getText(textConstant)
        let words = text.components(separatedBy: "/")
        for (tableIndex, word) in words.enumerated() {
            letterTable.append([SKLabelNode]())
            for letter in word {
//                let item = WTGameboardItem(blockSize: blockSize, fontSize: blockSize * 0.7)
//                _ = item.setLetter(letter: String(letter), status: ItemStatus.wholeWord, toColor: MyColor.myGoldColor)
//                item.position = CGPoint(x: self.frame.width * 0.5, y: self.frame.height * -0.1)
//                item.zPosition = self.zPosition + 2
//                item.alpha = 0.0
//                letterTable[tableIndex].append(item)
                let label = SKLabelNode(fontNamed: "CourierNewPS-BoldMT")
                label.text = String(letter)
                label.horizontalAlignmentMode = .center
                label.fontSize = self.frame.width * (GV.onIpad ? 0.04 : 0.04)
                label.fontColor = SKColor.black
                label.position = CGPoint(x: self.frame.width * 0.5, y: self.frame.height * -0.1)
                label.zPosition = self.zPosition + 2
                label.alpha = 0.0
                letterTable[tableIndex].append(label)
            }
        }
    }
    
    public func showHowToPlay() {
    }
    
    public func setDelegate(delegate: WelcomeSceneDelegate) {
        self.myDelegate = delegate
    }
    
    @objc private func ShowMeButtonTapped() {
        GV.helpTouches = realmHelpInfo.objects(HelpModel.self).filter("language = %d", GV.actLanguage)
        myDelegate!.showHowToPlay()
    }
    
    @objc private func laterButtonTapped() {
        myDelegate!.backFromAnimation()
    }
    
    private func createMyButton(imageName: String = "", title: String = "", size: CGSize, center: CGPoint, enabled: Bool, newSize: CGFloat = 0)->MyButton {
        var button: MyButton
        if imageName != "" {
            let texture = SKTexture(imageNamed: imageName)
            button = MyButton(normalTexture: texture, selectedTexture:texture, disabledTexture: texture)
        } else {
            button = MyButton(fontName: myTitleFont!.fontName, size: size)
            button.setButtonLabel(title: title, font: myTitleFont!)
        }
        button.position = center
        button.size = size
        
        button.alpha = enabled ? 1.0 : 0.2
        button.isEnabled = enabled
        //        if hasFrame {
        //            button.layer.borderWidth = GV.onIpad ? 5 : 3
        //            button.layer.borderColor = UIColor(red: 220/255, green: 220/255, blue: 220/255, alpha: 1.0).cgColor
        //        }
        //        button.frame = frame
        //        button.center = center
        return button
        
    }


}
