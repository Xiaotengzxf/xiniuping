//
//  ImageHandler.swift
//  CarDetecion
//
//  Created by 张晓飞 on 2018/3/15.
//  Copyright © 2018年 inewhome. All rights reserved.
//

import UIKit

class ImageHandler: NSObject {
    
    static let sharedInstance = ImageHandler()
    
    func handleImage(image: UIImage) -> UIImage {
        if var data = UIImageJPEGRepresentation(image, 0.9) {
            var i = 9
            while NSData(data: data).length > 500 * 1024 {
                i -= 1
                data = UIImageJPEGRepresentation(image, CGFloat(i) / 10)!
            }
            return UIImage(data: data)!
        } else {
            return image
        }
    }
}
