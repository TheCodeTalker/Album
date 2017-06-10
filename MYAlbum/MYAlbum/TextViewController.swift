//
//  TextViewController.swift
//  MYAlbum
//
//  Created by Chitaranjan Sahu on 08/06/17.
//  Copyright © 2017 Ithink. All rights reserved.
//

import UIKit

protocol SaveDescriptionDelegate{
    func saveDescriptionDidFinish(_ controller:TextViewController,title:String,subtitle:String,indexToUpdate:Int)
}


class TextViewController: UIViewController {

   
    @IBOutlet weak var saveBtn: UIButton!
    @IBOutlet weak var subTitileView: SAMTextView!
    @IBOutlet weak var titleTextView: SAMTextView!
    var delegate:SaveDescriptionDelegate! = nil
    var titleText :String?
    var subTitleText:String?
    
    var selectedIndex :Int?
    override func viewDidLoad() {
        super.viewDidLoad()
        self.titleTextView.placeholder = "Title"
        self.subTitileView.placeholder = "Enter your story here"
        self.titleTextView.text = titleText
        self.subTitileView.text = subTitleText
        self.titleTextView.becomeFirstResponder()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func saveClicked(_ sender: UIButton) {
        delegate.saveDescriptionDidFinish(self, title: self.titleTextView.text, subtitle: self.subTitileView.text,indexToUpdate:selectedIndex!)
        self.dismiss(animated: true, completion: nil)
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
