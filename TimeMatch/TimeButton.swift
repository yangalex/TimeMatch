//
//  TimeButton.swift
//  TimeMatch
//
//  Created by Alexandre Yang on 7/15/15.
//  Copyright (c) 2015 Alex Yang. All rights reserved.
//

import UIKit

class TimeButton: UIButton {
    
    var isHandle: Bool = false
    var matchingHandle: TimeButton?
    var isSingle: Bool = false
    
    enum TimeState {
        case Single, Handle, Path, Unselected
    }
    
    var timeState: TimeState = .Unselected
   
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

}
