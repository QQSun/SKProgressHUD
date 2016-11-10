//
//  SKRoundedButton.swift
//  SKProgressHUD
//
//  Created by nachuan on 2016/11/9.
//  Copyright © 2016年 nachuan. All rights reserved.
//

import UIKit

class SKRoundedButton: UIButton {

    override init(frame: CGRect) {
        super.init(frame: frame);
        self.layer.borderWidth = 1;
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews();
        let height: CGFloat = self.bounds.height;
        print(height);
        self.layer.cornerRadius = ceil(height / 2);
    }
    
    override var intrinsicContentSize: CGSize {
        
        if self.currentTitle == nil {
            return .zero;
        }
        var size: CGSize = super.intrinsicContentSize;
        size.width += 20;
        return size;
    }
    
    override func setTitleColor(_ color: UIColor?, for state: UIControlState) {
        super.setTitleColor(color, for: state);
        setHighlighted(highlighted: self.isHighlighted);
        self.layer.borderColor = color?.cgColor;
    }
    
    func setHighlighted(highlighted: Bool) -> Void {
        super.isHighlighted = highlighted;
        let baseColor = self.titleColor(for: .selected);
        self.backgroundColor = highlighted ? baseColor?.withAlphaComponent(0.1) : .clear;
    }

}


























