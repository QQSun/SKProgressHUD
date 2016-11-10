//
//  SKRoundProgressView.swift
//  SKProgressHUD
//
//  Created by nachuan on 2016/11/4.
//  Copyright © 2016年 nachuan. All rights reserved.
//

import UIKit


// MARK: - 计算属性
extension SKRoundProgressView {
    var progress: CGFloat {
        get {
            return _progress;
        }
        set {
            setProgress(progress: newValue);
        }
    }
    
    var progressTintColor: UIColor {
        get {
            return _progressTintColor;
        }
        set {
            setProgressTint(color: newValue);
        }
    }
    
    var backgroundTintColor: UIColor {
        get {
            return _backgroundTintColor;
        }
        set {
            setBackgroundTint(color: newValue);
        }
    }
    
}


// MARK: - setter
extension SKRoundProgressView {
    func setProgress(progress: CGFloat) -> Void {
        if _progress != progress {
            _progress = progress;
            setNeedsDisplay();
        }
    }
    
    func setProgressTint(color: UIColor) -> Void {
        if _progressTintColor != color && !_backgroundTintColor.isEqual(color) {
            _progressTintColor = color;
            setNeedsDisplay();
        }
    }
    
    func setBackgroundTint(color: UIColor) -> Void {
        if _backgroundTintColor != color && !_backgroundTintColor.isEqual(color) {
            _backgroundTintColor = color;
            setNeedsDisplay();
        }
    }
    
}



class SKRoundProgressView: UIView {

    /// 加载进度(0.0~1.0)
    fileprivate var _progress: CGFloat = 0.0;
    /// 指示进度颜色
    fileprivate var _progressTintColor: UIColor = .white;
    /// 指示背景颜色.非进度颜色
    fileprivate var _backgroundTintColor: UIColor = UIColor.init(white: 1.0, alpha: 0.1);
    /// Display mode - false: round   true: annular.  Defaults to round
    var isAnnular: Bool = false;
    
    init() {
        super.init(frame: CGRect(x: 0, y: 0, width: 37, height: 37));
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
        return CGSize(width: 37, height: 37);
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect);
        if let context: CGContext = UIGraphicsGetCurrentContext() {
            let isPreiOS7: Bool = kCFCoreFoundationVersionNumber < kCFCoreFoundationVersionNumber_iOS_7_0;
            if isAnnular {
                /// Draw background
                let linewidth: CGFloat = isPreiOS7 ? 5 : 2;
                let progressBackgroundPath = UIBezierPath();
                progressBackgroundPath.lineWidth = linewidth;
                progressBackgroundPath.lineCapStyle = CGLineCap.butt;
                let center: CGPoint = CGPoint(x: self.bounds.midX, y: self.bounds.midY);
                let radius: CGFloat = (self.bounds.width - linewidth) / 2;
                let startAngle: CGFloat = -CGFloat(M_PI_2);
                var endAngle: CGFloat = 2 * CGFloat(M_PI) + startAngle;
                progressBackgroundPath.addArc(withCenter: center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: true);
                _backgroundTintColor.set();
                progressBackgroundPath.stroke();
                
                /// Draw progress
                
                let progressPath: UIBezierPath = UIBezierPath();
                progressPath.lineWidth = linewidth;
                progressPath.lineCapStyle = isPreiOS7 ? CGLineCap.round : CGLineCap.square;
                endAngle = progress * 2 * CGFloat(M_PI) + startAngle;
                progressPath.addArc(withCenter: center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: true);
                _progressTintColor.set();
                progressPath.stroke();
            }else{
                let lineWidth: CGFloat = 2;
                let allRect: CGRect = self.bounds;
                let tempLineWidth: CGFloat = lineWidth / 2.0;
                
                let circleRect: CGRect = UIEdgeInsetsInsetRect(allRect, UIEdgeInsetsMake(tempLineWidth, tempLineWidth, tempLineWidth, tempLineWidth));
                let center: CGPoint = CGPoint(x: self.bounds.midX, y: self.bounds.midY);
                progressTintColor.setStroke();
                backgroundTintColor.setFill();
                context.setLineWidth(lineWidth);
                if isPreiOS7 {
                    context.fillEllipse(in: circleRect);
                }
                context.strokeEllipse(in: circleRect);
                /// 90 degress
                let startAngle: CGFloat = -(CGFloat(M_PI_2));
                /// Draw progress
                if isPreiOS7 {
                    let radius: CGFloat = (self.bounds.width / 2) - lineWidth;
                    let endAngle: CGFloat = progress * 2 * CGFloat(M_PI) + startAngle;
                    progressTintColor.setFill();
                    context.move(to: center);
                    context.addArc(center: center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: false);
                    context.closePath();
                    context.fillPath();
                    
                }else{
                    let progressPath: UIBezierPath = UIBezierPath();
                    progressPath.lineWidth = lineWidth * 2;
                    progressPath.lineCapStyle = .butt;
                    let radius: CGFloat = self.bounds.width / 2 - progressPath.lineWidth / 2;
                    let endAngle: CGFloat = progress * 2 * CGFloat(M_PI) + startAngle;
                    progressPath.addArc(withCenter: center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: true);
                    
                    /// Ensure that we don't get color overlaping when _progressTintColor alpha < 1.f.
                    context.setBlendMode(.copy);
                    progressTintColor.set();
                    progressPath.stroke();
                }
            }
        }
    }
}













































