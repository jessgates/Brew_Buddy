//
//  BubbleView.swift
//  Brew_Buddy
//
//  Created by Jess Gates on 6/12/17.
//  Copyright © 2017 Jess Gates. All rights reserved.
//

import UIKit
import Foundation

class BubbleView: UIView {
    
    func createBubbles() {
        let emitter = CAEmitterLayer()
        emitter.emitterPosition = CGPoint(x: frame.size.width / 2.0, y: frame.maxY)
        emitter.emitterShape = kCAEmitterLayerLine
        emitter.emitterSize = CGSize(width: frame.size.width, height: 1)
        
        emitter.emitterCells = (0..<5).map({ _ in
            let intensity = Float(0.5)
            
            let cell = CAEmitterCell()
            
            cell.birthRate = 6.0 * intensity
            cell.lifetime = 14.0 * intensity
            cell.lifetimeRange = 0
            cell.velocity = CGFloat(350.0 * intensity)
            cell.velocityRange = CGFloat(80.0 * intensity)
            cell.emissionLongitude = CGFloat(270)//(Double.pi)
            cell.emissionRange = CGFloat(Double.pi / 4)
            cell.spin = CGFloat(3.5 * intensity)
            cell.spinRange = CGFloat(4.0 * intensity)
            cell.scaleRange = CGFloat(intensity)
            cell.scaleSpeed = CGFloat(-0.1 * intensity)
            cell.contents = UIImage(named: "bubble")!.cgImage
            
            return cell
        })
        layer.addSublayer(emitter)
    }
    
    func createGradientLayer() {
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = CGRect(x: 0, y: 0, width: frame.size.width, height: frame.size.height)
        gradientLayer.colors = [UIColor.yellow.cgColor, UIColor.brown.cgColor]
        
        layer.addSublayer(gradientLayer)
    }
    
    
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
        createGradientLayer()
        createBubbles()
    }

}
