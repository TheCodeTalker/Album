//
//  DismissalAnimator.swift
//  iOS7Colors
//
//  Created by Sztanyi Szabolcs on 02/10/14.
//  Copyright (c) 2014 Sztanyi Szabolcs. All rights reserved.
//

import UIKit

class DismissalAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    
    var openingFrame: CGRect?
    var cellView:UIView?{
        didSet{
            print("help")
        }
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.5
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
                let fromViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from)!
                let toViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)!
                let containerView = transitionContext.containerView
                let toView = toViewController.view!
                toView.isHidden = false
                toView.alpha = 1
                toView.layoutIfNeeded()
                transitionContext.completeTransition(true)
//        let fromViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from)!
//        let toViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)!
//        let containerView = transitionContext.containerView
//        let test = toViewController as! UIViewController
//        //print(test.viewControllers.count)
//       // let viewForCollection  = fromViewController as! HomesInfoViewController{
//        //test.viewControllers.count
//        let toView = toViewController.view!
//        let fromView = fromViewController.view!
//        containerView.addSubview(toView)
//        containerView.addSubview(fromView)
//        
//        toView.isHidden = true
//        toView.layoutIfNeeded()
//        //let waterFallView = (toViewController as! NTTransitionProtocol).transitionCollectionView()
//        //let pageView = (fromViewController as! NTTransitionProtocol).transitionCollectionView()
//       // waterFallView.layoutIfNeeded()
//     //   let indexPath = pageView.fromPageIndexPath()
//      //  let gridView = waterFallView.cellForItemAtIndexPath(indexPath)
//        cellView?.layoutIfNeeded()
//        let gridView = cellView
//        let leftUpperPoint = gridView!.convert(CGPoint.zero, to: toViewController.view)
//        
//        let snapShot = gridView
//        snapShot!.transform = CGAffineTransform(scaleX: 1, y: 1)
//        let pullOffsetY :CGFloat = 0
//        let offsetY : CGFloat = 64
//        
//        snapShot?.frame = CGRect(x: 0, y: -pullOffsetY+offsetY, width: (snapShot?.frame.width)!, height: (snapShot?.frame.height)!)
//        //
//        //snapShot!.origin(CGPoint(x: 0, y: -pullOffsetY+offsetY))
//        //containerView.addSubview(snapShot!)
//        
//        toView.isHidden = true
//        toView.alpha = 0
//        toView.transform = snapShot!.transform
//        toView.frame = CGRect(x: -(leftUpperPoint.x * 1),y: -((leftUpperPoint.y-offsetY) * 1+pullOffsetY+offsetY),
//                                  width: toView.frame.size.width, height: toView.frame.size.height)
////        let whiteViewContainer = UIView(frame: UIS)
////        whiteViewContainer.backgroundColor = UIColor.whiteColor()
////        containerView!.addSubview(snapShot!)
////        containerView.insertSubview(whiteViewContainer, belowSubview: toView)
////        
//        UIView.animate(withDuration: 0.35, animations: {
//            snapShot!.transform = CGAffineTransform.identity
//            snapShot!.frame = CGRect(x: leftUpperPoint.x, y: leftUpperPoint.y, width: snapShot!.frame.size.width, height: snapShot!.frame.size.height)
//            toView.transform = CGAffineTransform.identity
//            toView.frame = CGRect(x: 0, y: 0, width: toView.frame.size.width, height: toView.frame.size.height);
//            toView.alpha = 1
//            }, completion:{finished in
//                if finished {
//                    //snapShot!.removeFromSuperview()
//                    //toView.removeFromSuperview()
//                    //fromView.removeFromSuperview()
//                    toView.isHidden = false
//                    toView.transform = CGAffineTransform.identity
//                    
//                   // whiteViewContainer.removeFromSuperview()
//                    transitionContext.completeTransition(true)
//                }
//        })
   
    }
}
