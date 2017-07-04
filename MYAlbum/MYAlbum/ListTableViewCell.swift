//
//  ListTableViewCell.swift
//  MYAlbum
//
//  Created by Chitaranjan Sahu on 20/05/17.
//  Copyright © 2017 Ithink. All rights reserved.
//

import UIKit

class ListTableViewCell: UITableViewCell,NTTansitionWaterfallGridViewProtocol,UIScrollViewDelegate {

    @IBOutlet weak var textViewHolder: UIView!
    @IBOutlet weak var ViewForScroll: UIView!
    @IBOutlet weak var gradientView: UIView!
    @IBOutlet weak var slideBtn: UIButton!
    @IBOutlet weak var shareBtn: UIButton!
    @IBOutlet weak var deleteStoryById: UIButton!
    @IBOutlet weak var scrollviewCell: UIScrollView!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var creatorImage: UIImageView!
    var perviousCell :Int = -1
    var visualEffectView: UIView?
    //@IBOutlet weak var visiualEffect: UIVisualEffectView!
    @IBOutlet weak var storyLabel: UILabel!
    @IBOutlet weak var storyImage: UIImageView!
       override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.scrollviewCell.delegate = self
        scrollviewCell.contentSize = CGSize(width: 460, height: 320)
        
        let blurEffect = UIBlurEffect(style: .dark)
        let visualEffectView = UIVisualEffectView(effect: blurEffect)
        storyImage.isUserInteractionEnabled = true
        
        visualEffectView.frame = CGRect(x: self.storyImage.bounds.origin.x, y: self.storyImage.bounds.origin.y, width: SCREENWIDTH, height: 320)
        
        self.storyImage.addSubview(visualEffectView)
        visualEffectView.alpha = 0
        
        self.visualEffectView = visualEffectView
        self.addGradientView()
        
        //self.scrollviewCell.delaysContentTouches = false
      // visiualEffect.alpha = 0
        
    }
    
    func configureWithItem(story: StoryModel) {
        
        var urlImage = story.story_cover_photo_path.components(separatedBy: "album")
        
        var totalPath = URLConstants.imgDomain
        storyImage.backgroundColor = UIColor(hexString:story.story_cover_photo_slice_code)
        if urlImage.count == 2{
            storyImage.sd_setShowActivityIndicatorView(true)
            // cell.storyImage.sd_setImage(with: URL(string: totalPath + urlImage[1]), placeholderImage: UIImage(named: ""))
            
            storyImage.sd_setImage(with: URL(string: totalPath + urlImage[1]), placeholderImage: UIImage(named: ""), options: [], completed: { (image, data, error, finished) in
                guard let image = image else{ return}
                //cell.storyImage.image = image.blurredImage(withRadius: 10, iterations: 20, tintColor: UIColor.clear)
                cache.setObject(image, forKey: "\(totalPath + urlImage[1])" as NSString)
            })
        }
       
        clipsToBounds = true
        if storyImage.subviews.contains(visualEffectView!){
            scrollviewCell.contentOffset = CGPoint(x: 0, y: 0)
        }else{
            scrollviewCell.contentOffset = CGPoint(x: 0, y: 0)
            let blurEffect = UIBlurEffect(style: .dark)
            var visualEffectView = UIVisualEffectView(effect: blurEffect)
            storyImage.isUserInteractionEnabled = true
            
            visualEffectView.frame = CGRect(x: storyImage.bounds.origin.x, y: storyImage.bounds.origin.y, width: SCREENWIDTH, height: 320)
            storyImage.addSubview(visualEffectView)
            visualEffectView.alpha = 0
              self.visualEffectView = visualEffectView
        }
        deleteStoryById.addTarget(self, action: #selector(ListAllTableViewController.deleteBtnCliked(sender:)), for: UIControlEvents.touchUpInside)
        storyLabel.text = story.story_heading.capitalized
        subtitleLabel.text = story.story_heading_description.capitalized
        creatorImage.setImage(string: story.writen_by, color: UIColor(hexString:story.story_cover_photo_slice_code), circular: true)
    }
    
    func addGradientView() {
        let colorTop =  UIColor(red: 0.0/255.0, green: 0.0/255.0, blue: 0.0/255.0, alpha: 0.0).cgColor
        let colorBottom = UIColor(red: 0.0/255.0, green: 0.0/255.0, blue: 0.0/255.0, alpha: 0.4).cgColor
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [ colorTop, colorBottom]
        gradientLayer.locations = [ 0.0, 1.0]
        gradientLayer.frame = CGRect(x: self.gradientView.bounds.origin.x, y: self.gradientView.bounds.origin.y, width: SCREENWIDTH, height: self.gradientView.bounds.height)
        
        self.gradientView.layer.addSublayer(gradientLayer)
    }
    
    @IBAction func slideBtnClicked(_ sender: UIButton) {
       // self.scrollWithAnimation()
    }
    
    override func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if (self.scrollviewCell.superview != nil) {
            
            if touch.view is  UIButton{
                return true
                
            }
        }
        return false
    }
    
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        //let actualPosition = scrollView.panGestureRecognizer.translation(in: scrollView.superview)
        if (scrollView.contentOffset.x == CGFloat(0)){
            let tablV = (self.superview?.superview) as! UITableView
            let cellNo = scrollView.tag
            let scrollCell =  IndexPath(item: cellNo, section: 0)
            
            if let visibleCell = tablV.indexPathsForVisibleRows{
                for cell in visibleCell{
                    if blurFlag == cell.item{
                        let index = IndexPath(item: cell.item, section: 0)
                        guard let cellClicked = tablV.cellForRow(at: index) as? ListTableViewCell else {return}
                        // if (cellClicked.visualEffectView?.alpha)! > CGFloat(0.5) {
                        DispatchQueue.main.async() {
                            UIView.animate(withDuration: 0.2, delay: 0, options: UIViewAnimationOptions.curveLinear, animations: {
                                 cellClicked.scrollviewCell.contentOffset.x = 0
                            }, completion: {(test) in
                                blurFlag = cellNo
                            })
                        }
                        //}
                    }
                }
            }
            
        }else{
            print("else\(scrollView.contentOffset.x)")
        }
    }
    
    
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
    //    print("scrollView.contentOffset.x\(scrollView.contentOffset.x)")
        let totalScroll   = scrollView.contentSize.width - scrollView.bounds.size.width
        let offset =  scrollView.contentOffset.x
        
        let  percentage = offset / totalScroll
        
        if scrollView.contentOffset.x > 50{
           // self.scrollviewCell.removeGestureRecognizer(gestureRecognizer: UIGestureRecognizer)
        }
        let cellNo = scrollView.tag
        
        visualEffectView?.alpha = (percentage)
        
        slideBtn.alpha = 1 - percentage
        
        

       // print("percentage\((percentage))")
        let offsetX = visualEffectView?.alpha
        let point: CGPoint = CGPoint(x: scrollView.frame.size.width * CGFloat(), y: 0.0)
        let other = CGFloat(1)
        let delta: CGFloat = 0.00001
        
