//
//  ShowGameCenterViewController
//  MagicOfWords
//
//  Created by Jozsef Romhanyi on 17/09/2018.
//  Copyright © 2018 Jozsef Romhanyi. All rights reserved.
//

import UIKit
import RealmSwift
import GameplayKit

#if DEBUG

class ShowGameCenterViewController: UIViewController, WTTableViewDelegate {
    var showGameCenterView: WTTableView? = WTTableView()
//    var headerLine = [String]()
    let color = UIColor(red: 230/255, green: 230/255, blue: 240/255, alpha: 1.0)
    let indexOfOnlineImage = 0
    let indexOfAlias = 1
    let indexOfDevice = 2
    let indexOfLand = 3
    let indexOfOnlineTime = 4
    let indexOfLastOnline = 5
    let indexOfOnlineDuration = 6
    let indexOfVersion = 7
    let indexOfEasyScore = 8
    let indexOfMediumScore = 9
    let indexOfEasyActScore = 10
    let indexOfMediumActScore = 11
    let indexOfCountPlays = 12
    
    enum ShowingModus: Int {
        case Left = 0, Right
    }
    
    var showingModus: ShowingModus = .Left

    //    var lengthOfOnlineSince = 0
    let myFont = UIFont(name: GV.actLabelFont, size: GV.onIpad ? 16 : 10)
    
    func didTappedButton(tableView: UITableView, indexPath: IndexPath, buttonName: String) {
        
    }
    

    
    func didSelectedRow(tableView: UITableView, indexPath: IndexPath) {
    }

    func getNumberOfSections() -> Int {
        return 1
    }
    
    func getNumberOfRowsInSections(section: Int) -> Int {
        return GV.globalInfoTable.count
    }
    
    @objc public func buttonTapped(indexPath: IndexPath) {
        
    }
    
//    private func yearMonthDayString(value: Int)-> String {
//        var returnValue = ""
//        if value > 0 {
//            let year = String(value / 10000)
//            var month = String((value % 10000) / 100)
//            month = month.length == 1 ? "0" + month : month
//            var day = String((value % 10000) % 100)
//            day = day.length == 1 ? "0" + day : day
//            returnValue = year + "-" + month + "-" + day
//        }
//        return returnValue
//    }
    

    
    func getTableViewCell(tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        let actColor = (indexPath.row % 2 == 0 ? UIColor.white : color)
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! CustomTableViewCell
        let cellWidth = tableView.frame.width
        let cellHeight = " ".height(font: myFont!) * 1.0
        cell.setFont(font: myFont!)
        cell.setCellSize(size: CGSize(width: cellWidth, height: cellHeight))
//        cell.setCellSize(size: CGSize(width: tableView.frame.width * (GV.onIpad ? 0.040 : 0.010), height: self.view.frame.width * (GV.onIpad ? 0.040 : 0.010)))
        cell.setBGColor(color: actColor) //showWordsBackgroundColor)
        let isOnline = GV.globalInfoTable[indexPath.row].isOnline
        let origImage = UIImage(named: isOnline ? "online.png" : "offline.png")!
        let image = origImage.resizeImage(newWidth: cellHeight * 0.6)
        let index = indexOfAlias
        cell.addButton(image: image, xPos: cellHeight * 0.5, callBack: buttonTapped)
        cell.addColumn(text: " " + (GV.globalInfoTable[indexPath.row].alias.fixLength(length: lengths[index], leadingBlanks: false)), color: actColor, xPos: cellHeight * 1.0) // WordColumn
        switch showingModus {
        case .Left:
            cell.addColumn(text: (GV.globalInfoTable[indexPath.row].device.fixLength(length: lengths[index + 1], leadingBlanks: false)), color: actColor)
            cell.addColumn(text: GV.globalInfoTable[indexPath.row].version.fixLength(length: lengths[index + 2], leadingBlanks: false), color: actColor)
            cell.addColumn(text: (GV.globalInfoTable[indexPath.row].land.fixLength(length: lengths[index + 3], leadingBlanks: false)), color: actColor)
            cell.addColumn(text: String(GV.globalInfoTable[indexPath.row].allTime.HourMin).fixLength(length: lengths[index + 4], leadingBlanks: false), color: actColor)
            if GV.onIpad {
                cell.addColumn(text: GV.globalInfoTable[indexPath.row].lastDay.yearMonthDay().fixLength(length: lengths[index + 5], leadingBlanks: false), color: actColor)
                cell.addColumn(text: String(GV.globalInfoTable[indexPath.row].lastTime.HourMin).fixLength(length: lengths[index + 6], leadingBlanks: false), color: actColor)
                cell.addColumn(text: String(GV.globalInfoTable[indexPath.row].easyBestScore).fixLength(length: lengths[index + 7], leadingBlanks: false), color: actColor)
                cell.addColumn(text: GV.globalInfoTable[indexPath.row].mediumBestScore.fixLength(length: lengths[index + 8], leadingBlanks: false), color: actColor)
            }
        case .Right:
            cell.addColumn(text: String(GV.globalInfoTable[indexPath.row].allTime.HourMin).fixLength(length: lengths[index + 1], leadingBlanks: false), color: actColor)
            cell.addColumn(text: GV.globalInfoTable[indexPath.row].lastDay.yearMonthDay().fixLength(length: lengths[index + 2], leadingBlanks: false), color: actColor)
            cell.addColumn(text: String(GV.globalInfoTable[indexPath.row].lastTime.HourMin).fixLength(length: lengths[index + 3], leadingBlanks: false), color: actColor)
            cell.addColumn(text: String(GV.globalInfoTable[indexPath.row].easyBestScore).fixLength(length: lengths[index + 4], leadingBlanks: false), color: actColor)
           if GV.onIpad {
                cell.addColumn(text: GV.globalInfoTable[indexPath.row].mediumBestScore.fixLength(length: lengths[index + 5], leadingBlanks: false), color: actColor)
                cell.addColumn(text: String(GV.globalInfoTable[indexPath.row].easyActScore).fixLength(length: lengths[index + 6], leadingBlanks: false), color: actColor)
                cell.addColumn(text: GV.globalInfoTable[indexPath.row].mediumActScore.fixLength(length: lengths[index + 7], leadingBlanks: false), color: actColor)
                cell.addColumn(text: GV.globalInfoTable[indexPath.row].countPlays.fixLength(length: lengths[index + 8], leadingBlanks: false), color: actColor)
            }
        }
        return cell
    }
    
