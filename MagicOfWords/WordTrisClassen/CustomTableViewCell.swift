//
//  CustomTableViewCell.swift
//  MagicOfWords
//
//  Created by Jozsef Romhanyi on 09/08/2018.
//  Copyright © 2018 Jozsef Romhanyi. All rights reserved.
//

import Foundation
import UIKit

class CustomTableViewCell: UITableViewCell {
    
    var myFont = UIFont()
//    var button = UIButton()
    var boxView = UIView()
    var indexPath: IndexPath?
    var buttonCount = 0
    let maxButtonCount = 3
    var callBackArray = [(indexPath: IndexPath)->()]()
    
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.selectionStyle = UITableViewCell.SelectionStyle.none
        self.contentView.backgroundColor = UIColor.clear
        self.isUserInteractionEnabled = true
        boxView.backgroundColor = UIColor.white
        boxView.layer.cornerRadius = 0.0;
//        button = UIButton(frame:CGRect(x:boxView.frame.size.width - 90 , y:6 , width: 80 , height: 32) )
//        boxView.addSubview(button)
//        button.setTitle("Call", for: UIControlState.normal)
//        button.titleLabel?.textColor = UIColor.white
//        button.backgroundColor = UIColor.init(red: 0/255.0, green: 152/255.0, blue: 152/255.0, alpha: 1.0)
//        button.titleLabel?.font = UIFont.systemFont(ofSize: 14.0, weight: UIFont.Weight(rawValue: 1.0))
//        button.layer.cornerRadius = 2.0
//        button.addTarget(self, action: #selector(self.callButtonClicked), for: UIControlEvents.touchUpInside)
    }
    
    public func setBGColor(color: UIColor) {
        boxView.backgroundColor = color
    }
    public func setFont(font: UIFont) {
        myFont = font
        self.buttonCount = 0
        self.callBackArray.removeAll()
   }
    public func setIndexPath(indexPath: IndexPath) {
        self.indexPath = indexPath
    }
    public func setCellSize(size: CGSize) {
        boxView = UIView.init(frame: CGRect(x : 0 , y : 0 , width: size.width, height : size.height))
//        boxView = UIView.init(frame: CGRect(x : 0 , y : 0 , width :UIScreen.main.bounds.size.width - 12*2, height : self.frame.size.height))
        self.contentView.addSubview(boxView)
    }
    public func addColumn(text: String, color: UIColor = .white, xPos: CGFloat = -1) {
        var posForColumn: CGFloat = 2
        for subview in boxView.subviews {
            posForColumn += subview.frame.width
        }
        var xValue = xPos
        if xValue < 0 {
            xValue = posForColumn
        }
        let wordLength = text.width(font: myFont) * 1.1
        let wordHeight = text.height(font: myFont) * 2
//        let label = UILabel(frame: CGRect(x: xValue, y: GV.onIpad ? 6 : 3, width: wordLength, height: wordHeight))
        let label = UILabel(frame: CGRect(x: xValue, y: GV.onIpad ? 2 : 3, width: wordLength, height: wordHeight))
//        let label = UILabel(frame: CGRect(x: xValue, y: boxView.center.y - wordHeight * 0.5, width: wordLength, height: wordHeight))
        label.font = myFont
        label.textColor = UIColor.black
        label.text = text
//        label.backgroundColor = UIColor.green //color
        label.center.y = boxView.center.y
        boxView.addSubview(label)
    }
    
    public func addButton(image: UIImage? = nil, text: String = "", color: UIColor = .white, xPos: CGFloat = -1, callBack: @escaping (_ indexPath: IndexPath)->()) {
        var posForColumn: CGFloat = 2
        for subView in boxView.subviews {
            posForColumn += subView.frame.width
        }
        let button = UIButton()
        buttonCount += 1
        if buttonCount > maxButtonCount {
            print("too many Buttons! Please change CustomTableViewCell")
            return
        }
        callBackArray.append(callBack)
        var xValue = xPos
        if xValue < 0 {
            xValue = posForColumn
        }
        if image != nil {
            button.setImage(image, for: UIControl.State.normal)
            button.frame = CGRect(x: xValue, y: 2.5, width: image!.size.width, height: image!.size.width)
            let centerY = boxView.frame.midY
            let centerX = button.frame.midX
            button.center = CGPoint(x: centerX, y: centerY)
//            button.frame = CGRect(x: xValue, y: 2.5, width: image!.size.width, height: image!.size.width)
//            button.frame = CGRect(x: posForColumn, y: 2.5, width: image!.size.width * 0.2, height: image!.size.height * 0.2)
       } else {
            button.setTitle(text, for: .normal)
            button.frame = CGRect(x: posForColumn, y: 3, width: text.width(font: myFont), height: text.height(font: myFont))
        }
//        button.backgroundColor = UIColor.blue
        button.setTitleColor(.black, for: .normal)
        button.titleLabel!.font = myFont //(UIFont(name: YourfontName, size: 20))
        switch buttonCount {
        case 1: button.addTarget(self, action: #selector(self.button1Tapped), for: .touchUpInside)
        case 2: button.addTarget(self, action: #selector(self.button2Tapped), for: .touchUpInside)
        case 3: button.addTarget(self, action: #selector(self.button3Tapped), for: .touchUpInside)
        default: break
       }
        boxView.addSubview(button)
    }

    @objc private func button1Tapped() {
        callBackArray[0](indexPath!)
    }
    
    @objc private func button2Tapped() {
        callBackArray[1](indexPath!)
    }
    
    @objc private func button3Tapped() {
        callBackArray[2](indexPath!)
    }
    

    

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        boxView.subviews.forEach({ $0.removeFromSuperview() })
        
    }

    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    @objc func callButtonClicked()  {
        print("Call Button Clicked")
    }
    
}
