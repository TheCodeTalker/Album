//
//  ListAllTableViewController.swift
//  MYAlbum
//
//  Created by Chitaranjan Sahu on 20/05/17.
//  Copyright © 2017 Ithink. All rights reserved.
//

import UIKit
import Alamofire
import SDWebImage
 var blurFlag = -1
class ListAllTableViewController: UIViewController,UINavigationControllerDelegate,NTTransitionProtocol {

    @IBOutlet weak var tableView: UITableView!
    var allStoryArray = [[String: AnyObject]]()
    var stopped : Bool = false
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(handleRefresh(refreshControl:)), for: UIControlEvents.valueChanged)
        return refreshControl
    }()
    var openingFrame: CGRect?
    var cellView:UIView?{
        didSet{
            print("hel;lpo")
        }
    }
    
    // var visualEffectView: UIView?
    
   

    var cellindexPath:IndexPath?
    
   //  let transitionDelegate: TransitioningDelegate = TransitioningDelegate()
    var storyArray = [StoryModel]()
   
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        self.tableView.emptyDataSetSource = self
        self.tableView.emptyDataSetDelegate = self
        self.navigationController?.delegate = self
        
        tableView.register(UINib(nibName: "ListTableViewCell", bundle: nil), forCellReuseIdentifier: "ListTableViewCell")
        let longpress = UILongPressGestureRecognizer(target: self, action: #selector(longPressGestureRecognized))
        self.tableView.addGestureRecognizer(longpress)
        
        //UINavigationBar.appearance()
        //self.navigationController?.navigationBar.setBackgroundImage(UIImage.init(), for: UIBarMetrics.default)
        
       
        
     //   let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture))
      //  swipeLeft.direction = UISwipeGestureRecognizerDirection.left
       // self.tableView.addGestureRecognizer(swipeLeft)
//        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture))
  //      swipeRight.direction = UISwipeGestureRecognizerDirection.right
    //    self.tableView.addGestureRecognizer(swipeRight)
     //   self.tableView.addSubview(self.refreshControl)
        
     //   self.transitioningDelegate = self
        
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        self.getAllStoryAPICall {
            DispatchQueue.main.async {
                //refreshControl.endRefreshing()
                self.tableView.reloadData()
            }

        }
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    
    func scrollIfNeed(snapshotView:UIView)  {
        var cellCenter = snapshotView.center
        
        var newOffset = tableView.contentOffset
        let buffer  = CGFloat(10)
        let bottomY = tableView.contentOffset.y + tableView.frame.size.height - 100
        // print("bottomY\(bottomY)")
        //print("(snapshotView.frame.maxY - buffer)\((snapshotView.frame.maxY - buffer))")
        
        //print("condition \(bottomY  < (snapshotView.frame.maxY - buffer))")
        if (bottomY  < (snapshotView.frame.maxY - buffer)){
            
            newOffset.y = newOffset.y + 1
            
            //      print("uppppp")
            
            if (((newOffset.y) + (tableView.bounds.size.height)) > (tableView.contentSize.height)) {
                return
            }
            cellCenter.y = cellCenter.y + 1
        }
        
        
        let offsetY = tableView.contentOffset.y
        // print("chita \(offsetY)")
        if (snapshotView.frame.minY + buffer < offsetY) {
            // print("Atul\(snapshotView.frame.minY + buffer)")
            // We're scrolling up
            newOffset.y = newOffset.y - 1
            
            //   print("downnnn")
            if ((newOffset.y) <= CGFloat(0)) {
                return
            }
            
            // adjust cell's center by 1
            cellCenter.y = cellCenter.y - 1
        }
        
        
        tableView.contentOffset = newOffset
        snapshotView.center = cellCenter;
        
        // Repeat until we went to far.
        if(self.stopped == true){
            
            return
            
        }else
        {
            let deadlineTime = DispatchTime.now() + 0.1
            DispatchQueue.main.asyncAfter(deadline: deadlineTime, execute: {
                self.scrollIfNeed(snapshotView: snapshotView)
            })
        }
        
        
    }
    
    
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationControllerOperation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        if operation == .push{
            
            let fromVCConfromA = (fromVC as? NTTransitionProtocol)
       //     let fromVCConfromB = (fromVC as? NTTansitionWaterfallGridViewProtocol)
            if (fromVCConfromA != nil){
                let presentationAnimator = PresentationAnimator()
                presentationAnimator.openingFrame = openingFrame!
                presentationAnimator.cellView = cellView
                presentationAnimator.indexPath = cellindexPath
                return presentationAnimator
            }
           
        }else if operation == .pop{
//            let dismissAnimator = DismissalAnimator()
//            dismissAnimator.openingFrame = openingFrame!
//            dismissAnimator.cellView = cellView
//            return dismissAnimator
        }
        return nil
    }
    
    func transitionCollectionView() -> UITableView!{
        return tableView
    }
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        let presentationAnimator = PresentationAnimator()
        
        presentationAnimator.openingFrame = openingFrame!
        presentationAnimator.cellView = cellView
        presentationAnimator.indexPath = cellindexPath
        return presentationAnimator
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        let dismissAnimator = DismissalAnimator()
        dismissAnimator.openingFrame = openingFrame!
        dismissAnimator.cellView = cellView
        
        return dismissAnimator
    }

    
    
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = false

        self.navigationController?.isNavigationBarHidden = false
        self.navigationController?.setNavigationBarHidden(false, animated: false)
      //  self.navigationController?.navigationBar.setBackgroundImage(nil, for: UIBarMetrics.default)
     //   self.navigationController?.navigationBar.shadowImage = nil
        //self.navigationController?.navigationItem.leftBarButtonItem = UIBarButtonItem.init(barButtonSystemItem: UIBarButtonItem., target: <#T##Any?#>, action: <#T##Selector?#>)
