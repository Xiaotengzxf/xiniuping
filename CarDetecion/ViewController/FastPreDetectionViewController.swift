//
//  DetectionNewViewController.swift
//  CarDetecion
//
//  Created by 张晓飞 on 2017/3/11.
//  Copyright © 2017年 inewhome. All rights reserved.
//

import UIKit
import Toaster
import SKPhotoBrowser
import SwiftyJSON
import MBProgressHUD

class FastPreDetectionViewController: UIViewController , UITableViewDataSource , UITableViewDelegate , DetectionTableViewCellDelegate , UIViewControllerTransitioningDelegate, Detection4TableViewCellDelegate {
    
    @IBOutlet weak var lcBottom: NSLayoutConstraint!
    @IBOutlet weak var btnSave: UIButton!
    @IBOutlet weak var vBottom: UIView!
    @IBOutlet weak var tableView: UITableView!
    let sectionTitles = ["基础照片" , "补充照片" , "备注"]
    let titles = [["登记证首页" , "中控台含档位杆", "车左前45度"] , ["行驶证-正本\n副本同照", "左前门"]]
    let titlesImageClass = [["登记证" , "车辆内饰" , "车身外观"] , ["行驶证" , "车体骨架"]]
    let titlesImageSeqNum = [[0, 2, 0], [0, 5]]
    var images : [Int : Data] = [:]
    var imagesPath = "" // 本地如果有缓冲图片，则读取图片
    var imagesFilePath = "" // 本地如果有缓冲图片，则读取图片
    let presentAnimator = PresentAnimator()
    let dismissAnimator = DismisssAnimator()
    let bill = "external/carBill/getCarBillIdNextVal.html"
    let upload = "external/app/uploadAppImage.html"
    let uploadPre = "external/app/addAppPreCarImage.html"
    let operationDesc = "external/source/operation-desc.json" // 水印和接口说明
    let billImages = "external/app/getAppPreBillImageList.html"
    let submitPre = "external/app/addPreCarBill.html"

