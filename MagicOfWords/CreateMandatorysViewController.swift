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
    
    var wordLengthsProGame: [WordLengthsProGame] =
        [WordLengthsProGame(first: 0, counts: [3, 3, 0, 0, 0, 0]),
         WordLengthsProGame(first: 15, counts: [3, 2, 1, 0, 0, 0]),
        WordLengthsProGame(first: 30, counts: [2, 2, 1, 1, 0, 0]),
        WordLengthsProGame(first: 60, counts: [2, 1, 1, 1, 1, 0]),
        WordLengthsProGame(first: 100, counts: [1, 1, 1, 1, 1, 1]),
        WordLengthsProGame(first: 500, counts: [0, 2, 1, 1, 1, 1]),
        WordLengthsProGame(first: 750, counts: [0, 0, 2, 2, 1, 1]),
        WordLengthsProGame(first: 1000, counts: [1, 1, 1, 1, 1, 1])]

    private func generateMandatoryWords() {
        savedMandatoryWordsArchiv = savedMandatoryWords
        generatedItems = RealmService.objects(Mandatory.self).filter("combinedKey BEGINSWITH %@", GV.actLanguage).sorted(byKeyPath: "combinedKey", ascending: true)
        generatedSubscription = generatedItems!.subscribe(named: "\(GV.actLanguage)generatedQuery")
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
                    return
                }
                try! RealmService.write() {
                    RealmService.delete(self!.generatedItems!)
                }
                self!.generateNewItems()
            default:
                print("state: \(state)")
            }
        }
    }
    
    private func generateNewItems() {
        var actWordLength: WordLengthsProGame = WordLengthsProGame()
        var index = 0
        var random: MyRandom?
        print("wordLengths: \(wordLengths)")
        
        for gameNumber in 0..<1000 {
            if wordLengthsProGame[index].first == gameNumber {
                actWordLength = wordLengthsProGame[index]
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
            print("generating: \(actWordLength), gameNumber: \(gameNumber), words: \(words)")
            
        }

    }
    
    private func createSavedMandatoryWords() -> [[String]] {
        var stringArray: [[String]] = []
        
        for _ in 0..<7 {
            stringArray.append([String]())
        }
        return stringArray
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
