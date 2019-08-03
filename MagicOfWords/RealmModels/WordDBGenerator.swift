//
//  WordDBGenerator.swift
//  MagicOfWords
//
//  Created by Jozsef Romhanyi on 31/05/2018.
//  Copyright © 2018 Jozsef Romhanyi. All rights reserved.
//
#if GENERATEWORDLIST || GENERATEMANDATORY || GENERATELETTERFREQUENCY || CREATEMANDATORY || CREATEWORDLIST
import Foundation
import RealmSwift

#if GENERATEWORDLIST
// for Generating WordList DB
//        Compressing Realm DB if neaded
//        let config1 = Realm.Configuration(shouldCompactOnLaunch: { totalBytes, usedBytes in
//            // totalBytes refers to the size of the file on disk in bytes (data + free space)
//            // usedBytes refers to the number of bytes used by data in the file
//
//            // Compact if the file is over 100MB in size and less than 50% 'used'
//            let tenMB = 10 * 1024 * 1024
//            return (totalBytes > tenMB) && (Double(usedBytes) / Double(totalBytes)) < 0.8
//        })
//        do {
//            // Realm is compacted on the first open if the configuration block conditions were met.
//            _ = try Realm(configuration: config1)
//        } catch {
//            print("error")
//            // handle error compacting or opening Realm
//        }

let wordListConf = Realm.Configuration(
    fileURL: URL(string: Bundle.main.path(forResource: "WordListTemp", ofType: "realm")!),
    readOnly: true,
    schemaVersion: 13,
    // Set the block which will be called automatically when opening a Realm with
    // a schema version lower than the one set above
    migrationBlock: { migration, oldSchemaVersion in
        switch oldSchemaVersion {
//        case 0...3:
//            migration.deleteData(forType: GameDataModel.className())
//            migration.deleteData(forType: RoundDataModel.className())
//            migration.deleteData(forType: BasicDataModel.className())
        default: migration.enumerateObjects(ofType: GameDataModel.className())
        { oldObject, newObject in
//            if oldObject!["combinedKey"] == nil {
//                newObject!["combinedKey"] = oldObject!["language"] as! String + String((oldObject!["gameNumber"] as! Int) % 1000)
//                newObject!["gameNumber"] = Int(oldObject!["gameNumber"] as! Int % 1000)
//            }
            }
            
        }
},
    objectTypes: [WordListTemp.self])

let defaultConfig = Realm.Configuration(
schemaVersion: 13,
// Set the block which will be called automatically when opening a Realm with
// a schema version lower than the one set above
migrationBlock: { migration, oldSchemaVersion in
    switch oldSchemaVersion {
    case 0...3:
        migration.deleteData(forType: GameDataModel.className())
        migration.deleteData(forType: RoundDataModel.className())
        migration.deleteData(forType: BasicDataModel.className())
    default: migration.enumerateObjects(ofType: GameDataModel.className())
    { oldObject, newObject in
        if oldObject!["combinedKey"] == nil {
            newObject!["combinedKey"] = oldObject!["language"] as! String + String((oldObject!["gameNumber"] as! Int) % 1000)
            newObject!["gameNumber"] = Int(oldObject!["gameNumber"] as! Int % 1000)
        }
        }
        
    }
},
objectTypes: [WordListModel.self]
//            objectTypes: [WordListModel.self]
)

//    let defaultConfig = Realm.Configuration(
//        objectTypes: [WordListModel.self, WordListTemp.self])
#endif
#if GENERATEMANDATORY
// for generating Mandatory Words
let defaultConfig = Realm.Configuration(
    objectTypes: [MandatoryModel.self])
#endif

#if CREATEMANDATORY
// for generating Mandatory Words
let defaultConfig = Realm.Configuration(
    objectTypes: [MandatoryModel.self])
#endif

#if CREATEWORDLIST
// for generating Mandatory Words
let defaultConfig = Realm.Configuration(
    objectTypes: [WordListModel.self])
#endif



var realm: Realm = try! Realm(configuration: defaultConfig)

class WordDBGenerator {
    
    init(mandatory: Bool = false, create: Bool = false) {
        if create && mandatory {
            generatingMandatoryWords(language: "en")
            generatingMandatoryWords(language: "de")
            generatingMandatoryWords(language: "hu")
            generatingMandatoryWords(language: "ru")
        } else if create && !mandatory {
            generatingWordList(language: "en")
            generatingWordList(language: "de")
            generatingWordList(language: "hu")
            generatingWordList(language: "ru")

        } else if mandatory {
            generateMandatoryWords(language: "en")
            generateMandatoryWords(language: "de")
            generateMandatoryWords(language: "hu")
            generateMandatoryWords(language: "ru")
        } else {
            print("Start")
//            generateWordList(language: "de")
//            print("DE ready")
//            _ = Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(getSavedMandatoryWords), userInfo: nil, repeats: true)
//            getSavedMandatoryWords()
            generateWordList(language: "en")
            print("EN ready")
//            generateWordList(language: "hu")
//            print("HU ready")
//            generateWordList(language: "ru")
//            print("RU ready")
        }
    }

