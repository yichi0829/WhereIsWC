//
//  WCTableViewCell.swift
//  HDAugmentedRealityDemo
//
//  Created by YiChi on 2016/6/16.
//  Copyright © 2016年 Danijel Huis. All rights reserved.
//

import UIKit

class WCTableViewCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var distLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
