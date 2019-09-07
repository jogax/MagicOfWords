//
//  ShowFinishedGamesScene.swift
//  MagicOfWords
//
//  Created by Jozsef Romhanyi on 24/05/2018.
//  Copyright © 2018 Jozsef Romhanyi. All rights reserved.
//

import Foundation
import GameKit
import UIKit
import RealmSwift

public protocol ShowGamesSceneDelegate: class {
    func backToMenuScene(gameNumberSelected: Bool, gameNumber: Int, restart: Bool)
}
class ShowGamesScene: SKScene, WTTableViewDelegate {
    let xMultiplierTab: [CGFloat] = [0.3, 0.5, 0.8]
    var myDelegate: ShowGamesSceneDelegate?
    let OKLabelName = "°°°OKLabel°°°"
    let OKButtonName = "°°°OKButton°°°"
    let myTitleFont = UIFont(name: GV.actFont, size: GV.onIpad ? 30 : 10)
    var buttonHeight: CGFloat = 0
    var buttonLine: CGFloat = GV.onIpad ? 0.1 : 0.1


//    var allResultsItems: Results<BestScoreForGame>?
    var background = SKSpriteNode(imageNamed: "magier")
//    var notificationToken: NotificationToken?
//    var subscriptionToken: NotificationToken?
//    var subscription: SyncSubscription<BestScoreForGame>!
//    var showAll = true
    var parentViewController: UIViewController?

//    override func didMoveToView(view: SKView) {
//        background.position = CGPoint(x: frame.size.width / 2, y: frame.size.height / 2)
//        addChild(background)

    var initialLoadDone = false

    override func didMove(to view: SKView) {        
//        background.position = CGPoint(x: frame.size.width / 2, y: frame.size.height / 2)
        
        buttonHeight = frame.size.width * (GV.onIpad ? 0.08 : 0.125)
//        let widthMultiplier = background.size.width / background.size.height
        lineHeight =  "A".height(font: myFont!) * 1.25
//        background.size = CGSize(width: self.size.height * widthMultiplier, height: self.size.height)
//        addChild(background)
        createChooseTypeLabel()
        createChooseTimeScopeLabel()
        self.zPosition = 50
//        createButtons()
        if GV.scoreForShowTable.count > 0 {
            self.showTable()
        } else {
            goBack(gameNumberSelected: false, gameNumber: 0)
        }
//        })
    }
    
    var actType: ScoreType = .Easy
    private func showTable() {
        gamesForShow.removeAll()
        for item in GV.scoreForShowTable {
            if !item.player.lowercased().begins(with: "jogax") && item.scoreType == actType {
                let type = item.scoreType
                let timeScope = item.timeScope
                let place = gamesForShow.count == 0 ? 1 : gamesForShow.last!.place + 1
                let player = item.player
                let score = item.score
                let me = item.me
                gamesForShow.append(ScoreForShow(scoreType: type, timeScope: timeScope, place: place, player: player, score: score, me: me))
            }
        }
//        }
        
        if gamesForShow.count > 0 {
            showFoundedGamesInTableView()
        } else {
            goBack(gameNumberSelected: false, gameNumber: 0)
        }
   }
    