    func getHeightForRow(tableView: UITableView, indexPath: IndexPath) -> CGFloat {
        return " ".height(font: myFont!)
    }
    
    func setHeaderView(tableView: UITableView, headerView: UIView, section: Int) {
    }
    
    func fillHeaderView(tableView: UITableView, section: Int) -> UIView {
        let view = UIView()
        var lastPosX: CGFloat = 0
        let textConstants = showingModus == ShowingModus.Left ? headerTextContantsLeft : headerTextContantsRight
        for (index, textConstant) in textConstants.enumerated() {
            let text = GV.language.getText(textConstant)
            let width = text.fixLength(length: lengths[index]).width(withConstrainedHeight: 0, font: myFont!)// * 1.1
            let height = text.height(font: myFont!)
            let label = UILabel(frame: CGRect(x: lastPosX, y: CGFloat(0), width: width, height: height))
            label.text = text
            label.font = myFont!
            view.addSubview(label)
            lastPosX += width
        }
        view.backgroundColor = UIColor(red:240/255, green: 240/255, blue: 240/255, alpha: 1.0)
        return view
    }
    
    func getHeightForHeaderInSection(tableView: UITableView, section: Int) -> CGFloat {
        return " ".height(font: myFont!)
    }
    var calculatedWidth: CGFloat = 0
    var lengths = [Int]()
    let headerTextContantsLeft: [TextConstants] = [.tcBlank, .tcPlayer, .tcDevice, .tcVersion, .tcLand, .tcOnlineTime, .tcLastOnline, .tcLastOnlineTime, .tcEasyScore, .tcMediumScore]
    let headerTextContantsRight: [TextConstants] = [.tcBlank, .tcPlayer, .tcOnlineTime, .tcLastOnline, .tcLastOnlineTime, .tcEasyScore, .tcMediumScore, .tcEasyActScore, .tcMediumActScore, .tcCountPlays]
    
