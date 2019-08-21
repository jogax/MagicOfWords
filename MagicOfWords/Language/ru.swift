//
//  ru.swift
//  Flowers
//
//  Created by Jozsef Romhanyi on 20.09.15.
//  Copyright © 2015 Jozsef Romhanyi. All rights reserved.
//


let ruDictionary: [TextConstants: String] = [
    .tcAktLanguage:      "ru",
    .tcLanguage:         "Язык",
    .tcEnglish:          "English (Английский)",
    .tcGerman:           "Deutsch (Немецкий)",
    .tcHungarian:        "Magyar (Венгерский)",
    .tcRussian:          "Русский (Русский)",
    .tcEnglishShort:     "en",
    .tcGermanShort:      "de",
    .tcHungarianShort:   "hu",
    .tcRussianShort:     "ru",
    .tcEasyPlay:         "Простая игра",
    .tcMediumPlay:       "Средняя игра",
    .tcPlayer:           "Игрок",
    .tcNewGame:          "Новая игра",
    .tcRestart:          "Перезапуск",
//    .tcContinue:         "Продолжение %",
    .tcFinished:         "Законченные игры %",
    .tcSettings:         "Настройки",
    .tcWordTris:         "Словотрис",
    .tcSearchWords:       "Найти слова",
    .tcCancel:            "Отмена",
    .tcLoadingInProgress: "Выпольнется загрузка русских слов",
    .tcChooseGameType:    "Bыбрать тип игры",
    .tcBack:              "Назад",
    .tcHeader:            "Круг: %, Время: %",
    .tcMe:                " (Я)",
    .tcScore:             "Очки",
    .tcPlace:             "Место",
    .tcKeywordHeader:     "Ключ:",
    .tcMyScoreHeader:     "\u{1F970} %. Место (Я): % (%)",
    .tcBestScoreHeader:   "\u{1F970} %. Место    : % (%)",
//    .tcActScoreHeader:    "Сейчас играет: %: %",
    .tcBonusHeader:       "Бонусные очки: %",
    .tcWordsToCollect:    "Слова для сбора: (% / % / % / %)",
    .tcOwnWords:          "Мои слова (% / % / %)",
    .tcGameFinished1:     "Действительно хочешь начать новую игру?",
    .tcGameFinished2:     "Ты можешь листать между начатыми играми, используя \">\" и \"<\"!",
    .tcBestPlayer:        "Лучший игрок",
    .tcBestScore:         "Лучшие очки",
    .tcCollectedRequiredWords: "Обязательные слова",
    .tcCollectedOwnWords:      "Собственные слова",
    .tcTotal:               "Всего:",
    .tcTaskNotCompletedWithNoMoreSteps: "Больше нет шагов, задача не выполнена!",
    .tcTaskNotCompletedWithTimeOut: "Время истекло, задача не выполнена!",
    .tcWillBeRestarted:     "Игра будет перезапущена!",
    .tcNoMoreStepsQuestion1: "Больше никаких шагов!",
//    .tcNoMoreStepsQuestion2: "Хочешь указать собственные слова?",
//    .tcNoMoreStepsAnswer1: "Да",
    .tcNoMoreStepsAnswer2: "Следующий раунд",
    .tcNoMoreStepsAnswer3: "Указать собственные слова",
    .tcAlphabet:           "АБВГДЕЁЖЗИЙКЛМНОПРСТУФХЦЧШЩЫЬЭЮЯ", /// Ъ!
//    .tcFrequency:           "А°10/Б°2/В°3/Г°2/Д°3/Е°8/Ё°1/Ж°1/З°2/И°9/Й°1/К°5/Л°4/М°3/Н°7/О°10/П°3/Р°7/С°5/Т°7/У°2/Ф°1/Х°1/Ц°1/Ч°1/Ш°1/Щ°1/Ы°1/Ь°2/Э°1/Ю°0/Я°1",
    .tcNickNameLetters:    "АБВГДЕЖЗИКЛМНОПРСТУФХЦЧШЭ",
    .tcOK:                  "OK",
    .tcReady:               "Готово",
    .tcChooseLanguage:      "Выбери язык",
    .tcWord:                "Слово",
    .tcCount:               "Штк.",
    .tcLength:              "Дл.",
    .tcMinutes:             "Мин.",
    .tcShowAllWords:        "Мои слова",//"Покажи все слова",
    .tcWordsOverLetter:     "Слова над буквой",
    .tcShowRealmCloud:      "Покажи Realm Cloud",
    .tcNickName:            "Псевдоним",
    .tcIsOnline:            "В_сети",
    .tcOnlineSince:         "В_сети_с",
    .tcOnlineTime:          "   В сети  ",
    .tcLastOnline:          "Играл",
    .tcLastOnlineTime:      "Время",
    .tcSetNickName:         "Выбери псевдоним",
    .tcSave:                "Сохранить",
    .tcAddCodeRecommended:  "Если ты добавишь ключевое слово, ты можешь использовать один и тот же псевдоним на всех твоих устройствах",
    .tcKeyWord:             "Добавить ключевое слово ...",
    .tcNicknameUsed:        "Псевдоним '%' используется на другом устройстве!",
    .tcNicknameUsedwithout: "Псевдоним '%' используется на другом устройстве без ключевого слова!",
    .tcNicknameActivating:  "Если это твоё устройство, открой его и добавь ключевое слово к псевдониму!",
    .tcAddKeyWord:          "Если это твоё устройство, добавь тут то же ключевое слово, иначе выбери другой псевдоним!",
    .tcChooseAction:        "Выбери пожалуйста!",
    .tcTableOfBestscores:   "Таблица лучших результатов",
    .tcGamesToContinue:     "Выбери игру для продолжения",
    .tcPlayerHeader:        "Игрок",
    .tcMyHeader:            "Мои очки",
    .tcActDifficulty:       "Текущая сложность: %",
    .tcGameIsFinished:      "Игра % уже закончена!",
    .tcRestartGameQuestion: "Ты можешь продолжить или перезапустить игру! Если перезапустить, очки будут удалены!",
    .tcRestartGame:         "Перезапуск",
    .tcContinueGame:        "Продолжение",
    .tcShowWordlistHeader:  " Список найденных слов (%)",
    .tcSearchingWord:       " Поисковое слово: %",
    .tcCollectMandatory:    "Поиск обязательных слов",
    .tcCreateMandatory:     "Создание обязательных слов",
    .tcChangeWord:          " сменить",
//    .tcCongratulationsFix1:    "Поздравляю! Ты использовал все фиксированные буквы! Но ты должен ещё собрать обязательные слова!",
//    .tcCongratulationsFix2:     "Собери оставшиеся обязательные слова!",
//    .tcCongratulationsMandatory1:    "Поздравляю! Ты собрал все обязательные слова! Но ты должен ещё использовать все фиксированные буквы!",
//    .tcCongratulationsMandatory2:     "Используй все фиксированные буквы!",
    .tcCongratulations1:    "Поздравляю! Ты использовал все фиксированные буквы!",
    .tcCongratulationsEasy1:"Поздравляю!",
    .tcCongratulations2:    "Ты можешь закончить игру (нажми кнопку <Закончить>) или продолжать играть, чтобы заработать больше очков (нажми кнопку <Продолжать>)!",
    .tcContinuePlaying:     "Продолжать",
    .tcFinishGame:          "Закончить",
    .tcChoosedWord:         " Добавлено",
    .tcCountLetters:        "Поиск обязательных слов из % букв",
    .tcAllWords:            "%/% Слов, выбрано: %/%",
    .tcIWillAdd:            " Я добавлю",
    .tcIWillDelete:         " Я удаляю",
    .tcIWillSeparate:       " Я отделяю",
    .tcMyCounts:           "Я добавил:%, отделил:%, удалил:% слов",
//    .tcChooseStyle:        "Выбери стиль для игры",
//    .tcSimpleStyle:        "Простой",
//    .tcEliteStyle:         "Изящный",
    .tcGenerateBestScore:  "Создать список лучших результатов",
    .tcDevice:             "Устройство",
    .tcLand:               " Страна",
    .tcUseCloudGameData:   "Получить игру из облака",
    .tcChooseGameToGet:    "Выбери игру, чтобы получить из облака",
    .tcGameLine:           "Уведомитель: %, Игра: %",
    .tcWelcomeText1:        "Добро пожаловать/в чудесный мир слов!",
    .tcWelcomeText2:        "Желаю приятно/провести время!",
    .tcWelcomeText3:        "А теперь давай/посмотрим, как играть/простую или/средней сложности игру",
    .tcLater:               "Позже",
    .tcShowEasyGame:        "Простая",
    .tcShowMediumGame:      "Средней сложности",
    .tcHelpGenNew:          "Создать демо",
    .tcHelpGenContinue:     "Продолжать демо",
    .tcDeveloperMenu:       "Меню разработчика",
    .tcShowHelp:            "Показать демо-игру",
    .tcDemoFinishedTitle:   "Демо закончено!",
    .tcDemoFinishedMessage: "Я надеюсь, что это было полезно для тебя! Если ты хочешь снова посмотреть демо, ты можешь запустить его в <Меню - Настройки - Показать демо-игру>. И теперь ты можешь начинать новую игру или перейти в меню",
    .tcDemoFinishedStartNewGame: "Новая игра",
    .tcDemoFinishedGoToMenu: "Перейти в меню",
    .tcChooseDifficulty:    "Выбери сложность",
    .tcCurrentDifficulty:   "Текущая сложность: %",
    .tcSimpleGame:          "Простая",
    .tcMediumGame:          "Средняя",
    .tcHardGame:            "Сложная",
    .tcVeryHardGame:        "Очень сложная",
    .tcAreYouSureForNewDemo: "Действительно хочешь создать новую демоверсию?",
    .tcAreYouSureMessage:   "Старая демо-информация будет удалена!",
    .tcVersion:             "Версия",
    .tcActVersion:          "©MagicOfWords V%",
    .tcAskForGameCenter: "Ты можешь подключиться к Игровому центру,\r\n" +
                            "чтобы узнать, сколько очков у других игроков.",
    .tcAskLater:        "Спроси меня позже",
    .tcAskNoMore:       "Не спрашивай меня больше",
    .tcConnectGC:       "Подключ. к Игровому центру",
//    .tcDisconnectGC:    "Отключиться от Игрового Центра",
    .tcNobody:          "Неизвестный",
    .tcEasyScore:       "Простая",
    .tcMediumScore:     "Средняя",
    .tcShowGameCenter:  "Покажи Game Center",
    .tcEasyActScore:    "АктПростая",
    .tcMediumActScore:  "АктСредняя",
    .tcCountPlays:      "Игры",
    .tcBlank:           " ",
    .tcStartGame:       "Играть",
]

