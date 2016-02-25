//
//  AddPhotoViewController.swift
//  PicShare
//
//  Created by ZhouJiashun on 2/20/16.
//  Copyright © 2016 USC. All rights reserved.
//

import UIKit

class AddPhotoViewController: UIViewController {

    
    // MARK: - Properties
    @IBOutlet weak var congratsLabel: UILabel!
    @IBOutlet weak var firstHalfTextField: UITextView!
    @IBOutlet weak var takePhotoButton: UIButton!
    @IBOutlet weak var cameraRollButton: UIButton!
    @IBOutlet weak var eventNameLabel: UILabel!
    @IBOutlet weak var secondHalfTextField: UITextView!
    
    var hashtag = String()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        /*if !UIImagePickerController.isSourceTypeAvailable(.Camera) {
            takePhotoButton.hidden = true // check if device have camera
        }
        */
        eventNameLabel.text = hashtag
    }

    /*override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if sengue.identifier ==
        
    }*/
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    // MARK: - User Actions
    
    @IBAction func takePhotoButtonPressed(sender: AnyObject) {
    }
    @IBAction func cameraRollButtonPressed(sender: AnyObject) {
    }
    @IBAction func backButtonPressed(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }

}
