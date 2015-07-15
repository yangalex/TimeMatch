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

class ViewController: UIViewController {
    
    var highlightedRange: IndexRange = IndexRange(start: 0, end: 0)
    
    var spacing: CGFloat!
    
    var buttonsArray: [UIButton] = [UIButton]()
    
    var startButton: UIButton?
    var endButton: UIButton?
    
    let buttonColor = UIColor(red: 180/255, green: 180/255, blue: 180/255, alpha: 1.0)
    let greenColor = UIColor(red: 46/255, green: 204/255, blue: 113/255, alpha: 1.0)
    let blueColor = UIColor(red: 86/255, green: 212/255, blue: 243/255, alpha: 1.0)
    
    let BUTTON_SIZE = 55
    
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
        
        // calculate spacing
        // Formula: view Width - left and right margins - all buttons sizes = total free space between buttons
        // then divide total free space by 5 to get size between each button
        spacing = self.view.frame.width - 16
        spacing = spacing - CGFloat(6*BUTTON_SIZE)
        spacing = spacing/5
        spacing = spacing + CGFloat(BUTTON_SIZE)
        
        // create and fill up array of TimeSlots
        var timeslots: [Timeslot] = [Timeslot]()
        
        for i in 0..<24 {
            let tempTimeslot = Timeslot(hour: i, isHalf: false)
            timeslots.append(tempTimeslot)
            let tempTimeslotHalf = Timeslot(hour: i, isHalf: true)
            timeslots.append(tempTimeslotHalf)
        }
        
        
        // Load buttons from timeslots
        var currentY: CGFloat = UIApplication.sharedApplication().statusBarFrame.height
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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func buildTimeButton(withTitle: String, atX x: CGFloat, atY y: CGFloat) -> UIButton {
        
        var newButton = UIButton(frame: CGRectMake(x, y, CGFloat(BUTTON_SIZE), CGFloat(BUTTON_SIZE)))
        newButton.backgroundColor = UIColor.whiteColor()
        newButton.layer.borderWidth = 3
        newButton.layer.borderColor = buttonColor.CGColor
        newButton.layer.cornerRadius = 0.5 * newButton.frame.size.width
        newButton.setTitle(withTitle, forState: UIControlState.Normal)
        newButton.titleLabel?.font = UIFont(name: "Helvetica-Bold", size: 17)
        newButton.setTitleColor(buttonColor, forState: UIControlState.Normal)
        
        newButton.userInteractionEnabled = false
        
        return newButton
    }
    
    
    func timeSelected(sender: UIButton!) {
        if sender.selected == false {
            sender.layer.borderColor = blueColor.CGColor
            sender.backgroundColor = blueColor
            sender.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
            sender.selected = true
        } else {
            sender.layer.borderColor = buttonColor.CGColor
            sender.backgroundColor = UIColor.whiteColor()
            sender.setTitleColor(buttonColor, forState: UIControlState.Normal)
            sender.selected = false
        }
    }
    
    func selectTime(sender:UIButton!) {
        sender.layer.borderColor = blueColor.CGColor
        sender.layer.cornerRadius = 0.5 * sender.frame.size.width
        sender.backgroundColor = blueColor
        sender.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        sender.selected = true
    }
    
    func unselectTime(sender: UIButton!) {
        sender.selected = false
        sender.frame.size = CGSizeMake(CGFloat(BUTTON_SIZE), CGFloat(BUTTON_SIZE))
        sender.layer.cornerRadius = 0.5 * sender.frame.size.width
        sender.layer.borderColor = buttonColor.CGColor
        sender.backgroundColor = UIColor.whiteColor()
        sender.setTitleColor(buttonColor, forState: UIControlState.Normal)
    }
    
    
    func timeDraggedInto(sender: UIButton!) {
        if sender.selected != true {
            let lightBlueColor = UIColor(red: 121/255, green: 219/255, blue: 243/255, alpha: 1.0)
            sender.layer.borderColor = lightBlueColor.CGColor
            sender.layer.cornerRadius = 0
            sender.backgroundColor = lightBlueColor
            sender.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
            sender.selected = true
            
            // change size of button
            sender.frame = CGRectMake(sender.frame.origin.x - (spacing - CGFloat(BUTTON_SIZE)), sender.frame.origin.y, sender.frame.width + (spacing - CGFloat(BUTTON_SIZE))*2, sender.frame.height)
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
                self.startButton = button
                highlightedRange.start = fromTimeToIndex(button.titleLabel!.text!)
                highlightedRange.end = fromTimeToIndex(button.titleLabel!.text!)
                self.endButton = button
                
                if button.selected {
                    unselectTime(button)
                } else {
                    selectTime(button)
                }
                println("Touched \(button.titleLabel!.text!)")
            }
        }
    }
    
    override func touchesMoved(touches: Set<NSObject>, withEvent event: UIEvent) {
        let touch = touches.first as! UITouch
        let viewPoint = touch.locationInView(self.view)
        
        // if touch was already on top of a button
        if let endButton = self.endButton {
            let buttonPoint = endButton.convertPoint(viewPoint, fromView: self.view)
            
            // Exited button
            if !endButton.pointInside(buttonPoint, withEvent: event) {
                if endButton != startButton {
                    unselectTime(endButton)
                }
                self.endButton = nil
            }
        // else if touch was not on top of a button
        } else {
            var isInButton = false
            for button in buttonsArray {
                // convert point
                let buttonPoint = button.convertPoint(viewPoint, fromView: self.view)
                
                // Entered button
                if button.pointInside(buttonPoint, withEvent: event) {
                    isInButton = true
                    self.endButton = button
                    selectTime(button)
       
                    highlightPathFrom(startButton, toButton: endButton)
                    highlightedRange.end = fromTimeToIndex(button.titleLabel!.text!)
                    break
                }
            }
            
            if !isInButton {
                //println("Not in any button")
            }
        }
    }
    
    override func touchesEnded(touches: Set<NSObject>, withEvent event: UIEvent) {
        highlightedRange.start = -1
        highlightedRange.end = -1
        endButton = nil
        startButton = nil
    }

    func highlightPathFrom(startButton: UIButton!, toButton endButton: UIButton!) {
    
        let startIndex = fromTimeToIndex(startButton.titleLabel!.text!)
        let endIndex = fromTimeToIndex(endButton.titleLabel!.text!)
        
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

        // Actual highlighting code
        if endIndex > startIndex {  // Touch is behind starting point
            for i in startIndex+1..<endIndex {
                timeDraggedInto(buttonsArray[i])
            }
        } else if endIndex < startIndex {   // Touch is after starting point
            for i in endIndex+1..<startIndex {
                timeDraggedInto(buttonsArray[i])
            }
        }
    }
    
    func fromTimeToIndex(time: String) -> Int {
        var timeArray = time.componentsSeparatedByString(":")
        
        let hour = Int(timeArray[0].toInt()!)
        let minute = Int(timeArray[1].toInt()!)
        
        if minute != 0 {
            return hour*2 + 1
        } else {
            return hour*2
        }
    }

}












