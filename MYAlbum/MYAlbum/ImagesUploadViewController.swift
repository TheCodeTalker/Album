//
//  ImagesUploadViewController.swift
//  MYAlbum
//
//  Created by Chitaranjan Sahu on 29/05/17.
//  Copyright © 2017 Ithink. All rights reserved.
//

import UIKit
import Alamofire

class ImagesUploadViewController: UIViewController {
    
    @IBOutlet weak var countProgressLabel: UILabel!
    @IBOutlet weak var falseUploadText: UILabel!
    @IBOutlet weak var percentageProgress: UILabel!
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var uploadText: UILabel!
    @IBOutlet weak var closeBtn: UIButton!
    var localPartition  = Array<Array<Array<String>>>()
    var elemntCount  = Int64.init()
    var uploadData  =  [[AnyHashable:Any]]()
    var storyId : String = ""
    var insideUpload = false
    var dismissView : ((_ sender : UIViewController?,_ initialize:Bool?,_ newObjects:[[AnyHashable:Any]]?) -> Void)?
    let defaults = UserDefaults.standard
    override func viewDidLoad() {
        super.viewDidLoad()
        
        elemntCount = Int64(self.uploadData.count)
        
        if let local  = defaults.object(forKey: "partition") as? Array<Array<Array<String>>>{
            localPartition = local
        }
        
        if let insideUploadOrNot = defaults.object(forKey: "insideUploads") as? Bool{
            insideUpload = insideUploadOrNot
        }
        
        
        
        self.progressView.progress = 0.0
        self.percentageProgress.text = "0 %"
        self.uploadText.text = "We are processing your upload, Please wait."
        self.falseUploadText.text = ""
        if insideUpload{
            self.uploadOtherThenCoverPhoto()
        }else{
            self.uploadMultipleImagesWithTextMessageMultipartFormat()
            
            
        }
        
        
        // Do any additional setup after loading the view.
    }
    
    
    func uploadMultipleImagesWithTextMessageMultipartFormat() {
        
        uploadText.text = "Uploading \(elemntCount) items"
        
        Alamofire.upload(
            multipartFormData: { multipartFormData in
                var upload =  self.uploadData[0]
                let urlName  =  upload["item_url"] as! String
                var fName = "\(urlName)"
                var mimeType = "image/jpeg"
                let fileData  =  upload["data"] as! Data
                
                
                multipartFormData.append(fileData, withName: "userPhoto", fileName: fName, mimeType: mimeType)
                
                
        },
            to: URLConstants.BaseURL + "photosUpload/\(storyId)/1",
            encodingCompletion: { encodingResult in
                switch encodingResult {
                case .success(let upload, _, _):
                    upload.responseJSON { response in switch response.result {
                    case .success(let JSON):
                        print("Success with JSON: \(JSON)")
                        
                        let response = JSON as! NSDictionary
                        
                        
                        //example if there is an id
                        let dataArray = response.value(forKey: "details") as! [[String: AnyObject]]
                        self.uploadData[0].updateValue((dataArray.first?["photo_path"]!)!, forKey: "cloudFilePath")
                        self.uploadData[0].updateValue(0, forKey: "cover")
                        self.uploadData[0].updateValue((dataArray.first?["photo_path"]!)!, forKey: "filePath")
                        self.uploadData[0].updateValue( (dataArray.first?["color_codes"]!)! , forKey: "hexCode")
                        // uploadData[0].updateValue("#322e20,#d3d5db,#97989d,#aeb2b9,#858176" as AnyObject, forKey: "hexCode")
                        let height = dataArray.first?["imgHeight"] as! CGFloat
                        let width = dataArray.first?["imgWidth"] as! CGFloat
                        let sizeImage = CGSize(width: width, height: height)
                        self.uploadData[0].updateValue(sizeImage, forKey: "item_size")
                        self.uploadData[0].updateValue((dataArray.first?["photo_path"]!)!, forKey: "item_url")
                        self.uploadData[0].removeValue(forKey: "data")
                        //self.uploadData[0].updateValue(data as AnyObject, forKey: "data")
                        self.uploadData[0].updateValue(sizeImage, forKey: "original_size")
                        self.uploadData[0].updateValue("Image", forKey: "type")
                        self.uploadData[0].updateValue((dataArray.first?["photo_id"]!)!, forKey: "photo_id")
                        
                        self.uploadOtherThenCoverPhoto()
                        
                        // uploadData[0].updateValue(<#T##value: Value##Value#>, forKey: <#T##Hashable#>)
                        
                        
                    case .failure(let error):
                        print("Request failed with error: \(error)")
                        }
                        
                        debugPrint(response)
                        
                        
                        
                    }
                case .failure(let encodingError):
                    print(encodingError)
                }
        }
        )
        
        
        
    }
    
    
    func uploadOtherThenCoverPhoto() {
        Alamofire.upload(
            multipartFormData: { multipartFormData in
                var startIndex = 1
                if self.insideUpload {
                    startIndex = 0
                }
                for i in startIndex ..< self.uploadData.count{
                    let element = self.uploadData[i]
                    var fName = ""
                    var mimeType = ""
                    if let type  =  element["type"] as? String{
                        
                        if type == "Video" {
                            let urlName  =  element["video_url"] as! URL
                            fName = "\(urlName)"
                            mimeType = "video/mp4"
                        }else if type == "Image" {
                            let urlName  =  element["item_url"] as! String
                            fName = "\(urlName)"
                            mimeType = "image/jpeg"
                        }
                        
                    }
                    
                    let fileData  =  element["data"] as! Data
                    multipartFormData.append(fileData, withName: "userPhoto", fileName: fName, mimeType: mimeType)
                    
                }
                //                for(index,element) in self.uploadData.enumerated(){
                //
                //
                //
                //                }
                
                
        },
            to: URLConstants.BaseURL + "photosUpload/\(storyId)/0/",
            encodingCompletion: { encodingResult in
                switch encodingResult {
                case .success(let upload, _, _):
                    upload.responseJSON {  response in switch response.result {
                    case .success(let JSON):
                        print("Success with JSON: \(JSON)")
                        
                        let response = JSON as! NSDictionary
                        
                        
                        //example if there is an id
                        let dataArray = response.value(forKey: "details") as! [[String: AnyObject]]
                        
                        for (index,element) in dataArray.enumerated(){
                            var tempIndex = index
                            if !self.insideUpload{
                                tempIndex += 1
                                
                            }
                            if (element["photo_type"] as! Int) == 8{
                                
                                
                                self.uploadData[tempIndex].updateValue(element["photo_path"]!, forKey: "item_url")
                                self.uploadData[tempIndex].updateValue("", forKey: "cover")
                                self.uploadData[tempIndex].updateValue(element["color_codes"], forKey: "hexCode")
                                // let height = element["imgHeight"] as! CGFloat
                                //let width = CGFloat(375 - 10)
                                // let sizeImage = CGSize(width: width, height: height)
                                //self.uploadData[index + 1].updateValue(NSStringFromCGSize(sizeImage) as AnyObject, forKey: "item_size")
                                //dictToAdd.updateValue(videoData as AnyObject, forKey: "data")
                                self.uploadData[tempIndex].updateValue(element["photo_path"]!, forKey: "video_url")
                                self.uploadData[tempIndex].updateValue("Video", forKey: "type")
                                // self.collectionArray.append(dictToAdd)
                                
                                
                                
                            }else{
                                self.uploadData[tempIndex].updateValue(element["photo_path"]!, forKey: "cloudFilePath")
                                self.uploadData[tempIndex].updateValue(0, forKey: "cover")
                                self.uploadData[tempIndex].updateValue(element["photo_path"]!, forKey: "filePath")
                                //  self.uploadData[index + 1].updateValue( element["color_codes"]! , forKey: "hexCode")
                                self.uploadData[tempIndex].updateValue("#322e20,#d3d5db,#97989d,#aeb2b9,#858176", forKey: "hexCode")
                                let height = element["imgHeight"] as! CGFloat
                                let width = element["imgWidth"] as! CGFloat
                                let sizeImage = CGSize(width: width, height: height)
                                self.uploadData[tempIndex].updateValue(sizeImage, forKey: "item_size")
                                self.uploadData[tempIndex].updateValue(element["photo_path"]!, forKey: "item_url")
                                self.uploadData[tempIndex].removeValue(forKey: "data")
                                //self.uploadData[0].updateValue(data as AnyObject, forKey: "data")
                                self.uploadData[tempIndex].updateValue(sizeImage, forKey: "original_size")
                                self.uploadData[tempIndex].updateValue("Image", forKey: "type")
                                self.uploadData[tempIndex].updateValue(element["photo_id"]!, forKey: "photo_id")
                                
                            }
                            
                            
                            
                        }
                        
                        
                        self.defaults.set(false, forKey: "insideUploads")
                        self.dismissView!(self,false,self.uploadData)
                        
                        self.dismiss(animated: true, completion: nil)
                        
                        
                    case .failure(let error):
                        print("Request failed with error: \(error)")
                        }
                        
                        
                    }
                    upload.uploadProgress { progress in // main queue by default
                        
                        var countOfEachUnit = progress.totalUnitCount / self.elemntCount
                        
                        runOnMainThread {
                            self.percentageProgress.text =  "\(Int(progress.fractionCompleted * 100))%"
                            self.progressView.progress =  Float(progress.fractionCompleted)
                            if(progress.fractionCompleted == 1.00)
                            {
                                self.uploadText.text = "We are processing your uploads and adding them to your album. Just a moment please."
                                //  self.dismissView!(self,true,nil)
                                // self.dismiss(animated: true, completion: nil)
                            }
                            
                            for i in 1 ... self.elemntCount{
                                if progress.completedUnitCount >= (countOfEachUnit * i){
                                    self.countProgressLabel.text = "\(i)/\(self.elemntCount)"
                                }
                            }
                            
                        }
                        
                        
                        print("Upload Progress: \(progress.fractionCompleted)")
                    }
                    upload.downloadProgress { progress in // main queue by default
                        print("Download Progress: \(progress.fractionCompleted)")
                    }
                case .failure(let encodingError):
                    print(encodingError)
                    
                    
                    
                }
        }
        )
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func setStoryArrayFromResposeArray()  {
        
        
    }
    
    @IBAction func closeBtnClicked(_ sender: UIButton) {
        
        let sessionManager = Alamofire.SessionManager.default
        sessionManager.session.getTasksWithCompletionHandler { dataTasks, uploadTasks, downloadTasks in
            dataTasks.forEach { $0.cancel() }
            uploadTasks.forEach { $0.cancel() }
            downloadTasks.forEach { $0.cancel() } }
        
        if self.localPartition.count > 0{
            defaults.set(false, forKey: "insideUploads")
        }
        self.defaults.set(0, forKey: "addedMorePhotos")
        
        self.dismiss(animated: true, completion: nil)
        
        
    }
    
    
}
