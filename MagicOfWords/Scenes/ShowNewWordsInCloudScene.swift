//
//  ShowNewWordsInCloudScene.swift
//  MagicOfWords
//
//  Created by Romhanyi Jozsef on 2020. 01. 23..
//  Copyright © 2020. Jozsef Romhanyi. All rights reserved.
//

import Foundation
import GameKit
import UIKit
import CloudKit
import RealmSwift

public protocol ShowNewWordsInCloudSceneDelegate: class {
    func backToMenuScene(gameNumberSelected: Bool, gameNumber: Int, restart: Bool)
}
class ShowNewWordsInCloudScene: SKScene, WTTableViewDelegate {
    var myDelegate: ShowGamesSceneDelegate?
    let myTitleFont = UIFont(name: GV.actFont, size: GV.onIpad ? 30 : 10)
    var actType = ScoreType.Easy
    var background = SKSpriteNode(imageNamed: "hook")
    var initialLoadDone = false
    var bgSprite: SKSpriteNode?

    override func didMove(to view: SKView) {
        self.bgSprite = SKSpriteNode()
        self.isHidden = false
        self.addChild(bgSprite!)
        self.addChild(background)
        getNewWordsFromCloud(completion: showTable)
    }
    
    struct FoundedRecord {
        var name = ""
        var word = ""
        var status = ""
        var language = ""
        init(name: String, word: String, status: String, language: String){
            self.name = name
            self.word = word
            self.status = status
            self.language = language
        }
        
    }
    var foundedRecords = [FoundedRecord]()
    
    private func getNewWordsFromCloud(completion: @escaping ()->()) {
        foundedRecords.removeAll()
        let predicate = NSPredicate(format: "status = %@", "pending")
        let query = CKQuery(recordType: "NewWords", predicate: predicate)
        query.sortDescriptors = [NSSortDescriptor(key: "language", ascending: true)]
        let container = CKContainer.default()
        container.publicCloudDatabase.perform(query, inZoneWith: nil) { results, error in
             if results!.count == 0 {
                DispatchQueue.main.async {
                    self.goBack()
                }
            } else {
                for result in results! {
                    let name = result.recordID.recordName
                    let language = result.object(forKey: "language") as! String
                    let word = result.object(forKey: "word") as! String
                    let status = result.object(forKey: "status") as! String
                    let foundedRecord = FoundedRecord(name: name, word: word, status: status, language: language)
                    self.foundedRecords.append(foundedRecord)
                }
                completion()
            }
          
        }

    }
    
    @objc private func nothingToDo() {
        
    }
    
    private func showTable() {
        DispatchQueue.main.async {
            self.showFoundedWordsInTableView()
        }
   }
    
    private func createLabel(text: String, target: Selector, lineNr: CGFloat) {
        let width = showTableView!.frame.width //self.frame.width //text.width(font:myFont!)
        let height = text.height(font:myFont!) * 1.5
        let myX = self.frame.midX - width / 2
        let yPos = showTableView!.frame.maxY + lineHeight * lineNr * 2
        let label = UILabel(frame: CGRect(x: myX, y: yPos, width: width, height: height))
        label.text = text
        label.font = myFont!
        label.textColor = .blue
        label.textAlignment = .center
        label.backgroundColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.5)
        label.isUserInteractionEnabled = true
        
