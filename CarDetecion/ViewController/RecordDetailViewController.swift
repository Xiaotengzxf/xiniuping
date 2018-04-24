//
//  RecordDetailViewController.swift
//  CarDetecion
//
//  Created by 张晓飞 on 2017/4/15.
//  Copyright © 2017年 inewhome. All rights reserved.
//

import UIKit
import SwiftyJSON
import WebKit

class RecordDetailViewController: UIViewController, WKNavigationDelegate {

    @IBOutlet weak var lblBillNo: UILabel! // 单号
    @IBOutlet weak var lblBrand: UILabel! // 品牌
    @IBOutlet weak var lblStrain: UILabel! // 车系
    @IBOutlet weak var lblCarType: UILabel! // 车型
    @IBOutlet weak var lblKM: UILabel! // 使用公里数
    @IBOutlet weak var lblTime: UILabel! // 登记日期
    @IBOutlet weak var lblPrice: UILabel! // 新车参考价
    @IBOutlet weak var vContent: UIView!
    @IBOutlet weak var lblPrePrice: UILabel! // 评估价格
    @IBOutlet weak var lblPreTime: UILabel! // 评估日期
    
    var json : JSON!
    var statusInfo : [String : String]!
    var flag = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        lblBillNo.text = json["carBillId"].string
        lblBrand.text = json["carBrandName"].string
        lblStrain.text = json["carSetName"].string
        lblCarType.text = json["carTypeName"].string
        lblKM.text = json["runNum"].string
        lblTime.text = json["regDate"].string
        lblPrice.text = format(price: json["newCarPrice"].int ?? 0)
        lblTime.text = json["createTime"].string
        lblPrePrice.text = format(price: json["evaluatePrice"].int ?? 0)
        lblPreTime.text = "评估日期：\(json["evaluateDate"].string ?? "")"
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func format(price: Int) -> String {
        let format = NumberFormatter()
        format.numberStyle = .currency
        return  format.string(from: NSNumber(value: price)) ?? ""
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    /* {
     applyAllOpinion = "2017-05-24 10:12:28 \U9ad8\U8bc4-\U6731\U9e4f[\U9ad8\U8bc4-\U901a\U8fc7]: <br /><br />2017-05-24 10:10:20 \U4e2d\U8bc4-\U5f20\U78ca[\U4e2d\U8bc4-\U901a\U8fc7]: <br /><br />2017-05-24 10:07:10 \U521d\U8bc4-\U827e\U5f6a[\U521d\U8bc4-\U901a\U8fc7]: <br /><br />2017-05-24 09:43:56 Moth[\U91c7\U96c6]: <br /><br />null";
     applyCarBillId = "<null>";
     applyResult = "<null>";
     applyResultName = "<null>";
     carBillId = NS201705240002;
     carBrandId = "<null>";
     carBrandName = "<null>";
     carDisplace = "<null>";
     carFrameNum = "<null>";
     carNo = "<null>";
     carSetId = "<null>";
     carSetName = "<null>";
     carTypeId = "<null>";
     carTypeName = "<null>";
     carUserName = "<null>";
     companyId = "<null>";
     companyName = "<null>";
     consumeTime = "<null>";
     createTime = "2017-05-24 09:43:40";
     createUser = "<null>";
     createUserName = "<null>";
     csTime = "<null>";
     curApplyOpinion = "<null>";
     curOperator = "<null>";
     curOperatorName = "<null>";
     evaluateDate = "<null>";
     evaluatePrice = 193833;
     imageNum = "<null>";
     imageThumbPath = "/source/upload/users/9/2017/05/24/moth/NS201705240002/thumb_cut_4020cc43eb834ff98080762180bb2d3f.jpeg";
     leaseTerm = 0;
     mark = "";
     modifyTime = "2017-05-24 10:12:28";
     modifyUser = "<null>";
     nextUser = "<null>";
     nextUserName = "<null>";
     preSalePrice = 90000;
     productionDate = "<null>";
     province = "<null>";
     provinceName = "<null>";
     regDate = "<null>";
     residualPrice = 0;
     runNum = "<null>";
     status = 54;
     statusName = "<null>";
     webchat = "<null>";
     zsTime = "<null>";
     }
*/
    
}
