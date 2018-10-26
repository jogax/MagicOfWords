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
    func getHeightForRow(tableView: UITableView, indexPath: IndexPath)->CGFloat
    func setHeaderView(tableView: UITableView, headerView: UIView, section: Int)
    func fillHeaderView(tableView: UITableView, section: Int)->UIView
    func getHeightForHeaderInSection(tableView: UITableView, section: Int)->CGFloat
    func didSelectedRow(tableView: UITableView, indexPath: IndexPath)
}
class WTTableView: UITableView,UITableViewDelegate,UITableViewDataSource  {
    var myDelegate: WTTableViewDelegate?
    override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)
        layer.borderColor = UIColor.black.cgColor
        layer.borderWidth = 1.0
        layer.cornerRadius = 10.0
        self.delegate = self
        self.dataSource = self
//        self.addBorder(toSide: .Left, withColor: UIColor.black, andThickness: 5)
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
//    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
//        return self.myDelegate!.geTitleForHeaderInSection(section: section)
//    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.myDelegate!.didSelectedRow(tableView: tableView, indexPath: indexPath)
    }
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        self.myDelegate!.setHeaderView(tableView: tableView, headerView: view, section: section)
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return self.myDelegate!.fillHeaderView(tableView: tableView, section: section)
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {        
        return self.myDelegate!.getHeightForRow(tableView: tableView, indexPath: indexPath)
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return self.myDelegate!.getHeightForHeaderInSection(tableView: tableView, section: section)
    }

}


