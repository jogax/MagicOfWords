//
//  MyButton.swift
//  MagicOfWords
//
//  Created by Jozsef Romhanyi on 14/03/2019.
//  Copyright © 2019 Jozsef Romhanyi. All rights reserved.
//

import SpriteKit

class MyButton: SKSpriteNode {
    
    enum FTButtonActionType: Int {
        case TouchUpInside = 1,
        TouchDown, TouchUp
    }
    
    var isEnabled: Bool = true {
        didSet {
            if (disabledTexture != nil) {
                texture = isEnabled ? defaultTexture : disabledTexture
            }
        }
    }
    var isSelected: Bool = false {
        didSet {
            texture = isSelected ? selectedTexture : defaultTexture
        }
    }
    
    var defaultTexture: SKTexture
    var selectedTexture: SKTexture
    var label: SKLabelNode
    var rect: CGRect
    
    required init(coder: NSCoder) {
        fatalError("NSCoding not supported")
    }
    
    init(fontName: String, size: CGSize) {
        self.rect = CGRect(origin: CGPoint(x:0, y:0), size: size)
        self.defaultTexture = SKTexture()
        self.selectedTexture = SKTexture()
        self.disabledTexture = SKTexture()
        self.label = SKLabelNode(fontNamed: fontName)
        super.init(texture: defaultTexture, color: UIColor.white, size: defaultTexture.size())
        isUserInteractionEnabled = true
        (defaultTexture, selectedTexture, disabledTexture) = myTexture()
        let textureX = defaultTexture
        self.texture = textureX
        self.label.verticalAlignmentMode = SKLabelVerticalAlignmentMode.center;
        self.label.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.center;
        addChild(self.label)
        let bugFixLayerNode = SKSpriteNode(texture: nil, color: UIColor.clear, size: defaultTexture.size())
        bugFixLayerNode.position = self.position
        addChild(bugFixLayerNode)

    }
    
    
    
    init(normalTexture defaultTexture: SKTexture!, selectedTexture:SKTexture!, disabledTexture: SKTexture!) {
        self.rect = CGRect()
        self.defaultTexture = defaultTexture
        self.selectedTexture = selectedTexture
        self.disabledTexture = disabledTexture
        self.label = SKLabelNode(fontNamed: "Helvetica");
        
        super.init(texture: defaultTexture, color: UIColor.white, size: defaultTexture.size())
        isUserInteractionEnabled = true
        
        //Creating and adding a blank label, centered on the button
        self.label.verticalAlignmentMode = SKLabelVerticalAlignmentMode.center;
        self.label.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.center;
        addChild(self.label)
        
        // Adding this node as an empty layer. Without it the touch functions are not being called
        // The reason for this is unknown when this was implemented...?
//        let bugFixLayerNode = SKSpriteNode(texture: nil, color: UIColor.clear, size: defaultTexture.size())
//        bugFixLayerNode.position = self.position
//        addChild(bugFixLayerNode)
        
    }
    
    /**
     * Taking a target object and adding an action that is triggered by a button event.
     */
    func setButtonAction(target: AnyObject, triggerEvent event:FTButtonActionType, action:Selector) {
        
        switch (event) {
        case .TouchUpInside:
            targetTouchUpInside = target
            actionTouchUpInside = action
        case .TouchDown:
            targetTouchDown = target
            actionTouchDown = action
        case .TouchUp:
            targetTouchUp = target
            actionTouchUp = action
        }
        
    }
    
    /*
     New function for setting text. Calling function multiple times does
     not create a ton of new labels, just updates existing label.
     You can set the title, font type and font size with this function
     */
    
    func setButtonLabel(title: String, font: UIFont) {
        let size = font.pointSize
        let name = font.fontName
        self.label.text = title
        self.label.fontSize = size
        self.label.fontName = name
        self.label.fontColor = .black
    }
    
