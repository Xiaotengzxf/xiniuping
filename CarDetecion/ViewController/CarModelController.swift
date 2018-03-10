//
//  CarModelController.swift
//  CarDetecion
//
//  Created by 张晓飞 on 2017/5/2.
//  Copyright © 2017年 inewhome. All rights reserved.
//

import UIKit
import SwiftyJSON
import DZNEmptyDataSet
import SDWebImage

class CarModelController: UIViewController , UITableViewDataSource , UITableViewDelegate , DZNEmptyDataSetSource , DZNEmptyDataSetDelegate{
    
    @IBOutlet weak var tableView: UITableView!
    let carType = "external/app/getCarBrandCommonList.html"
    let carSet = "external/app/getCarSetCommonList.html"
    let carType2 = "external/app/getCarTypeCommonList.html"
    var arrCarBrand : [JSON] = []
    var nShowEmpty = 0 // 1 无数据 2 加载中 3 无网络
    var arrKey : [String] = []
    var carBrandId = ""
    var carSetId = ""
    var carSetName = ""
    var brandName = ""
    var car1 : CarModelController?
    var car2 : CarModelController?

    override func viewDidLoad() {
        super.viewDidLoad()

        getCarTypeList()
        tableView.rowHeight = UITableViewAutomaticDimension
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getCarTypeList() {
        var params : [String : String]?
        if carBrandId.characters.count > 0 {
            params = ["carBrandId" : carBrandId]
        }
        if carSetId.characters.count > 0 {
            params?["carSetId"] = carSetId
        }
        var url = carType
        if carSetId.characters.count > 0 {
            url = carType2
        }else if carBrandId.characters.count > 0 {
            url = carSet
        }
        NetworkManager.sharedInstall.request(url: url, params: params) {[weak self](json, error) in
            if error != nil {
                print(error!.localizedDescription)
                self?.nShowEmpty = 3
                self?.tableView.reloadData()
            }else{
                if let data = json , data["total"].intValue > 0 {
                    if let arr = data["data"].array {
                        self?.arrCarBrand.removeAll()
                        self?.arrCarBrand += arr
                        for j in arr {
                            if self!.carSetId.characters.count > 0 {
                                if self!.arrKey.count == 0 {
                                    self?.arrKey.append("车型")
                                }
                            }else if self!.carBrandId.characters.count > 0 {
                                if let carSetFirstName = j["carSetFirstName"].string {
                                    if !self!.arrKey.contains(carSetFirstName) {
                                        self!.arrKey.append(carSetFirstName)
                                    }
                                }
                            }else{
                                if let carSetFirstName = j["brandFirstName"].string {
                                    if !self!.arrKey.contains(carSetFirstName) {
                                        self!.arrKey.append(carSetFirstName)
                                    }
                                }
                            }
                        }
                        self?.tableView.reloadData()
                    }else{
                        if self!.arrCarBrand.count == 0 {
                            self?.nShowEmpty = 1
                            self?.tableView.reloadData()
                        }
                    }
                }else{
                    if self!.arrCarBrand.count == 0 {
                        self?.nShowEmpty = 1
                        self?.tableView.reloadData()
                    }
                }
            }
        }
    }
    
    func addSelf() {
        if carSetId.characters.count > 0 {
            car2 = self.storyboard?.instantiateViewController(withIdentifier: "carmodel") as? CarModelController
            car2?.carSetId = carSetId
            car2?.carBrandId = carBrandId
            carSetId = ""
            car2?.brandName = brandName
            car2?.carSetName = carSetName
            self.addChildViewController(car2!)
            car2?.view.frame = CGRect(x: WIDTH, y: 0, width: WIDTH, height: HEIGHT - 64)
            self.view.addSubview(car2!.view)
            UIView.animate(withDuration: 0.3, animations: {
                [weak self] in
                self?.car2?.view.transform = CGAffineTransform(translationX: -WIDTH * 2 / 3, y: 0)
                }, completion: { (finished) in
                    
            })
        }else{
            car1 = self.storyboard?.instantiateViewController(withIdentifier: "carmodel") as? CarModelController
            car1?.carSetId = carSetId
            car1?.carBrandId = carBrandId
            carBrandId = ""
            car1?.brandName = brandName
            car1?.carSetName = carSetName
            self.addChildViewController(car1!)
            car1?.view.frame = CGRect(x: WIDTH, y: 64, width: WIDTH, height: HEIGHT - 64)
            self.view.addSubview(car1!.view)
            UIView.animate(withDuration: 0.3, animations: {
                [weak self] in
                self?.car1?.view.transform = CGAffineTransform(translationX: -WIDTH * 2 / 3, y: 0)
            }, completion: { (finished) in
                
            })
        }
    }

    // MARK: - Table view data source

    func numberOfSections(in tableView: UITableView) -> Int {
        return arrKey.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if carSetId.characters.count > 0 {
            return self.arrCarBrand.count
        }else if carBrandId.characters.count > 0 {
            return arrCarBrand.filter{$0["carSetFirstName"].stringValue == arrKey[section]}.count
        }else{
            return arrCarBrand.filter{$0["brandFirstName"].stringValue == arrKey[section]}.count
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! CarModelCell
        if  carSetId.characters.count > 0 {
            cell.lblCar?.text = arrCarBrand[indexPath.row]["carTypeName"].string
            cell.lcRight.constant = WIDTH / 3 - 20
            cell.ivIcon?.image = nil
            cell.lcLeft.constant = 16
        }else if carBrandId.characters.count > 0 {
            let arr = arrCarBrand.filter{$0["carSetFirstName"].stringValue == arrKey[indexPath.section]}
            let json = arr[indexPath.row]
            cell.lblCar?.text = json["carSetName"].string
            cell.ivIcon?.image = nil
            cell.lcLeft.constant = 16
        }else{
            let arr = arrCarBrand.filter{$0["brandFirstName"].stringValue == arrKey[indexPath.section]}
            let json = arr[indexPath.row]
            let strUrl = "\(NetworkManager.sharedInstall.domain)/external/source/autologos/\(json["brandName"].stringValue).jpg"
            if let url = URL(string:strUrl.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!) {
                cell.ivIcon?.sd_setImage(with: url, placeholderImage: UIImage(named: "ad_empty"))
            }else{
                cell.ivIcon?.image = UIImage(named: "ad_empty")
            }
            
            cell.lblCar?.text = json["brandName"].string
            cell.lcLeft.constant = 80
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return arrKey[section]
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if carSetId.characters.count > 0 {
            
            let json = arrCarBrand[indexPath.row]
            NotificationCenter.default.post(name: Notification.Name("preDetection"), object: 1, userInfo: ["json" : json.dictionaryObject!, "brandName" : brandName , "carSetName" : carSetName])
            self.navigationController?.popViewController(animated: true)
            
        }else {
            if carBrandId.characters.count == 0 {
                if car1 != nil {
                    UIView.animate(withDuration: 0.3, animations: {
                        [weak self] in
                        self?.car1?.view.transform = CGAffineTransform(translationX: WIDTH * 2 / 3, y: 0)
                        }, completion: {[weak self] (finished) in
                            self?.car1?.removeFromParentViewController()
                            self?.car1?.view.removeFromSuperview()
                            self?.car1 = nil
                            self?.carBrandId = ""
                    })
                }else{
                    let arr = arrCarBrand.filter{$0["brandFirstName"].stringValue == arrKey[indexPath.section]}
                    let json = arr[indexPath.row]
                    carBrandId = json["id"].stringValue
                    brandName = json["brandName"].stringValue
                    addSelf()
                }
                
            }else{
                if car2 != nil {
                    UIView.animate(withDuration: 0.3, animations: {
                        [weak self] in
                        self?.car2?.view.transform = CGAffineTransform(translationX: WIDTH * 2 / 3, y: 0)
                        }, completion: {[weak self] (finished) in
                            self?.car2?.removeFromParentViewController()
                            self?.car2?.view.removeFromSuperview()
                            self?.car2 = nil
                            self?.carSetId = ""
                    })
                }else{
                    let arr = arrCarBrand.filter{$0["carSetFirstName"].stringValue == arrKey[indexPath.section]}
                    let json = arr[indexPath.row]
                    carSetId = json["id"].stringValue
                    carSetName = json["carSetName"].stringValue
                    addSelf()
                }
            }
            
        }
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }

    func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        return index
    }
    
    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        if car1 == nil && car2 == nil  {
            return arrKey
        }else{
            return nil
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
