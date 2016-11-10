//
//  SKExtension.swift
//  SKProgressHUD
//
//  Created by nachuan on 2016/11/8.
//  Copyright © 2016年 nachuan. All rights reserved.
//
import UIKit
import Foundation

extension NSObject {
    func dictForViews(views:[UIView]) -> [String : UIView]? {
        var count: UInt32 = 0
        var dicts: [String : UIView] = [String: UIView]();
        for (_, view) in views.enumerated() {
            let ivars = class_copyIvarList(view.classForCoder, &count)
            for i in 0 ..< Int(2){
                let obj = object_getIvar(view, ivars![i])
                if let temp = obj as? UIView{
                    if views.contains(temp) {
                        let name = String.init(cString: ivar_getName(ivars![i]));
                        dicts[name] = temp
                        if dicts.count == views.count{ break }
                    }
                }
            }
            free(ivars)
        }
        return dicts
    }
    
    func dictionary(for view: UIView, index: Int) -> [String : UIView] {
        var dic = [String : UIView]();
        dic["view\(index)"] = view;
        return dic;
        
    }
    
    func nameFor(view: UIView) -> String?{
        var count:UInt32 = 0
        let ivars = class_copyIvarList(self.classForCoder, &count)
        if ivars == nil {
            return nil;
        }
        for i in 0 ..< Int(count){
            let obj = object_getIvar(self, ivars![i])
            if let temp = obj as? UIView{
                if temp === view {
                    return String.init(describing: ivar_getName(ivars![i]));
                }
            }
        }
        free(ivars)
        return nil;
    }
}