        let gesture = UITapGestureRecognizer(target: self, action: target)
        label.addGestureRecognizer(gesture)
        view!.addSubview(label)
    }
    
    @objc private func typeLabelClicked() {
        let alert = UIAlertController(title: "",
                                      message: "",
                                      preferredStyle: .alert)
        let easyAction = UIAlertAction(title: GV.language.getText(.tcEasyPlay), style: .default,
                                          handler: {[unowned self] (paramAction:UIAlertAction!) in
                                            try! realm.safeWrite() {
                                                GV.basicDataRecord.showingScoreType = ScoreType.Easy.rawValue
                                            }
                                            GCHelper.shared.getScoresForShow(completion: {self.showTable()})
        })
        alert.addAction(easyAction)
        let mediumAction = UIAlertAction(title: GV.language.getText(.tcMediumPlay), style: .default,
                                       handler: {[unowned self] (paramAction:UIAlertAction!) in
                                        try! realm.safeWrite() {
                                            GV.basicDataRecord.showingScoreType = ScoreType.Medium.rawValue
                                        }
                                        GCHelper.shared.getScoresForShow(completion: {self.showTable()})
        })
        alert.addAction(mediumAction)
        let wordCountAction = UIAlertAction(title: GV.language.getText(.tcWordCount), style: .default,
                                       handler: {[unowned self] (paramAction:UIAlertAction!) in
                                        try! realm.safeWrite() {
                                            GV.basicDataRecord.showingScoreType = ScoreType.WordCount.rawValue
                                        }
                                        GCHelper.shared.getScoresForShow(completion: {self.showTable()})
        })
        alert.addAction(wordCountAction)
        view?.window?.rootViewController?.present(alert, animated: true, completion: nil)
    }
    
    @objc private func timeScopeLabelClicked() {
        let alert = UIAlertController(title: "",
                                      message: "",
                                      preferredStyle: .alert)
        let easyAction = UIAlertAction(title: GV.language.getText(.tcAll), style: .default,
                                       handler: {[unowned self] (paramAction:UIAlertAction!) in
                                        try! realm.safeWrite() {
                                            GV.basicDataRecord.showingTimeScope = TimeScope.All.rawValue
                                        }
                                        GCHelper.shared.getScoresForShow(completion: {self.showTable()})
        })
        alert.addAction(easyAction)
        let mediumAction = UIAlertAction(title: GV.language.getText(.tcWeek), style: .default,
                                         handler: {[unowned self] (paramAction:UIAlertAction!) in
                                            try! realm.safeWrite() {
                                                GV.basicDataRecord.showingTimeScope = TimeScope.Week.rawValue
                                            }
                                            GCHelper.shared.getScoresForShow(completion: {self.showTable()})
        })
        alert.addAction(mediumAction)
        let wordCountAction = UIAlertAction(title: GV.language.getText(.tcToday), style: .default,
                                            handler: {[unowned self] (paramAction:UIAlertAction!) in
                                                try! realm.safeWrite() {
                                                    GV.basicDataRecord.showingTimeScope = TimeScope.Today.rawValue
                                                }
                                                GCHelper.shared.getScoresForShow(completion: {self.showTable()})
        })
        alert.addAction(wordCountAction)
        view?.window?.rootViewController?.present(alert, animated: true, completion: nil)
    }

    public func setDelegate(delegate: ShowGamesSceneDelegate) {
        myDelegate = delegate
    }

    private func removeLabels() {
        if view != nil {
            for subView in view!.subviews as [UIView] {
                if type(of: subView) == UILabel.self {
                    subView.removeFromSuperview()
                }
            }
        }
    }

    @objc public func goBack(gameNumberSelected: Bool = false, gameNumber: Int = 0, restart: Bool = false) {
        removeLabels()
        if showTableView != nil {
            showTableView!.isHidden = true
            showTableView = nil
        }
         if myDelegate == nil {
            return
        }
        myDelegate!.backToMenuScene(gameNumberSelected: gameNumberSelected, gameNumber: gameNumber, restart: restart)
    }

    var showTableView: WTTableView?
    let myFont = UIFont(name: "CourierNewPS-BoldMT", size: GV.onIpad ? 18 : 14)
    var lineHeight: CGFloat = 0
    var realmLoadingCompleted = false

    private func showFoundedWordsInTableView() {
        if showTableView != nil {
            showTableView!.removeFromSuperview()
        }
        showTableView = WTTableView()
        calculateColumnWidths()
        showTableView?.setDelegate(delegate: self)
        showTableView?.register(CustomTableViewCell.self, forCellReuseIdentifier: "cell")

        let origin = CGPoint(x: 0.5 * (self.frame.width - title.width(font: myFont!)), y: 0)
        lineHeight = title.height(font: myFont!)
        let headerframeHeight = lineHeight * 2.2
        var showingWordsHeight = CGFloat(foundedRecords.count) * 2 * lineHeight
        if showingWordsHeight  > self.frame.height * 0.5 {
            var counter = CGFloat(foundedRecords.count)
            repeat {
                counter -= 1
                showingWordsHeight = lineHeight * counter
            } while showingWordsHeight + headerframeHeight > self.frame.height * (GV.onIpad ? 1.8 : 1.2)
        }
        let height = showingWordsHeight + headerframeHeight
        let size = CGSize(width: widthOfView, height: height)
        showTableView?.frame=CGRect(origin: origin, size: size)
        let center = CGPoint(x: 0.5 * view!.frame.width, y: self.view!.frame.height * 0.1 + height / 2)
        self.showTableView!.center=center
        self.showTableView!.reloadData()

        self.scene?.view?.addSubview(showTableView!)
        removeLabels()
//        createChooseTypeLabel(yPos: showTableView!.frame.maxY + lineHeight * 2)
//        createChooseTimeScopeLabel(yPos: showTableView!.frame.maxY + 4 * lineHeight)
        createLabel(text: GV.language.getText(.tcChooseWhatYouWant), target: #selector(typeLabelClicked), lineNr: 1)
        createLabel(text: GV.language.getText(.tcChooseTimeScope), target: #selector(timeScopeLabelClicked), lineNr: 2)
        createLabel(text: GV.language.getText(.tcBack), target: #selector(goBack), lineNr: 3)
//        createGoBackLabel(yPos: showTableView!.frame.maxY + 6 * lineHeight)
    }
    
    
    var timer = Timer()
    var missingRecords = [Int]()

    var goOn = true
    

    var title = ""
    
    struct ColumnLengths {
        var text = ""
        var length = 0
        init(text: String, length: Int){
            self.text = text
            self.length = length
        }
    }
    
    var columns = [ColumnLengths]()

    private func calculateColumnWidths() {
        actType = ScoreType(rawValue: GV.basicDataRecord.showingScoreType)!
        columns.removeAll()
        let text0 = GV.language.getText(.tcLanguage)
        let text1 = GV.language.getText(.tcWord)
        let text2 = GV.language.getText(.tcStatus)
        let text3 = "Accept"
        let text4 = "Decline"
        var lengthOfLanguage = text0.length
        var lengthOfWord = text1.length
        var lengthOfStatus = text2.length
        let lengthOfAccept = text3.length
        let lengthOfDecline = text4.length

        for item in foundedRecords {
            lengthOfLanguage = String(item.language).length > lengthOfLanguage ? String(item.language).length : lengthOfLanguage
            lengthOfWord = String(item.word).length > lengthOfWord ? String(item.word).length : lengthOfWord
            lengthOfStatus = String(item.status).length > lengthOfStatus ? String(item.status).length : lengthOfStatus
        }
        columns.append(ColumnLengths(text: text0, length: lengthOfLanguage + 2))
        columns.append(ColumnLengths(text: text1, length: lengthOfWord + 2))
        columns.append(ColumnLengths(text: text2, length: lengthOfStatus + 2))
        columns.append(ColumnLengths(text: text3, length: lengthOfAccept + 2))
        columns.append(ColumnLengths(text: text4, length: lengthOfDecline + 2))
        widthOfView = 0
        for column in columns {
            widthOfView += column.text.fixLength(length: column.length).width(font:myFont!)
        }
   }
    var widthOfView:CGFloat = 0

    func fillHeaderView(tableView: UITableView, section: Int) -> UIView {
        let textColor: UIColor = .black
        let view = UIView()
//        let label1 = UILabel(frame: CGRect(x: 0, y: 0, width: widthOfView, height: lineHeight))
//        label1.font = myFont!
//        let textConstant: TextConstants  = actType == .Easy ? .tcTableOfEasyBestscores : actType == .Medium ? .tcTableOfMediumBestscores : .tcTableOfWordCounts
//        label1.text = GV.language.getText(textConstant).fixLength(length: title.length, center: true)
//        label1.textAlignment = .center
//        label1.textColor = textColor
//        view.addSubview(label1)
        
        var labelPos: CGFloat = 0

        let lineHeight = (myFont?.lineHeight)!// * (GV.onIpad ? 1.5 : 2.0)
        for column in columns {
            let width = column.text.fixLength(length:column.length).width(font:myFont!)
            let label = UILabel(frame: CGRect(x: labelPos, y: lineHeight, width: width, height: lineHeight))
            labelPos += width
            label.text = column.text.fixLength(length: column.length, leadingBlanks: false)
            label.textColor = textColor
            label.font = myFont!
//            widthOfView += width
            view.addSubview(label)
        }
//        let width = CGFloat(title.width(font: myFont!)) //lineHeight * CGFloat(title.length)
        //            view.frame = CGRect(x: 50, y: 0, width: width, height: 2 * lineHeight)
//        let label2 = UILabel(frame: CGRect(x: 0, y: lineHeight, width: width, height: lineHeight))
//        label2.font = myFont!
//        label2.text = title
//        view.addSubview(subView)
        view.backgroundColor = UIColor(red:240/255, green: 240/255, blue: 240/255, alpha: 1.0)
        return view
    }

    func didSelectedRow(tableView: UITableView, indexPath: IndexPath) {
        print("selected:\(foundedRecords[indexPath.row])")
    }

    func getHeightForHeaderInSection(tableView: UITableView, section: Int)->CGFloat {
        return GV.onIpad ? 48 : 30
    }
    func setHeaderView(tableView: UITableView, headerView: UIView, section: Int) {
    }


    let showWordsBackgroundColor = UIColor(red:255/255, green: 204/255, blue: 153/255, alpha: 1.0)
    let maxLengthMultiplier: CGFloat = GV.onIpad ? 12 : 8


    func getTableViewCell(tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
//        let color = UIColor(red: 240/255, green: 240/255, blue: 240/255,alpha: 1.0)
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! CustomTableViewCell
//        cell.accessoryType = .detailDisclosureButton
//        cell.selectionStyle = .none
//        cell.accessoryType = .detailDisclosureButton
        cell.setFont(font: myFont!)
        cell.setCellSize(size: CGSize(width: widthOfView, height: lineHeight * 2/*self.frame.height * (GV.onIpad ? 0.040 : 0.010)*/))
        cell.setBGColor(color: UIColor.white) //set to green when buttons not working!
        let cellColor = UIColor.white
        let text1 = foundedRecords[indexPath.row].language.fixLength(length: columns[0].length, leadingBlanks: false)
        cell.addColumn(text: text1, color: cellColor) // GameNumber
        let text2 = foundedRecords[indexPath.row].word.fixLength(length: columns[1].length - 2, leadingBlanks: false)
        cell.addColumn(text: text2, color: cellColor)
        let text3 = foundedRecords[indexPath.row].status.fixLength(length: columns[2].length)
        cell.addColumn(text: text3, color: cellColor) // My Score
        let xPos1 = String(repeating: " ", count: text1.length + text2.length + text3.length + columns[3].text.length / 2).width(font: myFont!)
        let origImage1 = UIImage(named: "online.png")
        let image1 = origImage1!.resizeImage(newWidth: lineHeight * 1.5)
        cell.addButton(image: image1, xPos: xPos1, callBack: acceptButtonTapped, indexPath: indexPath)
        let xPos2 = String(repeating: " ", count: text1.length + text2.length + text3.length + columns[3].text.length + columns[4].length / 2 + 3).width(font: myFont!)
        let origImage2 = UIImage(named: "offline.png")
        let image2 = origImage2!.resizeImage(newWidth: lineHeight * 1.5)
        cell.addButton(image: image2, xPos: xPos2, callBack: declineButtonTapped, indexPath: indexPath)
        return cell
    }
    
    private func modifyRecord(recordID: String, newStatus: String) {
        let recordID = CKRecord.ID(recordName: recordID)
        let container = CKContainer.default()
        container.publicCloudDatabase.fetch(withRecordID: recordID) { record, error in

            if let record = record, error == nil {

                record["status"] = newStatus
                record["lastChanged"] = Date()

                container.publicCloudDatabase.save(record) { _, error in
                    self.getNewWordsFromCloud(completion: self.showTable)
                    print("saved!")
                }
            }
        }
    }
    
    func acceptButtonTapped(indexPath: IndexPath) {
        modifyRecord(recordID: foundedRecords[indexPath.row].name, newStatus: GV.accepted)
    }
    
    func declineButtonTapped(indexPath: IndexPath) {
        modifyRecord(recordID: foundedRecords[indexPath.row].name, newStatus: GV.denied)
    }

    func getNumberOfSections() -> Int {
        return 1
    }
    func getNumberOfRowsInSections(section: Int)->Int {
        let returnValue = foundedRecords.count
//        if GV.myPlace > gamesForShow.last!.place {
//            returnValue += 1
//        }
        return returnValue
    }

    func getHeightForRow(tableView: UITableView, indexPath: IndexPath) -> CGFloat {
        return lineHeight * 2//title.height(font: myFont!) * 1.15//1.12
    }
}