    var letters = [String: Int]()
    var countLetters = 0
    var primaryKey = -1
    var wordList = [String]()
    
//    var mandatoryItems: Results<CommonString>?
//    var mandatorySubscription: SyncSubscription<CommonString>?
//    var mandatorySubscriptionToken: NotificationToken?
//
//    private func getSavedMandatoryWords() {
//        mandatoryItems = RealmService.objects(CommonString.self).filter("word BEGINSWITH %@", "myWordListen").sorted(byKeyPath: "word", ascending: true)
//        mandatorySubscription = mandatoryItems!.subscribe(named: "myWordListen")
//        mandatorySubscriptionToken = mandatorySubscription!.observe(\.state) { [weak self]  state in
//            switch state {
//            case .creating:
//                print("creating")
//            // The subscription has not yet been written to the Realm
//            case .pending:
//                print("pending")
//                // The subscription has been written to the Realm and is waiting
//            // to be processed by the server
//            case .complete:
//                for item in self!.mandatoryItems! {
//                    self!.wordList.append(item.word.endingSubString(at:9))
//                }
//                self!.generateWordList(language: "en")
//            default:
//                print("state: \(state)")
//            }
//        }
//    }
//

    private func generateWordList(language: String) {
        let realmWordListTemp:Realm = try! Realm(configuration: wordListConfig)

//        let notDELanguage = language != GV.language.getText(.tcGermanShort)
        countLetters = 0
        letters = [String: Int]()
//        let wordFileURL = Bundle.main.path(forResource: "\(language)Words", ofType: "txt")
//        // Read from the file Words
//        var wordsFile = ""
//        do {
//            wordsFile = try String(contentsOfFile: wordFileURL!, encoding: String.Encoding.utf8)
//        } catch let error as NSError {
//            print("Failed reading from URL: \(String(describing: wordFileURL)), Error: " + error.localizedDescription)
//        }
        let wordListItems = realmWordListTemp.objects(WordList.self)
        
//        for item in wordListItems {
//            wordList.append(item.word.endingSubString(at:2))
//        }
//        let wordsToCopy = realm.objects(WordListModel.self)//.filter("word BEGINSWITH %@", language)
        var countRu = 0
        var countHu = 0
        var countDe = 0
        var countEn = 0
        let all = wordListItems.count
        var countSavedWords = 0
        
        for word in wordListItems {
            let language = word.word.subString(at: 0, length: 2)
            if language == "en" {
                if word.word.ends(with: "s") {
                    let searchWord = word.word.subString(at:0, length: word.word.length - 1)
                    if wordListItems.filter("word = %@", searchWord).count == 1 {
                        continue
                    }
                }
            }
            countSavedWords += 1
            switch language {
            case "en": countEn += 1
            case "de": countDe += 1
            case "hu": countHu += 1
            case "ru": countRu += 1
            default: continue
            }
            let wordList = WordListModel()
            wordList.word = word.word
            try! realm.safeWrite() {
                realm.add(wordList)
                if countSavedWords % 1000 == 0 {
                    print("all: \(all), count: \(countSavedWords), en: \(countEn), de: \(countDe), hu: \(countHu), ru: \(countRu)")
                }
            }
        }
//        try! realm.safeWrite() {
//            realm.delete(wordsToDelete)
//        }
//        let wordList = wordsFile.components(separatedBy: .newlines)
//        for word in wordsToCopy {
//            let charset = CharacterSet(charactersIn: "-! /.èêûé") // words with "-", "!" are not computed
//            if word.rangeOfCharacter(from: charset) == nil || word.length > 20 || word.length < 2 {
//                if notDELanguage || word.firstChar().uppercased() == word.firstChar() {
////                    generateLetterFrequency(language: language, word: word.lowercased())
//                    let wordModel = WordListModel()
//                    wordModel.word = (language + word).lowercased()
//                    if realm.objects(WordListModel.self).filter("word = %d", wordModel.word).count == 0 {
//                        try! realm.write {
//                            realm.add(wordModel)
//                        }
//                    }
//                }
//            } else {
//                print("\(word)")
//            }
//        }
//        saveLetterFrequency(language: language)
        
    }
    
    private func generateLetterFrequency(language: String, word: String) {
        countLetters += word.length
        for letter in word {
            if letters[String(letter)] != nil {
                letters[String(letter)]! += 1
            } else {
                letters[String(letter)] = 1
            }
        }
    }
    
