//
//  NewsListController.swift
//  CarDetecion
//
//  Created by 张晓飞 on 2017/5/6.
//  Copyright © 2017年 inewhome. All rights reserved.
//

import UIKit
import SwiftyJSON
import MJRefresh
import DZNEmptyDataSet

class NewsListController: UITableViewController , DZNEmptyDataSetSource , DZNEmptyDataSetDelegate{
    
    let moreList = "external/news/moreList.html"
    var arrNewsData : [JSON] = []
    var curPage = 1
    var pageSize = 10
    var nShowEmpty = 0 // 1 无数据 2 加载中 3 无网络

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.mj_header = MJRefreshNormalHeader(refreshingBlock: { 
            [weak self] in
            self?.curPage = 1
            self?.loadNewsData()
        })
        self.tableView.mj_footer = MJRefreshAutoNormalFooter(refreshingBlock: {
            [weak self] in
            self?.curPage += 1
            self?.loadNewsData()
        })
        self.tableView.mj_header.beginRefreshing()
        self.tableView.mj_footer.isHidden = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.lt_setBackgroundColor(backgroundColor: UIColor(red: 55/255.0, green: 70/255.0, blue: 85/255.0, alpha: 1))
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loadNewsData() {
        //		GET /carWeb/external/news/moreList.html?classType=%E6%9C%80%E6%96%B0%E8%B5%84%E8%AE%AF&curPage=1&pageSize=10 HTTP/1.1
        var params : [String : String] = [:]
        params["classType"] = "最新资讯"
        params["curPage"] = "\(curPage)"
        params["pageSize"] = "\(pageSize)"
        
        NetworkManager.sharedInstall.request(url: moreList, params: params) {[weak self] (json, error) in
            self?.tableView.mj_header.endRefreshing()
            self?.tableView.mj_footer.endRefreshing()
            if error != nil {
                print(error!.localizedDescription)
                if self!.curPage == 1 {
                    self!.nShowEmpty = 3
                    self!.tableView.reloadData()
                }
            }else{
                if let data = json , data["total"].intValue > 0 {
                    if let array = data["data"].array {
                        if self!.curPage == 1 {
                            self!.arrNewsData.removeAll()
                        }
                        if self!.curPage == 1 && array.count == 0 {
                            self!.nShowEmpty = 1
                        }
                        if array.count > 0 {
                            self!.tableView.mj_footer.isHidden = false
                            if array.count < self!.pageSize {
                                self!.tableView.mj_footer.endRefreshingWithNoMoreData()
                            }
                        }
                        self?.arrNewsData += array
                        self?.tableView.reloadData()
                    }
                }else{
                    if self!.curPage == 1 {
                        self!.nShowEmpty = 1
                        self!.tableView.reloadData()
                    }
                }
            }
        }
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrNewsData.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        if let imageView = cell.contentView.viewWithTag(2) as? UIImageView {
            imageView.sd_setImage(with: URL(string: arrNewsData[indexPath.row]["imageThumb"].stringValue), placeholderImage: UIImage(named: "defult_image"))
        }
        if let label = cell.contentView.viewWithTag(3) as? UILabel {
            label.text = arrNewsData[indexPath.row]["title"].string
        }
        if let label = cell.contentView.viewWithTag(4) as? UILabel {
            label.text = arrNewsData[indexPath.row]["createTime"].string
        }
        if let label = cell.contentView.viewWithTag(5) as? UILabel {
            label.text = arrNewsData[indexPath.row]["shortContent"].string
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if let controller = self.storyboard?.instantiateViewController(withIdentifier: "newsdetail") as? NewsDetailController {
            controller.title = "新闻详情"
            controller.json = arrNewsData[indexPath.row]
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
        //        if nShowEmpty > 0 {
        //            nShowEmpty = 0
        //            tableView.reloadData()
        //            tableView.mj_header.beginRefreshing()
        //        }
    }
    
    func emptyDataSetShouldDisplay(_ scrollView: UIScrollView!) -> Bool {
        return nShowEmpty > 0
    }

}
