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
    var elemntCount  = Int64.init()
    var uploadData  =  [[String:AnyObject]]()
    var storyId : String = ""
    var dismissView : ((_ sender : UIViewController?,_ initialize:Bool?,_ newObjects:[[String:AnyObject]]?) -> Void)?
     let defaults = UserDefaults.standard
    override func viewDidLoad() {
        super.viewDidLoad()
        
        elemntCount = Int64(self.uploadData.count)
        self.progressView.progress = 0.0
        self.percentageProgress.text = "0 %"
        self.uploadText.text = "We are processing your upload, Please wait."
        self.falseUploadText.text = ""
        self.uploadMultipleImagesWithTextMessageMultipartFormat()
        

        // Do any additional setup after loading the view.
    }

    
    func uploadMultipleImagesWithTextMessageMultipartFormat() {
        
        uploadText.text = "Uploading \(elemntCount) items"
        
        Alamofire.upload(
            multipartFormData: { multipartFormData in
                var upload =  self.uploadData[0]
                    let urlName  =  (upload as AnyObject).object(forKey: "item_url") as! String
                    var fName = "\(urlName)"
                    var mimeType = "image/jpeg"
                    let fileData  =  (upload as AnyObject).object(forKey: "data") as! Data
                
                
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
                             self.uploadData[0].updateValue(0 as AnyObject, forKey: "cover")
                             self.uploadData[0].updateValue((dataArray.first?["photo_path"]!)!, forKey: "filePath")
                            self.uploadData[0].updateValue( (dataArray.first?["color_codes"]!)! , forKey: "hexCode")
                            // uploadData[0].updateValue("#322e20,#d3d5db,#97989d,#aeb2b9,#858176" as AnyObject, forKey: "hexCode")
                            let height = dataArray.first?["imgHeight"] as! CGFloat
                            let width = dataArray.first?["imgWidth"] as! CGFloat
                            let sizeImage = CGSize(width: width, height: height)
                             self.uploadData[0].updateValue(sizeImage as AnyObject, forKey: "item_size")
                             self.uploadData[0].updateValue((dataArray.first?["photo_path"]!)!, forKey: "item_url")
                            self.uploadData[0].removeValue(forKey: "data")
                             //self.uploadData[0].updateValue(data as AnyObject, forKey: "data")
                             self.uploadData[0].updateValue(sizeImage as AnyObject, forKey: "original_size")
                             self.uploadData[0].updateValue("Image" as AnyObject, forKey: "type")
                             self.uploadData[0].updateValue((dataArray.first?["photo_id"]!)!, forKey: "photo_id")
                        
                           // uploadData[0].updateValue(<#T##value: Value##Value#>, forKey: <#T##Hashable#>)
                            
                        
                    case .failure(let error):
                        print("Request failed with error: \(error)")
                        }
                        
                        debugPrint(response)
                        
                        self.uploadOtherThenCoverPhoto()
                        
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
                
                
                for i in 1 ..< self.uploadData.count{
                    let element = self.uploadData[i]
                    var fName = ""
                    var mimeType = ""
                    if let type  =  (element as AnyObject).object(forKey: "type") as? String{
                        
                        if type == "Video" {
                            let urlName  =  (element as AnyObject).object(forKey: "video_url") as! URL
                            fName = "\(urlName)"
                            mimeType = "video/mp4"
                        }else if type == "Image" {
                            let urlName  =  (element as AnyObject).object(forKey: "item_url") as! String
                            fName = "\(urlName)"
                            mimeType = "image/jpeg"
                        }
                        
                    }
                    
                    let fileData  =  (element as AnyObject).object(forKey: "data") as! Data
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
                    upload.responseJSON { response in switch response.result {
                        case .success(let JSON):
                            print("Success with JSON: \(JSON)")
                            
                            let response = JSON as! NSDictionary
                        
                            
                            //example if there is an id
                          let dataArray = response.value(forKey: "details") as! [[String: AnyObject]]
                        
                            for (index,element) in dataArray.enumerated(){
                                if (element["photo_type"] as! Int) == 8{
                                    
                                    
                                    
                                    
                                    
                                    self.uploadData[index + 1].updateValue(element["photo_path"]!, forKey: "item_url")
                                    self.uploadData[index + 1].updateValue("" as AnyObject, forKey: "cover")
                                    self.uploadData[index + 1].updateValue(element["color_codes"] as AnyObject, forKey: "hexCode")
                                   // let height = element["imgHeight"] as! CGFloat
                                    //let width = CGFloat(375 - 10)
                                   // let sizeImage = CGSize(width: width, height: height)
                                    //self.uploadData[index + 1].updateValue(NSStringFromCGSize(sizeImage) as AnyObject, forKey: "item_size")
                                    //dictToAdd.updateValue(videoData as AnyObject, forKey: "data")
                                    self.uploadData[index + 1].updateValue(element["photo_path"]!, forKey: "video_url")
                                    self.uploadData[index + 1].updateValue("Video" as AnyObject, forKey: "type")
                                   // self.collectionArray.append(dictToAdd)
                                    
                                    
                                    
                                }else{
                                    self.uploadData[index + 1].updateValue(element["photo_path"]!, forKey: "cloudFilePath")
                                    self.uploadData[index + 1].updateValue(0 as AnyObject, forKey: "cover")
                                    self.uploadData[index + 1].updateValue(element["photo_path"]!, forKey: "filePath")
                                  //  self.uploadData[index + 1].updateValue( element["color_codes"]! , forKey: "hexCode")
                                     self.uploadData[index + 1].updateValue("#322e20,#d3d5db,#97989d,#aeb2b9,#858176" as AnyObject, forKey: "hexCode")
                                    let height = element["imgHeight"] as! CGFloat
                                    let width = element["imgWidth"] as! CGFloat
                                    let sizeImage = CGSize(width: width, height: height)
                                    self.uploadData[index + 1].updateValue(sizeImage as AnyObject, forKey: "item_size")
                                    self.uploadData[index + 1].updateValue(element["photo_path"]!, forKey: "item_url")
                                    self.uploadData[index + 1].removeValue(forKey: "data")
                                    //self.uploadData[0].updateValue(data as AnyObject, forKey: "data")
                                    self.uploadData[index + 1].updateValue(sizeImage as AnyObject, forKey: "original_size")
                                    self.uploadData[index + 1].updateValue("Image" as AnyObject, forKey: "type")
                                    self.uploadData[index + 1].updateValue(element["photo_id"]!, forKey: "photo_id")

                                }
                                
                    
                                
                            }
                        
                        
                        self.dismissView!(self,true,self.uploadData)
                            
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
        
        self.dismiss(animated: true, completion: nil)
        
        
    }


}