//        let a: CGFloat = 3.141592
//        let b: CGFloat = 3.141593
        
        
        if abs(offsetX! - other) < delta {
        // visiualEffect.isHidden = true
           blurFlag = cellNo
             //scrollviewCell.isUserInteractionEnabled = false
        }else{
             //scrollviewCell.isUserInteractionEnabled = true
        }
        
        
        
      //  print("\(offsetX)")
    }
    
    
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
        //print("offset\(scrollView.contentOffset)")
    }
    
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        
        if scrollView.contentOffset.x > 15{
            DispatchQueue.main.async() {
                UIView.animate(withDuration: 0.2, delay: 0, options: UIViewAnimationOptions.curveLinear, animations: {
                    self.scrollviewCell.contentOffset.x = 85
                }, completion: nil)
                
            }
        }else{
            
        }
        print("scrollViewWillEndDragging\(scrollView.contentOffset)")
    }
    
    
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
  
    override func prepareForReuse() {
        super.prepareForReuse()
        
        visualEffectView?.removeFromSuperview()
    }
    
    func snapTitleShotForTransition() -> UIView!{
        UIGraphicsBeginImageContextWithOptions(self.textViewHolder.bounds.size, false, 0.0)
                self.textViewHolder.layer.render(in: UIGraphicsGetCurrentContext()!)
                let image = UIGraphicsGetImageFromCurrentImageContext()! as UIImage
                UIGraphicsEndImageContext()
                let cellSnapshot : UIView = UIImageView(image: image)
                cellSnapshot.layer.masksToBounds = false
                cellSnapshot.layer.cornerRadius = 0.0
                cellSnapshot.layer.shadowOffset = CGSize(width: -5.0, height: 0.0)
                cellSnapshot.layer.shadowRadius = 5.0
                cellSnapshot.layer.shadowOpacity = 0.4
                return cellSnapshot
    }
    func snapShotForTransition() -> UIView! {
        
//        
//        UIGraphicsBeginImageContextWithOptions(self.bounds.size, false, 0.0)
//        self.layer.render(in: UIGraphicsGetCurrentContext()!)
//        let image = UIGraphicsGetImageFromCurrentImageContext()! as UIImage
//        UIGraphicsEndImageContext()
//        
//        let cellSnapshot : UIView = UIImageView(image: image)
//        cellSnapshot.layer.masksToBounds = false
//        cellSnapshot.layer.cornerRadius = 0.0
//        cellSnapshot.layer.shadowOffset = CGSize(width: -5.0, height: 0.0)
//        cellSnapshot.layer.shadowRadius = 5.0
//        cellSnapshot.layer.shadowOpacity = 0.4
//        return cellSnapshot

        
        
       
        let snapShotView = UIImageView(image: self.storyImage.image)
        snapShotView.contentMode = .scaleAspectFill
        snapShotView.clipsToBounds = true
        snapShotView.frame = storyImage.frame
        return snapShotView
    }
    
}
