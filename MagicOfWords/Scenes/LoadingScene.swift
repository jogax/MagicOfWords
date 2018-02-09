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
    

    var loadingSceneDelegate: LoadingSceneDelegate?
    override func didMove(to view: SKView) {
        minX = self.frame.size.width * 0.20
        minY = self.frame.size.height * 0.49
        maxX = self.frame.size.width * 0.80
        maxY = self.frame.size.height * 0.51
        self.backgroundColor = SKColor(red: 255/255, green: 220/255, blue: 208/255, alpha: 1)
        var progressShapeNode: SKShapeNode?
        createLoadingProcessShape()
        
        DispatchQueue.main.async {
            _ = GenerateGameData()
        }
        print("started Generate")

//        loadingSceneDelegate!.loadingFinished()
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
//        self.addChild(groundShapeNode)
        
    }
    public func setDelegate(delegate: LoadingSceneDelegate) {
        loadingSceneDelegate = delegate
    }
    
//    public func startShowProgress() {
//        timer = Timer.scheduledTimer(timeInterval: 0.001, target: self, selector: #selector(showProgress(timerX:)), userInfo: nil, repeats: true)
//    }
    
    func showProgress(timerX: Timer) {
        let progressShapeNodeName = "progressShapeNode"
        if self.childNode(withName: progressShapeNodeName) != nil {
            self.childNode(withName: progressShapeNodeName)!.removeFromParent()
        }
        if GV.maxRecordCount > 0 {
            let procent = CGFloat(GV.actRecordCount) / CGFloat(GV.maxRecordCount)
            let calculatedMaxX = minX + (maxX * procent)
            print("minX: \(minX), calculateMaxX: \(calculatedMaxX)")
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

            
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        print ("hier")
        
    }


}
