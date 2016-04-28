//
//  UIImageExtension.swift
//  PicShare
//
//  Created by Logan Chang on 4/4/16.
//  Copyright © 2016 USC. All rights reserved.
//

import Foundation

extension UIImage {
    
    /**
        Crops the image to a square based on the larger dimension
     */
    func cropToSquare() -> UIImage {
        // Create a copy of the image without the imageOrientation property so it is in its native orientation (landscape)
        let contextImage = UIImage(CGImage: self.CGImage!)
        
        // Get the size of the contextImage
        let contextSize = contextImage.size
        let posX: CGFloat
        let posY: CGFloat
        let width: CGFloat
        let height: CGFloat
        
        // Check to see which length is the longest and create the offset based on that length, then set the width and height of our rect
        if contextSize.width > contextSize.height {
            posX = 0
            posY = 0
            width = contextSize.height
            height = contextSize.height
        } else {
            posX = 0
            posY = 0
            width = contextSize.width
            height = contextSize.width
        }
        
        let rect = CGRectMake(posX, posY, width, height)
        
        // Create bitmap image from context using the rect
        let imageRef = CGImageCreateWithImageInRect(contextImage.CGImage, rect)!
        
        // Create a new image based on the imageRef and rotate back to the original orientation
        let image = UIImage(CGImage: imageRef, scale: self.scale, orientation: self.imageOrientation)
        
        return image
    }
    
}