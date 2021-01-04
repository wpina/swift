//
//  WPPageControl.swift
//  CycleScrollViewExample
//
//  Created by wupin on 2020/12/26.
//

import UIKit

class WPPageControl: UIView {
    let pageControlDiameter: Float = 4
    var currentPage: NSInteger = 0 {
        didSet {
            if oldValue == currentPage {
                return
            }

            if currentPage < oldValue { // 向右拉伸
                UIView.animate(withDuration: 0.3, animations: {
                    for dot in self.subviews {
                        var dotFrame = dot.frame
                        if dot.tag == self.currentPage {
                            dotFrame.size.width = CGFloat(self.pageControlDiameter * 2.0)
                            dot.backgroundColor = UIColor(red: 223/255.0, green: 184/255.0, blue: 117/255.0, alpha: 1)
                            dot.frame = dotFrame

                        } else if dot.tag <= oldValue && dot.tag > self.currentPage {
                            dotFrame.origin.x += CGFloat(self.pageControlDiameter)
                            dotFrame.size.width = CGFloat(self.pageControlDiameter)
                            dot.backgroundColor = UIColor.init(red: 230.0/255.0, green: 230/255.0, blue: 230/255.0, alpha: 1.0)
                            dot.frame = dotFrame
                        }
                    }
                })

            } else { // 向左拉伸
                UIView.animate(withDuration: 0.3, animations: {
                    for dot in self.subviews {
                        var dotFrame = dot.frame
                        if dot.tag == self.currentPage {
                            dotFrame.size.width = CGFloat(self.pageControlDiameter * 2.0)
                            dotFrame.origin.x -= CGFloat(self.pageControlDiameter)
                            dot.backgroundColor = UIColor(red: 223/255.0, green: 184/255.0, blue: 117/255.0, alpha: 1)
                            dot.frame = dotFrame

                        } else if dot.tag > oldValue && dot.tag < self.currentPage {
                            dotFrame.origin.x -= CGFloat(self.pageControlDiameter)
                            dot.frame = dotFrame

                        } else if dot.tag == oldValue {
                            dotFrame.size.width = CGFloat(self.pageControlDiameter)
                            dot.backgroundColor = UIColor.init(red: 230.0/255.0, green: 230/255.0, blue: 230/255.0, alpha: 1.0)
                            dot.frame = dotFrame
                        }
                    }
                })
            }
        }
    }

    var numberOfPages: NSInteger = 0 {
        didSet {
            if self.numberOfPages == 0 {
                return
            }
            if self.subviews.count > 0 {
                for view in self.subviews {
                    view.removeFromSuperview()
                }
            }

            var dotX: Float = 0
            var dotW: Float = pageControlDiameter
            var bgColor: UIColor
            for i in 0 ..< numberOfPages {
                if i <= currentPage {
                    dotX = pageControlDiameter * 2.0 * Float(i)
                } else {
                    dotX = pageControlDiameter * 2 * Float(i) + pageControlDiameter
                }

                if i == currentPage {
                    dotW = pageControlDiameter * 2
                    bgColor = UIColor(red: 223/255.0, green: 184/255.0, blue: 117/255.0, alpha: 1)
                } else {
                    dotW = pageControlDiameter
                    bgColor =  UIColor(red: 223/255.0, green: 223/255.0, blue: 223/255.0, alpha: 1)
                }

                let temp = UIView()
                temp.frame = CGRect(x: CGFloat(dotX), y: CGFloat(0), width: CGFloat(dotW), height: CGFloat(pageControlDiameter))
                temp.layer.cornerRadius = CGFloat(pageControlDiameter * 0.5)
                temp.layer.masksToBounds = true
                temp.backgroundColor = bgColor
                temp.tag = i
                addSubview(temp)
            }
        }
    }
}
