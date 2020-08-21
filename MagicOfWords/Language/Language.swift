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
    tcEasyPlay,
    tcMediumPlay,
    tcPlayer,
    tcNewGame,
    tcNewGame5,
    tcNewGame6,
    tcNewGame7,
    tcNewGame8,
    tcNewGame9,
    tcNewGame10,
    tcRestart,
//    tcContinue,
    tcFinished,
    tcSettings,
    tcWordTris,
    tcSearchWords,
    tcCancel,
    tcLoadingInProgress,
    tcChooseGameType,
    tcBack,
    tcHeader,
    tcMe,
    tcScore,
    tcPlace,
    tcKeywordHeader,
    tcMyWordsHeader1000,
    tcMyWordsHeader250,
    tcMyScoreHeader,
    tcBestScoreHeader,
    tcBonusHeader,
    tcWordsToCollect,
    tcOwnWords,
    tcGameFinished1,
    tcGameFinished2,
    tcBestPlayer,
    tcBestScore,
    tcCollectedRequiredWords,
    tcCollectedOwnWords,
    tcTotal,
    tcTaskNotCompletedWithNoMoreSteps,
    tcTaskNotCompletedWithTimeOut,
    tcWillBeRestarted,
    tcNoMoreStepsQuestion1,
    tcNextRound,
//    tcNoMoreStepsAnswer3,
    tcAlphabet,
//    tcFrequency,
    tcNickNameLetters,
    tcGameNumber,
    tcOK,
    tcReady,
    tcChooseLanguage,
    tcWord,
    tcCount,
    tcLength,
    tcMinutes,
    tcShowAllWords,
    tcWordsOverLetter,
    tcShowRealmCloud,
    tcShowCloudData,
    tcNickName,
    tcIsOnline,
    tcOnlineSince,
    tcOnlineTime,
    tcLastOnline,
    tcLastOnlineTime,
    tcSetNickName,
    tcSave,
    tcAddCodeRecommended,
    tcKeyWord,
    tcNicknameUsed,
    tcNicknameUsedwithout,
    tcNicknameActivating,
    tcAddKeyWord,
    tcChooseAction,
    tcTableOfEasyBestscores,
    tcTableOfMediumBestscores,
    tcTableOfWordCounts,
    tcGamesToContinue,
    tcPlayerHeader,
    tcMyHeader,
    tcActDifficulty,
    tcGameIsFinished,
    tcRestartGameQuestion,
    tcRestartGame,
    tcContinueGame,
    tcShowWordlistHeader,
    tcSearchingWord,
    tcCollectMandatory,
    tcCreateMandatory,
    tcChangeWord,
    tcCongratulationsAllWords,
    tcCongratulationsMessageEasy,
    tcCongratulationsMessageMedium,
    tcCongratulationsAllLetters,
    tcCongratulations1,
    tcCongratulationsEasy1,
    tcCongratulations2,
    tcContinuePlaying,
    tcFinishGame,
    tcChoosedWord,
    tcCountLetters,
    tcAllWords,
    tcIWillAdd,
    tcIWillDelete,
    tcIWillSeparate,
    tcMyCounts,
//    tcChooseStyle,
//    tcSimpleStyle,
//    tcEliteStyle,
    tcGenerateBestScore,
    tcDevice,
    tcLand,
    tcUseCloudGameData,
    tcChooseGameToGet,
    tcGameLine,
//    tcWelcomeText1,
//    tcWelcomeText2,
//    tcWelcomeText3,
//    tcLater,
//    tcShowEasyGame,
//    tcShowMediumGame,
//    tcHelpGenNew,
//    tcHelpGenContinue,
    tcDeveloperMenu,
//    tcShowHelp,
//    tcDemoFinishedTitle,
//    tcDemoFinishedMessage,
//    tcDemoFinishedStartNewGame,
//    tcDemoFinishedGoToMenu,
//    tcChooseDifficulty,
//    tcCurrentDifficulty,
//    tcAreYouSureForNewDemo,
    tcAreYouSureMessage,
    tcVersion,
    tcActVersion,
    tcAskForGameCenter,
    tcAskLater,
    tcAskNoMore,
    tcConnectGC,
    tcDisconnectGC,
    tcNobody,
    tcEasyScore,
    tcMediumScore,
    tcShowGameCenter,
    tcEasyActScore,
    tcMediumActScore,
    tcCountPlays,
    tcBlank,
    tcStartGame,
    tcWordCount,
    tcLocalPlayerNotAuth,
    tcChooseWhatYouWant,
    tcChooseTimeScope,
    tcAll,
    tcWeek,
    tcToday,
    tcCounters,
//    tcChooseGoalForWords,
//    tcChooseGoalForLetters,
//    tcGoalMessageForWords,
//    tcGoalMessageForLetters,
    tcTipp,
    tcShouldReport,
    tcReportDescription,
    tcYes,
    tcShowWordReports,
    tcNoNewWords,
    tcStatus,
    tcDeniedReport,
    tcDeniedDescription,
    tcAcceptedReport,
    tcAcceptedDescription,
    tcWordReportedTitle,
    tcWordReportedMessage,
    tcHintsHeader
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
    
    func getText (_ textIndex: TextConstants, forLanguage: String, values: String ...) -> String {
        return languages[forLanguage]![textIndex]!.replace("%", values: values)
//        return aktLanguage[textIndex]!.replace("%", values: values)
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
//        let deviceLanguage = Locale.preferredLanguages[0]
//        let languageKey = deviceLanguage[deviceLanguage.startIndex..<deviceLanguage.self.index(deviceLanguage.startIndex, offsetBy: 2)]
        return String(Locale.preferredLanguages[0].subString(at: 0, length: 2))
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


