//
//  Language.swift
//  JLinesV1
//
//  Created by Jozsef Romhanyi on 31.01.18.
//  Copyright (c) 2018 Jozsef Romhanyi. All rights reserved.
//

import UIKit

enum TextConstants: Int {
    case
    tcAktLanguage = 0,
    tcLanguage,
    tcEnglish,
    tcGerman,
    tcHungarian,
    tcRussian,
    tcEnglishShort,
    tcGermanShort,
    tcHungarianShort,
    tcRussianShort,
    tcNewGame,
    tcRestart,
    tcContinue,
    tcFinished,
    tcSettings,
    tcWordTris,
    tcSearchWords,
    tcCancel,
    tcLoadingInProgress,
    tcChooseGameType,
    tcBack,
    tcHeader,
    tcTime,
    tcWordsToCollect,
    tcOwnWords,
    tcNoMoreSteps,
    tcScore,
    tcBestPlayer,
    tcBestScore,
    tcCollectedRequiredWords,
    tcCollectedOwnWords,
    tcTotal,
    tcTaskNotCompletedWithNoMoreSteps,
    tcTaskNotCompletedWithTimeOut,
    tcWillBeRestarted,
    tcNoMoreStepsQuestion,
    tcNoMoreStepsAnswer1,
    tcNoMoreStepsAnswer2,
    tcAlphabet,
    tcGameNumber,
    tcOK,
    tcChooseName,
    tcReady,
    tcChooseLanguage,
    tcWord,
    tcCount,
    tcLength,
    tcMinutes,
    tcShowAllWords,
    tcWordsOverLetter,
    tcMe
}

    let LanguageEN = "en" // index 0
    let LanguageDE = "de" // index 1
    let LanguageHU = "hu" // index 2
    let LanguageRU = "ru" // index 3

enum LanguageCodes: Int {
    case enCode = 0, deCode, huCode, ruCode
}


class Language {
    
    let languageNames = [LanguageEN, LanguageDE, LanguageHU, LanguageRU]
    
    let languages = [
        "de": deDictionary,
        "en": enDictionary,
        "hu": huDictionary,
        "ru": ruDictionary
    ]
    
    
    struct Callback {
        var function: ()->Bool
        var name: String
        init(function:@escaping ()->Bool, name: String) {
            self.function = function
            self.name = name
        }
    }
    var callbacks: [Callback] = []
    var aktLanguage = [TextConstants: String]()
    
    init() {
        checkPreferredLanguage()
    }
    
    func checkPreferredLanguage() {
        var preferredLanguage = getPreferredLanguage()
        if !languageNames.contains(preferredLanguage) {
            preferredLanguage = LanguageEN
        }
        aktLanguage = languages[preferredLanguage]!

    }
    
    func setLanguage(_ languageKey: String) {
        if languageNames.contains(languageKey) {
           aktLanguage = languages[languageKey]!
        } else {
            aktLanguage = languages[LanguageEN]!
        }
        for index in 0..<callbacks.count {
            _ = callbacks[index].function()
        }
    }
    
    func setLanguage(_ languageCode: LanguageCodes) {
        aktLanguage = languages[languageNames[languageCode.rawValue]]!
        for index in 0..<callbacks.count {
            _ = callbacks[index].function()
        }
    }
    
    func getText (_ textIndex: TextConstants, values: String ...) -> String {
        return aktLanguage[textIndex]!.replace("%", values: values)
    }

    func getAktLanguageKey() -> String {
        return aktLanguage[.tcAktLanguage]!
    }
    
    func isAktLanguage(_ language:String)->Bool {
        return language == aktLanguage[.tcAktLanguage]
    }
    
    func addCallback(_ callback: @escaping ()->Bool, callbackName: String) {
        callbacks.append(Callback(function: callback, name: callbackName))
    }
    
    func removeCallback(_ callbackName: String) {
        for index in 0..<callbacks.count {
            if callbacks[index].name == callbackName {
                callbacks.remove(at: index)
                return
            }
        }
    }
    
    func getPreferredLanguage()->String {
        let deviceLanguage = Locale.preferredLanguages[0]
        let languageKey = deviceLanguage[deviceLanguage.startIndex..<deviceLanguage.self.index(deviceLanguage.startIndex, offsetBy: 2)]
        return String(languageKey)
    }
    
    func count()->Int {
        return languages.count
    }
    
    func getLanguageNames(_ index:LanguageCodes)->(String, Bool) {
        switch index {
            case .enCode: return (aktLanguage[.tcEnglish]!, aktLanguage[.tcAktLanguage] == LanguageEN)
            case .deCode: return (aktLanguage[.tcGerman]!, aktLanguage[.tcAktLanguage] == LanguageDE)
            case .huCode: return (aktLanguage[.tcHungarian]!, aktLanguage[.tcAktLanguage] == LanguageHU)
            case .ruCode: return (aktLanguage[.tcRussian]!, aktLanguage[.tcAktLanguage] == LanguageRU)
        }
    }
    
}