    private func createChooseTypeLabel() {

        let myX = self.frame.minX + self.frame.width * 0.3
        let myY = self.frame.minY + self.frame.height * 0.90
        let text = GV.language.getText(.tcChooseWhatYouWant)
        let width = text.width(font:myFont!)
        let height = text.height(font:myFont!)
        let label = UILabel(frame: CGRect(x: myX, y: myY, width: width, height: height))
        label.text = text
        label.font = myFont!
        label.textColor = .blue
        label.isUserInteractionEnabled = true
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(typeLabelClicked))
        label.addGestureRecognizer(gesture)
        view!.addSubview(label)
    }
    
    private func createChooseTimeScopeLabel() {
        
        let myX = self.frame.minX + self.frame.width * 0.6
        let myY = self.frame.minY + self.frame.height * 0.90
        let text = GV.language.getText(.tcChooseTimeScope)
        let width = text.width(font:myFont!)
        let height = text.height(font:myFont!)
        let label = UILabel(frame: CGRect(x: myX, y: myY, width: width, height: height))
        label.text = text
        label.font = myFont!
        label.textColor = .blue
        label.isUserInteractionEnabled = true
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(timeScopeLabelClicked))
        label.addGestureRecognizer(gesture)
        view!.addSubview(label)
    }

    
    @objc private func typeLabelClicked() {
        let alert = UIAlertController(title: "",
                                      message: "",
                                      preferredStyle: .alert)
        let easyAction = UIAlertAction(title: GV.language.getText(.tcEasyPlay), style: .default,
                                          handler: {[unowned self] (paramAction:UIAlertAction!) in
                                            self.actType = .Easy
                                            self.showTable()
        })
        alert.addAction(easyAction)
        let mediumAction = UIAlertAction(title: GV.language.getText(.tcMediumPlay), style: .default,
                                       handler: {[unowned self] (paramAction:UIAlertAction!) in
                                        self.actType = .Medium
                                        self.showTable()
        })
        alert.addAction(mediumAction)
        let wordCountAction = UIAlertAction(title: GV.language.getText(.tcWordCount), style: .default,
                                       handler: {[unowned self] (paramAction:UIAlertAction!) in
                                        self.actType = .WordCount
                                        self.showTable()
        })
        alert.addAction(wordCountAction)
        view?.window?.rootViewController?.present(alert, animated: true, completion: nil)
    }
    
    @objc private func timeScopeLabelClicked() {
        
    }

    public func setDelegate(delegate: ShowGamesSceneDelegate, controller: UIViewController) {
        myDelegate = delegate
        parentViewController = controller
    }

