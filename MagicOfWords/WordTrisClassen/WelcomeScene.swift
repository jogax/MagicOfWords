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
    func showHowToPlay(difficulty: Int)
    
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
    let myTitleFont = UIFont(name: GV.actFont, size: GV.onIpad ? 25 : 14)
    var button1: MyButton?
    var button2: MyButton?
    var button3: MyButton?

    override func didMove(to view: SKView) {
        self.name = "WelcomaAnimation"
        self.view!.isMultipleTouchEnabled = false
        self.view!.subviews.forEach { $0.removeFromSuperview() }
        self.backgroundColor = bgColor
        blockSize = self.frame.width * (GV.onIpad ? 0.025 : 0.02)
        animateTexts()
    }
    
    var letterTable = [[SKLabelNode]]()
    var blockSize: CGFloat = 0
    var firstLinePosY: CGFloat = 0
    var lastPosY: CGFloat = 0

    private func createButtons() {
        var size = CGSize(width: self.frame.height * 0.10, height: self.frame.height * 0.05)
        let text1 = GV.language.getText(.tcShowEasyGame)
        size.width = text1.width(font: myTitleFont!) * 1.4
        let buttonCenter1 = CGPoint(x:self.frame.maxX * 0.20, y: self.frame.height * 0.05)
        let myButton1 = createMyButton(title: text1, size: size, center: buttonCenter1, enabled: true)
        myButton1.setButtonAction(target: self, triggerEvent:.TouchUpInside, action: #selector(EasyButtonTapped))
        myButton1.zPosition = self.zPosition + 1
        self.addChild(myButton1)
        let buttonCenter2 = CGPoint(x:self.frame.maxX * 0.55, y: self.frame.height * 0.05)
        let text2 = GV.language.getText(.tcShowMediumGame)
        size.width = text2.width(font: myTitleFont!) * 1.4
        let myButton2 = createMyButton(title: text2, size: size, center: buttonCenter2, enabled: true)
        myButton2.setButtonAction(target: self, triggerEvent:.TouchUpInside, action: #selector(MediumButtonTapped))
        myButton2.zPosition = self.zPosition + 1
        self.addChild(myButton2)
        let buttonCenter3 = CGPoint(x:self.frame.maxX * 0.85, y: self.frame.height * 0.05)
        let text3 = GV.language.getText(.tcLater)
        size.width = text3.width(font: myTitleFont!) * 1.4
        let myButton3 = createMyButton(title: text3, size: size, center: buttonCenter3, enabled: true)
        myButton3.setButtonAction(target: self, triggerEvent:.TouchUpInside, action: #selector(laterButtonTapped))
        myButton3.zPosition = self.zPosition + 1
        self.addChild(myButton3)

    }
    private func animateTexts() {
        firstLinePosY = self.frame.height * 0.9
        let text1 = GV.language.getText(.tcWelcomeText1)
        let text2 = GV.language.getText(.tcWelcomeText2)
        let text3 = GV.language.getText(.tcWelcomeText3)
        animate(text: text1, wait: 0)
        var wait = text2.filter { $0 == "/" }.count + 1
        animate(text: text2, wait: CGFloat(wait))
        wait += text3.filter { $0 == "/" }.count + 1
        animate(text: text3, wait: CGFloat(wait))
    }
    
    var countLetters = 0
    var shownLetters = 0

    private func animate(text: String, wait: CGFloat) {
        var actions = Array<SKAction>()
        var waiting = wait

        
        letterTable.removeAll()
        countLetters += getLetters(text: text)
        firstLinePosY = lastPosY > 0 ? lastPosY - self.frame.height * 0.05 : firstLinePosY

        for (lineIndex, lineTable) in letterTable.enumerated() {
            let startPosX = (self.frame.width - blockSize * 1.1 * CGFloat(lineTable.count)) / 2 - blockSize / 2
            for (index, item) in lineTable.enumerated() {
                if item.text != " " {
                    let toPositionX = startPosX + CGFloat(index + 1) * blockSize * 1.1
                    let toPositionY = firstLinePosY - 1.4 * (CGFloat(lineIndex) * blockSize * 1.1)
                    lastPosY = toPositionY
                    let waitAction = SKAction.wait(forDuration: TimeInterval(waiting))
                    waiting += 0.05
                    let moveAction = SKAction.move(to: CGPoint(x: toPositionX, y: toPositionY), duration: 1.0)
                    let fadeInAction = SKAction.fadeIn(withDuration: 0.0)
                    actions.append(SKAction.sequence([waitAction, fadeInAction, moveAction]))
                    self.addChild(item)
                    item.run(SKAction.sequence([waitAction, fadeInAction, moveAction]), completion: {
                        self.shownLetters += 1
                        if self.shownLetters == self.countLetters {
                            self.createButtons()
                        }
                    })
                }
            }
        }
    }
    
    private func getLetters(text: String)->Int {
        var counter = 0
        let words = text.components(separatedBy: "/")
        for (tableIndex, word) in words.enumerated() {
            letterTable.append([SKLabelNode]())
            for letter in word {
                let label = SKLabelNode(fontNamed: "CourierNewPS-BoldMT")
                label.text = String(letter)
                label.horizontalAlignmentMode = .center
                label.fontSize = self.frame.width * (GV.onIpad ? 0.04 : 0.04)
                label.fontColor = SKColor.black
                label.position = CGPoint(x: self.frame.width * 0.5, y: self.frame.height * -0.1)
                label.zPosition = self.zPosition + 2
                label.alpha = 0.0
                letterTable[tableIndex].append(label)
                if letter != " " {
                    counter += 1
                }
            }
        }
        return counter
    }
    
//    public func showHowToPlay() {
//    }
//
    public func setDelegate(delegate: WelcomeSceneDelegate) {
        self.myDelegate = delegate
    }
    
    @objc private func EasyButtonTapped() {
        myDelegate!.showHowToPlay(difficulty: GameDifficulty.Easy.rawValue)
    }
    
    @objc private func MediumButtonTapped() {
        myDelegate!.showHowToPlay(difficulty: GameDifficulty.Medium.rawValue)
    }
    
   @objc private func laterButtonTapped() {
        myDelegate!.backFromAnimation()
    }
    
    private func createMyButton(imageName: String = "", title: String = "", size: CGSize, center: CGPoint, enabled: Bool = false, newSize: CGFloat = 0)->MyButton {
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
