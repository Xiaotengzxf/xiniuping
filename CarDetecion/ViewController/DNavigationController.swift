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
}
