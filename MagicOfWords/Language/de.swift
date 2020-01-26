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
    .tcEasyPlay:         "%Spiel Sammle-Wörter",
    .tcMediumPlay:       "%Spiel Verwende-Feste-Buchstaben",
    .tcPlayer:           "Spieler",
    .tcNewGame:          "Neues Spiel",
    .tcRestart:          "Neustart",
//    .tcContinue:         "Fortsetzen %",
    .tcFinished:         "Beendete Spiele %",
    .tcSettings:         "Einstellungen",
    .tcWordTris:         "Wortris",
    .tcSearchWords:      "Wörter suchen",
    .tcCancel:           "Abbrechen",
    .tcLoadingInProgress: "Deutsche Wörter werden gerade geladen",
    .tcChooseGameType:    "Spieltyp wählen",
    .tcBack:              "Zurück",
    .tcHeader:             "Runde: %, Zeit: %",
    .tcMe:                " (Ich)",
    .tcScore:             "Punkte",
    .tcPlace:             "Platz",
    .tcKeywordHeader:     "Schlüssel:",
    .tcMyWordsHeader1000: "-> Gesammelt % aus % Wörter",
    .tcMyWordsHeader250:  "-> Gesammelt %/% Buchstaben/Wörter",
    .tcMyScoreHeader:     "-> %. Platz (Ich): % (%)",
    .tcBestScoreHeader:   "-> %. Platz      : % (%)",
//    .tcActScoreHeader:"Jetzt spielt: %: %",
    .tcBonusHeader:       "Bonuspunkte: %",
    .tcWordsToCollect:    "Zu sammelnde Wörter: (% / % / % / %)",
    .tcOwnWords:          "Eigene Wörter (% / % / %)",
    .tcGameFinished1:     "Möchtest Du wirklich ein neues Spiel starten?",
    .tcGameFinished2:     "Du kannst jederzeit mit den Tasten \">\", \"<\" zwischen den gestarteten Spielen wechseln!",
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
    .tcNextRound:           "Neue Runde",
//    .tcNoMoreStepsAnswer3: "Eigene Wörter markieren",
    .tcAlphabet:           "ABCDEFGHIJKLMNOPQRSTUVWXYZÄÖÜß",
//    .tcFrequency:           "A°6/B°2/C°3/D°2/E°15/F°2/G°4/H°4/I°6/J°0/K°3/L°4/M°2/N°9/O°3/P°2/Q°0/R°8/S°8/T°7/U°4/V°1/W°1/X°0/Y°0/Z°1/Ä°1/Ö°0/Ü°1/ẞ°0",
    .tcNickNameLetters:    "ABCDEFGHIJKLMNOPQRSTUVWXYZ",
    .tcOK:                  "OK",
    .tcReady:               "Fertig",
    .tcChooseLanguage:      "Sprache wählen",
    .tcWord:                "Wort:",
    .tcCount:               "Cnt:",
    .tcLength:              "Len:",
    .tcMinutes:             "Min:",
    .tcShowAllWords:        "Meine Wörter",//"Zeige alle Wörter",
    .tcWordsOverLetter:   "Wörter über den Buchstaben: \"%\"",
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
    .tcTableOfEasyBestscores:"Ergebnisse von Sammle-Wörter",
    .tcTableOfMediumBestscores:"Ergebnisse von Verwende-Feste-Buchstaben",
    .tcTableOfWordCounts:    "Wort Zählers",
    .tcGamesToContinue:     "Wähle ein Spiel um fortzufahren",
    .tcPlayerHeader:        "Spieler",
    .tcMyHeader:            "Mein Ergebnis",
    .tcActDifficulty:       "Schwierigkeit: %",
    .tcGameIsFinished:      "Das Spiel % ist bereits beendet!",
    .tcRestartGameQuestion: "Du kannst das Spiel fortsetzen (%) oder neu starten! Beim Neustart werden die Ergebnisse gelöscht!",
    .tcRestartGame:         "Neu starten",
    .tcContinueGame:        "Fortsetzen",
    .tcShowWordlistHeader:  " Liste der gefundenen Wörter (%)",
    .tcSearchingWord:       " Suchwort: %",
    .tcCollectMandatory:    "Pflichtwörter suchen",
    .tcCreateMandatory:     "Pflichtwörter erstellen",
    .tcChangeWord:          " ändern",
    .tcCongratulationsAllWords: "Herzliche Glückwünsche! Du hast die Aufgabe erledigt, Du hast % verschiedene Wörter gesammelt! Du hast % Punkte erzielt und den %-ten Platz belegt!",
