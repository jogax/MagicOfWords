//
//  HintEngine.swift
//  MagicOfWords
//
//  Created by Romhanyi Jozsef on 2020. 03. 06..
//  Copyright © 2020. Jozsef Romhanyi. All rights reserved.
//

import Foundation
import RealmSwift

class HintEngine {
//    public class var shared: HintEngine {
//        struct Static {
//            static let instance = HintEngine()
//        }
//        return Static.instance
//    }
    init() {
        
    }
    
    private func getAllWords()->[Results<HintModel>] {
        let mandatoryListConfig  = Realm.Configuration(
            // Get the path to the bundled file
        //    fileURL: URL(string: Bundle.main.path(forResource: "MandatoryList", ofType:"realm")!),
            fileURL: URL(string: Bundle.main.path(forResource: "Hints", ofType:"realm")!),
            // Open the file in read-only mode as application bundles are not writeable
            readOnly: true,
            objectTypes: [HintModel.self])

        let realmMandatoryList: Realm = try! Realm(configuration: mandatoryListConfig)
        var returnValue = [Results<HintModel>]()
        let formatString = "language = %@ AND word Like %@"
//        let likes = ["????", "?????", "??????", "???????", "????????", "?????????", "??????????"]
        let likes = ["????", "?????", "??????", "???????", "????????", "?????????", "??????????"]
        for like in likes {
            let results = realmMandatoryList.objects(HintModel.self).filter(formatString, GV.actLanguage, like)
            returnValue.append(results)
        }

        return returnValue
    }
    
    private func find(value searchValue: String, inArray: [UsedLetterWithCounter]) -> Int?
    {
//        var returnValue = 0
        for (index, value) in inArray.enumerated()
        {
            if value.letter == searchValue && value.freeCount > 0 {
                return index
            }
        }
        return nil
    }

    var redLetters = [String]()
    var fixLetters = [UsedLetterWithCounter]()
    var freeGreenLetters = [UsedLetterWithCounter]()
    var freeArrays = [FreeArray]()
    var greenLetters = [String:[UsedLetter]]()
    var results = [Results<HintModel>]()
    var maxWordLength = 0
//    let maxCountWords = 10
    var searchWord = ""
//    var OKWords = [HintTableStruct]()
    let maxCol = 9
    
    private func checkFreeAreasAtFixLetter(letter: UsedLetterWithCounter)->Int {
        var returnValue = 0
        var arrayNumberLeft = -1
        var arrayNumberRight = -1
        var arrayNumberUp = -1
        var arrayNumberDown = -1
        if letter.col > 0 {
            arrayNumberLeft = GV.gameArray[letter.col - 1][letter.row].inFreeArray
        }
        if letter.col < maxCol - 1 {
            arrayNumberRight = GV.gameArray[letter.col + 1][letter.row].inFreeArray
        }
        if letter.row > 0 {
            arrayNumberUp = GV.gameArray[letter.col][letter.row - 1].inFreeArray
        }
        if letter.row > maxCol - 1 {
            arrayNumberDown = GV.gameArray[letter.col + 1][letter.row].inFreeArray
        }
        returnValue = arrayNumberLeft < 0 ? returnValue : (returnValue < freeArrays[arrayNumberLeft].countFree ? freeArrays[arrayNumberLeft].countFree : returnValue)
        returnValue = arrayNumberRight < 0 ? returnValue : (returnValue < freeArrays[arrayNumberRight].countFree ? freeArrays[arrayNumberRight].countFree : returnValue)
        returnValue = arrayNumberUp < 0 ? returnValue : (returnValue < freeArrays[arrayNumberUp].countFree ? freeArrays[arrayNumberUp].countFree : returnValue)
        returnValue = arrayNumberDown < 0 ? returnValue : (returnValue < freeArrays[arrayNumberDown].countFree ? freeArrays[arrayNumberDown].countFree : returnValue)
        return returnValue
    }

