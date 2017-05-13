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
import GMImagePicker
import NYTPhotoViewer
import Letters

let SCREENHEIGHT = UIScreen.main.bounds.height
let SCREENWIDTH = UIScreen.main.bounds.width

class ViewController: UIViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate,GMImagePickerControllerDelegate,UICollectionViewDelegateFlowLayout {

    var collectionView :UICollectionView?
    
    typealias partitionType = Array<Array<Array<String>>>
     //UIView *lineView;
    var cellsToMove0 = NSMutableArray.init()
    var selectedIndexPath = 0
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
     let defaults = UserDefaults.standard
    var swapView: UIView?
    var draggingIndexPath: IndexPath?
    var draggingView: UIView?
    var dragOffset = CGPoint.zero
    var longPressGesture : UILongPressGestureRecognizer?
    fileprivate var images = [UIImage](), needsResetLayout = false
    let PrimaryImageName = "NYTimesBuilding"
    let PlaceholderImageName = "NYTimesBuildingPlaceholder"
    fileprivate let cellIdentifier = "cell", headerIdentifier = "header", footerIdentifier = "footer"
    var collectionArray  = [Any]()
    var headerView : PictureHeaderCollectionReusableView?

   //var pickerController: GMImagePickerCon!
   //  var assets: [DKAsset]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        defaults.removeObject(forKey: "partition")
        defaults.synchronize()
        
