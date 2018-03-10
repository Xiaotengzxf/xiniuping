//
//  PreDetectionTVController.swift
//  CarDetecion
//
//  Created by 张晓飞 on 2017/5/1.
//  Copyright © 2017年 inewhome. All rights reserved.
//

import UIKit
import SwiftyJSON
import DatePickerDialog
import Toaster

class PreDetectionTVController: UITableViewController {
    
    var arrIcon = ["icon_pinpai", "icon_licheng", "icon_shijian", "icon_licheng", "icon_weizhi"]
    var arrTitle = ["品牌车型", "车颜色", "上牌时间", "行驶里程", "选择城市", "备注输入"]
    var tabPage : TabPageViewController?
    var carType : JSON?
    var city : JSON?
    var strDate = ""
    let submitPre = "external/app/addPreCarBill.html"
    var carSetName = ""
    var brandName = ""

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.tableFooterView?.frame = CGRect(x: 0, y: 0, width: WIDTH, height: 64)
        NotificationCenter.default.addObserver(self, selector: #selector(PreDetectionTVController.handleNotification(notification:)), name: Notification.Name("preDetection"), object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func handleNotification(notification : Notification) {
        if let tag = notification.object as? Int {
            if let userInfo = notification.userInfo as? [String : Any] {
                if tag == 1 {
                    carType = JSON(userInfo["json"]!)
                    tableView.reloadData()
                    carSetName = userInfo["carSetName"] as? String ?? ""
                    brandName = userInfo["brandName"] as? String ?? ""
                }else if tag == 2 {
                    city = JSON(userInfo["json"]!)
                    tableView.reloadData()
                }
            }
        }
    }

