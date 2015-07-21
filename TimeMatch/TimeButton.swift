//
//  TimeButton.swift
//  TimeMatch
//
//  Created by Alexandre Yang on 7/15/15.
//  Copyright (c) 2015 Alex Yang. All rights reserved.
//

import UIKit

class TimeButton: UIButton {
    
    // Used only if handle
    var matchingHandle: TimeButton?
    
    // keep spacing constant
    var spacing: CGFloat?
    
    enum TimeState {
        case Single, Handle, Path, Unselected
    }
    
    var timeState: TimeState = .Unselected {
        didSet {
            // fix positioning for when button was a path
            if oldValue == .Path {
            
            }
            
            if timeState == .Single {
                
            } else if timeState == .Handle {
                
            } else if timeState == .Path {
                
            } else if timeState == .Unselected {
                
            }
        }
    }
   
    // Use for paths
    var leftHandle: TimeButton?
    var rightHandle: TimeButton?
   
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

}