//    .tcCongratulationsMessage: "Du kannst das Spiel fortsetzen mit einem neuen Ziel oder ein neues Spiel beginnen!",
    .tcCongratulationsMessageEasy: "Du kannst das Spiel fortsetzen mit einem neuen Ziel (% Wörter sammeln) oder ein neues Spiel starten",
    .tcCongratulationsMessageMedium: "Du kannst das Spiel fortsetzen mit einem neuen Ziel (% feste Buchstaben verwenden) oder ein neues Spiel starten",
    .tcCongratulationsAllLetters: "Herzliche Glückwünsche! Du hast die Aufgabe erledigt, Du hast % feste Buchstaben verwendet!  Du hast % Punkte erzielt und den %-ten Platz belegt!",
    .tcCongratulations1:    "Herzlichen Glückwunsch!  Du hast alle Feste Buchstaben verwendet!",
    .tcCongratulationsEasy1:"Herzliche Glückwunsch!",
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
//    .tcChooseStyle:        "Wähle einen Stil für das Spiel",
//    .tcSimpleStyle:        "Einfach",
//    .tcEliteStyle:         "Elite",
    .tcGenerateBestScore:  "BestScore-Liste generieren",
    .tcDevice:             "Gerät",
    .tcLand:               " Land",
    .tcUseCloudGameData:   "Spiel aus der Cloud",
    .tcChooseGameToGet:    "Wähle einen Spiel für einlesen vom Cloud",
    .tcGameLine:           "Notifier: %, GameNumber: %",
    .tcWelcomeText1:        "Herzlich Willkommen/in der wunderbaren/Welt von Wörter!",
    .tcWelcomeText2:        "Viel Spaß!",
    .tcWelcomeText3:        "Und jetzt wollen wir/sehen, wie man ein/Sammle-Wörter/oder/Verwende-Feste-Buchstaben/Spiel spielt",
    .tcLater:               "Später",
    .tcShowEasyGame:        "Sammle-Wörter",
    .tcShowMediumGame:      "Verwende-Feste-Buchstaben",
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
    .tcAreYouSureForNewDemo: "Möchtest Du wirklich eine neue Demo erstellen??",
    .tcAreYouSureMessage:   "Die alte Demo-Informationen werden gelöscht!",
    .tcVersion:             "Version",
    .tcActVersion:          "©MagicOfWords V%",
    .tcAskForGameCenter: "Du kannst eine Verbindung\r\n" +
                        "zum Game Center herstellen um zu sehen, \r\n" +
                        "welche Ergebnisse andere Spieler haben.",
    .tcAskLater:        "Frag mich später",
    .tcAskNoMore:       "Frag mich nie mehr",
    .tcConnectGC:       "Verbinden mit Gamecenter",
//    .tcDisconnectGC:    "Verbindung zum Game Center trennen",
    .tcNobody:          "Unbekannt",
    .tcEasyScore:       "Sammle",
    .tcMediumScore:     "Verwende",
    .tcShowGameCenter:  "Zeige Game Center",
    .tcEasyActScore:    "SammleAct",
    .tcMediumActScore:  "VerwendeAct",
    .tcCountPlays:      "Gespielt",
    .tcBlank:           " ",
    .tcStartGame:       "Spielen",
    .tcWordCount:       "Wortzähler",
    .tcLocalPlayerNotAuth: "Verbindung fehlgeschlagen!",
    .tcChooseWhatYouWant: "Wähle, was angezeigt werden soll",
    .tcChooseTimeScope: "Wähle den Zeitraum",
    .tcAll:             "Alle",
    .tcWeek:            "Woche",
    .tcToday:           "Heute",
    .tcCounters:        "Zähler",
    .tcChooseGoalForWords:"Wähle aus, wie viele Wörter Du sammeln möchtest",
    .tcChooseGoalForLetters: "Wähle aus, wie viele feste Buchstaben Du verwenden möchtest",
    .tcGoalMessageForWords: "Das Spiel endet, wenn Du die ausgewählte Anzahl verschiedener Wörter gesammelt hast",
    .tcGoalMessageForLetters: "Das Spiel endet, wenn Du die ausgewählte Anzahl fester Buchstaben verwendet hast",
    .tcTipp:            "Hinweis: %",
    .tcShouldReport:    "Möchtest Du dem Entwickler das Wort \"%\" mitteilen?",
    .tcReportDescription: "Wenn es wirklich ein existierendes Wort ist, erhaltest Du % Bonuspunkte!",
    .tcYes:             "Ja",
    .tcShowWordReports: "Zeige neue Wörter in der Cloud",
    .tcNoNewWords:      "Es sind keine Wörter zu verarbeiten",
    .tcStatus:          "Status",
]



