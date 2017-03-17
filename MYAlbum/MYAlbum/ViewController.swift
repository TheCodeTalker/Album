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


class ViewController: UIViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate,GMImagePickerControllerDelegate {

    var collectionView :UICollectionView?
     //UIView *lineView;
    var lineView : UIView = UIView(frame: CGRect.zero)
    let CustomEverythingPhotoIndex = 1, DefaultLoadingSpinnerPhotoIndex = 3, NoReferenceViewPhotoIndex = 4
    fileprivate var imageCount : NSNumber = 0
    var requestOptions = PHImageRequestOptions()
    var requestOptionsVideo = PHVideoRequestOptions()
    fileprivate var videoCount : NSNumber = 0
    var mutablePhotos: [ExamplePhoto] = []
    var originalIndexPath: IndexPath?
    var swapImageView: UIImageView?
    var stopped : Bool = false
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

   //var pickerController: GMImagePickerCon!
   //  var assets: [DKAsset]?
    
    let defaults = UserDefaults.standard
    override func viewDidLoad() {
        super.viewDidLoad()
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
                        layout.headerReferenceSize = CGSize(width: UIScreen.main.bounds.width , height: UIScreen.main.bounds.height)
                        layout.footerReferenceSize = CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height/2)
                        layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
                        self.collectionView = UICollectionView(frame: self.view.frame, collectionViewLayout: layout)
                        self.collectionView?.delegate = self
                        self.collectionView?.dataSource  = self
                        self.collectionView?.backgroundColor = UIColor.white
                        self.collectionView?.reloadData()
                        self.collectionView?.collectionViewLayout.invalidateLayout()
                        self.collectionView?.alwaysBounceVertical = true
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
                        layout.headerReferenceSize = CGSize(width: UIScreen.main.bounds.width , height: UIScreen.main.bounds.height)
                        layout.footerReferenceSize = CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height/2)
                        layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
                        self.collectionView = UICollectionView(frame: self.view.frame, collectionViewLayout: layout)
                        self.collectionView?.register(UICollectionViewCell.classForCoder(), forCellWithReuseIdentifier: self.cellIdentifier)
                        self.collectionView?.delegate = self
                        self.collectionView?.backgroundColor = UIColor.white
                        self.collectionView?.dataSource  = self
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
        draggingView!.frame = cell.frame
        vc.addSubview(draggingView!)
        dragOffset = CGPoint(x: draggingView!.center.x - location.x, y: draggingView!.center.y - location.y)
        
        draggingView?.layer.shadowPath = UIBezierPath(rect: draggingView!.bounds).cgPath
        draggingView?.layer.shadowColor = UIColor.black.cgColor
        draggingView?.layer.shadowOpacity = 0.8
        draggingView?.layer.shadowRadius = 10
        
        // self.collectionView?.collectionViewLayout.invalidateLayout()
        //invalidateLayout()
        cell.alpha = 0.0
        cell.isHidden = true
        UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 0.4, initialSpringVelocity: 0, options: [], animations: {
            self.draggingView?.alpha = 0.95
            self.draggingView?.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
        }, completion: nil)
    }

    
    func handleLongPress(gestureReconizer: UILongPressGestureRecognizer) {
        let location  = gestureReconizer.location(in: self.collectionView)
        
        switch gestureReconizer.state {
            
        case .began:
            startDragAtLocation(location: location)
            
            
        case .changed:
            guard let view = draggingView else { return }
            guard let cv = collectionView else { return }
            
            draggingView?.center = CGPoint(x: location.x + dragOffset.x, y: location.y + dragOffset.y)
            stopped = false
            
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
             //   self.swapView!.removeFromSuperview()
                //self.swapView = nil
               // self.swapImageView?.removeFromSuperview()
                //self.swapImageView = nil
                
            }
            updateDragAtLocation(location: location)
            //  scrollIfNeed(snapshotView: draggingView!)
            self.checkPreviousIndexPathAndCalculate(location: (draggingView?.center)!, forScreenShort: (draggingView?.frame)!, withSourceIndexPath: sourseIndexPathCh)
            
            
            
            break
        case .ended:
            stopped = true
            endDragAtLocation(location: location)
        default:
            break
        }
        
        
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionElementKindSectionHeader {
          let headerView =  collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "HeaderView", for: indexPath) as! PictureHeaderCollectionReusableView
           headerView.iboHeaderImage.image = self.images[0]
           // headerView.backgroundColor = UIColor.yellow
            return headerView
        } else if kind == UICollectionElementKindSectionFooter {
        //    assert(0)
            let fotterView =  collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionFooter, withReuseIdentifier: "FotterView", for: indexPath) as! FooterReusableView
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
            lineView.removeFromSuperview()
            
            if indexPath.item != sourceIndexPath.item{
                
                let topOffset = destinationCell.frame.origin.y + 20
                let leftOffset = destinationCell.frame.origin.x + 20
                let bottomOffset = destinationCell.frame.origin.y + destinationCell.frame.size.height - 20
                let rightOffset = destinationCell.frame.origin.x + destinationCell.frame.size.width - 20
                let differenceLeft = location.x - leftOffset
                
                let differenceRight = location.x - rightOffset
                let differenceTop = location.y - topOffset
                let differenceBottom = location.y - bottomOffset
                if differenceLeft > -20 && differenceLeft < 0 {
                    print("Insert to the left of cell line")
                    lineView.removeFromSuperview()
                    let xOffset = destinationCell.frame.origin.x - 4
                    let yValue = destinationCell.frame.origin.y
                    let nestedWidth = 2.0
                    let nestedHeight = destinationCell.frame.height
                    self.collectionView?.performBatchUpdates({
                        self.lineView.frame = CGRect(x: xOffset, y: yValue, width: CGFloat(nestedWidth), height: nestedHeight)
                        self.lineView.backgroundColor = UIColor.black
                        self.collectionView?.addSubview(self.lineView)
                    }, completion: { (test) in
                        self.moveCellsApartWithFrame(frame: (self.lineView.frame), andOrientation: 0)
                        
                    })
                    
                    
//                    [lineView removeFromSuperview];
//                    [blackTransparentView removeFromSuperview];
//                    
//                    CGRect cellFrame = CGRectFromString([frames objectAtIndex:[keys[0] integerValue]]);
//                    
//                    xOffset = destinationCell.frame.origin.x - 4;
//                    yValue = cellFrame.origin.y;
//                    nestedWidth = 2.0;
//                    nestedHeight = cellFrame.size.height;
//                    
//                    [self.collectionView performBatchUpdates:^{
//                        
//                        //[self makeSpaceToInsertWithAnimationForViews:destinationCell and:viewB withMode:0];
//                        
//                        lineView.frame = CGRectMake(xOffset, yValue, nestedWidth, nestedHeight);
//                        lineView.backgroundColor = [UIColor blackColor];
//                        [self.collectionView addSubview:lineView];
//                        
//                        [self moveCellsApartWithFrame:lineView.frame andOrientation:0];
//                        
//                        } completion:nil];
                }
                
                
                
            }
            
                
        }
            
            
            
        }
        
        
        
        
    }
    
    func moveCellsApartWithFrame(frame:CGRect,andOrientation orientation:Int) {
        var certOne  = CGRect.zero
        var certTwo = CGRect.zero
        let cellsToMove0 = NSMutableArray.init()
        let cellsToMove1 = NSMutableArray.init()
        if orientation == 0 {
            certOne = CGRect(x: frame.origin.x, y: frame.origin.y, width: CGFloat.greatestFiniteMagnitude, height: frame.size.height)
            certTwo = CGRect(x: 0.0, y: frame.origin.y, width: frame.origin.x, height: frame.size.height)
        }else{
            certOne = CGRect(x: frame.origin.x, y: frame.origin.y, width: frame.size.width, height: CGFloat.greatestFiniteMagnitude)
            certTwo = CGRect(x: frame.origin.x, y: 0.0, width: frame.size.width, height: frame.size.height)
        }
        
        for i in 0 ..< self.images.count{
            
            let indexPath = IndexPath(item: i, section: 0)
            let cell = self.collectionView?.cellForItem(at: indexPath)
            if (cell?.frame.intersects(certOne))!{
                cellsToMove0.add(cell)
            }else if (cell?.frame.intersects(certTwo))!
            {
                cellsToMove1.add(cell)
                
            }
            
        }
        
//        [self.collectionView performBatchUpdates:^{
//            
//            for(ImageCollectionViewCell *cell in cellsToMove1){
//            
//            if(orientation == 0){
//            
//            [UIView animateWithDuration:0.2 animations:^{
//            cell.transform = CGAffineTransformMakeTranslation(-5.0, 0.0);
//            }];
//            
//            }
//            else{
//            [UIView animateWithDuration:0.2 animations:^{
//            cell.transform = CGAffineTransformMakeTranslation(0.0, -5.0);
//            }];
//            }
//            
//            }
        
        self.collectionView?.performBatchUpdates({
            for i in  0 ..< cellsToMove0.count{
                UIView.animate(withDuration: 0.2, animations: {
                let cell = cellsToMove0[i] as! UICollectionViewCell
                    cell.transform = CGAffineTransform(translationX: -5.0, y: 0.0)
                })
            }
            
            for i in  0 ..< cellsToMove1.count{
                UIView.animate(withDuration: 0.2, animations: {
                    let cell = cellsToMove1[i] as! UICollectionViewCell
                    cell.transform = CGAffineTransform(translationX: 5.0, y: 0.0)
                })
            }
        }, completion: { (Bool) in
            
        })

        
        
        
    }
    
    func scrollIfNeed(snapshotView:UIView)  {
        var cellCenter = snapshotView.center
        var newOffset = self.collectionView?.contentOffset
        var buffer  = 10.0 as! CGFloat
        var bottomY = (self.collectionView?.contentOffset.y)! + (self.collectionView?.frame.size.height)!
        if bottomY  < ((snapshotView.frame.maxY) - buffer){
            
            newOffset?.y += 1
            
            if ((newOffset?.y)! + (self.collectionView?.bounds.size.height)! > (self.collectionView?.contentSize.height)!) {
                return
            }
            cellCenter.y += 1;
        }
        
        
        var offsetY = self.collectionView?.contentOffset.y
        if (snapshotView.frame.minY + buffer < offsetY!) {
            // We're scrolling up
            newOffset?.y -= 1;
            
            if ((newOffset?.y)! <= CGFloat(0)) {
                return; // Stop moving, went too far
            }
            
            // adjust cell's center by 1
            cellCenter.y -= 1;
        }
        
        
        
        
        
        self.collectionView?.contentOffset = self.dragOffset
        snapshotView.center = cellCenter;
        
        // Repeat until we went to far.
        if(self.stopped == true){
            
            return;
            
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

    
    
    func endDragAtLocation(location:CGPoint){
        guard let vc = collectionView else {return}
        if let indexPath = vc.indexPathForItem(at: location), let cell = vc.cellForItem(at: originalIndexPath!),let destination = vc.cellForItem(at: indexPath)  {
            self.collectionView?.performBatchUpdates({
                self.collectionView?.moveItem(at: self.originalIndexPath!, to: indexPath)
                self.collectionView?.moveItem(at: indexPath, to: self.originalIndexPath!)
            }, completion: { (Bool) in
                //  self.draggingView!.alpha = 0.0
                cell.alpha = 1
                cell.isHidden = false
                self.draggingView?.removeFromSuperview()
                self.collectionView?.layoutIfNeeded()
                self.collectionView?.setNeedsLayout()
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

            
        }else{
            let cell = self.collectionView?.cellForItem(at: self.originalIndexPath!)
            UIView.animate(withDuration: 0.2, animations: {
                
                
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
        
        let photosViewController = NYTPhotosViewController(photos: mutablePhotos)
        
        photosViewController.display(mutablePhotos[indexPath.row], animated: true)
        photosViewController.delegate = self
        self.present(photosViewController, animated: true, completion: nil)
        
       //let photoViewController = NYTPhotosViewController(photos: mutablePhotos, initialPhoto: mutablePhotos[indexPath.row])
       // photoViewController.display(mutablePhotos[indexPath.row], animated: true)
        //self.present(photoViewController, animated: true, completion: nil)
        
        
        
        
        
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let size = imageForIndexPath(indexPath).size
        let percentWidth = CGFloat(UInt32(140) - arc4random_uniform(UInt32(80)))/100
        return CGSize(width: size.width*percentWidth/4, height: size.height/4)
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
        cell.backgroundView = imageTemp
        cell.clipsToBounds = true
        return cell

        
    }
    
     func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    

}

