//
//  ZXXCycleCollectionView.swift
//  ZXXCycleScroll
//
//  Created by zhang on 17/3/23.
//  Copyright © 2017年 zhang. All rights reserved.
//

import UIKit

class ZXXCycleDisplayView: UIView, UICollectionViewDelegate, UICollectionViewDataSource {
    let cellIdentify = "NormalCellRuse";
    let MaxSection: Int = 100;
    var mainCollection: UICollectionView?;
    var timer: Timer? = nil;
    var currentIndex: Int = 0;
    var currentSection: Int = 5; // maxSection 的一半
    var leftBufferView: UIImageView?; // 左侧缓冲View 当CollectionView 滑动到最左边的时候缓冲用
    var rightBufferView: UIImageView?; // 右侧缓冲View 当CollectionView 滑动到最右侧的时候缓冲用
    var drag = false;
    
    
    var itemWidth: CGFloat;
    var miniInterItemSpace: CGFloat = 10;
    var scrollDirection: UICollectionViewScrollDirection = .horizontal;
    var srollTime: CGFloat = 3; // 滚动的时间间隔
    var dataSource: Array<Any>{
        didSet { // 当 dataSource 被赋值时 执行刷新
            if mainCollection != nil {
                if self.dataSource.count > 1 {
                    let firstObj = self.dataSource.first;
                    let lastObj = self.dataSource.last;
                    
                    leftBufferView?.image = UIImage.init(named: lastObj as! String);
                    rightBufferView?.image = UIImage.init(named: firstObj as! String);
                }
                
                // 刷新 collectionView 并初始化位置
                mainCollection?.performBatchUpdates(nil, completion: {(completion: Bool) -> Void in
                    let index = IndexPath.init(row: 0, section: Int(self.MaxSection / 2));
                    self.mainCollection?.scrollToItem(at: index, at: .left, animated: false)
                });
                startTimer();
            }
        }
    };
    
    
    override init(frame: CGRect){
        itemWidth = frame.size.width;
        dataSource = Array<Any>();
        super.init(frame: frame);
        setupSubViews();
        self.layer.masksToBounds = true; // 让超出的子视图的显示控制在 这个滑动视图的范围之内
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupSubViews() {
        setupMainCollection();
        setupBufferView();
    }
    
    private func setupMainCollection() {
        let flowlayout = UICollectionViewFlowLayout.init();
        flowlayout.itemSize = CGSize(width: itemWidth, height:self.bounds.size.height);
        flowlayout.minimumLineSpacing = 0;
        flowlayout.minimumInteritemSpacing = miniInterItemSpace;
        flowlayout.scrollDirection = scrollDirection;
        
        mainCollection = UICollectionView(frame: self.bounds,collectionViewLayout: flowlayout);
        mainCollection?.dataSource = self;
        mainCollection?.delegate = self;
        mainCollection?.isPagingEnabled = true;
        mainCollection?.showsHorizontalScrollIndicator = false;
        mainCollection?.showsVerticalScrollIndicator = false;
        self.addSubview(mainCollection!);
        
        let nib = UINib.init(nibName:"ZXXNormalImgCollectionViewCell", bundle: nil);
        mainCollection?.register(nib, forCellWithReuseIdentifier: cellIdentify);
    }
    
    private func setupBufferView() {
        var leftBufferFrame = mainCollection?.bounds;
        leftBufferFrame?.origin.x = 0 - (mainCollection?.frame.size.width)!;
        leftBufferFrame?.origin.y = 0;
        leftBufferView = UIImageView(frame: leftBufferFrame!);
        self.addSubview(leftBufferView!);
        
        var rightBufferFrame = mainCollection?.bounds;
        rightBufferFrame?.origin.x = (mainCollection?.frame.origin.x)! + (mainCollection?.frame.size.width)!;
        rightBufferView = UIImageView(frame: rightBufferFrame!);
        self.addSubview(rightBufferView!);
    }
    
    override func layoutSubviews() {
        super.layoutSubviews();
        mainCollection?.frame = self.bounds;
        itemWidth = (mainCollection?.frame.size.width)!;
    }
    
    // mark --- scroll control ---
    private func startTimer(){
        
        if timer == nil {
            timer = Timer.scheduledTimer(timeInterval: TimeInterval(srollTime), target: self, selector: #selector(scrollToNext), userInfo: nil, repeats: true)
        }
    }
    
    private func stopTimer(){
        if timer != nil {
            timer?.invalidate();
            timer = nil;
        }
    }
    
    @objc private func scrollToNext(){
        // 当展示或者显示的数量为0或者1的时候不滚动
        if dataSource.count <= 1 {
            return;
        }
        
        let indexPath = calculationCurrentIndex();
        currentIndex = indexPath.0;
        currentSection = indexPath.1;
        
        currentIndex += 1;
        if currentIndex >= dataSource.count {
            currentIndex = 0;
            currentSection += 1;
        }
        if currentSection == MaxSection {
            currentSection = Int(MaxSection / 2);
            // 解决当 滑动到最右边的时候 再次滑动到中部第一的问题, 先把位置移动到中部第一的前一个 然后造成一种假象是从当前的位置 产生滑动动画 滑动过去的
            mainCollection?.scrollToItem(at: IndexPath.init(row: dataSource.count - 1, section: currentSection - 1), at: .left, animated: false);
        }
        
        mainCollection?.scrollToItem(at: IndexPath.init(row: currentIndex, section: currentSection), at: .left, animated: true);
    }
    
    private func calculationCurrentIndex() -> (Int, Int) {
        var row = 0;
        var section = 0;
        let moveIndex = (mainCollection?.contentOffset.x)! / (mainCollection?.bounds.size.width)!;
        section = Int(moveIndex) / dataSource.count;
        row = Int(moveIndex) - dataSource.count * section;
        return (row, section);
    }
    
    
    // mark --- collectionview datasource and delegate ---
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource.count;
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int{
        return MaxSection;
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell{
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentify, for: indexPath) as? ZXXNormalImgCollectionViewCell;
        
        cell?.imgView.image = UIImage.init(named: dataSource[indexPath.row % dataSource.count] as! String);
        
        return cell!;
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        drag = true;
        stopTimer();
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView){
        drag = false;
        let offSetX = scrollView.contentOffset.x;
        NSLog("enddrag: %lf", offSetX);
        if offSetX <= 0 {
            // 解决当 滑动到最左边的时候 松开手, 先把位置移动到中部第一的前一个,可以让用户继续再次向左滑动
            let nextIndex = IndexPath.init(row: dataSource.count - 1, section: Int(MaxSection / 2) - 1);
            mainCollection?.scrollToItem(at: nextIndex, at: .left, animated:false);
        }
        else if offSetX >= (scrollView.contentSize.width - itemWidth){
            // 解决当 滑动到最右边的时候 松开手, 先把位置移动到中部第一个,可以让用户继续再次向右滑动
            let nextIndex = IndexPath.init(row: 0, section: Int(MaxSection / 2));
            mainCollection?.scrollToItem(at: nextIndex, at: .left, animated: false);
            
        }
        
        startTimer();
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offSetX = scrollView.contentOffset.x;
        if offSetX < 0 && drag{
            leftBufferView?.frame.origin.x = 0 - (mainCollection?.frame.size.width)! - offSetX;
        }
        else if offSetX > (scrollView.contentSize.width - itemWidth) && drag{
            let leftDirectMove = offSetX - (scrollView.contentSize.width - itemWidth);
            rightBufferView?.frame.origin.x = (mainCollection?.frame.origin.x)! + (mainCollection?.frame.size.width)! - CGFloat(leftDirectMove);
        
        }
        else{
            leftBufferView?.frame.origin.x = 0 - (mainCollection?.frame.size.width)!;
            
            rightBufferView?.frame.origin.x = (mainCollection?.frame.origin.x)! + (mainCollection?.frame.size.width)!
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