    private func calculateColumnWidths() {
        calculatedWidth = 0
        lengths.removeAll()
        switch showingModus {
        case .Left:
            for textConstant in headerTextContantsLeft {
                lengths.append(GV.language.getText(textConstant).length)
            }
        case .Right:
            for textConstant in headerTextContantsRight {
                lengths.append(GV.language.getText(textConstant).length)
            }
        }
        let index = indexOfAlias
        for item in GV.globalInfoTable {
            lengths[indexOfAlias] = item.alias.length > lengths[indexOfAlias] ? item.alias.length : lengths[indexOfAlias]
            if showingModus == ShowingModus.Left {
                lengths[index + 1] = item.device.length > lengths[index + 1] ? item.device.length : lengths[index + 1]
                lengths[index + 2] = item.version.length > lengths[index + 2] ? item.version.length : lengths[index + 2]
                lengths[index + 3] = item.land.length > lengths[index + 3] ? item.land.length : lengths[index + 3]
                lengths[index + 4] = item.allTime.HourMin.length > lengths[index + 4] ? item.allTime.HourMin.length : lengths[index + 4]
                if GV.onIpad {
                    lengths[index + 5] = item.lastDay.yearMonthDay().length > lengths[index + 5] ? item.lastDay.yearMonthDay().length : lengths[index + 5]
                    lengths[index + 6] = item.lastTime.HourMin.length > lengths[index + 6] ? item.lastTime.HourMin.length : lengths[index + 6]
                    lengths[index + 7] = item.easyBestScore.length > lengths[index + 7] ? item.easyBestScore.length : lengths[index + 7]
                    lengths[index + 8] = item.mediumBestScore.length > lengths[index + 8] ? item.mediumBestScore.length : lengths[index + 8]
                }
            } else  {
                lengths[index + 1] = item.allTime.HourMin.length > lengths[index + 1] ? item.allTime.HourMin.length : lengths[index + 1]
                lengths[index + 2] = item.lastDay.yearMonthDay().length > lengths[index + 2] ? item.lastDay.yearMonthDay().length : lengths[index + 2]
                lengths[index + 3] = item.lastTime.HourMin.length > lengths[index + 3] ? item.lastTime.HourMin.length : lengths[index + 3]
                lengths[index + 4] = item.easyBestScore.length > lengths[index + 4] ? item.easyBestScore.length : lengths[index + 4]
                if GV.onIpad {
                    lengths[index + 5] = item.mediumBestScore.length > lengths[index + 5] ? item.mediumBestScore.length : lengths[index + 5]
                    lengths[index + 6] = item.easyActScore.length > lengths[index + 6] ? item.easyActScore.length : lengths[index + 6]
                    lengths[index + 7] = item.mediumActScore.length > lengths[index + 7] ? item.mediumActScore.length : lengths[index + 7]
                    lengths[index + 8] = item.countPlays.length > lengths[index + 8] ? item.countPlays.length : lengths[index + 8]
                }
            }
       }
        let adder = 2
        for (index, _) in lengths.enumerated() {
            lengths[index] += adder
            let fixText = " ".fixLength(length: lengths[index])
            calculatedWidth += fixText.width(font: myFont!)// * 1.1
            if !GV.onIpad {
                if index > 4 {
                    break
                }
            }
        }
//        " ".removeAll()
//        var text1 = ""
//        var text2 = ""
//        var text3 = ""
//        var text4 = ""
//        var text5 = ""
//        var text6 = ""
//        var text7 = ""
//        var text8 = ""
//        var text9 = ""
//        text1 = "\(GV.language.getText(.tcPlayer)) ".fixLength(length: lengths[indexOfAlias], center: true)
//        text2 = "\(GV.language.getText(.tcDevice)) ".fixLength(length: lengths[indexOfDevice], center: true)
//        text3 = "\(GV.language.getText(.tcVersion))".fixLength(length: lengths[indexOfVersion], center: true)
//        text4 = "\(GV.language.getText(.tcLand)) ".fixLength(length: lengths[indexOfLand], center: true)
//        text5 = "\(GV.language.getText(.tcOnlineTime)) ".fixLength(length: lengths[indexOfOnlineTime], center: true)
//        if GV.onIpad {
//            text6 = "\(GV.language.getText(.tcLastOnline))".fixLength(length: lengths[indexOfLastOnline], center: true)
//            text7 = "\(GV.language.getText(.tcLastOnlineTime))".fixLength(length: lengths[indexOfOnlineDuration], center: true)
//            text8 = "\(GV.language.getText(.tcEasyScore))".fixLength(length: lengths[indexOfEasyScore], center: true)
//            text9 = "\(GV.language.getText(.tcMediumScore))".fixLength(length: lengths[indexOfMediumScore], center: true)
//        }
//        var line = ""
//        line += text1
//        line += text2
//        line += text3
//        line += text4
//        line += text5
//        line += text6
//        line += text7
//        line += text8
//        line += text9
//        headerLine.append(line)
//        text1 = "\(GV.language.getText(.tcPlayer)) ".fixLength(length: lengths[indexOfAlias], center: true)
//        text2 = "\(GV.language.getText(.tcOnlineTime)) ".fixLength(length: lengths[indexOfOnlineTime], center: true)
//        text3 = "\(GV.language.getText(.tcLastOnline))".fixLength(length: lengths[indexOfLastOnline], center: true)
//        text4 = "\(GV.language.getText(.tcLastOnlineTime))".fixLength(length: lengths[indexOfOnlineDuration], center: true)
//        if GV.onIpad {
//            text5 = "\(GV.language.getText(.tcEasyScore))".fixLength(length: lengths[indexOfEasyScore], center: true)
//            text6 = "\(GV.language.getText(.tcMediumScore))".fixLength(length: lengths[indexOfMediumScore], center: true)
//            text7 = "\(GV.language.getText(.tcEasyActScore))".fixLength(length: lengths[indexOfEasyActScore], center: true)
//            text8 = "\(GV.language.getText(.tcMediumActScore))".fixLength(length: lengths[indexOfMediumActScore], center: true)
//            text9 = "\(GV.language.getText(.tcCountPlays))".fixLength(length: lengths[indexOfCountPlays], center: true)
//        }
//        line = ""
//        line += text1
//        line += text2
//        line += text3
//        line += text4
//        line += text5
//        line += text6
//        line += text7
//        line += text8
//        line += text9
//        headerLine.append(line)

        
    }
    
