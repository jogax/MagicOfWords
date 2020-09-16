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
    .tcEasyPlay:         "Szógyűjtő %",
    .tcMediumPlay:       "Fix-Betű %",
    .tcPlayer:           "Játékos",
    .tcNewGame:          "Új játék",
    .tcNewGameX:         "Új játék (%)",
    .tcRestart:          "Újrakezdés",
    .tcChooseGame:       "Válassz egy játéktipust",
    .tcFinished:         "Befejezett játékok %",
    .tcSettings:         "Beállítások",
    .tcWordTris:         "Szótris",
    .tcSearchWords:      "Szókeresés",
    .tcCancel:           "Mégsem",
    .tcLoadingInProgress: "A magyar szavak betöltése folyamatban",
    .tcChooseGameType:    "Játéktípus választás",
    .tcBack:              "Vissza",
    .tcHeader:            "Kör: %, Idő: %",
    .tcMe:                " (Én)",
    .tcScore:             "Pontok",
    .tcPlace:             "Hely",
    .tcKeywordHeader:     "Kulcs:",
    .tcMyWordsHeader1000: "-> % szót találtál a %-ból",
    .tcMyWordsHeader250:  "-> %/% betüt használtál fel",
    .tcMyScoreHeader:     "-> %. Hely (Én): % (%)",
    .tcBestScoreHeader:   "-> %. Hely     : % (%)",
//    .tcActScoreHeader:"Most játszik: %: %",
    .tcBonusHeader:       "Bónusz pontok: %",
    .tcWordsToCollect:    "Kirakandó szavak: (% / % / % / %)",
    .tcOwnWords:          "Saját szavaim (% / % / %)",
    .tcGameFinished1:     "Tényleg új játékot akarsz elindítani?",
    .tcGameFinished2:     "Később bármikor lapozhatsz a megkezdett játékok között a \">\", \"<\" gombok segítségével",
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
    .tcNextRound:            "Új kör",
//    .tcNoMoreStepsAnswer3: "Saját szavak kijelölése",
    .tcAlphabet:           "AÁBCDEÉFGHIÍJKLMNOÓÖŐPRSTUÚÜŰVZY",
