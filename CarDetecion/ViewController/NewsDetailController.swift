//
//  NewsDetailController.swift
//  CarDetecion
//
//  Created by 张晓飞 on 2017/5/6.
//  Copyright © 2017年 inewhome. All rights reserved.
//

import UIKit
import SwiftyJSON
import WebKit

class NewsDetailController: UIViewController {

    var json : JSON?
    let pageDetail = "external/pageelement/pageDetail.html"
    let newsDetail = "external/news/newsDetail.html"
    var webView : WKWebView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblTime: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if title == "新闻详情" {
            lblTitle.text = json?["title"].string
        } else {
            lblTitle.text = json?["elementName"].string
        }
        lblTime.text = "时间：\(json?["createTime"].string ?? "")"
        //创建wkwebview
        webView = WKWebView()
        webView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(webView)
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[webView]|", options: .directionLeadingToTrailing, metrics: nil, views: ["webView" : webView]))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[lblTime]-20-[webView]|", options: .directionLeadingToTrailing, metrics: nil, views: ["webView" : webView , "lblTime" : lblTime]))
        loadDetailData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.lt_setBackgroundColor(backgroundColor: UIColor(red: 55/255.0, green: 70/255.0, blue: 85/255.0, alpha: 1))
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loadDetailData() {
        NetworkManager.sharedInstall.request(url: title == "新闻详情" ? newsDetail : pageDetail, params: title == "新闻详情" ? ["newsId" : json!["id"].intValue] : ["id" : json!["id"].intValue] ) {[weak self] (json, error) in
            if error != nil {
                print(error!.localizedDescription)
            }else{
                if let data = json {
                    if self!.title == "新闻详情" {
//                        do{
//                            let attributeString =  try NSAttributedString(data: data["content"].stringValue.data(using: String.Encoding.unicode, allowLossyConversion: true)!, options: [NSDocumentTypeDocumentAttribute : NSHTMLTextDocumentType], documentAttributes: nil)
//                            self?.lblContent.attributedText = attributeString
//                        }catch{
//                            
//                        }
                        self!.webView.loadHTMLString(data["content"].stringValue, baseURL: nil)
                    }else {
                        self!.webView.loadHTMLString(data["detailContent"].stringValue, baseURL: nil)
                        //self?.lblContent.text = data["detailContent"].string
                    }
                    
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
