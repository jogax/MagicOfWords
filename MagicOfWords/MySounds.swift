//
//  MySounds.swift
//  MagicOfWords
//
//  Created by Romhanyi Jozsef on 2020. 09. 15..
//  Copyright © 2020. Jozsef Romhanyi. All rights reserved.
//


import AVFoundation

enum Sounds: Int {
    case NoSuchWord = 0, OKWord, WordFoundedSoon
}



//class MySounds {
//    var players = [Sounds:AVAudioPlayer]()
//    var noSuchWordSound: AVAudioPlayer?
//    var wordOKSound: AVAudioPlayer?
//    let noSuchWordString = "NoSuchWord"
//    let OKWordString = "OKWord"
//    init() {
//        players[.NoSuchWord]    = makeAudioPlayer(noSuchWordString, volume: 10)
//        players[.OKWord]        = makeAudioPlayer(OKWordString, volume: 0.9)
//    }
//    private func makeAudioPlayer(_ soundToPlay: String, type: String = "mp3", volume: Float)->AVAudioPlayer {
//        var audioPlayer = AVAudioPlayer()
//        let sound = Bundle.main.path(forResource: soundToPlay, ofType: type)
//        audioPlayer = try! AVAudioPlayer(contentsOf: URL(fileURLWithPath: sound!))
//        audioPlayer.volume = volume
//        return audioPlayer
//    }
//    public func play(_ sound: Sounds) {
//        players[sound]!.play()
//    }
//}
