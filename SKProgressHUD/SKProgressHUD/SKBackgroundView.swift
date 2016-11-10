//
//  SKBackgroundView.swift
//  SKProgressHUD
//
//  Created by nachuan on 2016/11/4.
//  Copyright © 2016年 nachuan. All rights reserved.
//

import UIKit


// MARK: - 计算属性
extension SKBackgroundView {
    var style: SKProgressHUDBackgroundStyle {
        get {
            return _style;
        }
        set {
            setStyle(style: newValue);
            
        }
    }
    
    var color: UIColor {
        get {
            return _color;
        }
        set {
            setColor(color: newValue);
        }
    }
    
}


// MARK: - setter
extension SKBackgroundView {
    
    // MARK: - Appearance
    
    func setStyle(style: SKProgressHUDBackgroundStyle) -> Void {
        var tempStyle = style;
        if style == .blur && kCFCoreFoundationVersionNumber < kCFCoreFoundationVersionNumber_iOS_7_0 {
            tempStyle = .solidColor;
        }
        if _style != tempStyle {
            _style = tempStyle;
            updateForBackgroundStyle();
        }
    }
    
    func setColor(color: UIColor) -> Void {
        if color != _color && !color.isEqual(_color) {
            _color = color;
            updateViews(for: color);
        }
    }
    
}


class SKBackgroundView: UIView {
    
    
    fileprivate var _effectView: UIVisualEffectView?
    fileprivate var _toolbar: UIToolbar?

    fileprivate var _style: SKProgressHUDBackgroundStyle = .solidColor;
    fileprivate var _color: UIColor = UIColor.clear;
    
    
    
    
    override init(frame: CGRect) {
        super.init(frame: frame);
        if kCFCoreFoundationVersionNumber >= kCFCoreFoundationVersionNumber_iOS_7_0 {
            _style = SKProgressHUDBackgroundStyle.blur;
            if kCFCoreFoundationVersionNumber >= kCFCoreFoundationVersionNumber_iOS_8_0 {
                _color = UIColor.init(white: 0.8, alpha: 0.6);
            }else{
                _color = UIColor.init(white: 0.95, alpha: 0.6);
            }
        }else{
            _style = SKProgressHUDBackgroundStyle.solidColor;
            _color = UIColor.black.withAlphaComponent(0.8);
        }
        self.clipsToBounds = true;
        updateForBackgroundStyle();
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
  
    
    /// Layout
    override var intrinsicContentSize: CGSize {
        return CGSize.zero;
    }
    
    
    /// 跟新视图样式
    func updateForBackgroundStyle() -> Void {
        let tempStyle: SKProgressHUDBackgroundStyle = style;
        if tempStyle == .blur {
            if kCFCoreFoundationVersionNumber >= kCFCoreFoundationVersionNumber_iOS_8_0 {
                let effect: UIBlurEffect = UIBlurEffect(style: .light);
                let effectView: UIVisualEffectView = UIVisualEffectView(effect: effect);
                self.addSubview(effectView);
                effectView.frame = self.bounds;
                effectView.autoresizingMask = [.flexibleHeight ,.flexibleWidth];
                self.backgroundColor = self.color;
                self.layer.allowsGroupOpacity = false;
                _effectView = effectView;
                
            }else{
                // MARK: - 如果背景toolbar的frame出现问题就是这里的edgeInsets出现问题
                let rect = self.bounds;
                let tempRcet = UIEdgeInsetsInsetRect(rect, UIEdgeInsetsMake(-100, -100, -100, -100));
                let toolbar: UIToolbar = UIToolbar(frame: tempRcet);
                toolbar.autoresizingMask = [.flexibleWidth, .flexibleHeight];
                toolbar.barTintColor = self.color;
                toolbar.isTranslucent = true;
                _toolbar = toolbar;
                
            }
        }else{
            if kCFCoreFoundationVersionNumber >= kCFCoreFoundationVersionNumber_iOS_8_0 {
                if _effectView != nil{
                    _effectView!.removeFromSuperview();
                    _effectView = nil;
                }
            }else{
                if _toolbar != nil {
                    _toolbar!.removeFromSuperview();
                    _toolbar = nil;
                }
            }
            self.backgroundColor = self.color;
        }
    }
    
    
    /// 更新视图颜色
    func updateViews(for color: UIColor) -> Void {
        if style == .blur {
            if kCFCoreFoundationVersionNumber >= kCFCoreFoundationVersionNumber_iOS_8_0 {
                self.backgroundColor = self.color;
            }else{
                if _toolbar != nil {
                    _toolbar!.barTintColor = color;
                }
            }
        }else{
            self.backgroundColor = self.color;
        }
    }

}








































