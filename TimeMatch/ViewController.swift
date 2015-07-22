//
//  ViewController.swift
//  TimeMatch
//
//  Created by Alexandre Yang on 7/13/15.
//  Copyright (c) 2015 Alex Yang. All rights reserved.
//

import UIKit

struct IndexRange {
    var start: Int
    var end: Int
}

let leftEdgeIndexes = [0, 6, 12, 18, 24, 30, 36, 42]
let rightEdgeIndexes = [5, 11, 17, 23, 29, 35, 41, 47]

let buttonColor = UIColor(red: 180/255, green: 180/255, blue: 180/255, alpha: 1.0)
let greenColor = UIColor(red: 46/255, green: 204/255, blue: 113/255, alpha: 1.0)
let blueColor = UIColor(red: 86/255, green: 212/255, blue: 243/255, alpha: 1.0)

class ViewController: UIViewController {
    
    var draggingOn: Bool = false
    var isOnButton: Bool = false
    var draggingInitiated: Bool = false
    var touchBegan: Bool = false
    var pathSplittable: Bool = false
    var isMerging: Bool = false
    
    var highlightedRange: IndexRange = IndexRange(start: 0, end: 0)
    
    var spacing: CGFloat! = 3
    var BUTTON_SIZE: CGFloat!
    
    var buttonsArray: [TimeButton] = [TimeButton]()
    
    var startButton: TimeButton?
    var endButton: TimeButton?
    
    struct Timeslot {
        var hour: Int
        var isHalf: Bool
        
        init(hour: Int, isHalf: Bool) {
            if hour > 23 || hour < 0 {
                self.hour = 0
            } else {
                self.hour = hour
            }
            
            self.isHalf = isHalf
        }

        func description() -> String {
            if isHalf == true {
                if hour > 9 {
                    return "\(String(hour)):30"
                } else {
                    return "0\(String(hour)):30"
                }
            } else {
                if hour > 9 {
                    return "\(String(hour)):00"
                } else {
                    return "0\(String(hour)):00"
                }
            }
        }
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadButtons()
    }

    func loadButtons() {
        
        // calculate button size
        // Formula: (screen width - margins - space that spacing take) == space buttons have available to occupy
        //          divide that by 6 and you get size of each individual button
        BUTTON_SIZE = self.view.frame.width - 16 - spacing*5
        BUTTON_SIZE = BUTTON_SIZE/6
        spacing = spacing + BUTTON_SIZE
        
        // create and fill up array of TimeSlots
        var timeslots: [Timeslot] = [Timeslot]()
        
        for i in 0..<24 {
            let tempTimeslot = Timeslot(hour: i, isHalf: false)
            timeslots.append(tempTimeslot)
            let tempTimeslotHalf = Timeslot(hour: i, isHalf: true)
            timeslots.append(tempTimeslotHalf)
        }
        
        
        // Load buttons from timeslots
        var currentY: CGFloat = UIApplication.sharedApplication().statusBarFrame.height + 50
        var currentX: CGFloat = 8
        var elementsInRow = 0
        
        for timeslot in timeslots {
            let newButton = buildTimeButton(timeslot.description(), atX: currentX, atY: currentY)
            self.view.addSubview(newButton)
            buttonsArray.append(newButton)
            
            elementsInRow++
            // if row is filled up
            if elementsInRow == 6 {
                currentY = currentY + CGFloat(BUTTON_SIZE+10)
                currentX = 8
                elementsInRow = 0
            } else {
                currentX = currentX + spacing
            }
        }
 
    }
    
