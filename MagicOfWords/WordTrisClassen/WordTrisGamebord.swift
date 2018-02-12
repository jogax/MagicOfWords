//
//  WordTrisGamebord.swift
//  MagicOfWords
//
//  Created by Jozsef Romhanyi on 11/02/2018.
//  Copyright © 2018 Jozsef Romhanyi. All rights reserved.
//

import Foundation
import GameplayKit

class WordTrisGameboard: SKShapeNode {
    var countCols: Int
    init(countCols: Int) {
        self.countCols = countCols
        super.init()
        
//        createMyShape()
    }
    
//    func createMyShape() {
//        let points: [CGPoint] = [CGPoint(x:50, y: 50), CGPoint: x:200, y: 200]
//        var path = UIBezierPath()
//        path.move(to: CGPoint(x: 0, y: 0))
//        path.addLine(to: points)
//    }
//
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