    var orderNo = ""
    var remark = ""
    var bSubmit = false // 是否点击了提交
    var bSubmitSuccess = false // 是否提交成功
    var companyNo = 0 // 单位代号
    var nTag = 0 // 临时tag
    //var cameraType = 0 // 单拍，连拍
    var waterMarks : [JSON] = []
    let companyOtherNeed : [Int] = [0 , 100, 1 , 1000 , 1100]
    var source = 0  // 0 创建新的，1 未通过 ， 2 本地的
    var json : JSON? // 未通过时，获取的数据
    var arrImageInfo : [JSON] = []
    var pathName = ""
    var bSave = false
    var fWebViewCellHeight : Float = 100
    var unfinished = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.handleNotification(notification:)), name: Notification.Name("fastpredetection"), object: nil)
        self.edgesForExtendedLayout = UIRectEdge(rawValue: 0)
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "返回", style: .plain, target: nil, action: nil)
    
        tableView.register(UINib(nibName: "ReUseHeaderFooterView", bundle: nil), forHeaderFooterViewReuseIdentifier: "header")
        
        if source == 1 {
            remark = json?["mark"].string ?? ""
            loadUnpassData()
        }else {
            getWaterMark(tag: -1)
            
        }
            
        
        if imagesPath.count > 0 {
            let hud = self.showHUD(text: "读取中...")
            DispatchQueue.global().async {
                [weak self] in
                var images : [Int : Data] = [:]
                let array = self!.imagesPath.components(separatedBy: ",")
                var path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first
                path = path! + "/\(self!.imagesFilePath)"
                for item in array {
                    if let image = UIImage(contentsOfFile: path! + "/\(item).jpg") {
                        images[Int(item)!] = UIImageJPEGRepresentation(image, 1)
                    }
                }
                self!.images = images
                DispatchQueue.main.async {
                    [weak self] in
                    self?.hideHUD(hud: hud)
                    self?.tableView.reloadData()
                }
            }
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.lt_setBackgroundColor(backgroundColor: UIColor(red: 55/255.0, green: 70/255.0, blue: 85/255.0, alpha: 1))
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if unfinished {
            if let button = vBottom.viewWithTag(102) as? UIButton {
                button.setTitle("重新提交", for: .normal)
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if (!self.navigationController!.viewControllers.contains(self)) && bSave == false && source != 1 {
            self.save(UIButton())
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func loadUnpassData() {
        let hud = showHUD(text: "加载中...")
        let username = UserDefaults.standard.string(forKey: "username")
        let params = ["userName" : username!, "carBillId": json!["carBillId"].stringValue]
        NetworkManager.sharedInstall.request(url: billImages, params: params) {[weak self] (json, error) in
            self?.hideHUD(hud: hud)
            if error != nil {
                print(error!.localizedDescription)
            }else{
                if let data = json , data["total"].intValue > 0 {
                    if let array = data["data"].array {
                        self?.arrImageInfo += array
                        self?.tableView.reloadData()
                    }
                }else{
                    if let message = json?["message"].string {
                        Toast(text: message).show()
                    }
                }
            }
        }
    }
    
    // 通知处理
    func handleNotification(notification : Notification) {
        if let tag = notification.object as? Int {
            if tag == 1 {
                if let userInfo = notification.userInfo as? [String : String] {
                    print(userInfo)
                }
            }else if tag == 2 {
                if let userInfo = notification.userInfo as? [String : String] {
                    remark = userInfo["text"]!
                }
            }else if tag == 3 {
                if let userInfo = notification.userInfo as? [String : Int] {
                    nTag = userInfo["tag"]!
                }
            }
        }
    }
    
    // tableviewcell的拍照代理
    func cameraModel(tag: Int) {
        nTag = tag
        if let data = images[tag] {
            var images = [SKPhoto]()
            let photo = SKPhoto.photoWithImage(UIImage(data: data)!)// add some UIImage
            images.append(photo)
            SKPhotoBrowserOptions.displayAction = false
            SKPhotoBrowserOptions.displayCloseButton = false
            let browser = SKPhotoBrowser(photos: images)
            let row = ((tag % 1000) % 100) * 2 + (tag % 1000 >= 100 ? 1 : 0)
            if row < titles[tag / 1000].count {
                browser.title = titles[tag / 1000][row]
            }else{
                browser.title = "添加图片"
            }
            browser.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "delete"), style: .plain, target: self, action: #selector(DetectionNewViewController.pop))
            self.navigationController?.pushViewController(browser, animated: true)
        }else{
            if waterMarks.count > 0{
                pushToCamera(tag: tag)
            }else{
                getWaterMark(tag: tag)
            }
        }
        
    }
    
    // 跳转到拍照界面
    func pushToCamera(tag : Int) {
        
        nTag = tag
        let camera = CameraViewController(croppingEnabled: false, allowsLibraryAccess: true) {[weak self] (image, asset) in
            if image != nil {
                self?.images[self!.nTag] = UIImageJPEGRepresentation(image!, 0.2)!
                self?.tableView.reloadData()
            }
        }
        //camera.cameraType = cameraType
        camera.nTag = nTag
        camera.sectionTiltes = sectionTitles
        camera.titles = titles
        camera.waterMarks = waterMarks
        camera.companyNeed = companyOtherNeed
        camera.titlesImageClass = titlesImageClass
        camera.titlesImageSeqNum = titlesImageSeqNum
        //camera.transitioningDelegate = self
        self.present(camera, animated: true) {
            
        }
    }
    
    // 弹框是否删除
    func pop() {
        let alert = UIAlertController(title: nil, message: "确认删除？", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "删除", style: .default, handler: {[weak self] (action) in
            self!.images[self!.nTag] = nil
            self?.tableView.reloadData()
            _ = self?.navigationController?.popViewController(animated: true)
        }))
        alert.addAction(UIAlertAction(title: "不，保留", style: .cancel, handler: { (action) in
            
        }))
        self.present(alert, animated: true) {
            
        }
    }
    
    // 保存
    @IBAction func save(_ sender: Any) {
        if source == 1 || unfinished {
            self.navigationController?.popViewController(animated: true)
            return
        }
        bSave = true
        if images.count > 0 || remark.count > 0 {
            var orders : [[String : String]] = []
            if let order = UserDefaults.standard.object(forKey: "preorders") as? [[String : String]] {
                orders += order
            }
            var orderKeys : [String] = []
            if let keys = UserDefaults.standard.object(forKey: "preorderKeys") as? [String] {
                orderKeys += keys
            }
            let fileManager = FileManager.default
            var path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first
            let name = pathName.count > 0 ? pathName : "\(Date().timeIntervalSince1970)"
            if pathName != name {
                orderKeys.insert(name, at: 0)
            }
            path = path! + "/\(name)"
            do{
                if pathName == name {
                    try fileManager.removeItem(atPath: path!)
                }
                try fileManager.createDirectory(atPath:path! , withIntermediateDirectories: true, attributes: nil)
                var imageStr = ""
                for (key , value) in images {
                    imageStr += "\(key),"
                    let result = fileManager.createFile(atPath: path! + "/\(key).jpg", contents: value, attributes: nil)
                    if !result {
                        print("图片保存失败")
                    }
                }
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                let str = imageStr.count > 0 ? imageStr.substring(to: imageStr.index(before: imageStr.endIndex)) : ""
                if pathName == name {
                    let i = orderKeys.index(of: pathName) ?? 0
                    if i == 0 && orders.count == 0 {
                        var order = [ "mark" : remark , "images" : str , "addtime" : formatter.string(from: Date())]
                        if bSubmitSuccess && orderNo.count > 0 {
                            order["orderNo"] = orderNo
                        }
                        orders.append(order)
                    }else{
                        var order = [ "mark" : remark , "images" : str , "addtime" : formatter.string(from: Date())]
                        if bSubmitSuccess && orderNo.count > 0 {
                            order["orderNo"] = orderNo
                        }
                        orders[i] = order
                    }
                }else{
                    var order = [ "mark" : remark , "images" : str , "addtime" : formatter.string(from: Date())]
                    if bSubmitSuccess && orderNo.count > 0 {
                        order["orderNo"] = orderNo
                    }
                    orders.insert(order, at: 0)
                }
                UserDefaults.standard.set(orders, forKey: "preorders")
                UserDefaults.standard.set(orderKeys, forKey: "preorderKeys")
                UserDefaults.standard.synchronize()
                if let button = sender as? UIButton , button == btnSave {
                    showAlert(title: "温馨提示", message: "保存成功", button: "确定")
                }
                
            }catch{
                if let button = sender as? UIButton , button == btnSave {
                    showAlert(title: "温馨提示", message: "保存失败，数据丢失!", button: "确定")
                }
                
            }
        }else{
            if let button = sender as? UIButton , button == btnSave {
                showAlert(title: "温馨提示", message: "您没有拍摄任何照片，或输入内容！", button: "保存失败")
            }
            
        }
    }
    
    // 显示提示框
    func showAlert(title : String?, message : String , button : String) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: button, style: .cancel, handler: {[weak self] (action) in
            if message == "保存成功" {
                self?.navigationController?.popViewController(animated: true)
            }
        }))
        present(alert, animated: true) {
            
        }
    }
    
    // 提交预评估订单
    @IBAction func submit(_ sender: Any) {
        
        if unfinished {
            NotificationCenter.default.post(name: Notification.Name("app"), object: 14 , userInfo: ["orderNo" : orderNo])
            self.navigationController?.popViewController(animated: true)
            return
        }
        
        tableView.endEditing(true) // 结束编辑
        bSubmit = true
        if !checkoutImage(companyNo: companyNo) {
            self.tableView.reloadData()
            showAlert(title: nil, message: "您还有内容尚未录入，是否返回继续编辑？" , button:"继续编辑")
            return
        }
//        if source == 1 && images.count == 0 {
//            showAlert(title: nil, message: "您没有做任何图片修改，无法提交！" , button:"确定")
//            return
//        }

        if source == 1 {
            orderNo = json?["carBillId"].string ?? ""
            if orderNo.count > 0 {
                if self.images.count > 0 {
                    var arrPictureName : Set<String> = []
                    for key in self.images.keys {
                        arrPictureName.insert("\(key)")
                    }
                    uploadDictpre[orderNo] = arrPictureName
                }
                
                NotificationCenter.default.post(name: Notification.Name("app"), object: 15, userInfo: ["orderNo" : self.orderNo , "images" : self.images, "remark" : remark])
                
                Toast(text: "正在后台上传，稍后请到进度列表中查看").show()
                
                self.navigationController?.popViewController(animated: true)
            }
        }else{
            
            let username = UserDefaults.standard.string(forKey: "username")
            var params = ["createUser" : username!]
            params["carBillType"] = "routine"
            params["mark"] = remark
            params["clientName"] = "iOS"
            let hud = self.showHUD(text: "提交中...")
            NetworkManager.sharedInstall.request(url: submitPre, params: params) {[weak self] (json, error) in
                self?.hideHUD(hud: hud)
                if error != nil {
                    print(error!.localizedDescription)
                }else{
                    if let data = json , data["success"].boolValue {
                        self?.bSubmitSuccess = true
                        self!.orderNo = "\(data["object"].int ?? 0)"
                        var arrPictureName : Set<String> = []
                        for key in self!.images.keys {
                            arrPictureName.insert("\(key)")
                        }
                        uploadDictpre[self!.orderNo] = arrPictureName
                        
                        DispatchQueue.main.async {
                            NotificationCenter.default.post(name: Notification.Name("app"), object: 15, userInfo: ["orderNo" : self!.orderNo , "images" : self!.images])
                        }
                        
                        if self!.pathName.count > 0 {
                            var orderKeys = UserDefaults.standard.object(forKey: "preorderKeys") as! [String]
                            var orders = UserDefaults.standard.object(forKey: "preorders") as! [[String : String]]
                            let i = orderKeys.index(of: self!.pathName) ?? 0
                            if i < orderKeys.count {
                                orderKeys.remove(at: i)
                                orders.remove(at: i)
                            }
                            
                            UserDefaults.standard.set(orderKeys, forKey: "preorderKeys")
                            UserDefaults.standard.set(orders, forKey: "preorders")
                            UserDefaults.standard.synchronize()
                            
                        }
                        self?.navigationController?.popViewController(animated: true)
                        
                    }else{
                        if let message = json?["message"].string {
                            Toast(text: message).show()
                        }
                    }
                }
            }
        }
    }
    
    // 获取水印
    func getWaterMark(tag : Int) {
        weak var hud : MBProgressHUD?
        if tag >= 0 {
            hud = showHUD(text: "加载中...")
        }
        NetworkManager.sharedInstall.requestString(url: operationDesc, params: nil) {[weak self] (json, error) in
            if hud != nil {
                self?.hideHUD(hud: hud!)
            }
            if error != nil {
                print(error!.localizedDescription)
            }else{
                if let data = json?["data"].array {
                    self?.waterMarks += data
                    if tag >= 0 {
                        self?.pushToCamera(tag: tag)
                    }
                }
            }
        }
    }
    
    // 检查公司必传的照片
    func checkoutImage(companyNo : Int) -> Bool {
        if source != 1 {
            if images.count > 0 {
                if companyNo == 0 {
                    let keys = Set<Int>(images.keys)
                    if Set(companyOtherNeed).isSubset(of: keys) {
                        return true
                    }else{
                        return false
                    }
                }
            }
            return false
        }else{
            return true
        }
    }
    
    // MARK: - UITableView DataSource
    func numberOfSections(in tableView: UITableView) -> Int {
        let count = source == 1 ? (sectionTitles.count + 1) : sectionTitles.count
        return count

    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let mSection = source == 1 ? (section - 1) : section
        let max = source == 1 ? 3 : 2
        let min = source == 1 ? 1 : 0
        if section < max && section >= min{
            let count = titles[mSection].count
            return (count % 2 > 0) ? (count / 2 + 1) : (count / 2)
        }else {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let mSection = source == 1 ? (indexPath.section - 1) : indexPath.section
        let max = source == 1 ? 3 : 2
        let min = source == 1 ? 1 : 0
        if indexPath.section < max && indexPath.section >= min {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! DetectionTableViewCell
            cell.vCamera1.layer.cornerRadius = 6.0
            cell.vCamera2.layer.cornerRadius = 6.0
            cell.iv1.layer.cornerRadius = 6.0
            cell.iv2.layer.cornerRadius = 6.0
            cell.iv1.clipsToBounds = true
            cell.iv2.clipsToBounds = true
            cell.lbl11.layer.cornerRadius = 3.0
            cell.lbl22.layer.cornerRadius = 3.0
            cell.indexPath = source == 1 ? (IndexPath(row: indexPath.row, section: indexPath.section - 1)) : indexPath
            cell.delegate = self
            cell.source = source
            let c = titles[mSection].count
            let count = titles[mSection].count
            if count % 2 > 0 && indexPath.row == count / 2 {
                cell.vCamera2.isHidden = true
            }else{
                cell.vCamera2.isHidden = false
            }
            if indexPath.row * 2 < c {
                cell.lbl1.text = titles[mSection][indexPath.row * 2]
                cell.lbl11.text = titles[mSection][indexPath.row * 2]
            }
            if indexPath.row * 2 + 1 < c {
                cell.lbl2.text = titles[mSection][(indexPath.row * 2 + 1) % titles[mSection].count]
                cell.lbl22.text = titles[mSection][(indexPath.row * 2 + 1) % titles[mSection].count]
            }
            cell.iv11.image = UIImage(named: indexPath.row * 2 < count - 1 ? "icon_camera" : "icon_add_photo")
            cell.iv21.image = UIImage(named: indexPath.row * 2 + 1 < count - 1 ? "icon_camera" : "icon_add_photo")
            cell.vCamera1.layer.borderWidth = 0.5
            cell.vCamera2.layer.borderWidth = 0.5
            if source == 1 {
                var bTem = false
                if images.count > 0 {
                    if let data = images[mSection * 1000 + indexPath.row] {
                        cell.iv1.image = UIImage(data: data)
                        bTem = true
                    }
                }
                if !bTem {
                    for  json in arrImageInfo {
                        if json["imageClass"].string == titlesImageClass[mSection][indexPath.row * 2] {
                            cell.iv1.sd_setImage(with: URL(string: "\(NetworkManager.sharedInstall.domain)\(json["imageThumbPath"].stringValue)")!)
                            bTem = true
                        }
                    }
                }
                if bTem {
                    cell.lbl11.isHidden = false
                    cell.lbl1.isHidden = true
                    cell.iv11.isHidden = true
                    cell.vCamera1.layer.borderColor = UIColor(red: 230/255.0, green: 230/255.0, blue: 230/255.0, alpha: 1).cgColor
                }else{
                    cell.iv1.image = nil
                    cell.lbl1.isHidden = false
                    cell.iv11.isHidden = false
                    cell.lbl11.isHidden = true
                    cell.vCamera1.layer.borderColor = UIColor(red: 230/255.0, green: 230/255.0, blue: 230/255.0, alpha: 1).cgColor
                }
                
            }else {
                if let data = images[mSection * 1000 + indexPath.row] {
                    cell.iv1.image = UIImage(data: data)
                    cell.lbl11.isHidden = false
                    cell.lbl1.isHidden = true
                    cell.iv11.isHidden = true
                    cell.vCamera1.layer.borderColor = UIColor(red: 230/255.0, green: 230/255.0, blue: 230/255.0, alpha: 1).cgColor
                }else{
                    cell.iv1.image = nil
                    cell.lbl1.isHidden = false
                    cell.lbl11.isHidden = true
                    cell.iv11.isHidden = false
                    if bSubmit {
                        if companyNo == 0 {
                            if companyOtherNeed.contains(mSection * 1000 + indexPath.row) {
                                cell.vCamera1.layer.borderColor = UIColor.red.cgColor
                            }else{
                                cell.vCamera1.layer.borderColor = UIColor(red: 230/255.0, green: 230/255.0, blue: 230/255.0, alpha: 1).cgColor
                            }
                        }else{
                            cell.vCamera1.layer.borderColor = UIColor.red.cgColor
                        }
                        
                    }else{
                        cell.vCamera1.layer.borderColor = UIColor(red: 230/255.0, green: 230/255.0, blue: 230/255.0, alpha: 1).cgColor
                    }
                }
            }
            if source == 1 {
                var bTem = false
                if images.count > 0 {
                    if let data = images[mSection * 1000 + indexPath.row + 100] {
                        cell.iv2.image = UIImage(data: data)
                        bTem = true
                    }
                }
                if !bTem {
                    for  json in arrImageInfo {
                        if json["imageClass"].string == titlesImageClass[mSection][indexPath.row + 1] {
                            cell.iv2.sd_setImage(with: URL(string: "\(NetworkManager.sharedInstall.domain)\(json["imageThumbPath"].stringValue)")!)
                            bTem = true
                        }
                    }
                }
                if bTem {
                    cell.lbl2.isHidden = true
                    cell.lbl22.isHidden = false
                    cell.iv21.isHidden = true
                    cell.vCamera2.layer.borderColor = UIColor(red: 230/255.0, green: 230/255.0, blue: 230/255.0, alpha: 1).cgColor
                }else{
                    cell.iv2.image = nil
                    cell.lbl2.isHidden = false
                    cell.lbl22.isHidden = true
                    cell.iv21.isHidden = false
                    cell.vCamera2.layer.borderColor = UIColor(red: 230/255.0, green: 230/255.0, blue: 230/255.0, alpha: 1).cgColor
                }
                
            }else{
                if let data = images[mSection * 1000 + indexPath.row + 100] {
                    cell.iv2.image = UIImage(data: data)
                    cell.lbl2.isHidden = true
                    cell.lbl22.isHidden = false
                    cell.iv21.isHidden = true
                    cell.vCamera2.layer.borderColor = UIColor(red: 230/255.0, green: 230/255.0, blue: 230/255.0, alpha: 1).cgColor
                }else{
                    cell.iv2.image = nil
                    cell.lbl2.isHidden = false
                    cell.lbl22.isHidden = true
                    cell.iv21.isHidden = false
                    if bSubmit {
                        if companyNo == 0 {
                            if companyOtherNeed.contains(mSection * 1000 + indexPath.row + 100) {
                                cell.vCamera2.layer.borderColor = UIColor.red.cgColor
                            }else{
                                cell.vCamera2.layer.borderColor = UIColor(red: 230/255.0, green: 230/255.0, blue: 230/255.0, alpha: 1).cgColor
                            }
                        }else{
                            cell.vCamera2.layer.borderColor = UIColor.red.cgColor
                        }
                    }else{
                        cell.vCamera2.layer.borderColor = UIColor(red: 230/255.0, green: 230/255.0, blue: 230/255.0, alpha: 1).cgColor
                    }
                }
            }
            if unfinished {
                cell.isUserInteractionEnabled = false
            }
            cell.setSubTag()
            return cell
        }else{
            if source == 1 && indexPath.section == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "cell4", for: indexPath) as! Detection4TableViewCell
                cell.contentView.layer.borderWidth = 0.5
                cell.delegate = self
                cell.showWebView(htmlString: json?["applyAllOpinion"].string ?? "")
                cell.contentView.layer.borderColor = UIColor.clear.cgColor
                if unfinished {
                    cell.isUserInteractionEnabled = false
                }
                return cell
            }
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell2", for: indexPath) as! Detection2TableViewCell
            cell.contentView.layer.borderWidth = 0.5
            if source == 1 {
                cell.contentView.layer.borderColor = UIColor(red: 230/255.0, green: 230/255.0, blue: 230/255.0, alpha: 1).cgColor
                cell.tvMark.text = json?["mark"].string
            }else if remark.count == 0 && bSubmit {
                cell.contentView.layer.borderColor = UIColor.red.cgColor
            }else{
                if remark.count > 0 {
                    cell.tvMark.text = remark
                }
                cell.contentView.layer.borderColor = UIColor(red: 230/255.0, green: 230/255.0, blue: 230/255.0, alpha: 1).cgColor
            }
            if unfinished {
                cell.isUserInteractionEnabled = false
            }
            return cell
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 44
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        //let mSection = source == 1 ? (indexPath.section - 1) : indexPath.section
        let max = source == 1 ? 3 : 2
        let min = source == 1 ? 1 : 0
        if indexPath.section < max && indexPath.section >= min {
            return 10 + (WIDTH / 2 - 15) / 3 * 2.0
        }else{
            if source == 1 && indexPath.section == 0 {
                return CGFloat(fWebViewCellHeight + 20)
            }
            return 100
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = tableView.dequeueReusableHeaderFooterView(withIdentifier: "header") as! ReUseHeaderFooterView
        let mSection = source == 1 ? (section - 1) : section
        view.lblTitle.text = source == 1 && section == 0 ? "退回原因" : sectionTitles[mSection]
        return view
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
    // 转场动画
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return presentAnimator
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return dismissAnimator
    }
    
    func getWebViewContentHeight(height: Float) {
        fWebViewCellHeight = height
        tableView.reloadData()
    }
    
    func lookForAttach() {
        
    }

}

