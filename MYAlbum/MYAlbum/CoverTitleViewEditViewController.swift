//
//  CoverTitleViewEditViewController.swift
//  MYAlbum
//
//  Created by Chitaranjan Sahu on 14/06/17.
//  Copyright © 2017 Ithink. All rights reserved.
//

import UIKit

protocol SaveCoverTitleDelegate{
    func saveCoverTitleDidFinish(_ controller:CoverTitleViewEditViewController,title:String,subtitle:String)
}

class CoverTitleViewEditViewController: UIViewController,UITextFieldDelegate {

    @IBOutlet weak var storyTitle: UITextField!
   var delegate:SaveCoverTitleDelegate! = nil
    
    @IBOutlet weak var storySubtitle: UITextField!
    @IBOutlet weak var coverImage: UIImageView!
    
    var titleText = ""
    var subTitleText = ""
    var coverImageView :UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.storyTitle.delegate = self
        self.storySubtitle.delegate = self
        if titleText != "" {
            self.storyTitle.text = titleText
        }
        if subTitleText != ""{
            self.storySubtitle.text = subTitleText
        }
        if let coverImage = self.coverImageView{
            self.coverImage.image = coverImage
        }
        
        self.storyTitle.becomeFirstResponder()
                // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if textField == storyTitle{
            storySubtitle.becomeFirstResponder()
            //textField.becomeFirstResponder()
        }
        if textField == storySubtitle{
            
            if textField.hasText {
                subTitleText = textField.text!
            }
            delegate.saveCoverTitleDidFinish(self, title: titleText, subtitle: subTitleText)
            self.dismiss(animated: true, completion: nil)
        }
        
        return true

    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == storySubtitle{
            if textField.hasText{
                subTitleText = textField.text!
            }
            
            
        }
        else if textField == storyTitle{
            if textField.hasText {
                titleText = textField.text!
            }
    }

    }
    
    
    @IBAction func saveClicked(_ sender: UIButton) {
        delegate.saveCoverTitleDidFinish(self, title: titleText, subtitle: subTitleText)
        self.dismiss(animated: true, completion: nil)
    }

   
}
