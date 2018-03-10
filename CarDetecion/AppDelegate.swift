//
//  AppDelegate.swift
//  CarDetecion
//
//  Created by 张晓飞 on 2017/3/6.
//  Copyright © 2017年 inewhome. All rights reserved.
//

import UIKit
import CoreData
import IQKeyboardManagerSwift
import Toaster

var uploadDictCount : [String: Int] = [:]
var uploadDict : [String : Set<String>] = [:]
var uploadDictpre : [String : Set<String>] = [:]
var orderNos : [String] = []

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate , JPUSHRegisterDelegate {

    var window: UIWindow?
    var orderInfo : [String : [String : String]] = [:]
    let createBill = "external/app/finishCreateAppCarBill.html"
    let upload = "external/app/uploadAppImage.html"
    let sectionTitles = ["登记证" , "行驶证" , "铭牌" , "车身外观" , "车体骨架" , "车辆内饰" , "差异补充" , "原车保险" , "估价" , "租赁期限(非残值租赁产品就选无租期)", "备注"]
    let sectionTitlespre = ["基础照片" , "补充照片" , "备注"]
    let titlesImageClass = [["登记证" , "车辆内饰" , "车身外观"] , ["行驶证" , "车体骨架"]]
    let titlesImageSeqNum = [[0, 2, 0], [0, 5]]
    let uploadPre = "external/app/addAppPreCarImage.html"

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        if let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first?.appending("/upload.data") {
            if FileManager.default.fileExists(atPath: path) {
                let data = NSData(contentsOfFile: path)
                let unachiver = NSKeyedUnarchiver(forReadingWith: data! as Data)
                if let dict = unachiver.decodeObject(forKey: "upload") as? NSDictionary {
                    if let upload = dict as? [String : Set<String>] {
                        uploadDict = upload
                    }
                }
                
            }
        }
        
        if let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first?.appending("/uploadpre.data") {
            if FileManager.default.fileExists(atPath: path) {
                let data = NSData(contentsOfFile: path)
                let unachiver = NSKeyedUnarchiver(forReadingWith: data! as Data)
                if let dict = unachiver.decodeObject(forKey: "uploadpre") as? NSDictionary {
                    if let upload = dict as? [String : Set<String>] {
                        uploadDictpre = upload
                    }
                }
                
            }
        }
        
        isBadOrderAll()
        
        if let dicOrderInfo = UserDefaults.standard.object(forKey: "orderInfo") as? [String : [String : String]] {
            orderInfo = dicOrderInfo
        }
        
        if let uploadDicCount = UserDefaults.standard.object(forKey: "uploadDictCount") as? [String : Int] {
            uploadDictCount = uploadDicCount
        }
        
        Bugly.start(withAppId: "2304f83592") // 腾讯Bugly接入
        
        UITabBarItem.appearance().setTitleTextAttributes([NSForegroundColorAttributeName : UIColor(red: 66/255.0, green: 83/255.0, blue: 90/255.0, alpha: 1)], for: .normal)
        UITabBarItem.appearance().setTitleTextAttributes([NSForegroundColorAttributeName : UIColor(red: 0/255.0, green: 120/255.0, blue: 201/255.0, alpha: 1)], for: .selected)
        
        application.setStatusBarStyle(.lightContent, animated: true)
        
        IQKeyboardManager.sharedManager().enable = true
        
        if let username = UserDefaults.standard.object(forKey: "username") as? String {
            print("当前登录用户：\(username)")
        }else{
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let login = storyboard.instantiateViewController(withIdentifier: "login")
            window?.rootViewController = login
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.handleNotification(notification:)), name: Notification.Name("app"), object: nil)
        
        let option = HOptions()
        option.appkey = "1112170506115622#kefuchannelapp41042"
        option.tenantId = "41042"
        //option.apnsCertName = ""
        let initError = HChatClient.shared().initializeSDK(with: option)
        if initError != nil {
            print("环信客服初始化失败")
        }
        
        // 通知注册实体类
        let entity = JPUSHRegisterEntity()
        entity.types = Int(JPAuthorizationOptions.alert.rawValue) |  Int(JPAuthorizationOptions.sound.rawValue) |  Int(JPAuthorizationOptions.badge.rawValue)
        JPUSHService.register(forRemoteNotificationConfig: entity, delegate: self)
        // 注册极光推送
        JPUSHService.setup(withOption: launchOptions, appKey: "0cc682f084991254e7b0dd7a", channel:"Publish channel" , apsForProduction: true)
        // 获取推送消息
        let remote = launchOptions?[UIApplicationLaunchOptionsKey.remoteNotification] as? Dictionary<String,Any>;
        // 如果remote不为空，就代表应用在未打开的时候收到了推送消息
        if remote != nil {
            // 收到推送消息实现的方法
            self.perform(#selector(receivePush), with: remote, afterDelay: 1.0);
        }
        
        if let username = UserDefaults.standard.object(forKey: "username") as? String {
            JPUSHService.setAlias(username, callbackSelector: nil, object: nil)
        }
        
        application.applicationIconBadgeNumber = 0
        /*
        
        */
        UIToolbar.appearance().alpha = 1
        UIToolbar.appearance().tintColor = UIColor.black
        
        return true
    }
    
    
    // MARK: -JPUSHRegisterDelegate
    // iOS 10.x 需要
    
    @available(iOS 10.0, *)
    func jpushNotificationCenter(_ center: UNUserNotificationCenter!, willPresent notification: UNNotification!, withCompletionHandler completionHandler: ((Int) -> Void)!) {
        
        let userInfo = notification.request.content.userInfo;
        if notification.request.trigger is UNPushNotificationTrigger {
            JPUSHService.handleRemoteNotification(userInfo);
        }
        completionHandler(Int(UNNotificationPresentationOptions.alert.rawValue))
    }
    
    @available(iOS 10.0, *)
    func jpushNotificationCenter(_ center: UNUserNotificationCenter!, didReceive response: UNNotificationResponse!, withCompletionHandler completionHandler: (() -> Void)!) {
        
        let userInfo = response.notification.request.content.userInfo;
        if response.notification.request.trigger is UNPushNotificationTrigger {
            JPUSHService.handleRemoteNotification(userInfo);
        }
        completionHandler();
        // 应用打开的时候收到推送消息
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
        JPUSHService.handleRemoteNotification(userInfo);
        completionHandler(UIBackgroundFetchResult.newData);
    }
    
    // 接收到推送实现的方法
    func receivePush(_ userInfo : Dictionary<String,Any>) {
        // 角标变0
        UIApplication.shared.applicationIconBadgeNumber = 0
        // 剩下的根据需要自定义
    }

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        JPUSHService.registerDeviceToken(deviceToken)
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("apns fail:\(error.localizedDescription)")
    }
    

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        
        if let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first?.appending("/upload.data") {
            let dict = NSMutableDictionary(dictionary: uploadDict)
            let data = NSMutableData()
            let archiver = NSKeyedArchiver(forWritingWith: data)
            archiver.encode(dict, forKey: "upload")
            archiver.finishEncoding()
            let bValue = data.write(toFile: path, atomically: true)
            if !bValue {
                print("写入失败")
            }
        }
        
        if let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first?.appending("/uploadpre.data") {
            let dict = NSMutableDictionary(dictionary: uploadDictpre)
            let data = NSMutableData()
            let archiver = NSKeyedArchiver(forWritingWith: data)
            archiver.encode(dict, forKey: "uploadpre")
            archiver.finishEncoding()
            let bValue = data.write(toFile: path, atomically: true)
            if !bValue {
                print("写入失败")
            }
        }
        
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        application.applicationIconBadgeNumber = 0
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        if #available(iOS 10.0, *) {
            self.saveContext()
        } else {
            // Fallback on earlier versions
        }
    }

    // MARK: - Core Data stack

    @available(iOS 10.0, *)
    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentContainer(name: "CarDetecion")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                 
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support
    @available(iOS 10.0, *)
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

    // 处理通知
    func handleNotification(notification : Notification) {
        if let tag = notification.object as? Int {
            if tag == 1 {
                if let userinfo = notification.userInfo as? [String : String] {
                    orderInfo[userinfo["orderNo"]!] = ["price" : userinfo["price"]! , "remark" : userinfo["remark"]!, "leaseTerm" : userinfo["leaseTerm"]!]
                    UserDefaults.standard.set(orderInfo, forKey: "orderInfo")
                    UserDefaults.standard.synchronize()
                    self.perform(#selector(AppDelegate.showAlertView(userinfo:)), with: userinfo, afterDelay: 0.1)
                }
            }else if tag == 2 {
                if let userinfo = notification.userInfo as? [String : String] {
                    submitBill(orderNo: userinfo["orderNo"] ?? "")
                }
            }else if tag == 4 {
                if let userinfo = notification.userInfo as? [String : String] {
                    reuploadOrder(oldOrderNo: userinfo["orderNo"] ?? "")
                    self.perform(#selector(AppDelegate.showAlertView(userinfo:)), with: userinfo, afterDelay: 0.1)
                }
                
            }else if tag == 5 {
                if let userinfo = notification.userInfo as? [String : Any] {
                    if let orderNo = userinfo["orderNo"] as? String {
                        if let images = userinfo["images"] as? [Int : Data] {
                            let keys  = images.keys
                            uploadDictCount[orderNo] = keys.count
                            UserDefaults.standard.set(uploadDictCount, forKey: "uploadDictCount")
                            UserDefaults.standard.synchronize()
                            self.uploadImageQueue(i: 0, keys: keys, images: images, orderNo: orderNo)
                        }
                    }
                }
                
            }else if tag == 6 {
                if let userinfo = notification.userInfo as? [String : Any] {
                    if let orderNo = userinfo["orderNo"] as? String {
                        self.submitBill(orderNo: orderNo)
                    }
                }
                
            }else if tag == 15 {
                if let userinfo = notification.userInfo as? [String : Any] {
                    if let orderNo = userinfo["orderNo"] as? String {
                        if let images = userinfo["images"] as? [Int : Data] {
                            if images.count > 0 {
                                let keys  = images.keys
                                self.uploadImageQueuepre(i: 0, keys: keys, images: images, orderNo: orderNo)
                            }else{
                                self.perform(#selector(self.showToast(orderNo:)), with: orderNo, afterDelay: 1)
                            }
                        }
                    }
                }
                
            }else if tag == 14 {
                if let userinfo = notification.userInfo as? [String : String] {
                    reuploadOrderpre(oldOrderNo: userinfo["orderNo"] ?? "")
                    self.perform(#selector(AppDelegate.showAlertView(userinfo:)), with: userinfo, afterDelay: 0.1)
                }
                
            }
        }
    }
    
    func showToast(orderNo: String) {
        Toast(text: "\(orderNo)上传成功").show()
    }
    
    func showAlertView(userinfo : [String : String]) {
        if let source = userinfo["source"], source == "1" {
            Toast(text: "\(userinfo["orderNo"]!)正在上传中").show()
        }else{
            Toast(text: "\(userinfo["orderNo"]!)正在上传中，请在“未提交”中查看进度").show()
        }
        
    }
    
    // 标志订单提交失败
    func isBadOrder(orderNo : String) {
        if orderNo.characters.count > 0 {
            var orders = UserDefaults.standard.object(forKey: "orders") as! [[String : String]]
            var i = 0
            for (index , order) in orders.enumerated() {
                if order["orderNo"] == orderNo {
                    i = index
                    break
                }
            }
            if i < orders.count {
                var order = orders[i]
                order["unfinished"] = "1"
                orders[i] = order
            }
            UserDefaults.standard.set(orders, forKey: "orders")
            UserDefaults.standard.synchronize()
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: Notification.Name("recordVC"), object: nil)
            }
        }
    }
    
    // 标志预评估订单提交失败
    func isBadOrderpre(orderNo : String) {
        if orderNo.characters.count > 0 {
            var preorders = UserDefaults.standard.object(forKey: "preorders") as! [[String : String]]
            var i = 0
            for (index , order) in preorders.enumerated() {
                if order["orderNo"] == orderNo {
                    i = index
                    break
                }
            }
            if i < preorders.count {
                var order = preorders[i]
                order["unfinished"] = "1"
                preorders[i] = order
            }
            UserDefaults.standard.set(preorders, forKey: "preorders")
            UserDefaults.standard.synchronize()
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: Notification.Name("predetection"), object: 1)
            }
        }
    }
    
    func isBadOrderAll() {
        if var orders = UserDefaults.standard.object(forKey: "orders") as? [[String : String]] {
            if orders.count > 0 {
                for (index , order) in orders.enumerated() {
                    var orderT = order
                    orderT["unfinished"] = "1"
                    orders[index] = orderT
                }
                
                UserDefaults.standard.set(orders, forKey: "orders")
                UserDefaults.standard.synchronize()
            }
        }
        
        if var orders = UserDefaults.standard.object(forKey: "preorders") as? [[String : String]] {
            if orders.count > 0 {
                for (index , order) in orders.enumerated() {
                    var orderT = order
                    orderT["unfinished"] = "1"
                    orders[index] = orderT
                }
                
                UserDefaults.standard.set(orders, forKey: "preorders")
                UserDefaults.standard.synchronize()
            }
        }
    }
    
    
    // 提交订单
    func submitBill(orderNo : String)  {
        if orderNo.characters.count > 0 {
            DispatchQueue.global().async {
                [weak self] in
                let username = UserDefaults.standard.string(forKey: "username")
                var params = ["userName" : username!]
                params["carBillId"] = orderNo
                params["clientName"] = "iOS"
                params["preSalePrice"] = self?.orderInfo[orderNo]?["price"] ?? "0"
                let mark = self?.orderInfo[orderNo]?["remark"] ?? ""
                //mark = mark.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
                params["mark"] = mark
                params["leaseTerm"] = self?.orderInfo[orderNo]?["leaseTerm"] ?? "0"
                NetworkManager.sharedInstall.request(url: self!.createBill, params: params) {(json, error) in
                    if error != nil {
                        print(error!.localizedDescription)
                        self?.showAlert(title: "温馨提示", message: "评估单：\(orderNo)，提交失败；原因：\(error!.localizedDescription)", button: "确认")
                    }else{
                        if let data = json , data["success"].boolValue {
                            self?.showAlert(title: "温馨提示", message: "评估单：\(orderNo)提交成功，请在“审核中“查看进度", button: "确认")
                            
                            if var orders = UserDefaults.standard.object(forKey: "orders") as? [[String : String]] {
                                var orderKeys = UserDefaults.standard.object(forKey: "orderKeys") as! [String]
                                
                                var i = 0
                                for (index , order) in orders.enumerated() {
                                    if order["orderNo"] == orderNo {
                                        i = index
                                        break
                                    }
                                }
                                if i < orders.count {
                                    let fileName = orderKeys[i]
                                    self?.removeDir(fileName: fileName)
                                    orderKeys.remove(at: i)
                                    orders.remove(at: i)
                                    print("已删除：\(orderNo)")
                                }
                                
                                UserDefaults.standard.set(orderKeys, forKey: "orderKeys")
                                UserDefaults.standard.set(orders, forKey: "orders")
                                UserDefaults.standard.synchronize()
                            }
                            
                            DispatchQueue.main.async {
                                NotificationCenter.default.post(name: Notification.Name("recordVC"), object: nil)
                            }
                            
                        }else{
                            if let message = json?["message"].string {
                                self?.showAlert(title: "温馨提示", message: "评估单：\(orderNo)，提交失败；原因：\(message)", button: "确认")
                            }
                        }
                    }
                }
            }
        }
    }
    
    // 显示提示框
    func showAlert(title : String?, message : String , button : String) {
        DispatchQueue.main.async {
            Toast(text: message).show()
        }
//        let deadlineTime = DispatchTime.now() + .seconds(1)
//        DispatchQueue.main.asyncAfter(deadline: deadlineTime) {
//            [weak self] in
//            let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
//            alert.addAction(UIAlertAction(title: button, style: .cancel, handler: { (action) in
//                
//            }))
//            self?.window?.rootViewController?.present(alert, animated: true) {
//                
//            }
//        }
    }
    
    // 上传图片
    func uploadImageQueue(i : Int, keys: LazyMapCollection<Dictionary<Int, Data>, Int>, orderNo: String, images : [Int : Data]){
        guard let _ = UserDefaults.standard.object(forKey: "userinfo") else {
            return
        }
        if i == keys.count {
            if orderNos.contains(orderNo) {
                for (m , strOrderNo) in orderNos.enumerated() {
                    if strOrderNo == orderNo {
                        orderNos.remove(at: m)
                        break
                    }
                }
            }
            return
        }
        
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: Notification.Name("recordVC"), object: nil)
        }
        
        let key = keys[keys.index(keys.startIndex, offsetBy: i)]
        let value = images[key]!
        
        let section = key / 1000
        let row = (key % 1000) % 100
        let right = key % 1000 >= 100
        
        let username = UserDefaults.standard.string(forKey: "username")
        var params = ["createUser" : username!]
        params["clientName"] = "iOS"
        params["carBillId"] = orderNo
        params["imageClass"] = self.sectionTitles[section]
        params["imageSeqNum"] = "\(row * 2 + (right ? 1 : 0))"
        NetworkManager.sharedInstall.upload(url: upload, params: params, data: value) {[weak self] (json, error) in
            DispatchQueue.global().async {
                if json?["success"].boolValue == true {
                    
                    var arr : Set<String> = uploadDict[orderNo] ?? []
                    arr.remove("\(key)")
                    uploadDict[orderNo] = arr
                    if arr.count == 0 {
                        uploadDict.removeValue(forKey: orderNo)
                        DispatchQueue.main.async {
                            NotificationCenter.default.post(name: Notification.Name("app"), object: 2 , userInfo: ["orderNo" : params["carBillId"]!])
                        }
                    }
                    self?.uploadImageQueue(i: i+1, keys: keys, orderNo: orderNo, images: images)
                }else{
                    if !orderNos.contains(orderNo) {
                        orderNos.append(orderNo)
                        self?.isBadOrder(orderNo: orderNo)
                    }
                    DispatchQueue.main.async {
                        Toast(text: "订单：\(orderNo)提交一张图片失败").show()
                    }
                    self?.uploadImageQueue(i: i+1, keys: keys, orderNo: orderNo, images: images)
                }
            }
        }
    }
    
    func reuploadOrder(oldOrderNo: String) {
        if oldOrderNo.characters.count > 0 {
            if var orders = UserDefaults.standard.object(forKey: "orders") as? [[String : String]] {
                if orders.count > 0 {
                    var dicTem : [String : String] = [:]
                    var i = 0
                    for (index, dic) in orders.enumerated() {
                        if let orderNo = dic["orderNo"] {
                            if oldOrderNo == orderNo {
                                dicTem = dic
                                i = index
                                break
                            }
                        }
                    }
                 
                    if dicTem.count > 0 {
                        
                        dicTem["unfinished"] = ""
                        orders[i] = dicTem
                        UserDefaults.standard.set(orders, forKey: "orders")
                        UserDefaults.standard.synchronize()
                        
                        if let urls = dicTem["images"] {
                            
                            let keys = UserDefaults.standard.object(forKey: "orderKeys") as! [String]
                            if keys.count > 0 {
                                let imagesPath = keys[i]
                                DispatchQueue.global().async {
                                    [weak self] in
                                    var images : [Int : Data] = [:]
                                    let array = urls.components(separatedBy: ",")
                                    var path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first
                                    path = path! + "/\(imagesPath)"
                                    for item in array {
                                        if let image = UIImage(contentsOfFile: path! + "/\(item).jpg") {
                                            images[Int(item)!] = UIImageJPEGRepresentation(image, 1)
                                        }
                                    }
                                    
                                    if images.count > 0 {
                                        let arr : Set<String> = uploadDict[oldOrderNo] ?? []
                                        var images2 : [Int : Data] = [:]
                                        for (key , value) in images {
                                            if arr.contains("\(key)") == false {
                                                continue
                                            }else{
                                                images2[key] = value
                                            }
                                        }
                                        if images2.count > 0 {
                                            //uploadDictCount[oldOrderNo] = images2.keys.count
                                            self?.uploadImageQueue(i: 0, keys: images2.keys, orderNo: oldOrderNo, images: images2)
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    
    func reuploadOrderpre(oldOrderNo: String) {
        if oldOrderNo.characters.count > 0 {
            if var orders = UserDefaults.standard.object(forKey: "preorders") as? [[String : String]] {
                if orders.count > 0 {
                    var dicTem : [String : String] = [:]
                    var i = 0
                    for (index, dic) in orders.enumerated() {
                        if let orderNo = dic["orderNo"] {
                            if oldOrderNo == orderNo {
                                dicTem = dic
                                i = index
                                break
                            }
                        }
                    }
                    
                    if dicTem.count > 0 {
                        
                        dicTem["unfinished"] = ""
                        orders[i] = dicTem
                        UserDefaults.standard.set(orders, forKey: "preorders")
                        UserDefaults.standard.synchronize()
                        
                        if let urls = dicTem["images"] {
                            
                            let keys = UserDefaults.standard.object(forKey: "preorderKeys") as! [String]
                            if keys.count > 0 {
                                let imagesPath = keys[i]
                                DispatchQueue.global().async {
                                    [weak self] in
                                    var images : [Int : Data] = [:]
                                    let array = urls.components(separatedBy: ",")
                                    var path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first
                                    path = path! + "/\(imagesPath)"
                                    for item in array {
                                        if let image = UIImage(contentsOfFile: path! + "/\(item).jpg") {
                                            images[Int(item)!] = UIImageJPEGRepresentation(image, 1)
                                        }
                                    }
                                    
                                    if images.count > 0 {
                                        let arr : Set<String> = uploadDictpre[oldOrderNo] ?? []
                                        var images2 : [Int : Data] = [:]
                                        for (key , value) in images {
                                            if arr.contains("\(key)") == false {
                                                continue
                                            }else{
                                                images2[key] = value
                                            }
                                        }
                                        if images2.count > 0 {
                                            self?.uploadImageQueuepre(i: 0, keys: images2.keys, images: images2, orderNo: oldOrderNo)
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    
    // 上传图片
    func uploadImageQueue(i : Int, keys: LazyMapCollection<Dictionary<Int, Data>, Int>, images: [Int : Data], orderNo: String){
        guard let _ = UserDefaults.standard.object(forKey: "userinfo") else {
            return
        }
        if i == keys.count {
            if orderNos.contains(orderNo) {
                for (m , strOrderNo) in orderNos.enumerated() {
                    if strOrderNo == orderNo {
                        orderNos.remove(at: m)
                        break
                    }
                }
            }
            return
        }
        
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: Notification.Name("recordVC"), object: nil)
        }
        
        let key = keys[keys.index(keys.startIndex, offsetBy: i)]
        let value = images[key]!
        let section = key / 1000
        let row = (key % 1000) % 100
        let right = key % 1000 >= 100
        
        print("上传图片")
        let username = UserDefaults.standard.string(forKey: "username")
        var params = ["createUser" : username!]
        params["clientName"] = "iOS"
        params["carBillId"] = orderNo
        params["imageClass"] = self.sectionTitles[section]
        params["imageSeqNum"] = "\(row * 2 + (right ? 1 : 0))"
        NetworkManager.sharedInstall.upload(url: upload, params: params, data: value) {[weak self] (json, error) in
            DispatchQueue.global().async {
                if json != nil && json?["success"].boolValue == true {
                    
                    var arr : Set<String> = uploadDict[orderNo] ?? []
                    arr.remove("\(key)")
                    uploadDict[orderNo] = arr
                    print("还有\(arr.count)张没上传完")
                    
                    if arr.count == 0 {
                        uploadDict.removeValue(forKey: orderNo)
                        DispatchQueue.main.async {
                            NotificationCenter.default.post(name: Notification.Name("app"), object: 2 , userInfo: ["orderNo" : params["carBillId"]!])
                        }
                        
                    }
                     self?.uploadImageQueue(i: i + 1, keys: keys, images: images, orderNo: orderNo)
                }else{
                    
                    DispatchQueue.main.async {
                        Toast(text: "订单：\(orderNo)提交一张图片失败").show()
                    }
                    if !orderNos.contains(orderNo) {
                        orderNos.append(orderNo)
                        self?.isBadOrder(orderNo: orderNo)
                    }
                    self?.uploadImageQueue(i: i + 1, keys: keys, images: images, orderNo: orderNo)
                }
            }
        }
    }
    
    
    // 上传预评估图片
    func uploadImageQueuepre(i : Int, keys: LazyMapCollection<Dictionary<Int, Data>, Int>, images: [Int : Data], orderNo: String){
        guard let _ = UserDefaults.standard.object(forKey: "userinfo") else {
            return
        }
        if i == keys.count {
            if orderNos.contains(orderNo) {
                for (m , strOrderNo) in orderNos.enumerated() {
                    if strOrderNo == orderNo {
                        orderNos.remove(at: m)
                        break
                    }
                }
            }
            return
        }
        let key = keys[keys.index(keys.startIndex, offsetBy: i)]
        let value = images[key]!
        let section = key / 1000
        let row = (key % 1000) % 100
        let right = key % 1000 >= 100
        
        let username = UserDefaults.standard.string(forKey: "username")
        var params = ["createUser" : username!]
        params["clientName"] = "iOS"
        params["carBillId"] = orderNo
        params["imageClass"] = self.titlesImageClass[section][row * 2 + (right ? 1 : 0)]
        params["imageSeqNum"] = "\(self.titlesImageSeqNum[section][row * 2 + (right ? 1 : 0)])"
        NetworkManager.sharedInstall.upload(url: uploadPre, params: params, data: value) {[weak self] (json, error) in
            DispatchQueue.global().async {
                if json != nil && json?["success"].boolValue == true {
                    var arr : Set<String> = uploadDictpre[orderNo] ?? []
                    arr.remove("\(key)")
                    uploadDictpre[orderNo] = arr
                    
                    if arr.count == 0 {
                        uploadDictpre.removeValue(forKey: orderNo)
                        
                        if var orders = UserDefaults.standard.object(forKey: "preorders") as? [[String : String]] {
                            var orderKeys = UserDefaults.standard.object(forKey: "preorderKeys") as! [String]
                            
                            var i = 0
                            for (index , order) in orders.enumerated() {
                                if order["orderNo"] == orderNo {
                                    i = index
                                    break
                                }
                            }
                            if i < orders.count {
                                let fileName = orderKeys[i]
                                self?.removeDir(fileName: fileName)
                                orderKeys.remove(at: i)
                                orders.remove(at: i)
                                print("已删除：\(orderNo)")
                            }
                            
                            UserDefaults.standard.set(orderKeys, forKey: "preorderKeys")
                            UserDefaults.standard.set(orders, forKey: "preorders")
                            UserDefaults.standard.synchronize()
                        }
                        
                        DispatchQueue.main.async {
                            NotificationCenter.default.post(name: Notification.Name("predetection"), object: 2)
                        }
                        
                        self?.showAlert(title: nil, message: "评估单：\(orderNo)提交成功，请在“进度列表“查看进度", button: "")
                    }
                    
                    self?.uploadImageQueuepre(i: i + 1, keys: keys, images: images, orderNo: orderNo)
                }else{
                    DispatchQueue.main.async {
                        Toast(text: "订单：\(orderNo)提交一张图片失败").show()
                    }
                    if !orderNos.contains(orderNo) {
                        orderNos.append(orderNo)
                        self?.isBadOrderpre(orderNo: orderNo)
                    }
                    self?.uploadImageQueuepre(i: i + 1, keys: keys, images: images, orderNo: orderNo)
                }
            }
        }
    }

    // 删除文件夹及文件夹内文件
    func removeDir(fileName: String) {
        let fileManager = FileManager.default
        var path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first
        path = path! + "/\(fileName)"
        do {
            try fileManager.removeItem(atPath: path!)
        }catch {
            print("删除文件夹失败")
        }
    }
    
    
}

