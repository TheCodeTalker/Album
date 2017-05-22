//
//  ImagesUploadProgressViewController.swift
//  MYAlbum
//
//  Created by Chitaranjan Sahu on 20/05/17.
//  Copyright © 2017 Ithink. All rights reserved.
//

import UIKit

class ImagesUploadProgressViewController: UIViewController {

    @IBOutlet weak var uploadingText: UILabel!
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var percentageProgressLabel: UILabel!
    @IBOutlet weak var falseUploadText: UILabel!
    @IBOutlet weak var countProgressLabel: UILabel!
    @IBOutlet weak var closeBtn: UIButton!
    
    var storyId:String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()


        self.progressView.progress = 0.0
        self.percentageProgressLabel.text = "0 %"
        self.uploadingText.text = "we are processing your upload,please wait."
        self.falseUploadText.text = ""
        
        
        
    }
    
    
//    func uploadImageses()
//    {
//        Alamofire.upload(multipartFormData: { (multipartFormData) in
//            multipartFormData.append(UIImageJPEGRepresentation(self.photoImageView.image!, 0.5)!, withName: "photo_path", fileName: "swift_file.jpeg", mimeType: "image/jpeg")
//            for (key, value) in parameters {
//                multipartFormData.append(value.data(using: String.Encoding.utf8)!, withName: key)
//            }
//        }, to:"http://192.168.1.41:8000/photosUpload/\(storyId)/1")
//        { (result) in
//            switch result {
//            case .success(let upload, _, _):
//                
//                upload.uploadProgress(closure: { (Progress) in
//                    print("Upload Progress: \(Progress.fractionCompleted)")
//                })
//                
//                upload.responseJSON { response in
//                    //self.delegate?.showSuccessAlert()
//                    print(response.request)  // original URL request
//                    print(response.response) // URL response
//                    print(response.data)     // server data
//                    print(response.result)   // result of response serialization
//                    //                        self.showSuccesAlert()
//                    //self.removeImage("frame", fileExtension: "txt")
//                    if let JSON = response.result.value {
//                        print("JSON: \(JSON)")
//                    }
//                }
//                
//            case .failure(let encodingError):
//                //self.delegate?.showFailAlert()
//                print(encodingError)
//            }
//            
//        }
//    }
//
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func closeProgress(_ sender: UIButton) {
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
