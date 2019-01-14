//
//  CreateMandatorysViewController.swift
//  MagicOfWords
//
//  Created by Jozsef Romhanyi on 14/01/2019.
//  Copyright © 2019 Jozsef Romhanyi. All rights reserved.
//

import Foundation
import RealmSwift
import GameplayKit

#if DEBUG

class CreateMandatoryWordsViewController: UIViewController {

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        let myBackgroundImage = UIImageView (frame: UIScreen.main.bounds)
        myBackgroundImage.image = UIImage(named: "magier")
        myBackgroundImage.contentMode = UIView.ContentMode.scaleAspectFill
        self.view.insertSubview(myBackgroundImage, at: 0)
        creating()
    }
    
    func creating() {
        print("hier")
    }
}
#endif
