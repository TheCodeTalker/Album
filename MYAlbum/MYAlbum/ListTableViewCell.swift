//
//  ListTableViewCell.swift
//  MYAlbum
//
//  Created by Chitaranjan Sahu on 20/05/17.
//  Copyright © 2017 Ithink. All rights reserved.
//

import UIKit

class ListTableViewCell: UITableViewCell {

    @IBOutlet weak var storyLabel: UILabel!
    @IBOutlet weak var storyImage: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
