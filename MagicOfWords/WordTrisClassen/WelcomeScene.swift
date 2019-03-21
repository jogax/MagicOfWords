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
    var myDelegate: WelcomeSceneDelegate
    let myTitleFont = UIFont(name: GV.actFont, size: GV.onIpad ? 30 : 18)

    init(delegate: WelcomeSceneDelegate) {
        self.myDelegate = delegate
        super.init(size: CGSize(width: 1000, height: 1000))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func didMove(to view: SKView) {
        //        wtGameWordList = WTGameWordList(delegate: self)
        //        timeIncreaseValues = [0, 0, 0, 0, 0, 0, iFiveMinutes, iFiveMinutes, iTenMinutes, iTenMinutes, iQuarterHour]
        self.name = "WelcomaAnimation"
        self.view!.isMultipleTouchEnabled = false
//        self.view!.subviews.forEach { $0.removeFromSuperview() }
        let size = CGSize(width: self.frame.height * 0.10, height: self.frame.height * 0.05)
        let center = CGPoint(x:self.frame.midX, y: self.frame.midY)
        let myButton = createMyButton(title: "Done",
                                      size: size,
                                      center: center,
                                      enabled: true )
        myButton.setButtonAction(target: self, triggerEvent:.TouchUpInside, action: #selector(doneButtonTapped))
        myButton.zPosition = 10
        self.addChild(myButton)

    }
    @objc private func doneButtonTapped() {
        myDelegate.backFromAnimation()
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