    var disabledTexture: SKTexture?
    var actionTouchUpInside: Selector?
    var actionTouchUp: Selector?
    var actionTouchDown: Selector?
    weak var targetTouchUpInside: AnyObject?
    weak var targetTouchUp: AnyObject?
    weak var targetTouchDown: AnyObject?
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if (!isEnabled) {
            return
        }
        isSelected = true
        if (targetTouchDown != nil && targetTouchDown!.responds(to: actionTouchDown)) {
            UIApplication.shared.sendAction(actionTouchDown!, to: targetTouchDown, from: self, for: nil)
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if (!isEnabled) {
            return
        }
        
        let touch: AnyObject! = touches.first
        let touchLocation = touch.location(in: parent!)
        
        if (frame.contains(touchLocation)) {
            isSelected = true
        } else {
            isSelected = false
        }
        
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if (!isEnabled) {
            return
        }
        
        isSelected = false
        
        if (targetTouchUpInside != nil && targetTouchUpInside!.responds(to: actionTouchUpInside!)) {
            let touch: AnyObject! = touches.first
            let touchLocation = touch.location(in: parent!)
            
            if (frame.contains(touchLocation) ) {
                UIApplication.shared.sendAction(actionTouchUpInside!, to: targetTouchUpInside, from: self, for: nil)
            }
            
        }
        
        if (targetTouchUp != nil && targetTouchUp!.responds(to: actionTouchUp!)) {
            UIApplication.shared.sendAction(actionTouchUp!, to: targetTouchUp, from: self, for: nil)
        }
    }
    private func myTexture() -> (defaultTexture: SKTexture, selectedTexture: SKTexture, disabledTexture: SKTexture?) {
//        func drawLinearGradient(
//            context: CGContext, rect: CGRect, startColor: CGColor, endColor: CGColor) {
//            // 1
//            let colorSpace = CGColorSpaceCreateDeviceRGB()
//
//            // 2
//            let colorLocations: [CGFloat] = [0.0, 1.0]
//
//            // 3
//            let colors: CFArray = [startColor, endColor] as CFArray
//
//            // 4
////            let gradient = CGGradient(
////                colorsSpace: colorSpace, colors: colors, locations: colorLocations)!
//
//            // More to come...
//        }
        func drawGlossAndGradient(
            context: CGContext, rect: CGRect, startColor: CGColor, endColor: CGColor) {
            
            // 1
//            drawLinearGradient(
//                context: context, rect: rect, startColor: startColor, endColor: endColor)
            
//            let glossColor1 = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: /*0.35*/ 0.6)
//            let glossColor2 = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.1)
//            
//            let topHalf = CGRect(origin: rect.origin,
//                                 size: CGSize(width: rect.width, height: rect.height/2))
            
//            drawLinearGradient(context: context, rect: topHalf,
//                               startColor: glossColor1.cgColor, endColor: glossColor2.cgColor)
        }
        
        func createRoundedRectPath(for rect: CGRect, radius: CGFloat)->CGMutablePath {
            let path = CGMutablePath()
            
            // 1
            let midTopPoint = CGPoint(x: rect.midX, y: rect.minY)
            path.move(to: midTopPoint)
            
            // 2
            let topRightPoint = CGPoint(x: rect.maxX, y: rect.minY)
            let bottomRightPoint = CGPoint(x: rect.maxX, y: rect.maxY)
            let bottomLeftPoint = CGPoint(x: rect.minX, y: rect.maxY)
            let topLeftPoint = CGPoint(x: rect.minX, y: rect.minY)
            
            // 3
            path.addArc(tangent1End: topRightPoint,
                        tangent2End: bottomRightPoint,
                        radius: radius)
            
            path.addArc(tangent1End: bottomRightPoint,
                        tangent2End: bottomLeftPoint,
                        radius: radius)
            
            path.addArc(tangent1End: bottomLeftPoint,
                        tangent2End: topLeftPoint,
                        radius: radius)
            
            path.addArc(tangent1End: topLeftPoint,
                        tangent2End: topRightPoint,
                        radius: radius)
            
            // 4
            path.closeSubpath()
            
            return path
        }
        UIGraphicsBeginImageContext(rect.size)
        guard let context = UIGraphicsGetCurrentContext() else {
            return (defaultTexture: SKTexture(), selectedTexture: SKTexture(), disabledTexture: SKTexture())
        }
        
        
        
        let outerColor = UIColor(red: 220/255, green: 220/255, blue: 220/255, alpha: 1.0)
        let shadowColor = UIColor(red: 51/255, green: 51/255, blue: 51/255, alpha: 0.5)
        
        let outerMargin: CGFloat = 5.0
        let outerRect = rect.insetBy(dx: outerMargin, dy: outerMargin)
        let outerPath = createRoundedRectPath(for: outerRect, radius: GV.onIpad ? 8 : 8)
        
        //        if state != .highlighted {
        context.saveGState()
        context.setFillColor(outerColor.cgColor)
        context.setShadow(
            offset: CGSize(width: 0, height: 2), blur: 3.0, color: shadowColor.cgColor)
        context.addPath(outerPath)
        context.fillPath()
        context.restoreGState()
        //        }
        
        // Outer Path Gloss & Gradient
        let outerTop = UIColor(red: 100/255, green: 80/255, blue: 120/255, alpha: 1.0)
        let outerBottom = UIColor(red: 240/255, green: 120/255, blue: 140/255, alpha: 1.0)
        
        context.saveGState()
        context.addPath(outerPath)
        context.clip()
        drawGlossAndGradient(context: context, rect: outerRect,
                             startColor: outerTop.cgColor, endColor: outerBottom.cgColor)
        context.restoreGState()
        
        // Inner Path Gloss & Gradient
        let innerTop = UIColor(red: 200/255, green: 180/255, blue: 249/255, alpha: 1.0)
        let innerBottom = UIColor(red: 220/255, green: 80/255, blue: 220/255, alpha: 1.0)
        
        let innerMargin: CGFloat = 3.0
        let innerRect = outerRect.insetBy(dx: innerMargin, dy: innerMargin)
        let innerPath = createRoundedRectPath(for: innerRect, radius: 6.0)
        
        context.saveGState()
        context.addPath(innerPath)
        context.clip()
        drawGlossAndGradient(context: context, rect: innerRect,
                             startColor: innerTop.cgColor, endColor: innerBottom.cgColor)
        context.restoreGState()
        
        UIGraphicsBeginImageContext(size)
        //        let lineWidth: CGFloat = 5.0
        //        let context: CGContext = UIGraphicsGetCurrentContext()!
        //        context.setStrokeColor(UIColor.red.cgColor)
        //        context.setLineWidth(lineWidth)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        let texture = SKTexture(image: image!)
        return (defaultTexture: texture, selectedTexture: texture, disabledTexture: texture)
        
        
    }

}
