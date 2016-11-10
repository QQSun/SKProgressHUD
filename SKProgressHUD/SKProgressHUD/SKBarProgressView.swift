//
//  SKBarProgressView.swift
//  SKProgressHUD
//
//  Created by nachuan on 2016/11/4.
//  Copyright © 2016年 nachuan. All rights reserved.
//

import UIKit


// MARK: - 计算属性
extension SKBarProgressView {
    var progress: CGFloat {
        get {
            return _progress;
        }
        set {
            setProgress(progress: newValue);
        }
    }
    
    var progressRemainingColor: UIColor {
        get {
            return _progressRemainingColor;
        }
        set {
            setProgressRemaining(color: newValue);
        }
    }
    
    var progressColor: UIColor {
        get {
            return _progressColor;
        }
        set {
            setProgressColor(color: newValue);
        }
    }
    
    var lineColor: UIColor {
        get {
            return _lineColor;
        }
        set {
            _lineColor = newValue;
        }
    } 
}


// MARK: - setter
extension SKBarProgressView {
    func setProgress(progress: CGFloat) -> Void {
        if _progress != progress {
            _progress = progress;
            setNeedsDisplay();
        }
    }
    
    func setProgressRemaining(color: UIColor) -> Void {
        if _progressRemainingColor != color && !_progressRemainingColor.isEqual(color) {
            _progressRemainingColor = color
            setNeedsDisplay();
        }
    }
    
    func setProgressColor(color: UIColor) -> Void {
        if _progressColor != color && !_progressColor.isEqual(color) {
            _progressColor = color;
            setNeedsDisplay();
        }
    }
    
}


class SKBarProgressView: UIView {
    
    /// 进度(0.0 ~ 1.0)
    fileprivate var _progress: CGFloat = 0.0;
    /// Bar background color 默认clear
    fileprivate var _progressRemainingColor: UIColor = .clear;
    /// Bar progress color 默认白色
    fileprivate var _progressColor: UIColor = .white;
    /// Bar border line color
    fileprivate var _lineColor: UIColor = .white;
    
    init() {
        super.init(frame: CGRect(x: 0, y: 0, width: 120, height: 20));
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame);
        self.backgroundColor = .clear;
        self.isOpaque = false;
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var intrinsicContentSize: CGSize {
        let isPreiOS7 = kCFCoreFoundationVersionNumber < kCFCoreFoundationVersionNumber_iOS_7_0;
        return CGSize(width: 120, height: isPreiOS7 ? 20.0 : 10.0);
    }
   

