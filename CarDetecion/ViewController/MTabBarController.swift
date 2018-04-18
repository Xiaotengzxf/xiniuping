//
//  MTabBarController.swift
//  CarDetecion
//
//  Created by 张晓飞 on 2017/3/30.
//  Copyright © 2017年 inewhome. All rights reserved.
//

import UIKit

var recordIndex = -1

class MTabBarController: UITabBarController {
    
    var btnService : UIButton!
    @IBOutlet var tabView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(MTabBarController.handleNotification(notification:)), name: Notification.Name("tab"), object: nil)
        tabView.translatesAutoresizingMaskIntoConstraints = false
        self.tabBar.addSubview(tabView)
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[tabView(90)]", options: .directionLeadingToTrailing, metrics: nil, views: ["tabView": tabView]))
        self.view.addConstraint(NSLayoutConstraint(item: tabView, attribute: .centerX, relatedBy: .equal, toItem: tabBar, attribute: .centerX, multiplier: 1, constant: 0))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[tabView(90)]", options: .directionLeadingToTrailing, metrics: nil, views: ["tabView": tabView]))
        self.view.addConstraint(NSLayoutConstraint(item: tabView, attribute: .top, relatedBy: .equal, toItem: tabBar, attribute: .top, multiplier: 1, constant: -35))
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    func handleNotification(notification : Notification) {
        if let tag = notification.object as? Int {
            if tag == 1 {
                if let userInfo = notification.userInfo as? [String : Int] {
                    let index = userInfo["index"] ?? 0
                    recordIndex = index
                    self.selectedIndex = 2
                }
            } else if tag == 10 {
                if let button = tabView.viewWithTag(1) as? UIButton {
                    tapTab(button)
                }
            }
        }
    }

    @IBAction func tapTab(_ sender: Any) {
        if let button = sender as? UIButton {
            let tag = button.tag
            switch tag {
            case 5:
                if let navigation = viewControllers![selectedIndex] as? UINavigationController {
                    jumpToCamera(navigation: navigation)
                }
                break;
            default:
                self.selectedIndex = tag - 1
                break;
            }
            
        }
    }
    
    // 跳转至评估页面
    private func jumpToCamera(navigation: UINavigationController) {
        let mediaType = AVMediaTypeVideo
        let authStatus = AVCaptureDevice.authorizationStatus(forMediaType: mediaType)
        
        if authStatus == .restricted || authStatus == .denied {
            
            let alert = UIAlertController(title: nil, message: "请在设置里，先授权至信评使用相机权限", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "确定", style: .default, handler: { (action) in
                
                self.dismiss(animated: false, completion: nil)
                
            }))
            
            self.present(alert, animated: true, completion: nil)
            
            
        }else if UIImagePickerController.isSourceTypeAvailable(.camera){
            
            if let vc = self.storyboard?.instantiateViewController(withIdentifier: "detectionnew") as? DetectionNewViewController {
                navigation.pushViewController(vc, animated: true)
            }
            
        }else{
            // 模拟器
            if let vc = self.storyboard?.instantiateViewController(withIdentifier: "detectionnew") as? DetectionNewViewController {
                navigation.pushViewController(vc, animated: true)
            }
        }
    }
}
