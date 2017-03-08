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
    let CustomEverythingPhotoIndex = 1, DefaultLoadingSpinnerPhotoIndex = 3, NoReferenceViewPhotoIndex = 4
    fileprivate var imageCount : NSNumber = 0
    var requestOptions = PHImageRequestOptions()
    var requestOptionsVideo = PHVideoRequestOptions()
    fileprivate var videoCount : NSNumber = 0
    var mutablePhotos: [ExamplePhoto] = []
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
                        layout.headerReferenceSize = CGSize(width: 100, height: 100)
                        layout.footerReferenceSize = CGSize(width: 100, height: 100)
                        layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
                        self.collectionView = UICollectionView(frame: self.view.frame, collectionViewLayout: layout)
                        self.collectionView?.delegate = self
                        self.collectionView?.dataSource  = self
                        self.collectionView?.backgroundColor = UIColor.white
                        self.collectionView?.reloadData()
                        self.collectionView?.collectionViewLayout.invalidateLayout()
                        self.collectionView?.alwaysBounceVertical = true
                        self.collectionView?.register(UICollectionViewCell.classForCoder(), forCellWithReuseIdentifier: self.cellIdentifier)
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
                        layout.headerReferenceSize = CGSize(width: 100, height: 100)
                        layout.footerReferenceSize = CGSize(width: 100, height: 100)
                        layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
                        self.collectionView = UICollectionView(frame: self.view.frame, collectionViewLayout: layout)
                        self.collectionView?.register(UICollectionViewCell.classForCoder(), forCellWithReuseIdentifier: self.cellIdentifier)
                        self.collectionView?.delegate = self
                        self.collectionView?.backgroundColor = UIColor.white
                        self.collectionView?.dataSource  = self
                        self.collectionView?.alwaysBounceVertical = true
                        self.collectionView?.reloadData()
                        self.collectionView?.collectionViewLayout.invalidateLayout()
                        self.view.addSubview(self.collectionView!)
                        //let viewController = ViewController(collectionViewLayout: layout)
                        self.getPhoto()
                        picker.presentingViewController!.dismiss(animated: true, completion: { _ in })
                        
                    }

                })
                
                
            }
        }
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