    override func draw(_ rect: CGRect) {
        if let context = UIGraphicsGetCurrentContext() {
            context.setLineWidth(2);
            context.setStrokeColor(lineColor.cgColor);
            context.setFillColor(progressRemainingColor.cgColor);
            
            let rectW = rect.size.width;
            let rectH = rect.size.height;
            
            
            
            /// Draw background
            var radius: CGFloat = rectH / 2 - 2;
            var pointOne: CGPoint = CGPoint(x: 2, y: 2);
            var pointTwo: CGPoint = CGPoint(x: radius + 2, y: 2);
            
            context.move(to: CGPoint(x: 2, y: rectH / 2));
            context.addArc(tangent1End: pointOne, tangent2End: pointTwo, radius: radius);
            context.addLine(to: CGPoint(x: rectW - radius - 2, y: 2));
            
            pointOne = CGPoint(x: rectW - 2, y: 2)
            pointTwo = CGPoint(x: rectW - 2, y: rectH / 2);
            context.addArc(tangent1End: pointOne, tangent2End: pointTwo, radius: radius);
            
            pointOne = CGPoint(x: rectW - 2, y: rectH - 2);
            pointTwo = CGPoint(x: rectW - radius - 2, y: rectH - 2);
            context.addArc(tangent1End: pointOne, tangent2End: pointTwo, radius: radius);
            
            context.addLine(to: CGPoint(x: radius + 2, y: rectH - 2));
            
            pointOne = CGPoint(x: 2, y: rectH - 2);
            pointTwo = CGPoint(x: 2, y: rectH / 2);
            context.addArc(tangent1End: pointOne, tangent2End: pointTwo, radius: radius);
            context.fillPath();
            
            /// Draw border
            
            context.move(to: CGPoint(x: 2, y: rectH / 2));
            
            pointOne = CGPoint(x: 2, y: 2);
            pointTwo = CGPoint(x: radius + 2, y: 2);
            context.addArc(tangent1End: pointOne, tangent2End: pointTwo, radius: radius);
            
            context.addLine(to: CGPoint(x: rectW - radius - 2, y: 2));
            
            pointOne = CGPoint(x: rectW - 2, y: 2);
            pointTwo = CGPoint(x: rectW - 2, y: rectH / 2);
            context.addArc(tangent1End: pointOne, tangent2End: pointTwo, radius: radius);
            
            pointOne = CGPoint(x: rectW - 2, y: rectH - 2);
            pointTwo = CGPoint(x: rectW - radius - 2, y: rectH - 2);
            context.addArc(tangent1End: pointOne, tangent2End: pointTwo, radius: radius);
            
            context.addLine(to: CGPoint(x: radius + 2, y: rectH - 2));
            
            pointOne = CGPoint(x: 2, y: rectH - 2);
            pointTwo = CGPoint(x: 2, y: rectH / 2);
            context.addArc(tangent1End: pointOne, tangent2End: pointTwo, radius: radius);
            
            context.strokePath();
            
            context.setFillColor(progressColor.cgColor);
            radius -= 2;
            let amount: CGFloat = progress * rectW;
            
            //progress in the middle area
            if amount >= (radius + 4) && amount <= (rectW - radius - 4) {
                context.move(to: CGPoint(x: 4, y: rectH / 2));
                pointOne = CGPoint(x: 4, y: 4);
                pointTwo = CGPoint(x: radius + 4, y: 4);
                context.addArc(tangent1End: pointOne, tangent2End: pointTwo, radius: radius);
                context.addLine(to: CGPoint(x: amount, y: 4));
                context.addLine(to: CGPoint(x: amount, y: radius + 4));
                
                context.move(to: CGPoint(x: 4, y: rectH / 2));
                pointOne = CGPoint(x: 4, y: rectH - 4);
                pointTwo = CGPoint(x: radius + 4, y: rectH - 4);
                context.addArc(tangent1End: pointOne, tangent2End: pointTwo, radius: radius);
                context.addLine(to: CGPoint(x: amount, y: rectH - 4));
                context.addLine(to: CGPoint(x: amount, y: radius + 4));
                context.fillPath();
            }else if amount > (radius + 4) {
                // progress in the right arc
                let tempX: CGFloat = amount - (rectW - radius - 4);
                context.move(to: CGPoint(x: 4, y: rectH / 2));
                pointOne = CGPoint(x: 4, y: 4);
                pointTwo = CGPoint(x: radius + 4, y: 4);
                context.addArc(tangent1End: pointOne, tangent2End: pointTwo, radius: radius);
                context.addLine(to: CGPoint(x: rectW - radius - 4, y: 4));
                
                var angle: CGFloat = -acos(tempX / radius);
                if __inline_isnand(Double(angle)) != 0 {
                    angle = 0;
                }
                
                context.addArc(center: CGPoint(x: rectW - radius - 4, y: rectH / 2), radius: radius, startAngle: CGFloat(M_PI), endAngle: angle, clockwise: false);
                context.addLine(to: CGPoint(x: amount, y: rectH / 2));
                
                context.move(to: CGPoint(x: 4, y: rectH / 2));
                pointOne = CGPoint(x: 4, y: rectH - 4);
                pointTwo = CGPoint(x: radius + 4, y: rectH - 4);
                context.addArc(tangent1End: pointOne, tangent2End: pointTwo, radius: radius);
                context.addLine(to: CGPoint(x: rectW - radius - 4, y: rectH - 4));
                
                angle = acos(tempX / radius);
                if __inline_isnand(Double(angle)) != 0 {
                    angle = 0;
                }
                context.addArc(center: CGPoint(x: rectW - radius - 4, y: rectH / 2), radius: radius, startAngle: CGFloat(-M_PI), endAngle: angle, clockwise: true);
                context.addLine(to: CGPoint(x: amount, y: rectH / 2));
                context.fillPath();
            }else if amount < (radius + 4) && amount > 0 {
                context.move(to: CGPoint(x: 4, y: rectH / 2));
                pointOne = CGPoint(x: 4, y: 4);
                pointTwo = CGPoint(x: radius + 4, y: 4);
                context.addArc(tangent1End: pointOne, tangent2End: pointTwo, radius: radius);
                context.addLine(to: CGPoint(x: radius + 4, y: rectH / 2));
                
                context.move(to: CGPoint(x: 4, y: rectH / 2));
                pointOne = CGPoint(x: 4, y: rectH - 4);
                pointTwo = CGPoint(x: radius + 4, y: rectH - 4);
                context.addArc(tangent1End: pointOne, tangent2End: pointTwo, radius: radius);
                context.addLine(to: CGPoint(x: radius + 4, y: rectH / 2));
                context.fillPath();
            }
            
        }
    }
    
}


