    @IBAction func doSubmit(_ sender: Any) {
        self.view.endEditing(true)
        if carType == nil {
            Toast(text: "请选择品牌车型").show()
            return
        }
        var cell = tableView.cellForRow(at: IndexPath(row: 1, section: 0)) as! PreDetectionCell
        let carColor = cell.tfContent.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        if carColor == nil || carColor!.characters.count == 0 {
            Toast(text: "请输入车颜色").show()
            return
        }
        if strDate.characters.count == 0 {
            Toast(text: "请选择上牌时间").show()
            return
        }
        cell = tableView.cellForRow(at: IndexPath(row: 3, section: 0)) as! PreDetectionCell
        let gongli = cell.tfContent.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        if gongli == nil || gongli!.characters.count == 0 {
            Toast(text: "请输入公里数").show()
            return
        }
        if city == nil {
            Toast(text: "请选择上牌城市").show()
            return
        }
        cell = tableView.cellForRow(at: IndexPath(row: 5, section: 0)) as! PreDetectionCell
        let remark = cell.tvContent.text.trimmingCharacters(in: .whitespacesAndNewlines)
    
        let username = UserDefaults.standard.string(forKey: "username")
        var params = ["createUser" : username!]
        params["carTypeId"] = carType!["id"].stringValue
        params["cityId"] = city!["code"].stringValue
        params["color"] = carColor!
        params["regDate"] = strDate
        let fomatter = DateFormatter()
        fomatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        params["createTime"] = fomatter.string(from: Date())
        params["runNum"] = gongli
        params["mark"] = remark.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        params["clientName"] = "iOS"
        let hud = self.showHUD(text: "提交中...")
        NetworkManager.sharedInstall.request(url: submitPre, params: params) {[weak self] (json, error) in
            self?.hideHUD(hud: hud)
            if error != nil {
                print(error!.localizedDescription)
            }else{
                if let data = json , data["success"].boolValue {
                    Toast(text: "提交成功").show()
                    self?.tabPage?.navigationController?.popViewController(animated: true)
                }else{
                    if let message = json?["message"].string {
                        Toast(text: message).show()
                    }
                }
            }
        }
    }
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrTitle.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! PreDetectionCell
        if indexPath.row < 5 {
            cell.ivIcon.image = UIImage(named: arrIcon[indexPath.row])
        }else{
            cell.ivIcon.image = nil
        }
        cell.lblTitle.text = arrTitle[indexPath.row]
        switch indexPath.row {
        case 0:
            cell.ivArrow.isHidden = false
            cell.tfContent.isHidden = true
            cell.lblContent.isHidden = false
            cell.tvContent.isHidden = true
            if carType != nil {
                cell.lblContent.text = brandName + carSetName + carType!["carTypeName"].stringValue
            }else{
                cell.lblContent.text = "请选择品牌车型"
            }
            cell.tfContent.rightView = nil
            cell.lcIconWidth.constant = 30
            cell.lcIconHeight.constant = 22
        case 1:
            cell.ivArrow.isHidden = true
            cell.tfContent.isHidden = false
            cell.lblContent.isHidden = true
            cell.tvContent.isHidden = true
            cell.tfContent.attributedPlaceholder = NSAttributedString(string: "请输入车颜色", attributes: [NSForegroundColorAttributeName : UIColor.darkGray])
            cell.tfContent.keyboardType = .default
            cell.tfContent.rightView = nil
            cell.lcIconWidth.constant = 28
            cell.lcIconHeight.constant = 24
        case 2:
            cell.ivArrow.isHidden = false
            cell.tfContent.isHidden = true
            cell.lblContent.isHidden = false
            cell.tvContent.isHidden = true
            if strDate.characters.count > 0 {
                cell.lblContent.text = strDate
            }else{
                cell.lblContent.text = "请选择上牌时间"
            }
            cell.tfContent.rightView = nil
            cell.lcIconWidth.constant = 35
            cell.lcIconHeight.constant = 31
        case 3:
            cell.ivArrow.isHidden = true
            cell.tfContent.isHidden = false
            cell.lblContent.isHidden = true
            cell.tvContent.isHidden = true
            cell.tfContent.attributedPlaceholder = NSAttributedString(string: "请输入", attributes: [NSForegroundColorAttributeName : UIColor.darkGray])
            cell.tfContent.keyboardType = .numbersAndPunctuation
            if cell.tfContent.rightView == nil {
                let label = UILabel()
                label.text = "公里"
                label.textColor = UIColor.black
                label.font = UIFont.systemFont(ofSize: 14)
                label.bounds = CGRect(x: 0, y: 0, width: 30, height: 20)
                cell.tfContent.rightView = label
                cell.tfContent.rightViewMode = .always
            }
            cell.lcIconWidth.constant = 28
            cell.lcIconHeight.constant = 24
        case 4:
            cell.ivArrow.isHidden = false
            cell.tfContent.isHidden = true
            cell.lblContent.isHidden = false
            cell.tvContent.isHidden = true
            if city != nil {
                cell.lblContent.text = city?["cityName"].string
            }else{
                cell.lblContent.text = "请选择上牌城市"
            }
            
            cell.tfContent.rightView = nil
            cell.lcIconWidth.constant = 30
            cell.lcIconHeight.constant = 37
        default:
            cell.ivArrow.isHidden = true
            cell.tfContent.isHidden = true
            cell.lblContent.isHidden = true
            cell.tvContent.isHidden = false
            cell.tfContent.rightView = nil
        }

        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 5 {
            return 100
        }else{
            return 60
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.row == 0 {
            if let controller = self.storyboard?.instantiateViewController(withIdentifier: "carmodel") as? CarModelController {
                controller.title = "车型"
                tabPage?.navigationController?.pushViewController(controller, animated: true)
            }
        }else if indexPath.row == 4 {
            if let controller = self.storyboard?.instantiateViewController(withIdentifier: "city") as? CityTVController {
                controller.title = "选择城市"
                tabPage?.navigationController?.pushViewController(controller, animated: true)
            }
        }else if indexPath.row == 2 {
            var date = Date()
            date = date.addingTimeInterval(-60 * 60 * 24 * 365 * 5)
            DatePickerDialog().show(title: "请选择上牌时间", doneButtonTitle: "确定", cancelButtonTitle: "取消", minimumDate:date, maximumDate: Date() , datePickerMode: .date) {
                [weak self] (date) -> Void in
                if date != nil {
                    self?.strDate = date ?? ""
                    self?.tableView.reloadData()
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

}
