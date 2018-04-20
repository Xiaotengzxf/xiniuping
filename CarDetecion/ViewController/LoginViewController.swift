//
//  LoginViewController.swift
//  CarDetecion
//
//  Created by 张晓飞 on 2017/3/29.
//  Copyright © 2017年 inewhome. All rights reserved.
//

import UIKit
import Toaster
import SwiftyJSON

class LoginViewController: UIViewController {

    @IBOutlet weak var tfUserName: UITextField!
    @IBOutlet weak var tfPwd: UITextField!
    @IBOutlet weak var btnLogin: UIButton!
    @IBOutlet weak var btnPwdShow: UIButton!
    let login = "external/app/checkUser.html"
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func drawTriangle() -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(CGSize(width: 10, height: 5), false, UIScreen.main.scale)
        let ctx = UIGraphicsGetCurrentContext()
        
        ctx?.beginPath()
        ctx?.move(to: CGPoint(x: 5, y: 0))
        ctx?.addLine(to: CGPoint(x: 10, y: 5))
        ctx?.addLine(to: CGPoint(x: 0, y: 5))
        ctx?.setFillColor(UIColor.white.cgColor)
        ctx?.closePath()
        ctx?.fillPath()
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
    
    // 登录
    /*{
     "message" : "密码错误",
     "object" : null,
     "success" : false
     }*/
    @IBAction func loginIn(_ sender: Any) {
        tfUserName.resignFirstResponder()
        tfPwd.resignFirstResponder()
        guard let username = tfUserName.text?.trimmingCharacters(in: .whitespacesAndNewlines) , username.count > 0 else {
            Toast(text: "请输入用户名").show()
            return
        }
        if let oldUserName = UserDefaults.standard.object(forKey: "username") as? String {
            if oldUserName != username {
                let alert = UIAlertController(title: "提示", message: "切换账号将清除上一个账号的所有本地数据，包括未提交，正在提交的单，已上传的不影响。", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "取消", style: .cancel, handler: { (action) in
                    
                }))
                alert.addAction(UIAlertAction(title: "确定", style: .default, handler: {[weak self] (action) in
                    self?.loginWithUserName(username: username)
                }))
                self.present(alert, animated: true, completion: { 
                    
                })
            }else{
                loginWithUserName(username: username)
            }
        }else{
            loginWithUserName(username: username)
        }
        
    }
    
    func loginWithUserName(username: String) {
        
        UserDefaults.standard.removeObject(forKey: "orderInfo")
        UserDefaults.standard.removeObject(forKey: "orders")
        UserDefaults.standard.removeObject(forKey: "orderKeys")
        UserDefaults.standard.removeObject(forKey: "preorders")
        UserDefaults.standard.removeObject(forKey: "preorderKeys")
        
        if let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first?.appending("/upload.data") {
            if FileManager.default.fileExists(atPath: path) {
                do{
                    try FileManager.default.removeItem(atPath: path)
                }catch{
                    
                }
            }
        }
        
        if let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first?.appending("/uploadpre.data") {
            if FileManager.default.fileExists(atPath: path) {
                do{
                    try FileManager.default.removeItem(atPath: path)
                }catch{
                    
                }
            }
        }
        
        guard let pwd = tfPwd.text?.trimmingCharacters(in: .whitespacesAndNewlines) , pwd.count > 0 else {
            Toast(text: "请输入密码").show()
            return
        }
        let hud = self.showHUD(text: "登录中...")
        NetworkManager.sharedInstall.request(url: login, params: ["userName" : username , "password" : pwd]) {[weak self] (json, error) in
            self?.hideHUD(hud: hud)
            if error != nil {
                Toast(text: "网络故障，请检查网络").show()
            }else{
                if let data = json , data["success"].boolValue {
                    if var dic = data["object"].dictionaryObject {
                        for (key , value) in dic {
                            if value is NSNull {
                                dic[key] = ""
                            }
                        }
                        UserDefaults.standard.set(dic, forKey: "userinfo")
                    }
                    UserDefaults.standard.set(username, forKey: "username")
                    UserDefaults.standard.synchronize()
                    
                    if let username = UserDefaults.standard.object(forKey: "username") as? String {
                        JPUSHService.setAlias(username, callbackSelector: nil, object: nil)
                    }
                    
                    if let controller = self?.storyboard?.instantiateViewController(withIdentifier: "default") as? DefaultViewController {
                        controller.modalTransitionStyle = .crossDissolve
                        self?.present(controller, animated: true, completion: {
                            
                        })
                    }
                    
                }else{
                    if let message = json?["message"].string {
                        Toast(text: message).show()
                    }
                }
            }
        }
    }
    
    @IBAction func doRegister(_ sender: Any) {
        if let controller = self.storyboard?.instantiateViewController(withIdentifier: "register") as? RegisterController {
            self.present(controller, animated: true, completion: { 
                
            })
        }
    }
    
    @IBAction func showPWD(_ sender: Any) {
        if btnPwdShow.isSelected {
            btnPwdShow.isSelected = false
            tfPwd.isSecureTextEntry = true
        } else {
            btnPwdShow.isSelected = true
            tfPwd.isSecureTextEntry = false
        }
    }
}
