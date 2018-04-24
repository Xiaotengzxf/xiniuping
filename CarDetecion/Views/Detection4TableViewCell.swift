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
            self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[webView]|", options: .directionLeadingToTrailing, metrics: nil, views: ["webView" : webView]))
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
                self?.delegate?.getWebViewContentHeight(height: fHeight)
            }
        }
        
    }
    
    func htmlStringToHtml5(htmlString : String) -> String {
        let html = "<html><head><meta name=\"viewport\" content=\"width=device-width,initial-scale=1.0,user-scalable=no\"></head><body style='font-size:12px'>\(replaceHtmlString(htmlString: htmlString).removingPercentEncoding ?? "")</body></html>"
        return html
    }
    
    /*String[] splits_1 = content.split("\\[");
     StringBuffer buffer = new StringBuffer("");
     int index;
     int spaceIndex;
     String split;
     for (int i = 0; i < splits_1.length - 1; i++) {
     split = splits_1[i];
     index = split.indexOf("]");
     
     spaceIndex = split.lastIndexOf(" ");
     if (spaceIndex != -1) {
     buffer.append(split.substring(0, spaceIndex));
     } else {
     buffer.append(split);
     }
     buffer.append(" [");
     
     }
     buffer.append(splits_1[splits_1.length - 1]);
     return buffer.toString();*/
    
    private func replaceHtmlString(htmlString: String) -> String {
        let array = htmlString.components(separatedBy: "[")
        if array.count > 0 {
            var str = ""
            for (index, var item) in array.enumerated() {
                if index < array.count - 1 {
                    if item.contains("]") {
                        if item.contains("驳回") {
                            str += "驳回"
                            let range = item.range(of: "]")
                            item = item.substring(from: range!.lowerBound)
                        }
                    }
                    let arr = item.components(separatedBy: " ")
                    if arr.count > 0 {
                        for (index, ite) in arr.enumerated() {
                            if index < arr.count - 1 {
                                str += ite
                                str += " "
                            }
                        }
                    } else {
                        str += item
                    }
                    str += " ["
                }
            }
            str += array.last!
            return str
        } else {
            return htmlString
        }
    }

}

protocol Detection4TableViewCellDelegate {
    func getWebViewContentHeight(height : Float)
}
