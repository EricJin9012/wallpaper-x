//
//  CategoryTVCell.swift
//  Wallpapers X
//
//  Created by DanJin on 2019/12/8.
//  Copyright © 2019 sarwatshah. All rights reserved.
//

import UIKit

class CategoryTVCell: UITableViewCell {
    
    @IBOutlet weak var coverImageView: UIImageView!
    @IBOutlet weak var categoryNameNabel: UILabel!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
