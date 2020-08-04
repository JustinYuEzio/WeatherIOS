//
//  FavTableViewCell.swift
//  ForecastApp
//
//  Created by Hengyi Yu on 11/26/19.
//  Copyright © 2019 Hengyi Yu. All rights reserved.
//

import UIKit

class FavTableViewCell: UITableViewCell {

    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var sunsetTime: UILabel!
    @IBOutlet weak var sunriseTime: UILabel!
    @IBOutlet weak var date: UILabel!
    override func awakeFromNib() {
        
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
