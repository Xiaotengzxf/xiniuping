//
//  ReUseHeaderFooterView.swift
//  CarDetecion
//
//  Created by 张晓飞 on 2017/3/29.
//  Copyright © 2017年 inewhome. All rights reserved.
//

import UIKit

class ReUseHeaderFooterView: UITableViewHeaderFooterView {

    @IBOutlet weak var lblTitle: UILabel!
    weak var delegate: ReUseHeaderFooterViewDelegate?
    @IBOutlet weak var btnReject: UIButton!
    
    @IBAction func showRejectView(_ sender: Any) {
        delegate?.showRejectView()
    }
}

protocol ReUseHeaderFooterViewDelegate: NSObjectProtocol {
    func showRejectView()
}
