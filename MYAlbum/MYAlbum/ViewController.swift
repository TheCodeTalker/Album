//
//  ViewController.swift
//  MYAlbum
//
//  Created by Chitaranjan Sahu on 07/03/17.
//  Copyright © 2017 Ithink. All rights reserved.
//

import UIKit
import Photos
import AVKit
import NYTPhotoViewer
import Letters
import Alamofire
import SDWebImage
import DKImagePickerController
import NVActivityIndicatorView

let SCREENHEIGHT = UIScreen.main.bounds.height
let SCREENWIDTH = UIScreen.main.bounds.width
let cache = NSCache<NSString, UIImage>()


class ViewController: UIViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate,UICollectionViewDelegateFlowLayout,NVActivityIndicatorViewable,SetPartitionAfterInsideUpload,SaveDescriptionDelegate,autoScrollDelegate,UITextFieldDelegate,SaveCoverTitleDelegate {
    
    let MAX : UInt32 = 999999999
    let MIN : UInt32 = 1
    let TXTMAX : UInt64 = 99999999999999
    let TXTMIN : UInt64 = 1

    
    @IBOutlet var keyboardView: UIView!
   lazy  var collectionView :UICollectionView = {
        let layout = ZLBalancedFlowLayout()
        layout.setPartitionDelegate = self
        layout.headerReferenceSize = CGSize(width: UIScreen.main.bounds.width , height: UIScreen.main.bounds.height)
        layout.footerReferenceSize = CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height/2)
        layout.sectionInset = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        layout.minimumLineSpacing = 2
        layout.minimumInteritemSpacing = 2
        
