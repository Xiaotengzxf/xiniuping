//
//  PreDetectionViewController.swift
//  CarDetecion
//
//  Created by 张晓飞 on 2017/6/17.
//  Copyright © 2017年 inewhome. All rights reserved.
//

import UIKit
import DZNEmptyDataSet
import SwiftyJSON
import MJRefresh
import Toaster
import MBProgressHUD

class PreDetectionViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate, RecordTableViewCellDelegate {

    @IBOutlet weak var vFastPreDetection: UIView!
    @IBOutlet weak var segControl: UISegmentedControl!
    @IBOutlet weak var lcLineWidth: NSLayoutConstraint!
    @IBOutlet weak var lcLineLeading: NSLayoutConstraint!
    @IBOutlet weak var ivLine: UIImageView!
    @IBOutlet weak var tableView0: UITableView!
    @IBOutlet weak var tableView1: UITableView!
    @IBOutlet weak var tableView2: UITableView!
    @IBOutlet weak var lcTableViewLeading: NSLayoutConstraint!
    var data : [JSON] = []
    var data1 : [JSON] = []
    var data2 : [JSON] = []
    var nShowEmpty = 0 // 1 无数据 2 加载中 3 无网络
    var nShowEmpty1 = 0 // 1 无数据 2 加载中 3 无网络
    var nShowEmpty2 = 0 // 1 无数据 2 加载中 3 无网络
    var curPage1 = 1
    var curPage2 = 1
    let preCarBillList = "external/app/getPreCarBillList.html"
    let preCarBillToNormal = "external/app/postPreCarBill2Normal.html"
    let getAppDetailCarBill = "external/app/getAppDetailCarBill.html"
    let getAppDetailPreCarBill = "external/app/getAppDetailPreCarBill.html"
    let pageSize = 10 // 每页数量
    let statusInfo = ["-1" : "驳回", "0" : "审核中", "1" : "通过" , "2" : "已推送"]
    var statusInfo2 : [String : String] = ["21": "等待初审" , "22": "初审中" , "23": "初审驳回" , "24": "初审通过",
                                          "31": "等待初评" , "32": "初评中" , "33": "初评驳回" , "34": "初评通过",
                                          "41": "等待中评" , "42": "中评中" , "43": "中评驳回" , "44": "中评通过",
                                          "51": "等待高评" , "52": "高评中" , "53": "高评驳回" , "54": "高评通过",
                                          "80": "评估完成"] // 0, "提取图片"
    
    // MARK: - viewcontroller cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        lcLineWidth.constant = WIDTH / 3
        
        segControl.setBackgroundImage(UIImage(), for: .normal, barMetrics: .default)
        segControl.setDividerImage(UIImage(), forLeftSegmentState: .normal, rightSegmentState: .normal, barMetrics: .default)
        segControl.setTitleTextAttributes([NSForegroundColorAttributeName : UIColor.black], for: .selected)
        segControl.setTitleTextAttributes([NSForegroundColorAttributeName : UIColor.gray], for: .normal)

        let tap = UITapGestureRecognizer(target: self, action: #selector(PreDetectionViewController.handleTap(sender:)))
        vFastPreDetection.addGestureRecognizer(tap)
        
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
        tableView1.mj_footer.isHidden = true
        tableView2.mj_footer.isHidden = true
        
        tableView1.mj_header.beginRefreshing()
        tableView2.mj_header.beginRefreshing()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.handleNotification(notification:)), name: Notification.Name("predetection"), object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.lt_setBackgroundColor(backgroundColor: UIColor(red: 55/255.0, green: 70/255.0, blue: 85/255.0, alpha: 1))
        
