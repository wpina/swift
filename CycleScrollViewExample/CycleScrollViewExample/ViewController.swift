//
//  ViewController.swift
//  CycleScrollViewExample
//
//  Created by wupin on 2020/12/26.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        let frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 300)
        let urls = [
            "https://ss2.bdstatic.com/70cFvnSh_Q1YnxGkpoWK1HF6hhy/it/u=2437461586,2088419162&fm=27&gp=0.jpg",  "https://ss2.bdstatic.com/70cFvnSh_Q1YnxGkpoWK1HF6hhy/it/u=2219945528,2506368580&fm=27&gp=0.jpg", "https://ss1.bdstatic.com/70cFuXSh_Q1YnxGkpoWK1HF6hhy/it/u=2813160690,3273584349&fm=27&gp=0.jpg"]
        let scrollView = WPCycleScrollView(frame: frame, imageUrls: urls) { (index) in
            print("第\(index)张图片点击回调")
        }
        view.addSubview(scrollView)
    }


}

