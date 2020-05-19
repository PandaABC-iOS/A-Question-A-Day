//
//  InfiniteView.swift
//  infiniteScroll
//
//  Created by songzhou on 2020/5/8.
//  Copyright © 2020 songzhou. All rights reserved.
//

import UIKit

/**
 无限滑动的 View，可以设置滑到顶端，底端后，不再滑动
 scrollView 的每一个 page 高度必须大于等于 scrollView 高度
 */
class InfiniteView: UIView {
    init(frame: CGRect, initialPosition: Position) {
        self.scrollView = UIScrollView()
        self.initialPosition = initialPosition
        
        super.init(frame: frame)
        
        addSubview(scrollView)
        prepareImagesAndViews()
        scrollView.delegate = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        scrollView.frame = bounds
        
        let contentHeight = images.reduce(0) { (result, image) -> CGFloat in
            return result + image.size.height/image.size.width * bounds.width
        }
        
        pageHeight = images[0].size.height/images[0].size.width * bounds.width
        scrollView.contentSize = CGSize(width: scrollView.bounds.width, height: contentHeight)

        switch initialPosition {
        case .normal, .top:
            break
        case .bottom:
            scrollView.contentOffset.y = contentHeight-scrollView.bounds.height
        }
        
        layoutImages()
    }
    
    private func prepareImagesAndViews() {
        (0..<fetcher.count).forEach { i in
            let image = fetcher.fetchImageAt(index: i)
            images.append(image)
            imageViews[i].image = image
            scrollView.addSubview(imageViews[i])
        }
    }
    
    private func layoutImages() {
        var originY: CGFloat = 0
        imageViews.enumerated().forEach { (index: Int, imageView: UIImageView) in
            imageView.image = images[index]
            let height = images[index].size.height/images[index].size.width*bounds.width
            imageView.frame = CGRect(x: 0,
                                     y: originY,
                                     width: bounds.width,
                                     height: height)
            
            originY += height
         }
     }
    
    let scrollView: UIScrollView
    /// scrollView 默认处于的位置
    let initialPosition: Position
    /// 图片的高度
    private var pageHeight: CGFloat = 0
    private var images = [UIImage]()
    lazy private var imageViews: [UIImageView] = {
        let imageViews = [
            UIImageView(frame: .zero),
            UIImageView(frame: .zero),
            UIImageView(frame: .zero)
        ]
        imageViews.forEach({ imageView in
            imageView.contentMode = .scaleAspectFit
        })
        return imageViews
    }()
    
    lazy private var fetcher: ImageFetcher = {
        let o = ImageFetcher(count: 3)
        o.stopAtEnd = true
        
        return o
    }()
    
    private var dragging = false
    
    enum Position {
        case normal, top, bottom
    }
}

extension InfiniteView: UIScrollViewDelegate {
    func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        dragging = true
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        dragging = false
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if !dragging {
            return
        }
        
        let offsetY = scrollView.contentOffset.y
        
        if (fetcher.canScrollToEnd() && offsetY > pageHeight * 1.5) {
            let next = fetcher.fetchNextImage()
            images.remove(at: 0)
            images.append(next)
            layoutImages()
            scrollView.contentOffset.y -= pageHeight
        }
        
        if (fetcher.canScrollToStart() && offsetY < pageHeight * 0.5) {
            let prev = fetcher.fetchPrevImage()
            images.removeLast()
            images.insert(prev, at: 0)
            layoutImages()
            scrollView.contentOffset.y += pageHeight
        }
    }
}


/// 图片获取器
private class ImageFetcher {
    init(count: Int) {
        self.count = count
        // 默认展示处于中间位置的图片
        self.currentIndex = count/2
    }
    
    /// 根据索引循环返回图片
    func fetchImageAt(index: Int) -> UIImage {
        return UIImage(named: "CourseList_bg")!
    }
    
    /// 当前展示的图片 index
    var currentIndex: Int
    
    /// 图片的数量
    var count: Int
    /// 设置滑到顶部后不再滑动
    var stopAtStart: Bool = false
    /// 设置滑到底部后不再滑动
    var stopAtEnd: Bool = false

    /**
        是否允许继续滑向顶部
        当 currentIndex=1 时，此时不再需要在前面插入 page
     */
    func canScrollToStart() -> Bool {
        if stopAtStart == false {
            return true
        }
        
        return currentIndex > 1
    }
    
    /**
        是否允许继续滑向底部
        当 currentIndex = count-2 时，此时不再需要在后面插入 page
     */
    func canScrollToEnd() -> Bool {
        if stopAtEnd == false {
            return true
        }

        return currentIndex < count-2
    }
    
    /**
        获取新的在底端位置图片
     
     图片序列，假设是左右滑动，屏幕往左移动，移除最左边，添加到最右边
     0  1  2
     1  2  0
     2  0  1
     0  1  2
        
    currentIndex 变化：
     1, 2, 3, 4
          
     添加的图片：
     (1+2) mod 3 = 0
     (2+2) mod 3 = 1
     (3+2) mod 3 = 2
     (4+2) mod 3 = 0
     */
    func fetchNextImage() -> UIImage {
        currentIndex += 1
        return fetchImageAt(index: mod(currentIndex+1, count))
    }
    
    /**
     获取新的在顶端位置图片，与 `fetchNextImage` 同理
     */
    func fetchPrevImage() -> UIImage {
        currentIndex -= 1
        return fetchImageAt(index: mod(currentIndex-1, count))
    }
    
    /**
     取模操作，支持负数
     
     example: mod 3
     4   3   2   1   0   -1  -2  -3  -4
     1   0   2   1   0   2   1   0   2
     */
    private func mod(_ left: Int, _ right: Int) -> Int {
        guard right != 0 else {
            return -1
        }
        
        if left > 0 {
            return left % right
        }

        return mod(left+right, right)
    }
}
