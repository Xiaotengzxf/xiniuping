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

class DetectionNewViewController: UIViewController , UITableViewDataSource , UITableViewDelegate , DetectionTableViewCellDelegate , UIViewControllerTransitioningDelegate , Detection3TableViewCellDelegate, Detection4TableViewCellDelegate {

    @IBOutlet weak var lcBottom: NSLayoutConstraint!
    @IBOutlet weak var btnSave: UIButton!
    @IBOutlet weak var vBottom: UIView!
    @IBOutlet weak var tableView: UITableView!
    let sectionTitles = ["登记证" , "行驶证" , "铭牌" , "车身外观" , "车体骨架" , "车辆内饰" , "差异补充" , "原车保险" , "估价" , "租赁期限(非残值租赁产品就选无租期)", "备注"]
    let titles = [["登记证首页" , "登记证\n车辆信息记录"] , ["行驶证-正本\n副本同照\n[选拍]"] , ["车辆铭牌"] , ["车左前45度" , "前档风玻璃\n[选拍]" , "车右后45度" , "后档风玻璃\n[选拍]"] , ["发动机盖" , "右侧内轨" , "右侧水箱支架" , "左侧内轨" , "左侧水箱支架" , "左前门" , "左前门铰链\n[选拍]" , "左后门\n[选拍]" , "行李箱左侧" , "行李箱右侧" , "行李箱左后底板" , "行李箱右后底板" , "右后门\n[选拍]" , "右前门" , "右前门铰链\n[选拍]"] ,["方向盘及仪表" , "中央控制面板\n[选拍]" , "中控台含挡位杆" , "后出风口"], ["添加图片"], ["添加图片"]]
    var images : [Int : Data] = [:]
    var imagesPath = "" // 本地如果有缓冲图片，则读取图片
    var imagesFilePath = "" // 本地如果有缓冲图片，则读取图片
    let presentAnimator = PresentAnimator()
    let dismissAnimator = DismisssAnimator()
    let bill = "external/carBill/getCarBillIdNextVal.html"
    let upload = "external/app/uploadAppImage.html"
    let operationDesc = "external/source/operation-desc.json" // 水印和接口说明
    let billImages = "external/app/getAppBillImageList.html"
    let getAttachFiles = "external/app/getAttachFiles.html"
    var orderNo = ""
    var price = ""
    var remark = ""
    var bSubmit = false // 是否点击了提交
    var bSubmitSuccess = false // 是否提交成功
    var companyNo = 0 // 单位代号
    var nTag = 0 // 临时tag
    //var cameraType = 0 // 单拍，连拍
    var waterMarks : [JSON] = []
    let companyOtherNeed : [Int] = [0 , 100 , 1000 , 2000 , 3000 , 3100 , 3001 , 3101 , 4000 , 4100 , 4001 , 4101 , 4002 , 4102 , 4003 , 4103 , 4004 , 4104 , 4005 , 4105 , 4006 , 4106 , 4007 , 5000 , 5100 , 5001 , 5101]
    let companyOptional : [Int] = [1000, 3100, 3101, 4003, 4103, 4006, 4007, 5100]
    //
    var source = 0  // 0 创建新的，1 未通过 ， 2 本地的
    var json : JSON? // 未通过时，获取的数据
    var arrImageInfo : [JSON] = []
    var pathName = ""
    var bSave = false
    var bGuanghui = false
    var leaseTerm = 0 // 租赁
    var fWebViewCellHeight : Float = 100
    var unfinished = false
    var onceOrderId = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UINib(nibName: "ReUseHeaderFooterView", bundle: nil), forHeaderFooterViewReuseIdentifier: "header")
        NotificationCenter.default.addObserver(self, selector: #selector(DetectionNewViewController.handleNotification(notification:)), name: Notification.Name("detectionnew"), object: nil)
        self.edgesForExtendedLayout = UIRectEdge(rawValue: 0)
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "返回", style: .plain, target: nil, action: nil)
        
        if source == 1 {
            let p = json?["preSalePrice"].int ?? 0
            price = p > 0 ? "\(p)" : ""
            remark = json?["mark"].string ?? ""
            loadUnpassData()
        }else {
            getWaterMark(tag: -1)
            
        }
        
        if imagesPath.characters.count > 0 {
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
            if let button = vBottom.viewWithTag(101) as? UIButton {
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
    
    // 拍照类型
//    func setCameraType() {
//        let action = UIAlertController(title: "拍照类型", message: nil, preferredStyle: .actionSheet)
//        action.addAction(UIAlertAction(title: "取消", style: .cancel, handler: { (action) in
//            
//        }))
//        action.addAction(UIAlertAction(title: "单拍", style: .default, handler: {[weak self] (action) in
//            self?.cameraType = 0
//        }))
//        action.addAction(UIAlertAction(title: "连拍", style: .default, handler: {[weak self] (action) in
//            self?.cameraType = 1
//        }))
//    }
    
    // 通知处理
    func handleNotification(notification : Notification) {
        if let tag = notification.object as? Int {
            if tag == 1 {
                if let userInfo = notification.userInfo as? [String : String] {
                    price = userInfo["text"]!
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
//            if companyOtherNeed.contains(tag) {
//                if waterMarks.count > 0{
//                    pushToCamera(tag: tag)
//                }else{
//                    getWaterMark(tag: tag)
//                }
//            }else{
//                let section = tag / 1000
//                //let row = tag % 1000 % 100
//                //let right = tag % 100 >= 100
//                let array = companyOtherNeed.sorted()
//                for value in array {
//                    if value / 1000 == section {
//                        if value < tag {
//                            if images[value] == nil {
//                                self.showAlert(title: nil, message: "请先拍照：\(titles[value / 1000][((value % 1000) % 100) * 2 + (value % 1000 >= 100 ? 1 : 0)])" , button: "确定")
//                                return
//                            }
//                        }
//                    }
//                }
//            }
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

    @IBAction func move(_ sender: Any) {
        if let button = sender as? UIButton {
            switch button.tag {
            case 1:
                tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
            case 2:
                tableView.scrollToRow(at: IndexPath(row: 0, section: 3), at: .top, animated: true)
            case 3:
                tableView.scrollToRow(at: IndexPath(row: 0, section: 4), at: .top, animated: true)
            case 4:
                tableView.scrollToRow(at: IndexPath(row: 0, section: 5), at: .top, animated: true)
            case 5:
                tableView.scrollToRow(at: IndexPath(row: 0, section: 6), at: .top, animated: true)
            default:
                fatalError()
            }
        }
    }
    
    // 保存
    @IBAction func save(_ sender: Any) {
        if source == 1 || unfinished {
            self.navigationController?.popViewController(animated: true)
            return
        }
        bSave = true
        if images.count > 0 || price.characters.count > 0 || remark.characters.count > 0 {
            var orders : [[String : String]] = []
            if let order = UserDefaults.standard.object(forKey: "orders") as? [[String : String]] {
                orders += order
            }
            var orderKeys : [String] = []
            if let keys = UserDefaults.standard.object(forKey: "orderKeys") as? [String] {
                orderKeys += keys
            }
            let fileManager = FileManager.default
            var path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first
            let name = pathName.characters.count > 0 ? pathName : "\(Date().timeIntervalSince1970)"
            orderKeys.insert(name, at: 0)
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
                let str = imageStr.characters.count > 0 ? imageStr.substring(to: imageStr.index(before: imageStr.endIndex)) : ""
                if pathName == name {
                    let i = orderKeys.index(of: pathName) ?? 0
                    if i == 0 && orders.count == 0 {
                        var order = ["preSalePrice" : self.price , "mark" : remark ,"leaseTerm" : "\(self.leaseTerm)" , "images" : str , "addtime" : formatter.string(from: Date())]
                        if bSubmitSuccess && orderNo.characters.count > 0 {
                            order["orderNo"] = orderNo
                        }
                        orders.append(order)
                    }else{
                        var order = ["preSalePrice" : self.price , "mark" : remark ,"leaseTerm" : "\(self.leaseTerm)" , "images" : str , "addtime" : formatter.string(from: Date())]
                        if bSubmitSuccess && orderNo.characters.count > 0 {
                            order["orderNo"] = orderNo
                        }
                        orders[i] = order
                    }
                }else{
                    var order = ["preSalePrice" : self.price , "mark" : remark ,"leaseTerm" : "\(self.leaseTerm)" , "images" : str , "addtime" : formatter.string(from: Date())]
                    if bSubmitSuccess && orderNo.characters.count > 0 {
                        order["orderNo"] = orderNo
                    }
                    orders.insert(order, at: 0)
                }
                UserDefaults.standard.set(orders, forKey: "orders")
                UserDefaults.standard.set(orderKeys, forKey: "orderKeys")
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
                showAlert(title: "温馨提示", message: "您没有拍摄任何照片，或输入价格，或输入内容！", button: "保存失败")
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
    
    // 提交订单
    @IBAction func submit(_ sender: Any) {
        if unfinished {
            NotificationCenter.default.post(name: Notification.Name("app"), object: 4 , userInfo: ["orderNo" : onceOrderId])
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
        if source == 1 && images.count == 0 {
            showAlert(title: nil, message: "您没有做任何图片修改，无法提交！" , button:"确定")
            return
        }
        if price.characters.count == 0 {
            Toast(text : "请输入预售价格").show()
            return
        }
        if source == 1 {
            orderNo = json?["carBillId"].string ?? ""
            if orderNo.characters.count > 0 {
                var arrPictureName : Set<String> = []
                for key in self.images.keys {
                    arrPictureName.insert("\(key)")
                }
                uploadDict[orderNo] = arrPictureName
                
                NotificationCenter.default.post(name: Notification.Name("app"), object: 5, userInfo: ["orderNo" : self.orderNo , "images" : self.images])
                NotificationCenter.default.post(name: Notification.Name("app"), object: 1, userInfo: ["orderNo" : self.orderNo , "price" : self.price , "remark" : self.remark, "leaseTerm" : "\(self.leaseTerm)", "source" : "1"])
                self.navigationController?.popViewController(animated: true)
            }
        }else{
            let hud = self.showHUD(text: "创建中...")
            NetworkManager.sharedInstall.request(url: bill, params: nil) {[weak self] (json, error) in
                self?.hideHUD(hud: hud)
                if error != nil {
                    Toast(text: "网络故障，请检查网络").show()
                }else{
                    self!.bSubmitSuccess = true
                    if let data = json {
                        self?.orderNo = data.stringValue
                        var arrPictureName : Set<String> = []
                        for key in self!.images.keys {
                            arrPictureName.insert("\(key)")
                        }
                        uploadDict[self!.orderNo] = arrPictureName
                        
                        DispatchQueue.main.async {
                            NotificationCenter.default.post(name: Notification.Name("app"), object: 5, userInfo: ["orderNo" : self!.orderNo , "images" : self!.images])
                            NotificationCenter.default.post(name: Notification.Name("app"), object: 1, userInfo: ["orderNo" : self!.orderNo , "price" : self!.price , "remark" : self!.remark, "leaseTerm" : "\(self!.leaseTerm)"])
                        }
                        if self!.pathName.characters.count > 0 {
                            var orderKeys = UserDefaults.standard.object(forKey: "orderKeys") as! [String]
                            var orders = UserDefaults.standard.object(forKey: "orders") as! [[String : String]]
                            let i = orderKeys.index(of: self!.pathName) ?? 0
                            if i < orderKeys.count {
                                orderKeys.remove(at: i)
                                orders.remove(at: i)
                            }
                            
                            UserDefaults.standard.set(orderKeys, forKey: "orderKeys")
                            UserDefaults.standard.set(orders, forKey: "orders")
                            UserDefaults.standard.synchronize()

                        }
                        self?.navigationController?.popViewController(animated: true)
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
                    let array = Set(companyOtherNeed).subtracting(Set(companyOptional))
                    if array.isSubset(of: keys) {
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
        var count = 0
        if bGuanghui {
            count = sectionTitles.count
        }else{
            count = sectionTitles.count - 1
        }
        if source == 1 {
            count += 1
        }
        return count
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let nMin = source == 1 ? 1 : 0
        let nMax = source == 1 ? 9 : 8
        if section < nMax && section >= nMin {
            let nSection = source==1 ? section - 1 : section
            var count = titles[nSection].count + 1
            if images.count > 0 {
                let array = images.keys.filter{$0 >= nSection * 1000 && $0 < (nSection + 1) * 1000}
                let array1 = companyOtherNeed.filter{$0 >= nSection * 1000 && $0 < (nSection + 1) * 1000}
                var n = 0
                for key in array {
                    if !array1.contains(key) {
                        n += 1
                    }
                }
                if n > 0 {
                    n += 1
                }
                count = max(count, array1.count + n)
            }
            return (count % 2 > 0) ? (count / 2 + 1) : (count / 2)
        }else {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let nMin = source == 1 ? 1 : 0
        let nMax = source == 1 ? 9 : 8
        if indexPath.section < nMax && indexPath.section >= nMin {
            let nSection = source==1 ? indexPath.section - 1 : indexPath.section
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! DetectionTableViewCell
            cell.vCamera1.layer.cornerRadius = 6.0
            cell.vCamera2.layer.cornerRadius = 6.0
            cell.iv1.layer.cornerRadius = 6.0
            cell.iv2.layer.cornerRadius = 6.0
            cell.iv1.clipsToBounds = true
            cell.iv2.clipsToBounds = true
            cell.lbl11.layer.cornerRadius = 3.0
            cell.lbl22.layer.cornerRadius = 3.0
            cell.indexPath = IndexPath(row: indexPath.row, section: nSection)
            cell.delegate = self
            cell.source = source
            cell.setSubTag()
            let c = titles[nSection].count
            var count = titles[nSection].count + 1
            if nSection == 6 || nSection == 7 {
                count -= 1
            }
            if images.count > 0 {
                let array = images.keys.filter{$0 >= nSection * 1000 && $0 < (nSection + 1) * 1000}
                let array1 = companyOtherNeed.filter{$0 >= nSection * 1000 && $0 < (nSection + 1) * 1000}
                var n = 0
                for key in array {
                    if !array1.contains(key) {
                        n += 1
                    }
                }
                if n > 0 {
                    n += 1
                }
                count = max(count, array1.count + n)
            }
            if count % 2 > 0 && indexPath.row == count / 2 {
                cell.vCamera2.isHidden = true
            }else{
                cell.vCamera2.isHidden = false
            }
            if indexPath.row * 2 < c {
                cell.lbl1.text = titles[nSection][indexPath.row * 2]
                cell.lbl11.text = titles[nSection][indexPath.row * 2]
            }else{
                cell.lbl1.text = "添加照片"
                cell.lbl11.text = "添加照片"
            }
            if indexPath.row * 2 + 1 < c {
                cell.lbl2.text = titles[nSection][(indexPath.row * 2 + 1) % titles[nSection].count]
                cell.lbl22.text = titles[nSection][(indexPath.row * 2 + 1) % titles[nSection].count]
            }else{
                cell.lbl2.text = "添加照片"
                cell.lbl22.text = "添加照片"
            }
            cell.iv11.image = UIImage(named: indexPath.row * 2 < count - 1 ? "icon_camera" : "icon_add_photo")
            cell.iv21.image = UIImage(named: indexPath.row * 2 + 1 < count - 1 ? "icon_camera" : "icon_add_photo")
            cell.vCamera1.layer.borderWidth = 0.5
            cell.vCamera2.layer.borderWidth = 0.5
            if source == 1 {
                var bTem = false
                if images.count > 0 {
                    if let data = images[nSection * 1000 + indexPath.row] {
                        cell.iv1.image = UIImage(data: data)
                        bTem = true
                    }
                }
                if !bTem {
                    for  json in arrImageInfo {
                        if json["imageClass"].string == sectionTitles[nSection] {
                            if json["imageSeqNum"].intValue == indexPath.row * 2 {
                                cell.iv1.sd_setImage(with: URL(string: "\(NetworkManager.sharedInstall.domain)\(json["imageThumbPath"].stringValue)")!)
                                bTem = true
                            }
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
                if let data = images[nSection * 1000 + indexPath.row] {
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
                            if companyOtherNeed.contains(nSection * 1000 + indexPath.row) {
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
            if companyOptional.contains(nSection * 1000 + indexPath.row) {
                cell.vCamera1.layer.borderColor = UIColor.green.cgColor
                cell.lbl1.textColor = UIColor.green
            }else{
                cell.lbl1.textColor = UIColor(red: 107/255.0, green: 107/255.0, blue: 107/255.0, alpha: 1)
            }
            if source == 1 {
                var bTem = false
                if images.count > 0 {
                    if let data = images[nSection * 1000 + indexPath.row + 100] {
                        cell.iv2.image = UIImage(data: data)
                        bTem = true
                    }
                }
                if !bTem {
                    for  json in arrImageInfo {
                        if json["imageClass"].string == sectionTitles[nSection] {
                            if json["imageSeqNum"].intValue == indexPath.row * 2 + 1 {
                                cell.iv2.sd_setImage(with: URL(string: "\(NetworkManager.sharedInstall.domain)\(json["imageThumbPath"].stringValue)")!)
                                bTem = true
                            }
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
                if let data = images[nSection * 1000 + indexPath.row + 100] {
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
                            if companyOtherNeed.contains(nSection * 1000 + indexPath.row + 100) {
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
            if companyOptional.contains(nSection * 1000 + indexPath.row + 100) {
                cell.vCamera2.layer.borderColor = UIColor.green.cgColor
                cell.lbl2.textColor = UIColor.green
            }else{
                cell.lbl2.textColor = UIColor(red: 107/255.0, green: 107/255.0, blue: 107/255.0, alpha: 1)
            }
            if unfinished {
                cell.isUserInteractionEnabled = false
            }
            return cell
        }else if indexPath.section == nMax {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell1", for: indexPath) as! Detection1TableViewCell
            cell.contentView.layer.borderWidth = 0.5
            if source == 1 {
                cell.contentView.layer.borderColor = UIColor(red: 230/255.0, green: 230/255.0, blue: 230/255.0, alpha: 1).cgColor
                cell.tfPrice.text = "\(json?["preSalePrice"].int ?? 0)"
            }else if price.characters.count == 0 && bSubmit {
                cell.contentView.layer.borderColor = UIColor.red.cgColor
            }else{
                if price.characters.count > 0 {
                    cell.tfPrice.text = price
                }
                cell.contentView.layer.borderColor = UIColor(red: 230/255.0, green: 230/255.0, blue: 230/255.0, alpha: 1).cgColor
            }
            if unfinished {
                cell.isUserInteractionEnabled = false
            }
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
            if bGuanghui {
                if indexPath.section == nMax + 1 {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "cell3", for: indexPath) as! Detection3TableViewCell
                    cell.contentView.layer.borderWidth = 0.5
                    cell.delegate = self
                    if leaseTerm == 0 {
                        leaseTerm = json?["leaseTerm"].int ?? 0
                    }
                    if leaseTerm == 0 {
                        leaseTerm =  Int(json?["leaseTerm"].string ?? "0")!
                    }
                    cell.btn1.isSelected = (leaseTerm == 0)
                    cell.btn2.isSelected = (leaseTerm == 12)
                    cell.btn3.isSelected = (leaseTerm == 24)
                    cell.btn4.isSelected = (leaseTerm == 36)
                    cell.contentView.layer.borderColor = UIColor.clear.cgColor
                    if unfinished {
                        cell.isUserInteractionEnabled = false
                    }
                    return cell
                }else {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "cell2", for: indexPath) as! Detection2TableViewCell
                    cell.contentView.layer.borderWidth = 0.5
                    if source == 1 {
                        cell.contentView.layer.borderColor = UIColor(red: 230/255.0, green: 230/255.0, blue: 230/255.0, alpha: 1).cgColor
                        cell.tvMark.text = json?["mark"].string
                    }else if remark.characters.count == 0 && bSubmit {
                        cell.contentView.layer.borderColor = UIColor.red.cgColor
                    }else{
                        if remark.characters.count > 0 {
                            cell.tvMark.text = remark
                        }
                        cell.contentView.layer.borderColor = UIColor(red: 230/255.0, green: 230/255.0, blue: 230/255.0, alpha: 1).cgColor
                    }
                    if unfinished {
                        cell.isUserInteractionEnabled = false
                    }
                    return cell
                }
            }else{
                let cell = tableView.dequeueReusableCell(withIdentifier: "cell2", for: indexPath) as! Detection2TableViewCell
                cell.contentView.layer.borderWidth = 0.5
                if source == 1 {
                    cell.contentView.layer.borderColor = UIColor(red: 230/255.0, green: 230/255.0, blue: 230/255.0, alpha: 1).cgColor
                    cell.tvMark.text = json?["mark"].string
                }else if remark.characters.count == 0 && bSubmit {
                    cell.contentView.layer.borderColor = UIColor.red.cgColor
                }else{
                    if remark.characters.count > 0 {
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
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 44
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let nMin = source == 1 ? 1 : 0
        let nMax = source == 1 ? 9 : 8
        if indexPath.section < nMax && indexPath.section >= nMin {
            return 10 + (WIDTH / 2 - 15) / 3 * 2.0
        }else if indexPath.section == nMax {
            return 44
        }else{
            if source == 1 && indexPath.section == 0 {
                return CGFloat(fWebViewCellHeight + 20)
            }
            if bGuanghui {
                if indexPath.section == nMax + 1 {
                    return 60
                }else{
                    return 100
                }
            }else{
                return 100
            }
            
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = tableView.dequeueReusableHeaderFooterView(withIdentifier: "header") as! ReUseHeaderFooterView
        let nMin = source == 1 ? 1 : 0
        let nMax = source == 1 ? 9 : 8
        let nSection = source==1 ? section - 1 : section
        if section < nMax && section >= nMin {
            view.lblTitle.text = sectionTitles[nSection]
        }else if section == nMax {
            view.lblTitle.text = sectionTitles[nSection]
        }else{
            if source == 1 && section == 0 {
                view.lblTitle.text = "退回原因"
            }else{
                if bGuanghui {
                    view.lblTitle.text = sectionTitles[nSection]
                }else{
                    view.lblTitle.text = sectionTitles[nSection + 1]
                }
            }
            
        }
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
    
    // Detection3TableViewCellDelegate
    func selectedItem(tag: Int) {
        switch tag {
        case 0:
            leaseTerm = 0
        case 1:
            leaseTerm = 12
        case 2:
            leaseTerm = 24
        default:
            leaseTerm = 36
        }
        tableView.reloadData()
    }
    
    func getWebViewContentHeight(height: Float) {
        fWebViewCellHeight = height
        tableView.reloadData()
    }
    
    func lookForAttach() {
        if let controller = self.storyboard?.instantiateViewController(withIdentifier: "FileAttachViewController") as? FileAttachViewController {
            controller.carId = json!["carBillId"].stringValue
            controller.status = "23,33,43,53"
            self.navigationController?.pushViewController(controller, animated: true)
        }
    }
    
}