    private func saveLetterFrequency(language: String) {
        for (letter, frequency) in letters {
            let frequencyInProcent = (Double(100) * Double(frequency) / Double(countLetters)).twoDecimals
            let frString = String(round(frequencyInProcent))
            let wordModel = WordListModel()
            wordModel.word = language + GV.frequencyString + itemSeparator + letter + itemSeparator + frString
            try! realm.safeWrite {
                realm.add(wordModel)
            }
        }
    }

    private func generateMandatoryWords(language: String) {
        let dataFileURL = Bundle.main.path(forResource: language + "GameData", ofType: "txt")
        var gameDataFile = ""
        do {
            gameDataFile = try String(contentsOfFile: dataFileURL!, encoding: String.Encoding.utf8)
        } catch let error as NSError {
            print("Failed reading from URL: \(String(describing: dataFileURL)), Error: " + error.localizedDescription)
        }
        let myLines = gameDataFile.components(separatedBy: .newlines)
        for line in myLines {
            let myItems = line.components(separatedBy: "/")
            if myItems.count == 3 {
//                let gameType = myItems[0]
                let gameNumber = myItems[1]
                let myWords = myItems[2].components(separatedBy: itemSeparator)
                let maxIndex = 6
                var index = 0
                var lineToSave = ""
                repeat {
                    lineToSave += myWords[index] + itemSeparator
                    index += 1
                } while index < maxIndex
                lineToSave.removeLast()
                let mandatoryModel = MandatoryModel()
                mandatoryModel.combinedKey = language + gameNumber
                mandatoryModel.gameNumber = Int(gameNumber)!
                mandatoryModel.language = language
                mandatoryModel.mandatoryWords = lineToSave
                try! realm.safeWrite {
                    realm.add(mandatoryModel)
                }
            }
        }
    }
    
    func generatingMandatoryWords(language: String) {
        var words: Results<WordListModel>
        if language == "en" {
            words = realmWordList.objects(WordListModel.self).filter("word BEGINSWITH %@ and not word ENDSWITH %@", language, "s")
        } else {
            words = realmWordList.objects(WordListModel.self).filter("word BEGINSWITH %@", language)
        }
        let sortedWords =  Array(words).sorted(by: {$0.word.length < $1.word.length || ($0.word.length == $1.word.length && $0.word < $1.word)})
        var indexTab = [0,0,0,0,0,0,0,0,0,0,0,0]
        var searching = true
        repeat {
            for index in 0..<sortedWords.count {
                let length = sortedWords[index].word.length - 2
                if length < 5 {
                    continue
                }

                if indexTab[length] == 0 {
                    indexTab[length] = index
                }
                if length > 10 {
                    searching = false
                    break
                }
           }
        } while searching
        var wordTable = [String]()
        var wordsToPrint = [String]()
        let wordLengths = [5,5,5,5,6,6,6,6,7,7,7,7,7,7,7,7,8,8,9,10,11]
        let random = MyRandom(gameNumber: 0)
        repeat {
            let wLenIndex = random.getRandomInt(0, max: wordLengths.count - 2)
            let minIndex = indexTab[wordLengths[wLenIndex]]
            let maxIndex = indexTab[wordLengths[wLenIndex + 1]] - 1
            let wordIndex = random.getRandomInt(minIndex, max: maxIndex)
            let word = sortedWords[wordIndex]
            let wLength = word.word.length
            let search = word.word.subString(at: 2, length: wLength - 2)
            if let _ = wordTable.index(where: { $0 == search }) {
                
            } else if let _ = wordTable.index(where: { $0.subString(at: 0, length: $0.length - 1) == search}) {
                    
            } else if let _ = wordTable.index(where: { $0 == search.subString(at: 0, length: search.length - 1)}) {
            
            } else {
                wordTable.append(word.word.subString(at: 2, length: wLength - 2))
            }
        } while wordTable.count < 10000
        var index = 0
        for gameNumber in 0...999 {
            var text = ""
            for _ in 0...5 {
                text += wordTable[index] + "°"
                index += 1
            }
            text.removeLast()
            let mandatoryRecord = MandatoryModel()
            let combinedKey:String = language + String(gameNumber)
            mandatoryRecord.combinedKey = combinedKey
            mandatoryRecord.gameNumber = gameNumber
            mandatoryRecord.language = language
            mandatoryRecord.mandatoryWords = text
            try! realm.safeWrite() {
                realm.add(mandatoryRecord)
            }
            wordsToPrint.append(text)
        }
        
//        print(wordsToPrint)
    }
    func generatingWordList(language: String) {
        let words = realmWordList.objects(WordListModel.self).filter("word BEGINSWITH %@", language)
        let sortedWords =  Array(words).sorted(by: {$0.word < $1.word})
        for word in sortedWords {
            try! realm.safeWrite() {
                let wordListRecord = WordListModel()
                wordListRecord.word = word.word
                realm.add(wordListRecord)
            }
//            wordsToPrint.append(word.word)
        }
//        print(wordsToPrint)
    }


}
#endif