//    public func setSelect(all: Bool) {
//        self.showAll = all
//    }
//
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
//        let subscribes = RealmService.subscriptions()
//        for subscribe in subscribes {
//            subscribe.unsubscribe()
//        }
        goBack(gameNumberSelected: false, gameNumber: 0)
    }

    private func goBack(gameNumberSelected: Bool, gameNumber: Int, restart: Bool = false) {
        for subView in view!.subviews as [UIView] {
            if type(of: subView) == UILabel.self {
                subView.removeFromSuperview()
            }
        }
        if showGamesInTableView != nil {
            showGamesInTableView!.isHidden = true
            showGamesInTableView = nil
        }
         if myDelegate == nil {
            return
        }
        myDelegate!.backToMenuScene(gameNumberSelected: gameNumberSelected, gameNumber: gameNumber, restart: restart)
    }

    var showGamesInTableView: WTTableView?
    var gamesForShow = [ScoreForShow]()
    let myFont = UIFont(name: "CourierNewPS-BoldMT", size: GV.onIpad ? 18 : 12)
    var lineHeight: CGFloat = 0
    var realmLoadingCompleted = false

    private func showFoundedGamesInTableView() {
        if showGamesInTableView != nil {
            showGamesInTableView!.removeFromSuperview()
        }
        showGamesInTableView = WTTableView()
        calculateColumnWidths()
        showGamesInTableView?.setDelegate(delegate: self)
        showGamesInTableView?.register(CustomTableViewCell.self, forCellReuseIdentifier: "cell")

        let origin = CGPoint(x: 0.5 * (self.frame.width - title.width(font: myFont!)), y: 100)
//        let lineHeight = title.height(font: myFont!)
        let headerframeHeight = lineHeight * 2.2
        var showingWordsHeight = CGFloat(gamesForShow.count) * lineHeight
        if showingWordsHeight  > self.frame.height * 0.9 {
            var counter = CGFloat(gamesForShow.count)
            repeat {
                counter -= 1
                showingWordsHeight = lineHeight * counter
            } while showingWordsHeight + headerframeHeight > self.frame.height * 0.6
        }
//        let width = title.width(font: myFont!)
        let size = CGSize(width: widthOfView, height: showingWordsHeight + headerframeHeight)
        showGamesInTableView?.frame=CGRect(origin: origin, size: size)
        let center = CGPoint(x: 0.5 * view!.frame.width, y: 0.5 * self.view!.frame.height)
        self.showGamesInTableView!.center=center
        self.showGamesInTableView!.reloadData()

        self.scene?.view?.addSubview(showGamesInTableView!)
//        showAlert()
    }
    
    private func showAlert() {
        let alert = UIAlertController(title: GV.language.getText(.tcChooseWhatYouWant),
                                      message: "",
                                      preferredStyle: .alert)
        let easyAction = UIAlertAction(title: GV.language.getText(.tcEasyPlay), style: .default,
                                          handler: {(paramAction:UIAlertAction!) in
                                            self.actType = .Easy
                                            self.showTable()
                                            
        })
        alert.addAction(easyAction)
        
        let mediumAction = UIAlertAction(title: GV.language.getText(.tcMediumPlay), style: .default,
                                       handler: {(paramAction:UIAlertAction!) in
                                        self.actType = .Medium
                                        self.showTable()
                                        
        })
        alert.addAction(mediumAction)
        
        let wordCountAction = UIAlertAction(title: GV.language.getText(.tcWordCount), style: .default,
                                         handler: {(paramAction:UIAlertAction!) in
                                            self.actType = .WordCount
                                            self.showTable()
                                            
        })
        alert.addAction(wordCountAction)
        alert.view.center = CGPoint(x: self.frame.midX, y: self.frame.maxY * 0.9)
        view?.window?.rootViewController?.present(alert, animated: true, completion: nil)
//        self.scene?.view?.present(alert, animated: true, completion: nil)

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
        columns.removeAll()
        let text0 = GV.language.getText(.tcBlank)
        let text1 = GV.language.getText(.tcPlace)
        let text2 = GV.language.getText(.tcPlayerHeader)
        let text3 = GV.language.getText(.tcScore)
        let textConstant: TextConstants  = actType == .Easy ? .tcTableOfEasyBestscores : actType == .Medium ? .tcTableOfMediumBestscores : .tcTableOfWordCounts
        let text4 = GV.language.getText(textConstant)
        let lengthOfBlanks = text0.length
        var lengthOfPlace = text1.length
        var lengthOfPlayer = text2.length
        var lengthOfScore = text3.length
        
        for item in gamesForShow {
            let name = item.player + GV.language.getText(.tcMe)
            lengthOfPlace = String(item.place).length > lengthOfPlace ? String(item.place).length : lengthOfPlace
            lengthOfPlayer = name.length > lengthOfPlayer ? name.length : lengthOfPlayer
            lengthOfScore = String(item.score).length > lengthOfScore ? String(item.score).length : lengthOfScore
        }
        columns.append(ColumnLengths(text: text0, length: lengthOfBlanks + 2))
        columns.append(ColumnLengths(text: text1, length: lengthOfPlace + 2))
        columns.append(ColumnLengths(text: text2, length: lengthOfPlayer + 2))
        columns.append(ColumnLengths(text: text3, length: lengthOfScore + 2))
        widthOfView = 0
        for column in columns {
            widthOfView += column.text.fixLength(length: column.length).width(font:myFont!)
        }
        if text4.width(font: myFont!) > widthOfView {
            widthOfView = text4.width(font: myFont!)
        }
   }
    var widthOfView:CGFloat = 0
    
    func fillHeaderView(tableView: UITableView, section: Int) -> UIView {
        let view = UIView()
        
        let label1 = UILabel(frame: CGRect(x: 0, y: 0, width: widthOfView, height: lineHeight))
        label1.font = myFont!
        let textConstant: TextConstants  = actType == .Easy ? .tcTableOfEasyBestscores : actType == .Medium ? .tcTableOfMediumBestscores : .tcTableOfWordCounts
        label1.text = GV.language.getText(textConstant).fixLength(length: title.length, center: true)
        label1.textAlignment = .center
        view.addSubview(label1)
        
        var labelPos: CGFloat = 0

        let lineHeight = (myFont?.lineHeight)!// * (GV.onIpad ? 1.5 : 2.0)
        for column in columns {
            let width = column.text.fixLength(length:column.length).width(font:myFont!)
            let label = UILabel(frame: CGRect(x: labelPos, y: lineHeight, width: width, height: lineHeight))
            labelPos += width
            label.text = column.text.fixLength(length: column.length, leadingBlanks: false)
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
    }

    func getHeightForHeaderInSection(tableView: UITableView, section: Int)->CGFloat {
        return GV.onIpad ? 48 : 28
    }
    func setHeaderView(tableView: UITableView, headerView: UIView, section: Int) {
    }


    let showWordsBackgroundColor = UIColor(red:255/255, green: 204/255, blue: 153/255, alpha: 1.0)
    let maxLengthMultiplier: CGFloat = GV.onIpad ? 12 : 8


    func getTableViewCell(tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
//        let color = UIColor(red: 240/255, green: 240/255, blue: 240/255,alpha: 1.0)
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! CustomTableViewCell
        cell.setFont(font: myFont!)
        cell.setCellSize(size: CGSize(width: tableView.frame.width * (GV.onIpad ? 0.040 : 0.010), height: lineHeight/*self.frame.height * (GV.onIpad ? 0.040 : 0.010)*/))
        cell.setBGColor(color: UIColor.white) //showWordsBackgroundColor)
        var cellColor = UIColor.white
        var playerName = gamesForShow[indexPath.row].player
        if playerName == GKLocalPlayer.local.alias {
            cellColor = UIColor.white
            playerName += GV.language.getText(.tcMe)
        }
        let text0 = GV.language.getText(.tcBlank)
        cell.addColumn(text: text0, color: cellColor)
        let text1 = String(gamesForShow[indexPath.row].place).fixLength(length: columns[1].length)
        cell.addColumn(text: text1, color: cellColor) // GameNumber
        let text2 = "  " + (playerName).fixLength(length: columns[2].length - 2, leadingBlanks: false)
        cell.addColumn(text: text2, color: cellColor)
        let text3 = (String(gamesForShow[indexPath.row].score)).fixLength(length: columns[3].length)
        cell.addColumn(text: text3, color: cellColor) // My Score
//        cell.addColumn(text: String(gamesForShow[indexPath.row].place).fixLength(length: 4) )
        return cell
    }

    @objc public func buttonTapped(indexPath: IndexPath) {

    }

    func getNumberOfSections() -> Int {
        return 1
    }
    func getNumberOfRowsInSections(section: Int)->Int {
        let returnValue = gamesForShow.count
//        if GV.myPlace > gamesForShow.last!.place {
//            returnValue += 1
//        }
        return returnValue
    }

    func getHeightForRow(tableView: UITableView, indexPath: IndexPath) -> CGFloat {
        return lineHeight//title.height(font: myFont!) * 1.15//1.12
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
    

    private func createButtons() {
        
        func createButton(type: ScoreType, position: CGFloat) {
            var title = ""
            var selector: Selector?
            switch type {
            case .Easy:
                title = GV.language.getText(.tcEasyPlay)
                selector = #selector(showEasyTable)
            case .Medium:
                title = GV.language.getText(.tcMediumPlay)
                selector = #selector(showMediumTable)
            case .WordCount:
                title = GV.language.getText(.tcWordCount)
                selector = #selector(showWordCountTable)
            default: break
            }
            let wordLength = title.width(font: myTitleFont!)
            //        let wordHeight = title.height(font: myTitleFont!)
            let size = CGSize(width:wordLength * 1.4, height: buttonHeight)
            let ownHeaderYPos = self.frame.height * buttonLine
            let buttonCenter = CGPoint(x:self.frame.width * 0.3 * position, y: ownHeaderYPos)
            //        let radius = frame.height * 0.5
            let button = createMyButton(title: title, size: size, center: buttonCenter, enabled: true )
            button.isHidden = false
            button.setButtonAction(target: self, triggerEvent:.TouchUpInside, action: selector!)
            button.zPosition = 100
            self.addChild(button)
        }
        createButton(type: .Easy, position: 1)
        createButton(type: .Medium, position: 2)
        createButton(type: .WordCount, position: 3)
    }
    
    @objc private func showEasyTable() {
        
    }
    
    @objc private func showMediumTable() {
        
    }
    @objc private func showWordCountTable() {
        
    }

}
