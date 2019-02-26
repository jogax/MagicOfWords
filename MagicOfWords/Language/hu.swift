//
//  hu.swift
//  Flowers
//
//  Created by Jozsef Romhanyi on 20.09.15.
//  Copyright © 2015 Jozsef Romhanyi. All rights reserved.
//


let huDictionary: [TextConstants: String] = [
    .tcAktLanguage:      "hu",
    .tcLanguage:         "Nyelv",
    .tcEnglish:          "English (Angol)",
    .tcGerman:           "Deutsch (Német)",
    .tcHungarian:        "Magyar (Magyar)",
    .tcRussian:          "Русский (Orosz)",
    .tcEnglishShort:     "en",
    .tcGermanShort:      "de",
    .tcHungarianShort:   "hu",
    .tcRussianShort:     "ru",
    .tcNewGame:          "Új játék %",
    .tcRestart:          "Újrakezdés",
    .tcContinue:         "Folytatás %",
    .tcFinished:         "Befejezett játékok %",
    .tcSettings:         "Beállítások",
    .tcWordTris:         "Szótris",
    .tcSearchWords:      "Szó kereső",
    .tcCancel:           "Mégsem",
    .tcLoadingInProgress: "A magyar szavak betöltése folyamatban",
    .tcChooseGameType:    "Játéktípus választás",
    .tcBack:              "Vissza",
    .tcHeader:            "Játék: %, Kör: %,",
    .tcTime:              "Idő: %",
    .tcScore:             "Pontok:",
    .tcPlace:             "Hely:",
    .tcKeywordHeader:     "Kulcs:",
    .tcMyScoreHeader:     "%. Hely (Én): % (%)",
    .tcBestScoreHeader:   "1. Hely     : % (%)",
//    .tcActScoreHeader:"Most játszik: %: %",
    .tcBonusHeader:       "Bónusz pontok: %",
    .tcWordsToCollect:    "Kirakandó szavak: (% / % / % / %)",
    .tcOwnWords:          "Saját szavaim (% / % / %)",
    .tcGameFinished1:     "Tényleg be szeretnéd fejezni a játékot?",
    .tcGameFinished2:     "Ha később mégis folytatni szeretnéd, a <Legjobb eredmény> menüpontból folytathatod! ",
    .tcBestScore:         "Legjobb eredmény",
    .tcBestPlayer:        "Legjobb játékos",
    .tcCollectedRequiredWords:  "Kötelező szavak",
    .tcCollectedOwnWords:       "Saját szavak",
    .tcTotal:               "Összesen:",
    .tcTaskNotCompletedWithNoMoreSteps: "Nincs több lépés, feladat nem teljesült!",
    .tcWillBeRestarted:     "A játék újra indul!",
    .tcNoMoreStepsQuestion1: "Nincs több lépés!",
//    .tcNoMoreStepsQuestion2: "Szeretnél saját szavakat kijelölni?",
//    .tcNoMoreStepsAnswer1: "Igen",
    .tcNoMoreStepsAnswer2: "Következő kör",
    .tcNoMoreStepsAnswer3: "Saját szavak kijelölése",
    .tcAlphabet:           "AÁBCDEÉFGHIÍJKLMNOÓÖŐPRSTUÚÜŰVZY",
//    .tcFrequency:           "A°8/Á°5/B°2/C°2/D°2/E°7/É°3/F°1/G°3/H°1/I°4/Í°1/J°1/K°4/L°6/M°3/N°4/O°4/Ó°2/Ö°1/Ő°1/P°2/R°6/S°8/T°6/U°2/Ú°0/Ü°1/Ű°0/V°2/Z°4/Y°2",
    .tcNickNameLetters:    "ABCDEFGHIJKLMNOPRSTUVZY",
    .tcGameNumber:          "Játék",
    .tcOK:                  "OK",
    .tcReady:               "Kész",
    .tcChooseLanguage:      "Válassz nyelvet",
    .tcWord:                "Szó",
    .tcCount:               "Db.",
    .tcLength:              "Hossz",
    .tcMinutes:             "Perc",
    .tcShowAllWords:        "Mutasd az összes szót",
    .tcWordsOverLetter:     "Szavak a betü felett",
    .tcMe:                  "Én",
    .tcShowRealmCloud:      "Mutasd a Realm Cloud-ot",
    .tcNickName:            "Becenév",
    .tcIsOnline:            "Online",
    .tcOnlineSince:         "Mióta_Online",
    .tcOnlineTime:          "Online_idő  ",
    .tcSetNickName:         "Válassz becenevet",
    .tcSave:                "Mentés",
    .tcAddCodeRecommended:  "Ha hozzáad egy kulcsszót, akkor ugyanazt a becenevet használhatja az összes eszközén",
    .tcKeyWord:             "Kulcsszó hozzáadása ...",
    .tcNicknameUsed:        "A '%' becenevet másik eszközön használják!",
    .tcNicknameUsedwithout: "A '%' becenevet másik eszközön használják kulcsszó nélkül!",
    .tcNicknameActivating:  "Ha ez a te másik eszközöd, nyisd meg az eszközt, és adj egy kulcsszót becenévhez!",
    .tcAddKeyWord:          "Ha ez a te másik eszközöd, írd be itt ugyanazt a kulcsszót mint azon az eszközön, egyébként válassz más becenevet!",
    .tcChooseAction:        "Válassz!",
    .tcTableOfBestscores:   "A legjobb pontszámok táblázata",
    .tcGamesToContinue:     "Válaszd ki a játékot a folytatáshoz",
    .tcBestPlayerHeader:    "Legjobb eredm.",
    .tcMyHeader:            "Saját eredm./Hely",
    .tcMyNickName:          "Becenevem: %",
    .tcGameIsFinished:      "A %. játék már be lett fejezve!",
    .tcRestartGameQuestion: "Folytathatod vagy újraindíthatod a játékot! Újraindításkor a pontszám törlődik!",
    .tcRestartGame:         "Újraindítás",
    .tcContinueGame:        "Folytatás",
    .tcShowWordlistHeader:  " A talált szavak listája (%)",
    .tcSearchingWord:       " Kereső szó: %",
    .tcCollectMandatory:    "Kötelező szavak keresése",
    .tcCreateMandatory:     "Kötelező szavak generálása",
    .tcChangeWord:          " módosít",
    .tcCongratulations1:    "Gratulálok! Minden kötelező szót kiraktál!",
    .tcCongratulations2:    "Tovább játszhatsz és pontokat gyűjthetsz vagy a <Befejezem> gomb megérintésével befejezheted a játékot!",
    .tcContinuePlaying:     "Tovább játszom",
    .tcFinishGame:          "Befejezem",
    .tcChoosedWord:         " Hozzáadva",
    .tcCountLetters:        "% betüs kötelező szavak keresése",
    .tcAllWords:            "%/% Szó, kiválasztva: %/%",
    .tcIWillAdd:            " Hozzáadom",
    .tcIWillDelete:         " Törlöm",
    .tcIWillSeparate:       " Leválasztom",
    .tcMyCounts:           "Hozzáadtam:%, leválasztottam:%, töröltem:% szót",
]
