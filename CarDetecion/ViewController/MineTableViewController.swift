//
//  MineTableViewController.swift
//  CarDetecion
//
//  Created by 张晓飞 on 2017/3/10.
//  Copyright © 2017年 inewhome. All rights reserved.
//

import UIKit

class MineTableViewController: UITableViewController {
    
    var titles : [[String]]!
    var icons : [[String]]!
    @IBOutlet weak var lblUsername: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        titles = [["个人资料"] , ["关于"] , ["账号退出"]] //"客服电话" ,
        icons = [["mine_info"] , ["mine_setting"] , ["mine_logout"]] //"mine_call" ,
        tableView.tableHeaderView?.frame = CGRect(x: 0, y: 0, width: WIDTH, height: WIDTH * 553/1080.0)
        tableView.tableFooterView = UIView()
        view.backgroundColor = UIColor(red: 245/255.0, green: 245/255.0, blue: 245/255.0, alpha: 1)
        
        if let userinfo = UserDefaults.standard.object(forKey: "userinfo") as? [String : Any] {
            lblUsername.text = userinfo["userChineseName"] as? String
        }
        
        let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? ""
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "V\(version)", style: .plain, target: nil, action: nil)
        
        if #available(iOS 11.0, *) {
            tableView.contentInset = UIEdgeInsetsMake(-64, 0, 0, 0)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.lt_setBackgroundColor(backgroundColor: UIColor(red: 0, green: 0, blue: 0, alpha: 0))
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.navigationBar.lt_reset()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return titles.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return titles[section].count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = titles[indexPath.section][indexPath.item]
        cell.imageView?.image = UIImage(named: icons[indexPath.section][indexPath.item])

        return cell
    }
 
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.section == 2 {
            showAlet(title: "提示", message: "您确定退出吗？")
        }else if indexPath.section == 1 {
            if indexPath.row == 0 {
                if let controller = self.storyboard?.instantiateViewController(withIdentifier: "default") as? DefaultViewController {
                    controller.title = "关于我们"
                    controller.hidesBottomBarWhenPushed = true
                    controller.flag = 1
                    self.navigationController?.pushViewController(controller, animated: true)
                }
            }else{
                makeCall(message: "075586962135")
            }
        }else{
            self.performSegue(withIdentifier: "info", sender: self)
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 10
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    func showAlet(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "取消", style: .cancel, handler: { (action) in
            
        }))
        alert.addAction(UIAlertAction(title: "退出", style: .default, handler: {[weak self] (action) in
            let chat = HChatClient.shared()
            if chat!.isLoggedInBefore {
                if let error = chat?.logout(true) {
                    print(error.description)
                }
            }
            UserDefaults.standard.removeObject(forKey: "userinfo")
            //UserDefaults.standard.removeObject(forKey: "username")
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let login = storyboard.instantiateViewController(withIdentifier: "login")
            self?.view?.window?.rootViewController = login
        }))
        present(alert, animated: true) { 
            
        }
    }
    
    func makeCall(message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "取消", style: .cancel, handler: { (action) in
            
        }))
        alert.addAction(UIAlertAction(title: "拨打", style: .default, handler: {(action) in
            UIApplication.shared.openURL(URL(string: "tel://\(message)")!)
        }))
        present(alert, animated: true) {
            
        }
    }

}
