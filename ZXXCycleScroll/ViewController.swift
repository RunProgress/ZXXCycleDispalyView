//
//  ViewController.swift
//  ZXXCycleScroll
//
//  Created by zhang on 17/3/23.
//  Copyright © 2017年 zhang. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        var cycleView: ZXXCycleDisplayView?;
        var cycleScrollView: ZXXCycleSrollView?;
        
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        cycleView = ZXXCycleDisplayView.init(frame: CGRect(x:0, y:64, width:self.view.frame.size.width,height:200));
        self.view.addSubview(cycleView!);
        
        var imgNames = [String]();
        for index in 17...20 {
            let name = String(index) + ".jpg";
            imgNames.append(name);
        }
        cycleView?.dataSource = imgNames;
        
        cycleScrollView = ZXXCycleSrollView.init(frame: CGRect(x:0, y:300, width:self.view.frame.size.width,height:200));
        self.view.addSubview(cycleScrollView!);
        cycleScrollView?.dataSource = imgNames;
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

