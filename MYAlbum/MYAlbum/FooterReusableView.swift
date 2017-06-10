//
//  FooterReusableView.swift
//  MYAlbum
//
//  Created by Chitaranjan Sahu on 17/03/17.
//  Copyright © 2017 Ithink. All rights reserved.
//

import UIKit

class FooterReusableView: UICollectionReusableView {

    @IBOutlet weak var iboOwnerImg: UIImageView!
    @IBOutlet weak var iboOwnerLabel: UILabel!
    var delegate:autoScrollDelegate! = nil
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    @IBAction func scrollUpClicked(_ sender: UIButton) {
        
        delegate.autoScrollToTop()
    }
}
