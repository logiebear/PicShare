//
//  Utilities.swift
//  PicShare
//
//  Created by Logan Chang on 3/6/16.
//  Copyright © 2016 USC. All rights reserved.
//

import AVFoundation
import Reachability

func cameraAvailable() -> Bool {
    var available = true
    let status = AVCaptureDevice.authorizationStatusForMediaType(AVMediaTypeVideo)
    if status == .Denied || status == .Restricted {
        available = false
    } else if status == .NotDetermined {
        AVCaptureDevice.requestAccessForMediaType(AVMediaTypeVideo) { (granted) -> Void in
            if !granted {
                available = false
            }
        }
    }
    return available
}

func networkReachable() -> Bool {
    return Reachability.reachabilityForInternetConnection().currentReachabilityStatus() != .NotReachable
}