    //    let realm: Realm
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        //        let syncConfig = SyncConfiguration(user: GV.myUser!, realmURL: GV.REALM_URL, isPartial: true)
        //        self.realm = try! Realm(configuration: Realm.Configuration(syncConfiguration: syncConfig, objectTypes:[PlayerActivity.self]))
//        self.playerActivityItems = RealmService.objects(PlayerActivity.self).filter("isOnline == true").sorted(byKeyPath: "nickName", ascending: true)
//        self.gameRecords = RealmService.objects(BestScoreForGame.self).filter("isOnline == true").sorted(byKeyPath: "nickName", ascending: true)
        //       self.playerActivityItems = RealmService.objects(PlayerActivity.self).sorted(byKeyPath: "nickName", ascending: true)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    var initialLoadDone = false
    var buttonRadius = CGFloat(0)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let myBackgroundImage = UIImageView (frame: UIScreen.main.bounds)
        myBackgroundImage.image = UIImage(named: "magier")
        myBackgroundImage.contentMode = UIView.ContentMode.scaleAspectFill
        self.view.insertSubview(myBackgroundImage, at: 0)
        view.addSubview(showGameCenterView!)
        showGameCenterView!.setDelegate(delegate: self)
//        createButtons()
        GCHelper.shared.getAllGlobalInfos(completion: {self.allGlobalDataLoaded()})
        showingModus = .Left
        buttonsCreated = false
        buttonRadius = self.view.frame.width / 25

    }
    
    @objc private func allGlobalDataLoaded() {
        showPlayerActivity()
    }
    
    @objc func stopShowingTable() {
        showGameCenterView!.isHidden = true
        dismiss(animated: true, completion: {
            print("Dismissed")
        })
    }
    
    @objc func leftButtonTapped() {
        showingModus = .Left
        calculateColumnWidths()
        showGameCenterView!.reloadData()
    }
    
    @objc func rightButtonTapped() {
        showingModus = .Right
        calculateColumnWidths()
        showGameCenterView!.reloadData()
    }

    var enabled = true
    var doneButton: UIButton?
    var leftButton: UIButton?
    var rightButton: UIButton?
    var bestButton: UIButton?
    var sortButton: UIButton?
    let bgColor = SKColor(red: 223/255, green: 255/255, blue: 216/255, alpha: 0.8)
    let playersTitle = "Player"
    let allTitle = "All"
    let bestTitle = "Best"
    let myTitleFont = UIFont(name: GV.actFont, size: GV.onIpad ? 30 : 10)
    var sortUp = true
    var buttonsCreated = false

    private func createButtons() {
        let buttonCenterDistance = (showGameCenterView!.frame.size.width - 2 * buttonRadius) / 4
        let buttonFrameWidth = 2 * buttonRadius
        let buttonFrame = CGRect(x: 0, y: 0, width:buttonFrameWidth, height: buttonFrameWidth)
        let yPos = showGameCenterView!.frame.maxY + buttonRadius * 1.2
        let xPos1 = showGameCenterView!.frame.minX + buttonRadius
        let center1 = CGPoint(x: xPos1, y:yPos)
        doneButton = createButton(imageName: "hook", imageSize: 0.05, title: "", frame: buttonFrame, center: center1, enabled: enabled)
        doneButton?.addTarget(self, action: #selector(self.stopShowingTable), for: .touchUpInside)
        self.view?.addSubview(doneButton!)
        
        let xPos2 = showGameCenterView!.frame.minX + buttonRadius + buttonCenterDistance
        let center2 = CGPoint(x: xPos2, y:yPos)
        leftButton = createButton(imageName: "LeftSimple", imageSize: 0.05, title: "", frame: buttonFrame, center: center2, enabled: enabled)
        leftButton?.addTarget(self, action: #selector(self.leftButtonTapped), for: .touchUpInside)
        self.view?.addSubview(leftButton!)
        let xPos3 = showGameCenterView!.frame.minX + buttonRadius + buttonCenterDistance * 2
        let center3 = CGPoint(x: xPos3, y:yPos)
        rightButton = createButton(imageName: "RightSimple", imageSize: 0.05, title: "", frame: buttonFrame, center: center3, enabled: enabled)
        rightButton!.addTarget(self, action: #selector(self.rightButtonTapped), for: .touchUpInside)
        self.view!.addSubview(rightButton!)
//        let xPos4 = showGameCenterView!.frame.minX + buttonRadius + buttonCenterDistance * 3
//        let center4 = CGPoint(x: xPos4, y:yPos)
//        bestButton = createButton(imageName: "firstplaces.png", imageSize: 0.05, title: "", frame: buttonFrame, center: center4, enabled: enabled)
//        bestButton?.addTarget(self, action: #selector(self.bestButtonTapped), for: .touchUpInside)
//        self.view?.addSubview(bestButton!)
//        let xPos5 = showGameCenterView!.frame.minX + buttonRadius + buttonCenterDistance * 4
//        let center5 = CGPoint(x: xPos5, y:yPos)
//        sortButton = createButton(imageName: "sortdown.png", imageSize: 0.5, title: "", frame: buttonFrame, center: center5, enabled: enabled)
//        sortButton!.addTarget(self, action: #selector(self.sortButtonTapped), for: .touchUpInside)
//        self.view?.addSubview(sortButton!)
//        self.buttonsCreated = true
    }
    
    private func modifyButtonsPosition() {
        let height = showGameCenterView!.frame.height * 0.5
        let center = self.view.frame.midY
        let calculatedYPos = center + height + self.buttonRadius * 1.2
        doneButton!.center = CGPoint(x: doneButton!.center.x, y: calculatedYPos)
        leftButton!.center = CGPoint(x: leftButton!.center.x, y: calculatedYPos)
        rightButton!.center = CGPoint(x: rightButton!.center.x, y: calculatedYPos)
        bestButton!.center = CGPoint(x: bestButton!.center.x, y: calculatedYPos)
        sortButton!.center = CGPoint(x: sortButton!.center.x, y: calculatedYPos)
    }
    
    private func createButton(imageName: String, title: String, frame: CGRect, center: CGPoint, cornerRadius: CGFloat, enabled: Bool)->UIButton {
        let button = UIButton()
        if imageName.length > 0 {
            let image = UIImage(named: imageName)
            button.setImage(image, for: UIControl.State.normal)
        }
        if title.length > 0 {
            button.setTitle(title, for: .normal)
            button.setTitleColor(UIColor.black, for: .normal)
            button.titleLabel?.font = UIFont(name: GV.actFont, size: GV.onIpad ? 30 : 18)
            
        }
        button.backgroundColor = bgColor
        button.layer.cornerRadius = cornerRadius
        button.alpha = enabled ? 1.0 : 0.2
        button.isEnabled = enabled
        button.layer.borderWidth = GV.onIpad ? 5 : 3
        button.layer.borderColor = UIColor(red: 220/255, green: 220/255, blue: 220/255, alpha: 1.0).cgColor
        button.frame = frame
        button.center = center
        return button
    }
    


    private func createButton(imageName: String, imageSize: CGFloat = 1.0, title: String, frame: CGRect, center: CGPoint, enabled: Bool, color: UIColor? = nil)->UIButton {
        let button = UIButton()
        if imageName.length > 0 {
            let image = resizeImage(image: UIImage(named: imageName)!, newWidth: view.frame.width * imageSize)
            button.setImage(image, for: UIControl.State.normal)
        }
        if title.length > 0 {
            button.setTitle(title, for: .normal)
            button.setTitleColor(UIColor.black, for: .normal)
            button.titleLabel?.font = myTitleFont
        }
        button.backgroundColor = color == nil ? bgColor : color
        button.layer.cornerRadius = buttonRadius
        button.alpha = enabled ? 1.0 : 0.2
        button.isEnabled = enabled
        button.layer.borderWidth = GV.onIpad ? 5 : 3
        button.layer.borderColor = UIColor(red: 220/255, green: 220/255, blue: 220/255, alpha: 1.0).cgColor
        button.frame = frame
        button.center = center
        return button
    }
    
    private func setNewTableView() {
        sortUp = true
        initialLoadDone = false
        showGameCenterView!.removeFromSuperview()
        showGameCenterView = nil
        showGameCenterView = WTTableView()
        showGameCenterView!.setDelegate(delegate: self)
    }
    
    func resizeImage(image: UIImage, newWidth: CGFloat) -> UIImage {
        
        let scale = newWidth / image.size.width
        let newHeight = image.size.height * scale
        UIGraphicsBeginImageContext(CGSize(width: newWidth, height: newHeight))
        image.draw(in: CGRect(x: 0, y: 0, width: newWidth, height: newHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
    
    private func showPlayerActivity() {
        let textHeight = GV.language.getText(.tcBlank)
        calculateColumnWidths()
        let origin = CGPoint(x: 0, y: 0)
        let maxHeight = view.frame.height * 0.8
        let calculatedHeight = textHeight.height(font: myFont!) * (CGFloat(GV.globalInfoTable.count + 1))
        let height = maxHeight > calculatedHeight ? calculatedHeight : maxHeight
        let size = CGSize(width: calculatedWidth, height:height)
        let center = CGPoint(x: 0.5 * view.frame.width, y: 0.5 * view.frame.height)
        showGameCenterView!.frame=CGRect(origin: origin, size: size)
        showGameCenterView!.center=center
        //        showGameCenterView!.frame = self.view.frame
        if !buttonsCreated {
            createButtons()
        }
//        modifyButtonsPosition()
        showGameCenterView!.register(CustomTableViewCell.self, forCellReuseIdentifier: "cell")
        showGameCenterView!.reloadData()
    }

    
    private func setTableviewSize() {
        let origin = CGPoint(x: 0, y: 0)
        let maxHeight = view.frame.height * 0.8
        let calculatedHeight = " ".height(font: myFont!) * (CGFloat(GV.globalInfoTable.count + 1))
        let height = maxHeight > calculatedHeight ? calculatedHeight : maxHeight
        let size = CGSize(width: calculatedWidth, height: height)
        let center = CGPoint(x: 0.5 * view.frame.width, y: 0.5 * view.frame.height)
        showGameCenterView!.frame=CGRect(origin: origin, size: size)
        showGameCenterView!.center=center
        modifyButtonsPosition()
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}
#endif
