//
//  DNavigationController.swift
//  CarDetecion
//
//  Created by 张晓飞 on 2017/3/31.
//  Copyright © 2017年 inewhome. All rights reserved.
//

import UIKit

class DNavigationController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationBar.shadowImage = UIImage()
//        UIDevice.current.beginGeneratingDeviceOrientationNotifications()
//        NotificationCenter.default.addObserver(self, selector: #selector(DNavigationController.deviceOrientationDidChange), name: NSNotification.Name.UIDeviceOrientationDidChange, object: self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func deviceOrientationDidChange() {
        if UIDevice.current.orientation == .portrait {
            UIApplication.shared.statusBarOrientation = .portrait
        }else{
            UIApplication.shared.statusBarOrientation = .landscapeRight
        }
    }
    
    func orientationChange(right : Bool)  {
        if right {
            UIView.animate(withDuration: 0.2, animations: { 
               
                
            })
        }
    }
    /*CGFloat width = [UIScreen mainScreen].bounds.size.width;
     CGFloat height = [UIScreen mainScreen].bounds.size.height;
     if (landscapeRight) {
     [UIView animateWithDuration:0.2f animations:^{
     self.view.transform = CGAffineTransformMakeRotation(M_PI_2);
     self.view.bounds = CGRectMake(0, 0, width, height);
     }];
     } else {
     [UIView animateWithDuration:0.2f animations:^{
     self.view.transform = CGAffineTransformMakeRotation(0);
     self.view.bounds = CGRectMake(0, 0, width, height);
     }];
     }*/
}
