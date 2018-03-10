//
//  CityTVController.swift
//  CarDetecion
//
//  Created by 张晓飞 on 2017/5/2.
//  Copyright © 2017年 inewhome. All rights reserved.
//

import UIKit
import SwiftyJSON

class CityTVController: UITableViewController {
    
    let cityUrl = "external/app/getCityList.html"
    var arrCity : [JSON] = []
    var nShowEmpty = 0 // 1 无数据 2 加载中 3 无网络
    var arrKey : [String] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        getCityList()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getCityList() {
        NetworkManager.sharedInstall.request(url: cityUrl, params: nil) {[weak self](json, error) in
            if error != nil {
                print(error!.localizedDescription)
                self?.nShowEmpty = 3
                self?.tableView.reloadData()
            }else{
                if let data = json , data["total"].intValue > 0 {
                    if let arr = data["data"].array {
                        self?.arrCity.removeAll()
                        self?.arrCity += arr
                        for jsonCity in arr {
                            if let city = jsonCity["provinceName"].string {
                                if !self!.arrKey.contains(city) {
                                    self!.arrKey.append(city)
                                }
                            }
                        }
                        self?.tableView.reloadData()
                    }else{
                        if self!.arrCity.count == 0 {
                            self?.nShowEmpty = 1
                            self?.tableView.reloadData()
                        }
                    }
                }else{
                    if self!.arrCity.count == 0 {
                        self?.nShowEmpty = 1
                        self?.tableView.reloadData()
                    }
                }
            }
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return arrKey.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return arrCity.filter{$0["provinceName"].stringValue == arrKey[section]}.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let arr = arrCity.filter{$0["provinceName"].stringValue == arrKey[indexPath.section]}
        let json = arr[indexPath.row]
        cell.textLabel?.text = json["cityName"].string
        cell.textLabel?.font = UIFont.systemFont(ofSize: 16)
        return cell
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return arrKey[section]
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let arr = arrCity.filter{$0["provinceName"].stringValue == arrKey[indexPath.section]}
        let json = arr[indexPath.row]
        NotificationCenter.default.post(name: Notification.Name("preDetection"), object: 2, userInfo: ["json" : json.dictionaryObject!])
        self.navigationController?.popViewController(animated: true)
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
