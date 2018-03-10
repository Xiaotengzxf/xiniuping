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

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        NotificationCenter.default.addObserver(self, selector: #selector(MTabBarController.handleNotification(notification:)), name: Notification.Name("tab"), object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        addCustomServiceButton()
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
            }else if tag == 2 {
                btnService.isHidden = false
            }
        }
    }
    
    
    func addCustomServiceButton() {
        if btnService == nil {
            btnService = UIButton(frame: CGRect(x: WIDTH - 70, y: HEIGHT - 130, width: 60, height: 60))
            btnService.setImage(UIImage(named: "kefu"), for: .normal)
            btnService.backgroundColor = UIColor.rgbColorFromHex(rgb: 0x0789CD)
            btnService.layer.cornerRadius = 30
            btnService.clipsToBounds = true
            btnService.layer.shadowOffset = CGSize(width: 8, height: 8)
            btnService.layer.shadowOpacity = 0.8
            self.view?.insertSubview(btnService, at: 0)
            self.view?.bringSubview(toFront: btnService)
            btnService.addTarget(self, action: #selector(MTabBarController.jumpToCustom), for: .touchUpInside)
        }
    }
    
    func jumpToCustom() {
        DispatchQueue.global().async {
            [weak self] in
            let lgM = SCLoginManager.share()
            if lgM!.loginKefuSDK() {
//                if let userinfo = UserDefaults.standard.object(forKey: "userinfo") as? [String : Any] {
//                    lgM?.nickname = userinfo["userChineseName"] as? String ?? "用户"
//                }
//                if let username = UserDefaults.standard.object(forKey: "username") as? String {
//                    lgM?.username = username
//                }
                let chat = HDChatViewController(conversationChatter: "kefuchannelimid_856946")
                chat?.hidesBottomBarWhenPushed = true
                chat?.visitorInfo = self?.visitorInfo()
                chat?.title = lgM!.cname
                DispatchQueue.main.async {
                    self?.btnService.isHidden = true
                    let controller : UINavigationController = self!.viewControllers![self!.selectedIndex] as! UINavigationController
                    controller.pushViewController(chat!, animated: true)
                }
            }
        }
    }
    
    func visitorInfo() -> HVisitorInfo {
        let visitor = HVisitorInfo()
        if let userinfo = UserDefaults.standard.object(forKey: "userinfo") as? [String : Any] {
            visitor.nickName = userinfo["userChineseName"] as? String ?? "用户"
            visitor.companyName = userinfo["companyName"] as? String ?? "东风裕隆旧车置换有限公司"
        }
        if let username = UserDefaults.standard.object(forKey: "username") as? String {
            visitor.name = username
        }
        return visitor
    }

}
