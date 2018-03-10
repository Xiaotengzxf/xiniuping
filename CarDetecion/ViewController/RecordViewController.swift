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

    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var ivDivide: UIImageView!
    @IBOutlet weak var lcDivideLeft: NSLayoutConstraint!
    @IBOutlet weak var tableView0: UITableView!
    @IBOutlet weak var tableView1: UITableView!
    @IBOutlet weak var tableView2: UITableView!
    @IBOutlet weak var tableView3: UITableView!
    @IBOutlet weak var lcLeft: NSLayoutConstraint!
    let orderList = "external/app/getAppBillList.html"
    var curPage1 = 1
    var curPage2 = 1
    var curPage3 = 1
    var status1 = "21,22,24,31,32,34,41,42,44,51,52"
    var status2 = "23,33,43,53"
    var status3 = "54,80"
    let pageSize = 10
    var data : [JSON] = []
    var data1 : [JSON] = []
    var data2 : [JSON] = []
    var data3 : [JSON] = []
    var nShowEmpty = 0 // 1 无数据 2 加载中 3 无网络
    var nShowEmpty1 = 0 // 1 无数据 2 加载中 3 无网络
    var nShowEmpty2 = 0 // 1 无数据 2 加载中 3 无网络
    var nShowEmpty3 = 0 // 1 无数据 2 加载中 3 无网络
    var statusInfo : [String : String] = ["21": "等待初审" , "22": "初审中" , "23": "初审驳回" , "24": "初审通过",
                      "31": "等待初评" , "32": "初评中" , "33": "初评驳回" , "34": "初评通过",
                      "41": "等待中评" , "42": "中评中" , "43": "中评驳回" , "44": "中评通过",
                      "51": "等待高评" , "52": "高评中" , "53": "高评驳回" , "54": "高评通过",
                      "80": "评估完成"] // 0, "提取图片"
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //tableView.tableHeaderView?.frame = CGRect(x: 0, y: 0, width: WIDTH, height: 44)
        segmentedControl.setBackgroundImage(UIImage(), for: .normal, barMetrics: .default)
        segmentedControl.setTitleTextAttributes([NSForegroundColorAttributeName : UIColor.darkGray], for: .normal)
        segmentedControl.setTitleTextAttributes([NSForegroundColorAttributeName : UIColor.black], for: .selected)
        segmentedControl.setDividerImage(UIImage(), forLeftSegmentState: .normal, rightSegmentState: .normal, barMetrics: .default)
        
        tableView0.mj_header = MJRefreshNormalHeader(refreshingBlock: {
            [weak self] in
            self?.tableView0.mj_header.endRefreshing()
        })
        tableView1.mj_header = MJRefreshNormalHeader(refreshingBlock: {
            [weak self] in
            self?.curPage1 = 1
            self?.getBillList1()
        })
        tableView2.mj_header = MJRefreshNormalHeader(refreshingBlock: {
            [weak self] in
            self?.curPage2 = 1
            self?.getBillList2()
        })
        tableView3.mj_header = MJRefreshNormalHeader(refreshingBlock: {
            [weak self] in
            self?.curPage3 = 1
            self?.getBillList3()
        })
        
        tableView1.mj_footer = MJRefreshBackNormalFooter(refreshingBlock: {
            [weak self] in
            self?.curPage1 += 1
            self?.getBillList1()
        })
        tableView2.mj_footer = MJRefreshBackNormalFooter(refreshingBlock: {
            [weak self] in
            self?.curPage2 += 1
            self?.getBillList2()
        })
        tableView3.mj_footer = MJRefreshBackNormalFooter(refreshingBlock: {
            [weak self] in
            self?.curPage3 += 1
            self?.getBillList3()
        })
        tableView1.mj_footer.isHidden = true
        tableView2.mj_footer.isHidden = true
        tableView3.mj_footer.isHidden = true
        
        tableView1.mj_header.beginRefreshing()
        tableView2.mj_header.beginRefreshing()
        tableView3.mj_header.beginRefreshing()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.handleNotification(notification:)), name: Notification.Name("recordVC"), object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.lt_setBackgroundColor(backgroundColor: UIColor(red: 0, green: 0, blue: 0, alpha: 0))
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        
        refreshTableView0()
        
        
        if recordIndex >= 0 {
            segmentedControl.selectedSegmentIndex = recordIndex
            recordIndex = -1
            lcDivideLeft.constant = segmentedControl.bounds.width / 4 * CGFloat(segmentedControl.selectedSegmentIndex)
            lcLeft.constant = -WIDTH * CGFloat(segmentedControl.selectedSegmentIndex)
            self.view.layoutIfNeeded()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.navigationBar.lt_reset()
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func handleNotification(notification : Notification)  {
        if segmentedControl.selectedSegmentIndex == 0 {
            refreshTableView0()
        }else if segmentedControl.selectedSegmentIndex == 1 {
            self.tableView1.mj_header.beginRefreshing()
        }else if segmentedControl.selectedSegmentIndex == 2 {
            self.tableView2.mj_header.beginRefreshing()
        }else if segmentedControl.selectedSegmentIndex == 3 {
            self.tableView3.mj_header.beginRefreshing()
        }
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
    
    func getBillList1() {
        let username = UserDefaults.standard.string(forKey: "username")
        var params = ["userName" : username!]
        var page = 0
        var status = ""
        page = curPage1
        status = status1
        params["curPage"] = "\(page)"
        params["pageSize"] = "\(pageSize)"
        params["status"] = status
        NetworkManager.sharedInstall.request(url: orderList, params: params) {[weak self] (json, error) in
            self?.tableView1.mj_header.endRefreshing()
            self?.tableView1.mj_footer.endRefreshing()
            if error != nil {
                print(error!.localizedDescription)
                if self!.curPage1 == 1 {
                    self?.nShowEmpty1 = 3
                    self?.tableView1.reloadData()
                }
            }else{
                if self!.curPage1 == 1 {
                    self!.data1.removeAll()
                }
                if let total = json?["total"].intValue , total > 0 {
                    if let array = json?["data"].array {
                        self?.data1 += array
                    }
                    if self!.data1.count > 0 {
                        self?.tableView1.mj_footer.isHidden = false
                    }else{
                        self?.tableView1.mj_footer.isHidden = true
                    }
                    if total < self!.pageSize {
                        self?.tableView1.mj_footer.endRefreshingWithNoMoreData()
                    }
                    if self!.curPage1 == 1 && self!.data1.count == 0 {
                        self?.nShowEmpty1 = 1
                    }
                }else{
                    if self!.curPage1 == 1 && self!.data1.count == 0 {
                        self?.nShowEmpty1 = 1
                    }
                }
                self?.tableView1.reloadData()
            }
        }
    }
    
    func getBillList2() {
        let username = UserDefaults.standard.string(forKey: "username")
        var params = ["userName" : username!]
        var page = 0
        var status = ""
        page = curPage2
        status = status2
        params["curPage"] = "\(page)"
        params["pageSize"] = "\(pageSize)"
        params["status"] = status
        NetworkManager.sharedInstall.request(url: orderList, params: params) {[weak self] (json, error) in
            self?.tableView2.mj_header.endRefreshing()
            self?.tableView2.mj_footer.endRefreshing()
            if error != nil {
                print(error!.localizedDescription)
                if self!.curPage2 == 1 {
                    self?.nShowEmpty2 = 3
                    self?.tableView2.reloadData()
                }
            }else{
                if self!.curPage2 == 1 {
                    self!.data2.removeAll()
                }
                if let total = json?["total"].intValue , total > 0 {
                    if let array = json?["data"].array {
                        self?.data2 += array
                    }
                    if self!.data2.count > 0 {
                        self?.tableView2.mj_footer.isHidden = false
                    }else{
                        self?.tableView2.mj_footer.isHidden = true
                    }
                    if total < self!.pageSize {
                        self?.tableView2.mj_footer.endRefreshingWithNoMoreData()
                    }
                    if self!.curPage2 == 1 && self!.data2.count == 0 {
                        self?.nShowEmpty2 = 1
                    }
                }else{
                    if self!.curPage2 == 1 && self!.data2.count == 0 {
                        self?.nShowEmpty2 = 1
                    }
                }
                self?.tableView2.reloadData()
            }
        }
    }
    
    func getBillList3() {
        let username = UserDefaults.standard.string(forKey: "username")
        var params = ["userName" : username!]
        var page = 0
        var status = ""
        page = curPage3
        status = status3
        params["curPage"] = "\(page)"
        params["pageSize"] = "\(pageSize)"
        params["status"] = status
        NetworkManager.sharedInstall.request(url: orderList, params: params) {[weak self] (json, error) in
            self?.tableView3.mj_header.endRefreshing()
            self?.tableView3.mj_footer.endRefreshing()
            if error != nil {
                print(error!.localizedDescription)
                if self!.curPage3 == 1 {
                    self?.nShowEmpty3 = 3
                    self?.tableView3.reloadData()
                }
            }else{
                if self!.curPage3 == 1 {
                    self!.data3.removeAll()
                }
                if let total = json?["total"].intValue , total > 0 {
                    if let array = json?["data"].array {
                        self?.data3 += array
                    }
                    if self!.data3.count > 0 {
                        self?.tableView3.mj_footer.isHidden = false
                    }else{
                        self?.tableView3.mj_footer.isHidden = true
                    }
                    if total < self!.pageSize {
                        self?.tableView3.mj_footer.endRefreshingWithNoMoreData()
                    }
                    if self!.curPage3 == 1 && self!.data3.count == 0 {
                        self?.nShowEmpty3 = 1
                    }
                }else{
                    if self!.curPage3 == 1 && self!.data3.count == 0 {
                        self?.nShowEmpty3 = 1
                    }
                }
                self?.tableView3.reloadData()
            }
        }
    }

    @IBAction func changeSegmentControl(_ sender: Any) {
        lcDivideLeft.constant = segmentedControl.bounds.width / 4 * CGFloat(segmentedControl.selectedSegmentIndex)
        lcLeft.constant = -WIDTH * CGFloat(segmentedControl.selectedSegmentIndex)
        UIView.animate(withDuration: 0.3) { 
            [weak self] in
            self?.view.layoutIfNeeded()
        }
        switch segmentedControl.selectedSegmentIndex {
        case 0:
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
            return
        case 1:
            self.tableView1.mj_header.beginRefreshing()
        case 2:
            self.tableView2.mj_header.beginRefreshing()
        case 3:
            self.tableView3.mj_header.beginRefreshing()
        default:
            print(segmentedControl.selectedSegmentIndex)
        }
//        if nShowEmpty != 0 {
//            nShowEmpty = 0
//            self.tableView.reloadData()
//        }
//        tableView.mj_header.beginRefreshing()
    }
    // MARK: - Table view data source

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == tableView0 {
            return data.count
        }else if tableView == tableView1 {
            return data1.count
        }else if tableView == tableView2 {
            return data2.count
        }else {
            return data3.count
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == tableView0 {
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
        }else if tableView == tableView1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell1", for: indexPath) as! RecordTableViewCell
            //cell.delegate = self
            cell.tag = indexPath.row
            //cell.addLongTap()
            
            if let label = cell.contentView.viewWithTag(3) as? UILabel {
                label.text = "单号：\(data1[indexPath.row]["carBillId"].string ?? "")"
            }
            if let label = cell.contentView.viewWithTag(5) as? UILabel {
                label.text = "审核进度：\(statusInfo["\(data1[indexPath.row]["status"].int ?? 0)"]!)"
                label.textColor = UIColor.rgbColorFromHex(rgb: 0xF86765)
                
            }
            if let label = cell.contentView.viewWithTag(4) as? UILabel {
                label.text = "创建时间：\(data1[indexPath.row]["createTime"].string ?? "")"
                label.textColor = UIColor.darkGray
            }
            if let imageView = cell.contentView.viewWithTag(2) as? UIImageView {
                let imagePath = data1[indexPath.row]["imageThumbPath"].string ?? ""
                if imagePath.characters.count > 0 {
                    imageView.sd_setImage(with: URL(string: "\(NetworkManager.sharedInstall.domain)\(imagePath)"), placeholderImage: UIImage(named: "defult_image"))
                }else{
                    imageView.image = UIImage(named: "defult_image")
                }
            }
            return cell
        }else if tableView == tableView2 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell2", for: indexPath) as! RecordTableViewCell
            //cell.delegate = self
            cell.tag = indexPath.row
            //cell.addLongTap()
            
            if let label = cell.contentView.viewWithTag(3) as? UILabel {
                label.text = "单号：\(data2[indexPath.row]["carBillId"].string ?? "")"
            }
            if let label = cell.contentView.viewWithTag(5) as? UILabel {
                label.text = "创建时间：\(data2[indexPath.row]["createTime"].string ?? "")"
                label.textColor = UIColor.darkGray
            }
            if let label = cell.contentView.viewWithTag(4) as? UILabel {
                label.text = "退回时间：\(data2[indexPath.row]["createTime"].string ?? "")"
                label.textColor = UIColor.rgbColorFromHex(rgb: 0xF86765)
               
            }
            if let imageView = cell.contentView.viewWithTag(2) as? UIImageView {
                let imagePath = data2[indexPath.row]["imageThumbPath"].string ?? ""
                if imagePath.characters.count > 0 {
                    imageView.sd_setImage(with: URL(string: "\(NetworkManager.sharedInstall.domain)\(imagePath)"), placeholderImage: UIImage(named: "defult_image"))
                }else{
                    imageView.image = UIImage(named: "defult_image")
                }
                
            }
            
            return cell
        }else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell3", for: indexPath) as! RecordTableViewCell
            //cell.delegate = self
            cell.tag = indexPath.row
            //cell.addLongTap()
            
            if let label = cell.contentView.viewWithTag(3) as? UILabel {
                label.text = "单号：\(data3[indexPath.row]["carBillId"].string ?? "")"
            }
            if let label = cell.contentView.viewWithTag(5) as? UILabel {
                label.text = "创建时间：\(data3[indexPath.row]["createTime"].string ?? "")"
                label.textColor = UIColor.darkGray
                
            }
            if let label = cell.contentView.viewWithTag(4) as? UILabel {
                label.text = "评估价格：\(data3[indexPath.row]["evaluatePrice"].int ?? 0) "
                label.textColor = UIColor.rgbColorFromHex(rgb: 0x2e8b57)
                if let userinfo = UserDefaults.standard.object(forKey: "userinfo") as? [String : Any] {
                    let userSuperCompany = userinfo["userSuperCompany"] as? Int ?? 0
                    let userCompany = userinfo["userCompany"] as? Int ?? 0
                    if userSuperCompany == 803 || userCompany == 803 { // 日产金融机器子公司
                        label.isHidden = true
                    }
                }
            }
            if let imageView = cell.contentView.viewWithTag(2) as? UIImageView {
                let imagePath = data3[indexPath.row]["imageThumbPath"].string ?? ""
                if imagePath.characters.count > 0 {
                    imageView.sd_setImage(with: URL(string: "\(NetworkManager.sharedInstall.domain)\(imagePath)"), placeholderImage: UIImage(named: "defult_image"))
                }else{
                    imageView.image = UIImage(named: "defult_image")
                }
            }
            return cell
        }
    }
 
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if  tableView == tableView0 {
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
        }else{
            if tableView == tableView2 {
                if let controller = self.storyboard?.instantiateViewController(withIdentifier: "detectionnew") as? DetectionNewViewController {
                    controller.source = 1
                    controller.json = data2[indexPath.row]
                    controller.title = "已退回-\(data2[indexPath.row]["carBillId"].string ?? "")"
                    self.navigationController?.pushViewController(controller, animated: true)
                }
            }else if tableView == tableView1 {
                if let controller = self.storyboard?.instantiateViewController(withIdentifier: "recorddetail") as? RecordDetailViewController {
                    controller.json = data1[indexPath.row]
                    controller.statusInfo = statusInfo
                    controller.flag = segmentedControl.selectedSegmentIndex
                    self.navigationController?.pushViewController(controller, animated: true)
                }
            }else {
                if let controller = self.storyboard?.instantiateViewController(withIdentifier: "recorddetail") as? RecordDetailViewController {
                    controller.json = data3[indexPath.row]
                    controller.statusInfo = statusInfo
                    controller.flag = segmentedControl.selectedSegmentIndex
                    self.navigationController?.pushViewController(controller, animated: true)
                }
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
    
    // MARK: - 空数据
    func backgroundColor(forEmptyDataSet scrollView: UIScrollView!) -> UIColor! {
        return UIColor.white
    }
    
    func image(forEmptyDataSet scrollView: UIScrollView!) -> UIImage! {
        return UIImage(named: "ad_empty")
    }
    
    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        var message = ""
        if scrollView! == tableView0 {
            if nShowEmpty == 1 {
                message = "空空如也，啥子都没有哦！"
            }else if nShowEmpty == 2 {
                message = "加载是件正经事儿，走心加载中..."
            }else if nShowEmpty == 3 {
                message = "世界上最遥远的距离就是没有网络..."
            }
        }else if scrollView! == tableView1 {
            if nShowEmpty1 == 1 {
                message = "空空如也，啥子都没有哦！"
            }else if nShowEmpty1 == 2 {
                message = "加载是件正经事儿，走心加载中..."
            }else if nShowEmpty1 == 3 {
                message = "世界上最遥远的距离就是没有网络..."
            }
        }else if scrollView! == tableView2 {
            if nShowEmpty2 == 1 {
                message = "空空如也，啥子都没有哦！"
            }else if nShowEmpty2 == 2 {
                message = "加载是件正经事儿，走心加载中..."
            }else if nShowEmpty2 == 3 {
                message = "世界上最遥远的距离就是没有网络..."
            }
        }else if scrollView! == tableView3 {
            if nShowEmpty3 == 1 {
                message = "空空如也，啥子都没有哦！"
            }else if nShowEmpty3 == 2 {
                message = "加载是件正经事儿，走心加载中..."
            }else if nShowEmpty3 == 3 {
                message = "世界上最遥远的距离就是没有网络..."
            }
        }
        let att = NSMutableAttributedString(string: message)
        att.addAttributes([NSFontAttributeName : UIFont.systemFont(ofSize: 13)], range: NSMakeRange(0, att.length))
        return att
    }
    
    func emptyDataSet(_ scrollView: UIScrollView!, didTap view: UIView!) {
        if scrollView! == tableView1 {
            if nShowEmpty1 > 0 {
                nShowEmpty1 = 0
                tableView1.reloadData()
                tableView1.mj_header.beginRefreshing()
            }
        }else if scrollView! == tableView2 {
            if nShowEmpty2 > 0 {
                nShowEmpty2 = 0
                tableView2.reloadData()
                tableView2.mj_header.beginRefreshing()
            }
        }else if scrollView! == tableView3 {
            if nShowEmpty3 > 0 {
                nShowEmpty3 = 0
                tableView3.reloadData()
                tableView3.mj_header.beginRefreshing()
            }
        }
    }
    
    func emptyDataSetShouldDisplay(_ scrollView: UIScrollView!) -> Bool {
        if scrollView == tableView1 {
            return nShowEmpty1 > 0
        }else if scrollView == tableView2 {
            return nShowEmpty2 > 0
        }else if scrollView == tableView3 {
            return nShowEmpty3 > 0
        }else{
            return nShowEmpty > 0
        }
    }
    
    
    func tapCell(tag: Int) {
        if segmentedControl.selectedSegmentIndex == 0 {
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
    }
    
    func handleChangeToNormal(tag: Int) {
        
    }

}
