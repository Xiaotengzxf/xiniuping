//
//  Detection4TableViewCell.swift
//  CarDetecion
//
//  Created by 张晓飞 on 2017/6/21.
//  Copyright © 2017年 inewhome. All rights reserved.
//

import UIKit
import WebKit

class Detection4TableViewCell: UITableViewCell, WKNavigationDelegate {
    
    var webView : WKWebView!
    var delegate : Detection4TableViewCellDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func showWebView(htmlString : String) {
        if webView == nil {
            webView = WKWebView()
            webView.navigationDelegate = self
            webView.scrollView.isScrollEnabled = false
            webView.translatesAutoresizingMaskIntoConstraints = false
            self.addSubview(webView!)
            self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[webView]-10-|", options: .directionLeadingToTrailing, metrics: nil, views: ["webView" : webView]))
            self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-60-[webView]-10-|", options: .directionLeadingToTrailing, metrics: nil, views: ["webView" : webView]))
            webView.loadHTMLString(htmlStringToHtml5(htmlString: htmlString), baseURL: nil)
        }
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        
        let js = "var script = document.createElement('script');script.type = 'text/javascript';script.text = \"function ResizeImages() { var myimg,oldwidth;for(i=0;i <document.images.length;i++){myimg = document.images[i];myimg.setAttribute('style','max-width:\(UIScreen.main.bounds.size.width - 30);height:auto')}}\";document.getElementsByTagName('head')[0].appendChild(script);"
        webView.evaluateJavaScript(js) { (height, error) in
            
        }
        
        webView.evaluateJavaScript("ResizeImages();") { (height, error) in
            
        }
        
        webView.evaluateJavaScript("document.body.offsetHeight;") {[weak self] (height, error) in
            if let fHeight = height as? Float {
                self?.delegate?.getWebViewContentHeight(height: fHeight + 60)
            }
        }
        
    }
    
    func htmlStringToHtml5(htmlString : String) -> String {
        let html = "<html><head><meta name=\"viewport\" content=\"width=device-width,initial-scale=1.0,user-scalable=no\"></head><body>\(htmlString.removingPercentEncoding ?? "")</body></html>"
        return html
    }
    
    @IBAction func lookForAttach(sender: Any) {
        delegate?.lookForAttach()
    }

}

protocol Detection4TableViewCellDelegate {
    func getWebViewContentHeight(height : Float)
    func lookForAttach()
}
