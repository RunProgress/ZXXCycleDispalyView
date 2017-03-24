
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

class ZXXCycleSrollView: UIView, UIScrollViewDelegate {
    
    var mainScrollView: UIScrollView?;
    var dataSource: Array<Any> {
        didSet{
            guard (dataSource.count) > kZXX_IMGVIEW_NUM - 2 else {
                return;
            }
            loadScrollContent(centerIndex: 0);
        }
    };
    var imgViewArr: Array<Any> = Array<Any>();
    private var itemWidth: CGFloat = 100;
    private var itemHeight: CGFloat = 100;
    private var currentItem: Int = 0;
    
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
        mainScrollView?.delegate = self;
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
    
    /// 当获取到数据的时候 初始化scrollview上的各个imageView, 因为scrollView初始定位在中间位置, 所以中部位置放置第一个Img, 右边放从0开始的Img, 左边放 DataSource的最后一个, 向左一直递减 造成循环的假象
    private func loadScrollContent(centerIndex: Int){
        let centerPosition = Int(kZXX_IMGVIEW_NUM / 2);
        
        let item = dataSource[centerIndex];
        let imgView: UIImageView = imgViewArr[0] as! UIImageView;
        imgView.image = UIImage.init(named: item as! String)
        
        for index in 0..<kZXX_IMGVIEW_NUM {
            let distance = index - centerPosition;
            var itemIndex: Int = 0;
            if distance < 0 {
                var position = centerIndex - abs(distance);
                if position < 0 {
                    position = dataSource.count - abs(position);
                }
                
                itemIndex = max(0, position);
            }
            else if distance == 0 {
                itemIndex = centerIndex;
            }
            else {
                itemIndex = distance ;
            }
            let item = dataSource[itemIndex % dataSource.count];
            let imgView: UIImageView = imgViewArr[index] as! UIImageView;
            imgView.image = UIImage.init(named: item as! String)
        
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let centerOffetX = itemWidth * CGFloat(Int(kZXX_IMGVIEW_NUM/2)) ;
        let endContentOffsetX = scrollView.contentOffset.x - centerOffetX;
        currentItem = endContentOffsetX > 0 ? currentItem + 1 : currentItem - 1;
        if currentItem < 0 {
            currentItem = dataSource.count - 1;
        }
        if currentItem >= dataSource.count {
            currentItem = currentItem % dataSource.count;
        }
        loadScrollContent(centerIndex: currentItem);
        // 回到中间初始位置
        mainScrollView?.setContentOffset(CGPoint(x:centerOffetX , y: 0), animated: false);
       
    }
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
