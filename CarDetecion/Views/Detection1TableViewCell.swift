//
//  Detextion1TableViewCell.swift
//  CarDetecion
//
//  Created by 张晓飞 on 2017/4/3.
//  Copyright © 2017年 inewhome. All rights reserved.
//

import UIKit

class Detection1TableViewCell: UITableViewCell , UITextFieldDelegate {

    @IBOutlet weak var tfPrice: UITextField!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if let text = textField.text?.trimmingCharacters(in: .whitespacesAndNewlines) , text.characters.count > 0 {
            NotificationCenter.default.post(name: Notification.Name("detectionnew"), object: 1, userInfo: ["text" : text])
        }
    }

}
