//
//  WordTrisShowNewGameList.swift
//  MagicOfWords
//
//  Created by Jozsef Romhanyi on 13/02/2018.
//  Copyright © 2018 Jozsef Romhanyi. All rights reserved.
//

import SpriteKit
import UIKit

public protocol WTTableViewDelegate: class {
    
    /// Method called when a new Word is saved
    func getNumberOfSections()->Int
    func getNumberOfRowsInSections(section: Int)->Int
    func getTableViewCell(tableView: UITableView, indexPath: IndexPath)->UITableViewCell
    func geTitleForHeaderInSection(section: Int)->String?
}
class WTTableView: UITableView,UITableViewDelegate,UITableViewDataSource  {
//    var items: [String] = ["Player1", "Player2", "Player3"]
//    var words: [String] = ["Word1", "Word2", "Word3", "Word4", "Word5"]
    var myDelegate: WTTableViewDelegate?
    override init(frame: CGRect, style: UITableViewStyle) {
        super.init(frame: frame, style: style)
//        self.backgroundColor = UIColor.lightGray
//        let backgroundImage = UIImageView(frame: frame)
//        backgroundImage.clipsToBounds = true
//        backgroundImage.image = UIImage(named: "menuBackground.png")
//        backgroundImage.contentMode = .scaleToFill
//        self.backgroundView = backgroundImage
        self.delegate = self
        self.dataSource = self
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    public func setDelegate(delegate: WTTableViewDelegate) {
        self.myDelegate = delegate
    }
    // MARK: - Table view data source
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.myDelegate!.getNumberOfSections()
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.myDelegate!.getNumberOfRowsInSections(section: section)
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return self.myDelegate!.getTableViewCell(tableView: tableView, indexPath: indexPath)
    }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.myDelegate!.geTitleForHeaderInSection(section: section)
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("You selected cell #\(indexPath.row)!")
    }
    }


