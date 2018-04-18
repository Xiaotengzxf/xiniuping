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
    
    func handleImage(image: UIImage) -> Data {
        if var data = UIImageJPEGRepresentation(image, 0.9) {
            var i = 9
            while NSData(data: data).length > 500 * 1024 {
                i -= 1
                data = UIImageJPEGRepresentation(image, CGFloat(i) / 10)!
            }
            print("图片大小：\(NSData(data: data).length)")
            return data
        } else {
            return UIImageJPEGRepresentation(image, 1)!
        }
    }
    
    func handleImage(data: Data) -> Data {
        let image = UIImage(data: data)!
        return handleImage(image: image)
    }
}
