//
//  tutorialViewController.swift
//  GeoFence
//
//  Created by Kendall Lewis on 6/4/19.
//  Copyright © 2019 Kendall Lewis. All rights reserved.
//

import UIKit

class tutorialViewController: UIViewController, UIScrollViewDelegate  {
    @IBOutlet var pageView: UIView!
    let scrollView = UIScrollView(frame: CGRect(x:0, y:0, width:UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))
    var backgroundColors:[UIColor] = [
        UIColor().HexToColor(hexString: colorCollection!.systemForeground, alpha: 1.0),
        UIColor().HexToColor(hexString: colorCollection!.systemBackground , alpha: 1.0),
        UIColor().HexToColor(hexString: colorCollection!.systemBackground , alpha: 1.0),
        UIColor().HexToColor(hexString: colorCollection!.systemForeground, alpha: 1.0)]
    var frame: CGRect = CGRect(x:0, y:0, width:0, height:0)
    var pageControl : UIPageControl = UIPageControl(frame: CGRect(x:UIScreen.main.bounds.height / 2,y: UIScreen.main.bounds.height - 200, width:200, height:50))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configurePageControl()
         pageView.layer.backgroundColor =  UIColor().HexToColor(hexString: colorCollection!.systemBackground, alpha: 1.0).cgColor
        scrollView.delegate = self
        scrollView.isPagingEnabled = true
        
        self.view.addSubview(scrollView)
        for index in 0..<4 {
            if index == 0 {
                print("Tutorial header page")
            } else if (index == 1) {
                print("Tutorial header page 1")
            } else if (index == 2) {
                print("Tutorial header page 2")
            }else if (index == 3){
                print("Tutorial header page 3")
            }else if (index == 4){
                print("Tutorial header page 4")
            }
            frame.origin.x = self.scrollView.frame.size.width * CGFloat(index)
            frame.size = self.scrollView.frame.size
            
            let subView = UIView(frame: frame)
            subView.backgroundColor = backgroundColors[index]
            self.scrollView .addSubview(subView)
        }
        
        self.scrollView.contentSize = CGSize(width:self.scrollView.frame.size.width * 4,height: self.scrollView.frame.size.height)
        pageControl.addTarget(self, action: #selector(self.changePage(sender:)), for: UIControl.Event.valueChanged)
    }
    
    func configurePageControl() {
        // The total number of pages that are available is based on how many available colors we have.
        self.pageControl.numberOfPages = backgroundColors.count
        self.pageControl.currentPage = 0
        self.pageControl.tintColor = UIColor.red
        self.pageControl.pageIndicatorTintColor = UIColor.black
        self.pageControl.currentPageIndicatorTintColor = UIColor.green
        self.view.addSubview(pageControl)
    }
    
    // MARK : TO CHANGE WHILE CLICKING ON PAGE CONTROL
    @objc func changePage(sender: AnyObject) -> () {
        let x = CGFloat(pageControl.currentPage) * scrollView.frame.size.width
        scrollView.setContentOffset(CGPoint(x:x, y:0), animated: true)
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let pageNumber = round(scrollView.contentOffset.x / scrollView.frame.size.width)
        pageControl.currentPage = Int(pageNumber)
    }
}