//    .tcFrequency:           "A°8/Á°5/B°2/C°2/D°2/E°7/É°3/F°1/G°3/H°1/I°4/Í°1/J°1/K°4/L°6/M°3/N°4/O°4/Ó°2/Ö°1/Ő°1/P°2/R°6/S°8/T°6/U°2/Ú°0/Ü°1/Ű°0/V°2/Z°4/Y°2",
    .tcNickNameLetters:    "ABCDEFGHIJKLMNOPRSTUVZY",
    .tcOK:                  "OK",
    .tcReady:               "Kész",
    .tcChooseLanguage:      "Válassz nyelvet",
    .tcWord:                "Szó",
    .tcCount:               "Db.",
    .tcLength:              "Hossz",
    .tcMinutes:             "Perc",
    .tcShowAllWords:        "Szavaim", //"Mutasd az összes szót",
    .tcWordsOverLetter:     "Szavak a(z) \"%\" betü felett",
    .tcShowRealmCloud:      "Mutasd a Game Center adatokat",
    .tcShowCloudData:       "Mutasd az iCloud adatokat",
    .tcNickName:            "Becenév",
    .tcIsOnline:            "Online",
    .tcOnlineSince:         "Mióta_Online",
    .tcOnlineTime:          "Online",
    .tcLastOnline:          "Utoljára",
    .tcLastOnlineTime:      "Időtartam",
    .tcSetNickName:         "Válassz becenevet",
    .tcSave:                "Mentés",
    .tcAddCodeRecommended:  "Ha hozzáad egy kulcsszót, akkor ugyanazt a becenevet használhatja az összes eszközén",
    .tcKeyWord:             "Kulcsszó hozzáadása ...",
    .tcNicknameUsed:        "A '%' becenevet másik eszközön használják!",
    .tcNicknameUsedwithout: "A '%' becenevet másik eszközön használják kulcsszó nélkül!",
    .tcNicknameActivating:  "Ha ez a te másik eszközöd, nyisd meg az eszközt, és adj egy kulcsszót becenévhez!",
    .tcAddKeyWord:          "Ha ez a te másik eszközöd, írd be itt ugyanazt a kulcsszót mint azon az eszközön, egyébként válassz más becenevet!",
    .tcChooseAction:        "Válassz!",
    .tcTableOfEasyBestscores:"%Szógyűjtő eredmények",
    .tcTableOfMediumBestscores:"%Fix-Betű eredmények",
    .tcTableOfWordCounts:    "Szó számlálók",
    .tcGamesToContinue:     "Válaszd ki a játékot a folytatáshoz",
    .tcPlayerHeader:        "Játékos",
    .tcMyHeader:            "Saját eredmény",
    .tcActDifficulty:       "Nehézség: %",
    .tcGameIsFinished:      "A %. játék már be lett fejezve!",
    .tcRestartGameQuestion: "Folytathatod vagy újraindíthatod a játékot! Újraindításkor a pontszám törlődik!",
    .tcRestartGame:         "Újraindítás",
    .tcContinueGame:        "Folytatás",
    .tcShowWordlistHeader:  " A talált szavak listája (%)",
    .tcSearchingWord:       " Kereső szó: %",
    .tcCollectMandatory:    "Kötelező szavak keresése",
    .tcCreateMandatory:     "Kötelező szavak generálása",
    .tcChangeWord:          " módosít",
    .tcCongratulationsAllWords: "Gratulálok! Teljesítetted a feladatot, % különböző szót gyűjtöttél össze! % Pontot szereztél és a(z) %-ik helyre jutottál!",
    .tcCongratulationsMessageEasy: "Folytathatod a játékot egy új cél kitűzésével (% szó összegyűjtése), vagy új játékot indíthatsz",
    .tcCongratulationsMessageMedium: "Folytathatod a játékot egy új cél kitűzésével (% fix betű felhasználása) vagy új játékot indíthatsz",    .tcCongratulationsAllLetters: "Gratulálok! Teljesítetted a feladatot, % fix betűt használtál fel! % Pontot szereztél és a(z) %-ik helyre jutottál!",
    .tcCongratulations1:    "Gratulálok! Felhasználtad a fix betűket!",
    .tcCongratulationsEasy1:"Gratulálok!",
    .tcCongratulations2:    "Befejezheted a játékot (nyomd meg a <Befejezem> gombot) vagy folytathatod a játékot, hogy több pontot szerezz (nyomd meg a <Tovább> gombot)!",
    .tcContinuePlaying:     "Tovább",
    .tcFinishGame:          "Befejezem",
    .tcChoosedWord:         " Hozzáadva",
    .tcCountLetters:        "% betüs kötelező szavak keresése",
    .tcAllWords:            "%/% Szó, kiválasztva: %/%",
    .tcIWillAdd:            " Hozzáadom",
    .tcIWillDelete:         " Törlöm",
    .tcIWillSeparate:       " Leválasztom",
    .tcMyCounts:           "Hozzáadtam:%, leválasztottam:%, töröltem:% szót",
//    .tcChooseStyle:        "Válassz egy játékstílust",
//    .tcSimpleStyle:        "Egyszerű",
//    .tcEliteStyle:         "Elegáns",
    .tcGenerateBestScore:  "Legjobb eredmények lista generálása",
    .tcDevice:             "Készülék",
    .tcLand:               " Ország",
    .tcUseCloudGameData:   "Játék a felhőből",
    .tcChooseGameToGet:    "Válassz egy játékot a letöltéshez",
    .tcGameLine:           "Bejelentő: %, Játék: %",
//    .tcWelcomeText1:        "Üdvözöllek a szavak/csodálatos világában!",
//    .tcWelcomeText2:        "Érezd jól magad!",
//    .tcWelcomeText3:        "És most lássuk,/hogyan kell játszani egy//Szógyűjtő//vagy//Fix-Betű//játékot",
//    .tcLater:               "Később",
//    .tcShowEasyGame:        "Szógyűjtő",
//    .tcShowMediumGame:      "Fix-Betű",
//    .tcHelpGenNew:          "Új Demo",
//    .tcHelpGenContinue:     "Demo folytatás",
    .tcDeveloperMenu:       "Fejlesztői menü",