    func buildTimeButton(withTitle: String, atX x: CGFloat, atY y: CGFloat) -> TimeButton {
        
        var newButton = TimeButton(frame: CGRectMake(x, y, CGFloat(BUTTON_SIZE), CGFloat(BUTTON_SIZE)))
        newButton.spacing = self.spacing
        newButton.backgroundColor = UIColor.whiteColor()
        newButton.layer.borderWidth = 2
        newButton.layer.borderColor = buttonColor.CGColor
        newButton.layer.cornerRadius = 0.5 * newButton.frame.size.width
        newButton.setTitle(withTitle, forState: UIControlState.Normal)
        newButton.titleLabel?.font = UIFont(name: "HelveticaNeue-Light", size: 16)
        newButton.setTitleColor(buttonColor, forState: UIControlState.Normal)
        
        newButton.userInteractionEnabled = false
        
        return newButton
    }
    
    
    func selectTime(sender:TimeButton!) {

        sender.selected = true
        
        if draggingOn {
            sender.timeState = .Handle
        } else {
            sender.timeState = .Single
        }
    }
    
    func unselectTime(sender: TimeButton!) {
        sender.leftHandle = nil
        sender.rightHandle = nil
        sender.matchingHandle = nil
        sender.selected = false
        sender.timeState = .Unselected
    }
    
    
    func turnToPath(button: TimeButton!, leftHandle: TimeButton!, rightHandle: TimeButton!) {
        
        // clear gap rectangles
        if button.timeState == .Handle {
            unjoinNeighboringHandles(button)
        }
        
        button.timeState = TimeButton.TimeState.Path
        
        // Set left and right handles
        button.leftHandle = leftHandle
        button.rightHandle = rightHandle
        
        // Customize edges
        if contains(leftEdgeIndexes, fromTimeToIndex(button)) {
            button.setBackgroundImage(UIImage(named: "ButtonEdgeLeft"), forState: .Selected)
            button.layer.borderColor = UIColor.clearColor().CGColor
        }
        if contains(rightEdgeIndexes, fromTimeToIndex(button)) {
            button.setBackgroundImage(UIImage(named: "ButtonEdgeRight"), forState: .Selected)
            button.layer.borderColor = UIColor.clearColor().CGColor
        }
        
        // Change color if in the middle of a merge
        if button == endButton {
            button.backgroundColor = UIColor(red: 137/255, green: 196/255, blue: 244/255, alpha: 1.0)
        }
        
    }
    
    // Adds a blue rectangle to the right of the button to fill in gap
    func joinNeighboringHandles(leftHandle: TimeButton) {
        if leftHandle.timeState == .Handle {
            var rightRectangle = UIView(frame: CGRectMake(leftHandle.frame.width, 0, spacing-CGFloat(BUTTON_SIZE), leftHandle.frame.height))
            rightRectangle.backgroundColor = blueColor
            rightRectangle.tag = 15
            leftHandle.addSubview(rightRectangle)
        }
    }
    
    // Removes blue rectangle from UIButton
    func unjoinNeighboringHandles(leftHandle: TimeButton) {
        for subview in leftHandle.subviews {
            if subview.tag == 15 {
                subview.removeFromSuperview()
            }
        }
    }
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        let touch = touches.first as! UITouch
        let viewPoint = touch.locationInView(self.view)
        
