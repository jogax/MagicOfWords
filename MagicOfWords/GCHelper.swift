//
//  GCHelper.swift
//  MagicOfWords
//
//  Created by Jozsef Romhanyi on 19/07/2019.
//  Copyright © 2019 Jozsef Romhanyi. All rights reserved.
//

// GCHelper.swift (v. 0.5.1)
//
// Copyright (c) 2017 Jack Cook
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
import GameKit
import RealmSwift

/// Custom delegate used to provide information to the application implementing GCHelper.
public protocol GCHelperDelegate: class {
    
    /// Method called when a match has been initiated.
    func matchStarted()
    
    /// Method called when the device received data about the match from another device in the match.
    func match(_ match: GKMatch, didReceive didReceiveData: Data, fromPlayer: String)
    
    /// Method called when the match has ended.
    func matchEnded(error: String)
    func localPlayerAuthenticated()
    func localPlayerNotAuthenticated()
    func continueTimeCount()
    func firstPlaceFounded()
    func myPlaceFounded()
}

/// A GCHelper instance represents a wrapper around a GameKit match.
public class GCHelper: NSObject, GKMatchmakerViewControllerDelegate, GKGameCenterControllerDelegate, GKMatchDelegate, GKLocalPlayerListener, GKInviteEventListener {
    
    /// An array of retrieved achievements. `loadAllAchievements(completion:)` must be called in advance.
    public var achievements = [String: GKAchievement]()
    
    /// The match object provided by GameKit.
    public var match: GKMatch!
    public enum AuthenticatingStatus: Int {
        case notAuthenticated = 0, authenticatingInProgress, authenticated
    }
    public var authenticateStatus: AuthenticatingStatus = .notAuthenticated
    
    fileprivate weak var delegate: GCHelperDelegate?
    fileprivate var invite: GKInvite!
    fileprivate var invitedPlayer: GKPlayer!
    fileprivate var playersDict = [String: GKPlayer]()
    fileprivate var allPlayers = [String:GKPlayer]()
    fileprivate weak var presentingViewController: UIViewController!
    
    
    fileprivate var authenticated = false {
        didSet {
            //            print("Authentication changed: player\(authenticated ? " " : " not ")authenticated")
        }
    }
    
    fileprivate var matchStarted = false
    
    /// The shared instance of GCHelper, allowing you to access the same instance across all uses of the library.
    public class var shared: GCHelper {
        struct Static {
            static let instance = GCHelper()
        }
        return Static.instance
    }
    
    override init() {
        super.init()
        
        NotificationCenter.default.addObserver(self, selector: #selector(GCHelper.authenticationChanged), name: Notification.Name.GKPlayerAuthenticationDidChangeNotificationName, object: nil)
    }
    
    // MARK: Private functions
    
    @objc fileprivate func authenticationChanged() {
        if GKLocalPlayer.local.isAuthenticated && !authenticated {
            authenticated = true
        } else {
            authenticated = false
        }
    }
    
    fileprivate func lookupPlayers() {
        print ("\(match.players.count)")
        let playerIDs = match.players.map { $0.playerID }
        
        GKPlayer.loadPlayers(forIdentifiers: playerIDs) { (players, error) in
            guard error == nil else {
                print("Error retrieving player info: \(String(describing: error?.localizedDescription))")
                self.matchStarted = false
                let errorText = String(describing: error?.localizedDescription)
                self.delegate?.matchEnded(error: errorText)
                return
            }
            
            guard let players = players else {
                print("Error retrieving players; returned nil")
                return
            }
            
            for player in players {
                print("Found player: \(String(describing: player.alias))")
                self.playersDict[player.playerID] = player
            }
            
            self.matchStarted = true
            GKMatchmaker.shared().finishMatchmaking(for: self.match)
            self.delegate?.matchStarted()
        }
    }
    
    
    
    // MARK: User functions
    
    var globalInfosTimer: Timer?
    
    /// Authenticates the user with their Game Center account if possible
    public func authenticateLocalUser(theDelegate: GCHelperDelegate, presentingViewController: UIViewController) {
        delegate = theDelegate
        let viewController = presentingViewController

        authenticateStatus = .authenticatingInProgress
        func authAdmin() {
            self.authenticateStatus = .authenticated
            self.authenticated = true
            //                self.getAllPlayers()
//            self.startGameCenterSync()
            GKLocalPlayer.local.unregisterAllListeners()
            GKLocalPlayer.local.register(self)
            globalInfosTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(sendGlobalInfosTOGC(timerX: )), userInfo: nil, repeats: false)

            self.delegate?.localPlayerAuthenticated()
        }
        if GKLocalPlayer.local.isAuthenticated == false {
            GKLocalPlayer.local.authenticateHandler = { (gcAuthViewController, error) in
                guard error == nil else {
                    print("Authentication error: \(String(describing: error?.localizedDescription))")
                    self.delegate?.localPlayerNotAuthenticated()
                    return
                }
                if let gcAuthViewController = gcAuthViewController {
                    // Pause any activities that require user interaction, then present the
                    // gcAuthViewController to the player.
                    viewController.present(gcAuthViewController, animated:true, completion:nil)
                } else if GKLocalPlayer.local.isAuthenticated {
                    authAdmin()
                } else {
                    // Error
                }
            }
        } else {
            authAdmin()
        }
    }
    
