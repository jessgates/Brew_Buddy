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
    
    override func draw(_ rect: CGRect) {
        createGradientLayer()
        createBubbles()
    }
    
    override func layoutSubviews() {
        createGradientLayer()
        createBubbles()
    }
    
    func createBubbles() {
        let emitter = CAEmitterLayer()
        emitter.emitterPosition = CGPoint(x: self.bounds.width / 2, y: frame.maxY)
        emitter.emitterShape = kCAEmitterLayerLine
        emitter.emitterSize = CGSize(width: self.bounds.width, height: 1)
        
        emitter.emitterCells = (0..<10).map({ _ in
            let intensity = Float(0.5)
            
            let cell = CAEmitterCell()
            
            cell.birthRate = 17.0 * intensity
            cell.lifetime = 14.0 * intensity
            cell.lifetimeRange = 0
            cell.velocity = CGFloat(400.0 * intensity)
            cell.velocityRange = CGFloat(80.0 * intensity)
            cell.emissionLongitude = CGFloat(270.19)
            cell.contents = UIImage(named: "bubble")!.cgImage
            
            return cell
        })
        layer.addSublayer(emitter)
    }
    
    func createGradientLayer() {
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = self.bounds
        gradientLayer.colors = [UIColor(red:0.94, green:0.55, blue:0.15, alpha:1.0).cgColor, UIColor(red:0.85, green:0.45, blue:0.16, alpha:1.0).cgColor]
        
        layer.addSublayer(gradientLayer)
    }
}
