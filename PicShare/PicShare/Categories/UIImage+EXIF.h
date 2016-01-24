//
//  UIImage+EXIF.h
//  PicShare
//
//  Created by Logan Chang on 11/19/15.
//  Copyright © 2015 USC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (EXIF)

- (UIImage *)scaleAndRotateImage:(NSInteger)maxRes;

@end