        // iterate through every button in array and check if touch is inside it
        for button in buttonsArray {
            // convert viewPoint to button's coordinate system
            let buttonPoint = button.convertPoint(viewPoint, fromView: self.view)
            
            if button.pointInside(buttonPoint, withEvent: event) {
                touchBegan = true
                isOnButton = true
                // if button is a handle
                if button.timeState == .Handle {
                    draggingOn = true
                    self.startButton = button.matchingHandle
                    self.endButton = button
                    highlightedRange.start = fromTimeToIndex(button.matchingHandle!)
                    highlightedRange.end = fromTimeToIndex(button)
                } else if button.timeState == .Path {
                    draggingOn = true
                    pathSplittable = true
                    self.endButton = button
                } else if button.timeState == .Single {
                    draggingOn = true
                    self.startButton = button
                    self.endButton = button
                    highlightedRange.start = fromTimeToIndex(button)
                    highlightedRange.end = fromTimeToIndex(button)
                } else {
                    selectTime(button)
                    self.startButton = button
                    self.endButton = button
                    highlightedRange.start = fromTimeToIndex(button)
                    highlightedRange.end = fromTimeToIndex(button)
                }
            }
        }
    }
    
    override func touchesMoved(touches: Set<NSObject>, withEvent event: UIEvent) {
        if touchBegan {
            let touch = touches.first as! UITouch
            let viewPoint = touch.locationInView(self.view)
            
            // if touch was already on top of a button
            if isOnButton {
                let endButton = self.endButton!
                let buttonPoint = endButton.convertPoint(viewPoint, fromView: self.view)
                
                // Exited button
                if !endButton.pointInside(buttonPoint, withEvent: event) {
                    if endButton.timeState == .Handle {
                        draggingInitiated = true
                    } else if endButton.timeState == .Path {
                        draggingInitiated = true
                    }
                    
                    // touched moved away from starting point
                    if endButton == startButton {
                        draggingOn = true
                        startButton?.timeState = .Handle
                        draggingInitiated = true
                    }
                    
                    isOnButton = false
                    
                }
            // else if touch was not on top of a button
            } else {
                for button in buttonsArray {
                    // convert point
                    let buttonPoint = button.convertPoint(viewPoint, fromView: self.view)
                    
                    // Entered button
                    if button.pointInside(buttonPoint, withEvent: event) {
                        isOnButton = true
                        let pastPosition = self.endButton
                        self.endButton = button
                        
                        
                        // Path moved code
                        if pastPosition!.timeState == .Path && pathSplittable == true {
                            let initialIndex = fromTimeToIndex(pastPosition!)
                            highlightedRange.end = initialIndex
                            let leftHandle = pastPosition!.leftHandle!
                            let rightHandle = pastPosition!.rightHandle!
                            // Check if drag was to the right or left to decide if startButton should be left or right handle
                            if fromTimeToIndex(self.endButton!) > initialIndex {    // drag right
                                self.startButton = rightHandle
                                highlightedRange.start = fromTimeToIndex(rightHandle)

                                selectTime(buttonsArray[initialIndex-1])
                                buttonsArray[initialIndex-1].matchingHandle = leftHandle
                                leftHandle.matchingHandle = buttonsArray[initialIndex-1]
                                highlightPathFrom(buttonsArray[initialIndex-1], toButton: leftHandle)
                            } else if fromTimeToIndex(self.endButton!) < initialIndex {     // drag left
                                self.startButton = pastPosition?.leftHandle
                                highlightedRange.start = fromTimeToIndex(self.startButton!)

                                selectTime(buttonsArray[initialIndex+1])
                                buttonsArray[initialIndex+1].matchingHandle = pastPosition?.rightHandle
                                pastPosition?.rightHandle?.matchingHandle = buttonsArray[initialIndex+1]
                                highlightPathFrom(buttonsArray[initialIndex+1], toButton: pastPosition?.rightHandle)
                            }
                            pathSplittable = false
                            
                        }
                        
                        if startButton == endButton {
                            draggingOn = false
                            startButton?.timeState = .Single
                        }
                        
                        // merging code
                        // if button was already selected and not within own time cluster
                        if (button.timeState == .Path || button.timeState == .Handle)  && !(numBetweenRangeInclusive(fromTimeToIndex(button), startRange: highlightedRange.start, endRange: highlightedRange.end)) {
                            isMerging = true
                            
                            if button.timeState == .Path {
                                if highlightedRange.start < fromTimeToIndex(button) {
                                    unhighlightOldPath(fromTimeToIndex(startButton!), endIndex: fromTimeToIndex(button.rightHandle!))
                                    highlightedRange.end = fromTimeToIndex(button.rightHandle!)
                                } else if highlightedRange.start > fromTimeToIndex(button) {
                                    unhighlightOldPath(fromTimeToIndex(startButton!), endIndex: fromTimeToIndex(button.leftHandle!))
                                    highlightedRange.end = fromTimeToIndex(button.leftHandle!)
                                }
                            } else if button.timeState == .Handle {
                                highlightedRange.end = fromTimeToIndex(button.matchingHandle!)
                            }
                        }
                        
                        if isMerging {
                            if !numBetweenRange(fromTimeToIndex(button), startRange: highlightedRange.start, endRange: highlightedRange.end) {
                                isMerging = false
                            } else {
                                if button.timeState == .Path {
                                    // highlight everything from our initial position to the end of the time cluster's right or left handle
                                    if highlightedRange.start < fromTimeToIndex(button) {
                                        highlightPathFrom(startButton, toButton: button.rightHandle)
                                        button.rightHandle?.matchingHandle = startButton
                                        startButton?.matchingHandle = button.rightHandle
                                        highlightedRange.end = fromTimeToIndex(button.rightHandle!)
                                    } else if highlightedRange.start > fromTimeToIndex(button) {
                                        highlightPathFrom(startButton, toButton: button.leftHandle)
                                        button.leftHandle?.matchingHandle = startButton
                                        startButton?.matchingHandle = button.leftHandle
                                        highlightedRange.end = fromTimeToIndex(button.leftHandle!)
                                    }
                                } else if button.timeState == .Handle {
                                    highlightPathFrom(startButton, toButton: button.matchingHandle)
                                    startButton?.matchingHandle = button.matchingHandle
                                    button.matchingHandle?.matchingHandle = startButton
                                    highlightedRange.end = fromTimeToIndex(button.matchingHandle!)
                                }
                            }
                            
                        }
                        
                        if !isMerging {
                            selectTime(button)
                            highlightPathFrom(startButton, toButton: endButton)
                            unhighlightOldPath(fromTimeToIndex(startButton!), endIndex: fromTimeToIndex(endButton!))
                            highlightedRange.end = fromTimeToIndex(button)
                        }
                        
                        break
                    }
                }
            }
        }
    }
    
    override func touchesEnded(touches: Set<NSObject>, withEvent event: UIEvent) {
        if touchBegan {
            
            if draggingInitiated == false && draggingOn == true  {
                if let endButton = self.endButton {
                    if endButton.timeState == .Handle {
                        deselectHandleHelper(endButton)
                        unselectTime(endButton)
                    } else if endButton.timeState == .Single {
                        unselectTime(endButton)
                    } else if endButton.timeState == .Path {
                        splitPath(from: endButton)
                        unselectTime(endButton)
                    }
                }
                
            } else {
                // set matching handles
                if endButton!.timeState != .Path {  // necessary for when user lift finger mid-merging
                    if startButton != endButton {
                        self.startButton?.matchingHandle = endButton
                        self.endButton?.matchingHandle = startButton
                    }
                }
            }
           
            // when path is in middle of merge
            if endButton?.timeState == .Path {
                // revert to normal blue color
                endButton?.backgroundColor = blueColor
            }
            
            highlightedRange.start = 0
            highlightedRange.end = 0
            endButton = nil
            draggingInitiated = false
            self.startButton = nil
            isOnButton = false
            draggingOn = false
            touchBegan = false
            isMerging = false
            pathSplittable = false
        }
    }
    
    func deselectHandleHelper(handleButton: TimeButton) {
        let handleIndex = fromTimeToIndex(handleButton)
        let matchingIndex = fromTimeToIndex(handleButton.matchingHandle!)
        // check if handle is left or right handle
        if matchingIndex < handleIndex {      // right handle
            if buttonsArray[handleIndex-1].timeState == .Handle {
                unjoinNeighboringHandles(buttonsArray[matchingIndex])
                buttonsArray[handleIndex-1].timeState = .Single
            } else {
                buttonsArray[handleIndex-1].timeState = .Handle
                buttonsArray[handleIndex-1].matchingHandle = handleButton.matchingHandle
                handleButton.matchingHandle?.matchingHandle = buttonsArray[handleIndex-1]
                highlightPathFrom(buttonsArray[handleIndex-1], toButton: handleButton.matchingHandle)
            }
        } else if matchingIndex > handleIndex {     // left handle
            if buttonsArray[handleIndex+1].timeState == .Handle {
                unjoinNeighboringHandles(buttonsArray[handleIndex])
                buttonsArray[handleIndex+1].timeState = .Single
            } else {
                buttonsArray[handleIndex+1].timeState = .Handle
                buttonsArray[handleIndex+1].matchingHandle = handleButton.matchingHandle
                handleButton.matchingHandle?.matchingHandle = buttonsArray[handleIndex+1]
                highlightPathFrom(buttonsArray[handleIndex+1], toButton: handleButton.matchingHandle!)
            }
        }
    }
    
    func splitPath(from button: TimeButton) {
        let buttonIndex = fromTimeToIndex(button)
        // get left and right handles
        let leftHandle = button.leftHandle
        let rightHandle = button.rightHandle
        
        // update left side
        // check if left side is not just a single handle
        if buttonsArray[buttonIndex-1].timeState == .Handle {
            buttonsArray[buttonIndex-1].timeState = .Single
        } else {
            buttonsArray[buttonIndex-1].timeState = .Handle
            buttonsArray[buttonIndex-1].matchingHandle = leftHandle
            leftHandle?.matchingHandle = buttonsArray[buttonIndex-1]
            highlightPathFrom(buttonsArray[buttonIndex-1], toButton: leftHandle)
        }
        // update right side
        // check if right side is not a handle
        if buttonsArray[buttonIndex+1].timeState == .Handle {
            buttonsArray[buttonIndex+1].timeState = .Single
        } else {
            buttonsArray[buttonIndex+1].timeState = .Handle
            buttonsArray[buttonIndex+1].matchingHandle = rightHandle
            rightHandle?.matchingHandle = buttonsArray[buttonIndex+1]
            highlightPathFrom(buttonsArray[buttonIndex+1], toButton: rightHandle)
        }
    }

    func highlightPathFrom(startButton: TimeButton!, toButton endButton: TimeButton!) {
    
        let startIndex = fromTimeToIndex(startButton)
        let endIndex = fromTimeToIndex(endButton)
        
        // if the startButton is not the same as endButton
        if startIndex != endIndex {
            startButton.setTitleColor(buttonColor, forState: .Selected)
            endButton.setTitleColor(buttonColor, forState: .Selected)
            
            // Redesigning handles
            if endIndex > startIndex {
                // first check if startButton is at a right edge
                if contains(rightEdgeIndexes, startIndex) {
                    startButton.setBackgroundImage(UIImage(named: "ButtonEdgeHandle"), forState: .Selected)
                } else {
                    startButton.setBackgroundImage(UIImage(named: "ButtonHandleLeft"), forState: .Selected)
                }
                
                if !isMerging {
                    // first check if endButton is at a left edge
                    if contains(leftEdgeIndexes, endIndex) {
                        endButton.setBackgroundImage(UIImage(named: "ButtonEdgeHandle"), forState: .Selected)
                    } else {
                        endButton.setBackgroundImage(UIImage(named: "ButtonHandleRight"), forState: .Selected)
                    }
                }
            } else if endIndex < startIndex {
                // first check if startButton is at a left edge
                if contains(leftEdgeIndexes, startIndex) {
                    startButton.setBackgroundImage(UIImage(named: "ButtonEdgeHandle"), forState: .Selected)
                } else {
                    startButton.setBackgroundImage(UIImage(named: "ButtonHandleRight"), forState: .Selected)
                }
                
                if !isMerging {
                // first check if endButton is at a right edge
                    if contains(rightEdgeIndexes, endIndex) {
                        endButton.setBackgroundImage(UIImage(named: "ButtonEdgeHandle"), forState: .Selected)
                    } else {
                        endButton.setBackgroundImage(UIImage(named:"ButtonHandleLeft"), forState: .Selected)
                    }
                }
            }
        } else {    // startIndex == endIndex
            startButton.layer.borderColor = blueColor.CGColor
            startButton.layer.cornerRadius = 0.5 * startButton.frame.size.width
            startButton.backgroundColor = blueColor
            startButton.setBackgroundImage(nil, forState: .Selected)
            startButton.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Selected)
        }
        
        // Making paths
        if endIndex > startIndex {  // Touch is after starting point
            for i in startIndex+1..<endIndex {
                turnToPath(buttonsArray[i], leftHandle: startButton, rightHandle: endButton)
            }
        } else if endIndex < startIndex {   // Touch is behind starting point
            for i in endIndex+1..<startIndex {
                turnToPath(buttonsArray[i], leftHandle: endButton, rightHandle: startButton)
            }
        }
       
        // check neighboring handles
        if abs(startIndex-endIndex) == 1 {
            if rowFromIndex(startIndex) == rowFromIndex(endIndex)  {
                if startIndex > endIndex {
                    joinNeighboringHandles(endButton)
                } else if startIndex < endIndex {
                    joinNeighboringHandles(startButton)
                }
            }
        } else {
            // clear up extra rectangles
            if startIndex != 0 {
                unjoinNeighboringHandles(buttonsArray[startIndex-1])
            }
            unjoinNeighboringHandles(startButton)
            unjoinNeighboringHandles(endButton)
        }
 
    }
    
    func unhighlightOldPath(startIndex: Int, endIndex: Int) {
        // After startIndex, moving to after startIndex but lower index
        if highlightedRange.end > startIndex && endIndex > startIndex && endIndex < highlightedRange.end {
            for i in endIndex+1...highlightedRange.end {
                unselectTime(buttonsArray[i])
            }
        }
        
        // Moving from after startIndex to somewhere before startIndex
        if highlightedRange.end > startIndex && endIndex < startIndex {
            for i in startIndex+1...highlightedRange.end {
                unselectTime(buttonsArray[i])
            }
        }
        
        // Moving from before startIndex to somewhere before startIndex but higher index
        if highlightedRange.end < startIndex && endIndex < startIndex && endIndex > highlightedRange.end {
            for i in highlightedRange.end..<endIndex {
                unselectTime(buttonsArray[i])
            }
        }
        
        // Move from before startIndex to somewhere after startIndex
        if highlightedRange.end < startIndex && endIndex > startIndex {
            for i in highlightedRange.end..<startIndex {
                unselectTime(buttonsArray[i])
            }
        }
        
        // Move from somewhere directly to startbutton
        if startIndex == endIndex {
            if highlightedRange.end > startIndex {
                for i in startIndex+1...highlightedRange.end {
                    unselectTime(buttonsArray[i])
                }
            } else if highlightedRange.end < startIndex {
                for i in highlightedRange.end..<startIndex {
                    unselectTime(buttonsArray[i])
                }
            }
        }
    }
    
    
    func fromTimeToIndex(timeButton: TimeButton) -> Int {
        let time = timeButton.titleLabel!.text!
        var timeArray = time.componentsSeparatedByString(":")
        
        let hour = Int(timeArray[0].toInt()!)
        let minute = Int(timeArray[1].toInt()!)
        
        if minute != 0 {
            return hour*2 + 1
        } else {
            return hour*2
        }
    }
    
    func numBetweenRange(num: Int, startRange: Int, endRange: Int) -> Bool {
        if startRange < endRange {
            return startRange+1..<endRange ~= num
        } else if startRange > endRange {
            return endRange+1..<startRange ~= num
        } else {
            return false
        }
    }
    
    func numBetweenRangeInclusive(num: Int, startRange: Int, endRange: Int) -> Bool {
        if startRange < endRange {
            return startRange...endRange ~= num
        } else if startRange > endRange {
            return endRange...startRange ~= num
        } else {
            return false
        }

    }
    
    func rowFromIndex(index: Int) -> Int {
        switch index {
        case 0...5:
            return 0
        case 6...11:
            return 1
        case 12...17:
            return 2
        case 18...23:
            return 3
        case 24...29:
            return 4
        case 30...35:
            return 5
        case 36...41:
            return 6
        case 42...47:
            return 7
        default:
            return -1
        }
    }
    
}












