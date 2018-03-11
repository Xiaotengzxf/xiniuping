//
//  DefaultViewController.swift
//  CarDetecion
//
//  Created by 张晓飞 on 2017/4/5.
//  Copyright © 2017年 inewhome. All rights reserved.
//

import UIKit

class DefaultViewController: UIViewController {
    
    var flag = 0

    override func viewDidLoad() {
        super.viewDidLoad()

        if flag == 0 {
            self.perform(#selector(DefaultViewController.changeWindowRoot), with: nil, afterDelay: 3)
        }else{
            
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func changeWindowRoot() {
        if let tab = self.storyboard?.instantiateViewController(withIdentifier: "tab") {
            self.view.window?.rootViewController = tab
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
