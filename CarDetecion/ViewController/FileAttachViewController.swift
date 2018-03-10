//
//  FileAttachViewController.swift
//  CarDetecion
//
//  Created by 张晓飞 on 2017/9/17.
//  Copyright © 2017年 inewhome. All rights reserved.
//

import UIKit
import DZNEmptyDataSet
import SwiftyJSON
import Toaster
import MJRefresh
import SDWebImage
import SKPhotoBrowser

class FileAttachViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {

    @IBOutlet weak var collectionView: UICollectionView!
    let getAttachFiles = "external/app/getAttachFiles.html"
    var arrData : [JSON] = []
    var bEmptyShow = false
    var curPage = 1
    var carId = ""
    var status = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView.mj_header = MJRefreshNormalHeader(refreshingBlock: { 
            [weak self] in
            self?.curPage = 1
            self?.arrData.removeAll()
            self?.loadData()
        })
        
        collectionView.mj_footer = MJRefreshBackNormalFooter(refreshingBlock: { 
            [weak self] in
            self?.curPage += 1
            self?.loadData()
        })
        
        collectionView.mj_header.beginRefreshing()
        collectionView.mj_footer.isHidden = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loadData() {
        let hud = self.showHUD(text: "加载中...")
        let username = UserDefaults.standard.string(forKey: "username")
        NetworkManager.sharedInstall.request(url: getAttachFiles, params: ["userName" : username! , "carBillId": carId, "clientName" : "iOS", "curPage" : curPage,"pageSize": 50, "status": status]) {[weak self] (json, error) in
            self?.collectionView.mj_header.endRefreshing()
            self?.collectionView.mj_footer.endRefreshing()
            self?.hideHUD(hud: hud)
            if error != nil {
                Toast(text: "网络故障，请检查网络").show()
            }else{
                if let data = json {
                    if let total = data["total"].int, total > 0 {
                        if let array = data["data"].array {
                            self?.arrData += array
                        }
                        if total > self!.curPage * 50 {
                            self?.collectionView.mj_footer.isHidden = false
                        }
                        if total <= self!.curPage * 50 {
                            self?.collectionView.mj_footer.endRefreshingWithNoMoreData()
                        }
                    }else{
                        if self!.curPage == 1 {
                            self?.bEmptyShow = true
                        }
                    }
                    self?.collectionView.reloadData()
                    
                }else{
                    if let message = json?["message"].string {
                        Toast(text: message).show()
                    }
                }
            }
        }
    }
    
    // MARK: - Collection view data source
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arrData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath)
        if let imageView = cell.viewWithTag(2) as? UIImageView {
            imageView.sd_setImage(with: URL(string: arrData[indexPath.row]["attachmentURL"].stringValue), placeholderImage: UIImage(named: "ad_empty"))
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        
        var images = [SKPhoto]()
        let photo = SKPhoto.photoWithImageURL(arrData[indexPath.row]["attachmentURL"].stringValue, holder: UIImage(named: "ad_empty"))
        images.append(photo)
        SKPhotoBrowserOptions.displayAction = false
        SKPhotoBrowserOptions.displayCloseButton = false
        let browser = SKPhotoBrowser(photos: images)
        browser.view.backgroundColor = UIColor.white
        browser.title = "大图浏览"
        self.navigationController?.pushViewController(browser, animated: true)
    }
    
    // MARK: - Collection view delegate
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (WIDTH - 30) / 2, height: (WIDTH - 30) / 2)
    }
    
    // MARK: - Empty
    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        return NSAttributedString(string: "没有数据") 
    }
    
    func emptyDataSetShouldDisplay(_ scrollView: UIScrollView!) -> Bool {
        return bEmptyShow
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
