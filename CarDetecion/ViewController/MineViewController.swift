//
//  MineTableViewController.swift
//  CarDetecion
//
//  Created by 张晓飞 on 2017/3/10.
//  Copyright © 2017年 inewhome. All rights reserved.
//

import UIKit

class MineViewController: UIViewController {
    
    var titles : [[String]]!
    var icons : [[String]]!
    @IBOutlet weak var lblUserInfo: UILabel!
    @IBOutlet weak var rightConstraint: NSLayoutConstraint!
    @IBOutlet weak var leftConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let userinfo = UserDefaults.standard.object(forKey: "userinfo") as? [String : Any] {
            lblUserInfo.text = "所属公司：\(userinfo["companyName"] as? String ?? "") \n" +
                               "账号：\(userinfo["userChineseName"] as? String ?? "") \n" +
                               "电话： \n" +
                               "QQ:  \n" +
                               "微信： \n"
        }
        
        let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? ""
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "V\(version)", style: .plain, target: nil, action: nil)
        let constant = (WIDTH - 300) / 8
        leftConstraint.constant = constant
        rightConstraint.constant = constant
        
        let ivTitle = UIImageView(image: UIImage(named: "tabtitle43"))
        ivTitle.frame = CGRect(x: 0, y: 0, width: 47, height: 23)
        navigationItem.titleView = ivTitle
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let tabController = self.navigationController?.tabBarController as? MTabBarController {
            tabController.tabView.isHidden = false
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
 
    @IBAction func handleTap(_ sender: Any) {
        if let button = sender as? UIButton {
            let tag = button.tag
            switch tag {
            case 1:
                if let controller = self.storyboard?.instantiateViewController(withIdentifier: "default") as? DefaultViewController {
                    controller.title = "关于"
                    controller.hidesBottomBarWhenPushed = true
                    controller.flag = 1
                    if let tabController = self.navigationController?.tabBarController as? MTabBarController {
                        tabController.tabView.isHidden = true
                    }
                    self.navigationController?.pushViewController(controller, animated: true)
                }
                break
            case 2:
                if let controller = self.storyboard?.instantiateViewController(withIdentifier: "info") as? InfoTableViewController {
                    controller.title = "个人资料"
                    controller.hidesBottomBarWhenPushed = true
                    if let tabController = self.navigationController?.tabBarController as? MTabBarController {
                        tabController.tabView.isHidden = true
                    }
                    self.navigationController?.pushViewController(controller, animated: true)
                }
                break
            default:
                showAlet(title: "提示", message: "您确定退出吗？")
                break
            }
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    func showAlet(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "取消", style: .cancel, handler: { (action) in
            
        }))
        alert.addAction(UIAlertAction(title: "退出", style: .default, handler: {[weak self] (action) in
            let chat = HChatClient.shared()
            if chat!.isLoggedInBefore {
                if let error = chat?.logout(true) {
                    print(error.description)
                }
            }
            UserDefaults.standard.removeObject(forKey: "userinfo")
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let login = storyboard.instantiateViewController(withIdentifier: "login")
            self?.view?.window?.rootViewController = login
        }))
        present(alert, animated: true) { 
            
        }
    }
    
    func makeCall(message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "取消", style: .cancel, handler: { (action) in
            
        }))
        alert.addAction(UIAlertAction(title: "拨打", style: .default, handler: {(action) in
            UIApplication.shared.openURL(URL(string: "tel://\(message)")!)
        }))
        present(alert, animated: true) {
            
        }
    }

}
