//
//  DetectionTableViewCell.swift
//  CarDetecion
//
//  Created by 张晓飞 on 2017/3/30.
//  Copyright © 2017年 inewhome. All rights reserved.
//

import UIKit

class DetectionTableViewCell: UITableViewCell {

    @IBOutlet weak var vCamera1: UIView!
    @IBOutlet weak var vCamera2: UIView!
    @IBOutlet weak var vCamera3: UIView!
    @IBOutlet weak var iv1: UIImageView!
    @IBOutlet weak var iv2: UIImageView!
    @IBOutlet weak var iv3: UIImageView!
    @IBOutlet weak var iv11: UIImageView!
    @IBOutlet weak var iv21: UIImageView!
    @IBOutlet weak var iv31: UIImageView!
    @IBOutlet weak var lbl1: UILabel!
    @IBOutlet weak var lbl2: UILabel!
    @IBOutlet weak var lbl3: UILabel!
    @IBOutlet weak var lbl11: UILabel!
    @IBOutlet weak var lbl22: UILabel!
    @IBOutlet weak var lbl33: UILabel!
    var tap1 : UITapGestureRecognizer?
    var tap2 : UITapGestureRecognizer?
    var indexPath : IndexPath!
    var delegate : DetectionTableViewCellDelegate?
    var source = 0
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        print("awakeFromNib")
    }
    
    func setSubTag() {
        vCamera1.tag = indexPath.section * 1000 + indexPath.row
        vCamera2.tag = indexPath.section * 1000 + indexPath.row + 100
        if tap1 == nil {
            tap1 = UITapGestureRecognizer(target: self, action: #selector(DetectionTableViewCell.handleGestureRecognizer(recognizer:)))
            vCamera1.addGestureRecognizer(tap1!)
        }
        if tap2 == nil {
            tap2 = UITapGestureRecognizer(target: self, action: #selector(DetectionTableViewCell.handleGestureRecognizer(recognizer:)))
            vCamera2.addGestureRecognizer(tap2!)
        }
    }
    

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func handleGestureRecognizer(recognizer : UITapGestureRecognizer)  {
        delegate?.cameraModel(tag: recognizer.view?.tag ?? 0)
    }

}

protocol DetectionTableViewCellDelegate {
    func cameraModel(tag : Int)
}
