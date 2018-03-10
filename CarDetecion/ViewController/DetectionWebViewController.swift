//
//  DetectionWebViewController.swift
//  CarDetecion
//
//  Created by 张晓飞 on 2017/7/15.
//  Copyright © 2017年 inewhome. All rights reserved.
//

import UIKit
import WebKit

class DetectionWebViewController: UIViewController {

    var webView : WKWebView!
    var strUrl = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //创建wkwebview
        webView = WKWebView()
        webView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(webView)
        let username = UserDefaults.standard.string(forKey: "username")
        let url = URL(string: strUrl)
        webView.load(URLRequest(url: url!))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[webView]|", options: .directionLeadingToTrailing, metrics: nil, views: ["webView" : webView]))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[webView]|", options: .directionLeadingToTrailing, metrics: nil, views: ["webView" : webView]))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.lt_setBackgroundColor(backgroundColor: UIColor(red: 55/255.0, green: 70/255.0, blue: 85/255.0, alpha: 1))
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
