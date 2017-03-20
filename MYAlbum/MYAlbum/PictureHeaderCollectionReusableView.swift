//
//  PictureHeaderCollectionReusableView.swift
//  MYAlbum
//
//  Created by Chitaranjan Sahu on 16/03/17.
//  Copyright © 2017 Ithink. All rights reserved.
//

import UIKit

class PictureHeaderCollectionReusableView: UICollectionReusableView {
    let  kParallaxDeltaFactor :CGFloat = 0.5
    @IBOutlet weak var iboHeaderScroll: UIScrollView!
    @IBOutlet weak var iboSubTitle: UITextField!
    @IBOutlet weak var iboTitle: UITextField!
    @IBOutlet weak var iboScrollDownBrn: UIButton!
    @IBOutlet weak var iboHeaderImage: UIImageView!
    
//    - (void)layoutHeaderViewForScrollViewOffset:(CGPoint)offset
//    {
//    CGRect frame = self.imageScrollView.frame;
//    
//    if (offset.y > 0)
//    {
//    frame.origin.y = MAX(offset.y *kParallaxDeltaFactor, 0);
//    self.imageScrollView.frame = frame;
//    self.bluredImageView.alpha =   1 / kDefaultHeaderFrame.size.height * offset.y * 2;
//    self.clipsToBounds = YES;
//    }
//    else
//    {
//    CGFloat delta = 0.0f;
//    CGRect rect = kDefaultHeaderFrame;
//    delta = fabs(MIN(0.0f, offset.y));
//    rect.origin.y -= delta;
//    rect.size.height += delta;
//    self.imageScrollView.frame = rect;
//    self.clipsToBounds = NO;
//    self.headerTitleLabel.alpha = 1 - (delta) * 1 / kMaxTitleAlphaOffset;
//    }
//    }

    override func awakeFromNib() {
        super.awakeFromNib()
        self.iboHeaderImage.clipsToBounds = true
        self.iboHeaderImage.autoresizingMask = UIViewAutoresizing.flexibleHeight
        //[self.headerImageView setClipsToBounds:YES];
        //[self.headerImageView setAutoresizingMask:UIViewAutoresizingFlexibleHeight];
    }
    
func layoutHeaderViewForScrollViewOffset(offset:CGPoint) {
    var  frame = self.iboHeaderScroll.frame
        if offset.y > 0{
            frame.origin.y = max((offset.y * kParallaxDeltaFactor),  0)
            self.iboHeaderScroll.frame = frame
            self.clipsToBounds = true
            
        }else{
            var delta: CGFloat = 0.0
            var rect = CGRect(x: 0, y: 0, width: self.frame.size.width, height: self.frame.size.height)
            delta = fabs(min(CGFloat(0), offset.y))
            rect.origin.y -= delta
            rect.size.height += delta
            self.iboHeaderScroll.frame = rect
            self.clipsToBounds = true
        
            
        }
    }
}
