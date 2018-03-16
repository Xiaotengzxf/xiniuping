//
//  RecordTableViewController.swift
//  CarDetecion
//
//  Created by 张晓飞 on 2017/3/10.
//  Copyright © 2017年 inewhome. All rights reserved.
//

import UIKit
import MJRefresh
import SwiftyJSON
import Toaster
import DZNEmptyDataSet
import SDWebImage

class RecordViewController: UIViewController , DZNEmptyDataSetDelegate , DZNEmptyDataSetSource , UITableViewDelegate , UITableViewDataSource , RecordTableViewCellDelegate{

    @IBOutlet weak var tableView0: UITableView!
    @IBOutlet weak var lcLeft: NSLayoutConstraint!
    @IBOutlet weak var tfSearch: SearchTextField!
    let orderList = "external/app/getAppBillList.html"
    var curPage1 = 1
    var curPage2 = 1
    var curPage3 = 1
    var status1 = "21,22,24,31,32,34,41,42,44,51,52"
    var status2 = "23,33,43,53"
    var status3 = "54,80"
    let pageSize = 10
    var data : [JSON] = []
    var nShowEmpty = 0 // 1 无数据 2 加载中 3 无网络
    var statusInfo : [String : String] = ["21": "等待初审" , "22": "初审中" , "23": "初审驳回" , "24": "初审通过",
                      "31": "等待初评" , "32": "初评中" , "33": "初评驳回" , "34": "初评通过",
                      "41": "等待中评" , "42": "中评中" , "43": "中评驳回" , "44": "中评通过",
                      "51": "等待高评" , "52": "高评中" , "53": "高评驳回" , "54": "高评通过",
                      "80": "评估完成"] // 0, "提取图片"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let ivTitle = UIImageView(image: UIImage(named: "tabtitle11"))
        ivTitle.frame = CGRect(x: 0, y: 0, width: 72, height: 23)
        navigationItem.titleView = ivTitle
        