        reloadTableView0()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func reloadTableView0() {
        data.removeAll()
        if let orders = UserDefaults.standard.object(forKey: "preorders") as? [[String : String]] {
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
    
    // MARK: - private method
    
    @IBAction func segSelectedIndex(_ sender: Any) {
        let index = segControl.selectedSegmentIndex
        lcLineLeading.constant = CGFloat(index) * (WIDTH / 3)
        lcTableViewLeading.constant = -(CGFloat(index) * WIDTH)
        UIView.animate(withDuration: 0.3, animations: { 
            [weak self] in
            self?.view.layoutIfNeeded()
        }) { (finished) in
            
        }
        if index == 0 {
            reloadTableView0()
        }else if index == 1 {
            self.tableView1.mj_header.beginRefreshing()
        }else {
            self.tableView2.mj_header.beginRefreshing()
        }
    }
    
    func handleTap(sender : Any) {
        if let controller = self.storyboard?.instantiateViewController(withIdentifier: "fastpredetection") as? FastPreDetectionViewController {
            self.navigationController?.pushViewController(controller, animated: true)
        }
    }
    
    func getBillList1() {
        let username = UserDefaults.standard.string(forKey: "username")
        var params = ["userName" : username!]
        params["curPage"] = "\(curPage1)"
        params["pageSize"] = "\(pageSize)"
        params["status"] = "0,1,2"
        params["carBillType"] = "routine"
        NetworkManager.sharedInstall.request(url: preCarBillList, params: params) {[weak self] (json, error) in
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
        params["curPage"] = "\(curPage2)"
        params["pageSize"] = "\(pageSize)"
        params["status"] = "-1"
        params["carBillType"] = "routine"
        NetworkManager.sharedInstall.request(url: preCarBillList, params: params) {[weak self] (json, error) in
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
    
    func handleNotification(notification : Notification) {
        if segControl.selectedSegmentIndex == 0 {
            reloadTableView0()
        }else if segControl.selectedSegmentIndex == 1 {
            tableView1.mj_header.beginRefreshing()
        }else if segControl.selectedSegmentIndex == 2 {
            tableView2.mj_header.beginRefreshing()
        }
    }
    
    // MARK: - UITableView DataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == tableView0 {
            return data.count
        }else if tableView == tableView1 {
            return data1.count
        }else {
            return data2.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == tableView0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! RecordTableViewCell
            //cell.delegate = self
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
            
            if let label = cell.contentView.viewWithTag(4) as? UILabel {
                label.text = "添加时间：\(data[indexPath.row]["addtime"].string ?? "") "
                label.textColor = UIColor.rgbColorFromHex(rgb: 0xF86765)
            }
            if let label = cell.contentView.viewWithTag(5) as? UILabel {
                if strOrderNo.characters.count > 0 {
                    if bUnfinished {
                        label.text = "提交状态：提交失败"
                    }else{
                        label.text = "提交状态：提交中"
                    }
                }else{
                    label.text = ""
                }
            }
            if let imageView = cell.contentView.viewWithTag(2) as? UIImageView {
                let json = data[indexPath.row]
                var orderKeys : [String] = []
                if let keys = UserDefaults.standard.object(forKey: "preorderKeys") as? [String] {
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
            cell.delegate = self
            cell.tag = indexPath.row
            //cell.addLongTap()
            let status = data1[indexPath.row]["status"].string ?? "0"
            let normalCarBillId = data1[indexPath.row]["normalCarBillId"].string ?? ""
            if status == "1" || status == "2" {
                cell.btnChangeToNormal.isHidden = false
                if status == "1" {
                    cell.btnChangeToNormal.setTitle("提交正式评估", for: .normal)
                    cell.btnChangeToNormal.setTitleColor(UIColor.green, for: .normal)
                }else{
                    cell.btnChangeToNormal.setTitle("查看正式评估", for: .normal)
                    cell.btnChangeToNormal.setTitleColor(UIColor.rgbColorFromHex(rgb: 0xF86765), for: .normal)
                }
            }else{
                cell.btnChangeToNormal.isHidden = true
            }
            
            if let label = cell.contentView.viewWithTag(3) as? UILabel {
                label.text = "单号：\(data1[indexPath.row]["carBillId"].string ?? "")"
            }
            if let label = cell.contentView.viewWithTag(5) as? UILabel {
                label.text = "审核进度：\(statusInfo[status]!)"
                label.textColor = UIColor.rgbColorFromHex(rgb: 0x3B93EC)
                
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
            if let label = cell.contentView.viewWithTag(8) as? UILabel {
                if status == "2" {
                    label.isHidden = false
                    label.text = "正式评估单号：\(normalCarBillId)"
                }else{
                    label.isHidden = true
                    label.text = "正式评估单号："
                }
            }
            return cell
        }else {
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
                label.textColor = UIColor.rgbColorFromHex(rgb: 0x3B93EC)
                
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
                    Toast(text: "评估单：\(orderNo)，正在提交中" ).show()
                    return
                    
                }
            }
            
            if let controller = self.storyboard?.instantiateViewController(withIdentifier: "fastpredetection") as? FastPreDetectionViewController {
                
                var orderKeys : [String] = []
                if let keys = UserDefaults.standard.object(forKey: "preorderKeys") as? [String] {
                    orderKeys += keys
                }
                if let urls = json["images"].string {
                    controller.imagesPath = urls
                    controller.imagesFilePath = orderKeys[indexPath.row]
                }
                controller.remark = json["mark"].string ?? ""
                controller.pathName = orderKeys[indexPath.row]
                controller.unfinished = bUnfinished
                if let orderNo = json["orderNo"].string, orderNo.characters.count > 0 {
                    controller.orderNo = orderNo
                }
                self.navigationController?.pushViewController(controller, animated: true)
            }
        }else{
            if tableView == tableView2 {
                getAppDetailCarBillToFast(carBillId: data2[indexPath.row]["carBillId"].string ?? "")
                
            }else if tableView == tableView1 {
                let status = data1[indexPath.row]["status"].string ?? "0"
                if status == "0" {
                    return
                }
                if let controller = self.storyboard?.instantiateViewController(withIdentifier: "fastpredetectiondetail") as? FastPreDetectionDetailViewController {
                    controller.carBillId = data1[indexPath.row]["carBillId"].stringValue
                    controller.title = "报告详情"
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
        }
    }
    
    func emptyDataSetShouldDisplay(_ scrollView: UIScrollView!) -> Bool {
        if scrollView == tableView1 {
            return nShowEmpty1 > 0
        }else if scrollView == tableView2 {
            return nShowEmpty2 > 0
        }else{
            return nShowEmpty > 0
        }
    }
    
    
    func tapCell(tag: Int) {
        if segControl.selectedSegmentIndex == 0 {
            let alert = UIAlertController(title: "提示", message: "您想删除该条记录，还是置顶该条记录？", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "删除", style: .default, handler: {[weak self] (action) in
                self?.data.remove(at: tag)
                if self!.data.count == 0 {
                    self!.nShowEmpty = 1
                }
                self?.tableView0.reloadData()
                var orders = UserDefaults.standard.object(forKey: "preorders") as! [[String : String]]
                var orderkeys = UserDefaults.standard.object(forKey: "preorderKeys") as! [String]
                orders.remove(at: tag)
                orderkeys.remove(at: tag)
                UserDefaults.standard.set(orders, forKey: "preorders")
                UserDefaults.standard.set(orderkeys, forKey: "preorderKeys")
                UserDefaults.standard.synchronize()
            }))
            alert.addAction(UIAlertAction(title: "置顶", style: .default, handler: {[weak self] (action) in
                let json = self?.data.remove(at: tag)
                self?.data.insert(json!, at: 0)
                self?.tableView0.reloadData()
                var orders = UserDefaults.standard.object(forKey: "preorders") as! [[String : String]]
                var orderKeys = UserDefaults.standard.object(forKey: "preorderKeys") as! [String]
                let value = orders.remove(at: tag)
                orders.insert(value, at: 0)
                let valueKey = orderKeys.remove(at: tag)
                orderKeys.insert(valueKey, at: 0)
                UserDefaults.standard.set(orders, forKey: "preorders")
                UserDefaults.standard.set(orderKeys, forKey: "preorderKeys")
                UserDefaults.standard.synchronize()
            }))
            alert.addAction(UIAlertAction(title: "取消", style: .cancel, handler: { (action) in
                
            }))
            self.present(alert, animated: true, completion: {
                
            })
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
    
    //URL	http://119.23.128.214:8080/carWeb/external/app/getAppDetailCarBill.html?userName=Moth&carBillId=NS201707010009&clientName=android
    
    // RecordTableViewCellDelegate
    func handleChangeToNormal(tag: Int) {
        let username = UserDefaults.standard.string(forKey: "username")
        var params = ["userName" : username!]
        params["carBillId"] = data1[tag]["carBillId"].stringValue
        let status = data1[tag]["status"].stringValue
        if status == "1" {
            let hud = showHUD(text: "加载中...")
            NetworkManager.sharedInstall.request(url: preCarBillToNormal, params: params) {[weak self] (json, error) in
                if error != nil {
                    self?.hideHUD(hud: hud)
                    print(error!.localizedDescription)
                }else{
                    if let success = json?["success"].boolValue , success {
                        self?.getAppDetailCarBill(carBillId: json!["object"].stringValue, hud: hud, status: "1")
                    }else{
                        self?.hideHUD(hud: hud)
                        if let message = json?["message"].string {
                            Toast(text: message).show()
                        }
                    }
                }
            }
        }else if status == "2" {
            let normalCarBillId = data1[tag]["normalCarBillId"].string ?? ""
            let hud = showHUD(text: "加载中...")
            self.getAppDetailCarBill(carBillId: normalCarBillId, hud: hud, status: "2")
        }
        
    }
    
    func getAppDetailCarBill(carBillId : String, hud : MBProgressHUD, status: String) {
        let username = UserDefaults.standard.string(forKey: "username")
        var params = ["userName" : username!]
        params["carBillId"] = carBillId
        params["clientName"] = "iOS"
        NetworkManager.sharedInstall.request(url: getAppDetailCarBill, params: params) {[weak self] (json, error) in
            self?.hideHUD(hud: hud)
            if error != nil {
                print(error!.localizedDescription)
            }else{
                if let success = json?["carBillId"].string , success == carBillId {
                    let preStatus = json?["status"].int ?? 0
                    if status == "1" || preStatus == 33 {
                        if let controller = self?.storyboard?.instantiateViewController(withIdentifier: "detectionnew") as? DetectionNewViewController {
                            controller.source = 1
                            controller.json = json!
                            self?.navigationController?.pushViewController(controller, animated: true)
                            self?.tableView1.mj_header.beginRefreshing()
                        }
                    }else{
                        if let controller = self?.storyboard?.instantiateViewController(withIdentifier: "recorddetail") as? RecordDetailViewController {
                            controller.json = json!
                            controller.statusInfo = self!.statusInfo2
                            controller.flag = 1
                            controller.title = "订单结果"
                            self?.navigationController?.pushViewController(controller, animated: true)
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
    
    func getAppDetailCarBillToFast(carBillId : String) {
        let username = UserDefaults.standard.string(forKey: "username")
        var params = ["userName" : username!]
        params["carBillId"] = carBillId
        let hud = showHUD(text: "加载中...")
        NetworkManager.sharedInstall.request(url: getAppDetailPreCarBill, params: params) {[weak self] (json, error) in
            self?.hideHUD(hud: hud)
            if error != nil {
                print(error!.localizedDescription)
            }else{
                if let success = json?["carBillId"].string , success == carBillId {
                    if let controller = self?.storyboard?.instantiateViewController(withIdentifier: "fastpredetection") as? FastPreDetectionViewController {
                        controller.source = 1
                        controller.json = json!
                        controller.title = "驳回-\(success)"
                        self?.navigationController?.pushViewController(controller, animated: true)
                    }
                }else{
                    if let message = json?["message"].string {
                        Toast(text: message).show()
                    }
                }
            }
        }
    }

}
