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
    
}


class WelcomeScene: SKScene {
    let bgColor = SKColor(red: 223/255, green: 255/255, blue: 216/255, alpha: 0.8)
    var myDelegate: WelcomeSceneDelegate?
    let myTitleFont = UIFont(name: GV.actFont, size: GV.onIpad ? 30 : 18)

    override func didMove(to view: SKView) {
        self.name = "WelcomaAnimation"
        self.view!.isMultipleTouchEnabled = false
        self.view!.subviews.forEach { $0.removeFromSuperview() }
        let size = CGSize(width: self.frame.height * 0.10, height: self.frame.height * 0.05)
        self.backgroundColor = bgColor
        let buttonCenter1 = CGPoint(x:self.frame.midX * 0.5, y: self.frame.height * 0.05)
        let myButton1 = createMyButton(title: GV.language.getText(.tcOK), size: size, center: buttonCenter1, enabled: true)
        myButton1.setButtonAction(target: self, triggerEvent:.TouchUpInside, action: #selector(OKButtonTapped))
        myButton1.zPosition = self.zPosition + 1
        self.addChild(myButton1)
        let buttonCenter2 = CGPoint(x:self.frame.midX * 1.5, y: self.frame.height * 0.05)
        let myButton2 = createMyButton(title: GV.language.getText(.tcLater), size: size, center: buttonCenter2, enabled: true)
        myButton2.setButtonAction(target: self, triggerEvent:.TouchUpInside, action: #selector(laterButtonTapped))
        myButton2.zPosition = self.zPosition + 1
        self.addChild(myButton2)
        blockSize = self.frame.width * (GV.onIpad ? 0.05 : 0.06)
        animateTexts()
    }
    
    var letterTable = [[WTGameboardItem]]()
    var blockSize: CGFloat = 0
    var firstLinePosY: CGFloat = 0
    var lastPosY: CGFloat = 0

    private func animateTexts() {
        firstLinePosY = self.frame.height * 0.9
        animate(textConstant: .tcWelcomeText1)
        animate(textConstant: .tcWelcomeText2)
        animate(textConstant: .tcWelcomeText3)
    }

    private func animate(textConstant: TextConstants) {
        var actions = Array<SKAction>()
        var waiting = 0.0

        
        letterTable.removeAll()
        getLetters(textConstant: textConstant)
        firstLinePosY = lastPosY > 0 ? lastPosY - self.frame.height * 0.1 : firstLinePosY

        for (lineIndex, lineTable) in letterTable.enumerated() {
            let startPosX = (self.frame.width - blockSize * 1.1 * CGFloat(lineTable.count)) / 2 - blockSize / 2
            for (index, item) in lineTable.enumerated() {
                if item.letter != " " {
                    let toPositionX = startPosX + CGFloat(index + 1) * blockSize * 1.1
                    let toPositionY = firstLinePosY - 1.1 * (CGFloat(lineIndex) * blockSize)
                    lastPosY = toPositionY
                    let waitAction = SKAction.wait(forDuration: waiting)
                    waiting += 0.1
                    let moveAction = SKAction.move(to: CGPoint(x: toPositionX, y: toPositionY), duration: 2.0)
                    let fadeInAction = SKAction.fadeIn(withDuration: 0.0)
                    actions.append(SKAction.sequence([waitAction, fadeInAction, moveAction]))
                    self.addChild(item)
                    item.run(SKAction.sequence([waitAction, fadeInAction, moveAction]))
                }
            }
        }
    }
    
    private func getLetters(textConstant: TextConstants) {
        let text = GV.language.getText(textConstant).uppercased()
        let words = text.components(separatedBy: "/")
        for (tableIndex, word) in words.enumerated() {
            letterTable.append([WTGameboardItem]())
            for letter in word {
                let item = WTGameboardItem(blockSize: blockSize, fontSize: blockSize * 0.7)
                _ = item.setLetter(letter: String(letter), status: ItemStatus.wholeWord, toColor: MyColor.myGoldColor)
                item.position = CGPoint(x: self.frame.width * 0.5, y: self.frame.height * -0.1)
                item.zPosition = self.zPosition + 2
                item.alpha = 0.0
                letterTable[tableIndex].append(item)
            }
        }
    }
    
    public func showHowToPlay() {
        
    }
    
    public func setDelegate(delegate: WelcomeSceneDelegate) {
        self.myDelegate = delegate
    }
    
    @objc private func OKButtonTapped() {
        try! realm.safeWrite() {
            GV.basicDataRecord.startAnimationShown = true
        }
        showHowToPlay()
        myDelegate!.backFromAnimation()
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
