//
//  ChatViewController.swift
//  CarDetecion
//
//  Created by 张晓飞 on 2018/3/11.
//  Copyright © 2018年 inewhome. All rights reserved.
//

import UIKit

class ChatViewController: UIViewController {

    var chat: HDChatViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.tabBarController?.tabBar.isHidden = true
        let lgM = SCLoginManager.share()
        if lgM!.loginKefuSDK() {
            chat = HDChatViewController(conversationChatter: "kefuchannelimid_856946")
            chat?.visitorInfo = visitorInfo()
            title = lgM!.cname
            self.addChildViewController(chat!)
            self.view.addSubview(chat!.view)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
