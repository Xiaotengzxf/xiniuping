//
//  DetectionViewController.swift
//  CarDetecion
//
//  Created by 张晓飞 on 2017/3/10.
//  Copyright © 2017年 inewhome. All rights reserved.
//

import UIKit
import Toaster
import SwiftyJSON
import AVFoundation

class DetectionViewController: UIViewController {

    
    @IBOutlet weak var lblPreDetection: UILabel!
    @IBOutlet weak var vPass: UIView!
    @IBOutlet weak var vReview: UIView!
    @IBOutlet weak var vUnsubmit: UIView!
    @IBOutlet weak var vUnpass: UIView!
    @IBOutlet weak var lblUnSubmit: UILabel!
    @IBOutlet weak var lblUnpass: UILabel!
    @IBOutlet weak var lblReview: UILabel!
    @IBOutlet weak var lblPass: UILabel!
    @IBOutlet weak var vCarStatus: UIView!
    @IBOutlet weak var vPreDetection: UIView!
    @IBOutlet weak var vDetection: UIView!
    @IBOutlet weak var lcRight: NSLayoutConstraint!
    @IBOutlet weak var lcLeft: NSLayoutConstraint!
    
    let applyCount = "external/app/getApplyCountInfo.html"
    let latestList = "external/news/latestList.html"
    let pageDetail = "external/pageelement/pageDetail.html"
    var arrNews : [JSON] = []
    var bTemp = false // temprary bool for evaluation
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getApplyCount()
        //getLatestList(type: "新闻公告")
        let abStr = NSMutableAttributedString(string: "详情")
        abStr.addAttributes([NSUnderlineStyleAttributeName : 1 , NSForegroundColorAttributeName : UIColor.black , NSFontAttributeName : UIFont.systemFont(ofSize: 14)], range: NSMakeRange(0, 2))
        // 点击事件
        let tap = UITapGestureRecognizer(target: self, action: #selector(DetectionViewController.handleGestureRecognizer(recognizer:)))
        
        vDetection.addGestureRecognizer(tap)
        
        let tapB = UITapGestureRecognizer(target: self, action: #selector(DetectionViewController.handleGestureRecognizer(recognizer:)))
        
        vPreDetection.addGestureRecognizer(tapB)
        
        let tapC = UITapGestureRecognizer(target: self, action: #selector(DetectionViewController.handleGestureRecognizer(recognizer:)))
        
        vCarStatus.addGestureRecognizer(tapC)
        
        let tap1 = UITapGestureRecognizer(target: self, action: #selector(DetectionViewController.tap(recognizer:)))
        tap1.numberOfTapsRequired = 1
        vPass.addGestureRecognizer(tap1)
        
        let tap2 = UITapGestureRecognizer(target: self, action: #selector(DetectionViewController.tap(recognizer:)))
        tap2.numberOfTapsRequired = 1
        vReview.addGestureRecognizer(tap2)
        
        let tap3 = UITapGestureRecognizer(target: self, action: #selector(DetectionViewController.tap(recognizer:)))
        tap3.numberOfTapsRequired = 1
        vUnpass.addGestureRecognizer(tap3)
        
        let tap4 = UITapGestureRecognizer(target: self, action: #selector(DetectionViewController.tap(recognizer:)))
        tap4.numberOfTapsRequired = 1
        vUnsubmit.addGestureRecognizer(tap4)
        
        NotificationCenter.default.addObserver(self, selector: #selector(DetectionViewController.handleNotification(notification:)), name: Notification.Name("detection"), object: nil)
        
        // 判断是否显示预评估 非先锋不显示
        if let userinfo = UserDefaults.standard.object(forKey: "userinfo") as? [String : Any] {
            let userSuperCompany = userinfo["userSuperCompany"] as? Int ?? 0
            let userCompany = userinfo["userCompany"] as? Int ?? 0
            if userSuperCompany == 9 || userCompany == 9 { // 先锋
                lcRight.constant = (WIDTH - 240) / 4
                lcLeft.constant = (WIDTH - 240) / 4
            }else if userSuperCompany == 8 || userCompany == 8 { // 广汇
                lcRight.constant = (WIDTH - 240) / 4
                lcLeft.constant = (WIDTH - 240) / 4
                lblPreDetection.text = "残值评估"
            }else{
                lblPreDetection.isHidden = true
                vPreDetection.isHidden = true
                lcLeft.constant = ((WIDTH - 160) / 3 - 80 ) / 2
                lcRight.constant = ((WIDTH - 160) / 3 - 80 ) / 2
            }
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.lt_setBackgroundColor(backgroundColor: UIColor(red: 0, green: 0, blue: 0, alpha: 0))
        
        if let orders = UserDefaults.standard.object(forKey: "orders") as? [[String : String]] {
            lblUnSubmit.text = "共有\(orders.count)单"
        }else{
            lblUnSubmit.text = "共有0单"
        }
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.navigationBar.lt_reset()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @IBAction func showAdvertiseDetail(_ sender: Any) {
        
        if let button = sender as? UIButton {
            var strUrl = ""
            if button.tag == 1 {
                // 判断是否显示预评估 非先锋不显示
                var nId = -1
                if let userinfo = UserDefaults.standard.object(forKey: "userinfo") as? [String : Any] {
                    let userSuperCompany = userinfo["userSuperCompany"] as? Int ?? 0
                    let userCompany = userinfo["userCompany"] as? Int ?? 0
                    if userSuperCompany == 9 || userCompany == 9 { // 先锋
                        nId = 4
                    }else if userSuperCompany == 8 || userCompany == 8 { // 广汇
                        nId = 5
                    }else{
                        
                    }
                }
                NetworkManager.sharedInstall.request(url: pageDetail, params: ["id" : nId, "clientName" : "iOS"]) {[weak self](json, error) in
                    if error != nil {
                        print(error!.localizedDescription)
                    }else{
                        if let data = json {
                            if let controller = self?.storyboard?.instantiateViewController(withIdentifier: "newsdetail") as? NewsDetailController {
                                controller.title = "拒评规则"
                                controller.json = data
                                self?.navigationController?.pushViewController(controller, animated: true)
                            }
                        }
                    }
                }
            }else{ // 拍照手册
                if let username = UserDefaults.standard.object(forKey: "username") as? String {
                    strUrl = "\(NetworkManager.sharedInstall.domain)/external/app/getAppPageElement.html?id=3&userName=\(username)&clientName=iOS"
                    if let controller = self.storyboard?.instantiateViewController(withIdentifier: "detectionweb") as? DetectionWebViewController {
                        controller.title = button.titleLabel?.text
                        controller.strUrl = strUrl
                        controller.hidesBottomBarWhenPushed = true
                        self.navigationController?.pushViewController(controller, animated: true)
                    }
                }
                
            }
        }
    }
    
    // 处理通知
    func handleNotification(notification : Notification) {
        
    }
    
    func handleGestureRecognizer(recognizer : UITapGestureRecognizer) {
        if recognizer.view == vDetection {
            jumpToCamera()
        }else if recognizer.view == vPreDetection {
            if let userinfo = UserDefaults.standard.object(forKey: "userinfo") as? [String : Any] {
                let userSuperCompany = userinfo["userSuperCompany"] as? Int ?? 0
                let userCompany = userinfo["userCompany"] as? Int ?? 0
                if userSuperCompany == 9 || userCompany == 9 { // 先锋
                    // jumpToPreDetection()
                    self.performSegue(withIdentifier: "pre", sender: self)
                }else if userSuperCompany == 8 || userCompany == 8 { // 广汇
                    bTemp = true
                    jumpToCamera()
                }else{
                    
                }
            }
            
            
        }else{
            Toast(text: "抱歉，您还没有车。").show()
        }
    }
    
    // 跳转至评估页面
    func jumpToCamera() {
        let mediaType = AVMediaTypeVideo
        let authStatus = AVCaptureDevice.authorizationStatus(forMediaType: mediaType)
        
        if authStatus == .restricted || authStatus == .denied {
            
            let alert = UIAlertController(title: nil, message: "请在设置里，先授权至信评使用相机权限", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "确定", style: .default, handler: { (action) in
                
                self.dismiss(animated: false, completion: nil)
                
            }))
            
            self.present(alert, animated: true, completion: nil)
            
            
        }else if UIImagePickerController.isSourceTypeAvailable(.camera){
            
            self.performSegue(withIdentifier: "toNewDetection", sender: self)
            
        }else{
            // 模拟器
            self.performSegue(withIdentifier: "toNewDetection", sender: self)
        }
    }
    
    func jumpToPreDetection()  {
        let tabPage = TabPageViewController.create()
        let preDetection = storyboard?.instantiateViewController(withIdentifier: "predetection") as! PreDetectionTVController
        let preDetectionList = storyboard?.instantiateViewController(withIdentifier: "predetectionlist") as! PreDetectionListTVController
        preDetection.tabPage = tabPage
        preDetection.tableView.contentInset = UIEdgeInsetsMake(108, 0, 0, 0)
        preDetectionList.tableView.contentInset = UIEdgeInsetsMake(108, 0, 0, 0)
        tabPage.tabItems = [(preDetection, "预评估"), (preDetectionList, "预评估状态")]
        var option = TabPageOption()
        option.tabWidth = view.frame.width / CGFloat(tabPage.tabItems.count)
        option.tabHeight = 44
        tabPage.option = option
        tabPage.title = "预评估"
        tabPage.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(tabPage, animated: true)
    }
    
    // 处理点击事件
    func tap(recognizer : UITapGestureRecognizer) {
        var index = 0
        if recognizer.view == vUnsubmit {
            index = 0
        }else if recognizer.view == vReview {
            index = 1
        }else if recognizer.view == vUnpass {
            index = 2
        }else{
            index = 3
        }
        NotificationCenter.default.post(name: Notification.Name("tab"), object: 1, userInfo: ["index" : index])
    }
    
    // 获取审核中，未通过及通过的订单总数
    func getApplyCount() {
        let username = UserDefaults.standard.string(forKey: "username")
        let params = ["userName" : username!]
        NetworkManager.sharedInstall.request(url: applyCount, params: params) {[weak self] (json, error) in
            if error != nil {
                print(error!.localizedDescription)
            }else{
                if let data = json , data["total"].intValue > 0 {
                    if let array = data["data"].array {
                        for j in array {
                            if j["infoType"].stringValue == "finishCount" {
                                self?.lblPass.text = "共有\(j["countInfo"].int ?? 0)单"
                            }else if j["infoType"].stringValue == "refuseCount" {
                                self?.lblUnpass.text = "共有\(j["countInfo"].int ?? 0)单"
                            }else if j["infoType"].stringValue == "processCount" {
                                self?.lblReview.text = "共有\(j["countInfo"].int ?? 0)单"
                            }else if j["infoType"].stringValue == "allCount" {
                                //self?.lblReview.text = "共有\(j["countInfo"].string ?? "0")单"
                            }
                        }
                    }
                }else{
                    if let message = json?["message"].string {
                        Toast(text: message).show()
                    }
                }
            }
        }
    }
    
    // 获取最新公告
    func getLatestList(type : String) {
        NetworkManager.sharedInstall.request(url: latestList, params: ["classType" : type]) {[weak self](json, error) in
            if error != nil {
                print(error!.localizedDescription)
            }else{
                if let data = json , data["total"].intValue > 0 {
                    if let array = data["data"].array {
                        self?.arrNews += array
                    }
                }
            }
        }
    }

    // 搜索功能
    @IBAction func doSearch(_ sender: Any) {
        
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let controller = segue.destination as? DetectionNewViewController {
            if bTemp {
                controller.bGuanghui = true
                bTemp = false
            }
        }
    }
    

}
