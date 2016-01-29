//
//  ProfilePhotoViewController.swift
//  PicShare
//
//  Created by Yao Wang on 1/24/16.
//  Copyright © 2016 USC. All rights reserved.
//

import UIKit
import Parse

class ProfilePhotoViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {

    @IBOutlet weak var profilePhotoPreview: UIImageView!
    var profilePhoto: UIImage?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: - User Actions
    @IBAction func selectProfilePhoto(sender: UIButton) {
        let selector = UIImagePickerController()
        selector.delegate = self
        selector.sourceType = .PhotoLibrary
        presentViewController(selector, animated: true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController!, didFinishPickingImage image: UIImage!, editingInfo: NSDictionary!){
        self.dismissViewControllerAnimated(true, completion: { () -> Void in
            
        })
        
        profilePhotoPreview.image = image
        
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        let svc = segue.destinationViewController as! SignUpViewController
        if segue.identifier == "NoProfilePhoto" {
            svc.toPass = nil
        }
        else {
            svc.toPass = profilePhotoPreview.image
        }
    }
    
    
}
