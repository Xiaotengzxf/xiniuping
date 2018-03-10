//
//  Extension.swift
//  CarDetecion
//
//  Created by 张晓飞 on 2017/3/10.
//  Copyright © 2017年 inewhome. All rights reserved.
//

import UIKit
import MBProgressHUD

/**
 *  扩展部分
 */
extension UIColor {
    
    /**
     *  16进制 转 RGBA
     */
    class func rgbaColorFromHex(rgb:Int, alpha: CGFloat) ->UIColor {
        
        return UIColor(red: ((CGFloat)((rgb & 0xFF0000) >> 16)) / 255.0,
                       green: ((CGFloat)((rgb & 0xFF00) >> 8)) / 255.0,
                       blue: ((CGFloat)(rgb & 0xFF)) / 255.0,
                       alpha: alpha)
    }
    
    /**
     *  16进制 转 RGB
     */
    class func rgbColorFromHex(rgb:Int) -> UIColor {
        
        return UIColor(red: ((CGFloat)((rgb & 0xFF0000) >> 16)) / 255.0,
                       green: ((CGFloat)((rgb & 0xFF00) >> 8)) / 255.0,
                       blue: ((CGFloat)(rgb & 0xFF)) / 255.0,
                       alpha: 1.0)
    }
}

extension UIViewController : MBProgressHUDDelegate
{
    func showHUD(text : String) -> MBProgressHUD {
        let hud = MBProgressHUD.showAdded(to: self.view, animated: true)
        hud.delegate = self
        hud.labelText = text
        return hud
    }
    func hideHUD(hud : MBProgressHUD) {
        hud.hide(true)
    }
    public func hudWasHidden(_ hud: MBProgressHUD) {
        hud.removeFromSuperview()
    }
    
    
}

extension UIImage {
    class func image(withColor: UIColor) -> UIImage {
        let rect = CGRect(x: 0, y: 0, width: 1, height: 1)
        UIGraphicsBeginImageContext(CGSize(width: 1, height: 1))
        let context = UIGraphicsGetCurrentContext()
        context?.setFillColor(withColor.cgColor)
        context?.fill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
        
    }
}
