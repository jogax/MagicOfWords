//
//  de.swift
//  Szómágia
//
//  Created by Jozsef Romhanyi on 31.01.18.
//  Copyright © 2018 Jozsef Romhanyi. All rights reserved.
//


let deDictionary: [TextConstants: String] = [
    .tcAktLanguage:      "de",
    .tcLanguage:         "Sprache",
    .tcEnglish:          "English (Angol)",
    .tcGerman:           "Deutsch (Német)",
    .tcHungarian:        "Magyar (Magyar)",
    .tcRussian:          "Русский (Orosz)",
    .tcEnglishShort:     "en",
    .tcGermanShort:      "de",
    .tcHungarianShort:   "hu",
    .tcRussianShort:     "ru",
    .tcNewGame:          "Neues Spiel %",
    .tcRestart:          "Neustart",
    .tcContinue:         "Fortsetzen %",
    .tcFinished:         "Beendete Spiele %",
    .tcSettings:         "Einstellungen",
    .tcWordTris:         "Wortris",
    .tcSearchWords:      "Wörter suchen",
    .tcCancel:           "Abbrechen",
    .tcLoadingInProgress: "Deutsche Wörter werden gerade geladen",
    .tcChooseGameType:    "Spieltyp wählen",
    .tcBack:              "Zurück",
    .tcHeader:             "Spiel: %, Runde: %, Zeit: %",
//    .tcTime:               "Zeit: %",
    .tcScore:             "Punkte:",
    .tcPlace:             "Platz:",
    .tcKeywordHeader:     "Schlüssel:",
    .tcMyScoreHeader:     "%. Platz (Ich): % (%)",
    .tcBestScoreHeader:   "1. Platz      : % (%)",
//    .tcActScoreHeader:"Jetzt spielt: %: %",
    .tcBonusHeader:       "Bonuspunkte: %",
    .tcWordsToCollect:    "Zu sammelnde Wörter: (% / % / % / %)",
    .tcOwnWords:          "Eigene Wörter (% / % / %)",
    .tcGameFinished1:     "Möchtest Du das Spiel wirklich beenden?",
    .tcGameFinished2:     "Wenn Du später doch weiterspielen möchtest, kannst Du in Menüpunkt <Bestes Ergebnis> fortfahren!",
    .tcBestScore:          "Beste Erg.",
    .tcBestPlayer:         "Bester Sp.",
    .tcCollectedRequiredWords: "Pflichtwörter",
    .tcCollectedOwnWords:      "Eigene Wörter",
    .tcTotal:               "Insgesamt:",
    .tcTaskNotCompletedWithNoMoreSteps: "Keine weiteren Schritte, Aufgabe nicht erledigt!",
    .tcTaskNotCompletedWithTimeOut: "Timeout, Aufgabe nicht erledigt!",
    .tcWillBeRestarted:     "Das Spiel wird neu gestartet!",
    .tcNoMoreStepsQuestion1: "Keine weiteren Schritte!",
//    .tcNoMoreStepsQuestion2: "Möchtest du eigenen Wörter markieren?",
//    .tcNoMoreStepsAnswer1: "Ja",
    .tcNoMoreStepsAnswer2: "Nächste Runde",
    .tcNoMoreStepsAnswer3: "Eigene Wörter markieren",
    .tcAlphabet:           "ABCDEFGHIJKLMNOPQRSTUVWXYZÄÖÜß",
//    .tcFrequency:           "A°6/B°2/C°3/D°2/E°15/F°2/G°4/H°4/I°6/J°0/K°3/L°4/M°2/N°9/O°3/P°2/Q°0/R°8/S°8/T°7/U°4/V°1/W°1/X°0/Y°0/Z°1/Ä°1/Ö°0/Ü°1/ẞ°0",
    .tcNickNameLetters:    "ABCDEFGHIJKLMNOPQRSTUVWXYZ",
    .tcGameNumber:          "Spiel",
    .tcOK:                  "OK",
    .tcReady:               "Fertig",
    .tcChooseLanguage:      "Sprache wählen",
    .tcWord:                "Wort:",
    .tcCount:               "Cnt:",
    .tcLength:              "Len:",
    .tcMinutes:             "Min:",
    .tcShowAllWords:        "Meine Wörter",//"Zeige alle Wörter",
    .tcWordsOverLetter:   "Wörter über den Buchstaben",
    .tcMe:                  "Ich",
    .tcShowRealmCloud:      "Zeige Realm Cloud",
    .tcNickName:            "Spitzname",
    .tcIsOnline:            "ist online",
    .tcOnlineSince:         "Online_seit",
    .tcOnlineTime:          "Onlinezeit",
    .tcLastOnline:          "Zuletzt        ",
    .tcLastOnlineTime:      "Dauer",
    .tcSetNickName:         "Spitzname ändern",
    .tcSave:                "Speichern",
    .tcAddCodeRecommended:  "Wenn Du ein Keyword hinfügst, kannst Du auf allen Deien Geräten denselben Benutzernamen verwenden",
    .tcKeyWord:             "Füge ein Keyword hinzu ...",
    .tcNicknameUsed:        "Spitzname '%' wird auf einem anderen Gerät verwendet!",
    .tcNicknameUsedwithout: "Spitzname '%' wird auf einem anderen Gerät verwendet ohne Schlüsselwort!",
    .tcNicknameActivating:  "Wenn dies Dein Gerät ist, öffne es und füge ein Schlüsselwort dem Spitzname hinzu!",
    .tcAddKeyWord:          "Wenn dies Dein Gerät ist, füge hier dasselbe Schlüsselwort hinzu, ansonsten wähle einen anderen Spitznamen!",
    .tcChooseAction:        "Bitte wählen!",
    .tcTableOfBestscores:   "Tabelle der besten Ergebnisse",
    .tcGamesToContinue:     "Wähle ein Spiel um fortzufahren",
    .tcBestPlayerHeader:    "Bestes Ergebnis",
    .tcMyHeader:            "Mein Erg/Pl.",
    .tcMyNickName:          "Mein Spitzname: %\r\nSchwierigkeit: %",
    .tcGameIsFinished:      "Das Spiel % ist bereits beendet!",
    .tcRestartGameQuestion: "Du kannst das Spiel fortsetzen oder neu starten! Beim Neustart werden die Ergebnisse gelöscht!",
    .tcRestartGame:         "Neu starten",
    .tcContinueGame:        "Fortsetzen",
    .tcShowWordlistHeader:  " Liste der gefundenen Wörter (%)",
    .tcSearchingWord:       " Suchwort: %",
    .tcCollectMandatory:    "Pflichtwörter suchen",
    .tcCreateMandatory:     "Pflichtwörter erstellen",
    .tcChangeWord:          " ändern",
    .tcCongratulationsFix1:    "Herzlichen Glückwunsch! Du hast alle festen Buchstaben verwendet! Aber Du muss noch die Pflichtwörter zusammenstellen!",
    .tcCongratulationsFix2:     "Stelle die restliche Pflichtwörter zusammen!",
    .tcCongratulationsMandatory1:    "Herzliche Glückwunsch! Du hast alle Pflichtwörter zusammengestellt! Du muss aber auch alle Feste Buchstaben verwenden!",
    .tcCongratulationsMandatory2:     "Verwende auch die restliche feste Buchstaben!",
    .tcCongratulations1:    "Herzlichen Glückwunsch!  Du hast alle Pflichtwörter zusammengestellt und auch alle Feste Buchstaben verwendet!",
    .tcCongratulationsEasy1:"Herzliche Glückwunsch! Du hast alle Pflichtwörter zusammengestellt!",
    .tcCongratulations2:    "Du kannst das Spiel beenden (berühre den Knopf <Beenden>) oder weiterspielen um mehr Punkte zu sammeln (berühre den Knopf <Weiterspielen>)",
    .tcContinuePlaying:     "Weiterspielen",
    .tcFinishGame:          "Beenden",
    .tcChoosedWord:         " Hinzugefügt",
    .tcCountLetters:        "Suche nach Pflichtwörter mit 5 Buchstaben",
    .tcAllWords:            "%/% Wörter, gwwählt: %/%",
    .tcIWillAdd:           " Ich füge hinzu",
    .tcIWillDelete:        " Ich lösche",
    .tcIWillSeparate:      " Ich trenne",
    .tcMyCounts:           "Ich habe hinzugefügt:%, getrennt:%, gelöscht:% Wörter",
    .tcChooseStyle:        "Wähle einen Stil für das Spiel",
    .tcSimpleStyle:        "Einfach",
    .tcEliteStyle:         "Elite",
    .tcGenerateBestScore:  "BestScore-Liste generieren",
    .tcDevice:             "Gerät",
    .tcLand:               " Land",
    .tcUseCloudGameData:   "Spiel aus der Cloud",
    .tcChooseGameToGet:    "Wähle einen Spiel für einlesen vom Cloud",
    .tcGameLine:           "Notifier: %, GameNumber: %",
    .tcWelcomeText1:        "Herzlich Willkommen in der/wunderbaren Welt von Wörter!",
    .tcWelcomeText2:        "Viel Spaß!",
    .tcWelcomeText3:        "Und jetzt wollen wir sehen,/wie man ein einfaches oder/mittelschweres Spiel spielt",
    .tcLater:               "Später",
    .tcShowEasyGame:        "Einfaches",
    .tcShowMediumGame:      "Mittelschweres",
    .tcHelpGenNew:          "Demo erstellen",
    .tcHelpGenContinue:     "Demo fortsetzen",
    .tcDeveloperMenu:       "Menü für Entwickler",
    .tcShowHelp:            "Zeige Demo-Spiel",
    .tcDemoFinishedTitle:   "Demo ist fertig!",
    .tcDemoFinishedMessage: "Ich hoffe es war hilfreich für Dich! Wenn Du die Demo noch einmal sehen möchtest, kannst Du unter <Menü - Einstellungen - Zeige Demo-Spiel> starten. Und jetzt kannst Du weiterspielen oder zum Menü gehen",
    .tcDemoFinishedStartNewGame: "Neues Spiel",
    .tcDemoFinishedGoToMenu: "Gehe zum Menü",
    .tcChooseDifficulty:    "Wähle Schwierigkeitsgrad",
    .tcCurrentDifficulty:   "Aktuelle Schwierigkeit: %",
    .tcSimpleGame:          "Einfach",
    .tcMediumGame:          "Mittel",
    .tcHardGame:            "Hart",
    .tcVeryHardGame:        "Sehr hart",
    .tcAreYouSureForNewDemo: "Möchten Sie wirklich eine neue Demo erstellen??",
    .tcAreYouSureMessage:   "Die alte Demo-Informationen werden gelöscht!",
    .tcVersion:             "Version",
]



