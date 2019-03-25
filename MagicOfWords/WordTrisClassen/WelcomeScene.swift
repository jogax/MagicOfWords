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
        let buttonCenter = CGPoint(x:self.frame.midX, y: self.frame.height * 0.05)
        let myButton = createMyButton(title: "Done", size: size, center: buttonCenter, enabled: true )
        myButton.setButtonAction(target: self, triggerEvent:.TouchUpInside, action: #selector(doneButtonTapped))
        myButton.zPosition = 10
        self.backgroundColor = bgColor
        self.addChild(myButton)
        getLetters()
    }
    
    var letterTable = [WTGameboardItem]()
    
    private func getLetters() {
        let text = GV.language.getText(.tcWelcomeText1)
        for letter in text {
            let item = WTGameboardItem(blockSize: self.view!.frame.width * 0.08, fontSize: self.frame.width * 0.04)
            _ = item.setLetter(letter: String(letter), status: ItemStatus.wholeWord, toColor: MyColor.myGoldColor)
            letterTable.append(item)
        }
    }
    
    public func setDelegate(delegate: WelcomeSceneDelegate) {
        self.myDelegate = delegate
    }
    
    @objc private func doneButtonTapped() {
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
