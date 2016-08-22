/*
Copyright 2015 NEOPIXL S.A.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/

import UIKit

public enum CursorPosition
{
    case Top
    case Bottom
}

public class NPSegmentedControl : UIControl {
    private var views = [UIView]()
    private var labels = [UILabel]()
    public var cursor:UIView?
    {
        didSet{
            if views.count > 0
            {
                self.setItems(items)
                if let cur = oldValue
                {
                    cur.removeFromSuperview()
                }
            }
        }
    }

    public var cursorPosition:CursorPosition = CursorPosition.Bottom
    {
        didSet{
            if views.count > 0
            {
                self.setItems(items)
            }
        }

    }

    private var animationChecks = [Bool]()

    private var items:[String]!

    private var currentIndex:Int = 0

    public var selectedColor:UIColor? = UIColor.lightGrayColor()
    {
        didSet{
            if self.currentIndex <= views.count - 1 && self.currentIndex >= 0
            {
                let view = views[self.currentIndex]
                view.backgroundColor = self.selectedColor
            }
        }
    }

    public var selectedTextColor:UIColor?
        {
        didSet{
            if self.currentIndex <= views.count - 1 && self.currentIndex >= 0
            {
                let lab = labels[self.currentIndex]
                lab.textColor = self.selectedTextColor
            }
        }
    }

    public var unselectedColor:UIColor? = UIColor.grayColor()
        {
        didSet{

            for index in 0..<views.count
            {
                if(index != self.currentIndex)
                {
                    let view = views[index]
                    view.backgroundColor = self.unselectedColor
                }
            }
        }
    }

    public var unselectedTextColor:UIColor?
        {
        didSet{
            for index in 0..<views.count
            {
                if(index != self.currentIndex)
                {
                    let lab = labels[index]
                    lab.textColor = self.unselectedTextColor
                }
            }
        }
    }

    public var selectedFont:UIFont?
        {
        didSet{
            if self.currentIndex <= views.count - 1 && self.currentIndex >= 0
            {
                let lab = labels[self.currentIndex]
                lab.font = self.selectedFont
            }
        }
    }

    public var unselectedFont:UIFont?
        {
        didSet{
            for index in 0..<views.count
            {
                if(index != self.currentIndex)
                {
                    let lab = labels[index]
                    lab.font = self.unselectedFont
                }
            }
        }
    }

    private var cursorCenterXConstraint:NSLayoutConstraint!

    private var tapGestureRecogniser:UITapGestureRecognizer!

    private func initComponents()
    {
        tapGestureRecogniser = UITapGestureRecognizer(target: self, action: #selector(NPSegmentedControl.didTap(_:)))
        self.addGestureRecognizer(tapGestureRecogniser)
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.initComponents()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.initComponents()
    }

    public func setItems(items:[String])
    {
        self.items = items
        var previousView:UIView?

        for lab in labels
        {
            lab.removeFromSuperview()
        }

        for view in views
        {
            view.removeFromSuperview()
        }
        if let cur = cursor
        {
            cur.removeFromSuperview()
        }
        labels.removeAll(keepCapacity: false)
        views.removeAll(keepCapacity: false)

        for i in 0..<items.count
        {
            let view = UIView()
            view.backgroundColor = unselectedColor
            self.addSubview(view)
            views.append(view)
            let label = UILabel()
            label.text = items[i]
            label.textColor = unselectedTextColor
            if let font = unselectedFont
            {
                label.font = font
            }
            view.addSubview(label)
            labels.append(label)
            label.translatesAutoresizingMaskIntoConstraints = false
            var itemHeight = self.frame.height
            if let cur = self.cursor
            {
                itemHeight -= cur.frame.height
            }

            let centerXConstraint = NSLayoutConstraint(item:label,
                attribute:NSLayoutAttribute.CenterX,
                relatedBy:NSLayoutRelation.Equal,
                toItem:view,
                attribute:NSLayoutAttribute.CenterX,
                multiplier:1,
                constant:0)
            view.addConstraint(centerXConstraint)

            let centerYConstraint = NSLayoutConstraint(item:label,
                attribute:NSLayoutAttribute.CenterY,
                relatedBy:NSLayoutRelation.Equal,
                toItem:view,
                attribute:NSLayoutAttribute.CenterY,
                multiplier:1,
                constant:0)
            view.addConstraint(centerYConstraint)


            view.translatesAutoresizingMaskIntoConstraints = false
            let viewDict = [ "view" : view ]

            let constraints = NSLayoutConstraint.constraintsWithVisualFormat("V:[view(\(itemHeight))]", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: viewDict)
            view.addConstraints(constraints)

            if let previous = previousView
            {
                let leftConstraint = NSLayoutConstraint(item:view,
                    attribute:NSLayoutAttribute.Left,
                    relatedBy:NSLayoutRelation.Equal,
                    toItem:previous,
                    attribute:NSLayoutAttribute.Right,
                    multiplier:1,
                    constant:0)
                self.addConstraint(leftConstraint)

                let widthConstraint = NSLayoutConstraint(item:view,
                    attribute:NSLayoutAttribute.Width,
                    relatedBy:NSLayoutRelation.Equal,
                    toItem:previous,
                    attribute:NSLayoutAttribute.Width,
                    multiplier:1,
                    constant:0)
                self.addConstraint(widthConstraint)
            }
            else
            {
                let leftConstraint = NSLayoutConstraint(item:view,
                    attribute:NSLayoutAttribute.Left,
                    relatedBy:NSLayoutRelation.Equal,
                    toItem:self,
                    attribute:NSLayoutAttribute.Left,
                    multiplier:1.0,
                    constant:0)
                self.addConstraint(leftConstraint)
            }


            if(cursorPosition == CursorPosition.Top)
            {
                let bottomConstraint = NSLayoutConstraint(item:view,
                    attribute:NSLayoutAttribute.Bottom,
                    relatedBy:NSLayoutRelation.Equal,
                    toItem:self,
                    attribute:NSLayoutAttribute.Bottom,
                    multiplier:1.0,
                    constant:0)

                self.addConstraint(bottomConstraint)
            }
            else
            {
                let topConstraint = NSLayoutConstraint(item:view,
                    attribute:NSLayoutAttribute.Top,
                    relatedBy:NSLayoutRelation.Equal,
                    toItem:self,
                    attribute:NSLayoutAttribute.Top,
                    multiplier:1.0,
                    constant:0)

                self.addConstraint(topConstraint)
            }
            previousView = view
        }
        if let previous = previousView
        {
            let leftConstraint = NSLayoutConstraint(item:previous,
                attribute:NSLayoutAttribute.Right,
                relatedBy:NSLayoutRelation.Equal,
                toItem:self,
                attribute:NSLayoutAttribute.Right,
                multiplier:1.0,
                constant:0)
            self.addConstraint(leftConstraint)
        }
        if let cur = cursor
        {
        cur.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(cur)

        let bottomConstraint = NSLayoutConstraint(item:cur,
            attribute:NSLayoutAttribute.Bottom,
            relatedBy:NSLayoutRelation.Equal,
            toItem:self,
            attribute:NSLayoutAttribute.Bottom,
            multiplier:1.0,
            constant:0)
        self.addConstraint(bottomConstraint)

        cursorCenterXConstraint = NSLayoutConstraint(item:cur,
            attribute:NSLayoutAttribute.CenterX,
            relatedBy:NSLayoutRelation.Equal,
            toItem:self,
            attribute:NSLayoutAttribute.CenterX,
            multiplier:1.0,
            constant:0)
        self.addConstraint(cursorCenterXConstraint)

        let viewDict = [ "cursor" : cur ]

        var constraints = NSLayoutConstraint.constraintsWithVisualFormat("V:[cursor(\(cur.frame.height))]", options: NSLayoutFormatOptions(rawValue: 0) , metrics: nil, views: viewDict)
        cur.addConstraints(constraints)
        constraints = NSLayoutConstraint.constraintsWithVisualFormat("H:[cursor(\(cur.frame.width))]", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: viewDict)
        cur.addConstraints(constraints)
        }
        selectCell(currentIndex,animate: false)
    }

    //MARK: select cell at index

    public func selectCell(index:Int, animate:Bool)
    {
        let newView = views[index]
        let newLabel = labels[index]
        let oldView = views[currentIndex]
        let oldLabel = labels[currentIndex]
        var duration:NSTimeInterval = 0
        if animate
        {
            duration = 0.4
        }
        if (duration == 0 || index != currentIndex) && index < items.count
        {

            UIView.animateWithDuration(duration, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 10, options: [UIViewAnimationOptions.CurveEaseInOut, UIViewAnimationOptions.AllowUserInteraction], animations:
                {
                    self.animationChecks.append(true)
                    oldView.backgroundColor = self.unselectedColor
                    oldLabel.textColor = self.unselectedTextColor
                    if let font = self.unselectedFont
                    {
                        oldLabel.font = font
                    }
                    newView.backgroundColor = self.selectedColor
                    newLabel.textColor = self.selectedTextColor
                    if let font = self.selectedFont
                    {
                        newLabel.font = font
                    }
                    if let cur = self.cursor
                    {
                        cur.center.x = newView.center.x
                    }
                },
                completion: { finished in
                    if self.animationChecks.count == 1
                    {
                        if let cur = self.cursor
                        {
                            self.removeConstraint(self.cursorCenterXConstraint)
                            self.cursorCenterXConstraint = NSLayoutConstraint(item:cur,
                                attribute:NSLayoutAttribute.CenterX,
                                relatedBy:NSLayoutRelation.Equal,
                                toItem:newView,
                                attribute:NSLayoutAttribute.CenterX,
                                multiplier:1.0,
                                constant:0)
                            self.addConstraint(self.cursorCenterXConstraint)
                        }

                    }
                    self.animationChecks.removeLast()

            })
            currentIndex = index
        }
    }

    internal func didTap(recognizer:UITapGestureRecognizer)
    {
        if recognizer.state == UIGestureRecognizerState.Ended
        {
            let currentPoint = recognizer.locationInView(self)
            let index = indexFromPoint(currentPoint)
            selectCell(index, animate: true)
            self.sendActionsForControlEvents(UIControlEvents.ValueChanged)
        }
    }

    //MARK: getIndex from point

    private func indexFromPoint(point:CGPoint) -> Int
    {
        for pos in 0..<views.count
        {
            let view = views[pos]
            if point.x >= view.frame.minX && point.x < view.frame.maxX
            {
                return pos
            }
        }
        return 0
    }

    //MARK: selectedIndex
    public func selectedIndex() -> Int
    {
        return self.currentIndex
    }
}
