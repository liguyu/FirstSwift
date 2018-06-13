//
//  ProgressView.swift
//  test
//
//  Created by apple on 2018/6/1.
//  Copyright © 2018 apple. All rights reserved.
//

import UIKit

class ProgressView: UIView {

    // the layer that shows the actual progress
    private let progressLayer: CAShapeLayer = CAShapeLayer()
    
    private var progressLabel: UILabel = UILabel()
    private var sizeProgressLabel : UILabel = UILabel()
    
    // layer to show the dashed circle layer
    private var dashedLayer: CAShapeLayer = CAShapeLayer()
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }
    
    private func setupView() {
        backgroundColor = UIColor.clear
        createProgressLayer()
        createLabel()
    }
    
    func createLabel() {
        progressLabel = UILabel()
        progressLabel.textColor = .white
        progressLabel.textAlignment = .center
        progressLabel.text = "0 %"
        progressLabel.font = UIFont(name: "HelveticaNeue-UltraLight", size: 40.0)
        translatesAutoresizingMaskIntoConstraints = false
        addSubview(progressLabel)
        // add constraints
        addConstraint(NSLayoutConstraint(item: self, attribute: .centerX, relatedBy: .equal, toItem: progressLabel, attribute: .centerX, multiplier: 1.0, constant: 0.0))
        addConstraint(NSLayoutConstraint(item: self, attribute: .centerY, relatedBy: .equal, toItem: progressLabel, attribute: .centerY, multiplier: 1.0, constant: 0.0))
        
        // label to show the already downloaded size and the total size of the file
        sizeProgressLabel = UILabel()
        sizeProgressLabel.textColor = .white
        sizeProgressLabel.textAlignment = .center
        sizeProgressLabel.text = "0.0 MB / 0.0 MB"
        sizeProgressLabel.font = UIFont(name: "HelveticaNeue-Light", size: 10.0)
        translatesAutoresizingMaskIntoConstraints = false
        addSubview(sizeProgressLabel)
        // add constraints
        addConstraint(NSLayoutConstraint(item: self, attribute: .centerX, relatedBy: .equal, toItem: sizeProgressLabel, attribute: .centerX, multiplier: 1.0, constant: 0.0))
        addConstraint(NSLayoutConstraint(item: progressLabel, attribute: .bottom, relatedBy: .equal, toItem: sizeProgressLabel, attribute: .top, multiplier: 1.0, constant: -10.0))
    }

    private func createProgressLayer() {
        let startAngle = CGFloat(Double.pi/2)
        let endAngle = CGFloat(Double.pi * 2 + Double.pi/2)
        let centerPoint = CGPoint(x:frame.width/2.0, y:frame.height/2.0)
        
        progressLayer.path = UIBezierPath(arcCenter:centerPoint, radius: frame.width/2 - 10.0, startAngle:startAngle, endAngle:endAngle, clockwise: true).cgPath
        progressLayer.backgroundColor = UIColor.clear.cgColor
        progressLayer.fillColor = nil
        progressLayer.strokeColor = UIColor.white.cgColor
        progressLayer.lineWidth = 4.0
        progressLayer.strokeStart = 0.0
        progressLayer.strokeEnd = 0.0
        layer.addSublayer(progressLayer)
        
        let dashedLayer = CAShapeLayer()
        dashedLayer.strokeColor = UIColor(white: 1.0, alpha: 0.5).cgColor
        dashedLayer.fillColor = nil
        dashedLayer.lineDashPattern = [2, 4]
        dashedLayer.lineJoin = "round"
        dashedLayer.lineWidth = 2.0
        dashedLayer.path = progressLayer.path
        layer.insertSublayer(dashedLayer, below: progressLayer)
    }
    
    func animateProgressViewToProgress(progress: Float) {
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.fromValue = CGFloat(progressLayer.strokeEnd)
        animation.toValue = CGFloat(progress)
        animation.duration = 0.2
        animation.fillMode = kCAFillModeForwards
        progressLayer.strokeEnd = CGFloat(progress)
        progressLayer.add(animation, forKey: "animation")
    }
    
    func updateProgressViewLabelWithProgress(percent: Float) {
        progressLabel.text = NSString(format: "%.0f %@", percent, "%") as String
    }
    
    func updateProgressViewWith(totalSent: Float, totalFileSize: Float) {
        sizeProgressLabel.text = NSString(format: "%.1f MB / %.1f MB", convertFileSizeToMegabyte(size: totalSent), convertFileSizeToMegabyte(size: totalFileSize)) as String
    }
    
    private func convertFileSizeToMegabyte(size: Float) -> Float {
        return (size / 1024) / 1024
    }
    
//    func hideProgressView() {
//        progressLayer.strokeEnd = 0.0
//        progressLayer.removeAllAnimations()
//    }
//
//    override func animationDidStop(anim: CAAnimation!, finished flag: Bool) {
//        hideProgressView()
//    }

}
