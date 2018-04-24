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

class RecordSuccessViewController: UIViewController , DZNEmptyDataSetDelegate , DZNEmptyDataSetSource , UITableViewDelegate , UITableViewDataSource {

    @IBOutlet weak var statusIndexButton: UIButton!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView1: UITableView!
    let orderList = "external/app/getAppBillList.html"
    var curPage1 = 1
    let status1 = "21,22,24,31,32,34,41,42,44,51,52"
    var status3 = "54,80"
    let pageSize = 10
    var data1 : [JSON] = []
    var nShowEmpty1 = 0 // 1 无数据 2 加载中 3 无网络
    var statusInfo : [String : String] = ["21": "等待初审" , "22": "初审中" , "23": "初审驳回" , "24": "初审通过",
                      "31": "等待初评" , "32": "初评中" , "33": "初评驳回" , "34": "初评通过",
                      "41": "等待中评" , "42": "中评中" , "43": "中评驳回" , "44": "中评通过",
                      "51": "等待高评" , "52": "高评中" , "53": "高评驳回" , "54": "高评通过",
                      "80": "评估完成"] // 0, "提取图片"
    let arrTitle = ["所有","已提交","已完成"]
    let animationDelegate = PopoverAnimation()
    var index = 0
    var popVc: PopViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "已提交"
        searchBar.backgroundImage = UIImage()
        tableView1.mj_header = MJRefreshNormalHeader(refreshingBlock: {
            [weak self] in
            self?.curPage1 = 1
            self?.getBillList1()
        })
        
        tableView1.mj_footer = MJRefreshBackNormalFooter(refreshingBlock: {
            [weak self] in
            self?.curPage1 += 1
            self?.getBillList1()
        })
        
        tableView1.mj_footer.isHidden = true
        tableView1.mj_header.beginRefreshing()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.handleNotification(notification:)), name: Notification.Name("recordVC"), object: nil)
        
        statusIndexButton.set(title: "所有    ", titlePosition: .left, additionalSpacing: 5, state: .normal)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @IBAction func chooseStatus(_ sender: Any) {
        searchBar.resignFirstResponder()
        modalPopView(type: .right)
    }
    
    private func modalPopView(type: PopViewType) {
        popVc = PopViewController()
        popVc?.popType = type
        popVc?.transitioningDelegate = animationDelegate
        popVc?.modalPresentationStyle = .custom
        popVc?.selectDelegate = self
        animationDelegate.popViewType = type
        present(popVc!, animated: true, completion: nil)

    }
    
    @IBAction func refresh(_ sender: Any) {
        searchBar.resignFirstResponder()
        tableView1.mj_header.beginRefreshing()
    }
    
    func handleNotification(notification : Notification)  {
        if let tag = notification.object as? Int {
            if tag == 0 {
                tableView1.mj_header.beginRefreshing()
            }
        }
    }
    
    func getBillList1() {
        let username = UserDefaults.standard.string(forKey: "username")
        var params = ["userName" : username!]
        var page = 0
        var status = ""
        page = curPage1
        switch index {
        case 0:
            status = status1 + "," + status3
        case 1:
            status = status1
        case 2:
            status = status3
        default:
            fatalError()
        }
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

    // MARK: - Table view data source

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data1.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! RecordTableViewCell
        cell.tag = indexPath.row
        if let label = cell.contentView.viewWithTag(3) as? UILabel {
            label.text = "单号：\(data1[indexPath.row]["carBillId"].string ?? "")"
        }
        if let label = cell.contentView.viewWithTag(5) as? UILabel {
            label.text = "评估价格：\(data1[indexPath.row]["evaluatePrice"].string ?? "")"
            
        }
        if let label = cell.contentView.viewWithTag(4) as? UILabel {
            label.text = "创建时间：\(data1[indexPath.row]["createTime"].string ?? "")"
        }
        if let imageView = cell.contentView.viewWithTag(2) as? UIImageView {
            let imagePath = data1[indexPath.row]["imageThumbPath"].string ?? ""
            if imagePath.count > 0 {
                imageView.sd_setImage(with: URL(string: "\(NetworkManager.sharedInstall.domain)\(imagePath)"), placeholderImage: UIImage(named: "empty_default"))
            }else{
                imageView.image = UIImage(named: "empty_default")
            }
        }
        if let imageView = cell.contentView.viewWithTag(20) as? UIImageView {
            let status = "\(data1[indexPath.row]["status"].int ?? 0)"
            if status3.contains(status) {
                imageView.image = UIImage(named: "icon_finished")
            } else {
                imageView.image = UIImage(named: "icon_refresh")
            }
        }
        if let label = cell.contentView.viewWithTag(21) as? UILabel {
            let status = "\(data1[indexPath.row]["status"].int ?? 0)"
            if status3.contains(status) {
                label.text = "已完成"
            } else {
                label.text = "评估中"
            }
        }
        return cell
    }
 
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        searchBar.resignFirstResponder()
        let status = "\(data1[indexPath.row]["status"].int ?? 0)"
        if status3.contains(status) {
            if let controller = self.storyboard?.instantiateViewController(withIdentifier: "recorddetail") as? RecordDetailViewController {
                controller.json = data1[indexPath.row]
                controller.statusInfo = statusInfo
                controller.flag = 3
                controller.hidesBottomBarWhenPushed = true
                self.navigationController?.pushViewController(controller, animated: true)
            }
        } else {
            Toast(text: "正在评估，请稍等").show()
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
        if nShowEmpty1 == 1 {
            message = "空空如也，啥子都没有哦！"
        }else if nShowEmpty1 == 2 {
            message = "加载是件正经事儿，走心加载中..."
        }else if nShowEmpty1 == 3 {
            message = "世界上最遥远的距离就是没有网络..."
        }
        let att = NSMutableAttributedString(string: message)
        att.addAttributes([NSFontAttributeName : UIFont.systemFont(ofSize: 13)], range: NSMakeRange(0, att.length))
        return att
    }
    
    func emptyDataSet(_ scrollView: UIScrollView!, didTap view: UIView!) {
        if nShowEmpty1 > 0 {
            nShowEmpty1 = 0
            tableView1.reloadData()
            tableView1.mj_header.beginRefreshing()
        }
    }
    
    func emptyDataSetShouldDisplay(_ scrollView: UIScrollView!) -> Bool {
        return nShowEmpty1 > 0
    }
    
    func verticalOffset(forEmptyDataSet scrollView: UIScrollView!) -> CGFloat {
        return -100
    }
    
    func handleChangeToNormal(tag: Int) {
        
    }

}

extension RecordSuccessViewController: DidSelectPopViewCellDelegate {
    func didSelectRowAtIndexPath(_ indexPath: IndexPath) {
        index = indexPath.row
        tableView1.mj_header.beginRefreshing()
        statusIndexButton.setTitle(arrTitle[indexPath.row], for: .normal)
        popVc?.dismiss(animated: true, completion: {
            
        })
    }
}

extension RecordSuccessViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}