    private func findWordsWithOneFixletter() {
        let startWordCount = GV.hintTable.count
        if fixLetters.count == 0 {
            return
        }
        let startTime = Date()
//        OKWords = GV.hintTable
        if GV.hintTable.count >= maxWordCount {
            return
        }
        for myIndex in 0..<results.count {
            let resultIndex = results.count - 1 - myIndex
            if maxWordLength < results[resultIndex].first!.word.length {
                continue
            }
            let fillLength = results[resultIndex].first!.word.length
            for fixLetter in fixLetters {
                if GV.hintTable.count >= maxWordCount {
                    break
                }
                if fixLetter.freeCount == 0 {
                    continue
                }
                if checkFreeAreasAtFixLetter(letter: fixLetter) < fillLength {
                    break
                }
                
                searchWord = "".fill(with: "?", toLength: fillLength)
                searchWord = searchWord.changeChars(at: 0, to: fixLetter.letter)
    //                -----------------------------------------------
                let tippWordsResults = results[resultIndex].filter("word like %@", searchWord.lowercased())
                if tippWordsResults.count > 0 {
                    for foundedWord in tippWordsResults {
                        let word = foundedWord.word.myUpperCased()
                        var temporaryRedLetters = [(letter:String, index:Int)]()
                        var wordOK = true
                        for letterIndex in 0..<word.length {
                            if searchWord.char(at: letterIndex) == "?" {
                                if !(redLetters.contains(word.char(at: letterIndex))) {
                                    wordOK = false
                                    break
                                } else {
                                    let letter = word.char(at: letterIndex)
                                    temporaryRedLetters.append((letter, letterIndex))
                                    let index = redLetters.firstIndex(of: String(letter))
                                    if index != nil {
                                        redLetters.remove(at: index!)
                                    }
                                }
                            }
                        }
                        for temporaryLetter in temporaryRedLetters {
                            redLetters.append(temporaryLetter.letter)
                        }
                        temporaryRedLetters.removeAll()
                        if wordOK {
                            if checkFreeAreasAtFixLetter(letter: fixLetter) >= word.length {
                                if !WTGameWordList.shared.roundContainsWord(word: word.myUpperCased()) && !GV.hintTable.contains(where: {$0.hint == word.myUpperCased()}) {
                                    GV.hintTable.append(HintTableStruct(hint: word, search: searchWord.myUpperCased(), type: .WithFixLetter, count: 1))
                                }
//                                if !OKWords.contains(where: {$0.hint == word}) {
//                                    OKWords.append(HintTableStruct(hint: word, search: searchWord.myUpperCased(), type: .WithFixLetter, count: 1))
//                                    if OKWords.count >= maxWordCount {
//                                        break
//                                    }
//                                }
                            }
//                            for temporaryLetter in temporaryRedLetters {
//                                redLetters.append(temporaryLetter.letter)
//                            }
//                            temporaryRedLetters.removeAll()
                            break
                        } else {
//                            for temporaryLetter in temporaryRedLetters {
//                                redLetters.append(temporaryLetter.letter)
//                            }
//                            temporaryRedLetters.removeAll()
                        }
                        for temporaryLetter in temporaryRedLetters {
                            redLetters.append(temporaryLetter.letter)
                        }
                        temporaryRedLetters.removeAll()
                    }
                }
                if Date().timeIntervalSince(startTime) > maxInterval {
                    break
                }

            }
            if Date().timeIntervalSince(startTime) > maxInterval {
                break
            }
            if GV.hintTable.count - startWordCount >= maxWordCount {
                break
            }
        }
//        for item in OKWords {
//            let myApperCasedWord = item.hint.myUpperCased()
//            if !WTGameWordList.shared.roundContainsWord(word: myApperCasedWord) && !GV.hintTable.contains(where: {$0.hint == myApperCasedWord}) {
//                GV.hintTable.append(item)
//            }
//        }
//        OKWords.removeAll()
    }
    
    var maxInterval = 0.1
    let maxWordCount = 5
    
