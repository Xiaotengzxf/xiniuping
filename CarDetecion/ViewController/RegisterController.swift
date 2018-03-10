//
//  RegisterController.swift
//  CarDetecion
//
//  Created by 张晓飞 on 2017/5/10.
//  Copyright © 2017年 inewhome. All rights reserved.
//

import UIKit
import WebKit

class RegisterController: UIViewController {

    var webView : WKWebView!
    let strUrl = "http://119.23.128.214:8080/carWeb/view/common/register.jsp"
    @IBOutlet weak var btnBack: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        webView = WKWebView()
        webView.load(URLRequest(url: URL(string: strUrl)!, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 30))
        webView.translatesAutoresizingMaskIntoConstraints = false
        self.view.insertSubview(webView, belowSubview: btnBack)
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[webView]|", options: .directionLeadingToTrailing, metrics: nil, views: ["webView" : webView]))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[webView]|", options: .directionLeadingToTrailing, metrics: nil, views: ["webView" : webView]))
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func doBack(_ sender: Any) {
        self.dismiss(animated: true) { 
            
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
