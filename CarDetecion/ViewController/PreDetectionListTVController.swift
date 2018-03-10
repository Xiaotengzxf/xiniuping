//
//  PreDetectionListTVController.swift
//  CarDetecion
//
//  Created by 张晓飞 on 2017/5/2.
//  Copyright © 2017年 inewhome. All rights reserved.
//

import UIKit
import SwiftyJSON
import MJRefresh

class PreDetectionListTVController: UITableViewController {
    
    let preDetectionList = "external/app/getAppPreCarBillList.html"
    var curPage = 1
    var arrPreDetection : [JSON] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.mj_header = MJRefreshNormalHeader(refreshingBlock: { 
            [weak self] in
            self?.curPage = 1
            self?.getPreDetectionList()
        })
        tableView.mj_footer = MJRefreshBackNormalFooter(refreshingBlock: { 
            [weak self] in
            self?.curPage += 1
            self?.getPreDetectionList()
        })
        tableView.mj_footer.isHidden = true
        tableView.rowHeight = UITableViewAutomaticDimension
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.mj_header.beginRefreshing()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getPreDetectionList() {
        let username = UserDefaults.standard.string(forKey: "username")
        var params = ["userName" : username!]
        params["pageSize"] = "10"
        params["curPage"] = "\(curPage)"
        NetworkManager.sharedInstall.request(url: preDetectionList, params: params) {[weak self](json, error) in
            self?.tableView.mj_header.endRefreshing()
            self?.tableView.mj_footer.endRefreshing()
            if error != nil {
                print(error!.localizedDescription)
            }else{
                if let data = json , data["total"].intValue > 0 {
                    if self?.curPage == 1 {
                        self?.arrPreDetection.removeAll()
                    }
                    if let array = data["data"].array {
                        if array.count > 0 {
                            self?.tableView.mj_footer.isHidden = false
                        }
                        if self?.curPage == 1 && array.count < 10 {
                            self?.tableView.mj_footer.endRefreshingWithNoMoreData()
                        }
                        self?.arrPreDetection += array
                        self?.tableView.reloadData()
                    }
                }
            }
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return arrPreDetection.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)

        if let label = cell.contentView.viewWithTag(3) as? UILabel {
            label.text = "\(arrPreDetection[indexPath.row]["carBrandName"].stringValue) \(arrPreDetection[indexPath.row]["carSetName"].stringValue) \(arrPreDetection[indexPath.row]["carTypeName"].stringValue)"
        }
        if let label = cell.contentView.viewWithTag(4) as? UILabel {
            label.text = arrPreDetection[indexPath.row]["cityName"].string
        }
        if let label = cell.contentView.viewWithTag(5) as? UILabel {
            label.text = arrPreDetection[indexPath.row]["regDate"].string
        }
        if let label = cell.contentView.viewWithTag(6) as? UILabel {
            label.text = "\(arrPreDetection[indexPath.row]["runNum"].stringValue)公里"
        }
        if let label = cell.contentView.viewWithTag(7) as? UILabel {
            label.text = arrPreDetection[indexPath.row]["color"].string
        }
        if let label = cell.contentView.viewWithTag(8) as? UILabel {
            label.text = arrPreDetection[indexPath.row]["mark"].string
        }
//        if let imageView = cell.contentView.viewWithTag(4) as? UIImageView {
//            if let imageUrl = arrPreDetection[indexPath.row]["imageThumb"].string , imageUrl.hasPrefix("http") {
//                imageView.sd_setImage(with: URL(string: imageUrl)!, placeholderImage: UIImage(named: "ad_empty"))
//            }else{
//                imageView.image = UIImage(named: "ad_empty")
//            }
//            
//        }

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