    struct GCInfo {
        let identifier: String
        let value: Int
        init(identifier: String, value: Int, modifyValue: Int = GV.TimeModifier) {
            let adder = modifyValue * GV.getTimeIntervalSince20190101()
            self.identifier = identifier
            self.value = value + adder
        }
    }
    
    
    private func sendInfoToGC(infos: [GCInfo]) {
        var scoreArray = [GKScore]()
        for info in infos {
            let score = GKScore(leaderboardIdentifier: info.identifier, player: GKLocalPlayer.local)
            score.value = Int64(info.value)
            scoreArray.append(score)
        }
        GKScore.report(scoreArray) { (error) in
            if error != nil {
                print("Error by send score to GameCenter: \(error!.localizedDescription)")
            } else {
//                self.getGlobalInfos()
            }
        }
    }
    
    var leaderboardIdentifiers = [String]()
    var countFinished = 0
    
    @objc public func getAllGlobalInfos(completion: @escaping ()->()) {
        GV.globalInfoTable.removeAll()
        leaderboardIdentifiers = [playingTimeName, playingTimeTodayName, myDeviceName, myLandName, myVersionName, easyBestScoreName, mediumBestScoreName, easyActScoreName, mediumActScoreName, countPlaysName]
        countFinished = leaderboardIdentifiers.count
        func decreaseCountFinished() {
            self.countFinished -= 1
            if self.countFinished == 0 {
                print("at end!!!")
                completion()
            }
        }
        func loadScoresForLeaderboard(identifier: String, firstCall: Bool = true, rank1: Int = 1, rank2: Int = 100) {
            let leaderBoard = GKLeaderboard()
            leaderBoard.identifier = identifier
            leaderBoard.playerScope = .global
            leaderBoard.timeScope = .allTime
            leaderBoard.range = NSRange(location: rank1, length: rank2)
            leaderBoard.loadScores(completionHandler: {
                (scores, error) in
                if scores != nil {
                    for score in scores! {
                        let player = score.player.alias
                        let index = GV.globalInfoTable.firstIndex(where: {$0.alias == player})
                        let savedDate = GV.getDateFromInterval(interval: Int(score.value) / GV.TimeModifier)
                        let savedValue = Int(score.value) % GV.TimeModifier
                        var tableItem = PlayerData()
                        switch score.leaderboardIdentifier {
                        case self.playingTimeName:
                            let actTime = MyDate(date: Date())
                            let isOnline = actTime == savedDate

                            if index != nil {
                                GV.globalInfoTable[index!].allTime = savedValue
                                GV.globalInfoTable[index!].isOnline = isOnline
                            } else {
                                tableItem.allTime = savedValue
                                tableItem.isOnline = isOnline
                            }
                        case self.playingTimeTodayName:
                            let lastDay = savedDate.datum()
                            let lastTime = savedValue
                            if index != nil {
                                GV.globalInfoTable[index!].lastDay = lastDay
                                GV.globalInfoTable[index!].lastTime = lastTime
                            } else {
                                tableItem.lastDay = lastDay
                                tableItem.lastTime = lastTime
                           }
                        case self.myDeviceName:
                           let myDevice = UIDevice().convertIntToModelName(value: savedValue)
                           if index != nil {
                                GV.globalInfoTable[index!].device = myDevice
                           } else {
                                tableItem.device = myDevice
                           }
                        case self.myLandName:
                            let myLand = GV.convertIntToLocale(value: savedValue % 100000000)
                            if index != nil {
                                GV.globalInfoTable[index!].land = myLand
                            } else {
                                tableItem.land = myLand
                            }
                        case self.myVersionName:
                            let myVersion = String(Double(savedValue) / 100)
                            if index != nil {
                                GV.globalInfoTable[index!].version = myVersion
                            } else {
                                tableItem.version = myVersion
                            }
                        case self.easyBestScoreName:
                            if index != nil {
                                GV.globalInfoTable[index!].easyBestScore = String(score.value)
                            } else {
                                tableItem.easyBestScore = String(score.value)
                            }
                        case self.mediumBestScoreName:
                            if index != nil {
                                GV.globalInfoTable[index!].mediumBestScore = String(score.value)
                            } else {
                                tableItem.mediumBestScore = String(score.value)
                            }
                        case self.easyActScoreName:
                            if index != nil {
                                GV.globalInfoTable[index!].easyActScore = String(savedValue)
                            } else {
                                tableItem.easyActScore = String(savedValue)
                            }
                        case self.mediumActScoreName:
                            if index != nil {
                                GV.globalInfoTable[index!].mediumActScore = String(savedValue)
                            } else {
                                tableItem.mediumActScore = String(savedValue)
                            }
                        case self.countPlaysName:
                            if index != nil {
                                GV.globalInfoTable[index!].countPlays = String(savedValue)
                            } else {
                                tableItem.countPlays = String(savedValue)
                            }
                     default:
                            break
                        }
                        if index == nil {
                            tableItem.alias = player
                            GV.globalInfoTable.append(tableItem)
                        }
                    }
                    if scores!.count == rank2 {
                        loadScoresForLeaderboard(identifier: identifier, firstCall: false, rank1: rank1 + rank2, rank2: rank2)
                    } else {
                        decreaseCountFinished()
                    }
                } else {
                    decreaseCountFinished()
                }
            })
            }
        for identifier in leaderboardIdentifiers {
            loadScoresForLeaderboard(identifier: identifier)
        }
    }
    
//    private func getGlobalInfos () {
//        let leaderBoard = GKLeaderboard()
//        leaderBoard.identifier = playingTimeName
//        leaderBoard.playerScope = .global
//        leaderBoard.timeScope = .allTime
//        leaderBoard.range = NSRange(location: 1, length: 1)
//        leaderBoard.loadScores(completionHandler: {
//            (scores, error) in
//            if scores != nil {
//                if leaderBoard.localPlayerScore != nil {
//                    let usedTimeInGC = Int(leaderBoard.localPlayerScore!.value) % GV.TimeModifier
//                    if usedTimeInGC > GV.basicDataRecord.playingTime {
//                        try! realm.safeWrite() {
//                            GV.basicDataRecord.playingTime = usedTimeInGC
//                        }
//                    }
//                }
//            }
//        })
//        let leaderBoardforplayingTimeToday = GKLeaderboard()
//        leaderBoardforplayingTimeToday.identifier = playingTimeTodayName
//        leaderBoardforplayingTimeToday.playerScope = .global
//        leaderBoardforplayingTimeToday.timeScope = .allTime
//        leaderBoardforplayingTimeToday.range = NSRange(location: 1, length: 1)
//        leaderBoardforplayingTimeToday.loadScores(completionHandler: {
//            (scores, error) in
//            if scores != nil {
//                if leaderBoardforplayingTimeToday.localPlayerScore != nil {
//                    let playingTimeTodayInGC = Int(leaderBoardforplayingTimeToday.localPlayerScore!.value) % GV.TimeModifier
//                    if playingTimeTodayInGC > GV.basicDataRecord.playingTimeToday {
//                        try! realm.safeWrite() {
//                            GV.basicDataRecord.playingTimeToday = playingTimeTodayInGC
//                        }
//                    }
//                }
//            }
//        })
//    }
    
