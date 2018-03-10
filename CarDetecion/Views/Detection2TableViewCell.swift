//
//  Detection2TableViewCell.swift
//  CarDetecion
//
//  Created by 张晓飞 on 2017/4/3.
//  Copyright © 2017年 inewhome. All rights reserved.
//

import UIKit

class Detection2TableViewCell: UITableViewCell , UITextViewDelegate {

    @IBOutlet weak var tvMark: PlaceholderTextView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if let text = textView.text?.trimmingCharacters(in: .whitespacesAndNewlines) , text.characters.count > 0 {
            NotificationCenter.default.post(name: Notification.Name("fastpredetection"), object: 2, userInfo: ["text" : text])
            // detectionnew
            NotificationCenter.default.post(name: Notification.Name("detectionnew"), object: 2, userInfo: ["text" : text])
        }
    }

}
