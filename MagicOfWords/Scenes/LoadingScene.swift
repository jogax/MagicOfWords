//
//  LoadingScene.swift
//  MagicOfWords
//
//  Created by Jozsef Romhanyi on 08/02/2018.
//  Copyright © 2018 Jozsef Romhanyi. All rights reserved.
//

import Foundation
import GameKit
import RealmSwift

public protocol LoadingSceneDelegate: class {
    
    /// Method called when initialization finished
    func loadingFinished()
}
class LoadingScene: SKScene {
    var minX: CGFloat = 0
    var minY: CGFloat = 0
    var maxX: CGFloat = 0
    var maxY: CGFloat = 0
    var procentLabel: SKLabelNode?
    var labelZPosition = -1
    var upper = true
    

    var loadingSceneDelegate: LoadingSceneDelegate?
    override func didMove(to view: SKView) {
        minX = self.frame.size.width * 0.20
        minY = self.frame.size.height * 0.10
        maxX = self.frame.size.width * 0.80
        maxY = self.frame.size.height * 0.15
        self.backgroundColor = SKColor(red: 255/255, green: 220/255, blue: 208/255, alpha: 1)
        createLoadingProcessShape()
        createLabels()
        
        _ = GenerateGameData(parentScene: self)
    }
    
    func createLabels() {
        let loadingLabel = SKLabelNode(fontNamed: "Noteworthy")
        loadingLabel.fontSize = self.frame.size.height / 40
        loadingLabel.position = CGPoint(x: self.frame.size.width / 2, y: minY * 0.5)
        loadingLabel.fontColor = SKColor.blue
        loadingLabel.text = GV.language.getText(.tcLoadingInProgress)
        self.addChild(loadingLabel)
        procentLabel = SKLabelNode(fontNamed: "Noteworthy")
        procentLabel!.fontColor = SKColor.blue
        procentLabel!.fontSize = self.frame.size.height / 50
        procentLabel!.position = CGPoint(x: self.frame.size.width * 0.90, y: minY)
        procentLabel!.text = "0 %"
        self.addChild(procentLabel!)
        
    }
    public func createLoadingProcessShape() {
        var points = [CGPoint(x: minX, y: minY),
                      CGPoint(x: maxX, y: minY),
                      CGPoint(x: maxX, y: maxY),
                      CGPoint(x: minX, y: maxY),
                      CGPoint(x: minX, y: minY)]
        let groundShapeNode = SKShapeNode(points: &points,
                                          count: points.count)
        groundShapeNode.strokeColor = SKColor.white
        groundShapeNode.fillColor = SKColor.white
        groundShapeNode.name = "groundShapeNode"
        groundShapeNode.zPosition = 0
        self.addChild(groundShapeNode)
        
    }
    public func setDelegate(delegate: LoadingSceneDelegate) {
        loadingSceneDelegate = delegate
    }
    
//    public func startShowProgress() {
//        timer = Timer.scheduledTimer(timeInterval: 0.001, target: self, selector: #selector(showProgress(timerX:)), userInfo: nil, repeats: true)
//    }
    
    func showProgress() {
        let progressShapeNodeName = "progressShapeNode"
        if self.childNode(withName: progressShapeNodeName) != nil {
            self.childNode(withName: progressShapeNodeName)!.removeFromParent()
        }
        if GV.maxRecordCount > 0 {
            let procent = CGFloat(GV.actRecordCount) / CGFloat(GV.maxRecordCount)
            let calculatedMaxX = minX + (maxX - minX) * procent
            var points = [CGPoint(x: minX, y: minY),
                          CGPoint(x: calculatedMaxX, y: minY),
                          CGPoint(x: calculatedMaxX, y: maxY),
                          CGPoint(x: minX, y: maxY),
                          CGPoint(x: minX, y: minY)]

            let progressShapeNode = SKShapeNode(points: &points,
                                                count: points.count)
            progressShapeNode.fillColor = SKColor.green
            progressShapeNode.strokeColor = SKColor.green
            progressShapeNode.name = progressShapeNodeName
            progressShapeNode.zPosition = 10
            
            self.addChild(progressShapeNode)
            
            let wordLabel = SKLabelNode(fontNamed: "Noteworthy")
            wordLabel.zPosition = CGFloat(labelZPosition)
            let colors: [SKColor] = [.blue, .red, .green, .gray, .brown, .black, .magenta]
            labelZPosition -= 1
            let xProcent = CGFloat.random(min: 0.20, max: 0.80)
            let yProcent = CGFloat.random(min: 0.20, max: 0.90)
            let color = colors[Int.random(min:0, max: colors.count - 1)]
            wordLabel.fontColor = color
            wordLabel.fontSize = CGFloat.random(min: self.frame.size.height * 0.020, max: self.frame.size.height * 0.04)
            wordLabel.position = CGPoint(x: self.frame.size.width * xProcent, y: self.frame.size.height * yProcent)
            wordLabel.text = GV.lastSavedWord
            let actionFadeAlpha = SKAction.fadeAlpha(to: 0, duration: 1)
            wordLabel.run(actionFadeAlpha)
            self.addChild(wordLabel)
            self.procentLabel!.text = String(describing: Int(procent * 100)) + " %"
            // stop if all records done
            if GV.EndOfFileReached {
                loadingSceneDelegate!.loadingFinished()
            }
            
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        showProgress()
    }
    deinit {
        print("\n THE SCENE \((type(of: self))) WAS REMOVED FROM MEMORY (DEINIT) \n")
    }
}