    public func restartGlobalInfosTimer() {
        if globalInfosTimer != nil {
            globalInfosTimer!.invalidate()
        }
        globalInfosTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(sendGlobalInfosTOGC(timerX: )), userInfo: nil, repeats: false)
    }
    public func sendScoreToGameCenter(score: Int?, difficulty: Int, completion: @escaping ()->()) {
        // Submit score to GC leaderboard
        if score == nil {
            return
        }
        var infoArray = [GCInfo]()
        if GKLocalPlayer.local.isAuthenticated {
            let bestIdentifier = difficulty == GameDifficulty.Easy.rawValue ? easyBestScoreName : mediumBestScoreName
            let actIdentifier = difficulty == GameDifficulty.Easy.rawValue ? easyActScoreName : mediumActScoreName
            infoArray.append(GCInfo(identifier: bestIdentifier, value: score!, modifyValue: 0))
            infoArray.append(GCInfo(identifier: actIdentifier, value: score!))
            if score! != 0 {
                let countPlaysIdentifier = countPlaysName
                infoArray.append(GCInfo(identifier: countPlaysIdentifier, value: GV.basicDataRecord.countPlays))
            }
            sendInfoToGC(infos: infoArray)
        }
    }

    @objc private func sendGlobalInfosTOGC(timerX: Timer) {
        var infoArray = [GCInfo]()
        print("sendGlobalInfosTOGC actTime: \(Date())")
        if GKLocalPlayer.local.isAuthenticated {
            infoArray.append(GCInfo(identifier: playingTimeName, value: GV.basicDataRecord.playingTime))
            infoArray.append(GCInfo(identifier: playingTimeTodayName, value: GV.basicDataRecord.playingTimeToday))
            if !GV.basicDataRecord.deviceInfoSaved {
                infoArray.append(GCInfo(identifier: myLandName, value: GV.basicDataRecord.land))
                infoArray.append(GCInfo(identifier: myDeviceName, value: GV.basicDataRecord.deviceType))
                try! realm.safeWrite() {
                    GV.basicDataRecord.deviceInfoSaved = true
                }
            }
            if GV.basicDataRecord.version != Int(Double(actVersion)! * 100.0) {
                try! realm.safeWrite() {
                    GV.basicDataRecord.version = Int(Double(actVersion)! * 100.0)
                    infoArray.append(GCInfo(identifier: myVersionName, value: GV.basicDataRecord.version))
                }
            }
            sendInfoToGC(infos: infoArray)
        }
        // send infos to GC each 10 minutes
        globalInfosTimer = Timer.scheduledTimer(timeInterval: 600, target: self, selector: #selector(sendGlobalInfosTOGC(timerX: )), userInfo: nil, repeats: false)
    }
    
    /**
     Attempts to pair up the user with other users who are also looking for a match.
     
     :param: minPlayers The minimum number of players required to create a match.
     :param: maxPlayers The maximum number of players allowed to create a match.
     :param: viewController The view controller to present required GameKit view controllers from.
     :param: delegate The delegate receiving data from GCHelper.
     */
    public func findMatchWithMinPlayers(_ minPlayers: Int, maxPlayers: Int, viewController: UIViewController) {
        matchStarted = false
        match = nil
        presentingViewController = viewController
        //        delegate = theDelegate
        presentingViewController.dismiss(animated: false, completion: nil)
        
        let request = GKMatchRequest()
        request.minPlayers = minPlayers
        request.maxPlayers = maxPlayers
        
        let mmvc = GKMatchmakerViewController(matchRequest: request)!
        mmvc.matchmakerDelegate = self
        
        presentingViewController.present(mmvc, animated: true, completion: nil)
    }
    
    public func reportAchievementIdentifier(_ identifier: String, percent: Double, showsCompletionBanner banner: Bool = true) {
        let achievement = GKAchievement(identifier: identifier)
        
        if !achievementIsCompleted(identifier) {
            achievement.percentComplete = percent
            achievement.showsCompletionBanner = banner
            
            GKAchievement.report([achievement]) { (error) in
                guard error == nil else {
                    print("Error in reporting achievements: \(String(describing: error))")
                    return
                }
            }
        }
    }
    
    /**
     Loads all achievements into memory
     
     :param: completion An optional completion block that fires after all achievements have been retrieved
     */
    public func loadAllAchievements(_ completion: (() -> Void)? = nil) {
        GKAchievement.loadAchievements { (achievements, error) in
            guard error == nil, let achievements = achievements else {
                print("Error in loading achievements: \(String(describing: error))")
                return
            }
            
            for achievement in achievements {
                let id = achievement.identifier
                self.achievements[id] = achievement
            }
            
            completion?()
        }
    }
    
    /**
     Checks if an achievement in allPossibleAchievements is already 100% completed
     
     :param: identifier A string that matches the identifier string used to create an achievement in iTunes Connect.
     */
    public func achievementIsCompleted(_ identifier: String) -> Bool {
        if let achievement = achievements[identifier] {
            return achievement.percentComplete == 100
        }
        
        return false
    }
    
    /**
     Resets all achievements that have been reported to GameKit.
     */
    public func resetAllAchievements() {
        GKAchievement.resetAchievements { (error) in
            guard error == nil else {
                print("Error resetting achievements: \(String(describing: error))")
                return
            }
        }
    }
    
    /**
     Reports a high score eligible for placement on a leaderboard to GameKit.
     
     :param: identifier A string that matches the identifier string used to create a leaderboard in iTunes Connect.
     :param: score The score earned by the user.
     */
    public func reportLeaderboardIdentifier(_ identifier: String, score: Int) {
        let scoreObject = GKScore(leaderboardIdentifier: identifier)
        scoreObject.value = Int64(score)
        GKScore.report([scoreObject]) { (error) in
            guard error == nil else {
                print("Error in reporting leaderboard scores: \(String(describing: error))")
                return
            }
        }
    }
    
    /**
     Presents the game center view controller provided by GameKit.
     
     :param: viewController The view controller to present GameKit's view controller from.
     :param: viewState The state in which to present the new view controller.
     */
    public func showGameCenter(_ viewController: UIViewController, viewState: GKGameCenterViewControllerState) {
        presentingViewController = viewController
        
        let gcvc = GKGameCenterViewController()
        gcvc.viewState = viewState
        gcvc.gameCenterDelegate = self
        presentingViewController.present(gcvc, animated: true, completion: nil)
    }
    
    // MARK: GKGameCenterControllerDelegate
    
    public func gameCenterViewControllerDidFinish(_ gameCenterViewController: GKGameCenterViewController) {
        presentingViewController.dismiss(animated: true, completion: nil)
    }
    
    // MARK: GKMatchmakerViewControllerDelegate
    
    public func matchmakerViewControllerWasCancelled(_ viewController: GKMatchmakerViewController) {
        presentingViewController.dismiss(animated: true, completion: nil)
    }
    
    public func matchmakerViewController(_ viewController: GKMatchmakerViewController, didFailWithError error: Error) {
        presentingViewController.dismiss(animated: true, completion: nil)
        print("Error finding match: \(error.localizedDescription)")
    }
    
    public func matchmakerViewController(_ viewController: GKMatchmakerViewController, didFind theMatch: GKMatch) {
        presentingViewController.dismiss(animated: true, completion: nil)
        match = theMatch
        match.delegate = self
        if !matchStarted && match.expectedPlayerCount == 0 {
            print("Ready to start match!")
            self.lookupPlayers()
        }
    }
    
    // MARK: GKMatchDelegate
    
    public func match(_ theMatch: GKMatch, didReceive data: Data, fromPlayer playerID: String) {
        if match != theMatch {
            return
        }
        
        delegate?.match(theMatch, didReceive: data, fromPlayer: playerID)
    }
    
    
//    public func match(_ theMatch: GKMatch, player playerID: String, didChange state: GKPlayerConnectionState) {
//        if match != theMatch {
//            return
//        }
//
//        switch state {
//        case .connected where !matchStarted && theMatch.expectedPlayerCount == 0:
//            lookupPlayers()
//        case .disconnected:
//            matchStarted = false
//            guard let playerName = playersDict[playerID]?.alias else {
//                print("playerName is empty!")
//                break
//            }
//
//            delegate?.matchEnded(error: GV.language.getText(.tcMatchDisconnected, values: playerName))
//            match = nil
//        default:
//            break
//        }
//    }
//
//    public func match(_ theMatch: GKMatch, didFailWithError error: Error?) {
//        if match != theMatch {
//            return
//        }
//
//        print("Match failed with error: \(String(describing: error?.localizedDescription))")
//        matchStarted = false
//        let errorText = String(describing: error?.localizedDescription)
//        delegate?.matchEnded(error: errorText)
//    }
//
    // MARK: GKLocalPlayerListener
    
    public func player(_ player: GKPlayer, didAccept inviteToAccept: GKInvite) {
        let mmvc = GKMatchmakerViewController(invite: inviteToAccept)!
        mmvc.matchmakerDelegate = self
        presentingViewController.present(mmvc, animated: true, completion: nil)
    }
    
    
    var waitingForScores = false
    
    public func getScoresForShow(completion: @escaping ()->()) {
        if GKLocalPlayer.local.isAuthenticated {
            GV.scoreForShowTable.removeAll()
            let leaderBoard = GKLeaderboard()
            let leaderboardID = "\(GameDifficulty(rawValue: GV.basicDataRecord.difficulty)!.description().lowercased())BestScore"
            leaderBoard.identifier = leaderboardID
            leaderBoard.playerScope = .global
            leaderBoard.timeScope = .allTime
            leaderBoard.range =  NSRange(location: 1, length: 20)
            leaderBoard.loadScores(completionHandler: {
            (scores, error) in
                if scores != nil {
                    if leaderBoard.localPlayerScore != nil {
                        GV.myPlace = leaderBoard.localPlayerScore!.rank
                        GV.myScore = Int(leaderBoard.localPlayerScore!.value)
                    } else {
                        GV.myPlace = 0
                        GV.myScore = 0
                    }
                    if scores!.count > 0 {
                        for score in scores! {
                            let item = ScoreForShow(place: score.rank, player: score.player.alias, score: Int(score.value))
                            GV.scoreForShowTable.append(item)
                        }
                    }
                    completion()
                }
            })
        }
    }
    
    @objc public func getAllScores(rank1: Int = 1, length: Int = 100, inRecursion: Bool = false, completion: @escaping ()->()) {
        if GKLocalPlayer.local.isAuthenticated {
            if waitingForScores && !inRecursion {
                return
            }
            waitingForScores = true
            let leaderBoard = GKLeaderboard()
            let difficultyName = "\(GameDifficulty(rawValue: GV.basicDataRecord.difficulty)!.description().lowercased())BestScore"
            let leaderboardID = difficultyName
            if !inRecursion {
                GV.scoreTable.removeAll()
            }
            leaderBoard.identifier = leaderboardID
            leaderBoard.playerScope = .global
            leaderBoard.timeScope = .allTime
            leaderBoard.range =  NSRange(location: 1, length: length)
            leaderBoard.loadScores(completionHandler: {
                (scores, error) in
                if scores != nil {
                    if scores!.count > 0 {
                        for score in scores! {
                            GV.scoreTable.append(Int(score.value))
                        }
//                        if scores!.count == length {
//                            self.getAllScores(rank1: rank1 + 100, inRecursion: true, completion: completion)
//                        } else {
                            completion()
                            self.waitingForScores = false
//                        }
                    } else {
                        completion()
                        self.waitingForScores = false
                   }
                } else {
                    completion()
                    self.waitingForScores = false
                }
            })
        }
    }
    
    public func getBestScore(completion: @escaping ()->()) {
        let difficulty = GV.basicDataRecord.difficulty
        let leaderBoard = GKLeaderboard()
        let leaderboardID = difficulty == GameDifficulty.Easy.rawValue ? easyBestScoreName : mediumBestScoreName
        leaderBoard.identifier = leaderboardID
        leaderBoard.playerScope = .global
        leaderBoard.timeScope = .allTime
        leaderBoard.range = NSRange(location: 1, length: 1)
        leaderBoard.loadScores(completionHandler: {
            (scores, error) in
            if scores != nil {
                if scores!.count > 0 {
                    try! realm.safeWrite() {
                        GV.basicDataRecord.setBestScore(score: Int(scores![0].value), name: scores![0].player.alias, myRank: leaderBoard.localPlayerScore == nil ? 0 : leaderBoard.localPlayerScore!.rank)
                        completion()
                    }
                }
            }
        })
    }
//    var timer: Timer?
//    @objc private func waitForLocalPlayer() {
//        if GKLocalPlayer.local.isAuthenticated == false {
//            timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(waitForLocalPlayer), userInfo: nil, repeats: false)
//        } else {
////            syncWithGameCenter()
//        }
//    }
    
//    func startGameCenterSync() {
//        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(waitForLocalPlayer), userInfo: nil, repeats: false)
//    }
    
    
    public func getName() -> String {
        return GKLocalPlayer.local.alias
    }
    let easyBestScoreName = "easyBestScore"
    let mediumBestScoreName = "mediumBestScore"
    let easyActScoreName = "easyActScore"
    let mediumActScoreName = "mediumActScore"
    let countPlaysName = "countPlays"
    let playingTimeName = "playingTime"
    let playingTimeTodayName = "playingTimeToday"
    let myDeviceName = "myDevice"
    let myLandName = "myLandLanguage"
    let myVersionName = "myVersion"

}