        tableView0.mj_header = MJRefreshNormalHeader(refreshingBlock: {
            [weak self] in
            self?.tableView0.mj_header.endRefreshing()
        })
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.handleNotification(notification:)), name: Notification.Name("recordVC"), object: nil)
        
        let ivSearch = UIImageView(image: UIImage(named: "search"))
        ivSearch.frame = CGRect(x: 0, y: 0, width: 35, height: 20)
        ivSearch.contentMode = .scaleAspectFit
        tfSearch.leftView = ivSearch
        tfSearch.leftViewMode = .always
        tfSearch.textColor = UIColor.white
        tfSearch.attributedPlaceholder = NSAttributedString(string: "评估单号搜索", attributes: [NSForegroundColorAttributeName: UIColor.white])
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        refreshTableView0()
        if let tabController = self.navigationController?.tabBarController as? MTabBarController {
            tabController.tabView.isHidden = false
            tabController.tabBar.isHidden = true
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func handleNotification(notification : Notification)  {
        refreshTableView0()
    }
    
    func refreshTableView0() {
        data.removeAll()
        if let orders = UserDefaults.standard.object(forKey: "orders") as? [[String : String]] {
            if orders.count > 0 {
                for dic in orders {
                    data.append(JSON(dic))
                }
            }
        }
        if data.count == 0 {
            nShowEmpty = 1
        }
        self.tableView0.reloadData()
    }
    
    // MARK: - Table view data source

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! RecordTableViewCell
        cell.delegate = self
        cell.tag = indexPath.row
        cell.addLongTap()
        let json = data[indexPath.row]
        var bUnfinished = false
        var strOrderNo = ""
        if let orderNo = json["orderNo"].string, orderNo.characters.count > 0 {
            if let unfinished = json["unfinished"].string, unfinished == "1" {
                bUnfinished = true
            }else{
            }
            strOrderNo = orderNo
        }
        
        if let label = cell.contentView.viewWithTag(3) as? UILabel {
            if strOrderNo.characters.count == 0 {
                label.text = "暂无单号"
            }else{
                label.text = "单号：\(strOrderNo)"
            }
        }
        if let label = cell.contentView.viewWithTag(4) as? UILabel {
            label.text = "添加时间：\(data[indexPath.row]["addtime"].string ?? "") "
            label.textColor = UIColor.rgbColorFromHex(rgb: 0xF86765)
        }
        if let label = cell.contentView.viewWithTag(5) as? UILabel {
            if strOrderNo.characters.count > 0 {
                if bUnfinished {
                    label.text = "提交状态：提交失败"
                }else{
                    let normal = uploadDict[strOrderNo]?.count ?? 0
                    let total = uploadDictCount[strOrderNo] ?? 0
                    if total > 0 && normal > 0 {
                        let percent = Int(Float((total - normal) * 100) / Float(total))
                        label.text = "提交状态：提交中 \(percent)%"
                    }else{
                        label.text = "提交状态：重新提交"
                    }
                }
            }else{
                label.text = ""
            }
        }
        if let imageView = cell.contentView.viewWithTag(2) as? UIImageView {
            let json = data[indexPath.row]
            var orderKeys : [String] = []
            if let keys = UserDefaults.standard.object(forKey: "orderKeys") as? [String] {
                orderKeys += keys
            }
            if let urls = json["images"].string , urls.contains("3000") {
                var path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first
                path = path! + "/\(orderKeys[indexPath.row])"
                if let image = UIImage(contentsOfFile: path! + "/3000.jpg") {
                    imageView.image = image
                }
            }else{
                imageView.image = UIImage(named: "defult_image")
            }
        }
        
        return cell
    }
 
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let json = data[indexPath.row]
        var bUnfinished = false
        if let orderNo = json["orderNo"].string, orderNo.characters.count > 0 {
            if let unfinished = json["unfinished"].string, unfinished == "1" {
                bUnfinished = true
            }else{
                let normal = uploadDict[orderNo]?.count ?? 0
                if normal > 0 {
                    Toast(text: "评估单：\(orderNo)，正在提交中" ).show()
                    return
                }else{
                    Toast(text: "评估单：\(orderNo)，重新提交中" ).show()
                    NotificationCenter.default.post(name: Notification.Name("app"), object: 6, userInfo: ["orderNo": orderNo])
                    return
                }
            }
        }
        
        if let controller = self.storyboard?.instantiateViewController(withIdentifier: "detectionnew") as? DetectionNewViewController {
            
            var orderKeys : [String] = []
            if let keys = UserDefaults.standard.object(forKey: "orderKeys") as? [String] {
                orderKeys += keys
            }
            if let urls = json["images"].string {
                controller.imagesPath = urls
                controller.imagesFilePath = orderKeys[indexPath.row]
            }
            controller.pathName = orderKeys[indexPath.row]
            let p = json["preSalePrice"].string
            controller.price = p ?? ""
            controller.remark = json["mark"].string ?? ""
            controller.leaseTerm = Int(json["leaseTerm"].string ?? "0")!
            controller.unfinished = bUnfinished
            if let orderNo = json["orderNo"].string, orderNo.characters.count > 0 {
                controller.onceOrderId = orderNo
            }
            self.navigationController?.pushViewController(controller, animated: true)
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
    
    // MARK: - 空数据
    func backgroundColor(forEmptyDataSet scrollView: UIScrollView!) -> UIColor! {
        return UIColor.white
    }
    
    func image(forEmptyDataSet scrollView: UIScrollView!) -> UIImage! {
        return UIImage(named: "ad_empty")
    }
    
    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        var message = ""
        if nShowEmpty == 1 {
            message = "空空如也，啥子都没有哦！"
        }else if nShowEmpty == 2 {
            message = "加载是件正经事儿，走心加载中..."
        }else if nShowEmpty == 3 {
            message = "世界上最遥远的距离就是没有网络..."
        }
        let att = NSMutableAttributedString(string: message)
        att.addAttributes([NSFontAttributeName : UIFont.systemFont(ofSize: 13)], range: NSMakeRange(0, att.length))
        return att
    }
    
    func emptyDataSet(_ scrollView: UIScrollView!, didTap view: UIView!) {
        
    }
    
    func emptyDataSetShouldDisplay(_ scrollView: UIScrollView!) -> Bool {
        return nShowEmpty > 0
    }
    
    func verticalOffset(forEmptyDataSet scrollView: UIScrollView!) -> CGFloat {
        return -100
    }
    
    
    func tapCell(tag: Int) {
        let alert = UIAlertController(title: "提示", message: "您想删除该条记录，还是置顶该条记录？", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "删除", style: .default, handler: {[weak self] (action) in
            self?.data.remove(at: tag)
            if self!.data.count == 0 {
                self!.nShowEmpty = 1
            }
            self?.tableView0.reloadData()
            var orders = UserDefaults.standard.object(forKey: "orders") as! [[String : String]]
            var orderkeys = UserDefaults.standard.object(forKey: "orderKeys") as! [String]
            orders.remove(at: tag)
            orderkeys.remove(at: tag)
            UserDefaults.standard.set(orders, forKey: "orders")
            UserDefaults.standard.set(orderkeys, forKey: "orderKeys")
            UserDefaults.standard.synchronize()
        }))
        alert.addAction(UIAlertAction(title: "置顶", style: .default, handler: {[weak self] (action) in
            let json = self?.data.remove(at: tag)
            self?.data.insert(json!, at: 0)
            self?.tableView0.reloadData()
            var orders = UserDefaults.standard.object(forKey: "orders") as! [[String : String]]
            var orderKeys = UserDefaults.standard.object(forKey: "orderKeys") as! [String]
            let value = orders.remove(at: tag)
            orders.insert(value, at: 0)
            let valueKey = orderKeys.remove(at: tag)
            orderKeys.insert(valueKey, at: 0)
            UserDefaults.standard.set(orders, forKey: "orders")
            UserDefaults.standard.set(orderKeys, forKey: "orderKeys")
            UserDefaults.standard.synchronize()
        }))
        alert.addAction(UIAlertAction(title: "取消", style: .cancel, handler: { (action) in
            
        }))
        self.present(alert, animated: true, completion: {
            
        })
    }
    
    func handleChangeToNormal(tag: Int) {
        
    }

}
