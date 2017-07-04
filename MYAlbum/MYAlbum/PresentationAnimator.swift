//
//  PresentationAnimator.swift
//  iOS7Colors
//
//  Created by Ankur Gala on 02/10/14.
//  Copyright (c) 2014 Ankur Gala. All rights reserved.
//

import UIKit

let animationScale = SCREENWIDTH/SCREENHEIGHT
class PresentationAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    
    var openingFrame: CGRect?
    var cellView:UIView?
    var indexPath : IndexPath?
    private var selectedCellFrame: CGRect? = nil
    private var originalTableViewY: CGFloat? = nil
    //var selectedHomeCell:UIView?
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.35
    }
    
    private func createTransitionImageViewWithFrame(frame: CGRect) -> UIImageView {
        let imageView = UIImageView(frame: frame)
        imageView.contentMode = .scaleAspectFill
        //imageView.setupDefaultTopInnerShadow()
        imageView.clipsToBounds = true
        return imageView
    }
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let fromViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from)  as UIViewController!
        let toViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)  as UIViewController!
        let containerView = transitionContext.containerView
        let fromView = fromViewController?.view
        let toView = toViewController?.view
        toView?.layoutIfNeeded()
        containerView.addSubview(fromView!)
        containerView.addSubview(toView!)
        
        
    //  let gridView =  cellView
        
     //   let  cell = gridView?.convert(CG, to: nil)
     //   let leftUpperPoint = openingFrame?.origin//gridView!.convert(CGPoint.zero, to: nil)
       
         let waterFallView : UITableView = (fromViewController as! NTTransitionProtocol).transitionCollectionView()
        let gridView = waterFallView.cellForRow(at: indexPath!) as! ListTableViewCell
        
        
       // let leftUpperPoint = gridView?.frame
        toView?.isHidden = true
        
        let offsetY : CGFloat = 0
        let offsetStatuBar : CGFloat = 0;
    
       
        
        let leftUpperPoint = gridView.convert(CGPoint.zero, to: nil)
        let textHolderPoint = gridView.textViewHolder.frame.origin
        
        
        let snapShot = (gridView as! NTTansitionWaterfallGridViewProtocol).snapShotForTransition()
        let textHolder = (gridView as! NTTansitionWaterfallGridViewProtocol).snapTitleShotForTransition()
        
        
        containerView.addSubview(snapShot!)
    //    containerView.addSubview(textHolder!)
        //textHolder?.origin(textHolderPoint)
        containerView.clipsToBounds = true
        print("leftUpperPoint\(leftUpperPoint)")
        print("\(gridView.bounds)")
        snapShot?.origin(leftUpperPoint)
        snapShot?.layoutIfNeeded()
        
        
       // containerView.addSubview(snapShot!)
     //  snapShot!.origin(leftUpperPoint!)
        
        UIView.animate(withDuration: 0.5, animations: {
            //snapShot!.transform = CGAffineTransform(scaleX: 1,
              //  y: 1)
            print("snapShot\(snapShot?.frame.width)")
            print("toView?.frame.width\(toView?.frame.width)")
            
            snapShot!.frame = CGRect(x: 0, y: 0, width: (toView?.frame.width)!, height: (toView?.frame.height)!)
            UIView.animate(withDuration: 0.1, animations: {
            snapShot?.contentMode = .scaleAspectFill
            })
            
            
            fromView?.alpha = 0
            //fromView?.transform = snapShot!.transform
           // fromView?.frame = CGRect(x: -((leftUpperPoint.x))*animationScale,
            //                        y: -((leftUpperPoint.y)-offsetStatuBar)*animationScale+0,
              //                      width: (fromView?.frame.size.width)!,
                //                    height: (fromView?.frame.size.height)!)
            },completion:{finished in
                if finished {
                    snapShot!.removeFromSuperview()
                    toView?.isHidden = false
                    fromView?.alpha = 1
                    
                    fromView?.transform = CGAffineTransform.identity
                    transitionContext.completeTransition(true)
                }
        })
    }
}

extension UIView{
    func origin (_ point : CGPoint){
        frame.origin.x = point.x
        frame.origin.y = point.y
    }
}
