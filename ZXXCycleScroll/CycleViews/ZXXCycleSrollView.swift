
//
//  ZXXCycleSrollView.swift
//  ZXXCycleScroll
//
//  Created by zhang on 17/3/24.
//  Copyright © 2017年 zhang. All rights reserved.
//

import UIKit
let kZXX_IMGVIEW_NUM: Int = 5;
let kZXX_TAG_BASE: Int = 60;

class ZXXCycleSrollView: UIView {
    
    var mainScrollView: UIScrollView?;
    var dataSource: Array<Any> {
        didSet{
            guard (dataSource.count) > kZXX_IMGVIEW_NUM - 2 else {
                return;
            }
            loadInitlizeScrollContent();
        }
    };
    var imgViewArr: Array<Any> = Array<Any>();
    private var itemWidth: CGFloat = 100;
    private var itemHeight: CGFloat = 100;
    
    override init(frame: CGRect){
        dataSource = Array<Any>();
        super.init(frame: frame);
        setupSubViews();
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // mark ------ create view ------
    private func setupSubViews(){
        itemWidth = self.bounds.size.width;
        itemHeight = self.bounds.size.height;
        setupMainScrollView();
        setupScrollContent();
    }
    
    private func setupMainScrollView(){
        mainScrollView = UIScrollView(frame: CGRect(x: 0, y:0, width:self.bounds.size.width, height:self.bounds.size.height));
        mainScrollView?.showsVerticalScrollIndicator = false;
        mainScrollView?.showsHorizontalScrollIndicator = false;
        mainScrollView?.contentSize = CGSize(width: CGFloat(kZXX_IMGVIEW_NUM) * itemWidth, height:itemHeight);
        let centerPosition = Int(kZXX_IMGVIEW_NUM/2) ;
        mainScrollView?.contentOffset = CGPoint(x: itemWidth * CGFloat(centerPosition), y: 0);
        mainScrollView?.isPagingEnabled = true;
        self.addSubview(mainScrollView!);
    }
    
    private func setupScrollContent(){
        for index in 0..<kZXX_IMGVIEW_NUM {
            let originX = CGFloat(index) * itemWidth;
            let imageView = UIImageView(frame: CGRect(x: originX, y: 0, width:itemWidth, height: itemHeight));
            imageView.tag = kZXX_TAG_BASE + index;
            mainScrollView?.addSubview(imageView);
            imgViewArr.append(imageView);
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews();
        mainScrollView?.frame = self.bounds;
        itemWidth = (mainScrollView?.bounds.size.width)!;
        itemHeight = (mainScrollView?.bounds.size.height)!;
        mainScrollView?.contentSize = CGSize(width: CGFloat(kZXX_IMGVIEW_NUM) * itemWidth, height: itemHeight);
    }

    // mark --- display control ---
    private func loadInitlizeScrollContent(){
        let centerIndex = Int(kZXX_IMGVIEW_NUM / 2);
        for index in 0..<kZXX_IMGVIEW_NUM {
            var distance = index - centerIndex;
            var itemIndex: Int = 0;
            if distance < 0 {
                itemIndex = max(0, dataSource.count + distance);
            }
            else if distance == 0 {
                itemIndex = 0;
            }
            else {
                if distance >= dataSource.count {
                    distance = (distance - dataSource.count) % dataSource.count;
                }
                itemIndex = max(0, distance);
            }
            let item = dataSource[itemIndex % dataSource.count];
            let imgView: UIImageView = imgViewArr[index] as! UIImageView;
            imgView.image = UIImage.init(named: item as! String)
        
        }
    }
    
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
