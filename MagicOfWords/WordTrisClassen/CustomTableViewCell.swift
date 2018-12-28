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
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.selectionStyle = UITableViewCell.SelectionStyle.none
        self.contentView.backgroundColor = UIColor.clear

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
    }
    public func setCellSize(size: CGSize) {
        boxView = UIView.init(frame: CGRect(x : 0 , y : 0 , width: size.width, height : size.height))
//        boxView = UIView.init(frame: CGRect(x : 0 , y : 0 , width :UIScreen.main.bounds.size.width - 12*2, height : self.frame.size.height))
        self.contentView.addSubview(boxView)
    }
    public func addColumn(text: String, color: UIColor = .white) {
        var posForColumn: CGFloat = 2
        for subview in boxView.subviews {
            posForColumn += subview.frame.width
        }
        let wordLength = text.width(font: myFont) * 1.1
        let wordHeight = text.height(font: myFont)
        let label = UILabel(frame: CGRect(x: posForColumn, y: 0, width: wordLength, height: wordHeight))
        label.font = myFont
        label.textColor = UIColor.black
        label.text = text
        label.backgroundColor = color
        boxView.addSubview(label)
    }
    
    public func addButton(image: UIImage, text: String = "", color: UIColor = .white) {
        var posForColumn: CGFloat = 2
        for subView in boxView.subviews {
            posForColumn += subView.frame.width
        }
        let button = UIButton()
        button.setImage(image, for: UIControl.State.normal)
        button.frame = CGRect(x: posForColumn, y: 5, width: image.size.width * 0.1, height: image.size.height * 0.1)
        boxView.addSubview(button)
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
