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
        guard let username = tfUserName.text?.trimmingCharacters(in: .whitespacesAndNewlines) , username.characters.count > 0 else {
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
        
        guard let pwd = tfPwd.text?.trimmingCharacters(in: .whitespacesAndNewlines) , pwd.characters.count > 0 else {
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
    /*{
     companyName = "\U5b89\U9633\U5e02\U65b0\U7eaa\U5143\U6c7d\U8f66\U9500\U552e\U670d\U52a1\U6709\U9650\U516c\U53f8--\U5e7f\U6c47";
     superCompanyName = "\U5e7f\U6c47\U6c7d\U8f66\U670d\U52a1\U80a1\U4efd\U516c\U53f8";
     userChineseName = "\U5f6d\U5a01";
     userCompany = 642;
     userId = 19720;
     userLoginName = cy;
     userSuperCompany = 8;
     }*/
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    //http://119.23.128.214:8080/carWeb/view/common/register.jsp
}