//        self.navigationController?.navigationBar.tintColor = UIColor.black
//        self.navigationController?.navigationBar.barTintColor = UIColor.black
        
        self.navigationController?.navigationBar.setBackgroundImage(UIImage.init(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage.init()
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.view.backgroundColor = UIColor.clear
        
       //  self.navigationController?.navigationBar.setBackgroundImage(UIImage(named: "navigation")!.resizableImage(withCapInsets: UIEdgeInsetsMake(0, 0, 0, 0), resizingMode: .stretch), for: .default)
        self.navigationItem.setRightBarButton(UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addStory(_:))), animated: true)
        self.navigationItem.rightBarButtonItem?.tintColor = UIColor.blue
        //self.navigationItem.rightBarButtonItem.
            //UIBarButtonItem.init(image:, style:UIBarButtonItemStyle.Plain, target: self, action: Selector("back"))
//       for cell in tableView.visibleCells {
//        let cell1 = cell as! ListTableViewCell
//        cell1.scrollviewCell.isUserInteractionEnabled = true
//        
        self.getAllStoryAPICall {
            
            DispatchQueue.main.async {
        //        refreshControl.endRefreshing()
                self.tableView.reloadData()
            }
        }
        
//        }
        
        

    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = true
        
        self.navigationController?.isNavigationBarHidden = true
        self.navigationController?.setNavigationBarHidden(true, animated: false)

    }
    func handleRefresh(refreshControl: UIRefreshControl) {

    }
    
    func title(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
      
        let str = "Server Is Not Reachable"
        let attributes = [
          //  NSFontAttributeName            : UIFont(name: "raleway-Bold", size: 15)!,
            NSForegroundColorAttributeName : UIColor(hexString:"15181b")
        ]
        
        
        return NSAttributedString(string: str, attributes: attributes)
        
    }
    

    
    func buttonTitle(forEmptyDataSet scrollView: UIScrollView, for state: UIControlState) -> NSAttributedString? {
        
        
        let str2  = "Refresh"
        let attributes = [
            //NSFontAttributeName            : UIFont(name: "raleway-semiBold", size: 15)!,
            NSForegroundColorAttributeName : UIColor(hexString:"FD595D")
        ]
        
        //let attrs = [NSFontAttributeName: UIFont.preferredFont(forTextStyle: UIFontTextStyle.body)]
        return NSAttributedString(string: str2, attributes: attributes)
    }
    
    func emptyDataSet(_ scrollView: UIScrollView, didTap button: UIButton) {
        
        self.getAllStoryAPICall {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
        
        
    }
    
    func image(forEmptyDataSet scrollView: UIScrollView) -> UIImage? {
       
        return UIImage(named: "Swap-white")
    }
    
    func backgroundColor(forEmptyDataSet scrollView: UIScrollView) -> UIColor? {
      
        return UIColor.white
    }


    
    func respondToSwipeGesture(gesture: UIGestureRecognizer) {
        if let swipeGesture = gesture as? UISwipeGestureRecognizer {
            switch swipeGesture.direction {
            case UISwipeGestureRecognizerDirection.right:
                if gesture.state == UIGestureRecognizerState.ended {
                    let swipeLocation = gesture.location(in: self.tableView)
                    if let swipedIndexPath = tableView.indexPathForRow(at: swipeLocation) {
                        if let swipedCell = self.tableView.cellForRow(at: swipedIndexPath) as? ListTableViewCell{
                            // self.storyArray[swipedIndexPath.item].blurOrNot = true
                            //self.tableView.reloadRows(at: [swipedIndexPath], with: UITableViewRowAnimation.left)
                           // swipedCell.visiualEffect.isHidden = true
                        }
                    }
                }

                print("Swiped right")
            case UISwipeGestureRecognizerDirection.down:
                print("Swiped down")
            case UISwipeGestureRecognizerDirection.left:
                if gesture.state == UIGestureRecognizerState.ended {
                    let swipeLocation = gesture.location(in: self.tableView)
                    if let swipedIndexPath = tableView.indexPathForRow(at: swipeLocation) {
                        if let swipedCell = self.tableView.cellForRow(at: swipedIndexPath) as? ListTableViewCell{
                           // swipedCell.visiualEffect.isHidden = false
                            //self.storyArray[swipedIndexPath.item].blurOrNot = false
                          //  self.tableView.reloadRows(at: [swipedIndexPath], with: UITableViewRowAnimation.right)
                        }
                    }
                }
                
                
                print("Swiped left")
            case UISwipeGestureRecognizerDirection.up:
                print("Swiped up")
            default:
                break
            }
        }
    }

    
    func snapshotOfCell(inputView: UIView) -> UIView {
        UIGraphicsBeginImageContextWithOptions(inputView.bounds.size, false, 0.0)
        inputView.layer.render(in: UIGraphicsGetCurrentContext()!)
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
    
    
   
    
    func longPressGestureRecognized(gestureRecognizer: UIGestureRecognizer) {
        let longPress = gestureRecognizer as! UILongPressGestureRecognizer
        let state = longPress.state
        let locationInView = longPress.location(in: tableView)
        let indexPath = tableView.indexPathForRow(at: locationInView)
        
        struct My {
            static var cellSnapshot : UIView? = nil
            static var cellIsAnimating : Bool = false
            static var cellNeedToShow : Bool = false
        }
        struct Path {
            static var initialIndexPath : IndexPath? = nil
        }
        
        switch state {
        case UIGestureRecognizerState.began:
            
            if let cell = self.tableView.cellForRow(at: IndexPath(item: blurFlag, section: 0)) as? ListTableViewCell{
                DispatchQueue.main.async() {
                    UIView.animate(withDuration: 0.2, delay: 0, options: UIViewAnimationOptions.curveLinear, animations: {
                        cell.scrollviewCell.contentOffset.x = 0
                    }, completion: { (test) in
                        blurFlag = -1
                    })
                }
            }
            
            
            if indexPath != nil {
                Path.initialIndexPath = indexPath as IndexPath?
                let cell = tableView.cellForRow(at: indexPath!) as UITableViewCell!
                My.cellSnapshot  = snapshotOfCell(inputView: cell!)
                
                var center = cell?.center
                My.cellSnapshot!.center = center!
                My.cellSnapshot!.alpha = 0.0
                tableView.addSubview(My.cellSnapshot!)
                
                UIView.animate(withDuration: 0.25, animations: { () -> Void in
                    center?.y = locationInView.y
                    My.cellIsAnimating = true
                    My.cellSnapshot!.center = CGPoint(x: locationInView.x, y: locationInView.y)
                    My.cellSnapshot!.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
                    My.cellSnapshot!.alpha = 0.98
                    cell?.alpha = 0.0
                }, completion: { (finished) -> Void in
                    if finished {
                        My.cellIsAnimating = false
                        if My.cellNeedToShow {
                            My.cellNeedToShow = false
                            UIView.animate(withDuration: 0.25, animations: { () -> Void in
                                cell?.alpha = 1
                            })
                        } else {
                            cell?.isHidden = true
                        }
                    }
                })
            }
            
        case UIGestureRecognizerState.changed:
            stopped = false
            
            if My.cellSnapshot != nil {
                self.scrollIfNeed(snapshotView: My.cellSnapshot!)
                var center = My.cellSnapshot!.center
                center.y = locationInView.y
                center.x = locationInView.x
                My.cellSnapshot!.center = center
                
                if let indexPath = indexPath , indexPath != Path.initialIndexPath {
                    storyArray.insert(storyArray.remove(at: Path.initialIndexPath!.row), at: indexPath.row)
                    tableView.moveRow(at: Path.initialIndexPath!, to: indexPath)
                    
                    Path.initialIndexPath = indexPath
                }
            }
            
        case UIGestureRecognizerState.ended:
            
            stopped = true
            if Path.initialIndexPath != nil {
                let cell = tableView.cellForRow(at: Path.initialIndexPath! as IndexPath) as UITableViewCell!
                if My.cellIsAnimating {
                    My.cellNeedToShow = true
                } else {
                    cell?.isHidden = false
                    cell?.alpha = 0.0
                }
                
                UIView.animate(withDuration: 0.25, animations: { () -> Void in
                    My.cellSnapshot!.center = (cell?.center)!
                    My.cellSnapshot!.transform = CGAffineTransform.identity
                    My.cellSnapshot!.alpha = 1
                   
                    
                }, completion: { (finished) -> Void in
                    if finished {
                         cell?.alpha = 1.0
                        Path.initialIndexPath = nil
                        My.cellSnapshot!.removeFromSuperview()
                        My.cellSnapshot = nil
                    }
                })
            }
            
        default:
            break

        }
    }
    
    
    @IBAction func addStory(_ sender: UIBarButtonItem) {
        let addstory = self.storyboard?.instantiateViewController(withIdentifier: "HomePage") as! ViewController
        let navigation = UINavigationController(rootViewController: addstory)
        navigation.isNavigationBarHidden = false
        addstory.creatingStory = true
        addstory.upload = true
        self.navigationController?.present(navigation, animated: true, completion: nil)
    
    }
    
    func getAllStoryAPICall(_ handler: ((Void) -> Void)?) {
        //TODO:- XCODE 8
        let defaultFilterUrl = URLConstants.BaseURL + "allstories/0/1000"
       
        Alamofire.request(defaultFilterUrl, method: .get, parameters: nil, encoding: URLEncoding.default, headers: nil).responseJSON { (response:DataResponse<Any>) in
            switch response.result {
            case .success(let JSON):
                print("Success with JSON: \(JSON)")
                let response = JSON as! NSDictionary
                let errorCode: AnyObject = response.value(forKeyPath: "error.errorCode") as! NSNumber
                let errorMSG  = response.value(forKeyPath: "error.errorMsg")
                print("postURL is :", (defaultFilterUrl), "response is: \(response)", "error code is \(errorCode)")
                let compareCode: NSNumber = 0
                if errorCode as! NSNumber == compareCode{
                    self.allStoryArray.removeAll(keepingCapacity: true)
                    self.storyArray.removeAll(keepingCapacity: true)
                if(self.allStoryArray.count == 0){
                        //self.loading = true
                        print(self.allStoryArray.count)
                    
                        self.allStoryArray = (response.value(forKey: "results") as? [[String: AnyObject]])!
                        //self.allHomesArray = (response.valueForKey("results") as? NSMutableArray)!
                        for i in 0 ..< self.allStoryArray.count{
                          let singleStory = self.allStoryArray[i]
                            let story_id = singleStory["story_id"] as? Int ?? 0
                            let writen_by = singleStory["writen_by"] as? String ?? ""
                           
                            
                            let story_cover_photo_path = singleStory["story_cover_photo_path"] as? String ?? ""
                            
                           
                             let story_cover_photo_slice_code = singleStory["story_cover_photo_slice_code"] as? String ?? ""
                            
                            
                          //  let story_cover_photo_code = singleStory["story_cover_photo_code"] as? String ?? ""
                           
                            let story_heading = singleStory["story_heading"] as? String ?? ""
                            let story_heading_description = singleStory["story_heading_description"] as? String ?? ""
                                //story_cover_photo_slice_code = cover_photo_path
                            
                            
                            
                            //let story_cover_photo_path = singleStory["story_cover_photo_path"] as! String
                            //let story_cover_photo_slice_code = singleStory["story_cover_photo_slice_code"] as!  String
                            let story = StoryModel(writen_by: writen_by, story_id: story_id, story_cover_photo_slice_code: story_cover_photo_slice_code, story_cover_photo_path: story_cover_photo_path,blurOrNot:false, story_heading: story_heading, story_heading_description: story_heading_description)
                            self.storyArray.append(story)
                            
                        }
                        //let = allStoryArray
                    
                    
                        //self.collectionView.reloadData()
                        //     waitView!.removeFromSuperview()
                    }
                    handler?()
                }else {
                    //   self.activityLoaderForFirstTime.stopAnimating()
                   // self.viewLoader?.stopAnimating()
                   // AlertView.showAlert(self, title: "OOPS!", message: errorMSG! as AnyObject)
                }
            case .failure(let error):
             //   self.viewLoader?.stopAnimating()
                //  self.activityLoaderForFirstTime.stopAnimating()
                print("Request failed with error: \(error)")
                //     print("hello")
                //print(error.localizedDescription)
              //  Toast.show(error.localizedDescription)
                //                /AlertView.showAlert(self, title: "", message: error)
               // self.collectionView.finishInfiniteScroll()
                //      waitView!.removeFromSuperview()
            }
        }
    }
    
    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
}

extension ListAllTableViewController: DZNEmptyDataSetSource,DZNEmptyDataSetDelegate{
    
}

extension ListAllTableViewController : UITableViewDelegate,UITableViewDataSource
{
    
    
    // MARK: - Table view data source
    
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if storyArray.count == 0{
            return 0
        }
        return storyArray.count
        
    }
    
    
      func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
     let cell = tableView.dequeueReusableCell(withIdentifier: "ListTableViewCell", for: indexPath) as! ListTableViewCell
        var story = self.storyArray[indexPath.item]
       cell.configureWithItem(story: story)
        cell.slideBtn.tag = indexPath.item
        cell.scrollviewCell.tag = indexPath.item
        //cell.scrollviewCell.delegate = self
        let singleTap = UITapGestureRecognizer(target: self, action: #selector(ListAllTableViewController.clickedScrollView(_:)))
        cell.ViewForScroll.removeGestureRecognizer(singleTap)
        singleTap.numberOfTapsRequired = 1
        cell.ViewForScroll.addGestureRecognizer(singleTap)
        cell.slideBtn.addTarget(self, action: #selector(scrollWithAnimation(sender:)), for: UIControlEvents.touchUpInside)
        if blurFlag == indexPath.item{
            cell.scrollviewCell.contentOffset.x = 85
        }
        return cell
     }
    
    
    func pickCellCleanUp() {
        for cell in self.tableView.visibleCells{
            let celltemp = cell as! ListTableViewCell
            DispatchQueue.main.async() {
                UIView.animate(withDuration: 0.2, delay: 0, options: UIViewAnimationOptions.curveLinear, animations: {
                    celltemp.scrollviewCell.contentOffset.x = 0
                }, completion: { (test) in
                    blurFlag = -1
                })
            }
        }
    }
    
    
    func scrollWithAnimation(sender : AnyObject)  {
        guard let cellNo = sender.tag else {return}
        guard let cellClicked = self.tableView.cellForRow(at: IndexPath(item: cellNo, section: 0)) as? ListTableViewCell else {return}
        for cell in self.tableView.visibleCells{
            let celltemp = cell as! ListTableViewCell
            DispatchQueue.main.async() {
                UIView.animate(withDuration: 0.2, delay: 0, options: UIViewAnimationOptions.curveLinear, animations: {
                    celltemp.scrollviewCell.contentOffset.x = 0
                }, completion: { (test) in
                blurFlag = cellNo
                })
            }
        }
        DispatchQueue.main.async() {
            UIView.animate(withDuration: 0.2, delay: 0, options: UIViewAnimationOptions.curveLinear, animations: {
                cellClicked.scrollviewCell.contentOffset.x = 85
            }, completion: { (test) in
            blurFlag = cellNo
            })
        }
        
    }

    
    
    @IBAction func deleteBtnCliked(sender : AnyObject) {
        let point =  sender.convert(CGPoint(x: 0, y: 0), to: self.tableView)
        //let point = sender.convert(CGPoint(x: 0, y: 0), toView : self.tableView)
        let indexPath = self.tableView.indexPathForRow(at: point)
        
        let actionSheetControllerIOS8: UIAlertController = UIAlertController(title: "Delete item ?", message: "Are you sure that you wish to delete this?", preferredStyle: .actionSheet)
        
        let cancelActionButton: UIAlertAction = UIAlertAction(title: "Cancel", style: .default) { action -> Void in
        }
        actionSheetControllerIOS8.addAction(cancelActionButton)
        
        let deleteActionButton: UIAlertAction = UIAlertAction(title: "Delete", style: .destructive)
        { action -> Void in
            //self.deleteHomesAPICall(timeLineID: String(describing: self.profile!.timeLine[(indexPath?.row)!].timeLineID), handler: {
                
                
                self.tableView.beginUpdates()
                
                self.tableView.deleteRows(at: [indexPath!], with: UITableViewRowAnimation.automatic)
                
                self.storyArray.remove(at: indexPath!.row)
                
                self.tableView.endUpdates()
          //  })
            
        }
        actionSheetControllerIOS8.addAction(deleteActionButton)
        self.present(actionSheetControllerIOS8, animated: true, completion: nil)
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 280
    }
    
    
    func clickedScrollView(_ sender: UITapGestureRecognizer) {
        
    
        let touchLocation = sender.location(ofTouch: 0, in: self.tableView)
        let indexpath = self.tableView.indexPathForRow(at: touchLocation)
        if let  indexpath = indexpath{
            let cell = self.tableView.cellForRow(at: indexpath) as! ListTableViewCell
            
            if (cell.visualEffectView?.alpha)! > CGFloat(0.5){
                DispatchQueue.main.async() {
                    
                    UIView.animate(withDuration: 0.2, delay: 0, options: UIViewAnimationOptions.curveLinear, animations: {
                        cell.scrollviewCell.contentOffset.x = 0
                    }, completion: nil)
                }

            }else{
            blurFlag = -1
            let home = self.storyboard?.instantiateViewController(withIdentifier: "HomePage") as! ViewController
            let story = self.storyArray[indexpath.item]
            home.storyId = String(story.story_id)
            home.storyTitle = story.story_heading
            home.storySubtitle = story.story_heading_description
            var urlImage = story.story_cover_photo_path.components(separatedBy: "album")
            var totalPath = URLConstants.imgDomain
            if urlImage.count > 1{
           totalPath = totalPath + urlImage[1]
            }else{
                totalPath = totalPath + urlImage[0]
            }
            let url = totalPath
            home.story_cover_photo_path = url
            let cell = tableView.cellForRow(at: indexpath) as! ListTableViewCell
            openingFrame = cell.frame
            cellView = cell.storyImage
            cellindexPath = indexpath
            self.navigationController?.pushViewController(home, animated: true)
            }

        }
        
        
        
    }
 
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let home = self.storyboard?.instantiateViewController(withIdentifier: "HomePage") as! ViewController
        let story = self.storyArray[indexPath.item]
        home.storyId = String(story.story_id)
        home.storyTitle = story.story_heading
        home.storySubtitle = story.story_heading_description
        var urlImage = story.story_cover_photo_path.components(separatedBy: "album")
        let totalPath = URLConstants.imgDomain
        let items = urlImage[1]
        let url = totalPath + items
        home.story_cover_photo_path = url
        let cell = tableView.cellForRow(at: indexPath) as! ListTableViewCell
        openingFrame = cell.frame
        cellView = cell.storyImage
        cellindexPath = indexPath
       // home.transitioningDelegate = self
     //   home.modalPresentationStyle = .custom
        
        //let navController = UINavigationController(rootViewController: home)
        //self.present(navController, animated:true, completion: nil)
        //self.navigationController?.present(home, animated: true, completion: nil)
        self.navigationController?.pushViewController(home, animated: true)
        
        
        
    }

}
