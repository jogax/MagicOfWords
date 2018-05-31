//
//  WordDBGenerator.swift
//  MagicOfWords
//
//  Created by Jozsef Romhanyi on 31/05/2018.
//  Copyright © 2018 Jozsef Romhanyi. All rights reserved.
//

import Foundation
import RealmSwift

class WordDBGenerator {
    
    init() {
        generateDBForLanguage(language: "en")
        generateDBForLanguage(language: "de")
        generateDBForLanguage(language: "hu")
        generateDBForLanguage(language: "ru")
    }
    
    private func generateDBForLanguage(language: String) {
        let wordFileURL = Bundle.main.path(forResource: "\(language)Words", ofType: "txt")
        // Read from the file Words
        var wordsFile = ""
        do {
            wordsFile = try String(contentsOfFile: wordFileURL!, encoding: String.Encoding.utf8)
        } catch let error as NSError {
            print("Failed reading from URL: \(String(describing: wordFileURL)), Error: " + error.localizedDescription)
        }
        let wordList = wordsFile.components(separatedBy: .newlines)
        for word in wordList {
            let wordModel = WordListModel()
            wordModel.word = language + word
            realm.beginWrite()
            realm.add(wordModel)
            try! realm.commitWrite()
            print(wordModel.word)
        }
    }

}
