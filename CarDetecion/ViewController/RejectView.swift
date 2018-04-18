//
//  RejectView.swift
//  CarDetecion
//
//  Created by 张晓飞 on 2018/3/15.
//  Copyright © 2018年 inewhome. All rights reserved.
//

import UIKit
import WebKit

class RejectView: UIView, WKNavigationDelegate {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    @IBOutlet weak var contentView: UIView!
    weak var delegate: RejectViewDelegate?
    var webView : WKWebView!
    
    @IBAction func hideRejectView(_ sender: Any) {
        delegate?.hideRejectView()
    }
    
    func showWebView(htmlString : String) {
        if webView == nil {
            webView = WKWebView()
            webView.navigationDelegate = self
            webView.scrollView.isScrollEnabled = false
            webView.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview(webView!)
            contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[webView]-10-|", options: .directionLeadingToTrailing, metrics: nil, views: ["webView" : webView]))
            contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-50-[webView]-74-|", options: .directionLeadingToTrailing, metrics: nil, views: ["webView" : webView]))
            webView.loadHTMLString(htmlStringToHtml5(htmlString: htmlString), baseURL: nil)
        }
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        
        let js = "var script = document.createElement('script');script.type = 'text/javascript';script.text = \"function ResizeImages() { var myimg,oldwidth;for(i=0;i <document.images.length;i++){myimg = document.images[i];myimg.setAttribute('style','max-width:\(UIScreen.main.bounds.size.width - 30);height:auto')}}\";document.getElementsByTagName('head')[0].appendChild(script);"
        webView.evaluateJavaScript(js) { (height, error) in
            
        }
        
        webView.evaluateJavaScript("ResizeImages();") { (height, error) in
            
        }
        
//        webView.evaluateJavaScript("document.body.offsetHeight;") {[weak self] (height, error) in
//            if let fHeight = height as? Float {
//                self?.delegate?.getWebViewContentHeight(height: fHeight + 60)
//            }
//        }
        
    }
    
    func htmlStringToHtml5(htmlString : String) -> String {
        let html = "<html><head><meta name=\"viewport\" content=\"width=device-width,initial-scale=1.0,user-scalable=no\"></head><body>\(htmlString.removingPercentEncoding ?? "")</body></html>"
        return html
    }
    
}

protocol RejectViewDelegate: NSObjectProtocol {
    func hideRejectView()
}
