//
//  ImageViewCollectionViewCell.swift
//  MYAlbum
//
//  Created by Chitaranjan Sahu on 19/05/17.
//  Copyright © 2017 Ithink. All rights reserved.
//

import UIKit
import AVFoundation
import AVKit

class ImageViewCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imageViewToShow: UIImageView!
    @IBOutlet weak var videoAsSubView: UIView!
    
    @IBOutlet weak var videoPlayBtn: UIImageView!
    @IBOutlet weak var fullScreenBtn: UIButton!
    
    @IBOutlet weak var volumeBtn: UIButton!
    var player : AVPlayer!
    var playerLayer : AVPlayerLayer!
    var playerItm : AVPlayerItem!
}
