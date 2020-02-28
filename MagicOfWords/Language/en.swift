//
//  en.swift
//  Flowers
//
//  Created by Jozsef Romhanyi on 20.09.15.
//  Copyright © 2015 Jozsef Romhanyi. All rights reserved.
//


let enDictionary: [TextConstants: String] = [
    .tcAktLanguage:      "en",
    .tcLanguage:         "Language",
    .tcEnglish:          "English (English)",
    .tcGerman:           "Deutsch (German)",
    .tcHungarian:        "Magyar (Hungarian)",
    .tcRussian:          "Русский (Russian)",
    .tcEnglishShort:     "en",
    .tcGermanShort:      "de",
    .tcHungarianShort:   "hu",
    .tcRussianShort:     "ru",
    .tcEasyPlay:         "%Game Collect-Words",
    .tcMediumPlay:       "%Game Use-Fixed-Letters",
    .tcPlayer:           "Player",
    .tcNewGame:          "New game",
    .tcRestart:          "Restart",
//    .tcContinue:         "Continue %",
    .tcFinished:         "Finished games %",
    .tcSettings:         "Settings",
    .tcWordTris:         "Wordtris",
    .tcSearchWords:       "Find words",
    .tcCancel:            "Cancel",
    .tcLoadingInProgress: "Loading English Words in progress",
    .tcChooseGameType:    "Choose game type",
    .tcBack:              "Back",
    .tcHeader:            "Round: %, Time: %",
    .tcMe:                " (Me)",
    .tcScore:             "Score",
    .tcPlace:             "Place",
    .tcKeywordHeader:     "Keyword:",
    .tcMyWordsHeader1000: "-> Collected % from % words",
    .tcMyWordsHeader250:  "-> Collected %/% letters/words",
    .tcMyScoreHeader:     "-> %. Place (Me): % (%)", //\u{1F970}
    .tcBestScoreHeader:   "-> %. Place     : % (%)",
//    .tcActScoreHeader:    "Best plyaing: %: %",
    .tcBonusHeader:       "Bonus Points: %",
    .tcWordsToCollect:    "Words to collect: (% / % / % / %)",
    .tcOwnWords:          "My own words (% / % / %)",
    .tcGameFinished1:     "Do you really want to start a new game?",
    .tcGameFinished2:     "You can always flip between started games using the buttons \">\", \"<\"!",
    .tcBestScore:          "Best scores",
    .tcBestPlayer:         "Best player",
    .tcCollectedRequiredWords: "Mandatory words",
    .tcCollectedOwnWords:   "Own words",
    .tcTotal:               "Total:",
    .tcTaskNotCompletedWithNoMoreSteps: "No more steps, task not completed!",
    .tcTaskNotCompletedWithTimeOut: "Timeout, task not completed!",
    .tcWillBeRestarted:     "Game will be restarted!",
    .tcNoMoreStepsQuestion1: "No more steps!",
//    .tcNoMoreStepsQuestion2: "Would yue like to choose own words?",
//    .tcNoMoreStepsAnswer1: "Yes",
    .tcNextRound:           "Next round",
//    .tcNoMoreStepsAnswer3: "Choose own words",
    .tcAlphabet:           "ABCDEFGHIJKLMNOPQRSTUVWXYZ",
//    .tcFrequency:           "A°8/B°2/C°4/D°3/E°11/F°1/G°2/H°3/I°8/J°1/K°1/L°5/M°3/N°7/O°7/P°3/Q°0/R°7/S°10/T°7/U°3/V°1/W°1/X°0/Y°1/Z°0",
    .tcNickNameLetters:    "ABCDEFGHIJKLMNOPQRSTUVWXYZ",
    .tcOK:                  "OK",
    .tcReady:               "Done",
    .tcChooseLanguage:      "Choose language",
    .tcWord:                "Word:",
    .tcCount:               "Cnt:",
    .tcLength:              "Len:",
    .tcMinutes:             "Min:",
    .tcShowAllWords:        "My Words", //"Show all words",
    .tcWordsOverLetter:     "Words over the letter: \"%\"",
    .tcShowRealmCloud:      "Show Realm Cloud",
    .tcNickName:            "Nickname",
    .tcIsOnline:            "isOnline",
    .tcOnlineSince:         "Online_since",
    .tcOnlineTime:          "Online   ",
    .tcLastOnline:          "Last           ",
    .tcLastOnlineTime:      "Duration",
    .tcSetNickName:         "Choose a nickname",
    .tcSave:                "Save",
    .tcAddCodeRecommended:  "If you add a keyword, you can use the same nickname on all of your devices",
    .tcKeyWord:             "Add a keyword...",
    .tcNicknameUsed:        "Nickname '%' is used on another device!",
    .tcNicknameUsedwithout: "Nickname '%' is used on another device without keyword!",
    .tcNicknameActivating:  "If this is your device, open it and add a keyword to the nickname!",
    .tcAddKeyWord:          "If this is your device, add hier the same keyword otherwise choose another nickname!",
    .tcChooseAction:        "Choose please!",
    .tcTableOfEasyBestscores:"Scores of \"Collect-Words\"",
    .tcTableOfMediumBestscores:"Scores of \"Use-Fixed-Letters\"",
    .tcTableOfWordCounts:    "Word counters",
    .tcGamesToContinue:     "Choose game to continue",
    .tcPlayerHeader:        "Player",
    .tcMyHeader:            "My Score",
    .tcActDifficulty:       "Difficulty:%",
    .tcGameIsFinished:      "The game % is already finished!",
    .tcRestartGameQuestion: "You can continue or restart the game! If restart, the score will be deleted!",
    .tcRestartGame:         "Restart",
    .tcContinueGame:        "Continue",
    .tcShowWordlistHeader:  " List of found words (%)",
    .tcSearchingWord:       " Searching word: %",
    .tcCollectMandatory:    "Search mandatory words",
    .tcCreateMandatory:     "Create mandatory words",
    .tcChangeWord:          " change",
    .tcCongratulationsAllWords: "Congratulations! You have completed the task, you have collected a total of % different words! You earned % points and took % place!",
    .tcCongratulationsMessageEasy: "You can continue the game by setting a new goal (Collect % words) or start a new game",
    .tcCongratulationsMessageMedium: "You can continue the game by setting a new goal (Use % fixed letters) or start a new game",
    .tcCongratulationsAllLetters: "Congratulations! You have completed the task, you have used % fixed letters! You earned % points and took % place!",
    .tcCongratulationsEasy1:"Congratulations!",
    .tcCongratulations2:    "You can finish the game (press the <Finish> button) or continue playing to earn more points (press the <Continue> button)!",
    .tcContinuePlaying:     "Continue",
    .tcFinishGame:          "Finish",
    .tcChoosedWord:         " Added",
    .tcCountLetters:        "Search mandatory words with % letters",
    .tcAllWords:            "%/% Words, choosed: %/%",
    .tcIWillAdd:           " I will add",
    .tcIWillDelete:        " I will delete",
    .tcIWillSeparate:      " I will separate",
    .tcMyCounts:           "I have added: %, separated: %, deleted: % words",
//    .tcChooseStyle:        "Choose a style for game",
//    .tcSimpleStyle:        "Simple",
//    .tcEliteStyle:         "Elite",
    .tcGenerateBestScore:  "Generate BestScore List",
    .tcDevice:             "Device",
    .tcLand:               " Land",
    .tcUseCloudGameData:   "Get Game from Cloud",
    .tcChooseGameToGet:    "Choose a Game to get from Cloud",
    .tcGameLine:           "Notifier: %, GameNumber: %",
//    .tcWelcomeText1:        "Welcome to the wonderful/world of Words!",
//    .tcWelcomeText2:        "Have a nice time!",
//    .tcWelcomeText3:        "And now let's see/how to play a/Collect-Words/or/Use-Fixed-Letters/game",
//    .tcLater:               "Later",
//    .tcShowEasyGame:        "Collect-Words",
//    .tcShowMediumGame:      "Use-Fixed-Letters",
//    .tcHelpGenNew:          "Create Demo",
//    .tcHelpGenContinue:     "Continue Demo",
    .tcDeveloperMenu:       "Developers menu",
//    .tcShowHelp:            "Show Demo Game",
//    .tcDemoFinishedTitle:   "Demo is finished!",
//    .tcDemoFinishedMessage: "I hope it was helpful for you! If you want to see the demo again, yout can run it in <Menu - Settings - Show Demo Game>. And now you can continue with a new game or go to the menu",
//    .tcDemoFinishedStartNewGame: "New game",
//    .tcDemoFinishedGoToMenu: "Go to menu",
//    .tcChooseDifficulty:    "Choose difficulty",
//    .tcCurrentDifficulty:   "Current difficulty: %",
//    .tcAreYouSureForNewDemo: "Are you sure to create a new Demo?",
    .tcAreYouSureMessage:   "The old demo info will be deleted!",
    .tcVersion:             "Version",
    .tcActVersion:          "©MagicOfWords V%",
    .tcAskForGameCenter: "You can connect to the Game Center \r\n" +
    "to see what scores other players have.",
    .tcAskLater:        "Ask me Later",
    .tcAskNoMore:       "Ask me no more",
    .tcConnectGC:       "Connect to Gamecenter",
//    .tcDisconnectGC:    "Disconnect from Gamecenter",
    .tcNobody:          "unknown",
    .tcEasyScore:       "Collect",
    .tcMediumScore:     "Use",
    .tcShowGameCenter:  "Show Game Center",
    .tcEasyActScore:    "CollectAct",
    .tcMediumActScore:  "UseAct",
    .tcCountPlays:      "Played",
    .tcBlank:           " ",
    .tcStartGame:       "Play",
    .tcWordCount:       "Word counters",
    .tcLocalPlayerNotAuth: "Local player not authenticated!",
    .tcChooseWhatYouWant: "Choose what to show",
    .tcChooseTimeScope: "Choose time scope",
    .tcAll:             "All",
    .tcWeek:            "Week",
    .tcToday:           "Today",
    .tcCounters:        "Counters",
    .tcChooseGoalForWords:"Choose how many words do you want to collect",
    .tcChooseGoalForLetters: "Choose how many fixed letters do you want to use",
    .tcGoalMessageForWords: "The game ends when you have collected the selected number of different words",
    .tcGoalMessageForLetters: "The game ends when you have used the selected number of fixed letters",
    .tcTipp:            "Hint: %",
    .tcShouldReport:    "Do you want to report the word \"%\" to the developer?",
    .tcReportDescription: "If it's really an existing word (singular noun), you'll get % bonus points every time you use it! Verification will take a few days and you will be notified when the word is accepted!",
    .tcYes:             "Yes",
    .tcShowWordReports: "Show new words in Cloud",
    .tcNoNewWords:      "There are no words to process",
    .tcStatus:          "Status",
    .tcDeniedReport:    "The word \"%\" you have reported to the developer does not exist!",
    .tcDeniedDescription: "Next time, make sure you only report missing singular nouns!",
    .tcAcceptedReport:    "Congratulations! The word \"%\" you have reported to the developer exists!",
    .tcAcceptedDescription: "You get % bonus points for each using!",
    .tcWordReportedTitle:    "The word has been sent to the developer!",
    .tcWordReportedMessage: "Please wait patiently for the answer!",
    .tcHintsWithRedLetters: "Some hints with red letters",
]