    private func checkLetter(letter: UsedLetterWithCounter)->[Int] {
        var letterInArrays = [Int]()
        for array in freeArrays {
            for freePlace in array.freePlaces {
                if (freePlace.col == letter.col && (freePlace.row == letter.row - 1 || freePlace.row == letter.row + 1)) ||
                    (freePlace.row == letter.row && (freePlace.col == letter.col - 1 || freePlace.col == letter.col + 1)) {
                    if !letterInArrays.contains(array.numberOfFreeArray) {
                        letterInArrays.append(array.numberOfFreeArray)
                    }
                }
            }
        }
        return letterInArrays
    }
    
    private func findWordsWithTwoFixLetters() {
        
        if fixLetters.count == 0 {
            return
        }
        let startTime = Date()
//        OKWords = [HintTableStruct]()
        func lettersInTheSameFreeArea(letter1: UsedLetterWithCounter, letter2: UsedLetterWithCounter)->(Bool, Int) {
            var letter1InArray = 1000
            var letter2InArray = 1001
            for array in freeArrays {
                for freePlace in array.freePlaces {
                    if (freePlace.col == letter1.col && (freePlace.row == letter1.row - 1 || freePlace.row == letter1.row + 1)) ||
                        (freePlace.row == letter1.row && (freePlace.col == letter1.col - 1 || freePlace.col == letter1.col + 1)) {
                        letter1InArray = array.numberOfFreeArray
                        break
                    }
                }
                for freePlace in array.freePlaces {
                    if (freePlace.col == letter2.col && (freePlace.row == letter2.row - 1 || freePlace.row == letter2.row + 1)) ||
                        (freePlace.row == letter2.row && (freePlace.col == letter2.col - 1 || freePlace.col == letter2.col + 1)) {
                        letter2InArray = array.numberOfFreeArray
                        break
                    }
                }
            }
            return (letter1InArray == letter2InArray, letter1InArray)
        }
        for myIndex in 0..<results.count {
            let resultIndex = results.count - 1 - myIndex
            if maxWordLength < results[resultIndex].first!.word.length {
                continue
            }
            let fillLength = results[resultIndex].first!.word.length
            for fixLetter1 in fixLetters {
                if fixLetter1.freeCount == 0 {
                    continue
                }
            //                -----------------------------------------------
                for fixLetter2 in fixLetters {
                    if fixLetter2.freeCount == 0 || fixLetter1 == fixLetter2 {
                        continue
                    }
                    searchWord = "".fill(with: "?", toLength: fillLength)
                    let (inTheSameArea, firstAreaNr) = lettersInTheSameFreeArea(letter1: fixLetter1, letter2: fixLetter2)
                    if inTheSameArea {
                        let distance = fixLetter1.freeDistance(to: fixLetter2)
                        if distance < fillLength - 2 {
                            if fixLetter2.freeCount == 1 {
                                continue
                            }
                            let secondArraySize = fillLength - distance - 2
                            let arrays = checkLetter(letter: fixLetter1)
                            if arrays.count == 1 {
                                if freeArrays[arrays[0]].freePlaces.count < distance + secondArraySize {
                                    continue
                                }
                            } else {
                                var areaSizeOK = false
                                for arrayNr in arrays {
                                    if arrayNr != firstAreaNr {
                                        if secondArraySize <= freeArrays[arrayNr].freePlaces.count {
                                            areaSizeOK = true
                                        }
                                    }
                                }
                                if !areaSizeOK {
                                    continue
                                }
                            }
                        }
                        if  distance > 0 && distance  <= fillLength - 2 {

                            searchWord = searchWord.changeChars(at: 0, to: fixLetter1.letter)
                            searchWord = searchWord.changeChars(at: distance + 1, to: fixLetter2.letter).lowercased()
                            let tippWordsResults = results[resultIndex].filter("word like %@", searchWord)
                            if tippWordsResults.count > 0 {
                                for foundedWord in tippWordsResults {
                                    let word = foundedWord.word.myUpperCased()
                                    var temporaryRedLetters = [(letter:String, index:Int)]()
                                    var wordOK = true
                                    for letterIndex in 0..<word.length {
                                        if searchWord.char(at: letterIndex) == "?" {
                                            if !redLetters.contains(word.char(at: letterIndex).myUpperCased()) {
                                                wordOK = false
                                                break
                                            } else {
                                                let letter = word.char(at: letterIndex).myUpperCased()
                                                temporaryRedLetters.append((letter, letterIndex))
                                                let index = redLetters.firstIndex(of: String(letter))
                                                if index != nil {
                                                    redLetters.remove(at: index!)
                                                }
                                            }
                                        }
                                    }
                                    for temporaryLetter in temporaryRedLetters {
                                        redLetters.append(temporaryLetter.letter)
                                    }
                                    temporaryRedLetters.removeAll()
                                    if wordOK {
                                        let item = HintTableStruct(hint: word, search: searchWord.myUpperCased(), type: .WithFixLetter, count: 2)
                                        if !WTGameWordList.shared.roundContainsWord(word: word.myUpperCased()) && !GV.hintTable.contains(item) {
                                            GV.hintTable.append(item)
                                            break
                                        }

                                    }
                                    for temporaryLetter in temporaryRedLetters {
                                        redLetters.append(temporaryLetter.letter)
                                    }
                                    temporaryRedLetters.removeAll()

                                }
                            }
                            searchWord = "".fill(with: "?", toLength: fillLength)
                        }
                    }
                    if Date().timeIntervalSince(startTime) > maxInterval || GV.hintTable.count >= maxWordCount {
                        break
                    }
                }
                if Date().timeIntervalSince(startTime) > maxInterval || GV.hintTable.count >= maxWordCount {
                    break
                }
            }
            if Date().timeIntervalSince(startTime) > maxInterval {
                break
            }
            if GV.hintTable.count >= maxWordCount {
                break
            }
        }
//        for item in OKWords {
//            if !WTGameWordList.shared.roundContainsWord(word: item.hint) && !GV.hintTable.contains(item) {
//                GV.hintTable.append(item)
//            }
//        }
//        OKWords.removeAll()
    }
    
//    private func findWordsWithRedLetters(gameNumber: Int, modifier: Int) {
//
//        let startWordCounter = GV.hintTable.count
//        for myIndex in 0..<results.count {
//            let startTime = Date()
//            let resultIndex = results.count - 1 - myIndex
//            if maxWordLength < results[resultIndex].first!.word.length {
//                continue
//            }
//            let actResults = results[resultIndex]
//            var wordIndexes = [Int]()
//            for index in 0..<actResults.count {
//                wordIndexes.append(index)
//            }
//            repeat {
//                var wordOK = true
////                let index = Int.random(in: 0 ..< wordIndexes.count)
//                let index = random!.getRandomInt(0, max: wordIndexes.count - 1)
//                let ind = wordIndexes[index]
//                wordIndexes.remove(at: index)
//                if wordIndexes.count == 0 {
//                    break
//                }
//                let word = results[resultIndex][ind].word.myUpperCased()
//                var temporaryRedLetters = [(letter:String, index:Int)]()
//                var searchWord = "".fill(with: "?", toLength: word.length)
//                var countGreenLetters = 0
//
//                for (letterIndex, letter) in word.enumerated() {
//                        if !redLetters.contains(String(letter)) {
//                            wordOK = false
////                                break
//                            searchWord = searchWord.changeChars(at: letterIndex, to: String(letter))
//                            countGreenLetters  += 1
//                        } else {
//                            temporaryRedLetters.append((String(letter), letterIndex))
//                            let index = redLetters.firstIndex(of: String(letter))
//                            if index != nil {
//                                redLetters.remove(at: index!)
//                            }
//                        }
//                }
//                if wordOK && maxWordLength >= word.length {
//                    let item = HintTableStruct(hint: word, search: searchWord.myUpperCased(), type: .WithRedLetter, count: 0)
//                    if !WTGameWordList.shared.roundContainsWord(word: item.hint) && !GV.hintTable.contains(item) {
//                        GV.hintTable.append(item)
//                    }
//
////                    if !OKWords.contains(where: {$0.hint == word}) {
////                        OKWords.append(HintTableStruct(hint: word, search: searchWord.myUpperCased(), type: .WithRedLetter, count: 0))
////                    }
//                } else {
//                    if let index = searchWord.index(from: 0, of: "?") {
//                        if index > 0 && index < 9 {
//                            let endsWith = "".fill(with: "?", toLength: word.length - index)
//                            if endsWith.length > maxWordLength {
//                                continue
//                            }
//                            if searchWord.ends(with: endsWith)  {
//                                var myLetters = [[UsedLetter]]()
//                                for letter in searchWord.startingSubString(length: index) {
//                                    if greenLetters[String(letter)] != nil && greenLetters[String(letter)]!.count > 0 {
//                                        myLetters.append(greenLetters[String(letter)]!)
//                                    } else {
//                                        myLetters.removeAll()
//                                        break
//                                    }
//                                }
//                                if myLetters.count == index {
//                                    var indexes = [Int](repeating: 0, count: index)
//                                    stopCycle:
//                                    repeat {
//                                        var letters = [UsedLetter]()
//                                        for (letterIndex, myLetter) in myLetters.enumerated() {
//                                            let actIndex = indexes[letterIndex]
//                                            letters.append(myLetter[actIndex])
//                                        }
//                                        if checkLetters(letters: letters, free: word.length - index) {
//                                            let item = HintTableStruct(hint: word, search: searchWord.myUpperCased(), type: .WithGreenLetter, count: countGreenLetters)
//                                            if !WTGameWordList.shared.roundContainsWord(word: item.hint) && !GV.hintTable.contains(item) {
//                                                GV.hintTable.append(item)
//                                            }
////                                            if !OKWords.contains(where: {$0.hint == word}) {
//////                                                print("word: \(word), searchWord: \(searchWord)")
////                                                OKWords.append(HintTableStruct(hint: word, search: searchWord.myUpperCased(), type: .WithGreenLetter, count: countGreenLetters))
////                                            }
//                                            break stopCycle
//                                        } else {
//                                            var indexForIndexes = indexes.count - 1
//                                            repeat {
//                                                indexes[indexForIndexes] += 1
//                                                if indexes[indexForIndexes] > myLetters[indexForIndexes].count - 1 {
//                                                    indexes[indexForIndexes] = 0
//                                                    if indexForIndexes > 0 {
//                                                        indexForIndexes -= 1
//                                                    } else {
//                                                        break stopCycle
//                                                    }
//                                                } else {
//                                                    break
//                                                }
//                                            } while true
//                                        }
//                                    } while true
//                                }
//                            }
//                        }
//                    }
//                }
//                for temporaryLetter in temporaryRedLetters {
//                    redLetters.append(temporaryLetter.letter)
//                }
//            } while GV.hintTable.count - startWordCounter < 10 && Date().timeIntervalSince(startTime) < maxInterval
////            for item in OKWords {
////                if !WTGameWordList.shared.roundContainsWord(word: item.hint) && !GV.hintTable.contains(item) {
////                    GV.hintTable.append(item)
////                }
////            }
//            if Date().timeIntervalSince(startTime) > maxInterval {
////                print("myIndex: \(myIndex)")
//                continue
//            }
//        }
//    }
//
    private func findWordsWithGreenAndRedLetters(gameNumber: Int, modifier: Int) {
        let random = MyRandom(gameNumber: gameNumber, modifier: modifier)

//        OKWords = [HintTableStruct]()
        maxInterval = 10.0
        let startWordCounter = GV.hintTable.count
        for myIndex in 0..<results.count {
            let startTime = Date()
            let resultIndex = results.count - 1 - myIndex
            if maxWordLength < results[resultIndex].first!.word.length {
                continue
            }
            let actResults = results[resultIndex]
            var wordIndexes = [Int]()
            for index in 0..<actResults.count {
                wordIndexes.append(index)
            }
            repeat {
                var wordOK = true
//                let index = Int.random(in: 0 ..< wordIndexes.count)
                let index = random.getRandomInt(0, max: wordIndexes.count - 1)
                let ind = wordIndexes[index]
                wordIndexes.remove(at: index)
                if wordIndexes.count == 0 {
                    break
                }
                let word = results[resultIndex][ind].word.myUpperCased()
                var temporaryRedLetters = [(letter:String, index:Int)]()
                var searchWord = "".fill(with: "?", toLength: word.length)
                var countGreenLetters = 0

                for (letterIndex, letter) in word.enumerated() {
                        if !redLetters.contains(String(letter)) {
                            wordOK = false
//                                break
                            searchWord = searchWord.changeChars(at: letterIndex, to: String(letter))
                            countGreenLetters  += 1
                        } else {
                            temporaryRedLetters.append((String(letter), letterIndex))
                            let index = redLetters.firstIndex(of: String(letter))
                            if index != nil {
                                redLetters.remove(at: index!)
                            }
                        }
                }
                if wordOK && maxWordLength >= word.length {
                    let item = HintTableStruct(hint: word, search: searchWord.myUpperCased(), type: .WithRedLetter, count: 0)
                    if !WTGameWordList.shared.roundContainsWord(word: item.hint) && !GV.hintTable.contains(item) {
                        GV.hintTable.append(item)
                    }

//                    if !OKWords.contains(where: {$0.hint == word}) {
//                        OKWords.append(HintTableStruct(hint: word, search: searchWord.myUpperCased(), type: .WithRedLetter, count: 0))
//                    }
                } else {
                    if let index = searchWord.index(from: 0, of: "?") {
                        if index > 0 && index < 9 {
                            print("searchWord: \(searchWord)") // itt bővíteni!!!
                            let endsWith = "".fill(with: "?", toLength: word.length - index)
                            if endsWith.length > maxWordLength {
                                continue
                            }
                            if searchWord.ends(with: endsWith)  {
                                var myLetters = [[UsedLetter]]()
                                for letter in searchWord.startingSubString(length: index) {
                                    if greenLetters[String(letter)] != nil && greenLetters[String(letter)]!.count > 0 {
                                        myLetters.append(greenLetters[String(letter)]!)
                                    } else {
                                        myLetters.removeAll()
                                        break
                                    }
                                }
                                if myLetters.count == index {
                                    var indexes = [Int](repeating: 0, count: index)
                                    stopCycle:
                                    repeat {
                                        var letters = [UsedLetter]()
                                        for (letterIndex, myLetter) in myLetters.enumerated() {
                                            let actIndex = indexes[letterIndex]
                                            letters.append(myLetter[actIndex])
                                        }
                                        let (checkOK, errorIndex) = checkLetters(letters: letters, free: word.length - index)
                                        if checkOK {
                                            let item = HintTableStruct(hint: word, search: searchWord.myUpperCased(), type: .WithGreenLetter, count: countGreenLetters)
                                            if !WTGameWordList.shared.roundContainsWord(word: item.hint) && !GV.hintTable.contains(item) {
                                                GV.hintTable.append(item)
                                            }
//                                            if !OKWords.contains(where: {$0.hint == word}) {
////                                                print("word: \(word), searchWord: \(searchWord)")
//                                                OKWords.append(HintTableStruct(hint: word, search: searchWord.myUpperCased(), type: .WithGreenLetter, count: countGreenLetters))
//                                            }
                                            break stopCycle
                                        } else {
                                            var indexForIndexes = errorIndex //indexes.count - 1
                                            repeat {
                                                indexes[indexForIndexes] += 1
                                                if indexes[indexForIndexes] > myLetters[indexForIndexes].count - 1 {
                                                    indexes[indexForIndexes] = 0
                                                    if indexForIndexes > 0 {
                                                        indexForIndexes -= 1
                                                    } else {
                                                        break stopCycle
                                                    }
                                                } else {
                                                    break
                                                }
                                            } while true
                                        }
                                    } while true
                                }
                            }
                        }
                    }
                }
                for temporaryLetter in temporaryRedLetters {
                    redLetters.append(temporaryLetter.letter)
                }
            } while GV.hintTable.count - startWordCounter < 20 && Date().timeIntervalSince(startTime) < maxInterval
//            for item in OKWords {
//                if !WTGameWordList.shared.roundContainsWord(word: item.hint) && !GV.hintTable.contains(item) {
//                    GV.hintTable.append(item)
//                }
//            }
            if Date().timeIntervalSince(startTime) > maxInterval {
//                print("myIndex: \(myIndex)")
                continue
            }
        }
    }
    let countHints = GV.onIpad ? 30 : 20
    
