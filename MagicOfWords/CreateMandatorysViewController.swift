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

class CreateMandatoryWordsViewController: UIViewController, WTTableViewDelegate {
    var showMandatoryWordsView: WTTableView? = WTTableView()
    let myFont = UIFont(name: "CourierNewPS-BoldMT", size: GV.onIpad ? 18 : 15)

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
        getSavedMandatoryWords()
    }
    
    private func getSavedMandatoryWords() {
        savedMandatoryWords = createSavedMandatoryWords()
        mandatoryItems = RealmService.objects(CommonString.self).filter("word BEGINSWITH %@", GV.actLanguage).sorted(byKeyPath: "word", ascending: true)
        mandatorySubscription = mandatoryItems!.subscribe(named: "\(GV.actLanguage)mandatoryQuery")
        mandatorySubscriptionToken = mandatorySubscription!.observe(\.state) { [weak self]  state in
            switch state {
            case .creating:
                print("creating")
            // The subscription has not yet been written to the Realm
            case .pending:
                print("pending")
                // The subscription has been written to the Realm and is waiting
            // to be processed by the server
            case .complete:
                for item in self!.mandatoryItems! {
                    let word = item.word.endingSubString(at:2)
                    let index = word.length - 5
                    if realmWordList.objects(WordListModel.self).filter("word = %@", item.word).count == 1 {
                        if index >= 0 && index < 6 {
                            self!.savedMandatoryWords[index].append(word)
                            self!.wordLengths[index] += 1
                            self!.wordLengths[self!.wordLengths.count - 1] += 1
                        }
                    } else {
//                        try! RealmService.write() {
//                            let recordToDelete = RealmService.objects(CommonString.self).filter("word BEGINSWITH %@", GV.actLanguage + word)
//                            if recordToDelete.count > 0 {
//                                RealmService.delete(recordToDelete)
//                            }
//                        }
                        print("word not in wordList: \(word)")
                    }
                }
                self!.generateMandatoryWords()
            default:
                print("state: \(state)")
            }
        }
    }

    struct WordLengthsProGame {
        var first = 0
        var counts = [0, 0, 0, 0, 0, 0]
        init(first: Int = 0, counts: [Int] = [0, 0, 0, 0, 0, 0]) {
            self.first = first
            self.counts[0] = counts[0]
            self.counts[1] = counts[1]
            self.counts[2] = counts[2]
            self.counts[3] = counts[3]
            self.counts[4] = counts[4]
            self.counts[5] = counts[5]
        }
    }
    
    var wordLengthsProGame: [WordLengthsProGame]?

    var mandatoryWordsTable = [String]()
    private func generateMandatoryWords() {
        switch GV.actLanguage {
            case "en": // OK
                wordLengthsProGame =
                [WordLengthsProGame(first: 0, counts: [2, 2, 1, 1, 0, 0]),
                WordLengthsProGame(first: 400, counts: [1, 1, 2, 1, 1, 0]),
                WordLengthsProGame(first: 600, counts: [0, 1, 1, 2, 1, 1]),
                WordLengthsProGame(first: 700, counts: [0, 0, 2, 2, 1, 1]),
                WordLengthsProGame(first: 800, counts: [0, 1, 1, 0, 2, 2]),
                WordLengthsProGame(first: 850, counts: [0, 0, 1, 0, 3, 2]),
                WordLengthsProGame(first: 880, counts: [0, 0, 0, 0, 3, 3]),
                WordLengthsProGame(first: 1000, counts: [1, 1, 1, 1, 1, 1])]
        case "de":  // OK
            wordLengthsProGame =
                [WordLengthsProGame(first: 0, counts: [1, 2, 1, 1, 1, 0]),
                 WordLengthsProGame(first: 100, counts: [1, 1, 1, 1, 1, 1]),
                 WordLengthsProGame(first: 920, counts: [0, 0, 1, 2, 2, 1]),
                 WordLengthsProGame(first: 980, counts: [2, 0, 1, 0, 1, 2]),
                 WordLengthsProGame(first: 990, counts: [2, 1, 1, 0, 0, 2]),
                 WordLengthsProGame(first: 1000, counts: [1, 1, 1, 1, 1, 1])]
        case "hu": // OK
            wordLengthsProGame =
                [WordLengthsProGame(first: 0, counts: [3, 3, 0, 0, 0, 0]),
                 WordLengthsProGame(first: 25, counts: [3, 2, 1, 0, 0, 0]),
                 WordLengthsProGame(first: 50, counts: [2, 2, 1, 1, 0, 0]),
                 WordLengthsProGame(first: 150, counts: [2, 1, 1, 1, 1, 0]),
                 WordLengthsProGame(first: 300, counts: [1, 1, 1, 1, 1, 1]),
                 WordLengthsProGame(first: 700, counts: [0, 2, 1, 1, 1, 1]),
                 WordLengthsProGame(first: 900, counts: [0, 0, 2, 2, 1, 1]),
                 WordLengthsProGame(first: 1000, counts: [1, 1, 1, 1, 1, 1])]
        case "ru": // OK
            wordLengthsProGame =
                [WordLengthsProGame(first: 0, counts: [3, 3, 0, 0, 0, 0]),
                 WordLengthsProGame(first: 25, counts: [3, 2, 1, 0, 0, 0]),
                 WordLengthsProGame(first: 50, counts: [2, 2, 1, 1, 0, 0]),
                 WordLengthsProGame(first: 150, counts: [2, 1, 1, 1, 1, 0]),
                 WordLengthsProGame(first: 450, counts: [1, 1, 1, 1, 1, 1]),
                 WordLengthsProGame(first: 700, counts: [0, 2, 1, 1, 1, 1]),
                 WordLengthsProGame(first: 900, counts: [0, 0, 2, 2, 1, 1]),
                 WordLengthsProGame(first: 1000, counts: [1, 1, 1, 1, 1, 1])]
        default:
            break
        }
        savedMandatoryWordsArchiv = savedMandatoryWords
        generatedItems = RealmService.objects(Mandatory.self).filter("combinedKey BEGINSWITH %@", GV.actLanguage).sorted(byKeyPath: "gameNumber", ascending: true)
        generatedSubscription = generatedItems!.subscribe(named: "\(GV.actLanguage)generatedQuery1")
//        generatedSubscription!.unsubscribe()
//        generatedItems = RealmService.objects(Mandatory.self).filter("combinedKey BEGINSWITH %@", GV.actLanguage).sorted(byKeyPath: "gameNumber", ascending: true)
        generatedSubscriptionToken = generatedSubscription!.observe(\.state) { [weak self]  state in
            switch state {
            case .creating:
                print("creating")
            // The subscription has not yet been written to the Realm
            case .pending:
                print("pending")
                // The subscription has been written to the Realm and is waiting
            // to be processed by the server
            case .complete:
                if self!.generatedItems!.count == 1000 {
                    for item in self!.generatedItems! {
                        self!.mandatoryWordsTable.append(item.mandatoryWords)
                    }
                    self!.showMandatoryTable()
                    return
                }
//                try! RealmService.write() {
//                    RealmService.delete(self!.generatedItems!)
//                }
                self!.generateNewItems()
            default:
                print("state: \(state)")
            }
        }
    }
    
    var tableviewAdded = false
    var timer: Timer?
    
    private func showMandatoryTable() {
        if !tableviewAdded {
            let origin = CGPoint(x: 0, y: 0)
            let height = view.frame.height * (GV.onIpad ? 0.6 : 0.3)
            let width = view.frame.width * (GV.onIpad ? 0.99 : 0.9)
            let size = CGSize(width: width, height: height)
            let center = CGPoint(x: 0.5 * view.frame.width, y: 0.35 * view.frame.height)
            showMandatoryWordsView!.frame=CGRect(origin: origin, size: size)
            showMandatoryWordsView!.center=center
            showMandatoryWordsView!.setDelegate(delegate: self)
            //            createButtons()
            //            modifyButtonsPosition()
            showMandatoryWordsView!.register(CustomTableViewCell.self, forCellReuseIdentifier: "cell")
            view.addSubview(showMandatoryWordsView!)
            timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(checkTable(timerX: )), userInfo: nil, repeats: true)
            let indexPath = IndexPath(row: GV.basicDataRecord.showingRow, section: 0)
            showMandatoryWordsView!.scrollToRow(at: indexPath, at: .top, animated: true)
            tableviewAdded = true
        }
    }
    
    var lastHighestRow = 0
    
    @objc private func checkTable(timerX: Timer) {
        let indexPaths = showMandatoryWordsView!.indexPathsForVisibleRows
        let actHighestRow = indexPaths![0].row + 2
        if lastHighestRow != actHighestRow {
            lastHighestRow = actHighestRow
            try! realm.write() {
                GV.basicDataRecord.showingRow = actHighestRow
            }
        }
    }

    
    private func generateNewItems() {
        var actWordLength: WordLengthsProGame = WordLengthsProGame()
        var index = 0
        var random: MyRandom?
//        var cs: [Int] = [1, 1, 1, 1, 1, 0]
        var actWordLengths = wordLengths
//        var actWordLengthsArchiv = [Int]()
//        var first = 0
        print("wordLengths: \(wordLengths)")
        
        for gameNumber in 0..<1000 {
            if wordLengthsProGame![index].first == gameNumber {
                actWordLength = wordLengthsProGame![index]
                if gameNumber > 0 {
                    let substracter = wordLengthsProGame![index].first - wordLengthsProGame![index - 1].first
                    actWordLengths[6] = 0
                    for ind in 0..<actWordLengths.count - 1 {
                        let multiplier = wordLengthsProGame![index - 1].counts[ind]
                        actWordLengths[ind] -= substracter * multiplier
                        actWordLengths[6] += actWordLengths[ind]
                    }
                    
                    print("actWordLengths: \(actWordLengths)")
                }
                index += 1
            }
            var words = ""
            
            random = MyRandom(gameNumber: gameNumber)
            for (index, count) in actWordLength.counts.enumerated() {
                for _ in 0..<count {
                    let max = savedMandatoryWords[index].count - 1
                    let ind = random!.getRandomInt(0, max: max)
                    words += savedMandatoryWords[index][ind] + "°"
                    savedMandatoryWords[index].remove(at:ind)
                    if savedMandatoryWords[index].count == 0 {
                        savedMandatoryWords[index] = savedMandatoryWordsArchiv[index]
                    }
                }
            }
            words.removeLast()
            let combinedKey = GV.actLanguage + String(gameNumber)
            let wordsInCloud = Mandatory()
            if RealmService.objects(Mandatory.self).filter("combinedKey = %@", combinedKey).count == 0 {
                wordsInCloud.combinedKey = combinedKey
                wordsInCloud.gameNumber = gameNumber
                wordsInCloud.language = GV.actLanguage
                wordsInCloud.mandatoryWords = words
                try! RealmService.write {
                    RealmService.add(wordsInCloud)
                }
            }
//            print("generating: \(actWordLength), gameNumber: \(gameNumber), words: \(words)")
            
        }
        
        var printString = ""
        var allCounts = 0
        for index in 0..<savedMandatoryWords.count {
            printString += "\(index + 5): \(savedMandatoryWords[index].count), "
            allCounts += savedMandatoryWords[index].count
        }
        printString += " AllCounts: \(allCounts)"
        print("actWordLengths: \(actWordLengths)")
        print(printString)
        
        
//        let substracter = wordLengthsProGame![index].first - wordLengthsProGame![index - 1].first
//        actWordLengths[6] = 0
//        for ind in 0..<actWordLengths.count - 1 {
//            let multiplier = wordLengthsProGame![index - 1].counts[ind]
//            actWordLengths[ind] -= substracter * multiplier
//            actWordLengths[6] += actWordLengths[ind]
//        }
        


    }
    
    private func createSavedMandatoryWords() -> [[String]] {
        var stringArray: [[String]] = []
        
        for _ in 0..<7 {
            stringArray.append([String]())
        }
        return stringArray
    }
    
    func didSelectedRow(tableView: UITableView, indexPath: IndexPath) {
//        let mandatoryRecord = generatedItems![indexPath.row]
        try! RealmService.write() {
            generatedItems![indexPath.row].change = !generatedItems![indexPath.row].change
        }
        showMandatoryWordsView!.reloadData()
    }
    
    func getNumberOfSections() -> Int {
        return 1
    }
    
    func getNumberOfRowsInSections(section: Int) -> Int {
        return mandatoryWordsTable.count
    }
    
    func getTableViewCell(tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        let actColor = UIColor.white
        let width = tableView.frame.width
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! CustomTableViewCell
        cell.setFont(font: myFont!)
        cell.setCellSize(size: CGSize(width: width, height: self.view.frame.width * (GV.onIpad ? 0.040 : 0.010)))
        cell.setBGColor(color: UIColor.white) //showWordsBackgroundColor)
        //        switch indexPath.row {
        //        case 0:
        //            cell.addColumn(text: " " + (String(wordLengths[indexPath.row]).fixLength(length: 100, leadingBlanks: false)), color: actColor)
        //        default:
        cell.addColumn(text: " " + String(indexPath.row) + ":" )
        var text = " " + (mandatoryWordsTable[indexPath.row].fixLength(length: 40, leadingBlanks: false))
        if generatedItems![indexPath.row].change {
            text += GV.language.getText(.tcChangeWord)
        }
        cell.addColumn(text: text, color: actColor)
        //        }
        return cell
    }
    
    func getHeightForRow(tableView: UITableView, indexPath: IndexPath) -> CGFloat {
        return "A".height(font: myFont!) * 2
    }
    
    func setHeaderView(tableView: UITableView, headerView: UIView, section: Int) {
    }
    
    func fillHeaderView(tableView: UITableView, section: Int) -> UIView {
        let lineHeight = "A".height(font: myFont!)
        let title = "   Mandatorywords"
//        if wordLengths.count > 0 {
//            title = " all: \(wordLengths[0]), 5: \(wordLengths[1]), 6: \(wordLengths[2]), 7: \(wordLengths[3]), 8: \(wordLengths[4]), 9: \(wordLengths[5]), 10: \(wordLengths[6])"
//        }
        let width = title.width(withConstrainedHeight: 0, font: myFont!)
        let view = UIView()
        //        let label1 = UILabel(frame: CGRect(x: 0, y: 0, width: width, height: lineHeight))
        //        label1.font = myFont!
        //        label1.text = headerLine
        //        view.addSubview(label1)
        let label2 = UILabel(frame: CGRect(x: 0, y: lineHeight * 0.5, width: width, height: lineHeight))
        label2.font = myFont!
        label2.text = title
        view.addSubview(label2)
        view.backgroundColor = UIColor(red:240/255, green: 240/255, blue: 240/255, alpha: 1.0)
        return view
    }
    
    func getHeightForHeaderInSection(tableView: UITableView, section: Int) -> CGFloat {
        return "A".height(font: myFont!) * 2
    }

    var mandatoryItems: Results<CommonString>?
    var mandatorySubscription: SyncSubscription<CommonString>?
    var mandatorySubscriptionToken: NotificationToken?
    
    var generatedItems: Results<Mandatory>?
    var generatedSubscription: SyncSubscription<Mandatory>?
    var generatedSubscriptionToken: NotificationToken?

    var savedMandatoryWords: [[String]] = []
    var savedMandatoryWordsArchiv: [[String]] = []
    var wordLengths = [0,0,0,0,0,0,0]
}
#endif
