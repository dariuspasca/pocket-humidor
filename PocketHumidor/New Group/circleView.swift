//
//  circleView.swift
//  CigarStack
//
//  Created by Darius Pasca on 08/05/2018.
//  Copyright © 2018 Darius Pasca. All rights reserved.
//

import UIKit

class circleView: UIView {

    var backgroundLayer: CAShapeLayer!
    var progressLayer: CAShapeLayer!
    
    init(frame: CGRect, percent: Double) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.clear
        let circlePath = UIBezierPath(arcCenter: CGPoint(x: frame.size.width / 2.0, y: frame.size.height / 2.0), radius: (frame.size.width - 10)/2, startAngle: CGFloat(-Double.pi/2), endAngle: CGFloat(Double.pi + Double.pi/2), clockwise: true)
        
        backgroundLayer = CAShapeLayer()
        backgroundLayer.path = circlePath.cgPath
        backgroundLayer.fillColor = UIColor.clear.cgColor
        backgroundLayer.strokeColor = UIColor(red: 230/255, green: 230/255, blue: 230/255, alpha: 1).cgColor
        backgroundLayer.lineWidth = 3.0
        
        
        progressLayer = CAShapeLayer()
        progressLayer.path = circlePath.cgPath
        progressLayer.fillColor = UIColor.clear.cgColor
        progressLayer.strokeColor = UIColor(red: 231/255, green: 76/255, blue: 60/255, alpha: 1).cgColor
        progressLayer.lineWidth = 3.0
        progressLayer.strokeEnd = CGFloat(percent)
        progressLayer.lineCap = kCALineCapRound
        
        layer.addSublayer(backgroundLayer)
        layer.addSublayer(progressLayer)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

}
