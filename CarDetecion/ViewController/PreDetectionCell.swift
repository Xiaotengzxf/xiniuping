//
//  PreDetectionCell.swift
//  CarDetecion
//
//  Created by 张晓飞 on 2017/5/1.
//  Copyright © 2017年 inewhome. All rights reserved.
//

import UIKit

class PreDetectionCell: UITableViewCell {

    @IBOutlet weak var ivIcon: UIImageView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var ivArrow: UIImageView!
    @IBOutlet weak var lblContent: UILabel!
    @IBOutlet weak var tfContent: UITextField!
    @IBOutlet weak var tvContent: UITextView!
    @IBOutlet weak var lcIconWidth: NSLayoutConstraint!
    @IBOutlet weak var lcIconHeight: NSLayoutConstraint!
    @IBOutlet weak var lcContentWidth: NSLayoutConstraint!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
