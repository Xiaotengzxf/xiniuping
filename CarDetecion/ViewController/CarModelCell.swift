//
//  CarModelCell.swift
//  CarDetecion
//
//  Created by 张晓飞 on 2017/5/2.
//  Copyright © 2017年 inewhome. All rights reserved.
//

import UIKit

class CarModelCell: UITableViewCell {

    @IBOutlet weak var lblCar: UILabel!
    @IBOutlet weak var lcRight: NSLayoutConstraint!
    @IBOutlet weak var lcLeft: NSLayoutConstraint!
    @IBOutlet weak var ivIcon: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
