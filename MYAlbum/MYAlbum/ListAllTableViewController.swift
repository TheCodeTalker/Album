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

class ListAllTableViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    var allStoryArray = [[String: AnyObject]]()
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(handleRefresh(refreshControl:)), for: UIControlEvents.valueChanged)
        return refreshControl
    }()
    var storyArray = [StoryModel]()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        self.tableView.emptyDataSetSource = self
        self.tableView.emptyDataSetDelegate = self
        
        
        tableView.register(UINib(nibName: "ListTableViewCell", bundle: nil), forCellReuseIdentifier: "ListTableViewCell")
        let longpress = UILongPressGestureRecognizer(target: self, action: #selector(longPressGestureRecognized))
        self.tableView.addGestureRecognizer(longpress)
        
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture))
        swipeLeft.direction = UISwipeGestureRecognizerDirection.left
        self.tableView.addGestureRecognizer(swipeLeft)
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture))
        swipeRight.direction = UISwipeGestureRecognizerDirection.right
        self.tableView.addGestureRecognizer(swipeRight)
        
        self.tableView.addSubview(self.refreshControl)
        
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        self.getAllStoryAPICall {
            
        }
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    func handleRefresh(refreshControl: UIRefreshControl) {
        self.allStoryArray.removeAll(keepingCapacity: true)
        self.storyArray.removeAll(keepingCapacity: true)
        self.getAllStoryAPICall {
             refreshControl.endRefreshing()
        }
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
                             self.storyArray[swipedIndexPath.item].blurOrNot = true
                            //self.tableView.reloadRows(at: [swipedIndexPath], with: UITableViewRowAnimation.left)
                            swipedCell.visiualEffect.isHidden = true
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
                            swipedCell.visiualEffect.isHidden = false
                            self.storyArray[swipedIndexPath.item].blurOrNot = false
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
                    My.cellSnapshot!.center = center!
                    My.cellSnapshot!.transform = CGAffineTransform(scaleX: 1.05, y: 1.05)
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
            if My.cellSnapshot != nil {
                var center = My.cellSnapshot!.center
                center.y = locationInView.y
                My.cellSnapshot!.center = center
                
                if let indexPath = indexPath , indexPath != Path.initialIndexPath {
                    storyArray.insert(storyArray.remove(at: Path.initialIndexPath!.row), at: indexPath.row)
                    tableView.moveRow(at: Path.initialIndexPath!, to: indexPath)
                    Path.initialIndexPath = indexPath
                }
            }
        default:
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
                    My.cellSnapshot!.alpha = 0.0
                    cell?.alpha = 1.0
                    
                }, completion: { (finished) -> Void in
                    if finished {
                        Path.initialIndexPath = nil
                        My.cellSnapshot!.removeFromSuperview()
                        My.cellSnapshot = nil
                    }
                })
            }
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
                if(self.allStoryArray.count == 0){
                        //self.loading = true
                        print(self.allStoryArray.count)
                        self.allStoryArray = (response.value(forKey: "results") as? [[String: AnyObject]])!
                        //self.allHomesArray = (response.valueForKey("results") as? NSMutableArray)!
                        for i in 0 ..< self.allStoryArray.count{
                          let singleStory = self.allStoryArray[i]
                            let story_id = singleStory["story_id"] as! Int
                            let writen_by = singleStory["writen_by"] as! String
                            var story_cover_photo_path  = ""
                            var story_cover_photo_slice_code = ""
                            if let cover_photo_path = singleStory["story_cover_photo_path"] as? String{
                                 story_cover_photo_path = cover_photo_path
                            }
                            if let cover_photo_path = singleStory["story_cover_photo_slice_code"] as? String{
                                story_cover_photo_slice_code = cover_photo_path
                            }
                            
                            //let story_cover_photo_path = singleStory["story_cover_photo_path"] as! String
                            //let story_cover_photo_slice_code = singleStory["story_cover_photo_slice_code"] as!  String
                            let story = StoryModel(writen_by: writen_by, story_id: story_id, story_cover_photo_slice_code: story_cover_photo_slice_code, story_cover_photo_path: story_cover_photo_path,blurOrNot:false)
                            self.storyArray.append(story)
                            
                        }
                        //let = allStoryArray
                    DispatchQueue.main.async {
                         self.tableView.reloadData()
                    }
                    
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
        return storyArray.count
    }
    
    
      func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
     let cell = tableView.dequeueReusableCell(withIdentifier: "ListTableViewCell", for: indexPath) as! ListTableViewCell
        var story = self.storyArray[indexPath.item]
        
        var urlImage = story.story_cover_photo_path.components(separatedBy: "album")
        
        var totalPath = URLConstants.imgDomain
        if urlImage.count == 2{
        cell.storyImage.sd_setImage(with: URL(string: totalPath + urlImage[1]), placeholderImage: UIImage(named: ""))
        }
        cell.storyLabel.text = story.writen_by.capitalized
       if  story.blurOrNot{
        cell.visiualEffect.isHidden = false
        }else{
            cell.visiualEffect.isHidden = true
        }
        
     
     return cell
     }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 200
    }
 
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        var home = self.storyboard?.instantiateViewController(withIdentifier: "HomePage") as! ViewController
        var story = self.storyArray[indexPath.item]
        home.storyId = String(story.story_id)
        self.navigationController?.pushViewController(home, animated: true)
        
        
        
    }

}