        var collectionView = UICollectionView(frame: CGRect(x: self.view.frame.origin.x, y: self.view.frame.origin.y, width: self.view.frame.width, height: self.view.frame.height), collectionViewLayout: layout)
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.delegate = self
        collectionView.dataSource  = self
        collectionView.backgroundColor = UIColor.white
        collectionView.alwaysBounceVertical = true
        collectionView.bounces = false
        collectionView.register(UINib(nibName: "ImageCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: self.cellIdentifier)
        collectionView.register(UINib(nibName: "TextCellStory", bundle: nil), forCellWithReuseIdentifier: self.cellTextIdentifier)
        collectionView.register(UINib(nibName: "PictureHeader", bundle: nil), forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "HeaderView")
        collectionView.register(UINib(nibName: "FooterReusableView", bundle: nil), forSupplementaryViewOfKind: UICollectionElementKindSectionFooter, withReuseIdentifier: "FotterView")
    return collectionView
    }()
    
    var editTurnOn = false
    var upload = false
    
    lazy var singleTap: UITapGestureRecognizer = {
        var singleTap = UITapGestureRecognizer(target: self, action: #selector(ViewController.uploadCoverImageBtnAction))
        singleTap.numberOfTapsRequired = 1
        return singleTap
        
    }()
    
    
    // after upload collection view scroll
    var scrollToPostionAfterUpload = 0
    
    
   lazy  var scrollViewForColors :UIScrollView = {
        var colors = UIScrollView.init(frame: CGRect(x: 0, y: 0, width: SCREENWIDTH - 60, height: self.editToolBar.frame.size.height))
        
        colors.showsVerticalScrollIndicator = false
        colors.showsHorizontalScrollIndicator = false
        colors.backgroundColor = UIColor.white
        // CGSize(width: width, height: self.editToolBar.frame.size.height)
    
        return colors
    }()
    
    typealias partitionType = Array<Array<Array<String>>>
    //UIView *lineView;
    var cellsToMove0 = NSMutableArray.init()
    var selectedIndexPath = 0
    
    var colorCodeArray = ["#c6bfe5","#1f1f1f","#686869","#7a797d","#645c64"]
    lazy var editToolBar: UIToolbar  = {
        var edit = UIToolbar(frame: CGRect(x: 0, y: SCREENHEIGHT - 60, width: SCREENWIDTH, height: 60))
        return edit
    }()
    
    lazy var autoBarButton:UIBarButtonItem = {
        var element  = UIBarButtonItem.init(title: "Auto", style: UIBarButtonItemStyle.plain, target: self, action: #selector(ViewController.changeAspectRatioOfSelectedItem(_:)))
        element.tag = 0
        return element
    }()
    
    lazy var threeToTwo:UIBarButtonItem = {
        var element  = UIBarButtonItem.init(title: "3:2", style: UIBarButtonItemStyle.plain, target: self, action: #selector(ViewController.changeAspectRatioOfSelectedItem(_:)))
        element.tag = 1
        return element
    }()
    
    lazy var twoToThree:UIBarButtonItem = {
        var element  = UIBarButtonItem.init(title: "2:3", style: UIBarButtonItemStyle.plain, target: self, action: #selector(ViewController.changeAspectRatioOfSelectedItem(_:)))
        element.tag = 2
        return element
    }()
    
    lazy var oneToOne:UIBarButtonItem = {
        var element  = UIBarButtonItem.init(title: "3:1", style: UIBarButtonItemStyle.plain, target: self, action: #selector(ViewController.changeAspectRatioOfSelectedItem(_:)))
        element.tag = 3
        return element
    }()
    
    lazy var threeToOne:UIBarButtonItem = {
        var element  = UIBarButtonItem.init(title: "1:1", style: UIBarButtonItemStyle.plain, target: self, action: #selector(ViewController.changeAspectRatioOfSelectedItem(_:)))
        element.tag = 4
        return element
    }()

    lazy var oneToThree:UIBarButtonItem = {
        var element  = UIBarButtonItem.init(title: "1:3", style: UIBarButtonItemStyle.plain, target: self, action: #selector(ViewController.changeAspectRatioOfSelectedItem(_:)))
        element.tag = 5
        return element
    }()
    
    lazy var editToolbarItemDoneshape:UIBarButtonItem = {
        var upload = UIBarButtonItem.init(image: UIImage(named: "check"), landscapeImagePhone: UIImage(named: "check"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(ViewController.turnOnEditMode))
        return upload
    }()

    
    

    
    
    
    
     lazy var uploadMorePhotoButton:UIBarButtonItem = {
        var upload = UIBarButtonItem.init(image: UIImage(named: "img-album"), landscapeImagePhone: UIImage(named: "img-album"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(morePhotoUpload))
        return upload
    }()
    
    lazy var addTextButton:UIBarButtonItem = {
        var upload = UIBarButtonItem.init(image: UIImage(named: "typ-cursor"), landscapeImagePhone: UIImage(named: "typ-cursor"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(addTextCell))
        return upload
    }()
    
    lazy var leftAlign:UIBarButtonItem = {
        var upload = UIBarButtonItem.init(image: UIImage(named: "typ-cursor"), landscapeImagePhone: UIImage(named: "typ-cursor"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(addTextCell))
        return upload
    }()
    
    
    
    lazy var backBarButton:UIBarButtonItem = {
        var upload = UIBarButtonItem.init(image: UIImage(named: "ios-previous"), landscapeImagePhone: UIImage(named: "ios-previous"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(ViewController.cancelClicked))
        return upload
    }()
    
    lazy var moreButton:UIBarButtonItem = {
        var upload = UIBarButtonItem.init(image: UIImage(named: "ios-more"), landscapeImagePhone: UIImage(named: "ios-more"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(ViewController.dontDoAnything))
        return upload
    }()
    lazy var shareButton:UIBarButtonItem = {
        var upload = UIBarButtonItem.init(image: UIImage(named: "share"), landscapeImagePhone: UIImage(named: "share"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(ViewController.dontDoAnything))
        return upload
    }()

    lazy var editTextCellButton:UIBarButtonItem = {
        var upload = UIBarButtonItem.init(image: UIImage(named: "edit"), landscapeImagePhone: UIImage(named: "edit"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(ViewController.addTitleToTextCell))
        return upload
    }()
    lazy var editToolbarItemDone:UIBarButtonItem = {
        var upload = UIBarButtonItem.init(image: UIImage(named: "Check"), landscapeImagePhone: UIImage(named: "Check"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(ViewController.editToolbarConfigurationForTextCells))
        return upload
    }()
    
    
    
    lazy var coverBarButton:UIBarButtonItem = {
        var upload = UIBarButtonItem.init(image: UIImage(named: "profile-1"), landscapeImagePhone: UIImage(named: "profile-1"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(ViewController.setCoverPhoto(_:)))
        return upload
    }()
    
    
    lazy var shapeBarButton:UIBarButtonItem = {
        var upload = UIBarButtonItem.init(image: UIImage(named: "shape"), landscapeImagePhone: UIImage(named: "shape"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(ViewController.setToolbarConfigurationForShapeOfCells))
        return upload
    }()
    
    lazy var deleteBarButton1:UIBarButtonItem = {
        var upload = UIBarButtonItem.init(barButtonSystemItem: UIBarButtonSystemItem.trash, target: self, action: #selector(ViewController.dontDoAnything))
        
        return upload
    }()
    
    
    lazy var alignmentButton:UIBarButtonItem = {
        var upload = UIBarButtonItem.init(image: UIImage(named: "AlignCenter"), landscapeImagePhone: UIImage(named: "AlignCenter"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(ViewController.dontDoAnything))
        return upload
    }()
    
    lazy var colorButton:UIBarButtonItem = {
        var upload = UIBarButtonItem.init(image: UIImage(named: "color"), landscapeImagePhone: UIImage(named: "color"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(ViewController.editToolbarForTextCellColor))
        return upload
    }()
    
    lazy var deleteBarButton:UIBarButtonItem = {
        
        var upload = UIBarButtonItem.init(barButtonSystemItem: UIBarButtonSystemItem.trash, target: self, action: #selector(ViewController.deleteSelectedItem(_:)))
       
        return upload
    }()
    lazy var fixedSpace:UIBarButtonItem = {
        var upload = UIBarButtonItem.init(barButtonSystemItem: UIBarButtonSystemItem.fixedSpace, target: self, action: #selector(ViewController.dontDoAnything))
        
        return upload
    }()
    lazy var flexibleSpace:UIBarButtonItem = {
    var upload = UIBarButtonItem.init(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        
        return upload
    }()
    
  
    

    
   lazy var editButton:UIBarButtonItem = {
        var upload = UIBarButtonItem.init(image: UIImage(named: "edit"), landscapeImagePhone: UIImage(named: "edit"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(ViewController.turnOnEditMode))
        return upload
    }()
    
    lazy var closeEdit:UIBarButtonItem = {
        var upload = UIBarButtonItem.init(image: UIImage(named: "ui-cross_1"), landscapeImagePhone: UIImage(named: "ui-cross_1"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(ViewController.closeEditInStory))
        return upload
    }()
    
    

    
    
    
    
    var cellsToMove1 = NSMutableArray.init()
    var lineView : UIView = UIView(frame: CGRect.zero)
    var localPartition  = Array<Array<Array<String>>>()
    let CustomEverythingPhotoIndex = 1, DefaultLoadingSpinnerPhotoIndex = 3, NoReferenceViewPhotoIndex = 4
    fileprivate var imageCount : NSNumber = 0
    var requestOptions = PHImageRequestOptions()
    var requestOptionsVideo = PHVideoRequestOptions()
    fileprivate var videoCount : NSNumber = 0
    var mutablePhotos: [ExamplePhoto] = []
    var originalIndexPath: IndexPath?
    var swapImageView: UIImageView?
    var stopped : Bool = false
    var storyId :String = ""
    var editingTextFieldIndex = Int.init()
    var selectedItemIndex = Int.init()
    let defaults = UserDefaults.standard
    var swapView: UIView?
    var draggingIndexPath: IndexPath?
    var frameOfDragingIndexPath : CGPoint?
    var draggingView: UIView?
    var coverdata : UIImage?
    var dragOffset = CGPoint.zero
    var longPressGesture : UILongPressGestureRecognizer?
    fileprivate var images = [UIImage](), needsResetLayout = false
    let PrimaryImageName = "NYTimesBuilding"
    let PlaceholderImageName = "NYTimesBuildingPlaceholder"
    fileprivate let cellIdentifier = "ImageCell", headerIdentifier = "header", footerIdentifier = "footer"
    fileprivate let cellTextIdentifier = "TextCell"
    var collectionArray  = [[AnyHashable:Any]]()
    var headerView : PictureHeaderCollectionReusableView?
    
    var originalYOffset =  CGFloat()
    
    //storyDetails
    
    var creatingStory = false
    var viewStoryId = 0
    var writen_by = ""
    var story_cover_photo_path = ""
    var story_cover_photo_code = ""
    var story_cover_photo_slice_code = ""
    var story_json = [[String:AnyObject]]()
    var isViewStory = false
    var reloadHeaderView = true
    
    var storyTitle  = ""
    var storySubtitle = ""
    
    var headerCellTextFieldEditing = false
    
    //var pickerController: GMImagePickerCon!
    //  var assets: [DKAsset]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
       
        
        selectedItemIndex = -1
       editingTextFieldIndex = -1
        defaults.set(false, forKey: "isViewStory")
        if creatingStory{
        self.IbaOpenGallery()
        }
        self.setUI()
        defaults.removeObject(forKey: "partition")
        defaults.removeObject(forKey: "addedMorePhotos")
        defaults.set(false, forKey: "insideUploads")
        defaults.synchronize()
        
        self.registerForKeyboardNotifications()
        
        //flag for story View or not
        if !isViewStory{
            
            if storyId == ""{
                storyId = String(randomNumber())
            }else{
                isViewStory = false
                editTurnOn = false
                getDetailStoryWithId(storyId: storyId) {
                    // self.collectionView.collectionViewLayout.invalidateLayout()
                    
                    runOnMainThread {
                   
                        self.swapView = UIView(frame: CGRect.zero)
                        self.swapImageView = UIImageView(image: UIImage(named: "Swap-white"))
                        
                        self.view.addSubview(self.collectionView)
                        self.isViewStory = true
                        self.collectionView.reloadData()
                        self.collectionView.collectionViewLayout.invalidateLayout()
                        
                    }
                    
                    
                    
                    
                }
                
            }
            
            
        }else{
            //not view
            
        }
        
    }
    
    
    deinit {
        self.creatingStory = false
        self.editTurnOn = false
        self.upload = false
        NotificationCenter.default.removeObserver(self)
        self.deRegisterForKeyboardNotifications()
    }
    
    func setCoverPhoto(_ sender: UIBarButtonItem)  {
        
        
        let alertView = UIAlertController(title: "Cover photo", message: "Do you want to use this photo as the cover photo of your album.", preferredStyle: .alert)
        let action = UIAlertAction(title: "Yes", style: .default, handler: { (alert) in
            
            if let headerAttributes =  self.collectionView.collectionViewLayout.layoutAttributesForItem(at: IndexPath(item: 0, section: 0)){
                
                
                let data = self.collectionArray[self.selectedItemIndex]
                if let story_cover_photo_path =  data["item_url"] as? String
                {
                    self.story_cover_photo_path = story_cover_photo_path
                    
                    var url = story_cover_photo_path
                    var urlImage = url.components(separatedBy: "album")
                    let totalPath = URLConstants.imgDomain
                    if urlImage.count == 2 {
                        let second = urlImage[1]
                        url = totalPath + second
                    }else{
                        if let first = urlImage.first{
                            url = totalPath + first
                        }
                        
                    }
                    //url = totalPath + (urlImage?[1])!
                    var version = url.components(separatedBy: "compressed")
                    
                    var afterAppending  = url.components(separatedBy: "compressed")
                    var widthImage = (version.first)! + "480" + (afterAppending[1])
                    
                    DispatchQueue.global(qos: .background).async {
                        
                        self.headerView?.iboHeaderImage.sd_setImage(with: URL(string: widthImage), placeholderImage: UIImage(named: ""), options: SDWebImageOptions.progressiveDownload, completed: { (image, data, error, finished) in
                            
                            
                            guard let image = image else { return  }
                            print("Image loaded!")
                            self.headerView?.iboHeaderImage.contentMode = UIViewContentMode.scaleAspectFill
                            self.headerView?.iboHeaderImage.image = image
                            self.coverdata = image
                            
                            DispatchQueue.main.async {
                                self.collectionView.reloadData()
                                self.collectionView.setContentOffset(CGPoint(x: 0, y: (headerAttributes.frame.origin.x)), animated: true)                            }
                            
                            
                        })
                        
                    }
                    
                    //                    if let data = UIImagePNGRepresentation(imageCell.imageViewToShow)!{
                    //                        self.coverdata = data
                    //                    }
                    
                }
                
                self.collectionView.setContentOffset(CGPoint(x: 0, y: (headerAttributes.frame.origin.x)), animated: true)
            }
            
            
            
            
        })
        let cancel = UIAlertAction(title: "Cancel", style: .default, handler: { (alert) in
            
        })
        alertView.addAction(action)
        alertView.addAction(cancel)
        self.present(alertView, animated: true, completion: nil)
        
        
    }
    // MARK:-shape images
    func setToolbarConfigurationForShapeOfCells() {
        
        
        self.editToolBar.items = nil
        
        if (scrollViewForColors.isDescendant(of: self.editToolBar)){
            self.scrollViewForColors.removeFromSuperview()
        }
        
        
        self.editToolBar.items = [autoBarButton,fixedSpace,threeToTwo,fixedSpace,twoToThree,fixedSpace,oneToOne,flexibleSpace,threeToOne,flexibleSpace,oneToThree,flexibleSpace,editToolbarItemDoneshape]
     
        
    }
    
    func changeAspectRatioOfSelectedItem(_ sender: UIBarButtonItem)  {
        
        let item = self.collectionArray[self.selectedItemIndex]
        let oldSizeString = item["original_size"] as! CGSize
    //   let oldSize =  CGSizeFromString(oldSizeString)
        let newWidth = oldSizeString.width
        let newHeight = oldSizeString.height
        let squaredVal = newWidth * newHeight
        var newlySize = CGSize.init()
        if sender.tag == 0
        {
            newlySize = oldSizeString
        }else if sender.tag == 1{
            newlySize = CalculationsShape.getSizeWithFloatValue(number: Float(squaredVal/6), widthConstant: 3, heightConstant: 2) as! CGSize
        }else if sender.tag == 2{
            newlySize = CalculationsShape.getSizeWithFloatValue(number: Float(squaredVal/6), widthConstant: 2, heightConstant: 3) as! CGSize
        }else if sender.tag == 3{
            newlySize = CalculationsShape.getSizeWithFloatValue(number: Float(squaredVal), widthConstant: 1, heightConstant: 1) as! CGSize
        }else if sender.tag == 4{
            newlySize = CalculationsShape.getSizeWithFloatValue(number: Float(squaredVal/3), widthConstant: 3, heightConstant: 1) as! CGSize
        }else if sender.tag == 5{
            newlySize = CalculationsShape.getSizeWithFloatValue(number: Float(squaredVal/3), widthConstant: 1, heightConstant: 3) as! CGSize
        }
        
        self.collectionArray[self.selectedItemIndex]["item_size"] = newlySize
        
       // self.collectionArray[self.selectedItemIndex] = newObj
        DispatchQueue.main.async {
        
            UIView.animate(withDuration: 2.0) {
               // self.collectionView.reloadData()
                self.collectionView.collectionViewLayout.invalidateLayout()
            }
            
            
        }
        
        
        
    }
    
    func deleteSelectedItem(_ sender: UIBarButtonItem)  {
        let alertView = UIAlertController(title: "Delete item", message: "Are you sure you wish to delete this item?", preferredStyle: .alert)
        let action = UIAlertAction(title: "Delete", style: .default, handler: { (alert) in
            
            
            DispatchQueue.main.async {
                self.title = ""
                self.collectionArray.remove(at: self.selectedItemIndex)
                let singletonArray = self.getSingletonArray()
                let obj = singletonArray[self.selectedItemIndex]
                let keys = obj.components(separatedBy: "-")
                var rowArray = self.localPartition[Int(keys.first!)!]
                var colArray = rowArray[Int(keys[1])!]
                colArray.remove(at: colArray.count - 1)
                
                if colArray.count > 0{
                    rowArray[Int(keys[1])!] = colArray
                    self.localPartition[Int(keys.first!)!] = rowArray
                }else{
                    rowArray.remove(at: Int(keys[1])!)
                    if rowArray.count > 0 {
                        self.localPartition[Int(keys.first!)!] = rowArray
                    }else{
                        self.localPartition.remove(at: Int(keys.first!)!)
                        
//                        for(int i = [[keys firstObject] integerValue];i<[localPartition count];i++){
//                            NSMutableArray *rowArray = [[localPartition objectAtIndex:i] mutableCopy];
//                            for(int j=0;j<[rowArray count];j++){
//                                NSMutableArray *colArray = [rowArray[j] mutableCopy];
//                                for (NSInteger k=0; k<[colArray count]; k++) {
//                                    [colArray replaceObjectAtIndex:k withObject:[NSString stringWithFormat:@"%d-%d-%d",i,j,k]];
//                                }
//                                [rowArray replaceObjectAtIndex:j withObject:colArray];
//                            }
//                            [localPartition replaceObjectAtIndex:i withObject:rowArray];
//                        }
                        if   let first = Int(keys.first!){
                            for i in first ..< self.localPartition.count{
                                var rowArray = self.localPartition[i]
                                
                                for j in 0 ..< rowArray.count{
                                    var colArray = rowArray[j]
                                    for k in 0 ..< colArray.count{
                                        colArray[k] = "\(i)-\(j)-\(k)"
                                    }
                                    rowArray[j] = colArray
                                }
                                self.localPartition[i] = rowArray
                            }
                  
                        }
                 
                    }
                }
                
               self.defaults.set(self.localPartition, forKey: "partition")
                
                self.collectionView.performBatchUpdates({
                    let selectedIndex = IndexPath(item: self.selectedItemIndex, section: 0)
                    self.collectionView.deleteItems(at: [selectedIndex])
                }, completion: { (flag) in
                    self.selectedItemIndex = -1
                    let set :IndexSet = [0]
                    CATransaction.begin()
                    CATransaction.setValue(kCFBooleanTrue, forKey: kCATransactionDisableActions)
                    self.collectionView.reloadSections(set)
                    CATransaction.commit()
                    self.setInitialToolbarConfiguration()
                })
                
                
                
            }

            
            
            
        })
        let cancel = UIAlertAction(title: "Cancel", style: .default, handler: { (alert) in
            
        })
        alertView.addAction(action)
        alertView.addAction(cancel)
        self.present(alertView, animated: true, completion: nil)
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        if textField.tag == 98 || textField.tag == 99{
            headerCellTextFieldEditing = true
        }
        
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
            
            if textField.tag == 99{
                self.headerView?.iboSubTitle.becomeFirstResponder()
                //textField.becomeFirstResponder()
            }
            if textField.tag == 98{
                textField.resignFirstResponder()
            }
            
            return true
        
    }
    
    
    
    
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField.tag == 98{
            if textField.hasText{
                storySubtitle = textField.text!
            }
            headerCellTextFieldEditing = false
            
        }
        else if textField.tag == 99{
            if textField.hasText {
            storyTitle = textField.text!
            }
            
            headerCellTextFieldEditing = false
            
        }
    }
    
    
    func randomNumber() -> Int
    {
        var random_number = Int(arc4random_uniform(MAX) + MIN)
        print ("random = ", random_number);
        return random_number
    }
    func generateTextId() -> String{
        var rnd : UInt64 = TXTMIN

         arc4random_buf(&rnd, MemoryLayout.size(ofValue: rnd))
        
       // var random_number = String(arc4random_uniform(TXTMAX) + TXTMIN)
        //print ("random TextId = ", random_number);
        return  String(rnd % TXTMAX)
    }
    
    func addTitleToTextCell()  {
        
        let textViewController  = storyboard?.instantiateViewController(withIdentifier: "TextViewController") as! TextViewController
        textViewController.delegate = self
        
        textViewController.titleText = self.collectionArray[self.selectedItemIndex]["title"] as! String
        textViewController.subTitleText = self.collectionArray[self.selectedItemIndex]["description"] as! String
        //self.collectionArray[selectedIndex]["title"] = title
      //  self.collectionArray[selectedIndex]["description"] = subtitle
        
        
        textViewController.selectedIndex = self.selectedItemIndex
        self.present(textViewController, animated: true, completion: nil)
        
    }
    
    
    func saveDescriptionDidFinish(_ controller:TextViewController,title:String,subtitle:String,indexToUpdate selectedIndex:Int)
    {
     
        self.collectionArray[selectedIndex]["title"] = title
        self.collectionArray[selectedIndex]["description"] = subtitle
        
        selectedItemIndex =  -1
        
        if(selectedItemIndex != selectedIndex){
            var previousSelected = selectedItemIndex
            selectedItemIndex = selectedIndex
            if previousSelected != -1{
                
                
                
            }
            
        }
        
        DispatchQueue.main.async {
            self.collectionView.performBatchUpdates({
                self.collectionView.reloadItems(at: [IndexPath(item: selectedIndex, section: 0)])
            }) { (test) in
                
            }

        
        }
        
    }
    func setUI() {
        
        self.fixedSpace.width = 20
        DispatchQueue.main.async {
            
            self.navigationController?.navigationBar.isHidden = false
            self.navigationController?.isNavigationBarHidden = false
            self.navigationController?.navigationBar.setBackgroundImage(UIImage.init(), for: UIBarMetrics.default)
            self.navigationController?.navigationBar.shadowImage = UIImage.init()
            self.navigationController?.navigationBar.isTranslucent = true
            self.navigationController?.navigationBar.backgroundColor = UIColor.clear
            self.navigationController?.navigationBar.alpha = 1
            
            self.navigationController?.setNavigationBarHidden(false, animated: true)
            self.navigationItem.setLeftBarButton(self.backBarButton, animated: true)
            self.navigationItem.leftBarButtonItem?.isEnabled = true
            self.navigationItem.setHidesBackButton(false, animated: true)
            self.navigationItem.setRightBarButtonItems([self.moreButton,self.shareButton,self.editButton], animated: true)
            self.navigationController?.navigationBar.tintColor = UIColor.white
            self.setNeedsStatusBarAppearanceUpdate()
            
            self.navigationController?.navigationBar.barTintColor = UIColor.white
        }
        
        
      //  self.collectionView.removeGestureRecognizer(<#T##gestureRecognizer: UIGestureRecognizer##UIGestureRecognizer#>)
        
       // self.navigationController?.setNavigationBarHidden(false, animated: true)
        
        
        //self.navigationController setNavigationBarHidden:NO];
        
        //[self.navigationItem setHidesBackButton:NO];
//        [self.navigationItem setRightBarButtonItems:[NSArray arrayWithObjects:moreButton, shareButton, editButton, nil]];
  //      [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
        
        
        
        
        
    }
    
    
    
    func morePhotoUpload()  {
        
        if self.localPartition.count > 0{
            
            defaults.set(true, forKey: "insideUploads")
        }else{
            defaults.set(false, forKey: "insideUploads")
        }
        
        self.showImagePicker()
    }
    
    func setPartitionAfterInsideUpload()
    {
        
        if let local  = defaults.object(forKey: "partition") as? partitionType{
            self.localPartition = local
        }

        
    }
    
    func setNavigationBarForViewMode() {
        self.editToolBar.removeFromSuperview()
        self.title = ""
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        //[self.navigationController setNavigationBarHidden:NO];
        self.navigationItem.setLeftBarButton(backBarButton, animated: true)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        self.navigationItem.setRightBarButtonItems([moreButton,shareButton,editButton], animated: false)
        self.navigationController?.navigationBar.tintColor = UIColor.white
        //[self.navigationItem setLeftBarButtonItems:[NSArray arrayWithObjects:backBarButton, nil]];
        //[self.navigationItem setHidesBackButton:NO];
       // [self.navigationItem setRightBarButtonItems:[NSArray arrayWithObjects:moreButton, shareButton, editButton, nil]];
        //[self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
        

    
    }
    
    func giveGridFrame(index: Int,frame: [String]) -> CGRect{
        var rectArray   = frame.map { CGRectFromString($0)  }
        return rectArray[index]
    }
    
    func giveFramesFrame(index: Int,framesFrame: [String]) -> CGRect {
        var rectArray   = framesFrame.map { CGRectFromString($0)  }
        return rectArray[index]
    }
    
    
    func  giveKeyForValue(key:String,index:Int) -> Any {
            var temp =  self.collectionArray[index]
            return temp[key]
        
        
    }
    
    enum ImagePosition {
        case LEFT
        case BOTTOM(Int)
        case NOTDEFIND
    }
    
    func compareReturnLeftOrBottom(parant:String,child:String) -> ImagePosition {
        
        var parantKeys = parant.components(separatedBy: "-")
        
        var childKeys = child.components(separatedBy: "-")
        if parantKeys[0] == childKeys[0]{
            
            if parantKeys[1] < childKeys[1]{
                return .LEFT
            }else{
                if parantKeys[2] < childKeys[2]{
                    return .BOTTOM(Int(childKeys[1])!)
                }else{
                    return .NOTDEFIND
                }
            }
            
        }else{
            return .NOTDEFIND
        }
    }
    
    func postDataForStoryMaking()  {
        
        var id = [String]()
          var frmaes = defaults.object(forKey: "Frames") as! [String]
        print("frmaes\(frmaes)")
          var FramesForEachRow = defaults.object(forKey: "FramesForEachRow") as! [String]
        print("FramesForEachRow\(FramesForEachRow)")
        
        
        //self.localPartition
        
        for (index,element) in self.collectionArray.enumerated(){
            var  element_id = element["photo_id"] as! String
            id.append(element_id)
        }
        
        let singleArray = self.getSingletonArray()
        
        var storyJsonDictonary  = [[AnyHashable:Any]]()
        var gridHeight = 0
        var gridTop = CGFloat(0)
        var countNoOfElement = 0
        for (index,element) in self.localPartition.enumerated(){
            
            var gridHeightDict = [AnyHashable:Any]()
            gridHeightDict.updateValue(gridTop, forKey: "top")
            gridHeightDict.updateValue(0, forKey: "left")
            var giveGridFrame = self.giveGridFrame(index: index, frame: FramesForEachRow)
            gridHeightDict.updateValue(giveGridFrame.size.height, forKey: "height")
            
            
           var itemsDict = [[AnyHashable:Any]]()
            
            
            var parant = element[0].first
            for(index1,element1) in element.enumerated(){
                
               
                var heightForTop = CGFloat(0)
                var widthForLeft = CGFloat(0)
            
                for(index2,element2) in element1.enumerated(){
                    if element1.count > 1 && index2 > 0{
                        parant = element1.first
                    }
                    var items = [AnyHashable:Any]()
                    let frame = self.giveFramesFrame(index: countNoOfElement, framesFrame: frmaes)
                    let type = self.giveKeyForValue(key: "type", index: countNoOfElement)
                    let original_size = self.giveKeyForValue(key: "original_size", index: countNoOfElement)
                    let url = self.giveKeyForValue(key: "item_url", index: countNoOfElement) as? String ?? ""
                    var image_Path = ""
                    if url.contains("http"){
                    image_Path = url
                    }else{
                        image_Path = URLConstants.imgDomain + url
                    }
                    
                   // let original_height = self.giveKeyForValue(key: "dh", index: countNoOfElement)
                    guard let typeElement = type as? String else {
                        return
                    }
                     var width_CGFloat  = CGFloat.init()
                    var height_CGFloat = CGFloat.init()
                     var factor  = CGFloat.init()
                    
                    if typeElement == "Text"{
                       width_CGFloat = SCREENWIDTH
                        
                        height_CGFloat = (CGSizeFromString(original_size as! String).height)
                    }else if  typeElement == "video"{
                        
                        width_CGFloat = CGFloat((original_size as! CGSize).width)
                        height_CGFloat = CGFloat((original_size as! CGSize).height)
                        factor  = width_CGFloat / height_CGFloat

                        
                        
                        }else{
                            width_CGFloat = CGFloat((original_size as! CGSize).width)
                            height_CGFloat = CGFloat((original_size as! CGSize).height)
                            factor  = width_CGFloat / height_CGFloat

                        }
                    
                    
                   
                   
                   
                    
                    if  index1 == 0 && index2 == 0 {
                       
                        if typeElement == "Text"{
                            items.updateValue(0, forKey: "left")
                            items.updateValue(0, forKey: "top")
                            items.updateValue(id[countNoOfElement], forKey: "id")
                            items.updateValue(id[countNoOfElement], forKey: "imagePath")
                            items.updateValue(frame.size.width, forKey: "width")
                            items.updateValue(frame.size.height, forKey: "height")
                            items.updateValue("txt", forKey: "type")
                            let title = self.giveKeyForValue(key: "title", index: countNoOfElement) as? String ?? ""
                            let sub = self.giveKeyForValue(key: "description", index: countNoOfElement) as? String ?? ""
                            items.updateValue(title, forKey: "textTitle")
                            items.updateValue(sub, forKey: "textSubTitle")
                            items.updateValue("\(width_CGFloat)", forKey: "dw")
                            items.updateValue("\(height_CGFloat)", forKey: "dh")
                           // items.updateValue("\(factor)", forKey: "factor")
                           // items.updateValue(color, forKey: "color")
                            items.updateValue("", forKey: "below")

                            
                        }else{
                            
                           
                                
                              
                                
                          
                                
                                items.updateValue(0, forKey: "left")
                                items.updateValue(0, forKey: "top")
                                items.updateValue(id[countNoOfElement], forKey: "id")
                                items.updateValue(image_Path, forKey: "imagePath")
                                items.updateValue(frame.size.width, forKey: "width")
                                items.updateValue(frame.size.height, forKey: "height")
                                items.updateValue(type, forKey: "type")
                                items.updateValue("\(width_CGFloat)", forKey: "dw")
                                items.updateValue("\(height_CGFloat)", forKey: "dh")
                                items.updateValue("\(factor)", forKey: "factor")
                             if typeElement != "video"{
                                let color = self.giveKeyForValue(key: "hexCode", index: countNoOfElement)
                                items.updateValue(color, forKey: "color")
                            }
                                items.updateValue("", forKey: "below")

                          
                            

                            
                        }
                        
                        
                    }else{
                      //  var sourseKeys = element2.components(separatedBy: "-")
                        
                        var leftOrBottom = self.compareReturnLeftOrBottom(parant: parant!, child: element2)
                        
                       switch leftOrBottom {
                       case  .LEFT:
                        let leftFrame = self.giveFramesFrame(index: countNoOfElement - 1, framesFrame: frmaes)
                        widthForLeft += leftFrame.size.width
                        
                        items.updateValue(widthForLeft, forKey: "left")
                        items.updateValue(0, forKey: "top")
                        items.updateValue(id[countNoOfElement], forKey: "id")
                        items.updateValue(image_Path, forKey: "imagePath")
                        items.updateValue(frame.size.width, forKey: "width")
                        items.updateValue(frame.size.height, forKey: "height")
                        items.updateValue(type as! String, forKey: "type")
                        items.updateValue("\(width_CGFloat)", forKey: "dw")
                        items.updateValue("\(height_CGFloat)", forKey: "dh")
                        items.updateValue(factor, forKey: "factor")
                        if typeElement != "video"{
                         let color = self.giveKeyForValue(key: "hexCode", index: countNoOfElement)
                        items.updateValue(color, forKey: "color")
                        }
                        items.updateValue("", forKey: "below")
                        
                        break
                        
                       case .BOTTOM(let postion):
                        
                        
                        let index = singleArray.index(of: parant!)
                        print(index)
                        //let ph = self.giveKeyForValue(key: "photo_id", index: index)
                        let photo_id = self.giveKeyForValue(key: "photo_id", index: index!)
                        
                        heightForTop += frame.size.height
                        
                        items.updateValue(widthForLeft, forKey: "left")
                        items.updateValue(heightForTop, forKey: "top")
                        items.updateValue(id[countNoOfElement], forKey: "id")
                        items.updateValue(image_Path, forKey: "imagePath")
                        items.updateValue(frame.size.width, forKey: "width")
                        items.updateValue(frame.size.height, forKey: "height")
                        items.updateValue(type as! String, forKey: "type")
                        items.updateValue("\(width_CGFloat)", forKey: "dw")
                        items.updateValue("\(height_CGFloat)", forKey: "dh")
                        items.updateValue(factor, forKey: "factor")
                        if typeElement != "video"{
                         let color = self.giveKeyForValue(key: "hexCode", index: countNoOfElement)
                        items.updateValue(color, forKey: "color")
                        }
                        items.updateValue(photo_id as! String, forKey: "below")

                  
                        print(postion)
                        
                        break
                        
                       case .NOTDEFIND:
                        
                        break
                        
                        }
                        
                    }
                    countNoOfElement += 1
                    
                    print("singke element\(gridHeightDict)")
                    print(element2)
                    itemsDict.append(items)
                
                }
                
                
            }
            
            
            gridHeightDict.updateValue(itemsDict, forKey: "items")
            gridTop += giveGridFrame.size.height

            print("grid element\(gridHeightDict)")
            storyJsonDictonary.append(gridHeightDict)
            
        }
        print("grid element\(storyJsonDictonary)")
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: storyJsonDictonary, options: .prettyPrinted)
            // here "jsonData" is the dictionary encoded in JSON data
            
            let decoded = try JSONSerialization.jsonObject(with: jsonData, options: [])
            
            var storyJSON = String.init(data: jsonData, encoding: String.Encoding.utf8)
            
            self.postStoryData(storyDataTosend: storyJSON!)
            
            
        } catch {
            print(error.localizedDescription)
        }
        
        
        
    }
    
    func dontDoAnything() {
        
    }
    
    func saveCoverTitleDidFinish(_ controller:CoverTitleViewEditViewController,title:String,subtitle:String)
    {
        if let header = self.headerView{
            storyTitle = title
            storySubtitle = subtitle
            header.iboTitle.text = title
            header.iboSubTitle.text = subtitle
        }
    }
    
    func uploadCoverImageBtnAction() {
        
        var coverViewController = self.storyboard?.instantiateViewController(withIdentifier: "CoverTitleViewEditViewController") as! CoverTitleViewEditViewController
        coverViewController.delegate = self
        if let header = self.headerView{
            coverViewController.coverImageView = self.coverdata
            if header.iboTitle.hasText{
                coverViewController.titleText = header.iboTitle.text!
            }
            if header.iboSubTitle.hasText{
                 coverViewController.subTitleText = header.iboSubTitle.text!
            }
            
           
        }
        
        self.present(coverViewController, animated: true, completion: nil)
       
       
        
        
    }
    
    
    func appendStroyIdAnddetails(Params: inout [String:String]) {
        for (index,element) in self.collectionArray.enumerated(){
            if (element["type"] as! String) != "Text"{
            
            Params.updateValue(element["photo_id"] as! String, forKey: "story_photo[\(index)][photo_id]")
            let  imgurl = element["item_url"] as! String
            let totalPath = URLConstants.imgDomain
            var url = ""
            var urlImage = imgurl.components(separatedBy: "album")
            
            if urlImage.count == 2 {
                var second = urlImage[1]
                second.remove(at: second.startIndex)
                url = totalPath + second
            }else{
                let first = urlImage[0]
                url = totalPath + first
                
            }
            
            
            Params.updateValue(url , forKey: "story_photo[\(index)][photo_path]")
            if (element["type"] as! String) != "video"{
                Params.updateValue(element["hexCode"] as! String, forKey: "story_photo[\(index)][color_codes]")
                }
            
        }
        
           // print(Params)
        }
        
     //   return Params
        
    }
    
    func postStoryData(storyDataTosend:String)  {
        
        var  paramsDict = [String:String]()
        paramsDict.updateValue(storyId, forKey: "storyId")
        paramsDict.updateValue(self.storyTitle, forKey: "story_heading")
        paramsDict.updateValue(self.storySubtitle, forKey: "story_heading_description")
        paramsDict.updateValue("Chitaranjan", forKey: "writen_by")
        paramsDict.updateValue("CH", forKey: "writen_by_name_initials")
        paramsDict.updateValue("14946557868453", forKey: "writen_by_id")
        paramsDict.updateValue("chitaranjan", forKey: "writen_by_img")
        paramsDict.updateValue(story_cover_photo_path, forKey: "story_cover_photo_path")
        paramsDict.updateValue("#2b2b2a,#d2c6ad,#847f75,#9da29f,#6c86a2", forKey: "story_cover_photo_code")
        paramsDict.updateValue("#2b2b2a", forKey: "story_cover_photo_slice_code")
        paramsDict.updateValue(storyDataTosend, forKey: "storyJson")
        //print(paramsDict)
        
        //    Params = Params +
         self.appendStroyIdAnddetails(Params: &paramsDict)
          //print(paramsDict)
        
        let pa = paramsDict as [String : Any]
          print(pa)
        var url = URLConstants.BaseURL + "addStory"
        Alamofire.request(url, method: .post, parameters: pa , encoding: URLEncoding.default, headers: nil)
            .validate()
            .responseJSON { (response:DataResponse<Any>) in
            print(response)
            switch response.result {
            case .success(let JSON):
                print("Success with JSON: \(JSON)")
                let response = JSON as! NSDictionary
                print("reee", response)
                let allKeys : NSArray  = response.allKeys as NSArray;
                let tempVal : Bool = allKeys.contains("error")
                //retVal = [allKeys containsObject:key];
                //return retVal;
                //   if(response.key)
                if(tempVal == true){
                    let errorCode: AnyObject = response.value(forKeyPath: "error.errorCode") as! NSNumber
                    let errorMSG  = response.value(forKeyPath: "error.errorMsg")
                    let compareCode: NSNumber = 0
                    if errorCode as! NSNumber == compareCode{
                       print("sucess")
                        
                    } else {
                         print("error")
                        
                    }
                }else{
                    print("error")
                    AlertView.showAlert(self, title: "currently busy server", message: "Not reachable" as AnyObject)
                    
                }
            case .failure(let error):
                print("Request failed with error: \(error)")
                AlertView.showAlert(self, title: "currently busy server", message: error as AnyObject)
            }
        }

        
        
        
        
        
    }
    
    
    func turnOnEditMode()  {
        
        self.navigationItem.leftBarButtonItem = nil
        self.navigationItem.setHidesBackButton(true, animated: true)
        self.navigationItem.rightBarButtonItems = nil
        self.title = "Edit and enrich"
        //self.navigationItem.rightBarButtonItem = nil
        //self.navigationController?.navigationBar.titleTextAttributes = NSForegroundColorAttributeName
        self.navigationItem.setRightBarButton(closeEdit, animated: true)
        self.setInitialToolbarConfiguration()
        self.longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(self.handleLongPress))
        self.collectionView.addGestureRecognizer(self.longPressGesture!)
        editTurnOn = true
        isViewStory = false
      self.collectionView.scrollToItem(at: IndexPath(item: scrollToPostionAfterUpload, section: 0), at: .centeredVertically, animated: true)
        headerView?.iboHeaderImage.addGestureRecognizer(singleTap)
        
       
        
        
        
        
    }
    
    func closeEditInStory()  {
        self.postDataForStoryMaking()
        //self.navigationController?.navigationBar.tintColor = UIColor.black
        self.setNavigationBarForViewMode()
        self.collectionView.removeGestureRecognizer(self.longPressGesture!)
        headerView?.iboHeaderImage.removeGestureRecognizer(singleTap)
        editTurnOn = false
        
    }
    
    @IBAction func doneClicked(_ sender: UIButton) {
        if headerCellTextFieldEditing{
            if let headerView = self.headerView{
                UIView.animate(withDuration: 0.2, animations: {
                    headerView.titleView.frame = CGRect(x: headerView.titleView.frame.origin.x, y: self.originalYOffset, width: headerView.titleView.frame.size.width, height: headerView.titleView.frame.size.height)
                })
            }
            
        }
        
        
        sender.resignFirstResponder()
        self.view.endEditing(true)
        
       }
    
    @IBAction func dismissViewClicked(_ sender: UIBarButtonItem) {
        
        self.navigationController?.dismiss(animated: true, completion: nil)
        
    }
    func startAnimation(){
        let size = CGSize(width: 30, height:30)
        
        startAnimating(size, message: "Loading...", type: NVActivityIndicatorType.ballScaleRipple)
    }
    func stopAnimationLoader() {
        stopAnimating()
    }
    
    func addTextCell() {
        editToolBar.isUserInteractionEnabled = true
        var visibleIndexPath = self.collectionView.indexPathsForVisibleItems
        print("addtextCell\(visibleIndexPath.count)")
        var previousIndexPath = IndexPath.init()
        
        if visibleIndexPath.count != 0{
            previousIndexPath = (visibleIndexPath[0])
        }else{
            previousIndexPath = IndexPath(item: 0, section: 0)
        }
        
        print("previu\(previousIndexPath.item)")
        var singletonArray = self.getSingletonArray()
        print("si\(singletonArray)")
        
        var originalPaths = singletonArray[previousIndexPath.item]
        var keys = originalPaths.components(separatedBy: "-")
        var destRow = Int(keys.first!)
        
        var text = "\(destRow!)-0-0"
        var txtCellObj = [String]()
        txtCellObj.append(text)
        var objArray = [txtCellObj]
        var checkObj = "\(destRow!)-0-0"
        var indexOfNewItem = singletonArray.index(of: checkObj)
        print("text path\(objArray)")
        self.localPartition.insert(objArray, at: destRow!)
        
        for i in (destRow! + 1) ..< self.localPartition.count{
            
            var destPartArray = self.localPartition[i]
            for j in 0 ..< destPartArray.count {
                var colArray = destPartArray[j]
                for k in 0 ..< colArray.count{
                    colArray[k] = "\(i)-\(j)-\(k)"
                }
                
                destPartArray[j] = colArray
            }
            self.localPartition[i] = destPartArray
        }
        defaults.set(localPartition, forKey: "partition")
        
        let txtSize = CGSize(width: SCREENWIDTH, height: 200)
        
        var textDict = [AnyHashable:Any]()
        textDict.updateValue("Text", forKey: "type")
        textDict.updateValue(NSStringFromCGSize(txtSize), forKey: "item_size")
        textDict.updateValue(NSStringFromCGSize(txtSize), forKey: "original_size")
        let generatedId = generateTextId()
        textDict.updateValue(generatedId, forKey: "id")
        textDict.updateValue(generatedId, forKey: "photo_id")
        textDict.updateValue(generatedId, forKey: "imagePath")
        textDict.updateValue("#FFFFFF", forKey: "backgroundColor")
        textDict.updateValue("#000000", forKey: "textColor")
        
        textDict.updateValue(1, forKey: "textAlignment")
        textDict.updateValue(false, forKey: "cover")
        textDict.updateValue("", forKey: "title")
        textDict.updateValue("", forKey: "description")
        
        self.collectionArray.insert(textDict, at: indexOfNewItem!)
        //self.collectionArray[indexOfNewItem!] = textDict
        
        editingTextFieldIndex = indexOfNewItem!
        selectedItemIndex = indexOfNewItem!
        
        
        
        
        self.collectionView.performBatchUpdates({
            self.collectionView.insertItems(at: [IndexPath(item: indexOfNewItem!, section: 0)])
            
            
        }, completion: { (flag) in
            
            self.collectionView.scrollToItem(at: IndexPath(item: indexOfNewItem!, section: 0), at: UICollectionViewScrollPosition.top, animated: true)
            
            self.editToolbarConfigurationForTextCells()
            //self.initialiseColorCodeArray
            guard let  TextCell = self.collectionView.cellForItem(at: IndexPath(item: indexOfNewItem!, section: 0)) as? TextCellStoryCollectionViewCell else{
                return
            }
            TextCell.titleLabel.placeholder = "Title"
            TextCell.subTitleLabel.placeholder = "Enter your story here"
            
           // TextCell.titleLabel.inputAccessoryView = self.keyboardView
            //TextCell.subTitleLabel.inputAccessoryView = self.keyboardView
            //TextCell.titleLabel.becomeFirstResponder()
            
            self.editToolBar.isUserInteractionEnabled = true
            
        })
        
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        

    }
    
    
    func setInitialToolbarConfiguration() {
        self.editToolBar.items = nil
        if (scrollViewForColors.isDescendant(of: self.editToolBar)){
            self.scrollViewForColors.removeFromSuperview()
        }
        
        self.editToolBar.items = [uploadMorePhotoButton,addTextButton]
        
        if !editToolBar.isDescendant(of: self.view){
            self.view.addSubview(self.editToolBar)
            
            
        UIView.animate(withDuration: 2, delay: 1, usingSpringWithDamping: 0, initialSpringVelocity: 0.1, options: .curveEaseOut, animations: {
            
            }, completion: nil)
            
        
        }
        
        
        
    }
    
    func editToolbarConfigurationForTextAlignment() {
        
        
    }
    
    func editToolbarForTextCellColor()  {
        
        self.editToolBar.items = nil
        
        self.editToolBar.items = [flexibleSpace,editToolbarItemDone]
        self.addScrollViewToToolbarWithItemsArray()
        
        
//        self.editToolbarItemDone = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"check"] style:UIBarButtonItemStylePlain target:self action:@selector(editToolbarConfigurationForTextCells)];
//        editToolbar.items = [NSArray arrayWithObjects:flexibleSpace,editToolbarItemDone, nil];
//        [self addScrollViewToToolbarWithItemsArray:colorCodeArray];

    }
    
    func addScrollViewToToolbarWithItemsArray() {
        
        var width = CGFloat(40 * self.colorCodeArray.count)
        
        scrollViewForColors.contentSize = CGSize(width: width, height: self.editToolBar.frame.size.height)
        
        var xCoordinate = 10
        for i in 0 ..< self.colorCodeArray.count{
            let hexCode =  self.colorCodeArray[i]
            let colorButtonText = UIButton.init(frame: CGRect(x: xCoordinate, y: 15, width: 30, height: 30))
            colorButtonText.layer.cornerRadius = 15
            colorButtonText.tag = i
            colorButtonText.backgroundColor = UIColor(hexString: hexCode)
            colorButtonText.addTarget(self, action: #selector(setBackgroundColorForTextCell), for: UIControlEvents.touchUpInside)
            xCoordinate += 40
            self.scrollViewForColors.addSubview(colorButtonText)
            
        }
        
        self.editToolBar.addSubview(scrollViewForColors)
        
        
    }
    
    func screenShotOfView(of inputView:UIView) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(inputView.bounds.size, false, 0)
        inputView.layer.render(in: UIGraphicsGetCurrentContext()!)
        var image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
    
    
    func changeToEnrichMode()  {
        self.editToolBar.items = nil
        
        if (scrollViewForColors.isDescendant(of: self.editToolBar)){
            self.scrollViewForColors.removeFromSuperview()
        }
        
        let dict = self.collectionArray[selectedItemIndex]
        
        if let type  =  dict["type"] as? String{
            if type == "video"{
                self.editToolBar.items = [flexibleSpace,deleteBarButton1]
               
                self.title = "Video"

                
            }else{
                
                self.editToolBar.items = [coverBarButton,flexibleSpace,shapeBarButton,deleteBarButton]
                self.title = "Image"

            }
            
        }
        
        self.editToolBar.tintColor  = UIColor(red: 21/255, green: 24/255, blue: 25/255, alpha: 1)
        
        
//        self.editToolBar.items = [editTextCellButton,fixedSpace,alignmentButton,fixedSpace,colorButton,fixedSpace,deleteBarButton]
//        if !editToolBar.isDescendant(of: self.view){
//            self.view.addSubview(self.editToolBar)
//        }
        
        
        

        
        
    }
    
    func editToolbarConfigurationForTextCells() {
        
        self.editToolBar.items = nil
        
        if (scrollViewForColors.isDescendant(of: self.editToolBar)){
            self.scrollViewForColors.removeFromSuperview()
        }
        
        
        self.editToolBar.items = [editTextCellButton,fixedSpace,alignmentButton,fixedSpace,colorButton,fixedSpace,deleteBarButton]
        
        

        if  let cell =  self.collectionView.cellForItem(at: IndexPath(item: selectedItemIndex, section: 0)) as? TextCellStoryCollectionViewCell{
        let screenshotOfTextCell = screenShotOfView(of: cell)
        if let TextCell = screenshotOfTextCell{
            
            var temp = self.collectionArray[selectedIndexPath]
            
            temp.updateValue(screenshotOfTextCell, forKey: "text_image")
            
        }
        }
    
    }
    
    func setBackgroundColorForTextCell()  {
        
              
        


        
    }
    

    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == self.collectionView{
            self.headerView?.layoutHeaderViewForScrollViewOffset(offset: scrollView.contentOffset)
        }
    }
    
    @IBAction func displayStory(_ sender: UIButton) {
        
        defaults.set(true, forKey: "viewStory")
        
        storyId = "44"
        getDetailStoryWithId(storyId: storyId) {
            //self.collectionView
            
            
          //  self.collectionView.collectionViewLayout.invalidateLayout()
            
            
            runOnMainThread {
               
                
                self.longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(self.handleLongPress))
                self.collectionView.addGestureRecognizer(self.longPressGesture!)
                self.swapView = UIView(frame: CGRect.zero)
                self.swapImageView = UIImageView(image: UIImage(named: "Swap-white"))
                
                self.view.addSubview(self.collectionView)
                self.isViewStory = true
                self.collectionView.reloadData()
                self.collectionView.collectionViewLayout.invalidateLayout()

                
                
               // let set :IndexSet = [0]
                // self.collectionView?.reloadSections(set)
                //self.collectionView?.reloadSections(IndexSet(set))
            }
            
            
        }
        
    }
    
    
    func getDetailStoryWithId(storyId:String,handler: ((Void) -> Void)?) {
        let postUrl = URLConstants.BaseURL + "storyDetails/" + storyId
        Alamofire.request(postUrl, method: .get, parameters: nil, encoding: URLEncoding.default, headers: nil).responseJSON { (response:DataResponse<Any>) in
            switch response.result {
            case .success(let JSON):
                print("Success with JSON: \(JSON)")
                let response = JSON as! NSDictionary
                let errorCode: AnyObject = response.value(forKeyPath: "error.errorCode") as! NSNumber
                let errorMSG  = response.value(forKeyPath: "error.errorMsg")
                print("postURL is :", (postUrl), "response is: \(response)", "error code is \(errorCode)")
                let compareCode: NSNumber = 0
                if errorCode as! NSNumber == compareCode{
                    
                    // if(self.allHomesArray.count == 0){
                    //print(self.allHomesArray.count)
                    let dataArray = response.value(forKey: "results") as! [String: AnyObject]
                    
                    if let Id =  dataArray["story_id"] as! Int?{
                        self.viewStoryId = Id
                    }
                    if let writen =  dataArray["writen_by"] as! String?{
                        self.writen_by = writen
                    }
                    if let story_cover =  dataArray["story_cover_photo_path"] as! String?{
                        self.story_cover_photo_path = story_cover
                    }
                    if let photo_code =  dataArray["story_cover_photo_code"] as! String?{
                        self.story_cover_photo_code = photo_code
                    }
                    if let photo_code =  dataArray["story_cover_photo_slice_code"] as! String?{
                        self.story_cover_photo_slice_code = photo_code
                    }
                    if let story_heading =  dataArray["story_heading"] as! String?{
                        self.storyTitle = story_heading
                    }
                    if let story_heading_description =  dataArray["story_heading_description"] as! String?{
                        self.storySubtitle = story_heading_description
                    }
                    
                    
                    if let story_json  =  dataArray["story_json"] as! String?{
                        
                        let json: AnyObject? = story_json.parseJSONString
                        print("Parsed JSON: \(json!)")
                        self.story_json =  json as! [[String:AnyObject]]
                        //story_json.parseJSONString
                        self.populateImage(objects: self.story_json)
                        
                        //                            story_json
                        //                            self.story_json =
                    }
                    
                    print(self.story_json)
                      self.getPhoto()
                    handler?()
                }else {
                    //  self.activityLoaderForFirstTime.stopAnimating()
                    //   AlertView.showAlert(self, title: "OOPS!", message: errorMSG! as AnyObject)
                }
            case .failure(let error):
                //  self.activityLoaderForFirstTime.stopAnimating()
                print("Request failed with error: \(error)")
                // Toast.show(error.localizedDescription)
                // AlertView.showAlert(self, title: "", message: error)
            }
        }
        
        
        
    }
    
    func registerForKeyboardNotifications()
    {
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.keyboardNotification(notification:)), name: NSNotification.Name.UIKeyboardDidShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.keyboardWillHide(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    func deRegisterForKeyboardNotifications()
    {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardDidShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }

    
    
    func keyboardNotification(notification: NSNotification) {
        
        if let userInfo = notification.userInfo {
            let endFrame = (userInfo[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue
            let duration:TimeInterval = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0
            let animationCurveRawNSN = userInfo[UIKeyboardAnimationCurveUserInfoKey] as? NSNumber
            let animationCurveRaw = animationCurveRawNSN?.uintValue ?? UIViewAnimationOptions.curveEaseInOut.rawValue
            let animationCurve:UIViewAnimationOptions = UIViewAnimationOptions(rawValue: animationCurveRaw)
            if let longPressGesture = self.longPressGesture{
            self.collectionView.removeGestureRecognizer(longPressGesture)
            }
            
            let offset  = SCREENHEIGHT - (endFrame?.height)! + 40
            if let hederView = self.headerView{
                if (hederView.iboTitle.isFirstResponder) || (hederView.iboSubTitle.isFirstResponder){
                    originalYOffset = (hederView.titleView.frame.origin.y)
                    let yOffsetHeader = offset - (hederView.titleView.frame.size.height)
                    //let movementDuration:TimeInterval = 0.3
                    //UIView.beginAnimations( "animateView", context: nil)
                    //UIView.setAnimationBeginsFromCurrentState(true)
                    //UIView.setAnimationDuration(movementDuration )
                    
                   // UIView.commitAnimations()
                    
                    UIView.animate(withDuration: 0.4,
                                   delay: TimeInterval(0),
                                   options: animationCurve,
                                   animations: {
                    hederView.titleView.frame = CGRect(x: hederView.titleView.frame.origin.x, y: yOffsetHeader, width: hederView.titleView.frame.size.width, height: hederView.titleView.frame.size.height)
                                    
                    },
                                   completion: nil)
                }
            }
           
//            if (endFrame?.origin.y)! >= UIScreen.main.bounds.size.height {
//               // self.keyboardHeightLayoutConstraint?.constant = 0.0
//            } else {
//               // self.keyboardHeightLayoutConstraint?.constant = endFrame?.size.height ?? 0.0
//            }
           
        }
        
    }
    
    func keyboardWillHide(notification: NSNotification) {
        
        
        
        
        if let longPressGesture = self.longPressGesture{
            self.collectionView.addGestureRecognizer(longPressGesture)
            //self.collectionView.removeGestureRecognizer(longPressGesture)
        }
        
        
        
        
        
        
    }
    
    func populateImage(objects:[[String:AnyObject]]) {
        var localpartitionGrid = [[[String]]]()
        var grid = [[[String]]]()
        var id = [String]()
        
        for (index, element) in objects.enumerated() {
            let items = element["items"] as! [[String:AnyObject]]
            var count = 0
            for (index, element) in items.enumerated() {
                id.append(element["id"] as! String)
                //count += 1
                
            }
            //grid.append(count)
        }
        
        var i = 0
        
        var partitionGrid = [[String]]()
        for (indexOut, element) in objects.enumerated() {
            var partition = [[String]]()
            if indexOut == 0{
                //let top = element["top"]
                
                //localPartition.append(contentsOf: )
            }
            let item = element["items"] as! [[String:AnyObject]]
            var belowCount = 0
            var leftCount = 0
            var belowObject = [String]()
            var search = [String: Int]()
            for (index, element) in item.enumerated() {
                
                var singleObj = [String]()
                var singleGrid = [String]()
                var dictToAdd = [AnyHashable:Any]()
                if let type = element["type"] as? String{
                    
                    if type == "txt"{
                  
                        let id = element["id"] as? String ?? ""
                        let imagePath = element["imagePath"] as? String ?? ""
                      //  let type = element["type"] as? String ?? "Text"
                        let textTitle = element["textTitle"] as? String ?? ""
                        let textSubTitle = element["textSubTitle"] as? String ?? ""
                       // let dw = element["dw"] as! String
                      //  let dh = element["dh"] as! String
                        let height = element["height"] as? Int ?? 0
                        let width = element["width"] as? Int ?? 0
                        
                        let txtSize = CGSize(width: SCREENWIDTH, height: CGFloat(height))
                        
                       
                        dictToAdd.updateValue(NSStringFromCGSize(txtSize), forKey: "original_size")
                        
                       // let original_size = CGSize(width: CGFloat((dw as NSString).floatValue), height: CGFloat((dh as NSString).floatValue))
                        let item_size = CGSize(width: SCREENWIDTH, height: CGFloat(200))
                        dictToAdd.updateValue(id, forKey: "photo_id")
                        dictToAdd.updateValue(imagePath, forKey: "item_url")
                        dictToAdd.updateValue("Text", forKey: "type")
                        
                        dictToAdd.updateValue("#322e20", forKey: "hexCode")
                        //dictToAdd.updateValue(item_size, forKey: "original_size")
                        dictToAdd.updateValue(NSStringFromCGSize(item_size), forKey: "item_size")
                        dictToAdd.updateValue(textTitle, forKey: "title")
                        dictToAdd.updateValue(textSubTitle, forKey: "description")
                       // dictToAdd.updateValue("xelpmoc story making processs", forKey: "textColor")
                        
                        dictToAdd.updateValue("#322e20", forKey: "textColor")
                        
                        dictToAdd.updateValue("#FFFFFF", forKey: "backgroundColor")
                        singleObj.append("\(i)-\(leftCount)-\(0)")
                        singleGrid.append(id)
                        leftCount += 1
                        partitionGrid.append(singleGrid)
                        partition.append(singleObj)

                          //  dictToAdd.updateValue(color, forKey: "hexCode")
                        
                    }else{
                        
                        let below = element["below"] as! String
                        if (below == ""){
                            search.updateValue(index, forKey: element["id"] as! String)
                            let left = element["left"] as! Int
                            if left == Int(0){
                                singleObj.append("\(i)-\(leftCount)-\(0)")
                                singleGrid.append(element["id"] as! String)
                                leftCount += 1
                            }else{
                                singleObj.append("\(i)-\(leftCount)-\(0)")
                                singleGrid.append(element["id"] as! String)
                                leftCount += 1
                            }
                            
                            
                            partitionGrid.append(singleGrid)
                            partition.append(singleObj)
                            
                        }else{
                            var index = ""
                            // var indexToNest = id.index(of: below)
                            
                            var countLength = partition.count
                            
                            //  var indexToInsert = search[below]
                            belowCount += 1
                            var tempMiddle = leftCount - 1
                            partition[countLength-1].append("\(i)-\(tempMiddle)-\(belowCount)")
                            
                        }
                        
                        
                        let id = element["id"] as? String ?? ""
                        let imagePath = element["imagePath"] as? String ?? ""
                        let type = element["type"] as? String ?? ""
                        var dw = element["dw"] as? String ?? ""
                        if dw == "undefined"{
                            dw = "0"
                        }
                        var dh = element["dh"] as? String ?? ""
                        if dh == "undefined"{
                            dh = "0"
                        }
                        
                        if let factor = element["factor"] as? AnyObject{
                            dictToAdd.updateValue("\(factor)", forKey: "factor")
                        }
                        if type != "video"{
                             let color = element["color"] as?  String ?? ""
                            dictToAdd.updateValue(color, forKey: "hexCode")
                        }
                       
                        let height = element["height"] as? Int ?? 0
                        let width = element["width"] as? Int ?? 0
                        
                        let original_size = CGSize(width: CGFloat((dw as NSString).floatValue), height: CGFloat((dh as NSString).floatValue))
                        let item_size = CGSize(width: CGFloat(width), height: CGFloat(height))
                        dictToAdd.updateValue(id, forKey: "photo_id")
                        dictToAdd.updateValue(imagePath, forKey: "item_url")
                        dictToAdd.updateValue(type, forKey: "type")
                        dictToAdd.updateValue(original_size, forKey: "original_size")
                        dictToAdd.updateValue(item_size, forKey: "item_size")
                        
                        
                        // dictToAdd.updateValue(type, forKey: "type")
                      
                        
                        
                    }
                }
                
                
                
                
               
                
                self.collectionArray.append(dictToAdd)
            }
            localpartitionGrid.append(partitionGrid)
            localPartition.append(partition)
            i += 1
            //partition.append(singleObj)
        }
        
        defaults.set(true, forKey: "isViewStory")
        defaults.set(localPartition, forKey: "partition")
    
    }
    
    
    
    func startDragAtLocation(location:CGPoint) {
        
         let vc = self.collectionView
        guard let indexPath = vc.indexPathForItem(at: location) else {return}
        guard let cell = vc.cellForItem(at: indexPath) else {return}
        
         if(selectedItemIndex != indexPath.item){
            var previousSelected = selectedItemIndex
         selectedItemIndex = indexPath.item
            if previousSelected != -1{
                
                self.collectionView.reloadItems(at: [IndexPath(item: previousSelected, section: 0)])
                
            }
            
        }
        
        self.collectionView.performBatchUpdates({
            self.collectionView.reloadData()
        }) { (test) in
            
        }
        self.editToolBar.isUserInteractionEnabled = false
      //  isSourceCellTypeText = 0
        
        
        frameOfDragingIndexPath = cell.center
        originalIndexPath = indexPath
        draggingIndexPath = indexPath
        draggingView = cell.snapshotView(afterScreenUpdates: true)
        guard let view = draggingView else { return }
        
        
        
        view.frame = cell.frame
        var center = cell.center
        view.center = center
        vc.addSubview(view)
        
        view.layer.shadowPath = UIBezierPath(rect: (draggingView?.bounds)!).cgPath
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.8
        view.layer.shadowRadius = 10
        view.alpha = 0.3
        
        // self.collectionView?.collectionViewLayout.invalidateLayout()
        //invalidateLayout()
        cell.alpha = 0.0
        cell.isHidden = true
        UIView.animate(withDuration: 2, delay: 1, usingSpringWithDamping: 0.4, initialSpringVelocity: 0.2, options: [], animations: {
            
            center.y = location.y
            view.center = cell.center
            
            if (cell.frame.size.height > SCREENHEIGHT * 0.75  || cell.frame.size.width > SCREENWIDTH * 0.8){
                
                view.transform = CGAffineTransform(scaleX: 0.3, y: 0.3)
                
            }else{
                view.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
            }
            
        }, completion: nil)
        
    }
    
    
    func handleLongPress(gestureReconizer: UILongPressGestureRecognizer) {
        let location  = gestureReconizer.location(in: self.collectionView)
        
        switch gestureReconizer.state {
            
        case .began:
            
            if let local  = defaults.object(forKey: "partition") as? partitionType{
                localPartition = local
            }
            
            
            
            startDragAtLocation(location: location)
            break
            
        case .changed:
            guard let view = draggingView else { return }
            let cv = collectionView
            guard let originalIndexPath = originalIndexPath else {return}
            
            //   view.center = CGPoint(x: location.x + dragOffset.x, y: location.y + dragOffset.y)
            
            var center = view.center
            center.x = location.x
            
            center.y = location.y
            view.center = center
            stopped = false
            scrollIfNeed(snapshotView: view)
            self.checkPreviousIndexPathAndCalculate(location: center, forScreenShort: view.frame, withSourceIndexPath: originalIndexPath)
            break
        case .ended:
            self.changeToIdentiPosition()
            
             editingTextFieldIndex = -1
            self.editToolBar.isUserInteractionEnabled = true
            stopped = true
            endDragAtLocation(location: location)
        default:
            guard let view = draggingView else { return }
            var center = view.center
            center.y = location.y
            center.x = location.x
            view.center = center
            //   break
        }
        
        
    }
    
    
    func autoScroll()
    {
        if self.collectionArray.count > 1{
            self.collectionView.scrollToItem(at: IndexPath(item: 0, section: 0), at: .centeredVertically, animated: true)
        }
    }
    func autoScrollToTop()
    {
        
        if let headerAttributes =  self.collectionView.collectionViewLayout.layoutAttributesForItem(at: IndexPath(item: 0, section: 0)){
        self.collectionView.setContentOffset(CGPoint(x: 0, y: (headerAttributes.frame.origin.x)), animated: true)
        }
        
        
        
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionElementKindSectionHeader {
            if reloadHeaderView == true{
            headerView =  collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "HeaderView", for: indexPath) as! PictureHeaderCollectionReusableView
                headerView?.delegate = self
                self.headerView?.iboTitle.delegate = self
                self.headerView?.iboSubTitle.delegate = self
                
                
            if self.isViewStory{
                 headerView?.iboHeaderImage.removeGestureRecognizer(singleTap)
                self.headerView?.iboHeaderImage.backgroundColor = UIColor(hexString: self.story_cover_photo_slice_code)
                var urlImage = self.story_cover_photo_path.components(separatedBy: "album")
                
                self.headerView?.iboTitle.text = self.storyTitle
                self.headerView?.iboSubTitle.text = self.storySubtitle
                
                var totalPath = URLConstants.imgDomain
                
                if  let data = coverdata
                {
                    //self.headerView?.iboHeaderImage.contentMode = UIViewContentMode.scaleAspectFill
                    DispatchQueue.main.async {
                    self.headerView?.iboHeaderImage.image = data
                    }
                   
                }else {
                    self.headerView?.iboHeaderImage.sd_setImage(with: URL(string: totalPath + urlImage[1]), placeholderImage: UIImage(named: ""), options: SDWebImageOptions.progressiveDownload, completed: { (image, data, error, finished) in
                        
                        
                        guard let image = image else { return  }
                        print("Image loaded!")
                        self.headerView?.iboHeaderImage.contentMode = UIViewContentMode.scaleAspectFill
                        self.headerView?.iboHeaderImage.image = image
                        self.coverdata =  image
                        //    self.iboProfileLoaderIndicator.stopAnimating()
                        
                        
                    })
                }
               
                
                
                //self.headerView?.iboHeaderImage.sd_setImage(with: URL(string: totalPath + urlImage[1]), placeholderImage: UIImage(named: ""))
            }else{
                
                headerView?.iboHeaderImage.addGestureRecognizer(singleTap)
                
                
                if let coverData = coverdata{
                self.headerView?.iboHeaderImage.image = coverData
                }
                
            }
                //self.headerView?.iboTitle.inputAccessoryView = keyboardView
                //self.headerView?.iboSubTitle.inputAccessoryView = keyboardView
            }
            return headerView!
        } else if kind == UICollectionElementKindSectionFooter {
            //    assert(0)
            let fotterView =  collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionFooter, withReuseIdentifier: "FotterView", for: indexPath) as! FooterReusableView
            fotterView.iboOwnerImg.setImage(string: "Chitaranjan sahu", color: UIColor(hexString:"#7FC9F1"), circular: true)
            fotterView.delegate = self
            fotterView.backgroundColor = UIColor.white
            return fotterView
        }else{
            return UICollectionReusableView()
        }
    }
    
    func sameRowOrNot(sourceIndexPath: Int,destinationIndexPath :Int ) -> Bool {
        var singletonArray = self.getSingletonArray()
        let destPaths = singletonArray[sourceIndexPath]
        let sourcePaths = singletonArray[destinationIndexPath]
        var destKeys = destPaths.components(separatedBy: "-")
        var sourceKeys = destPaths.components(separatedBy: "-")
        if destKeys[0] == sourceKeys[0]{
            return true
        }else{
            return false
            
        }
        
    }
    
    func checkPreviousIndexPathAndCalculate(location:CGPoint,forScreenShort snapshot:CGRect,withSourceIndexPath sourceIndexPath:IndexPath){
        
        
        self.changeToIdentiPosition()
        lineView.removeFromSuperview()
        self.swapView?.removeFromSuperview()
           var singletonArray = self.getSingletonArray()
        if let indexPath = self.collectionView.indexPathForItem(at: location){
            
            let sourceCell = self.collectionView.cellForItem(at: sourceIndexPath)
            if let destinationCell = self.collectionView.cellForItem(at: indexPath)
            {
                
                var destinationCellType = self.collectionArray[indexPath.item]
                var sourceCellType = self.collectionArray[sourceIndexPath.item]
                
                
                //   print("\(indexPath.item)source but destination\(sourceIndexPath.item)")
                if indexPath.item != sourceIndexPath.item{
                    
                    let topOffset = destinationCell.frame.origin.y + 25
                    let leftOffset = destinationCell.frame.origin.x + 25
                    let bottomOffset = destinationCell.frame.origin.y + destinationCell.frame.size.height - 25
                    let rightOffset = destinationCell.frame.origin.x + destinationCell.frame.size.width - 25
                    let differenceLeft = location.x - leftOffset
                    
                    let differenceRight = location.x - rightOffset
                    // print("destination\(destinationCell.frame)")
                    let differenceTop = location.y - topOffset
                    let differenceBottom = location.y - bottomOffset
                    
                  
                    
                    var frmaes = defaults.object(forKey: "FramesForEachRow") as! [String]
                    if let destType  =  destinationCellType["type"] as? String {
                        if destType != "Text"{
                    guard let sourceType  =  sourceCellType["type"] as? String else { return }
                             var keys = singletonArray[indexPath.item].components(separatedBy: "-")
                    if differenceLeft > -25 && differenceLeft < 0  &&  sourceType != "Text"{
                        
                        var cellFrame = CGRectFromString(frmaes[Int(keys[0])!])
                        print("Insert to the left of cell line")
                        lineView.removeFromSuperview()
                        self.swapView?.removeFromSuperview()
                        print("differenceLeft\(differenceLeft)")
                        let xOffset = destinationCell.frame.origin.x - 2
                        // print("\(xOffset)in left of the cell line ")
                        let yValue = cellFrame.origin.y
                        //print("\(yValue)in left of the cell line ")
                        let nestedWidth = 2.0
                        let nestedHeight = cellFrame.size.height
                        self.collectionView.performBatchUpdates({
                            print("height destinationleft  \(nestedHeight)")
                            self.lineView.frame = CGRect(x: xOffset, y: yValue, width: CGFloat(nestedWidth), height: nestedHeight)
                            self.lineView.backgroundColor = UIColor.black
                            self.collectionView.addSubview(self.lineView)
                        }, completion: { (test) in
                            self.moveCellsApartWithFrame(frame: (self.lineView.frame), andOrientation: 0)
                            
                        })
                        // }
                    }else if differenceRight < 25 && differenceRight > 0 && sourceType != "Text"{
                        
                        var cellFrame = CGRectFromString(frmaes[Int(keys[0])!])
                        
                        print("Insert to the right of the cell line")
                        print("differenceright\(differenceRight)")
                        lineView.removeFromSuperview()
                        self.swapView?.removeFromSuperview()
                        
                        let  xOffset = destinationCell.frame.origin.x + destinationCell.frame.size.width
                        let  yValue = cellFrame.origin.y
                        let nestedWidth = 2.0
                        let nestedHeight = cellFrame.size.height
                        //floor(xOffset)
                        //floor(yValue)
                        //print("\(floor(xOffset))in right of the cell line ")
                        //print("\(floor(yValue))in right of the cell line ")
                        self.collectionView.performBatchUpdates({
                            print("height destinationright  \(nestedHeight)")
                            self.lineView.frame = CGRect(x: xOffset, y: yValue, width: CGFloat(nestedWidth), height: nestedHeight)
                            self.lineView.backgroundColor = UIColor.black
                            self.collectionView.addSubview(self.lineView)
                        }, completion: { (test) in
                            self.moveCellsApartWithFrame(frame: (self.lineView.frame), andOrientation: 0)
                            
                        })
                        
                    }else if (differenceTop > -20 && differenceTop < 0 && destinationCell.frame.size.width < (UIScreen.main.bounds.width - 16) && sourceType != "Text"){
                        print("Insert to the TOP of the cell line")
                        lineView.removeFromSuperview()
                        self.swapView?.removeFromSuperview()
                        
                        let  xOffset = destinationCell.frame.origin.x
                        let  yValue = destinationCell.frame.origin.y
                        let nestedWidth = destinationCell.frame.size.width
                        let nestedHeight = 2.0
                        //floor(xOffset)
                        //floor(yValue)
                        // print("\(floor(xOffset))in right of the cell line ")
                        //print("\(floor(yValue))in right of the cell line ")
                        self.collectionView.performBatchUpdates({
                            self.lineView.frame = CGRect(x: xOffset, y: yValue, width: CGFloat(nestedWidth), height: CGFloat(nestedHeight))
                            self.lineView.backgroundColor = UIColor.black
                            self.collectionView.addSubview(self.lineView)
                        }, completion: { (test) in
                            self.moveCellsApartWithFrame(frame: (self.lineView.frame), andOrientation: 1)
                            
                        })
                        
                        
                    }else if(differenceBottom > 0 && differenceBottom < 20 && destinationCell.frame.size.width < (UIScreen.main.bounds.width - 16) && sourceType != "Text"){
                        print("Insert to the Bottom of the cell line")
                        lineView.removeFromSuperview()
                        self.swapView?.removeFromSuperview()
                        
                        let  xOffset = destinationCell.frame.origin.x
                        let  yValue = destinationCell.frame.origin.y + destinationCell.frame.size.height + 2
                        let nestedWidth = destinationCell.frame.size.width
                        let nestedHeight = 2.0
                        //floor(xOffset)
                        //floor(yValue)
                        //   print("\(floor(xOffset))in right of the cell line ")
                        //  print("\(floor(yValue))in right of the cell line ")
                        self.collectionView.performBatchUpdates({
                            self.lineView.frame = CGRect(x: xOffset, y: yValue, width: CGFloat(nestedWidth), height: CGFloat(nestedHeight))
                            self.lineView.backgroundColor = UIColor.black
                            self.collectionView.addSubview(self.lineView)
                        }, completion: { (test) in
                            self.moveCellsApartWithFrame(frame: (self.lineView.frame), andOrientation: 1)
                            
                        })
                    }else{
                        
                        
                        let dict = self.collectionArray[(originalIndexPath?.item)!]
                        if let type  =  dict["type"] as? String{
                            if type != "Text"{
                                
                                self.lineView.removeFromSuperview()
                                self.swapView?.removeFromSuperview()
                                self.collectionView.performBatchUpdates({
                                    self.swapView?.frame = destinationCell.contentView.bounds
                                    self.swapView?.backgroundColor = UIColor.black
                                    self.swapView?.alpha = 0.6
                                    self.swapImageView?.center = CGPoint(x: (self.swapView?.frame.size.width)! / 2, y: (self.swapView?.frame.size.height)! / 2)
                                    self.swapView?.addSubview(self.swapImageView!)
                                    destinationCell.contentView.addSubview(self.swapView!)
                                    
                                }, completion: { (boolTest) in
                                    
                                })
                                
                            }else{
                                
                                if (sourceCell?.frame.size.width == destinationCell.frame.size.width){
                                    
                                    self.lineView.removeFromSuperview()
                                    
                                    
                                    self.swapView?.removeFromSuperview()
                                    self.collectionView.performBatchUpdates({
                                        self.swapView?.frame = destinationCell.contentView.bounds
                                        self.swapView?.backgroundColor = UIColor.black
                                        self.swapView?.alpha = 0.6
                                        self.swapImageView?.center = CGPoint(x: (self.swapView?.frame.size.width)! / 2, y: (self.swapView?.frame.size.height)! / 2)
                                        self.swapView?.addSubview(self.swapImageView!)
                                        destinationCell.contentView.addSubview(self.swapView!)
                                        
                                    }, completion: { (boolTest) in
                                        
                                    })
                                }else{
                                    
                                    self.lineView.removeFromSuperview()
                                }
                                
                            }
                            
                            
                            
                        }
                        
                    }
                        }else{
                            
                            if (sourceCell?.frame.size.width == destinationCell.frame.size.width){
                                
                                self.lineView.removeFromSuperview()
                                
                                
                                self.swapView?.removeFromSuperview()
                                self.collectionView.performBatchUpdates({
                                    self.swapView?.frame = destinationCell.contentView.bounds
                                    self.swapView?.backgroundColor = UIColor.black
                                    self.swapView?.alpha = 0.6
                                    self.swapImageView?.center = CGPoint(x: (self.swapView?.frame.size.width)! / 2, y: (self.swapView?.frame.size.height)! / 2)
                                    self.swapView?.addSubview(self.swapImageView!)
                                    destinationCell.contentView.addSubview(self.swapView!)
                                    
                                }, completion: { (boolTest) in
                                    
                                })
                            }else{
                                
                                self.lineView.removeFromSuperview()
                            }
                            

                            
                    }
                }
                }
                else{
                    self.lineView.removeFromSuperview()
                    print("outofsource")
                    print("removed")
                    //  moveCellsApartWithFrame(frame: (self.lineView.frame), andOrientation: 1)
                    
                }
                
                
            }
           
            
        }else{
            
            let pIndexPath = self.collectionView.indexPathForItem(at: CGPoint(x: location.x - 6, y: location.y))
            let nIndexPath = self.collectionView.indexPathForItem(at: CGPoint(x: location.x + 6, y: location.y))
            let uIndexPath = self.collectionView.indexPathForItem(at: CGPoint(x: location.x, y: location.y - 6))
            let lIndexPath = self.collectionView.indexPathForItem(at: CGPoint(x: location.x, y: location.y + 6))
            
         
            
            var frmaes = defaults.object(forKey: "FramesForEachRow") as! [String]
            var sourceCellType = self.collectionArray[sourceIndexPath.item]
            guard let sourceType  =  sourceCellType["type"] as? String else { return }
            
            
            if var pIndexPath = pIndexPath,var nIndexPath = nIndexPath, sourceType != "Text"{
                print("Insert in between two cells in the same row taken as horizontally line")
                
                var keys = singletonArray[pIndexPath.item].components(separatedBy: "-")
                if let  pCell = self.collectionView.cellForItem(at:pIndexPath){
                    var cellFrame = CGRectFromString(frmaes[Int(keys[0])!])
                    self.lineView.removeFromSuperview()
                    let xOffset = pCell.frame.origin.x + pCell.frame.size.width
                    let yValue = cellFrame.origin.y
                    let nestedHeight = cellFrame.size.height
                    let nestedWidth = CGFloat(2.0)
                    self.collectionView.performBatchUpdates({
                        self.lineView.frame = CGRect(x: xOffset, y: yValue, width: nestedWidth, height: nestedHeight)
                        self.lineView.backgroundColor = UIColor.black
                        self.collectionView.addSubview(self.lineView)
                        self.moveCellsApartWithFrame(frame: (self.lineView.frame), andOrientation: 0)
                    }, completion: { (bool) in
                    })
                    
                    
                    
                }
                
                
                
            }else if var uIndexPath = uIndexPath,var lIndexPath = lIndexPath{
                print("Insert in between two cells in the same row taken as vertically line")
                if let  uCell = self.collectionView.cellForItem(at:uIndexPath){
                    var uKey = singletonArray[uIndexPath.item].components(separatedBy: "-")
                    var lKey = singletonArray[lIndexPath.item].components(separatedBy: "-")
                    var cellFrame = CGRectFromString(frmaes[Int(uKey[0])!])
                    
                    
                    if Int(uKey[0]) == Int(lKey[0])
                    {
                        if sourceType != "Text"{
                        let xOffset = uCell.frame.origin.x
                        let yValue = uCell.frame.origin.y + uCell.frame.size.height + 2
                        let nestedWidth = uCell.frame.size.width
                        let nestedHeight = CGFloat(2.0)
                        self.collectionView.performBatchUpdates({
                            self.lineView.frame = CGRect(x: xOffset, y: yValue, width: nestedWidth, height: nestedHeight)
                            self.lineView.backgroundColor = UIColor.black
                            self.collectionView.addSubview(self.lineView)
                            self.moveCellsApartWithFrame(frame: (self.lineView.frame), andOrientation: 1)
                        }, completion: { (bool) in
                            
                        })
                        }else{
                            self.lineView.removeFromSuperview()
                        }
                    
                    }else{
                        print("Different row")
                        let xOffset = cellFrame.origin.x
                        let yValue = uCell.frame.origin.y + uCell.frame.size.height + 3
                        let nestedWidth = cellFrame.size.width
                        let nestedHeight = CGFloat(2.0)
                        self.collectionView.performBatchUpdates({
                            self.lineView.frame = CGRect(x: xOffset, y: yValue, width: nestedWidth, height: nestedHeight)
                            self.lineView.backgroundColor = UIColor.black
                            self.collectionView.addSubview(self.lineView)
                            self.moveCellsApartWithFrame(frame: (self.lineView.frame), andOrientation: 1)
                        }, completion: { (bool) in
                            
                        })
                        
                        
                    }
                    
                }
                
            }else  if var uIndexPath = uIndexPath , lIndexPath == nil{
                var uKey = singletonArray[uIndexPath.item].components(separatedBy: "-")
                if ((Int(uKey[0])!) == localPartition.count - 1)
                {
                    print("insert at the bottom of collection view line")
                    let cellFrame = CGRectFromString(frmaes[Int(uKey[0])!])
                    let xOffset = cellFrame.origin.x
                    let yValue = cellFrame.origin.y + cellFrame.size.height + 3
                    let nestedWidth = cellFrame.size.width
                    let nestedHeight = CGFloat(2.0)
                    
                    self.collectionView.performBatchUpdates({
                        self.lineView.frame = CGRect(x: xOffset, y: yValue, width: nestedWidth, height: nestedHeight)
                        self.lineView.backgroundColor = UIColor.black
                        self.collectionView.addSubview(self.lineView)
                        self.moveCellsApartWithFrame(frame: (self.lineView.frame), andOrientation: 1)
                        
                    }, completion: { (bool) in
                        
                    })
                }else{
                    self.lineView.removeFromSuperview()
                }
                
            }else if var lIndexPath = lIndexPath ,  uIndexPath == nil{
                var lKey = singletonArray[lIndexPath.item].components(separatedBy: "-")
                
                if ((Int(lKey[0])!) == 0)
                {
                    print("Insert at the top of collection view line")
                    let cellFrame = CGRectFromString(frmaes[Int(lKey[0])!])
                    
                    let xOffset = cellFrame.origin.x
                    let yValue = cellFrame.origin.y
                    let nestedWidth = cellFrame.size.width
                    let nestedHeight = CGFloat(2.0)
                    
                    self.collectionView.performBatchUpdates({
                        self.lineView.frame = CGRect(x: xOffset, y: yValue, width: nestedWidth, height: nestedHeight)
                        self.lineView.backgroundColor = UIColor.black
                        self.collectionView.addSubview(self.lineView)
                        self.moveCellsApartWithFrame(frame: (self.lineView.frame), andOrientation: 1)
                        
                    }, completion: { (bool) in
                        
                    })
                    
                    
                    
                }else{
                    self.lineView.removeFromSuperview()
                }
                
            }else{
                
//                if let  sourceCell = self.collectionView.cellForItem(at:sourceIndexPath){
//                    sourceCell.alpha = 1
//                }
                
                
                print("move snapshot to its original position line")
                self.lineView.removeFromSuperview()
            }
            
            
            
            
            
            
        }
        
        
        
    }
    
    
    
    
    
    
    func moveCellsApartWithFrame(frame:CGRect,andOrientation orientation:Int) {
        var certOne  = CGRect.zero
        var certTwo = CGRect.zero
        cellsToMove0.removeAllObjects()
        cellsToMove1.removeAllObjects()
        if orientation == 0 {
            certOne = CGRect(x: frame.origin.x, y: frame.origin.y, width: CGFloat.greatestFiniteMagnitude, height: frame.size.height)
            certTwo = CGRect(x: 0.0, y: frame.origin.y, width: frame.origin.x, height: frame.size.height)
            print("\(certOne)first One")
            print("\(certTwo)secondOne")
        }else{
            certOne = CGRect(x: frame.origin.x, y: frame.origin.y, width: CGFloat.greatestFiniteMagnitude, height: frame.size.height)
            certTwo = CGRect(x: frame.origin.x, y: 0.0, width: frame.size.width, height: frame.origin.y)
        }
        
        for i in 0 ..< self.collectionArray.count{
            
            let indexPath = IndexPath(item: i, section: 0)
            if let cell = self.collectionView.cellForItem(at: indexPath){
                
                if (cell.frame.intersects(certOne)){
                    cellsToMove0.add(cell)
                }else if (cell.frame.intersects(certTwo))
                {
                    cellsToMove1.add(cell)
                }
            }
            
        }
        
        
        self.collectionView.performBatchUpdates({
            for i in  0 ..< self.cellsToMove0.count{
                if orientation == 0{
                    UIView.animate(withDuration: 0.2, animations: {
                        let cell = self.cellsToMove0[i] as! UICollectionViewCell
                        cell.transform = CGAffineTransform(translationX: 5.0, y: 0.0)
                    })
                }else{
                    UIView.animate(withDuration: 0.2, animations: {
                        let cell = self.cellsToMove0[i] as! UICollectionViewCell
                        cell.transform = CGAffineTransform(translationX: 0.0, y: 5.0)
                    })
                }
                
            }
            
            for i in  0 ..< self.cellsToMove1.count{
                if orientation == 0{
                    UIView.animate(withDuration: 0.2, animations: {
                        let cell = self.cellsToMove1[i] as! UICollectionViewCell
                        cell.transform = CGAffineTransform(translationX: -5.0, y: 0.0)
                    })
                }else{
                    UIView.animate(withDuration: 0.2, animations: {
                        let cell = self.cellsToMove1[i] as! UICollectionViewCell
                        cell.transform = CGAffineTransform(translationX: 0.0, y: -5.0)
                    })
                    
                }
            }
        }, completion: { (Bool) in
            
        })
    }
    
    func changeToIdentiPosition()  {
        
        self.collectionView.performBatchUpdates({
            for i in  0 ..< self.cellsToMove0.count{
                
                UIView.animate(withDuration: 0.2, animations: {
                    let cell = self.cellsToMove0[i] as! UICollectionViewCell
                    cell.transform = CGAffineTransform.identity
                })
            }
            
            for i in  0 ..< self.cellsToMove1.count{
                
                UIView.animate(withDuration: 0.2, animations: {
                    let cell = self.cellsToMove1[i] as! UICollectionViewCell
                    cell.transform = CGAffineTransform.identity
                })
                
            }
            
            
        }, completion: { (test) in
            
        })
              
    }
    
    
    
     func cancelClicked() {
        self.defaults.removeObject(forKey: "isViewStory")
        if upload{
            self.navigationController?.dismiss(animated: true, completion: nil)
            self.upload = false
        }else{
      _ = self.navigationController?.popViewController(animated: true)
        }
      
    }
    
    func scrollIfNeed(snapshotView:UIView)  {
        var cellCenter = snapshotView.center
        
            var newOffset = collectionView.contentOffset
            let buffer  = CGFloat(10)
            let bottomY = collectionView.contentOffset.y + collectionView.frame.size.height - 100
       // print("bottomY\(bottomY)")
        //print("(snapshotView.frame.maxY - buffer)\((snapshotView.frame.maxY - buffer))")
        
        //print("condition \(bottomY  < (snapshotView.frame.maxY - buffer))")
            if (bottomY  < (snapshotView.frame.maxY - buffer)){
                
                newOffset.y = newOffset.y + 1
                
          //      print("uppppp")
                
                if (((newOffset.y) + (collectionView.bounds.size.height)) > (collectionView.contentSize.height)) {
                    return
                }
                cellCenter.y = cellCenter.y + 1
            }
            
            
            let offsetY = collectionView.contentOffset.y
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
            
            
            collectionView.contentOffset = newOffset
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
    
    
    func insertNewCellAtPoint(location:CGPoint ,withSourceIndexPathwithSourceIndexPath  sourceIndexPath : IndexPath ,forSnapshot snapshot:CGRect){
        
        if let  destinationIndexPath = self.collectionView.indexPathForItem(at: location){
            if let destinationCell  = self.collectionView.cellForItem(at: destinationIndexPath){
                let temp = collectionArray[destinationIndexPath.row]
                let type  =  temp["type"] as! String
                
                if destinationIndexPath.item != sourceIndexPath.item{
                    
                    if (type != "Text")
                    {
                    
                    let topOffset = destinationCell.frame.origin.y + 20
                    let leftOffset = destinationCell.frame.origin.x + 20
                    let bottomOffset = destinationCell.frame.origin.y + destinationCell.frame.size.height - 20
                    let rightOffset = destinationCell.frame.origin.x + destinationCell.frame.size.width - 20
                    let differenceLeft = location.x - leftOffset
                    
                    let differenceRight = location.x - rightOffset
                    let differenceTop = location.y - topOffset
                    let differenceBottom = location.y - bottomOffset
                    
                    var singletonArray = self.getSingletonArray()
                    var sourseKey = singletonArray[sourceIndexPath.item]
                    var sourseKeys = sourseKey.components(separatedBy: "-")
                    
                    //  if   let sourseKeys = findWithIndex(array: singletonArray, index: sourceIndexPath.item){
                    
                    if(differenceLeft > -20 && differenceLeft < 0 && type != "Text"){
                        
                        print("Inserting to the left of cell")
                        let destPaths = singletonArray[destinationIndexPath.item]
                        // let destPaths = findWithIndex(array: singletonArray, index: destinationIndexPath.item)
                        var destKeys = destPaths.components(separatedBy: "-")
                        let rowNumber  = self.localPartition[Int(destKeys[0])!]
                        //let rowNumber :NSArray = self.localPartition.object(at: Int(destKeys[0])!) as! NSArray
                        // let rowNumber : NSMutableArray = self.localPartition.object(at: destKeys[0])
                        let rowTemp = rowNumber
                        
                        
                        let nextItem  = rowTemp[Int(destKeys[1])!]
                        let searchString = nextItem.first
                        
                        
                        
                        
                        var destIndex = singletonArray.index(of: searchString!)
                        
                        
                        if sourceIndexPath.item < destinationIndexPath.item && destIndex != 0{
                            destIndex = destIndex! - 1
                        }
                        var insertRow = self.localPartition[Int((destKeys[0]))!]
                        var insertRowArray = insertRow
                        let columnNumber = Int((destKeys[1]))!
                        guard let newIndex = Int(destKeys.first!) else {
                            return
                        }
                        print("New index \(newIndex)")
                        
                        let ArrayWithObj = "\(newIndex)-\(columnNumber)-\(0)"
                        var arrayObj = [ArrayWithObj]
                        //var arrayObj = NSArray(array: [ArrayWithObj])
                        // arrayObj.adding(ArrayWithObj)
                        // arrayObj.append(ArrayWithObj)
                        insertRowArray.insert(arrayObj, at: columnNumber)
                        print("start\(insertRowArray)")
                        
                        for i in columnNumber ..< insertRowArray.count{
                            
                            var insertColumn  = insertRowArray[i]
                            //  let insertColumnArray = [insertColumn]
                            
                            // let insertColumnArray = NSMutableArray.init(array: [insertColumn])
                            print("start\(insertColumn)")
                            for j in 0 ..< insertColumn.count{
                                insertColumn[j] = "\(newIndex)-\(i)-\(j)"
                                // insertColumnArray.replaceObject(at: j, with: "\(newIndex)-\(i)-\(j)")
                                
                                
                            }
                            insertRowArray[i] = insertColumn
                            
                        }
                        
                        self.localPartition[newIndex] = insertRowArray
                        print("NEW Index\(destIndex)")
                        let obj = collectionArray[sourceIndexPath.item]
                        collectionArray.remove(at: sourceIndexPath.item)
                        collectionArray.insert(obj, at: destIndex!)
                        print("locacl Part")
                        let sourseKeysSecond = Int(sourseKeys[1])! + 1
                        if (Int(sourseKeys[0])) == Int(destKeys[0]){
                            
                            if (Int(sourseKeys[1]) )! >= Int(destKeys[1])!{
                                
                                sourseKeys[0] = "\(Int(sourseKeys[0])!)"
                                sourseKeys[1] = "\(sourseKeysSecond)"
                                sourseKeys[2] = "\(Int(sourseKeys[2])!)"
                            }
                            
                        }
                        let rowArray = self.localPartition[(Int(sourseKeys[0]))!]
                        //  let rowArray = (self.localPartition.object(at: (Int(sourseKeys[0]))!) as! NSArray)
                        var row  = rowArray
                        print("source row array\(row)")
                        
                        let columnArray  = row[(Int(sourseKeys[1]))!]
                        // let columnArray  = row.object(at: (Int(sourseKeys[1]))!) as! NSArray
                        var column  = columnArray
                        print("column  array \(column)")
                        column.remove(at: column.count-1)
                        // need uncomment Code
                        self.changePartitionForSourceRowWithRow(rowArray: &row , andColumn: &column, andSourceKeys: &sourseKeys , andDestKeys: &destKeys)
                        defaults.set(localPartition, forKey: "partition")
                        if let local = defaults.object(forKey: "partition") as? Array<Array<Array<String>>>{
                            print(local)
                        }
                        
                        
                        
                        self.collectionView.performBatchUpdates({
                          //  UIView.setAnimationsEnabled(false)
                            
                            self.collectionView.moveItem(at: sourceIndexPath, to: IndexPath(item: destIndex!, section: 0))
                        }, completion: { (bool) in
                            self.reloadHeaderView = false
                            let set :IndexSet = [0]
                            CATransaction.begin()
                            CATransaction.setValue(kCFBooleanTrue, forKey: kCATransactionDisableActions)
                            self.collectionView.reloadSections(set)
                            CATransaction.commit()
                          //  UIView.setAnimationsEnabled(true)
                           // self.collectionView?.scrollToItem(at: IndexPath(item: destIndex!, section: 0), at: .centeredVertically, animated: true)
                            
                        })
                        
                    }else if (differenceRight < 20 && differenceRight > 0 && type != "Text"){
                        
                        
                        print("Inserting to the right of cell")
                        let destPaths = singletonArray[destinationIndexPath.item]
                        
                        var destKeys = destPaths.components(separatedBy: "-")
                        let rowNumber  = self.localPartition[Int(destKeys[0])!]
                        let rowTemp = rowNumber
                        
                        let nextItem  = rowTemp[Int(destKeys[1])!]
                        let searchString = nextItem.last
                        
                        var destIndex = singletonArray.index(of: searchString!)
                        let columnNumber = Int((destKeys[1]))! + 1
                        destKeys[0] = destKeys[0]
                        destKeys[1] = "\(columnNumber)"
                        destKeys[2] = destKeys[2]
                        
                        
                        if sourceIndexPath.item > destIndex!{
                            destIndex = destIndex! + 1
                        }
                        var insertRow = self.localPartition[Int((destKeys[0]))!]
                        var insertRowArray = insertRow
                        
                        guard let newIndex = Int(destKeys.first!) else {
                            return
                        }
                        print("New index \(newIndex)")
                        
                        let ArrayWithObj = "\(newIndex)-\(columnNumber)-\(0)"
                        var arrayObj = [ArrayWithObj]
                        //var arrayObj = NSArray(array: [ArrayWithObj])
                        // arrayObj.adding(ArrayWithObj)
                        // arrayObj.append(ArrayWithObj)
                        insertRowArray.insert(arrayObj, at: columnNumber)
                        print("start\(insertRowArray)")
                        
                        for i in columnNumber ..< insertRowArray.count{
                            
                            var insertColumn  = insertRowArray[i]
                            //  let insertColumnArray = [insertColumn]
                            
                            // let insertColumnArray = NSMutableArray.init(array: [insertColumn])
                            print("start\(insertColumn)")
                            for j in 0 ..< insertColumn.count{
                                insertColumn[j] = "\(newIndex)-\(i)-\(j)"
                                // insertColumnArray.replaceObject(at: j, with: "\(newIndex)-\(i)-\(j)")
                                
                                
                            }
                            insertRowArray[i] = insertColumn
                            
                        }
                        
                        self.localPartition[newIndex] = insertRowArray
                        print("NEW Index\(destIndex)")
                        let obj = collectionArray[sourceIndexPath.item]
                        collectionArray.remove(at: sourceIndexPath.item)
                        collectionArray.insert(obj, at: destIndex!)
                        selectedItemIndex = destIndex!
                        print("locacl Part")
                        let sourseKeysSecond = Int(sourseKeys[1])! + 1
                        if (Int(sourseKeys[0])) == Int(destKeys[0]){
                            
                            if (Int(sourseKeys[1]) )! >= Int(destKeys[1])!{
                                
                                
                                sourseKeys[0] = "\(Int(sourseKeys[0])!)"
                                sourseKeys[1] = "\(sourseKeysSecond)"
                                sourseKeys[2] = "\(Int(sourseKeys[2])!)"
                                
                                
                                //sourseKeys = ["\(Int(sourseKeys[0])!)-\(sourseKeysSecond)-\(Int(sourseKeys[2])!)"]
                            }
                            
                        }
                        let rowArray = self.localPartition[(Int(sourseKeys[0]))!]
                        //  let rowArray = (self.localPartition.object(at: (Int(sourseKeys[0]))!) as! NSArray)
                        var row  = rowArray
                        print("source row array\(row)")
                        
                        let columnArray  = row[(Int(sourseKeys[1]))!]
                        // let columnArray  = row.object(at: (Int(sourseKeys[1]))!) as! NSArray
                        var column  = columnArray
                        print("column  array \(column)")
                        column.remove(at: column.count-1)
                        // need uncomment Code
                        self.changePartitionForSourceRowWithRow(rowArray: &row , andColumn: &column, andSourceKeys: &sourseKeys , andDestKeys: &destKeys)
                        defaults.set(localPartition, forKey: "partition")
                        if let local = defaults.object(forKey: "partition") as? Array<Array<Array<String>>>{
                            print(local)
                        }
                        
                        
                        self.collectionView.performBatchUpdates({
                            
                            self.collectionView.moveItem(at: sourceIndexPath, to: IndexPath(item: destIndex!, section: 0))
                        }, completion: { (bool) in
                            self.reloadHeaderView = false
                            let set :IndexSet = [0]
                            CATransaction.begin()
                            CATransaction.setValue(kCFBooleanTrue, forKey: kCATransactionDisableActions)
                            self.collectionView.reloadSections(set)
                            CATransaction.commit()
                          //  self.collectionView?.scrollToItem(at: IndexPath(item: destIndex!, section: 0), at: .centeredVertically, animated: true)
                            
                        })
                        
                        
                    }else   if (differenceTop > -20 && differenceTop < 0 && destinationCell.frame.size.width < (UIScreen.main.bounds.width - 16) && type != "Text"){
                        print("Insert to the top of that cell")
                        
                        
                        
                        let destPaths = singletonArray[destinationIndexPath.item]
                        
                        
                        
                        var destKeys = destPaths.components(separatedBy: "-")
                        
                        var destIndex = destinationIndexPath.item
                        
                        if sourceIndexPath.item < destIndex {
                            destIndex = destIndex - 1
                            
                        }
                        var destRowArray  = self.localPartition[Int(destKeys[0])!]
                        var destColArray  = destRowArray[Int(destKeys[1])!]
                        //  let searchString = nextItem.first
                        var newObj = destKeys[0] + "-" + destKeys[1] + "-" + "\(destColArray.count)"
                        destColArray.append(newObj)
                        destRowArray[Int(destKeys[1])!] = destColArray
                        localPartition[Int(destKeys[0])!] = destRowArray
                        
                        let obj = collectionArray[sourceIndexPath.item]
                        collectionArray.remove(at: sourceIndexPath.item)
                        collectionArray.insert(obj, at: destIndex)
                        
                        
                        var rowArray = self.localPartition[(Int(sourseKeys[0]))!]
                        var columnArray  = rowArray[(Int(sourseKeys[1]))!]
                        
                        print("column  array \(columnArray)")
                        columnArray.remove(at: columnArray.count-1)
                        // need uncomment Code
                        
                        self.changePartitionForSourceRowWithRow(rowArray: &rowArray , andColumn: &columnArray, andSourceKeys: &sourseKeys , andDestKeys: &destKeys)
                        defaults.set(localPartition, forKey: "partition")
                        if let local = defaults.object(forKey: "partition") as? Array<Array<Array<String>>>{
                            print(local)
                        }
                        
                        
                        self.collectionView.performBatchUpdates({
                            
                            self.collectionView.moveItem(at: sourceIndexPath, to: IndexPath(item: destIndex, section: 0))
                        }, completion: { (bool) in
                            self.reloadHeaderView = false
                            let set :IndexSet = [0]
                            CATransaction.begin()
                            CATransaction.setValue(kCFBooleanTrue, forKey: kCATransactionDisableActions)
                            self.collectionView.reloadSections(set)
                            CATransaction.commit()
                     //       self.collectionView?.scrollToItem(at: IndexPath(item: destIndex, section: 0), at: .centeredVertically, animated: true)
                            
                        })
                        
                        
                        
                        
                        
                    }else if(differenceBottom > 0 && differenceBottom < 20 && destinationCell.frame.size.width < (UIScreen.main.bounds.width - 16) && type != "Text"){
                        print("Insert to the bottom of that cell")
                        
                        let destPaths = singletonArray[destinationIndexPath.item]
                        var destKeys = destPaths.components(separatedBy: "-")
                        var destRowArray  = self.localPartition[Int(destKeys[0])!]
                        var destIndex = destinationIndexPath.item
                        
                        if sourceIndexPath.item > destIndex {
                            destIndex = destIndex + 1
                        }
                        var destColArray  = destRowArray[Int(destKeys[1])!]
                        //  let searchString = nextItem.first
                        var newObj = destKeys[0] + "-" + destKeys[1] + "-" + "\(destColArray.count)"
                        destColArray.append(newObj)
                        destRowArray[Int(destKeys[1])!] = destColArray
                        localPartition[Int(destKeys[0])!] = destRowArray
                        
                        let obj = collectionArray[sourceIndexPath.item]
                        collectionArray.remove(at: sourceIndexPath.item)
                        collectionArray.insert(obj, at: destIndex)
                        
                        
                        var rowArray = self.localPartition[(Int(sourseKeys[0]))!]
                        var columnArray  = rowArray[(Int(sourseKeys[1]))!]
                        
                        print("column  array \(columnArray)")
                        columnArray.remove(at: columnArray.count-1)
                        // need uncomment Code
                        
                        self.changePartitionForSourceRowWithRow(rowArray: &rowArray , andColumn: &columnArray, andSourceKeys: &sourseKeys , andDestKeys: &destKeys)
                        defaults.set(localPartition, forKey: "partition")
                        if let local = defaults.object(forKey: "partition") as? Array<Array<Array<String>>>{
                            print(local)
                        }
                        self.collectionView.performBatchUpdates({
                            
                            self.collectionView.moveItem(at: sourceIndexPath, to: IndexPath(item: destIndex, section: 0))
                        }, completion: { (bool) in
                            self.reloadHeaderView = false
                            let set :IndexSet = [0]
                            CATransaction.begin()
                            CATransaction.setValue(kCFBooleanTrue, forKey: kCATransactionDisableActions)
                            self.collectionView.reloadSections(set)
                             CATransaction.commit()
                     //       self.collectionView?.scrollToItem(at: IndexPath(item: destIndex, section: 0), at: .centeredVertically, animated: true)
                            
                        })
                    }else{
                        self.reloadHeaderView = false
                        let set :IndexSet = [0]
                        CATransaction.begin()
                        CATransaction.setValue(kCFBooleanTrue, forKey: kCATransactionDisableActions)
                        self.collectionView.reloadSections(set)
                        CATransaction.commit()
                        
                    }
                    }else{
                        self.reloadHeaderView = false
                        let set :IndexSet = [0]
                        CATransaction.begin()
                        CATransaction.setValue(kCFBooleanTrue, forKey: kCATransactionDisableActions)
                        self.collectionView.reloadSections(set)
                        CATransaction.commit()

                        
                    }
                }else{
                    self.lineView.removeFromSuperview()
                    
                }
                
            }
            
            
        }else{
            
            
            let pIndexPath = self.collectionView.indexPathForItem(at: CGPoint(x: location.x - 6, y: location.y))
            let nIndexPath = self.collectionView.indexPathForItem(at: CGPoint(x: location.x + 6, y: location.y))
            let uIndexPath = self.collectionView.indexPathForItem(at: CGPoint(x: location.x, y: location.y - 6))
            let lIndexPath = self.collectionView.indexPathForItem(at: CGPoint(x: location.x, y: location.y + 6))
            //guard let indexPath = self.collectionView?.indexPathForItem(at: location)else{  return }
            
            var singletonArray = self.getSingletonArray()
            var sourseKey = singletonArray[sourceIndexPath.item]
            var sourseKeys = sourseKey.components(separatedBy: "-")
            let temp = collectionArray[sourceIndexPath.row]
            let type  =  temp["type"] as! String
            
            if var pIndexPath = pIndexPath,var nIndexPath = nIndexPath, type != "Text"{
                let dict = self.collectionArray[sourceIndexPath.item]
                if let type  =  dict["type"] as? String{
                    if type != "Text"{
                        print("Insert in between two cells in the same row taken as horizontally")
                        
                        print("Inserting to the right of cell")
                        let destPaths = singletonArray[pIndexPath.item]
                        
                        var destKeys = destPaths.components(separatedBy: "-")
                        let rowNumber  = self.localPartition[Int(destKeys[0])!]
                        let rowTemp = rowNumber
                        
                        let nextItem  = rowTemp[Int(destKeys[1])!]
                        let searchString = nextItem.first
                        
                        // let nextItem = rowNumber.object(at: destKeys[1])
                        var destIndex = singletonArray.index(of: searchString!)
                        
                        
                        if sourceIndexPath.item >  destIndex!{
                            destIndex = destIndex! + 1
                        }
                        
                        var insertRow = self.localPartition[Int((destKeys[0]))!]
                        var insertRowArray = insertRow
                        let columnNumber = Int((destKeys[1]))!
                        guard let newIndex = Int(destKeys.first!) else {
                            return
                        }
                        print("New index \(newIndex)")
                        
                        let ArrayWithObj = "\(newIndex)-\(columnNumber)-\(0)"
                        var arrayObj = [ArrayWithObj]
                        //var arrayObj = NSArray(array: [ArrayWithObj])
                        // arrayObj.adding(ArrayWithObj)
                        // arrayObj.append(ArrayWithObj)
                        insertRowArray.insert(arrayObj, at: columnNumber)
                        print("start\(insertRowArray)")
                        
                        for i in columnNumber ..< insertRowArray.count{
                            
                            var insertColumn  = insertRowArray[i]
                            //  let insertColumnArray = [insertColumn]
                            
                            // let insertColumnArray = NSMutableArray.init(array: [insertColumn])
                            print("start\(insertColumn)")
                            for j in 0 ..< insertColumn.count{
                                insertColumn[j] = "\(newIndex)-\(i)-\(j)"
                                // insertColumnArray.replaceObject(at: j, with: "\(newIndex)-\(i)-\(j)")
                                
                                
                            }
                            insertRowArray[i] = insertColumn
                            
                        }
                        
                        self.localPartition[newIndex] = insertRowArray
                        print("NEW Index\(destIndex)")
                        let obj = collectionArray[sourceIndexPath.item]
                        collectionArray.remove(at: sourceIndexPath.item)
                        collectionArray.insert(obj, at: destIndex!)
                        
                        selectedItemIndex = destIndex!
                        print("locacl Part")
                        let sourseKeysSecond = Int(sourseKeys[1])! + 1
                        if (Int(sourseKeys[0])) == Int(destKeys[0]){
                            
                            if (Int(sourseKeys[1]) )! >= Int(destKeys[1])!{
                                
                                
                                sourseKeys[0] = "\(Int(sourseKeys[0])!)"
                                sourseKeys[1] = "\(sourseKeysSecond)"
                                sourseKeys[2] = "\(Int(sourseKeys[2])!)"
                                
                                
                                //sourseKeys = ["\(Int(sourseKeys[0])!)-\(sourseKeysSecond)-\(Int(sourseKeys[2])!)"]
                            }
                            
                        }
                        let rowArray = self.localPartition[(Int(sourseKeys[0]))!]
                        //  let rowArray = (self.localPartition.object(at: (Int(sourseKeys[0]))!) as! NSArray)
                        var row  = rowArray
                        print("source row array\(row)")
                        
                        let columnArray  = row[(Int(sourseKeys[1]))!]
                        // let columnArray  = row.object(at: (Int(sourseKeys[1]))!) as! NSArray
                        var column  = columnArray
                        print("column  array \(column)")
                        column.remove(at: column.count-1)
                        // need uncomment Code
                        self.changePartitionForSourceRowWithRow(rowArray: &row , andColumn: &column, andSourceKeys: &sourseKeys , andDestKeys: &destKeys)
                        defaults.set(localPartition, forKey: "partition")
                        if let local = defaults.object(forKey: "partition") as? Array<Array<Array<String>>>{
                            print(local)
                        }
                        
                        
                        self.collectionView.performBatchUpdates({
                            
                            self.collectionView.moveItem(at: sourceIndexPath, to: IndexPath(item: destIndex!, section: 0))
                        }, completion: { (bool) in
                            self.reloadHeaderView = false
                            let set :IndexSet = [0]
                            CATransaction.begin()
                            CATransaction.setValue(kCFBooleanTrue, forKey: kCATransactionDisableActions)
                            self.collectionView.reloadSections(set)
                            CATransaction.commit()
                       //     self.collectionView?.scrollToItem(at: IndexPath(item: destIndex!, section: 0), at: .centeredVertically, animated: true)
                            
                        })
                        
                        
                    }
                }
            }else if var uIndexPath = uIndexPath,var lIndexPath = lIndexPath{
                
                print("Insert in between two cells in the same row taken as vertically line")
                if let  uCell = self.collectionView.cellForItem(at:uIndexPath){
                    var uKey = singletonArray[uIndexPath.item].components(separatedBy: "-")
                    var lKey = singletonArray[lIndexPath.item].components(separatedBy: "-")
                    //  var cellFrame = CGRectFromString(frmaes[Int(uKey[0])!])
                    
                    
                    if Int(uKey[0]) == Int(lKey[0])
                    {
                        
                        let dict = self.collectionArray[sourceIndexPath.item]
                        if let type  =  dict["type"] as? String{
                            if type != "Text"{
                                
                                print("Inserting to the right of cell")
                                let destPaths = singletonArray[uIndexPath.item]
                                
                                var destKeys = destPaths.components(separatedBy: "-")
                                let rowNumber  = self.localPartition[Int(destKeys[0])!]
                                let rowTemp = rowNumber
                                
                                let nextItem  = rowTemp[Int(destKeys[1])!]
                                let searchString = nextItem.first
                                
                                // let nextItem = rowNumber.object(at: destKeys[1])
                                var destIndex = singletonArray.index(of: searchString!)
                                
                                
                                if sourceIndexPath.item > destIndex!{
                                    destIndex = destIndex! + 1
                                }
                                
                                
                                var insertRow = self.localPartition[Int((destKeys[0]))!]
                                var destColArray = insertRow[Int((destKeys[1]))!]
                                let columnNumber = Int((destKeys[1]))!
                                guard let newIndex = Int(destKeys.first!) else {
                                    return
                                }
                                print("New index \(newIndex)")
                                let ArrayWithObj = "\(newIndex)-\(columnNumber)-\(destColArray.count)"
                                destColArray.append(ArrayWithObj)
                                insertRow[columnNumber] = destColArray
                                self.localPartition[Int((destKeys[0]))!] = insertRow
                                
                                let obj = collectionArray[sourceIndexPath.item]
                                collectionArray.remove(at: sourceIndexPath.item)
                                collectionArray.insert(obj, at: destIndex!)
                                selectedItemIndex = destIndex!
                                
                                let rowArray = self.localPartition[(Int(sourseKeys[0]))!]
                                
                                
                                //  let rowArray = (self.localPartition.object(at: (Int(sourseKeys[0]))!) as! NSArray)
                                var row  = rowArray
                                print("source row array\(row)")
                                
                                let columnArray  = row[(Int(sourseKeys[1]))!]
                                // let columnArray  = row.object(at: (Int(sourseKeys[1]))!) as! NSArray
                                var column  = columnArray
                                print("column  array \(column)")
                                column.remove(at: column.count-1)
                                // need uncomment Code
                                self.changePartitionForSourceRowWithRow(rowArray: &row , andColumn: &column, andSourceKeys: &sourseKeys , andDestKeys: &destKeys)
                                defaults.set(localPartition, forKey: "partition")
                                if let local = defaults.object(forKey: "partition") as? Array<Array<Array<String>>>{
                                    print(local)
                                }
                                
                                
                                self.collectionView.performBatchUpdates({
                                    
                                    self.collectionView.moveItem(at: sourceIndexPath, to: IndexPath(item: destIndex!, section: 0))
                                }, completion: { (bool) in
                                    
                                    self.reloadHeaderView = false
                                    let set :IndexSet = [0]
                                    CATransaction.begin()
                                    CATransaction.setValue(kCFBooleanTrue, forKey: kCATransactionDisableActions)
                                    self.collectionView.reloadSections(set)
                                     CATransaction.commit()
                                   // self.collectionView?.scrollToItem(at: IndexPath(item: destIndex!, section: 0), at: .centeredVertically, animated: true)
                                    
                                })
                                
                                
                            }else{
                                self.reloadHeaderView = false
                                self.lineView.removeFromSuperview()
                                let set :IndexSet = [0]
                                CATransaction.begin()
                                CATransaction.setValue(kCFBooleanTrue, forKey: kCATransactionDisableActions)
                                self.collectionView.reloadSections(set)
                                CATransaction.commit()
                            }
                        }
                        
                    }else{
                        print("Different row")
                        
                        let destPaths = singletonArray[uIndexPath.item]
                        var destKeys = destPaths.components(separatedBy: "-")
                        var lastItem = self.localPartition[Int(destKeys[0])!]
                        var nested = lastItem.last
                        var thirdNested = nested?.last
                        var destIndex = singletonArray.index(of: thirdNested!)
                        destIndex! = destIndex! + 1
                        if sourceIndexPath.item < destIndex!{
                            destIndex = destIndex! - 1
                        }
                        var destRow = Int(destKeys.first!)! +  1
                        
                        var newObj = ["\(destRow)-0-0"]
                        
                        var insertObj = [newObj]
                        
                        self.localPartition.insert(insertObj, at: destRow)
                        //   self.localPartition[destRow] = insertObj
                        
                        for i in (destRow + 1) ..< self.localPartition.count{
                            
                            var rowArray  = self.localPartition[i]
                            for j in 0 ..< rowArray.count{
                                var colArray = rowArray[j]
                                
                                for k in 0 ..< colArray.count{
                                    colArray[k] = "\(i)-\(j)-\(k)"
                                }
                                rowArray[j] = colArray
                            }
                            self.localPartition[i] = rowArray
                        }
                        
                        let obj = collectionArray[sourceIndexPath.item]
                        collectionArray.remove(at: sourceIndexPath.item)
                        collectionArray.insert(obj, at: destIndex!)
                        selectedItemIndex = destIndex!
                        
                        var sourceRow = (Int(sourseKeys[0]))!
                        
                        if(destRow <= sourceRow){
                            sourceRow = sourceRow +  1
                        }
                        
                        sourseKeys[0] = "\(sourceRow)"
                        sourseKeys[1] = sourseKeys[1]
                        sourseKeys[2] = sourseKeys[2]
                        
                        //sourseKeys  = ["\(sourceRow)",sourseKeys[1],sourseKeys[2]]
                        
                        
                        var rowArray = self.localPartition[sourceRow]
                        var columnArray  = rowArray[(Int(sourseKeys[1]))!]
                        
                        print("column  array \(columnArray)")
                        columnArray.remove(at: columnArray.count-1)
                        // need uncomment Code
                        
                        self.changePartitionForSourceRowWithRow(rowArray: &rowArray , andColumn: &columnArray, andSourceKeys: &sourseKeys , andDestKeys: &destKeys)
                        defaults.set(localPartition, forKey: "partition")
                        if let local = defaults.object(forKey: "partition") as? Array<Array<Array<String>>>{
                            print(local)
                        }
                        
                        
                        self.collectionView.performBatchUpdates({
                            
                            self.collectionView.moveItem(at: sourceIndexPath, to: IndexPath(item: destIndex!, section: 0))
                        }, completion: { (bool) in
                            self.reloadHeaderView = false
                            let set :IndexSet = [0]
                            CATransaction.begin()
                            CATransaction.setValue(kCFBooleanTrue, forKey: kCATransactionDisableActions)
                            self.collectionView.reloadSections(set)
                            CATransaction.commit()
                          //  self.collectionView?.scrollToItem(at: IndexPath(item: destIndex!, section: 0), at: .centeredVertically, animated: true)
                            
                        })
                        
                        
                        
                    }
                    
                }
                
            }else  if var uIndexPath = uIndexPath, lIndexPath == nil{
                var uKey = singletonArray[uIndexPath.item]
                var uKey1 = uKey.components(separatedBy: "-")
                
                if Int(uKey1[0])! == (self.localPartition.count - 1){
                    print("insert at the bottom of collection view")
                    
                    var destPaths = singletonArray[uIndexPath.item]
                    var destKeys = destPaths.components(separatedBy: "-")
                    var destIndex = singletonArray.count - 1
                    var destRow = Int(destKeys.first!)! + 1
                    var newObj = ["\(destRow)-0-0"]
                    var insertObj = [newObj]
                    self.localPartition.insert(insertObj, at: destRow)
                    // self.localPartition[destRow] = insertObj
                    
                    for i in destRow+1 ..< self.localPartition.count{
                        var rowArray = self.localPartition[i]
                        for j in 0 ..< rowArray.count{
                            var colArray =  rowArray[j]
                            for k in 0 ..< colArray.count{
                                colArray[k] = "\(i)-\(j)-\(k)"
                            }
                            rowArray[j] = colArray
                        }
                        localPartition[i] = rowArray
                        
                    }
                    
                    
                    //  self.localPartition[newIndex] = insertRowArray
                    // print("NEW Index\(destIndex)")
                    let obj = collectionArray[sourceIndexPath.item]
                    collectionArray.remove(at: sourceIndexPath.item)
                    collectionArray.insert(obj, at: destIndex)
                    print("locacl Part")
                    
                    
                    
                    let rowArray = self.localPartition[(Int(sourseKeys[0]))!]
                    //  let rowArray = (self.localPartition.object(at: (Int(sourseKeys[0]))!) as! NSArray)
                    var row  = rowArray
                    print("source row array\(row)")
                    
                    let columnArray  = row[(Int(sourseKeys[1]))!]
                    // let columnArray  = row.object(at: (Int(sourseKeys[1]))!) as! NSArray
                    var column  = columnArray
                    print("column  array \(column)")
                    column.remove(at: column.count-1)
                    // need uncomment Code
                    self.changePartitionForSourceRowWithRow(rowArray: &row , andColumn: &column, andSourceKeys: &sourseKeys , andDestKeys: &destKeys)
                    defaults.set(localPartition, forKey: "partition")
                    if let local = defaults.object(forKey: "partition") as? Array<Array<Array<String>>>{
                        print(local)
                    }
                    
                    
                    self.collectionView.performBatchUpdates({
                        
                        self.collectionView.moveItem(at: sourceIndexPath, to: IndexPath(item: destIndex, section: 0))
                    }, completion: { (bool) in
                        self.reloadHeaderView = false
                        let set :IndexSet = [0]
                        CATransaction.begin()
                        CATransaction.setValue(kCFBooleanTrue, forKey: kCATransactionDisableActions)
                        self.collectionView.reloadSections(set)
                        CATransaction.commit()
                      //  self.collectionView?.scrollToItem(at: IndexPath(item: destIndex, section: 0), at: .centeredVertically, animated: true)
                        
                    })
                    
                    
                }else{
                    self.lineView.removeFromSuperview()
                    var indexSet :IndexSet = [0]
                    self.collectionView.reloadSections(indexSet)
                }
                
            }else if var lIndexPath = lIndexPath, uIndexPath == nil {
                
                var lKey = singletonArray[lIndexPath.item]
                var lKey1 = lKey.components(separatedBy: "-")
                if( Int(lKey1[0])! == 0)
                {
                    print("Insert at the top of collection view")
                    
                    var destPaths = singletonArray[lIndexPath.item]
                    var destKeys = destPaths.components(separatedBy: "-")
                    var destIndex = 0
                    var destRow = Int(destKeys.first!)!
                    
                    var newObj = ["\(destRow)-0-0"]
                    
                    var insertObj = [newObj]
                    self.localPartition.insert(insertObj, at: destRow)
                    // self.localPartition[destRow] = insertObj
                    
                    for i in destRow+1 ..< self.localPartition.count{
                        var rowArray = self.localPartition[i]
                        for j in 0 ..< rowArray.count{
                            var colArray =  rowArray[j]
                            for k in 0 ..< colArray.count{
                                colArray[k] = "\(i)-\(j)-\(k)"
                            }
                            rowArray[j] = colArray
                        }
                        localPartition[i] = rowArray
                        
                    }
                    
                    
                    let obj = collectionArray[sourceIndexPath.item]
                    collectionArray.remove(at: sourceIndexPath.item)
                    collectionArray.insert(obj, at: destIndex)
                    print("locacl Part")
                    
                    selectedItemIndex  = destIndex
                    
                    var sourceRow = Int(sourseKeys[0])!
                    
                    if(destRow <= sourceRow){
                        sourceRow = sourceRow  + 1
                    }
                    
                    sourseKeys[0] = "\(sourceRow)"
                    sourseKeys[1] = sourseKeys[1]
                    sourseKeys[2] = sourseKeys[2]
                    
                    
                    
                    
                    let rowArray = self.localPartition[(Int(sourceRow))]
                    //  let rowArray = (self.localPartition.object(at: (Int(sourseKeys[0]))!) as! NSArray)
                    var row  = rowArray
                    print("source row array\(row)")
                    
                    let columnArray  = row[(Int(sourseKeys[1]))!]
                    // let columnArray  = row.object(at: (Int(sourseKeys[1]))!) as! NSArray
                    var column  = columnArray
                    print("column  array \(column)")
                    column.remove(at: column.count-1)
                    // need uncomment Code
                    self.changePartitionForSourceRowWithRow(rowArray: &row , andColumn: &column, andSourceKeys: &sourseKeys , andDestKeys: &destKeys)
                    defaults.set(localPartition, forKey: "partition")
                    if let local = defaults.object(forKey: "partition") as? Array<Array<Array<String>>>{
                        print(local)
                    }
                    
                    
                    self.collectionView.performBatchUpdates({
                        
                        self.collectionView.moveItem(at: sourceIndexPath, to: IndexPath(item: destIndex, section: 0))
                    }, completion: { (bool) in
                        self.reloadHeaderView = false
                        let set :IndexSet = [0]
                        CATransaction.begin()
                        CATransaction.setValue(kCFBooleanTrue, forKey: kCATransactionDisableActions)
                        self.collectionView.reloadSections(set)
                        CATransaction.commit()
                    //    self.collectionView?.scrollToItem(at: IndexPath(item: destIndex, section: 0), at: .centeredVertically, animated: true)
                        
                    })
                    
                    
                    
                    
                    
                }else{
                    self.reloadHeaderView = false
                    self.lineView.removeFromSuperview()
                    let set :IndexSet = [0]
                    CATransaction.begin()
                    CATransaction.setValue(kCFBooleanTrue, forKey: kCATransactionDisableActions)
                    self.collectionView.reloadSections(set)
                    CATransaction.commit()
                }
                
                
                
            }else{
                self.lineView.removeFromSuperview()
            }
            
            
            
        }
        
        self.changeToIdentiPosition()
    }
    
    func changePartitionForSourceRowWithRow(rowArray :inout Array<Array<String>>,andColumn columnArray:inout Array<String>,andSourceKeys keys: inout Array<String>,andDestKeys destKeys:inout Array<String>) {
        
        if (columnArray.count > 0){
            //rowArray[Int(keys[1])!] = columnArray
            rowArray[Int(keys[1])!] = columnArray
            //  rowArray.replaceObject(at: Int(keys[1] as! String)! , with: columnArray)
            localPartition[Int(keys[0])!] = rowArray
            //    localPartition.replaceObject(at:Int(keys[0] as! String)!, with: rowArray)
            
        }else{
            
            rowArray.remove(at: Int(keys[1])!)
            // rowArray.removeObject(at: keys[1] as! Int)
            if rowArray.count != 0{
                if rowArray.count == 1 && (rowArray[0].count > 1){
                    localPartition.remove(at: Int(keys[0])!)
                    let sourceRow = Int(keys[0])!
                    let rowCount = rowArray[0].count
                    
                    for i in sourceRow..<(sourceRow + rowCount) {
                        
                        let ArrayWithObj = "\(i)-\(0)-\(0)"
                        
                        var arrayObj = [ArrayWithObj]
                        let rowObject = [arrayObj]
                        localPartition.insert(rowObject, at: i)
                        //localPartition.insert(rowObject, at: i)
                    }
                    
                    for j in (sourceRow+rowCount) ..< localPartition.count{
                        var rowArray = localPartition[j]
                        //let rowArray : NSMutableArray = localPartition.object(at: j) as! NSMutableArray
                        for k  in 0 ..< rowArray.count{
                            var colArray1 = rowArray[k]
                            //let colArray1:NSMutableArray = rowArray.object(at: k) as! NSMutableArray
                            for  l in 0 ..< colArray1.count{
                                colArray1[l] = "\(j)-\(k)-\(l)"
                                //colArray1.replaceObject(at: l, with: "\(j)-\(k)-\(l)")
                            }
                            rowArray[k] = colArray1
                            //rowArray.replaceObject(at: k, with: colArray1)
                        }
                        localPartition[j] = rowArray
                        //localPartition.replaceObject(at: j, with: rowArray)
                        
                    }
                    
                }else{
                    for  i in Int(keys[1])! ..< rowArray.count {
                        var colArray = rowArray[i]
                        
                        //let colArray :NSMutableArray = rowArray.object(at: i) as! NSMutableArray
                        for j  in 0 ..< colArray.count {
                            colArray[j] = "\(Int(keys[0])!)-\(i)-\(j)"
                            // colArray.replaceObject(at: j, with: "\(keys.firstObject as! Int)-\(i)-\(j)")
                        }
                        rowArray[i] = colArray
                        // rowArray.replaceObject(at: i, with: colArray)
                    }
                    localPartition[Int(keys[0])!] = rowArray
                    //localPartition.replaceObject(at: keys.firstObject as! Int, with: rowArray)
                    
                }
                
            }else{
                localPartition.remove(at: Int(keys[0])!)
                //localPartition.removeObject(at: keys.firstObject as! Int)
                for i in Int(keys[0])! ..< localPartition.count {
                    var rowArray = localPartition[i]
                    //let rowArray :NSMutableArray = localPartition.object(at: i) as! NSMutableArray
                    for j in 0 ..< rowArray.count {
                        var colArray = rowArray[j]
                        //let colArray :NSMutableArray = rowArray.object(at: j) as! NSMutableArray
                        for k in 0 ..< colArray.count{
                            colArray[k] = "\(i)-\(j)-\(k)"
                            //colArray.replaceObject(at: j, with: "\(i)-\(j)-\(k)")
                        }
                        rowArray[j] = colArray
                        //rowArray.replaceObject(at: j, with: colArray)
                        
                    }
                    localPartition[i] = rowArray
                }
            }
            
        }
        
        print("final update \(localPartition)")
        
    }
    
    func findWithIndex(array : [String],index i : Int = 0) -> String? {
        for j in 0...array.count {
            if j == i {
                return  array[i]
            }
        }
        return nil
    }
    
    func getSingletonArray() -> Array<String>{
        
        var returnArray = Array<String>()
        for (_,indexArray) in localPartition.enumerated(){
            for (_,insideArray) in indexArray.enumerated(){
                for (_,inside) in insideArray.enumerated(){
                    returnArray.append(inside)
                }
                
            }
            
        }
        
        
        
        //        let returnArray = NSMutableArray.init()
        //        for (_,indexArray) in localPartition.enumerated(){
        //            for (_,insideArray) in (indexArray as! NSArray).enumerated(){
        //            for (_,inside) in (insideArray as! NSArray).enumerated(){
        //             //   returnArray.addObjects(from: inside)
        //                let element = inside as! String
        //                returnArray.add(element)
        //          //  returnArray.addObjects(from: element)
        //                //returnArray.add(element[0])
        //                }
        //
        //            }
        //        }
        return returnArray
        
    }
    
    func endDragAtLocation(location:CGPoint){
       let vc = collectionView
        guard let originalIndexPath = originalIndexPath else {return}
        guard var dragView = self.draggingView else {return}
        if let indexPath = vc.indexPathForItem(at: location), let cell = vc.cellForItem(at: originalIndexPath),let destination = vc.cellForItem(at: indexPath)  {
            //added
            
            
            if let indexPath = vc.indexPathForItem(at: location){
                
                let sourceCell = vc.cellForItem(at: originalIndexPath)
                if let destinationCell = vc.cellForItem(at: indexPath)
                {
                    self.changeToIdentiPosition()
                    lineView.removeFromSuperview()
                    self.swapView?.removeFromSuperview()
                    
                    //   print("\(indexPath.item)source but destination\(sourceIndexPath.item)")
                    if indexPath.item != originalIndexPath.item{
                        
                        let dict = self.collectionArray[originalIndexPath.item]
                        if let type  =  dict["type"] as? String{
                            if type != "Text"{
                                
                                
                                let topOffset = destinationCell.frame.origin.y + 20
                                let leftOffset = destinationCell.frame.origin.x + 20
                                let bottomOffset = destinationCell.frame.origin.y + destinationCell.frame.size.height - 20
                                let rightOffset = destinationCell.frame.origin.x + destinationCell.frame.size.width - 20
                                let differenceLeft = location.x - leftOffset
                                
                                let differenceRight = location.x - rightOffset
                                // print("destination\(destinationCell.frame)")
                                let differenceTop = location.y - topOffset
                                let differenceBottom = location.y - bottomOffset
                                if differenceLeft > -20 && differenceLeft < 0 {
                                    print("Insert to the left of cell line")
                                    self.insertNewCellAtPoint(location: location, withSourceIndexPathwithSourceIndexPath: originalIndexPath, forSnapshot: dragView.frame)
                                    sourceCell?.isHidden  = false
                                  //  originalIndexPath = nil
                                    sourceCell?.removeFromSuperview()
                                    //sourceCell.hidden = NO;
                                    //sourceIndexPath = nil;
                                    dragView.removeFromSuperview()
                                    // dragView = nil
                                    
                                    //[snapshot removeFromSuperview];
                                    //snapshot = nil;
                                    
                                }else if differenceRight < 20 && differenceRight > 0{
                                    
                                    print("Insert to the right of the cell line")
                                    
                                    self.insertNewCellAtPoint(location: location, withSourceIndexPathwithSourceIndexPath: originalIndexPath, forSnapshot: dragView.frame)
                                    sourceCell?.isHidden  = false
                                   // originalIndexPath = nil
                                    sourceCell?.removeFromSuperview()
                                    //sourceCell.hidden = NO;
                                    //sourceIndexPath = nil;
                                    dragView.removeFromSuperview()
                                    //  dragView = nil
                                    
                                    //          need to remove top should be uncomment
                                }else if (differenceTop > -20 && differenceTop < 0 && destinationCell.frame.size.width < (UIScreen.main.bounds.width - 16)){
                                    print("Insert to the TOP of the cell line")
                                    self.insertNewCellAtPoint(location: location, withSourceIndexPathwithSourceIndexPath: originalIndexPath, forSnapshot: dragView.frame)
                                    sourceCell?.isHidden  = false
                                   // originalIndexPath = nil
                                    sourceCell?.removeFromSuperview()
                                    //sourceCell.hidden = NO;
                                    //sourceIndexPath = nil;
                                    dragView.removeFromSuperview()
                                    //self.draggingView = nil
                                    
                                }else if(differenceBottom > 0 && differenceBottom < 20 && destinationCell.frame.size.width < (UIScreen.main.bounds.width - 16)){
                                    print("Insert to the Bottom of the cell line")
                                    self.insertNewCellAtPoint(location: location, withSourceIndexPathwithSourceIndexPath: originalIndexPath, forSnapshot: (self.draggingView?.frame)!)
                                    sourceCell?.isHidden  = false
                                    //originalIndexPath = nil
                                    sourceCell?.removeFromSuperview()
                                    //sourceCell.hidden = NO;
                                    //sourceIndexPath = nil;
                                    dragView.removeFromSuperview()
                                    //self.draggingView = nil
                                }else{
                                    
                                    let dict = self.collectionArray[(originalIndexPath.item)]
                                    if let type  =  dict["type"] as? String{
                                        if type != "Text"{
                                            
                                            
                                            self.exchangeDataSource(sourceIndex: indexPath.item, destIndex: (self.originalIndexPath?.item)!)
                                            
                                            
                                            vc.performBatchUpdates({
                                                print("\(UserDefaults.standard.object(forKey: "partition"))final partation")
                                                self.collectionView.moveItem(at: self.originalIndexPath!, to: indexPath)
                                                self.collectionView.moveItem(at: indexPath, to: self.originalIndexPath!)
                                                
                                            }, completion: { (Bool) in
                                                cell.alpha = 1
                                                cell.isHidden = false
                                                dragView.removeFromSuperview()
                                                // vc.layoutIfNeeded()
                                                // vc.setNeedsLayout()
                                                self.originalIndexPath = nil
                                                self.draggingView = nil
                                                
                                            })
                                            
                                            
                                            
                                            
                                        }else{
                                            
                                            
                                            
                                            if (cell.frame.size.width == destinationCell.frame.size.width){
                                                
                                                self.exchangeDataSource(sourceIndex: indexPath.item, destIndex: (self.originalIndexPath?.item)!)
                                                self.selectedItemIndex = indexPath.item
                                                vc.performBatchUpdates({
                                                    
                                                    self.collectionView.moveItem(at: self.originalIndexPath!, to: indexPath)
                                                    self.collectionView.moveItem(at: indexPath, to: self.originalIndexPath!)
                                                    
                                                }, completion: { (Bool) in
                                                    cell.alpha = 1
                                                    cell.isHidden = false
                                                    dragView.removeFromSuperview()
                                                    self.originalIndexPath = nil
                                                    self.draggingView = nil
                                                    
                                                })
                                                
                                                
                                                
                                            }else{
                                                
                                                self.lineView.removeFromSuperview()
                                                cell.alpha = 0
                                                
                                                
                                                UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 0.4, initialSpringVelocity: 0.2, options: [], animations: {
                                                    self.draggingView!.center = cell.center
                                                    self.draggingView!.transform = CGAffineTransform.identity
                                                    self.draggingView!.alpha = 0.0
                                                    //self.draggingView!.
                                                    cell.alpha = 1
                                                    cell.isHidden = false
                                                }) { (Bool) in
                                                    self.draggingView?.removeFromSuperview()
                                                    self.collectionView.layoutIfNeeded()
                                                    self.collectionView.setNeedsLayout()
                                                    // cell.alpha = 1
                                                    self.originalIndexPath = nil
                                                    self.draggingView = nil
                                                }
                                                
                                                
                                            }
                                            
                                        }
                                    }
                                    
                                    
                                    
                                    
                                }
                                
                            }else{
                                //Swap the images
                                
                                if (cell.frame.size.width == destinationCell.frame.size.width){
                                    
                                    self.exchangeDataSource(sourceIndex: indexPath.item, destIndex: (self.originalIndexPath?.item)!)
                                    self.selectedItemIndex = indexPath.item
                                    vc.performBatchUpdates({
                                        
                                        self.collectionView.moveItem(at: self.originalIndexPath!, to: indexPath)
                                        self.collectionView.moveItem(at: indexPath, to: self.originalIndexPath!)
                                        
                                    }, completion: { (Bool) in
                                        cell.alpha = 1
                                        cell.isHidden = false
                                        dragView.removeFromSuperview()
                                        self.originalIndexPath = nil
                                        self.draggingView = nil
                                        
                                    })
                                    
                                    
                                    
                                }else{
                                    
                                    self.lineView.removeFromSuperview()
                                    cell.alpha = 0
                                    
                                    UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 0.4, initialSpringVelocity: 0.2, options: [], animations: {
                                        self.draggingView!.center = cell.center
                                        self.draggingView!.transform = CGAffineTransform.identity
                                        self.draggingView!.alpha = 0.0
                                        //self.draggingView!.
                                        cell.alpha = 1
                                        cell.isHidden = false
                                    }) { (Bool) in
                                        self.draggingView?.removeFromSuperview()
                                        self.collectionView.layoutIfNeeded()
                                        self.collectionView.setNeedsLayout()
                                        // cell.alpha = 1
                                        self.originalIndexPath = nil
                                        self.draggingView = nil
                                    }
                                    
                                    
                                }
                            }
                        }
                        
                        
                    }
                    else{
                        
                        print("outofsource")
                        self.lineView.removeFromSuperview()
                        cell.alpha = 0
                        
                        UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 0.4, initialSpringVelocity: 0.2, options: [], animations: {
                            self.draggingView!.center = cell.center
                            self.draggingView!.transform = CGAffineTransform.identity
                            self.draggingView!.alpha = 0.0
                            //self.draggingView!.
                            cell.alpha = 1
                            cell.isHidden = false
                            
                        }, completion: { (end) in
                            
                            self.draggingView?.removeFromSuperview()
                            self.collectionView.layoutIfNeeded()
                            self.collectionView.setNeedsLayout()
                            // cell.alpha = 1
                            self.originalIndexPath = nil
                            self.draggingView = nil
                            
                        })
                        
//                        UIView.animate(withDuration: 0.25, animations: {
//                            self.draggingView!.center = cell.center
//                            self.draggingView!.transform = CGAffineTransform.identity
//                            self.draggingView!.alpha = 0.0
//                            //self.draggingView!.
//                            cell.alpha = 1
//                            cell.isHidden = false
//                        }) { (Bool) in
//                            self.draggingView?.removeFromSuperview()
//                            self.collectionView.layoutIfNeeded()
//                            self.collectionView.setNeedsLayout()
//                            // cell.alpha = 1
//                            self.originalIndexPath = nil
//                            self.draggingView = nil
//                        }
//                        
                    }
                    
                    
                }
                
                
                
            }
            
        }else{
            
            self.changeToIdentiPosition()
            lineView.removeFromSuperview()
            self.swapView?.removeFromSuperview()

            
            let pIndexPath = self.collectionView.indexPathForItem(at: CGPoint(x: location.x - 6, y: location.y))
            let nIndexPath = self.collectionView.indexPathForItem(at: CGPoint(x: location.x + 6, y: location.y))
            let uIndexPath = self.collectionView.indexPathForItem(at: CGPoint(x: location.x, y: location.y - 6))
            let lIndexPath = self.collectionView.indexPathForItem(at: CGPoint(x: location.x, y: location.y + 6))
            // guard let indexPath = vc.indexPathForItem(at: location)else{  return }
            let dict = self.collectionArray[originalIndexPath.item]
            let type  =  dict["type"] as! String

            
            if var pIndexPath = pIndexPath,var nIndexPath = nIndexPath,type != "Text"{
                
                let dict = self.collectionArray[(originalIndexPath.item)]
                if let type  =  dict["type"] as? String{
                    if type != "Text"{
                        print("Insert in between two cells in the same row taken as horizontally gesture")
                        self.insertNewCellAtPoint(location: dragView.center, withSourceIndexPathwithSourceIndexPath: originalIndexPath, forSnapshot: dragView.frame)
                        let sourceCell = vc.cellForItem(at: originalIndexPath)
                        sourceCell?.isHidden = false
                        sourceCell?.alpha = 1
                     
                        dragView.removeFromSuperview()
                        
                        
                        
                        
                    }
                }
                
                
            }else if var uIndexPath = uIndexPath,var lIndexPath = lIndexPath{
             //   let dict = self.collectionArray[(originalIndexPath.item)]
                
                        
                        print("Insert in between two cells in the same row taken as vertically gesture")
                        self.insertNewCellAtPoint(location: dragView.center, withSourceIndexPathwithSourceIndexPath: originalIndexPath, forSnapshot: dragView.frame)
                        let sourceCell = vc.cellForItem(at: originalIndexPath)
                        sourceCell?.isHidden = false
                        sourceCell?.alpha = 1
                     //   originalIndexPath = nil
                        //sourceCell?.removeFromSuperview()
                        //sourceCell.hidden = NO;
                        //sourceIndexPath = nil;
                        dragView.removeFromSuperview()
                        
                        
                        
                        
                
            }else if var uIndexPath = uIndexPath, lIndexPath  == nil{
                print("insert at the bottom of collection view gesture")
                self.insertNewCellAtPoint(location: dragView.center, withSourceIndexPathwithSourceIndexPath: originalIndexPath, forSnapshot: dragView.frame)
                let sourceCell = vc.cellForItem(at: originalIndexPath)
                sourceCell?.isHidden = false
                sourceCell?.alpha  = 1
                //originalIndexPath = nil
                //sourceCell?.removeFromSuperview()
                //sourceCell.hidden = NO;
                //sourceIndexPath = nil;
                dragView.removeFromSuperview()
                
            }
            else if var lIndexPath = lIndexPath, uIndexPath == nil{
                
                print("insert at the top of collection view gesture")
                self.insertNewCellAtPoint(location: dragView.center, withSourceIndexPathwithSourceIndexPath: originalIndexPath, forSnapshot: dragView.frame)
                let sourceCell = vc.cellForItem(at: originalIndexPath)
                sourceCell?.isHidden = false
                sourceCell?.alpha = 1
              //  originalIndexPath = nil
                dragView.removeFromSuperview()
                
                
            }else{
                self.lineView.removeFromSuperview()
                guard var frameOfDraging = self.frameOfDragingIndexPath else { return }
                guard let  sourceCell = self.collectionView.cellForItem(at:originalIndexPath)else { return }
                    UIView.animate(withDuration: 0.25, animations: {
                        dragView.center = frameOfDraging
                        dragView.transform = CGAffineTransform.identity
                        dragView.alpha = 0.0;
                        sourceCell.alpha = 1.0;
                    }, completion: { (flag) in
                        sourceCell.isHidden = false
                        self.originalIndexPath = nil
                        dragView.removeFromSuperview()
                    })
                
                
    
            }
            
        }
     
    }
    
    func exchangeDataSource(sourceIndex:Int,destIndex:Int)  {
        
        var temp = self.collectionArray[sourceIndex]
        self.collectionArray[sourceIndex] = self.collectionArray[destIndex]
        self.collectionArray[destIndex] = temp
}
    
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    //MARK: - showImagePicker
    func showImagePicker() {
        // self.enableGaleery()
        let pickerController = DKImagePickerController()
        //pickerController.assetType =
        pickerController.allowMultipleTypes = true
        pickerController.autoDownloadWhenAssetIsInCloud = true
        pickerController.showsCancelButton = true
        
        self.present(pickerController, animated: true) {}
        
        pickerController.didSelectAssets = { [unowned self] (assets: [DKAsset]) in
            print("didSelectAssets")
            self.startAnimation()
            
            self.requestOptions.resizeMode = .exact
            self.requestOptions.deliveryMode = .highQualityFormat
            self.requestOptions.isSynchronous = false
            self.requestOptions.isNetworkAccessAllowed = true
            let manager: PHImageManager = PHImageManager.default()
            var assetsOriginal  = [PHAsset]()
            for dKasset :DKAsset in assets{
                assetsOriginal.append(dKasset.originalAsset!)
            }
            
            var newItemsArray = [[AnyHashable:Any]]()
            
            
            
            
            DispatchQueue.global(qos: .background).async {
                
                
                for asset: PHAsset in assetsOriginal {
                    
                    if asset.mediaType == .video {
                        self.requestOptionsVideo.deliveryMode = .highQualityFormat
                        self.requestOptionsVideo.isNetworkAccessAllowed = true
                        
                        manager.requestAVAsset(forVideo: asset, options:  self.requestOptionsVideo, resultHandler: { (assert:AVAsset?, audio:AVAudioMix?, info:[AnyHashable : Any]?) in
                            
                            let UrlLocal: URL = ((assert as? AVURLAsset)?.url)!
                            let videoData = NSData(contentsOf: UrlLocal)
                            guard let track = AVAsset(url: UrlLocal).tracks(withMediaType: AVMediaTypeVideo).first else { return  }
                            
                            // var tracks = ass.tracks(withMediaType: "AVMediaTypeVideo").first
                          //  let track = tracks
                            let trackDimensions = track.naturalSize
                            let length = (videoData?.length)! / 1000000
                            
                            var dictToAdd = Dictionary<AnyHashable, Any>()
                            dictToAdd.updateValue(UrlLocal, forKey: "item_url")
                            dictToAdd.updateValue("", forKey: "cover")
                            dictToAdd.updateValue("#322e20,#d3d5db,#97989d,#aeb2b9,#858176", forKey: "hexCode")
                            
                            dictToAdd.updateValue(NSStringFromCGSize(trackDimensions), forKey: "item_size")
                            dictToAdd.updateValue(videoData, forKey: "data")
                            dictToAdd.updateValue(UrlLocal, forKey: "item_url")
                            dictToAdd.updateValue("video", forKey: "type")
                            newItemsArray.append(dictToAdd)
                            if assetsOriginal.count == newItemsArray.count{
                                if(self.localPartition.count > 0){
                                self.defaults.set(newItemsArray.count, forKey: "addedMorePhotos")
                                }
                                
                                var uploadViewController = self.storyboard?.instantiateViewController(withIdentifier: "ImagesUploadViewController") as! ImagesUploadViewController
                                uploadViewController.uploadData = newItemsArray
                                uploadViewController.storyId = String(self.randomNumber())
                                
                                uploadViewController.dismissView = {(sender : UIViewController?,initialize:Bool?,newObjects:[[AnyHashable:Any]]?) -> Void in
                                    
                                    
                                    if self.collectionArray.count > 0{
                                        self.defaults.set(true, forKey: "deletedAllItems")
                                        
                                    }else{

                                            self.defaults.set(false, forKey: "deletedAllItems")
                                            


                                    }

                                    
                                    if self.localPartition.count > 0{
                                        if !(initialize!){
                                            self.scrollToPostionAfterUpload = self.collectionArray.count - 1
                                         self.collectionArray.append(contentsOf: newObjects!)
                                            self.upload = true
                                            runOnMainThread {
                                                
                                                if let local = self.defaults.object(forKey: "partition") as? Array<Array<Array<String>>>{
                                                    self.localPartition = local
                                                }
                                                
                                                self.reloadHeaderView = true

                                                self.collectionView.reloadData()
                                                self.collectionView.collectionViewLayout.invalidateLayout()
                                                
                                                self.getPhotobyupload()
                                                
                                                self.stopAnimationLoader()
                                                self.turnOnEditMode()
                                                                                           }
                                            
                                        }
                                    }else{
                                        self.collectionArray = newObjects!
                                        self.scrollToPostionAfterUpload = 0
                                        runOnMainThread {
                                            self.reloadHeaderView = true
                                            let temp = self.collectionArray[0]
                                            var sizeOrg = temp["cloudFilePath"] as? String
                                              sizeOrg = URLConstants.imgDomain  + sizeOrg!
                                            self.story_cover_photo_path = sizeOrg!
                                            self.getDataFromUrl(url: URL(string: sizeOrg!)!) { (data, response, error)  in
                                                guard let data = data, error == nil else { return }
                                                
                                                self.coverdata = UIImage(data: data)
                                                
                                                DispatchQueue.main.async() { () -> Void in
                                                    self.longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(self.handleLongPress))
                                                    self.collectionView.addGestureRecognizer(self.longPressGesture!)
                                                    self.swapView = UIView(frame: CGRect.zero)
                                                    self.swapImageView = UIImageView(image: UIImage(named: "Swap-white"))
                                                    
                                                    
                                                    self.view.addSubview(self.collectionView)
                                                    self.collectionView.reloadData()
                                                    self.collectionView.collectionViewLayout.invalidateLayout()
                                                    self.upload = true
                                                    
                                                   self.getPhotobyupload()
                                                    
                                                    self.stopAnimationLoader()
                                                    self.turnOnEditMode()
                                                    //defaults.set(localPartition, forKey: "partition")
                                                    if let local = self.defaults.object(forKey: "partition") as? Array<Array<Array<String>>>{
                                                    self.localPartition = local
                                                    }
                                                 
                                                }
                                            }
                                            
                                            
                                            
                                            
                                            //let viewController = ViewController(collectionViewLayout: layout)
                                            //      self.getPhoto()
                                            
                                        }
                                    }
                                    
                                  //  if let deletedAllItems =  self.defaults.object(forKey: "deletedAllItems") as? Bool{
                                    
                                        
                                   // }
                                    
                                    
                                    
                                    
                                }

                                self.present(uploadViewController, animated: true, completion: {
                                    self.stopAnimationLoader()
                                })
                                
                                
                                //picker.presentingViewController!.dismiss(animated: true, completion: { _ in })
                                
                            }
                            
                        })
                        
                    }else{
                        
                        manager.requestImageData(for: asset, options: self.requestOptions, resultHandler: { (data: Data?, identificador: String?, orientaciomImage: UIImageOrientation, info: [AnyHashable: Any]?) in
                            // print(info)
                            var dictToAdd = Dictionary<AnyHashable, Any>()
                            let compressedImage = UIImage(data: data!)
                            // self.images.append(compressedImage!)
                            let urlString =  "\(((((info as! Dictionary<String,Any>)["PHImageFileURLKey"])! as! URL)))"
                            dictToAdd.updateValue(urlString, forKey: "cloudFilePath")
                            dictToAdd.updateValue(0, forKey: "cover")
                            dictToAdd.updateValue(urlString, forKey: "filePath")
                            dictToAdd.updateValue("#322e20,#d3d5db,#97989d,#aeb2b9,#858176", forKey: "hexCode")
                           // dictToAdd.updateValue("#322e20,#d3d5db,#97989d,#aeb2b9,#858176" as AnyObject, forKey: "hexCode")
                            let sizeImage = compressedImage?.size
                            dictToAdd.updateValue(sizeImage, forKey: "item_size")
                            dictToAdd.updateValue(urlString, forKey: "item_url")
                            dictToAdd.updateValue(data, forKey: "data")
                            dictToAdd.updateValue(sizeImage, forKey: "original_size")
                            dictToAdd.updateValue("img", forKey: "type")
                            newItemsArray.append(dictToAdd)
                            
                            if assetsOriginal.count == newItemsArray.count{
                               
                                if(self.localPartition.count > 0){
                                    self.defaults.set(newItemsArray.count, forKey: "addedMorePhotos")
                                }
                                
                                var uploadViewController = self.storyboard?.instantiateViewController(withIdentifier: "ImagesUploadViewController") as! ImagesUploadViewController
                                uploadViewController.uploadData = newItemsArray
                                uploadViewController.storyId = String(self.randomNumber())
                              //let addHomes = self.storyboard?.instantiateViewController(withIdentifier: "AddHomesVC") as! AddHomesVC
                             //   var uploadViewController = ImagesUploadViewController(with: self.collectionArray, storyId: "5678")
                                
                                uploadViewController.dismissView = {(sender : UIViewController?,initialize:Bool?,newObjects:[[AnyHashable:Any]]?) -> Void in
                                    
                                    if self.collectionArray.count > 0{
                                        self.defaults.set(true, forKey: "deletedAllItems")
                                        
                                    }else{

                                            self.defaults.set(false, forKey: "deletedAllItems")
                                            


                                    }

                                    
                                    if self.localPartition.count > 0{
                                        if !(initialize!){
                                            self.scrollToPostionAfterUpload = self.collectionArray.count - 1
                                            self.collectionArray.append(contentsOf: newObjects!)
                                            self.upload = true
                                            runOnMainThread {
                                                if let local = self.defaults.object(forKey: "partition") as? Array<Array<Array<String>>>{
                                                    self.localPartition = local
                                                }
                                                self.reloadHeaderView = true
                                                self.collectionView.reloadData()
                                                self.collectionView.collectionViewLayout.invalidateLayout()
                                                
                                                self.getPhotobyupload()
                                                
                                                self.stopAnimationLoader()
                                                self.turnOnEditMode()
                                                
                                                
                                            }

                                            
                                        }
                                    }else{
                                        self.collectionArray = newObjects!
                                        self.scrollToPostionAfterUpload = 0
                                        runOnMainThread {
                                            self.reloadHeaderView = true
                                            let temp = self.collectionArray[0]
                                            var sizeOrg = temp["cloudFilePath"] as? String
                                            
                                             sizeOrg = URLConstants.imgDomain  + sizeOrg!
                                            self.story_cover_photo_path = sizeOrg!
                                            self.getDataFromUrl(url: URL(string: sizeOrg!)!) { (data, response, error)  in
                                                guard let data = data, error == nil else { return }
                                                
                                                self.coverdata = UIImage(data: data)
                                                
                                                DispatchQueue.main.async() { () -> Void in
                                                    self.longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(self.handleLongPress))
                                                    self.collectionView.addGestureRecognizer(self.longPressGesture!)
                                                    self.swapView = UIView(frame: CGRect.zero)
                                                    self.swapImageView = UIImageView(image: UIImage(named: "Swap-white"))
                                                    self.view.addSubview(self.collectionView)
                                                    self.collectionView.reloadData()
                                                    self.collectionView.collectionViewLayout.invalidateLayout()
                                                    self.upload = true
                                                    
                                                    self.getPhotobyupload()
                                                    self.stopAnimationLoader()
                                                    self.turnOnEditMode()
                                                    if let local = self.defaults.object(forKey: "partition") as? Array<Array<Array<String>>>{
                                                        self.localPartition = local
                                                    }
                                                    
                                                }
                                            }

                                            
                                            
                                        }                                    }
                                    
                                    
                                    
                                }
                                
                                
                                self.navigationController?.present(uploadViewController, animated: true, completion: {
                                     self.stopAnimationLoader()
                                    
                                })
                                


                                
                                //   picker.presentingViewController!.dismiss(animated: true, completion: { _ in })
                                
                            }
                            
                        })
                        
                        
                    }
                }
                
            }
}
        
        
    }
    
    func getDataFromUrl(url: URL, completion: @escaping (_ data: Data?, _  response: URLResponse?, _ error: Error?) -> Void) {
        URLSession.shared.dataTask(with: url) {
            (data, response, error) in
            completion(data, response, error)
            }.resume()
    }
    
     func IbaOpenGallery() {
        
        
        let status = PHPhotoLibrary.authorizationStatus()
        switch status {
        case .authorized:
            runOnMainThread {
                self.showImagePicker()
            }
            defaults.set(true, forKey: "forStoryMaking")
            break
            
        case .denied, .restricted : break
            
        //handle denied status
        case .notDetermined:
            // ask for permissions
            PHPhotoLibrary.requestAuthorization() { (status) -> Void in
                switch status {
                case .authorized:
                    runOnMainThread {
                    self.showImagePicker()
                    }
                    
                self.defaults.set(true, forKey: "forStoryMaking")

                    
                // as above
                case .denied, .restricted: break
                    
                // as above
                case .notDetermined: break
                    // won't happen but still
                }
            }
        }
        
        
        
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func selectPhotoFromPhotoLibrary() {
        
    }
    
    func shouldSetImageOnIndex(photoIndex: Int) -> Bool {
        return photoIndex != CustomEverythingPhotoIndex && photoIndex != DefaultLoadingSpinnerPhotoIndex
    }
    
    func getPhoto() {
        
        
        var totalPath = URLConstants.imgDomain
        
        for photoIndex in 0 ..< self.collectionArray.count {
            let temp = collectionArray[photoIndex]
            
            
            if let type = temp["type"] as? String{
                
                
                if type == "Text"{
                    
                    
                    let textFrame = CGRect(x: 0, y: 0, width: SCREENWIDTH, height: SCREENHEIGHT)
                    let textImageView = UIView(frame: textFrame)
                    textImageView.backgroundColor = UIColor.blue
                    
                    let title = temp["title"] as? String ?? ""
                    let subTitle = temp["description"] as? String ?? ""
                    let titleFont = UIFont(name: "Raleway-Regular", size: 18.0)
                    
                    let titleLabel = UILabel.init()
                    titleLabel.text = title
                    titleLabel.textColor = UIColor(hexString:temp["textColor"] as! String)
                    titleLabel.numberOfLines = 0
                    titleLabel.font = titleFont
                    titleLabel.textAlignment = .center
                    //                CGFloat titleHeight = [self getHeightForText:title withFont:titleFont andWidth:SCREENWIDTH - 20];
                    //                CGRect titleFrame = CGRectMake(10.0, 40.0, SCREENWIDTH - 20, 100);
                    //                titleLabel.frame = titleFrame;
                    //                [textImageView addSubview:titleLabel];
                    
                    let titleHeight =  title.height(withConstrainedWidth: SCREENWIDTH - 20, font: titleFont!)
                    let titleFrame = CGRect(x: 10, y: 40, width: SCREENWIDTH - 20, height: 100)
                    titleLabel.frame = titleFrame
                    textImageView.addSubview(titleLabel)
                    let descriptionLabel = UILabel.init()
                    descriptionLabel.text = title
                    descriptionLabel.textColor = UIColor(hexString:temp["textColor"] as! String)
                    descriptionLabel.numberOfLines = 0
                    descriptionLabel.font = titleFont
                    descriptionLabel.textAlignment = .center
                    //                CGFloat titleHeight = [self getHeightForText:title withFont:titleFont andWidth:SCREENWIDTH - 20];
                    //                CGRect titleFrame = CGRectMake(10.0, 40.0, SCREENWIDTH - 20, 100);
                    //                titleLabel.frame = titleFrame;
                    //                [textImageView addSubview:titleLabel];
                    
                    let titledescriptionHeight =  subTitle.height(withConstrainedWidth: SCREENWIDTH - 20, font: titleFont!)
                    let titledescriptionFrame = CGRect(x: 10, y: titleHeight + 80, width: SCREENWIDTH - 20, height: titledescriptionHeight)
                    descriptionLabel.frame = titledescriptionFrame
                    textImageView.addSubview(descriptionLabel)
                    
                    let imageView = UIImage(view: textImageView)
                    
                    
                    
                    
                    let Ptitle = NSAttributedString(string: "\(photoIndex + 1)", attributes: [NSForegroundColorAttributeName: UIColor.white])
                    
                    let photo = shouldSetImageOnIndex(photoIndex: photoIndex) ? ExamplePhoto(image: imageView, attributedCaptionTitle: Ptitle) : ExamplePhoto(attributedCaptionTitle: Ptitle)
                    
                    if photoIndex == CustomEverythingPhotoIndex {
                        photo.placeholderImage = UIImage(named: PlaceholderImageName)
                    }
                    photo.video = false
                    
                    mutablePhotos.append(photo)
                    
                    
                    
                    
                }else{
                    
                    
                    var url = temp["item_url"] as! String
                    //if url.contains("http"){
                    //   totalPath = url
                    
                    
                    if type == "img"{
                        
                        var urlImage = url.components(separatedBy: "album")
                        
                        if urlImage.count == 2 {
                            var second = urlImage[1]
                            second.remove(at: second.startIndex)
                            url = totalPath + second
                        }else{
                            let first = urlImage[0]
                            url = totalPath + first
                            
                        }
                        
                        var version = url.components(separatedBy: "compressed")
                        
                        var afterAppending  = url.components(separatedBy: "compressed")
                        var widthImage = (version[0]) + "480" + (afterAppending[1])
                        
                        
                        
                        // totalPath = URLConstants.imgDomain + widthImage
                        
                        
                        let data = NSData.init(contentsOf: URL(string: widthImage)!)
                        let imageView = UIImage(data: data as! Data)
                        let title = NSAttributedString(string: "\(photoIndex + 1)", attributes: [NSForegroundColorAttributeName: UIColor.white])
                        
                        let photo = shouldSetImageOnIndex(photoIndex: photoIndex) ? ExamplePhoto(image: imageView, attributedCaptionTitle: title) : ExamplePhoto(attributedCaptionTitle: title)
                        
                        if photoIndex == CustomEverythingPhotoIndex {
                            photo.placeholderImage = UIImage(named: PlaceholderImageName)
                        }
                        photo.video = false
                        mutablePhotos.append(photo)
                        
                        
                        
                    }else if type == "video"{
                        if  let image  = thumbnailImageForFileUrl(URL(string: url)!){
                            
                            if    let data = UIImagePNGRepresentation(image){
                                
                                //  let data = NSData.init(contentsOf: URL(string: totalPath)!)
                                let imageView = UIImage(data: data as! Data)
                                let title = NSAttributedString(string: "\(photoIndex + 1)", attributes: [NSForegroundColorAttributeName: UIColor.white])
                                
                                let photo = shouldSetImageOnIndex(photoIndex: photoIndex) ? ExamplePhoto(image: imageView, attributedCaptionTitle: title,videoUrl: URL(string: url)!,video:true) : ExamplePhoto(attributedCaptionTitle: title)
                                
                                if photoIndex == CustomEverythingPhotoIndex {
                                    photo.placeholderImage = UIImage(named: PlaceholderImageName)
                                }
                                
                                photo.videoUrl = URL(string: url)!
                                photo.video = true
                                mutablePhotos.append(photo)
                                
                            }
                            
                        }
                        
                        
                        
                    }
                }
                
                
                
                
            }else{
                
                var url = temp["item_url"] as? String
                if url != ""{
                    var urlImage = url?.components(separatedBy: "album")
                    var totalPath = URLConstants.imgDomain
                    url = totalPath + (urlImage?[1])!
                    var version = url?.components(separatedBy: "compressed")
                    
                    var afterAppending  = url?.components(separatedBy: "compressed")
                    var widthImage = (version?[0])! + "480" + (afterAppending?[1])!
                    
                    
                    // let sizeOrg = (temp as AnyObject).object(forKey: "data") as? Data
                    
                    let data = NSData.init(contentsOf: URL(string: widthImage)!)
                    let imageView = UIImage(data: data as! Data)
                    
                    //let image = images[photoIndex]
                    let title = NSAttributedString(string: "\(photoIndex + 1)", attributes: [NSForegroundColorAttributeName: UIColor.white])
                    
                    let photo = shouldSetImageOnIndex(photoIndex: photoIndex) ? ExamplePhoto(image: imageView, attributedCaptionTitle: title) : ExamplePhoto(attributedCaptionTitle: title)
                    
                    if photoIndex == CustomEverythingPhotoIndex {
                        photo.placeholderImage = UIImage(named: PlaceholderImageName)
                    }
                    
                    mutablePhotos.append(photo)
                }
                
            }
            

        }
        
    }
    
    func getPhotobyupload() {
        
        
        
        for photoIndex in 0 ..< self.collectionArray.count {
            let temp = collectionArray[photoIndex]
            var totalPath = URLConstants.imgDomain
            let type  =  temp["type"] as! String
            if type == "Text"{
                
                
                let textFrame = CGRect(x: 0, y: 0, width: SCREENWIDTH, height: SCREENHEIGHT)
                let textImageView = UIView(frame: textFrame)
                textImageView.backgroundColor = UIColor.blue
                
                let title = temp["title"] as! String
                let subTitle = temp["description"] as! String
                let titleFont = UIFont(name: "Raleway-Regular", size: 18.0)
                
                let titleLabel = UILabel.init()
                titleLabel.text = title
                titleLabel.textColor = UIColor(hexString:temp["textColor"] as! String)
                titleLabel.numberOfLines = 0
                titleLabel.font = titleFont
                titleLabel.textAlignment = .center
//                CGFloat titleHeight = [self getHeightForText:title withFont:titleFont andWidth:SCREENWIDTH - 20];
//                CGRect titleFrame = CGRectMake(10.0, 40.0, SCREENWIDTH - 20, 100);
//                titleLabel.frame = titleFrame;
//                [textImageView addSubview:titleLabel];
                
                let titleHeight =  title.height(withConstrainedWidth: SCREENWIDTH - 20, font: titleFont!)
                let titleFrame = CGRect(x: 10, y: 40, width: SCREENWIDTH - 20, height: 100)
                titleLabel.frame = titleFrame
                textImageView.addSubview(titleLabel)
                

                
                
                let descriptionLabel = UILabel.init()
                descriptionLabel.text = title
                descriptionLabel.textColor = UIColor(hexString:temp["textColor"] as! String)
                descriptionLabel.numberOfLines = 0
                descriptionLabel.font = titleFont
                descriptionLabel.textAlignment = .center
                //                CGFloat titleHeight = [self getHeightForText:title withFont:titleFont andWidth:SCREENWIDTH - 20];
                //                CGRect titleFrame = CGRectMake(10.0, 40.0, SCREENWIDTH - 20, 100);
                //                titleLabel.frame = titleFrame;
                //                [textImageView addSubview:titleLabel];
                
                let titledescriptionHeight =  subTitle.height(withConstrainedWidth: SCREENWIDTH - 20, font: titleFont!)
                let titledescriptionFrame = CGRect(x: 10, y: titleHeight + 80, width: SCREENWIDTH - 20, height: titledescriptionHeight)
                descriptionLabel.frame = titledescriptionFrame
                textImageView.addSubview(descriptionLabel)
                
                let imageView = UIImage(view: textImageView)
                
                
                
                
                let Ptitle = NSAttributedString(string: "\(photoIndex + 1)", attributes: [NSForegroundColorAttributeName: UIColor.white])
                
                let photo = shouldSetImageOnIndex(photoIndex: photoIndex) ? ExamplePhoto(image: imageView, attributedCaptionTitle: Ptitle) : ExamplePhoto(attributedCaptionTitle: Ptitle)
                
                if photoIndex == CustomEverythingPhotoIndex {
                    photo.placeholderImage = UIImage(named: PlaceholderImageName)
                }
                photo.video = false
                
                mutablePhotos.append(photo)
                
                
                
                
            }else{
                
            
            var url = temp["item_url"] as! String
            //if url.contains("http"){
              //   totalPath = url
            
            
            if type == "img"{
                
                var urlImage = url.components(separatedBy: "album")
                
                if urlImage.count == 2 {
                    var second = urlImage[1]
                    second.remove(at: second.startIndex)
                    url = totalPath + second
                }else{
                    let first = urlImage[0]
                    url = totalPath + first
                    
                }
              
                var version = url.components(separatedBy: "compressed")
                
                var afterAppending  = url.components(separatedBy: "compressed")
                var widthImage = (version[0]) + "480" + (afterAppending[1])
                
                
                
               // totalPath = URLConstants.imgDomain + widthImage
                
                
                let data = NSData.init(contentsOf: URL(string: widthImage)!)
                let imageView = UIImage(data: data as! Data)
                let title = NSAttributedString(string: "\(photoIndex + 1)", attributes: [NSForegroundColorAttributeName: UIColor.white])
                
                let photo = shouldSetImageOnIndex(photoIndex: photoIndex) ? ExamplePhoto(image: imageView, attributedCaptionTitle: title) : ExamplePhoto(attributedCaptionTitle: title)
                
                if photoIndex == CustomEverythingPhotoIndex {
                    photo.placeholderImage = UIImage(named: PlaceholderImageName)
                }
                photo.video = false
                mutablePhotos.append(photo)


                
            }else if type == "video"{
                if  let image  = thumbnailImageForFileUrl(URL(string: url)!){
                    
                    if    let data = UIImagePNGRepresentation(image){
                    
                //  let data = NSData.init(contentsOf: URL(string: totalPath)!)
                    let imageView = UIImage(data: data as! Data)
                        let title = NSAttributedString(string: "\(photoIndex + 1)", attributes: [NSForegroundColorAttributeName: UIColor.white])
                        
                        let photo = shouldSetImageOnIndex(photoIndex: photoIndex) ? ExamplePhoto(image: imageView, attributedCaptionTitle: title,videoUrl: URL(string: url)!,video:true) : ExamplePhoto(attributedCaptionTitle: title)
                        
                        if photoIndex == CustomEverythingPhotoIndex {
                            photo.placeholderImage = UIImage(named: PlaceholderImageName)
                        }
                        
                        photo.videoUrl = URL(string: url)!
                        photo.video = true
                        mutablePhotos.append(photo)

                    }

                }
                
                
                
            }
        }
        
                                 }
    }
    
    
     func thumbnailImageForFileUrl(_ fileUrl: URL) -> UIImage? {
        
        
        if let cachedVersion = cache.object(forKey: "\(fileUrl)" as NSString) {
        
            return cachedVersion
            
        }else{
            let asset = AVAsset(url: fileUrl)
            let imageGenerator = AVAssetImageGenerator(asset: asset)
            imageGenerator.appliesPreferredTrackTransform = true
            let durationSeconds = CMTimeGetSeconds(asset.duration)
            
            do {
                
                
                
                let thumbnailCGImage = try imageGenerator.copyCGImage(at: CMTimeMake(Int64(durationSeconds/1.0), 600), actualTime: nil)
                let images = UIImage(cgImage: thumbnailCGImage)
                cache.setObject(images, forKey: "\(fileUrl)" as NSString)
                
                return images
                
            } catch let err {
                print(err)
            }
}
    return nil
    }
}

extension ViewController:UICollectionViewDelegate,UICollectionViewDataSource,NYTPhotosViewControllerDelegate
{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return self.collectionArray.count
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // UNDO This Comments
        
        
        if editTurnOn{
            let previouslySelectedItem = selectedItemIndex
            
            if editingTextFieldIndex == -1{
                if(selectedItemIndex == indexPath.item){
                    self.setInitialToolbarConfiguration()
                    //[self setInitialToolbarConfiguration];
                   selectedItemIndex = -1
                    self.title = ""
                }else{
                    selectedItemIndex = indexPath.item
                    let temp = collectionArray[indexPath.row]
                    let type  =  temp["type"] as! String
                    
                    if type == "Text"{
                        self.editToolbarConfigurationForTextCells()
                        self.title = "Text"
                    }
                    else{
                        
                       self.changeToEnrichMode()
                        
                    }
        }
                    var indexPathsToReload = [IndexPath]()
                    if previouslySelectedItem != -1{
                        indexPathsToReload.append(IndexPath(item: previouslySelectedItem, section: 0))
                        
                    }
                    if self.selectedItemIndex != -1{
                        indexPathsToReload.append(IndexPath(item: self.selectedItemIndex, section: 0))
                        
                    }
                    
                DispatchQueue.main.async {
                    
                    self.collectionView.performBatchUpdates({
                        print(indexPathsToReload)
                        self.collectionView.reloadItems(at: indexPathsToReload)
                    }, completion: { (test) in
                        
                    })
                  
                }
            }
            
        }else{
            
            selectedIndexPath = indexPath.item
            let photosViewController = NYTPhotosViewController(photos: mutablePhotos)
            let temp = collectionArray[indexPath.row]
            let type  =  temp["type"] as! String
            
            if type == "Text"{
                
                guard let  textCell = self.collectionView.cellForItem(at: indexPath) as? TextCellStoryCollectionViewCell else{
                    return
                }
                
                
                let screenshotOfTextCell = UIImage(view: textCell)
                
                
                
                
            }else if type == "video"{
                
                guard let  VideoCell = self.collectionView.cellForItem(at: indexPath) as? ImageViewCollectionViewCell else{
                    return
                }
                
                if (VideoCell.player.rate == 0)  && (VideoCell.player.error == nil){
                    VideoCell.player.pause()
                }else{
                    VideoCell.player.play()
                }
                
                
                
                
            }else{
                
                
                photosViewController.display(mutablePhotos[indexPath.row], animated: true)
                photosViewController.delegate = self
                self.present(photosViewController, animated: true, completion: nil)
                
            }
            
            
            
        }
        
        
        
        
    }
    
    
    
    func photosViewController(_ photosViewController: NYTPhotosViewController, referenceViewFor photo: NYTPhoto) -> UIView? {
        
        guard let cell = collectionView.cellForItem(at: IndexPath(item: selectedIndexPath, section: 0))else {return nil}
        return cell.contentView
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var size = CGSize.zero
        let temp = collectionArray[indexPath.row]
        let type  =  temp["type"] as! String
        if isViewStory {
            
            if type == "Text"{
                let sizeOrg = temp["item_size"] as? String
                var cgsize  = CGSizeFromString(sizeOrg!)
                size = cgsize
                
            }else{
                let sizeOrg = temp["item_size"] as? CGSize
                size = sizeOrg!
            }
            
        }else{
            
            if type == "video"{
                let sizeOrg = temp["item_size"] as? CGSize
                var cgsize  = sizeOrg!
                size = cgsize
            }else if type == "Text"{
                let sizeOrg = temp["item_size"] as? String
                size = CGSizeFromString(sizeOrg!)
                
            }else{
                size = imageForIndexPath(indexPath)
            }
            
        }
        
        // let percentWidth = CGFloat(UInt32(140) - arc4random_uniform(UInt32(80)))/100
        return size //CGSize(width: size.width*percentWidth/4, height: size.height/4)
    }
    
    
    func imageForIndexPath(_ indexPath:IndexPath) -> CGSize {
        //return images[indexPath.item%images.count]
        
        let temp = collectionArray[indexPath.row]
        let sizeOrg = temp["item_size"] as? CGSize
        
        return sizeOrg!
    }
    
    func getDataFromUrl(urL:URL, completion: @escaping ((_ data: NSData?) -> Void)) {
        URLSession.shared.dataTask(with: urL) { (data, response, error) in
            completion(data as NSData?)
            }.resume()
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        let temp = collectionArray[indexPath.row]
        let type  =  temp["type"] as! String
        
        if isViewStory {
            
            if type == "Text"{
                if let cell = cell as? TextCellStoryCollectionViewCell{
                    
                    if selectedItemIndex == indexPath.item{
                        
                        cell.layer.borderWidth = 2
                        
                        cell.layer.borderColor = UIColor(hexString:"#32C5B6").cgColor
                    }
                    
                    
                    cell.alpha = 1
                    cell.isHidden = false
                    cell.titleLabel.isUserInteractionEnabled = false
                    cell.subTitleLabel.isUserInteractionEnabled = false
                    cell.layer.borderWidth = CGFloat.leastNormalMagnitude
                    cell.layer.borderColor = UIColor.clear.cgColor
                    if let title = temp["title"] as? String{
                    cell.titleLabel.text = title
                    }else{
                        
                    }
                    if let subTitleLabel = temp["description"] as? String{
                    cell.subTitleLabel.text = subTitleLabel
                    }else{
                        
                    }
                    
                    //cell.subTitleLabel.textColor =
                    if let allign = temp["textAlignment"] as? Int{
                        if allign == 1{
                            cell.titleLabel.textAlignment = .center
                            cell.subTitleLabel.textAlignment = .center
                        }else{
                            cell.titleLabel.textAlignment = .left
                            cell.subTitleLabel.textAlignment = .left
                        }
                    }
                    
                    //cell.titleLabel.inputAccessoryView = self.keyboardView
                    //cell.subTitleLabel.inputAccessoryView = self.keyboardView
                    if let textColor = temp["textColor"] as? String
                    {
                        cell.titleLabel.textColor = UIColor(hexString:textColor)
                    }else{
                        
                    }
                    
                    if let backgroundColor = temp["backgroundColor"] as? String
                    {
                        cell.myView.backgroundColor = UIColor(hexString:backgroundColor)
                    }else{
                        
                    }
                    
                    
                    
                    
                    
                }
            }else{
                if let imageViewCell = cell as? ImageViewCollectionViewCell{
                    
                   
//                        imageViewCell.layer.borderWidth = CGFloat.leastNormalMagnitude
//                        imageViewCell.layer.borderColor = UIColor.clear.cgColor
//                        imageViewCell.videoAsSubView.isHidden = false
//                        imageViewCell.volumeBtn.isHidden = false
//                        imageViewCell.player.isMuted = false
//                        imageViewCell.player.play()
//                        // imageViewCell.fullScreenBtn.isHidden = false
//                        
                        
                        
                        if type == "video"{
                            imageViewCell.layer.borderWidth = CGFloat.leastNormalMagnitude
                            imageViewCell.layer.borderColor = UIColor.clear.cgColor
                            imageViewCell.videoAsSubView.isHidden = false
                            imageViewCell.volumeBtn.isHidden = false
                            //imageViewCell.fullScreenBtn.isHidden = false
                            if let player_layer  =  temp["player_layer"] as? AVPlayerLayer{
                                let layer  =  temp["player"] as! AVPlayer
                                
                                if let isLayerPresent = (imageViewCell.videoAsSubView.layer.sublayers?.contains(player_layer)){
                                    
                                    if !isLayerPresent{
                                        //cell.iboVideoView.layer.sublayers = nil
                                        //self.singleTap.cancelsTouchesInView = false
                                        //  imageViewCell.iboVideoView.addGestureRecognizer(doubleTapVideo)
                                        //imageViewCell.iboVideoView.addGestureRecognizer(singleTapvideo)
                                        //singleTapvideo.require(toFail: doubleTapVideo)
                                        imageViewCell.videoAsSubView.layer.addSublayer(player_layer)
                                        imageViewCell.player = layer
                                        //imageViewCell.playerItm = temp.playerItm
                                        imageViewCell.player.isMuted = false
                                        // imageViewCell.volumeBtn.setImage(UIImage(named: "icon_muted"), for: .normal)
                                        imageViewCell.player.play()
                                        
                                        NotificationCenter.default.addObserver(self,selector: #selector(self.restartVideoFromBeginning),name: NSNotification.Name.AVPlayerItemDidPlayToEndTime,object: imageViewCell.player.currentItem)
                                    }else{
                                        // self.singleTap.cancelsTouchesInView = false
                                        //imageViewCell.iboVideoView.addGestureRecognizer(doubleTapVideo)
                                        //imageViewCell.iboVideoView.addGestureRecognizer(singleTapvideo)
                                        //singleTapvideo.require(toFail: doubleTapVideo)
                                        imageViewCell.videoAsSubView.layer.addSublayer(player_layer)
                                        imageViewCell.player = layer
                                        //  imageViewCell.playerItm = temp.playerItm
                                        imageViewCell.player.isMuted = false
                                        //imageViewCell.iboSound.setImage(UIImage(named: "icon_muted"), for: .normal)
                                        imageViewCell.player.play()
                                        print("layer is there")
                                        
                                        NotificationCenter.default.addObserver(self,selector: #selector(self.restartVideoFromBeginning),name: NSNotification.Name.AVPlayerItemDidPlayToEndTime,object: imageViewCell.player.currentItem)
                                    }
                                    
                                }else{
                                    //  imageViewCell.iboVideoView.addGestureRecognizer(doubleTapVideo)
                                    // imageViewCell.iboVideoView.addGestureRecognizer(singleTapvideo)
                                    // singleTapvideo.require(toFail: doubleTapVideo)
                                    imageViewCell.videoAsSubView.layer.addSublayer(player_layer)
                                    imageViewCell.player = layer
                                    //imageViewCell.playerItm = temp.playerItm
                                    imageViewCell.player.isMuted = false
                                    //  imageViewCell.iboSound.setImage(UIImage(named: "icon_muted"), for: .normal)
                                    imageViewCell.player.play()
                                    
                                    NotificationCenter.default.addObserver(self,selector: #selector(self.restartVideoFromBeginning),name: NSNotification.Name.AVPlayerItemDidPlayToEndTime,object: imageViewCell.player.currentItem)
                                }
                                
                                
                                
                            }else{
                                
                                var video_url = temp["item_url"] as? String
                                video_url = URLConstants.imgDomain  + video_url!
                                
                                imageViewCell.imageViewToShow.image = UIImage(named: "process")
                                
                                DispatchQueue.global(qos: .userInitiated).async {
                                    
                                    
                                    
                                    imageViewCell.playerItm = AVPlayerItem.init(url: URL(string: video_url!)!)
                                    
                                    
                                    DispatchQueue.main.sync(execute: {
                                        
                                        imageViewCell.player = AVPlayer(playerItem: imageViewCell.playerItm)
                                        imageViewCell.playerLayer = AVPlayerLayer(player: imageViewCell.player)
                                        imageViewCell.playerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
                                        imageViewCell.player.actionAtItemEnd = .none
                                        imageViewCell.playerLayer.frame = imageViewCell.videoAsSubView.bounds
                                        //cell.playerLayer.frame = cell.videoAsSubview.bounds;
                                        
                                        imageViewCell.player.isMuted = true
                                        //  imageViewCell.volumeBtn.setImage(UIImage(named: "icon_muted"), for: .normal)
                                        //cell.iboVideoView.layer.sublayers = nil
                                        imageViewCell.imageViewToShow.image = nil
                                        imageViewCell.videoAsSubView.layer.addSublayer(imageViewCell.playerLayer)
                                        imageViewCell.player.play()
                                        self.collectionArray[indexPath.row].updateValue(imageViewCell.player, forKey: "player_layer")
                                        self.collectionArray[indexPath.row].updateValue(imageViewCell.player, forKey: "player")
                                        //temp
                                        // dictToAdd.updateValue("Video" as AnyObject, forKey: "type")
                                        // temp.player = imageViewCell.player
                                        //temp.playerLayer = imageViewCell.playerLayer
                                        NotificationCenter.default.addObserver(self,selector: #selector(self.restartVideoFromBeginning),name: NSNotification.Name.AVPlayerItemDidPlayToEndTime,object: imageViewCell.player.currentItem)
                                    })
                                }
                                
                                
                            }
                            
                            
                            
                            
                            
                        }
                        
                 else{
                        var url = temp["item_url"] as? String
                            
                        var urlImage = url?.components(separatedBy: "album")
                        let totalPath = URLConstants.imgDomain
                        if urlImage?.count == 2 {
                            let second = urlImage?[1]
                            url = totalPath + second!
                        }else{
                            if let first = urlImage?[0]{
                            url = totalPath + first
                            }
                            
                        }
                        //url = totalPath + (urlImage?[1])!
                        var version = url?.components(separatedBy: "compressed")
                        
                        var afterAppending  = url?.components(separatedBy: "compressed")
                        var widthImage = (version?[0])! + "480" + (afterAppending?[1])!
                        
                        imageViewCell.imageViewToShow.sd_setImage(with: URL(string: widthImage), placeholderImage: UIImage(named: ""))
                        imageViewCell.imageViewToShow.contentMode = .scaleAspectFill
                        imageViewCell.videoAsSubView.isHidden = true
                        imageViewCell.volumeBtn.isHidden = true
                        //imageViewCell.fullScreenBtn.isHidden = true
                        imageViewCell.videoPlayBtn.isHidden = true
                        imageViewCell.backgroundColor = UIColor.brown
                        imageViewCell.clipsToBounds = true
                        
                    }
                    
                    
                }
            }
        }else{
            
            // edit mode On
            
            if let imageViewCell = cell as? ImageViewCollectionViewCell{
                
                if selectedItemIndex == indexPath.item{
                    
                    imageViewCell.layer.borderWidth = 2
                    
                    imageViewCell.layer.borderColor = UIColor(red: 50/255, green: 197/255, blue: 182/255, alpha: 1).cgColor
                }
                
                if type == "img"{
                    let temp = collectionArray[indexPath.row]
                    var url = temp["item_url"] as? String
                    var urlImage = url?.components(separatedBy: "album")
                    let totalPath = URLConstants.imgDomain
                    if urlImage?.count == 2 {
                        let second = urlImage?[1]
                        url = totalPath + second!
                    }else{
                        if let first = urlImage?[0]{
                            url = totalPath + first
                        }
                        
                    }
                    //url = totalPath + (urlImage?[1])!
                    var version = url?.components(separatedBy: "compressed")
                    
                    var afterAppending  = url?.components(separatedBy: "compressed")
                    var widthImage = (version?[0])! + "480" + (afterAppending?[1])!
                    
               
                   // url = URLConstants.imgDomain  + url!
                   // imageViewCell.alpha = 1
                    //imageViewCell.isHidden = false
                 //   let sizeOrg = (temp as AnyObject).object(forKey: "data") as? Data
                    imageViewCell.backgroundColor = UIColor.brown
                    imageViewCell.videoAsSubView.isHidden = true
                    imageViewCell.videoPlayBtn.isHidden = true
                    imageViewCell.volumeBtn.isHidden = true
                    //imageViewCell.fullScreenBtn.isHidden = true
                    imageViewCell.imageViewToShow.sd_setImage(with: URL(string: widthImage), placeholderImage: UIImage(named: ""))
                    imageViewCell.imageViewToShow.contentMode = .scaleAspectFill
                    imageViewCell.clipsToBounds = true
                }else if type == "video"{
                    
                    let temp = collectionArray[indexPath.row]
                    imageViewCell.videoAsSubView.layer.sublayers = nil
                    imageViewCell.videoAsSubView.isHidden = false
                    imageViewCell.volumeBtn.isHidden = false
                   // imageViewCell.player.isMuted = true
                    imageViewCell.layer.borderWidth = CGFloat.leastNormalMagnitude
                    imageViewCell.layer.borderColor = UIColor.clear.cgColor
                   // imageViewCell.player.pause()
                      DispatchQueue.global(qos: .userInitiated).async {
                        var url = temp["item_url"] as? String
                        url = URLConstants.imgDomain + url!
                          if  let image  = self.thumbnailImageForFileUrl(URL(string: url!)!){
                            DispatchQueue.main.async {
                            imageViewCell.imageViewToShow.image = image
                            }
                         
                        }
                       
                    }
                    
                    
                    
                    
                }
            }else{
                if type == "Text"{
                    if let cell = cell as? TextCellStoryCollectionViewCell{
                        
                        if selectedItemIndex == indexPath.item{
                            
                            cell.layer.borderWidth = 2
                            
                            cell.layer.borderColor = UIColor(red: 50/255, green: 197/255, blue: 182/255, alpha: 1).cgColor
                        }
                        
                        
                        cell.alpha = 1
                        cell.isHidden = false
                        cell.titleLabel.isUserInteractionEnabled = false
                        cell.subTitleLabel.isUserInteractionEnabled = false
                        cell.layer.borderWidth = CGFloat.leastNormalMagnitude
                        cell.layer.borderColor = UIColor.clear.cgColor
                        cell.titleLabel.text = temp["title"] as! String
                        cell.subTitleLabel.text = temp["description"] as! String
                        //cell.subTitleLabel.textColor =
                        if let allign = temp["textAlignment"] as? Int{
                            if allign == 1{
                                cell.titleLabel.textAlignment = .center
                                cell.subTitleLabel.textAlignment = .center
                            }else{
                                cell.titleLabel.textAlignment = .left
                                cell.subTitleLabel.textAlignment = .left
                            }
                        }
                        
                        //cell.titleLabel.inputAccessoryView = self.keyboardView
                        //cell.subTitleLabel.inputAccessoryView = self.keyboardView
                        cell.titleLabel.textColor = UIColor(hexString:(temp["textColor"] as! String))
                        cell.myView.backgroundColor = UIColor(hexString:(temp["backgroundColor"] as! String))
                                }
                }
            }
        }
        
        
    }

    
     func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: ImageViewCollectionViewCell, forItemAt indexPath: IndexPath) {
        
        
        if !editTurnOn{
            
            let indexData = self.collectionArray[indexPath.item]
            let type  =  indexData["type"] as! String
            
            if type == "video" {
                cell.player.isMuted = true
            }
        }
    }
    
    
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let temp = collectionArray[indexPath.row]
        let type  =  temp["type"] as! String
        
        if type == "Text" {
            var textViewCell:TextCellStoryCollectionViewCell!
            if (textViewCell == nil) {
                textViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: self.cellTextIdentifier, for: indexPath) as! TextCellStoryCollectionViewCell
            }
            textViewCell.layer.borderWidth = CGFloat.greatestFiniteMagnitude
            textViewCell.layer.borderColor = UIColor.clear.cgColor
            
            
             if editTurnOn {
                if selectedItemIndex == indexPath.item{
                    
                    textViewCell.layer.borderWidth = 2
                  //  textViewCell.backgroundColor = UIColor.red
                    
                    textViewCell.layer.borderColor = UIColor(red: 50/255, green: 197/255, blue: 182/255, alpha: 1).cgColor
                }
            }
            
            return textViewCell
            
            
        }else{
            var imageViewCell:ImageViewCollectionViewCell!
            if (imageViewCell == nil) {
                imageViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: self.cellIdentifier, for: indexPath) as! ImageViewCollectionViewCell
            }
            imageViewCell.layer.borderWidth = CGFloat.greatestFiniteMagnitude
            imageViewCell.layer.borderColor = UIColor.clear.cgColor
             if editTurnOn {
                if selectedItemIndex == indexPath.item{
                    
                    imageViewCell.layer.borderWidth = 2
                    
                    imageViewCell.layer.borderColor = UIColor(red: 50/255, green: 197/255, blue: 182/255, alpha: 1).cgColor
                }
            }
            imageViewCell.alpha = 1
            imageViewCell.isHidden = false
            imageViewCell.layer.shouldRasterize = true;
            imageViewCell.layer.rasterizationScale = UIScreen.main.scale
            return imageViewCell
        }
        
        
}
    
    func restartVideoFromBeginning(notification:NSNotification)  {
        
        let seconds : Int64 = 0
        let preferredTimeScale : Int32 = 1
        let seekTime : CMTime = CMTimeMake(seconds, preferredTimeScale)
        
        let player : AVPlayerItem = notification.object as! AVPlayerItem
        player.seek(to: seekTime)
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    
    
}

extension String {
    
    var parseJSONString: AnyObject? {
        
        let data = self.data(using: String.Encoding.utf8, allowLossyConversion: false)
        
        if let jsonData = data {
            // Will return an object or nil if JSON decoding fails
            return try! JSONSerialization.jsonObject(with: jsonData, options: JSONSerialization.ReadingOptions.mutableContainers) as AnyObject?
        } else {
            // Lossless conversion of the string was not possible
            return nil
        }
    }
}

extension Dictionary {
    
    mutating func update(other:Dictionary) {
        for (key,value) in other {
            self.updateValue(value, forKey:key)
        }
    }
}