    private func checkLetters(letters: [UsedLetter], free: Int)->(Bool, Int) {
        var myLetters = [UsedLetter]()
        for (index, letter) in letters.enumerated() {
            if !myLetters.contains(letter) {
                myLetters.append(letter)
            } else {
                return (false, index)
            }
        }
        for (index, letter) in letters.enumerated() {
            if index < letters.count - 1 {
                let col = letters[index].col
                let row = letters[index].row
                let col1 = letters[index + 1].col
                let row1 = letters[index + 1].row
                if !((col == col1 && (row == row1 - 1 || row == row1 + 1)) ||
                   (row == row1 && (col == col1 - 1 || col == col1 + 1))) {
                    return (false, index + 1)
                }
            } else {
                for array in freeArrays {
                    for freePlace in array.freePlaces {
                        if (freePlace.col == letter.col && (freePlace.row == letter.row - 1 || freePlace.row == letter.row + 1)) ||
                            (freePlace.row == letter.row && (freePlace.col == letter.col - 1 || freePlace.col == letter.col + 1)) {
                            if array.countFree >= free {
                                return (true, index)
                            }
                        }
                    }
                }
            }
        }
        return (false, 0)
    }
    
    public func checkFreePlacesAtLetter(letter: UsedLetter, countLetters: Int)->Bool {
        
        for array in freeArrays {
            for freePlace in array.freePlaces {
                if (freePlace.col == letter.col && (freePlace.row == letter.row - 1 || freePlace.row == letter.row + 1)) ||
                    (freePlace.row == letter.row && (freePlace.col == letter.col - 1 || freePlace.col == letter.col + 1)) {
                    if array.countFree >= countLetters {
                        return true
                    }
                }
            }
        }
        return false
    }
    
//    var random: MyRandom?
    public func createHints(gameNumber: Int, round: Int) {
//        random = MyRandom(gameNumber: gameNumber % 1000, modifier: (round == 0 ? 1 : round - 1) * 22)
        
        GV.hintTable.removeAll()
//        if GV.hintTable.count == countHints {
//            return
//        }
        (maxWordLength, freeArrays) = wtGameboard!.getFreeArrays()
        redLetters = wtGameboard!.getRedLetters()
        fixLetters = wtGameboard!.getFixLetters()
//        freeGreenLetters = wtGameboard!.getFreeGreenLetters()
        greenLetters = wtGameboard!.getAllGreenLetters()
        results = getAllWords()
//        checkHintsTable(maxWordLength: maxWordLength)
//        startTime = Date()
        findWordsWithTwoFixLetters()
//        showTime(num: num1, string: "findWordsWithTwoFixLetters")
        if GV.hintTable.count < countHints {
            findWordsWithOneFixletter()
        }
        
        findWordsWithGreenAndRedLetters(gameNumber: gameNumber, modifier: (round == 0 ? 1 : round - 1) * 22)
    }
    
    deinit {
//        print("\n THE CLASS \((type(of: self))) WAS REMOVED FROM MEMORY (DEINIT) \n")
    }

    
    
}
