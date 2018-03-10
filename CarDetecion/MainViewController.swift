//
//  ViewController.swift
//  CarDetecion
//
//  Created by 张晓飞 on 2017/3/6.
//  Copyright © 2017年 inewhome. All rights reserved.
//

import UIKit
import SDCycleScrollView
import SwiftyJSON

class MainViewController: UIViewController , UITableViewDataSource , UITableViewDelegate , SDCycleScrollViewDelegate{
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var vNewsMore: UIView!
    
    let applyCount = "external/app/getApplyCountInfo.html"
    let latest = "external/pageelement/latestList.html"
    let news = "external/news/latestList.html"
    var banner : SDCycleScrollView?
    var arrBannerData : [JSON] = []
    var arrNewsData : [JSON] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        tableView.tableHeaderView?.frame = CGRect(x: 0, y: 0, width: WIDTH, height: 244 + 120)
        addBannerView()
        
        //getApplyCount() // 获取总单量
        
        loadNewsData()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(MainViewController.handleTap(recognizer:)))
        vNewsMore.addGestureRecognizer(tap)
        
        if #available(iOS 11.0, *) {
            tableView.contentInset = UIEdgeInsetsMake(-44, 0, 0, 0)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.lt_setBackgroundColor(backgroundColor: UIColor(red: 0, green: 0, blue: 0, alpha: 0))
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.navigationBar.lt_reset()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func addBannerView() -> Void {
        banner = SDCycleScrollView(frame: CGRect(x: 0, y: 120, width: WIDTH, height: 200), delegate: self, placeholderImage: nil)
        banner?.delegate = self
        tableView.tableHeaderView?.addSubview(banner!)
        loadBannerData()
    }
    
    // 获取审核中，未通过及通过的订单总数
    func getApplyCount() {
//        let username = UserDefaults.standard.string(forKey: "username")
//        let params = ["userName" : username!]
//        NetworkManager.sharedInstall.request(url: applyCount, params: params) {[weak self] (json, error) in
//            if error != nil {
//                print(error!.localizedDescription)
//            }else{
//                if let data = json , data["total"].intValue > 0 {
//                    if let array = data["data"].array {
//                        var totalCount = 0
//                        for j in array {
//                            
//                            if j["infoType"].stringValue == "finishCount" {
//                                totalCount += j["countInfo"].int ?? 0
//                            }else if j["infoType"].stringValue == "refuseCount" {
//                                totalCount += j["countInfo"].int ?? 0
//                            }else if j["infoType"].stringValue == "processCount" {
//                                totalCount += j["countInfo"].int ?? 0
//                            }
//                        }
//                        //self?.lblTotalCount.text = "总单量：\(totalCount)"
//                    }
//                }
//            }
//        }
    }
    
    func loadBannerData() {
        //http://119.23.128.214:8080/carWeb/external/pageelement/latestList.html?classType=%E8%BD%AE%E6%92%AD%E5%9B%BE
        NetworkManager.sharedInstall.request(url: latest, params: ["classType" : "轮播图"]) {[weak self] (json, error) in
            if error != nil {
                print(error!.localizedDescription)
            }else{
                if let data = json , data["total"].intValue > 0 {
                    if let array = data["data"].array {
                        self?.arrBannerData += array
                        var arrImageUrl : [String] = []
                        for item in array {
                            if let url = item["previewMedia"].string?.trimmingCharacters(in: .whitespacesAndNewlines) {
                                print(url)
                                arrImageUrl.append(url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)
                            }
                        }
                        self?.banner?.imageURLStringsGroup = arrImageUrl
                    }
                }
            }
        }
    }
    
    func loadNewsData() {
        //	GET /carWeb/external/news/latestList.html?classType=%E6%9C%80%E6%96%B0%E8%B5%84%E8%AE%AF HTTP/1.1
        NetworkManager.sharedInstall.request(url: news, params: ["classType" : "最新资讯"]) {[weak self] (json, error) in
            if error != nil {
                print(error!.localizedDescription)
            }else{
                if let data = json , data["total"].intValue > 0 {
                    if let array = data["data"].array {
                        self?.arrNewsData += array
                        self?.tableView.reloadData()
                    }
                }
            }
        }
    }
    
    func handleTap(recognizer : UITapGestureRecognizer) {
        if let controller = self.storyboard?.instantiateViewController(withIdentifier: "newslist") as? NewsListController {
            controller.title = "所有新闻"
            self.navigationController?.pushViewController(controller, animated: true)
        }
    }
    
    //	GET /carWeb/external/news/moreList.html?classType=%E6%9C%80%E6%96%B0%E8%B5%84%E8%AE%AF&curPage=1&pageSize=10 HTTP/1.1
    
    
    // MARK: - UITableView DataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrNewsData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if let controller = self.storyboard?.instantiateViewController(withIdentifier: "newsdetail") as? NewsDetailController {
            controller.title = "新闻详情"
            controller.json = arrNewsData[indexPath.row]
            self.navigationController?.pushViewController(controller, animated: true)
        }
    }
    
    // MARK: - SDCycleScrollViewDelegate
    func cycleScrollView(_ cycleScrollView: SDCycleScrollView!, didSelectItemAt index: Int) {
        if let controller = self.storyboard?.instantiateViewController(withIdentifier: "newsdetail") as? NewsDetailController {
            controller.title = "活动详情"
            controller.json = arrBannerData[index]
            self.navigationController?.pushViewController(controller, animated: true)
        }
    }

}

