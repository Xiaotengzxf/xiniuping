//
//  Detection3TableViewCell.swift
//  CarDetecion
//
//  Created by 张晓飞 on 2017/6/11.
//  Copyright © 2017年 inewhome. All rights reserved.
//

import UIKit

class Detection3TableViewCell: UITableViewCell {

    @IBOutlet weak var btn1: UIButton!
    @IBOutlet weak var btn2: UIButton!
    @IBOutlet weak var btn3: UIButton!
    @IBOutlet weak var btn4: UIButton!
    weak var delegate : Detection3TableViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @IBAction func radioSelected(_ sender: Any) {
        if let button = sender as? UIButton {
            let tag = button.tag
            btn1.isSelected = (tag == 1)
            btn2.isSelected = (tag == 2)
            btn3.isSelected = (tag == 3)
            btn4.isSelected = (tag == 4)
            delegate?.selectedItem(tag: tag - 1)
        }
    }
}

@objc protocol Detection3TableViewCellDelegate {
    func selectedItem(tag : Int)
}

