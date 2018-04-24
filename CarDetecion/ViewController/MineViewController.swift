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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "我的"
        let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? ""
        if let userinfo = UserDefaults.standard.object(forKey: "userinfo") as? [String : Any] {
            lblUserInfo.text = "所属公司：\(userinfo["companyName"] as? String ?? "") \n" +
                "\n" +
                "账       号：\(userinfo["userChineseName"] as? String ?? "") \n" +
                "\n" +
               "版       本： V\(version)\n" +
                "\n" +
               "手       机： \n" +
                "\n" +
               "Q         Q:  \n" +
                "\n" +
               "微       信： \n"
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func handleTap(_ sender: Any) {
        if let recognizer = sender as? UITapGestureRecognizer {
            let tag = recognizer.view?.tag ?? 0
            switch tag {
            case 1:
                if let controller = self.storyboard?.instantiateViewController(withIdentifier: "aboutus") as? AboutUsViewController {
                    controller.title = "关于我们"
                    controller.hidesBottomBarWhenPushed = true
                    self.navigationController?.pushViewController(controller, animated: true)
                }
                break
            case 2:
                let strUrl = "\(NetworkManager.sharedInstall.domain)/external/source/refuserules/1.json"
                if let controller = self.storyboard?.instantiateViewController(withIdentifier: "detectionweb") as? DetectionWebViewController {
                    controller.title = "拒评规则"
                    controller.strUrl = strUrl
                    controller.hidesBottomBarWhenPushed = true
                    self.navigationController?.pushViewController(controller, animated: true)
                }
                break
            case 3:
                if let controller = self.storyboard?.instantiateViewController(withIdentifier: "info") as? InfoTableViewController {
                    controller.title = "我的信息"
                    controller.hidesBottomBarWhenPushed = true
                    self.navigationController?.pushViewController(controller, animated: true)
                }
                break
            case 4:
                if let controller = self.storyboard?.instantiateViewController(withIdentifier: "detectionweb") as? DetectionWebViewController {
                    controller.title = "拍照手册"
                    controller.strUrl = ""
                    controller.hidesBottomBarWhenPushed = true
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
