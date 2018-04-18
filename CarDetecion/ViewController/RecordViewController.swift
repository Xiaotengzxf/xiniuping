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
   
    @IBOutlet weak var statusIndexButton: UIButton!
    @IBOutlet weak var searchBar: UISearchBar!
    let orderList = "external/app/getAppBillList.html"
    var curPage2 = 1
    var status2 = "23,33,43,53"
    let pageSize = 10
    var data : [JSON] = []
    var data2 : [JSON] = []
    var nShowEmpty = 0 // 1 无数据 2 加载中 3 无网络
    var nShowEmpty2 = 0 // 1 无数据 2 加载中 3 无网络
    var statusInfo : [String : String] = ["21": "等待初审" , "22": "初审中" , "23": "初审驳回" , "24": "初审通过",
                      "31": "等待初评" , "32": "初评中" , "33": "初评驳回" , "34": "初评通过",
                      "41": "等待中评" , "42": "中评中" , "43": "中评驳回" , "44": "中评通过",
                      "51": "等待高评" , "52": "高评中" , "53": "高评驳回" , "54": "高评通过",
                      "80": "评估完成"] // 0, "提取图片"
    var loadingView: LoadingView?
    var shadow: UIView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "未提交"
        searchBar.backgroundImage = UIImage()
        tableView0.mj_header = MJRefreshNormalHeader(refreshingBlock: {
            [weak self] in
            self?.curPage2 = 1
            self?.getBillList2()
        })
        
        tableView0.mj_footer = MJRefreshBackNormalFooter(refreshingBlock: {
            [weak self] in
            self?.curPage2 += 1
            self?.getBillList2()
        })
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.handleNotification(notification:)), name: Notification.Name("recordVC"), object: nil)
        
        getBillList2()
        
        statusIndexButton.set(title: "所有", titlePosition: .left, additionalSpacing: 5, state: .normal)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        refreshTableView0()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @IBAction func chooseStatus(_ sender: Any) {
    }
    
    func handleNotification(notification : Notification)  {
        if let tag = notification.object as? Int {
            if tag == 0 {
                refreshTableView0()
            } else if tag == 1 {
                if let dic = notification.userInfo as? [String : String] {
                    if let orderNo2 = dic["orderNo"] {
                        for json in data {
                            if let orderNo = json["orderNo"].string, orderNo.characters.count > 0 {
                                if orderNo == orderNo2 {
                                    let normal = uploadDict[orderNo]?.count ?? 0
                                    let total = uploadDictCount[orderNo] ?? 0
                                    if total > 0 && normal > 0 {
                                        showLoadingView(orderNo: orderNo, normal: normal, total: total)
                                    }
                                    break
                                }
                            }
                        }
                    }
                }
            } else if tag == 2 {
                
            }
        }
    }
    
    func showLoadingView(orderNo: String, normal: Int, total: Int) {
        if normal <= 1 {
            if loadingView != nil {
                loadingView?.removeFromSuperview()
                loadingView = nil
            }
        } else {
            if loadingView == nil {
                loadingView = Bundle.main.loadNibNamed("LoadingView", owner: nil, options: nil)?.first as? LoadingView
                loadingView?.translatesAutoresizingMaskIntoConstraints = false
                self.view.window?.addSubview(loadingView!)
                
                self.view.window?.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[loadingView]|", options: .directionLeadingToTrailing, metrics: nil, views: ["loadingView": loadingView!]))
                self.view.window?.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[loadingView]|", options: .directionLeadingToTrailing, metrics: nil, views: ["loadingView": loadingView!]))
                
            }
            loadingView?.lblOrderId.text = orderNo
            loadingView?.lblLoading.text = "[\(total - normal)/\(total)]上传中..."
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
        if data.count == 0 && data2.count == 0 {
            nShowEmpty = 1
        }
        self.tableView0.reloadData()
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
            self?.tableView0.mj_header.endRefreshing()
            self?.tableView0.mj_footer.endRefreshing()
            if error != nil {
                print(error!.localizedDescription)
                if self!.curPage2 == 1 {
                    self?.nShowEmpty2 = 3
                    self?.tableView0.reloadData()
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
                        self?.tableView0.mj_footer.isHidden = false
                    }else{
                        self?.tableView0.mj_footer.isHidden = true
                    }
                    if total < self!.pageSize {
                        self?.tableView0.mj_footer.endRefreshingWithNoMoreData()
                    }
                    if self!.curPage2 == 1 && self!.data2.count == 0 {
                        self?.nShowEmpty2 = 1
                    }
                }else{
                    if self!.curPage2 == 1 && self!.data2.count == 0 {
                        self?.nShowEmpty2 = 1
                    }
                }
                self?.tableView0.reloadData()
            }
        }
    }
    
    // MARK: - Table view data source

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count + data2.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! RecordTableViewCell
        if indexPath.row < data.count {
            cell.delegate = self
            cell.tag = indexPath.row
            cell.addLongTap()
            let json = data[indexPath.row]
            var strOrderNo = ""
            if let orderNo = json["orderNo"].string, orderNo.characters.count > 0 {
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
                label.text = "时间：\(data[indexPath.row]["addtime"].string ?? "") "
            }
            if let label = cell.contentView.viewWithTag(5) as? UILabel {
                label.text = "评估价格：无"
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
                    imageView.image = UIImage(named: "empty_default")
                }
            }
            
            if let imageView = cell.contentView.viewWithTag(20) as? UIImageView {
                if strOrderNo.characters.count > 0 {
                    if let unfinished = json["unfinished"].string, unfinished == "1" {
                        imageView.image = UIImage(named: "icon_unfinished")
                    } else {
                        imageView.image = UIImage(named: "icon_refresh")
                    }
                    
                }else{
                    imageView.image = UIImage(named: "icon_unfinished")
                }
            }
            if let label = cell.contentView.viewWithTag(21) as? UILabel {
                if strOrderNo.characters.count > 0 {
                    if let unfinished = json["unfinished"].string, unfinished == "1" {
                        label.text = "未完成"
                    } else {
                        label.text = ""
                    }
                    
                }else{
                    label.text = "未完成"
                }
            }
        } else {
            cell.tag = indexPath.row
            let index = indexPath.row - data.count
            if let label = cell.contentView.viewWithTag(3) as? UILabel {
                label.text = "单号：\(data2[index]["carBillId"].string ?? "")"
            }
            if let label = cell.contentView.viewWithTag(5) as? UILabel {
                let aStr = NSMutableAttributedString(string: "状态:驳回 ")
                aStr.addAttributes([NSForegroundColorAttributeName: UIColor.darkGray], range: NSMakeRange(0, 3))
                aStr.addAttributes([NSForegroundColorAttributeName: UIColor.rgbColorFromHex(rgb: 0xF86765)], range: NSMakeRange(3, aStr.length - 3))
                label.attributedText = aStr
            }
            if let label = cell.contentView.viewWithTag(4) as? UILabel {
                label.text = "创建时间：\(data2[index]["createTime"].string ?? "")"
            }
            if let imageView = cell.contentView.viewWithTag(2) as? UIImageView {
                let imagePath = data2[index]["imageThumbPath"].string ?? ""
                if imagePath.characters.count > 0 {
                    imageView.sd_setImage(with: URL(string: "\(NetworkManager.sharedInstall.domain)\(imagePath)"), placeholderImage: UIImage(named: "empty_default"))
                }else{
                    imageView.image = UIImage(named: "empty_default")
                }
            }
            if let imageView = cell.contentView.viewWithTag(20) as? UIImageView {
                imageView.image = UIImage(named: "icon_reject2")
            }
            if let label = cell.contentView.viewWithTag(21) as? UILabel {
                label.text = ""
            }
        }
        return cell
    }
 
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.row >= data.count {
            if let controller = self.storyboard?.instantiateViewController(withIdentifier: "detectionnew") as? DetectionNewViewController {
                controller.source = 1
                controller.json = data2[indexPath.row - data.count]
                controller.title = data2[indexPath.row - data.count]["carBillId"].string ?? ""
                controller.hidesBottomBarWhenPushed = true
                self.navigationController?.pushViewController(controller, animated: true)
            }
        } else {
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
                controller.hidesBottomBarWhenPushed = true
                self.navigationController?.pushViewController(controller, animated: true)
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

extension RecordViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if shadow == nil {
            shadow = UIView()
            shadow?.backgroundColor = UIColor.black.withAlphaComponent(0.5)
            shadow?.translatesAutoresizingMaskIntoConstraints = false
            self.view.addSubview(shadow!)
            
            self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[shadow]|", options: .directionLeadingToTrailing, metrics: nil, views: ["shadow": shadow!]))
            self.view.addConstraint(NSLayoutConstraint(item: shadow!, attribute: .top, relatedBy: .equal, toItem: tableView0, attribute: .top, multiplier: 1, constant: 0))
            self.view.addConstraint(NSLayoutConstraint(item: shadow!, attribute: .bottom, relatedBy: .equal, toItem: tableView0, attribute: .bottom, multiplier: 1, constant: 0))
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if shadow != nil {
            shadow?.removeFromSuperview()
            shadow = nil
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let text = textField.text, text.count > 0 {
            
        }
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        return true
    }
    
}
