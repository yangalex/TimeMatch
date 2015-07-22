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
                self.frame = CGRectMake(self.frame.origin.x + (spacing! - CGFloat(self.frame.size.height)), self.frame.origin.y, CGFloat(self.frame.size.height), CGFloat(self.frame.size.height))
                self.layer.cornerRadius = 0.5 * self.frame.size.width
            }
            
            if timeState == .Single {
                self.layer.borderColor = blueColor.CGColor
                self.layer.cornerRadius = 0.5 * self.frame.size.width
                self.backgroundColor = blueColor
                self.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Selected)
                self.setBackgroundImage(nil, forState: .Selected)
            } else if timeState == .Handle {
                self.layer.borderColor = UIColor.clearColor().CGColor
            } else if timeState == .Path {
                let lightBlueColor = UIColor(red: 121/255, green: 219/255, blue: 243/255, alpha: 1.0)
                self.layer.borderColor = blueColor.CGColor
                self.layer.cornerRadius = 0
                self.backgroundColor = blueColor
                self.setBackgroundImage(nil, forState: .Selected)
                self.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Selected)
                self.selected = true
                
                // change size of button
                self.frame = CGRectMake(self.frame.origin.x - (spacing! - CGFloat(self.frame.size.height)), self.frame.origin.y, self.frame.width + (spacing! - CGFloat(self.frame.size.height))*2, self.frame.height)
                
            } else if timeState == .Unselected {
                self.layer.cornerRadius = 0.5 * self.frame.size.width
                self.layer.borderColor = buttonColor.CGColor
                self.backgroundColor = UIColor.whiteColor()
                self.setTitleColor(buttonColor, forState: UIControlState.Normal)
                self.setBackgroundImage(nil, forState: .Selected)
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