//    .tcShowHelp:            "Mutasd a Demo-játékot",
//    .tcDemoFinishedTitle:   "A demó befejeződött!",
//    .tcDemoFinishedMessage: "Remélem, hasznos volt számodra! Ha újra szeretnéd látni a demót, akkor elindíthatod azt a <Menü - Beállítások - Mutasd a Demo-játékot> menüpontban. És most kezdhetsz egy új játékot, vagy elindíthatod a főmenüt",
//    .tcDemoFinishedStartNewGame: "Új játék",
//    .tcDemoFinishedGoToMenu: "Vissza a főmenübe",
//    .tcChooseDifficulty:    "Válassz nehézséget",
//    .tcCurrentDifficulty:   "Jelenlegi nehézség: %",
//    .tcAreYouSureForNewDemo: "Biztosan új demót akarsz létrehozni?",
    .tcAreYouSureMessage:   "A régi demo információ törlődik!",
    .tcVersion:             "Verzió",
    .tcActVersion:          "©MagicOfWords V%",
    .tcAskForGameCenter: "Csatlakozhatsz a Game Centerhez, \r\n" +
                        "hogy lásd, hány pontja van a többi játékosnak.",
    .tcAskLater:        "Kérdezz később",
    .tcAskNoMore:       "Ne kérdezz többé",
    .tcConnectGC:       "Kapcs. a Game Centerhez",
//    .tcDisconnectGC:    "Lekapcsolódás a Game Centerről",
    .tcNobody:          "Ismeretlen",
    .tcEasyScore:       "Szógyűjtő",
    .tcMediumScore:     "Fix-Betű",
    .tcShowGameCenter:  "Mutasd a Game Center-t",
    .tcEasyActScore:    "SzógyűjtőAct",
    .tcMediumActScore:  "Fix-BetűAct",
    .tcCountPlays:      "Játszott",
    .tcBlank:           " ",
    .tcStartGame:       "Játék",
    .tcWordCount:       "Szó számlálók",
    .tcLocalPlayerNotAuth: "Nem sikerült a kapcsolatfelvétel!",
    .tcChooseWhatYouWant: "Válassz egy táblázatot",
    .tcChooseTimeScope: "Válassz egy időtartamot",
    .tcAll:             "Összes",
    .tcWeek:            "Hét",
    .tcToday:           "Ma",
    .tcCounters:        "Számlálók",
//    .tcChooseGoalForWords:"Válassz, hogy hány szót szeretnél gyűjteni",
//    .tcChooseGoalForLetters: "Válassz hány fix betűt szeretnél felhasználni",
//    .tcGoalMessageForWords: "A játék akkor fejeződik be, a megjelölt számú különböző szót kiraktad",
//    .tcGoalMessageForLetters: "A játék akkor fejeződik be, ha a megjelölt számú fix betűt felhasználtad",
    .tcTipp:            "Tipp: %",
    .tcShouldReport:    "Közölni szeretnéd a(z) \"%\" szót a fejlesztővel?",
    .tcReportDescription: "Ha ez tényleg egy létező szó (egyesszámű főnév), akkor % jutalompontot kapsz minden használatakor! Az ellenőrzés néhány napot vesz igénybe, elfogadás esetén értesítést kapsz!",
    .tcYes:             "Igen",
    .tcShowWordReports: "Mutasd az új szavakat a Cloud-ban",
    .tcNoNewWords:      "Nincsenek feldolgozandó szavak",
    .tcStatus:          "Status",
    .tcDeniedReport:    "Az általad bejelentett szó \"%\" nem létezik!",
    .tcDeniedDescription: "Legközelebb ügyelj, hogy csak hiányzó egyes számú főnevet jelents be!",
    .tcAcceptedReport:    "Gratulálok! Az általad bejelentett szó \"%\" létezik!",
    .tcAcceptedDescription: "Ezért  % jutalompont jár neked a szó minden felhasználásakor!",
    .tcWordReportedTitle:    "A szó elküldve a fejlesztőnek!",
    .tcWordReportedMessage:     "Kérlek várj türelemmel a válaszra!",
    .tcHintsHeader:             "Néhány tipp",
    .tcChooseGameSize:          "Válassz játék méretet",
    .tcCongratulations:         "Gratulálok!",
    .tcFinishGameMessage:       "Befejezted a játékot. Új játék indul.",
    .tcWordsToFind:             "Keresendő szavak:",
]
