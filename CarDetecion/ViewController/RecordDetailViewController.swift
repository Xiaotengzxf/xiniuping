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

    @IBOutlet weak var lcSuggestionHieght: NSLayoutConstraint!
    @IBOutlet weak var lcTop: NSLayoutConstraint!
    @IBOutlet weak var lblPriceTip: UILabel!
    @IBOutlet weak var lblBillNo: UILabel!
    @IBOutlet weak var lblBillStatus: UILabel!
    @IBOutlet weak var lblPrice: UILabel!
    @IBOutlet weak var lblTime: UILabel!
    @IBOutlet weak var lblRemark: UILabel!
    @IBOutlet weak var vAllSuggestion: UIView!
    @IBOutlet weak var vContent: UIView!
    @IBOutlet weak var vZuLin: UIView!
    @IBOutlet weak var lblLeaseTerm: UILabel!
    @IBOutlet weak var lblLeasePrice: UILabel!
    @IBOutlet weak var lcPriceTop: NSLayoutConstraint!
    @IBOutlet weak var lcPriceTipTop: NSLayoutConstraint!
    var json : JSON!
    var statusInfo : [String : String]!
    var flag = 0
    var webView: WKWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        vContent.layer.borderWidth = 0.5
        vContent.layer.borderColor = UIColor(red: 230/255.0, green: 230/255.0, blue: 230/255.0, alpha: 1).cgColor
        self.view.backgroundColor = UIColor(red: 240/255.0, green: 240/255.0, blue: 240/255.0, alpha: 1)
        vContent.backgroundColor = UIColor(red: 240/255.0, green: 240/255.0, blue: 240/255.0, alpha: 1)
        
        lblBillNo.text = json["carBillId"].string
        lblBillStatus.text = statusInfo["\(json["status"].int ?? 0)"]
        lblPrice.text = "\(json["evaluatePrice"].int ?? 0)"
        lblTime.text = json["createTime"].string
        lblRemark.text = json["mark"].string?.removingPercentEncoding
        showWebView(htmlString: json["applyAllOpinion"].stringValue)
        if flag == 1 {
            lblPrice.isHidden = true
            lblPriceTip.isHidden = true
            let leaseTerm = json["leaseTerm"].int ?? 0
            let residualPrice = json["residualPrice"].int ?? 0
            if leaseTerm == 0 {
                vZuLin.isHidden = true
                lcTop.constant = 5-59-20-10
            }else{
                lblLeaseTerm.text = "\(leaseTerm)月"
                lblLeasePrice.text = "\(residualPrice)元"
                lcPriceTop.constant = -25
            }
        }else{
            let leaseTerm = json["leaseTerm"].int ?? 0
            let residualPrice = json["residualPrice"].int ?? 0
            if leaseTerm == 0 {
                vZuLin.isHidden = true
                lcTop.constant = 5-59
            }else{
                lblLeaseTerm.text = "\(leaseTerm)月"
                lblLeasePrice.text = "\(residualPrice)元"
            }
        }
        
        if let userinfo = UserDefaults.standard.object(forKey: "userinfo") as? [String : Any] {
            let userSuperCompany = userinfo["userSuperCompany"] as? Int ?? 0
            let userCompany = userinfo["userCompany"] as? Int ?? 0
            if userSuperCompany == 803 || userCompany == 803 { // 日产金融机器子公司
                lcPriceTipTop.constant = 0
                lblPriceTip.isHidden = true
                lblPrice.isHidden = true
            }
        }
        
    }
    
    func showWebView(htmlString : String) {
        if webView == nil {
            webView = WKWebView()
            webView.navigationDelegate = self
            webView.scrollView.isScrollEnabled = false
            webView.translatesAutoresizingMaskIntoConstraints = false
            vAllSuggestion.addSubview(webView!)
            vAllSuggestion.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[webView]-10-|", options: .directionLeadingToTrailing, metrics: nil, views: ["webView" : webView]))
            vAllSuggestion.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-10-[webView]-10-|", options: .directionLeadingToTrailing, metrics: nil, views: ["webView" : webView]))
            webView.loadHTMLString(htmlStringToHtml5(htmlString: htmlString), baseURL: nil)
        }
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        
        let js = "var script = document.createElement('script');script.type = 'text/javascript';script.text = \"function ResizeImages() { var myimg,oldwidth;for(i=0;i <document.images.length;i++){myimg = document.images[i];myimg.setAttribute('style','max-width:\(UIScreen.main.bounds.size.width - 60);height:auto')}}\";document.getElementsByTagName('head')[0].appendChild(script);"
        webView.evaluateJavaScript(js) { (height, error) in
            
        }
        
        webView.evaluateJavaScript("ResizeImages();") { (height, error) in
            
        }
        
        webView.evaluateJavaScript("document.body.offsetHeight;") {[weak self] (height, error) in
            if let fHeight = height as? CGFloat {
                self?.lcSuggestionHieght.constant = fHeight + 40
            }
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.lt_setBackgroundColor(backgroundColor: UIColor(red: 55/255.0, green: 70/255.0, blue: 85/255.0, alpha: 1))
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func htmlStringToHtml5(htmlString : String) -> String {
        return "<html><head><meta name=\"viewport\" content=\"width=device-width,initial-scale=1.0,user-scalable=no\"></head><body>\(htmlString.removingPercentEncoding ?? "")</body></html>"
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