    //    UserDefaults.standard.set(currentAnswer, forKey: "partation")
                // Do any additional setup after loading the view, typically from a nib.
    }
    
    func enableGaleery()  {
        let imagePicker = GMImagePickerController()
        imagePicker.delegate = self
        imagePicker.displayAlbumsNumberOfAssets = true
        imagePicker.allowsMultipleSelection = true
        imagePicker.title = "addImage"
        imagePicker.colsInPortrait = 4
        imagePicker.showCameraButton = false
        imagePicker.autoSelectCameraImages = false
        imagePicker.autoDisableDoneButton = true
      //  imagePicker.pickerFontName = "RobotoSlab-Light"
       // imagePicker.pickerBoldFontName = "RobotoSlab-Regular"
        imagePicker.useCustomFontForNavigationBar = true
        self.present(imagePicker, animated: true, completion: nil)
        //self.present(imagePicker, animated: true, completion: nil)
        
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == self.collectionView{
        self.headerView?.layoutHeaderViewForScrollViewOffset(offset: scrollView.contentOffset)
        }
        
        
    }
    
    
    func assetsPickerController(_ picker: GMImagePickerController!, didFinishPickingAssets assets: [Any]!) {
        self.requestOptions.resizeMode = .exact
        self.requestOptions.deliveryMode = .highQualityFormat
        self.requestOptions.isSynchronous = false
        self.requestOptions.isNetworkAccessAllowed = true
        let manager: PHImageManager = PHImageManager.default()
        let ass1 = assets as! [PHAsset]
        for asset: PHAsset in ass1 {

            if asset.mediaType == .video {
                self.requestOptionsVideo.deliveryMode = .highQualityFormat
                // self.requestOptionsVideo.isSynchronous = false
                self.requestOptionsVideo.isNetworkAccessAllowed = true
                
                manager.requestAVAsset(forVideo: asset, options:  self.requestOptionsVideo, resultHandler: { (assert:AVAsset?, audio:AVAudioMix?, info:[AnyHashable : Any]?) in
                    
                    let UrlLocal: URL = ((assert as? AVURLAsset)?.url)!
                    let videoData = NSData(contentsOf: UrlLocal)
                    let ass = AVURLAsset(url: UrlLocal, options: nil)
                    var tracks = ass.tracks(withMediaType: "AVMediaTypeVideo")
                    let track = tracks[0]
                    let trackDimensions = track.naturalSize
                    let length = (videoData?.length)! / 1000000
                    
                    var dictToAdd = Dictionary<String, Any>()
                    dictToAdd.updateValue(UrlLocal, forKey: "item_url")
                    dictToAdd.updateValue("", forKey: "cover")
                    dictToAdd.updateValue("#322e20,#d3d5db,#97989d,#aeb2b9,#858176", forKey: "hexCode")
                    
                    dictToAdd.updateValue(NSStringFromCGSize(trackDimensions), forKey: "item_size")
                    dictToAdd.updateValue(videoData, forKey: "data")
                    dictToAdd.updateValue(UrlLocal, forKey: "video_url")
                    dictToAdd.updateValue("Video", forKey: "type")
                    self.collectionArray.append(dictToAdd)
                    if asset == (ass1[assets.count - 1]){
                        
                        let layout = ZLBalancedFlowLayout()
                        //layout.sectionHeadersPinToVisibleBounds = false
                        layout.headerReferenceSize = CGSize(width: UIScreen.main.bounds.width , height: UIScreen.main.bounds.height)
                        layout.footerReferenceSize = CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height/2)
                        layout.sectionInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
                        //collectionView?.setCollectionViewLayout(layout, animated: true)
                        self.collectionView = UICollectionView(frame: self.view.frame, collectionViewLayout: layout)
                        self.collectionView?.autoresizingMask = [.flexibleWidth, .flexibleHeight]
                        self.collectionView?.delegate = self
                        //self.collectionView?.collectionViewLayout = self
                        self.collectionView?.dataSource  = self
                        self.collectionView?.backgroundColor = UIColor.white
                        self.collectionView?.reloadData()
                        self.collectionView?.collectionViewLayout.invalidateLayout()
                        self.collectionView?.alwaysBounceVertical = true
                        self.collectionView?.bounces = false
                        self.collectionView?.register(UICollectionViewCell.classForCoder(), forCellWithReuseIdentifier: self.cellIdentifier)
                        self.collectionView?.register(UINib(nibName: "PictureHeader", bundle: nil), forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "HeaderView")
                        self.collectionView?.register(UINib(nibName: "FooterReusableView", bundle: nil), forSupplementaryViewOfKind: UICollectionElementKindSectionFooter, withReuseIdentifier: "FotterView")
                        self.longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(self.handleLongPress))
                        self.collectionView?.addGestureRecognizer(self.longPressGesture!)
                        self.swapView = UIView(frame: CGRect.zero)
                        self.swapImageView = UIImageView(image: UIImage(named: "Swap-white"))

                        self.view.addSubview(self.collectionView!)
                        //let viewController = ViewController(collectionViewLayout: layout)
                                            self.getPhoto()
                        picker.presentingViewController!.dismiss(animated: true, completion: { _ in })
                        
                    }

                    
                })
                
            }else{
                
                manager.requestImageData(for: asset, options: self.requestOptions, resultHandler: { (data: Data?, identificador: String?, orientaciomImage: UIImageOrientation, info: [AnyHashable: Any]?) in
                   // print(info)
                    var dictToAdd = Dictionary<String, Any>()
                    let compressedImage = UIImage(data: data!)
                    self.images.append(compressedImage!)
                    let urlString =  "\(((((info as! Dictionary<String,Any>)["PHImageFileURLKey"])! as! URL)))"
                    dictToAdd.updateValue(urlString, forKey: "cloudFilePath")
                    dictToAdd.updateValue(0, forKey: "cover")
                    dictToAdd.updateValue(urlString, forKey: "filePath")
                    dictToAdd.updateValue("#322e20,#d3d5db,#97989d,#aeb2b9,#858176", forKey: "hexCode")
                    dictToAdd.updateValue("#322e20,#d3d5db,#97989d,#aeb2b9,#858176", forKey: "hexCode")
                    let sizeImage = compressedImage?.size
                    dictToAdd.updateValue(sizeImage as Any, forKey: "item_size")
                    dictToAdd.updateValue(urlString, forKey: "item_url")
                    dictToAdd.updateValue(sizeImage as Any, forKey: "original_size")
                    dictToAdd.updateValue("Image", forKey: "type")
                    self.collectionArray.append(dictToAdd)
                    if asset == (ass1[assets.count - 1]){
                        
                        let layout = ZLBalancedFlowLayout()
                       // layout.sectionHeadersPinToVisibleBounds = false
                        layout.headerReferenceSize = CGSize(width: UIScreen.main.bounds.width , height: UIScreen.main.bounds.height)
                        layout.footerReferenceSize = CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height/2)
                        layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
                        self.collectionView = UICollectionView(frame: self.view.frame, collectionViewLayout: layout)
                        self.collectionView?.register(UICollectionViewCell.classForCoder(), forCellWithReuseIdentifier: self.cellIdentifier)
                        self.collectionView?.delegate = self
                        self.collectionView?.autoresizingMask = [.flexibleWidth, .flexibleHeight]
                        self.collectionView?.backgroundColor = UIColor.white
                        self.collectionView?.dataSource  = self
                        self.collectionView?.bounces = false
                        self.collectionView?.alwaysBounceVertical = true
                        
                        self.collectionView?.reloadData()
                        self.collectionView?.collectionViewLayout.invalidateLayout()
                        self.longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(self.handleLongPress))
                        self.collectionView?.addGestureRecognizer(self.longPressGesture!)
                        self.swapView = UIView(frame: CGRect.zero)
                        self.swapImageView = UIImageView(image: UIImage(named: "Swap-white"))
                         self.collectionView?.register(UINib(nibName: "PictureHeader", bundle: nil), forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "HeaderView")
                        self.collectionView?.register(UINib(nibName: "FooterReusableView", bundle: nil), forSupplementaryViewOfKind: UICollectionElementKindSectionFooter, withReuseIdentifier: "FotterView")
                        self.view.addSubview(self.collectionView!)
                        //let viewController = ViewController(collectionViewLayout: layout)
                        self.getPhoto()
                        picker.presentingViewController!.dismiss(animated: true, completion: { _ in })
                        
                    }

                })
                
                
            }
        }
    }
    
    func startDragAtLocation(location:CGPoint) {
        
        guard let vc = collectionView else {return}
        guard let indexPath = vc.indexPathForItem(at: location) else {return}
        guard let cell = vc.cellForItem(at: indexPath) else {return}
        originalIndexPath = indexPath
        draggingIndexPath = indexPath
         draggingView = cell.snapshotView(afterScreenUpdates: true)
        guard let view = draggingView else { return }
        
        view.frame = cell.frame
            var center = cell.center
        view.center = center
        vc.addSubview(view)
            
      //  dragOffset = CGPoint(x: draggingView.center.x - location.x, y: draggingView.center.y - location.y)
        
        view.layer.shadowPath = UIBezierPath(rect: (draggingView?.bounds)!).cgPath
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.8
        view.layer.shadowRadius = 10
        
        // self.collectionView?.collectionViewLayout.invalidateLayout()
        //invalidateLayout()
        cell.alpha = 0.0
        cell.isHidden = true
        UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 0.4, initialSpringVelocity: 0, options: [], animations: {
            
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
            guard let cv = collectionView else { return }
            guard let originalIndexPath = originalIndexPath else {return}
            
         //   view.center = CGPoint(x: location.x + dragOffset.x, y: location.y + dragOffset.y)
            
            var center = view.center
            center.x = location.x
            
            center.y = location.y
            view.center = center
            
            guard let destIndexPathCh = cv.indexPathForItem(at: location) else {return}
            guard let cell = cv.cellForItem(at: destIndexPathCh) else {return}
            
            guard let sourseIndexPathCh = cv.indexPathForItem(at: location) else {return}
            guard let sourseCell = cv.cellForItem(at: sourseIndexPathCh) else {return}
            
            if sourseCell.frame.size.width == cell.frame.size.width{
                swapView?.frame = cell.contentView.bounds
                swapImageView?.center = CGPoint(x: (swapView?.frame.size.width)!, y: (swapView?.frame.size.height)!)
                //self.swapView?.addSubview(swapImageView!)
               // cell.contentView.addSubview(self.swapView!)
            }else{
             //   self.swapView!.removeFromSuperview()x
                //self.swapView = nil
               // self.swapImageView?.removeFromSuperview()
                //self.swapImageView = nil
                
            }
           // updateDragAtLocation(location: location)
            stopped = false
              scrollIfNeed(snapshotView: view)
            self.checkPreviousIndexPathAndCalculate(location: view.center, forScreenShort: view.frame, withSourceIndexPath: originalIndexPath)
            
            
            
            break
        case .ended:
            self.changeToIdentiPosition()
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
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionElementKindSectionHeader {
          headerView =  collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "HeaderView", for: indexPath) as! PictureHeaderCollectionReusableView
           self.headerView?.iboHeaderImage.image = self.images[0]
           // headerView.backgroundColor = UIColor.yellow
            return headerView!
        } else if kind == UICollectionElementKindSectionFooter {
        //    assert(0)
            let fotterView =  collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionFooter, withReuseIdentifier: "FotterView", for: indexPath) as! FooterReusableView
            fotterView.iboOwnerImg.setImage(string: "Chitaranjan sahu", color: UIColor.brown, circular: true)
            fotterView.backgroundColor = UIColor.yellow
            return fotterView
        }else{
            return UICollectionReusableView()
        }
    }
    
    func checkPreviousIndexPathAndCalculate(location:CGPoint,forScreenShort snapshot:CGRect,withSourceIndexPath sourceIndexPath:IndexPath){
        if let indexPath = self.collectionView?.indexPathForItem(at: location){
            
        let sourceCell = self.collectionView?.cellForItem(at: sourceIndexPath)
        if let destinationCell = self.collectionView?.cellForItem(at: indexPath)
        {
            self.changeToIdentiPosition()
            lineView.removeFromSuperview()
            self.swapView?.removeFromSuperview()
            
         //   print("\(indexPath.item)source but destination\(sourceIndexPath.item)")
            if indexPath.item != sourceIndexPath.item{
                
                let topOffset = destinationCell.frame.origin.y + 20
                let leftOffset = destinationCell.frame.origin.x + 20
                let bottomOffset = destinationCell.frame.origin.y + destinationCell.frame.size.height - 10
                let rightOffset = destinationCell.frame.origin.x + destinationCell.frame.size.width - 10
                let differenceLeft = location.x - leftOffset
                
                let differenceRight = location.x - rightOffset
               // print("destination\(destinationCell.frame)")
                let differenceTop = location.y - topOffset
                let differenceBottom = location.y - bottomOffset
                if differenceLeft > -20 && differenceLeft < 0 {
                  //  print("Insert to the left of cell line")
                    lineView.removeFromSuperview()
                    self.swapView?.removeFromSuperview()
                    print("differenceLeft\(differenceLeft)")
                    let xOffset = destinationCell.frame.origin.x - 5
                     // print("\(xOffset)in left of the cell line ")
                    let yValue = destinationCell.frame.origin.y
                    //print("\(yValue)in left of the cell line ")
                    let nestedWidth = 2.0
                    let nestedHeight = destinationCell.frame.height
                    self.collectionView?.performBatchUpdates({
                        print("height destinationleft  \(nestedHeight)")
                        self.lineView.frame = CGRect(x: xOffset, y: yValue, width: CGFloat(nestedWidth), height: nestedHeight)
                        self.lineView.backgroundColor = UIColor.black
                        self.collectionView?.addSubview(self.lineView)
                    }, completion: { (test) in
                        self.moveCellsApartWithFrame(frame: (self.lineView.frame), andOrientation: 0)
                        
                    })
                }else if differenceRight < 20 && differenceRight > 0{
                    
                    print("Insert to the right of the cell line")
                    print("differenceright\(differenceRight)")
                    lineView.removeFromSuperview()
                    self.swapView?.removeFromSuperview()
                    
                    let  xOffset = destinationCell.frame.origin.x + destinationCell.frame.size.width + 5
                    let  yValue = destinationCell.frame.origin.y
                    let nestedWidth = 2.0
                    let nestedHeight = destinationCell.frame.size.height
                    //floor(xOffset)
                    //floor(yValue)
                    //print("\(floor(xOffset))in right of the cell line ")
                    //print("\(floor(yValue))in right of the cell line ")
                    self.collectionView?.performBatchUpdates({
                        print("height destinationright  \(nestedHeight)")
                        self.lineView.frame = CGRect(x: xOffset, y: yValue, width: CGFloat(nestedWidth), height: nestedHeight)
                        self.lineView.backgroundColor = UIColor.black
                        self.collectionView?.addSubview(self.lineView)
                    }, completion: { (test) in
                        self.moveCellsApartWithFrame(frame: (self.lineView.frame), andOrientation: 0)
                        
                    })

                    
//                    let xOffset = destinationCell.frame.origin.x + destinationCell.frame.size.width + 2
//                    let yValue = destinationCell.frame.origin.y
//                    let nestedWidth = 2.0
//                    let nestedHeight = destinationCell.frame.height
//                    self.collectionView?.performBatchUpdates({
//                        self.lineView.frame = CGRect(x: xOffset, y: yValue, width: CGFloat(nestedWidth), height: nestedHeight)
//                        self.lineView.backgroundColor = UIColor.black
//                        self.collectionView?.addSubview(self.lineView)
//                    }, completion: { (test) in
//                        self.moveCellsApartWithFrame(frame: (self.lineView.frame), andOrientation: 0)
//                        
//                    })

                    
                }else if (differenceTop > -20 && differenceTop < 0 && destinationCell.frame.size.width < (UIScreen.main.bounds.width - 16)){
                    print("Insert to the TOP of the cell line")
                    lineView.removeFromSuperview()
                    self.swapView?.removeFromSuperview()
                    
                    let  xOffset = destinationCell.frame.origin.x
                    let  yValue = destinationCell.frame.origin.y - 4
                    let nestedWidth = destinationCell.frame.size.width
                    let nestedHeight = 2.0
                    //floor(xOffset)
                    //floor(yValue)
                   // print("\(floor(xOffset))in right of the cell line ")
                    //print("\(floor(yValue))in right of the cell line ")
                    self.collectionView?.performBatchUpdates({
                        self.lineView.frame = CGRect(x: xOffset, y: yValue, width: CGFloat(nestedWidth), height: CGFloat(nestedHeight))
                        self.lineView.backgroundColor = UIColor.black
                        self.collectionView?.addSubview(self.lineView)
                    }, completion: { (test) in
                        self.moveCellsApartWithFrame(frame: (self.lineView.frame), andOrientation: 0)
                        
                    })

                    
                }else if(differenceBottom > 0 && differenceBottom < 20 && destinationCell.frame.size.width < (UIScreen.main.bounds.width - 16)){
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
                    self.collectionView?.performBatchUpdates({
                        self.lineView.frame = CGRect(x: xOffset, y: yValue, width: CGFloat(nestedWidth), height: CGFloat(nestedHeight))
                        self.lineView.backgroundColor = UIColor.black
                        self.collectionView?.addSubview(self.lineView)
                    }, completion: { (test) in
                        self.moveCellsApartWithFrame(frame: (self.lineView.frame), andOrientation: 0)
                        
                    })
                }else{
                    
                    self.lineView.removeFromSuperview()
                    self.swapView?.removeFromSuperview()
                    self.collectionView?.performBatchUpdates({
//                        blackTransparentView.frame = destinationCell.contentView.bounds;
//                        blackTransparentView.backgroundColor = [UIColor blackColor];
//                        blackTransparentView.alpha = 0.6;
//                        swapImageView.center = CGPointMake(blackTransparentView.frame.size.width  / 2,blackTransparentView.frame.size.height / 2);
//                        [blackTransparentView addSubview:swapImageView];
//                        [destinationCell.contentView addSubview:blackTransparentView];
                        self.swapView?.frame = destinationCell.contentView.bounds
                        self.swapView?.backgroundColor = UIColor.black
                        self.swapView?.alpha = 0.6
                        self.swapImageView?.center = CGPoint(x: (self.swapView?.frame.size.width)! / 2, y: (self.swapView?.frame.size.height)! / 2)
                        self.swapView?.addSubview(self.swapImageView!)
                        destinationCell.contentView.addSubview(self.swapView!)
                        
                    }, completion: { (boolTest) in
                        
                    })
                    
                    print("outof left and right and top and bottom")
                //    moveCellsApartWithFrame(frame: (self.lineView.frame), andOrientation: 1)
                }
            }
            else{
                //self.lineView.removeFromSuperview()
                print("outofsource")
              //  moveCellsApartWithFrame(frame: (self.lineView.frame), andOrientation: 1)
                
            }
            
                
        }else{
            

            
            }
            
            
            
        }else{
            
            
            let uIndexPath = self.collectionView?.indexPathForItem(at: CGPoint(x: location.x, y: location.y - 10))
            let lIndexPath = self.collectionView?.indexPathForItem(at: CGPoint(x: location.x, y: location.y + 10))
            if let  pIndexPath = self.collectionView?.indexPathForItem(at: CGPoint(x: location.x - 10, y: location.y)),  let nIndexPath = self.collectionView?.indexPathForItem(at: CGPoint(x: location.x + 10, y: location.y)){
                print("pIndexPath\(pIndexPath) and nIndexPath\(nIndexPath)")
                print("Insert in between two cells in the same row taken as horizontally line")
                //                NSLog(@"Insert in between two cells in the same row taken as horizontally line");
                //
                //                NSArray *keys = [[singletonArray objectAtIndex:pIndexPath.item] componentsSeparatedByString:@"-"];
                //
                //                ImageCollectionViewCell *pCell = (ImageCollectionViewCell *)[_collectionView cellForItemAtIndexPath:pIndexPath];
                //                CGRect cellFrame = CGRectFromString([frames objectAtIndex:[keys[0] integerValue]]);
                //
                //                [lineView removeFromSuperview];
                //                [blackTransparentView removeFromSuperview];
                //
                //                xOffset = pCell.frame.origin.x + pCell.frame.size.width + 2;
                //                yValue = cellFrame.origin.y;
                //                nestedWidth = 2.0;
                //                nestedHeight = cellFrame.size.height;
                //
                //                [self.collectionView performBatchUpdates:^{
                //
                //                lineView.frame = CGRectMake(xOffset, yValue, nestedWidth, nestedHeight);
                //                lineView.backgroundColor = [UIColor blackColor];
                //                [self.collectionView addSubview:lineView];
                //
                //                [self moveCellsApartWithFrame:lineView.frame andOrientation:0];
                //
                //                } completion:nil];
//                if  let pCell = self.collectionView?.cellForItem(at: pIndexPath){
//                    lineView.removeFromSuperview()
//                    
//                    let  xOffset = pCell.frame.origin.x + pCell.frame.size.width + 2
//                    
//                    let  yValue = destinationCell.frame.origin.y + destinationCell.frame.size.height + 2
//                    let nestedWidth = destinationCell.frame.size.width
//                    let nestedHeight = 2.0
//                    
                
                }
                
                
                
                
                //floor(xOffset)
                //floor(yValue)
                //   print("\(floor(xOffset))in right of the cell line ")
                //  print("\(floor(yValue))in right of the cell line ")
//                self.collectionView?.performBatchUpdates({
//                    self.lineView.frame = CGRect(x: xOffset, y: yValue, width: CGFloat(nestedWidth), height: CGFloat(nestedHeight))
//                    self.lineView.backgroundColor = UIColor.black
//                    self.collectionView?.addSubview(self.lineView)
//                }, completion: { (test) in
//                    self.moveCellsApartWithFrame(frame: (self.lineView.frame), andOrientation: 0)
//                    
//                })
            
                
                
                
                
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
        
        for i in 0 ..< self.images.count{
            
            let indexPath = IndexPath(item: i, section: 0)
            if let cell = self.collectionView?.cellForItem(at: indexPath){
            
            if (cell.frame.intersects(certOne)){
                cellsToMove0.add(cell)
            }else if (cell.frame.intersects(certTwo))
            {
                cellsToMove1.add(cell)
            }
            }
            
        }
        
        self.collectionView?.performBatchUpdates({
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
        
        self.collectionView?.performBatchUpdates({
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
//        -(void)changeToIdentityPosition{
//            
//            [self.collectionView performBatchUpdates:^{
//                
//                for(ImageCollectionViewCell *cell in cellsToMove1){
//                
//                [UIView animateWithDuration:0.2 animations:^{
//                cell.transform = CGAffineTransformIdentity;
//                }];
//                
//                }
//                
//                for(ImageCollectionViewCell *cell in cellsToMove0){
//                
//                [UIView animateWithDuration:0.2 animations:^{
//                cell.transform = CGAffineTransformIdentity;
//                }];
//                }
//                
//                } completion:nil];
//        }
//        

    }
    
    func scrollIfNeed(snapshotView:UIView)  {
        var cellCenter = snapshotView.center
      if let collectionView = self.collectionView {
        var newOffset = collectionView.contentOffset
        let buffer  = CGFloat(10.0)
        let bottomY = (collectionView.contentOffset.y) + (collectionView.frame.size.height)
        if (bottomY  < ((snapshotView.frame.maxY) - buffer)){
            
            newOffset.y += 1
            
            
            if (((newOffset.y) + (collectionView.bounds.size.height)) > (collectionView.contentSize.height)) {
                return
            }
            cellCenter.y += 1;
        }
        
        
        let offsetY = collectionView.contentOffset.y
        if (snapshotView.frame.minY + buffer < offsetY) {
            // We're scrolling up
            newOffset.y -= 1;
            
            if ((newOffset.y) <= CGFloat(0)) {
                return
            }
            
            // adjust cell's center by 1
            cellCenter.y -= 1
        }
        
        
        collectionView.contentOffset = newOffset
        snapshotView.center = cellCenter;
        
        // Repeat until we went to far.
        if(self.stopped == true){
            
            return
            
        }else
        {
            //DispatchQueue.main.as
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double((Int64)(1 * NSEC_PER_SEC)), execute: {
                self.scrollIfNeed(snapshotView: snapshotView)
            })
            //  DISPATCH_TIME_NOW, (Int64)(3 * NSEC_PER_SEC))
            //            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            //                [self scrollIfNeededWhileDraggingCell:snapshotView];
            //                });
        }
        
    }
    }

    
    func insertNewCellAtPoint(location:CGPoint ,withSourceIndexPathwithSourceIndexPath  sourceIndexPath : IndexPath ,forSnapshot snapshot:CGRect){
        
        if let  destinationIndexPath = self.collectionView?.indexPathForItem(at: location){
            if let destinationCell  = self.collectionView?.cellForItem(at: destinationIndexPath){
                
                if destinationIndexPath.item != sourceIndexPath.item{
                    
                    
                    let topOffset = destinationCell.frame.origin.y + 20
                    let leftOffset = destinationCell.frame.origin.x + 20
                    let bottomOffset = destinationCell.frame.origin.y + destinationCell.frame.size.height - 10
                    let rightOffset = destinationCell.frame.origin.x + destinationCell.frame.size.width - 10
                    let differenceLeft = location.x - leftOffset
                    
                    let differenceRight = location.x - rightOffset
                    let differenceTop = location.y - topOffset
                    let differenceBottom = location.y - bottomOffset
                    
                    var singletonArray = self.getSingletonArray()
                    var sourseKey = singletonArray[sourceIndexPath.item]
                   var sourseKeys = sourseKey.components(separatedBy: "-")
                    
                  //  if   let sourseKeys = findWithIndex(array: singletonArray, index: sourceIndexPath.item){
                    
                        if(differenceLeft > -20 && differenceLeft < 0){
                            
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
                            
                            
                            self.collectionView?.performBatchUpdates({
                                
                                self.collectionView?.moveItem(at: sourceIndexPath, to: IndexPath(item: destIndex!, section: 0))
                            }, completion: { (bool) in
                                
                                let set :IndexSet = [0]
                                self.collectionView?.reloadSections(set)
                                self.collectionView?.scrollToItem(at: IndexPath(item: destIndex!, section: 0), at: .centeredVertically, animated: true)
                                
                            })
                            
                        }else if (differenceRight < 20 && differenceRight > 0){
                            
                            
                            print("Inserting to the right of cell")
                            let destPaths = singletonArray[destinationIndexPath.item]
                         
                            var destKeys = destPaths.components(separatedBy: "-")
                            let rowNumber  = self.localPartition[Int(destKeys[0])!]
                            let rowTemp = rowNumber
                            
                            let nextItem  = rowTemp[Int(destKeys[1])!]
                            let searchString = nextItem.first
                            
                            // let nextItem = rowNumber.object(at: destKeys[1])
                            var destIndex = singletonArray.index(of: searchString!)
                            
                            
                            if sourceIndexPath.item > destinationIndexPath.item && destIndex != 0{
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
                            
                            
                            self.collectionView?.performBatchUpdates({
                                
                                self.collectionView?.moveItem(at: sourceIndexPath, to: IndexPath(item: destIndex!, section: 0))
                            }, completion: { (bool) in
                                
                                let set :IndexSet = [0]
                                self.collectionView?.reloadSections(set)
                                self.collectionView?.scrollToItem(at: IndexPath(item: destIndex!, section: 0), at: .centeredVertically, animated: true)
                                
                            })

                            
                        }else   if (differenceTop > -20 && differenceTop < 0 && destinationCell.frame.size.width < (UIScreen.main.bounds.width - 16)){
                             print("Insert to the top of that cell")
                            
                            
                            
                            let destPaths = singletonArray[destinationIndexPath.item]
                            var destKeys = destPaths.components(separatedBy: "-")
                            var destRowArray  = self.localPartition[Int(destKeys[0])!]
                            var destIndex = destinationIndexPath.item
                            
                            if sourceIndexPath.item > destinationIndexPath.item {
                                destIndex = destIndex - 1
                            }
                            var destColArray  = destRowArray[Int(destKeys[1])!]
                            //  let searchString = nextItem.first
                            var newObj = destKeys[0] + destKeys[1] + "\(destColArray.count)"
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
                            
                            
                            self.collectionView?.performBatchUpdates({
                                
                                self.collectionView?.moveItem(at: sourceIndexPath, to: IndexPath(item: destIndex, section: 0))
                            }, completion: { (bool) in
                                
                                let set :IndexSet = [0]
                                self.collectionView?.reloadSections(set)
                                self.collectionView?.scrollToItem(at: IndexPath(item: destIndex, section: 0), at: .centeredVertically, animated: true)
                                
                            })

                            
                            
                            
                            
                        }else if(differenceBottom > 0 && differenceBottom < 20 && destinationCell.frame.size.width < (UIScreen.main.bounds.width - 16)){
                            print("Insert to the bottom of that cell")
                            
                        let destPaths = singletonArray[destinationIndexPath.item]
                            var destKeys = destPaths.components(separatedBy: "-")
                            var destRowArray  = self.localPartition[Int(destKeys[0])!]
                           var destIndex = destinationIndexPath.item
                            
                            if sourceIndexPath.item > destinationIndexPath.item {
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
                            
                            
                            self.collectionView?.performBatchUpdates({
                                
                                self.collectionView?.moveItem(at: sourceIndexPath, to: IndexPath(item: destIndex, section: 0))
                            }, completion: { (bool) in
                                
                                let set :IndexSet = [0]
                                self.collectionView?.reloadSections(set)
                                self.collectionView?.scrollToItem(at: IndexPath(item: destIndex, section: 0), at: .centeredVertically, animated: true)
                                
                            })

                            
                    }
                    
                        
                    
                    
            }
            
        }
        
        
    }
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
                   // localPartition.removeObject(at: keys[0] as! Int)
                    let sourceRow = Int(keys[0])!
                    let rowCount = rowArray[0].count
                    
                    for i in 0..<(sourceRow + rowCount) {
                        
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
        guard let vc = collectionView else {return}
        guard var dragView = self.draggingView else {return}
        if let indexPath = vc.indexPathForItem(at: location), let cell = vc.cellForItem(at: originalIndexPath!),let destination = vc.cellForItem(at: indexPath)  {
            //added
            
            
            if let indexPath = vc.indexPathForItem(at: location){
                
                let sourceCell = vc.cellForItem(at: originalIndexPath!)
                if let destinationCell = vc.cellForItem(at: indexPath)
                {
                    self.changeToIdentiPosition()
                    lineView.removeFromSuperview()
                    self.swapView?.removeFromSuperview()
                    
                    //   print("\(indexPath.item)source but destination\(sourceIndexPath.item)")
                    if indexPath.item != originalIndexPath?.item{
                        
                        let topOffset = destinationCell.frame.origin.y + 20
                        let leftOffset = destinationCell.frame.origin.x + 20
                        let bottomOffset = destinationCell.frame.origin.y + destinationCell.frame.size.height - 10
                        let rightOffset = destinationCell.frame.origin.x + destinationCell.frame.size.width - 10
                        let differenceLeft = location.x - leftOffset
                        
                        let differenceRight = location.x - rightOffset
                        // print("destination\(destinationCell.frame)")
                        let differenceTop = location.y - topOffset
                        let differenceBottom = location.y - bottomOffset
                        if differenceLeft > -20 && differenceLeft < 0 {
                              print("Insert to the left of cell line")
                            self.insertNewCellAtPoint(location: location, withSourceIndexPathwithSourceIndexPath: originalIndexPath!, forSnapshot: dragView.frame)
                            sourceCell?.isHidden  = false
                            originalIndexPath = nil
                            sourceCell?.removeFromSuperview()
                            //sourceCell.hidden = NO;
                            //sourceIndexPath = nil;
                            dragView.removeFromSuperview()
                           // dragView = nil
                            
                            //[snapshot removeFromSuperview];
                            //snapshot = nil;

                        }else if differenceRight < 20 && differenceRight > 0{
                            
                            print("Insert to the right of the cell line")
                            
                            self.insertNewCellAtPoint(location: location, withSourceIndexPathwithSourceIndexPath: originalIndexPath!, forSnapshot: dragView.frame)
                            sourceCell?.isHidden  = false
                            originalIndexPath = nil
                            sourceCell?.removeFromSuperview()
                            //sourceCell.hidden = NO;
                            //sourceIndexPath = nil;
                            dragView.removeFromSuperview()
                          //  dragView = nil
                            
                 //          need to remove top should be uncomment
                        }else if (differenceTop > -20 && differenceTop < 0 && destinationCell.frame.size.width < (UIScreen.main.bounds.width - 16)){
                            print("Insert to the TOP of the cell line")
                            self.insertNewCellAtPoint(location: location, withSourceIndexPathwithSourceIndexPath: originalIndexPath!, forSnapshot: dragView.frame)
                            sourceCell?.isHidden  = false
                            originalIndexPath = nil
                            sourceCell?.removeFromSuperview()
                            //sourceCell.hidden = NO;
                            //sourceIndexPath = nil;
                            dragView.removeFromSuperview()
                            //self.draggingView = nil
                            
                        }else if(differenceBottom > 0 && differenceBottom < 20 && destinationCell.frame.size.width < (UIScreen.main.bounds.width - 16)){
                            print("Insert to the Bottom of the cell line")
                            self.insertNewCellAtPoint(location: location, withSourceIndexPathwithSourceIndexPath: originalIndexPath!, forSnapshot: (self.draggingView?.frame)!)
                            sourceCell?.isHidden  = false
                            originalIndexPath = nil
                            sourceCell?.removeFromSuperview()
                            //sourceCell.hidden = NO;
                            //sourceIndexPath = nil;
                            dragView.removeFromSuperview()
                            //self.draggingView = nil
                        }else{
                            vc.performBatchUpdates({
                                print("\(UserDefaults.standard.object(forKey: "partition"))final partation")
                                self.insertNewCellAtPoint(location: location, withSourceIndexPathwithSourceIndexPath: self.originalIndexPath!, forSnapshot: dragView.frame)
                                self.collectionView?.moveItem(at: self.originalIndexPath!, to: indexPath)
                                self.collectionView?.moveItem(at: indexPath, to: self.originalIndexPath!)
                                self.swapView?.removeFromSuperview()
                                let temp  = self.images[indexPath.item]
                                self.images[indexPath.item] = self.images[(self.originalIndexPath?.item)!]
                                self.images[(self.originalIndexPath?.item)!] = temp
                                
                            }, completion: { (Bool) in
                                
                                cell.alpha = 1
                                cell.isHidden = false
                                dragView.removeFromSuperview()
                                vc.layoutIfNeeded()
                                vc.setNeedsLayout()
                                self.originalIndexPath = nil
                                self.draggingView = nil
                                
                            })
                            UIView.animate(withDuration: 0.2, animations: {
                                self.draggingView!.center = cell.center
                                self.draggingView!.transform = CGAffineTransform.identity
                                self.draggingView!.alpha = 0.0
                                //self.draggingView!.
                                cell.alpha = 1
                                cell.isHidden = false
                            }) { (Bool) in
                                self.draggingView?.removeFromSuperview()
                                self.collectionView?.layoutIfNeeded()
                                self.collectionView?.setNeedsLayout()
                                // cell.alpha = 1
                                self.originalIndexPath = nil
                                self.draggingView = nil
                            }
                            
                            
                            print("outof left and right and top and bottom")
                            //    moveCellsApartWithFrame(frame: (self.lineView.frame), andOrientation: 1)
                        }
                    }
                    else{
                        //self.lineView.removeFromSuperview()
                        print("outofsource")
                        //  moveCellsApartWithFrame(frame: (self.lineView.frame), andOrientation: 1)
                        self.collectionView?.performBatchUpdates({
                            print("\(UserDefaults.standard.object(forKey: "partition"))final partation")
                            self.insertNewCellAtPoint(location: location, withSourceIndexPathwithSourceIndexPath: self.originalIndexPath!, forSnapshot: (self.draggingView?.frame)!)
                            self.collectionView?.moveItem(at: self.originalIndexPath!, to: indexPath)
                            self.collectionView?.moveItem(at: indexPath, to: self.originalIndexPath!)
                            self.swapView?.removeFromSuperview()
                            let temp  = self.images[indexPath.item]
                            self.images[indexPath.item] = self.images[(self.originalIndexPath?.item)!]
                            self.images[(self.originalIndexPath?.item)!] = temp
                            
                        }, completion: { (Bool) in
                            
                            cell.alpha = 1
                            cell.isHidden = false
                            self.draggingView?.removeFromSuperview()
                            self.collectionView?.layoutIfNeeded()
                            self.collectionView?.setNeedsLayout()
                            self.originalIndexPath = nil
                            self.draggingView = nil
                            
                        })
                        UIView.animate(withDuration: 0.4, animations: {
                            self.draggingView!.center = cell.center
                            self.draggingView!.transform = CGAffineTransform.identity
                            self.draggingView!.alpha = 0.0
                            //self.draggingView!.
                            cell.alpha = 1
                            cell.isHidden = false
                        }) { (Bool) in
                            self.draggingView?.removeFromSuperview()
                            self.collectionView?.layoutIfNeeded()
                            self.collectionView?.setNeedsLayout()
                            // cell.alpha = 1
                            self.originalIndexPath = nil
                            self.draggingView = nil
                        }
                        
                    }
                    
                    
                }else{
                    
                    
                    
                }
                
                
                
            }else{
                
                self.collectionView?.performBatchUpdates({
                    print("\(UserDefaults.standard.object(forKey: "partition"))final partation")
                    self.insertNewCellAtPoint(location: location, withSourceIndexPathwithSourceIndexPath: self.originalIndexPath!, forSnapshot: (self.draggingView?.frame)!)
                    self.collectionView?.moveItem(at: self.originalIndexPath!, to: indexPath)
                    self.collectionView?.moveItem(at: indexPath, to: self.originalIndexPath!)
                    self.swapView?.removeFromSuperview()
                    let temp  = self.images[indexPath.item]
                    self.images[indexPath.item] = self.images[(self.originalIndexPath?.item)!]
                    self.images[(self.originalIndexPath?.item)!] = temp
                    
                }, completion: { (Bool) in
                    
                    cell.alpha = 1
                    cell.isHidden = false
                    self.draggingView?.removeFromSuperview()
                    self.collectionView?.layoutIfNeeded()
                    self.collectionView?.setNeedsLayout()
                    self.originalIndexPath = nil
                    self.draggingView = nil
                    
                })
                UIView.animate(withDuration: 0.4, animations: {
                    self.draggingView!.center = cell.center
                    self.draggingView!.transform = CGAffineTransform.identity
                    self.draggingView!.alpha = 0.0
                    //self.draggingView!.
                    cell.alpha = 1
                    cell.isHidden = false
                }) { (Bool) in
                    self.draggingView?.removeFromSuperview()
                    self.collectionView?.layoutIfNeeded()
                    self.collectionView?.setNeedsLayout()
                    // cell.alpha = 1
                    self.originalIndexPath = nil
                    self.draggingView = nil
                }
                

                
            }
            
        }else{
            
            
            let indexPaths = vc.indexPathsForVisibleSupplementaryElements(ofKind: UICollectionElementKindSectionHeader)
            for indexPath in indexPaths {
                if (headerView) == vc.supplementaryView(forElementKind: UICollectionElementKindSectionHeader, at: indexPath){
                    if let headerView  = vc.supplementaryView(forElementKind: UICollectionElementKindSectionHeader, at: indexPath) as? PictureHeaderCollectionReusableView {
                    
                    if (self.draggingView?.frame.intersects(headerView.frame))!
                    {
                        let cell = vc.cellForItem(at: self.originalIndexPath!)
                        
                       // imageTemp.contentMode = .scaleAspectFill
                        let imageData =  images[0]
                        // let image = UIImage(c)
                        let imageTemp = UIImageView(image: imageData)
                       

                        
                        cell?.backgroundView = imageTemp
                        cell?.backgroundView?.contentMode = .scaleAspectFill
                        cell?.clipsToBounds = true
                        
                        //cell?.backgroundView
                        headerView.iboHeaderImage.image = self.images[(self.originalIndexPath?.item)!]
                        
                        self.images[0] = self.images[(self.originalIndexPath?.item)!]
                        
                        self.images[(self.originalIndexPath?.item)!] = imageData
                        self.lineView.removeFromSuperview()
                        self.swapView?.removeFromSuperview()
                        self.draggingView?.removeFromSuperview()
                        cell?.alpha = 1
                        cell?.isHidden = false
                        
                        return
                    }else{
                        let cell = vc.cellForItem(at: self.originalIndexPath!)
                        UIView.animate(withDuration: 0.4, animations: {
                            
                            
                            self.draggingView?.frame = (cell?.frame)!
                            self.draggingView?.transform = CGAffineTransform.identity
                            
                            self.draggingView?.removeFromSuperview()
                            
                        }, completion: { (Bool) in
                            cell?.alpha = 1
                            cell?.isHidden = false
                            return
                        })
                        

                    }
                    }
                    //break
                }
            }
            
            
            
           // if let headerView = self.collectionView.
            let cell = vc.cellForItem(at: self.originalIndexPath!)
            UIView.animate(withDuration: 0.4, animations: {
                
                
                self.draggingView?.frame = (cell?.frame)!
                self.draggingView?.transform = CGAffineTransform.identity
                
                self.draggingView?.removeFromSuperview()
                
            }, completion: { (Bool) in
                cell?.alpha = 1
                cell?.isHidden = false
                return
            })

        }
       // guard let cell = vc.cellForItem(at: originalIndexPath!) else {return}
       // guard let destination = vc.cellForItem(at: indexPath) else {return}
        
        
        
    }
    
    func updateDragAtLocation(location:CGPoint) {
        
        
        //        if let newIndexPath = cv.indexPathForItem(at: location) {
        //        //    cv.moveItem(at: draggingIndexPath!, to: newIndexPath)
        //            draggingIndexPath = newIndexPath
        //        }
        
    }

    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    func showImagePicker() {
        self.enableGaleery()
    
    }
    
    @IBAction func IbaOpenGallery(_ sender: UIButton) {
     
        
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
                case .authorized: break
                    
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
        
       // let photoOriginal = NYTPhoto
        
        for photoIndex in 0 ..< images.count {
            let image = images[photoIndex]
            let title = NSAttributedString(string: "\(photoIndex + 1)", attributes: [NSForegroundColorAttributeName: UIColor.white])
            
            let photo = shouldSetImageOnIndex(photoIndex: photoIndex) ? ExamplePhoto(image: image, attributedCaptionTitle: title) : ExamplePhoto(attributedCaptionTitle: title)
            
            if photoIndex == CustomEverythingPhotoIndex {
                photo.placeholderImage = UIImage(named: PlaceholderImageName)
            }
            
            mutablePhotos.append(photo)
        }

        
        
        
    }
    }
    
   



extension ViewController:UICollectionViewDelegate,UICollectionViewDataSource,NYTPhotosViewControllerDelegate
{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return self.collectionArray.count
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
      // self.collectionView?.deselectItem(at: <#T##IndexPath#>, animated: <#T##Bool#>)
        selectedIndexPath = indexPath.item
        let photosViewController = NYTPhotosViewController(photos: mutablePhotos)
        
        photosViewController.display(mutablePhotos[indexPath.row], animated: true)
        photosViewController.delegate = self
        self.present(photosViewController, animated: true, completion: nil)
        
       //let photoViewController = NYTPhotosViewController(photos: mutablePhotos, initialPhoto: mutablePhotos[indexPath.row])
       // photoViewController.display(mutablePhotos[indexPath.row], animated: true)
        //self.present(photoViewController, animated: true, completion: nil)
        
        
        
        
        
    }
    
    
    
    func photosViewController(_ photosViewController: NYTPhotosViewController, referenceViewFor photo: NYTPhoto) -> UIView? {
        
        guard let cell = collectionView?.cellForItem(at: IndexPath(item: selectedIndexPath, section: 0))else {return nil}
        
        return cell.contentView
        
        
        
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let size = imageForIndexPath(indexPath).size
       // let percentWidth = CGFloat(UInt32(140) - arc4random_uniform(UInt32(80)))/100
        return size //CGSize(width: size.width*percentWidth/4, height: size.height/4)
    }
    

    func imageForIndexPath(_ indexPath:IndexPath) -> UIImage {
        return images[indexPath.item%images.count]
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath)
        let temp = collectionArray[indexPath.row]
        //   let imageView = UIImageView(image: imageForIndexPath(indexPath))
        let url = (temp as AnyObject).object(forKey: "item_url") as? String
       let imageData =  images[indexPath.item]
        // let image = UIImage(c)
        let imageTemp = UIImageView(image: imageData)
        imageTemp.contentMode = .scaleAspectFill
//        cell.backgroundColor = [UIColor lightGrayColor];
        cell.backgroundColor = UIColor.brown

        cell.backgroundView = imageTemp
        cell.clipsToBounds = true
        return cell

        
    }
    
     func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    

}

