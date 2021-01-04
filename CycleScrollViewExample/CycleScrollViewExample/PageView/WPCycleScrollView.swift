//
//  WPCycleScrollView.swift
//  CycleScrollViewExample
//
//  Created by wupin on 2020/12/26.
//

import SDWebImage
import UIKit

class WPCycleScrollView: UIView, UIScrollViewDelegate {
    var timeInterval: TimeInterval = 3

    private var imageUrls: [String] = [String]()
    private var imageArray: [UIImageView] = [UIImageView]()
    private var tapAction: (Int) -> Void
    private var currentIndex: Int = 0
    private weak var timer: Timer?
    private lazy var scrollNode: UIScrollView = createScrollView()
    lazy var pageControl: WPPageControl = createPageControl()

    // - Public

    func resetCurrentPage(_ page: Int) {
        currentIndex = page
        pageControl.currentPage = page
        resetImageView()
        startTimer()
    }

    // - Init

    init(frame: CGRect, imageUrls: [String], tapAction action: @escaping (Int) -> Void) {
        self.imageUrls = imageUrls
        tapAction = action
        super.init(frame: frame)

        addImageView()
        addSubview(scrollNode)
        guard imageUrls.count > 0 else { return }
        addSubview(pageControl)
        startTimer()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // - UIScrollViewDelegate

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let contentOffsetX = scrollView.contentOffset.x
        // 设置图片信息
        if contentOffsetX == 2 * scrollView.frame.width { // 左滑
            currentIndex = getActualCurrentPage(calculatedPage: currentIndex + 1)
            resetImageView()
        } else if contentOffsetX == 0 { // 右滑
            currentIndex = getActualCurrentPage(calculatedPage: currentIndex - 1)
            resetImageView()
        }

        // 设置 pageControl
        if contentOffsetX < scrollView.frame.width && contentOffsetX > 0 {
            if contentOffsetX <= scrollView.frame.width * 0.5 {
                pageControl.currentPage = getActualCurrentPage(calculatedPage: currentIndex - 1)
            } else if contentOffsetX > scrollView.frame.width * 0.5 {
                pageControl.currentPage = getActualCurrentPage(calculatedPage: currentIndex)
            }
        } else if contentOffsetX > scrollView.frame.width && contentOffsetX < scrollView.frame.width * 2 {
            if contentOffsetX >= scrollView.frame.width * 1.5 {
                pageControl.currentPage = getActualCurrentPage(calculatedPage: currentIndex + 1)
            } else if contentOffsetX < scrollView.frame.width * 1.5 {
                pageControl.currentPage = currentIndex
            }
        }
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        scrollView.setContentOffset(CGPoint(x: frame.width, y: 0), animated: true)
        startTimer()
    }

    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        timer?.invalidate()
        timer = nil
    }

    // - Action

    @objc fileprivate func cycleViewDidClick(gesture: UITapGestureRecognizer) {
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: frame.width, height: frame.height))
        imageView.sd_setImage(with: URL(string: imageUrls[currentIndex]), placeholderImage: nil, options: [.refreshCached, .retryFailed])
        tapAction(currentIndex)
    }

    @objc fileprivate func autoScroll() {
        if imageUrls.count < 2 {
            return
        }
        scrollNode.setContentOffset(CGPoint(x: frame.width * 2, y: 0), animated: true)
    }

    func startTimer() {
        guard imageUrls.count > 0 else { return }

        if let myTimer = timer {
            myTimer.invalidate()
            timer = nil
        }
        timer = Timer.scheduledTimer(timeInterval: timeInterval, target: self, selector: #selector(autoScroll), userInfo: nil, repeats: true)
        RunLoop.current.add(timer!, forMode: RunLoop.Mode.common)
    }

    func invalidateTimer() {
        timer?.invalidate()
        timer = nil
    }

    fileprivate func addImageView() {
        var x: CGFloat = 0
        var pageIndex: NSInteger = imageUrls.count - 1
        for index in 0 ..< 3 {
            let imgNode = UIImageView()
            x = CGFloat(index) * frame.width
            imgNode.frame = CGRect(x: x, y: 0, width: frame.width, height: frame.height)
            imgNode.sd_setImage(with: URL(string: imageUrls.count == 0 ? "" : imageUrls[pageIndex]), placeholderImage: nil, options: [.refreshCached, .retryFailed])
            imgNode.contentMode = .scaleAspectFill
            imgNode.clipsToBounds = true

            let gesture = UITapGestureRecognizer(target: self, action: #selector(cycleViewDidClick(gesture:)))
            imgNode.addGestureRecognizer(gesture)
            imgNode.isUserInteractionEnabled = true
            imageArray.append(imgNode)
            scrollNode.addSubview(imgNode)

            if imageUrls.count == 1 {
                pageIndex = 0
                scrollNode.isScrollEnabled = false
            } else {
                pageIndex = index == 0 ? 0 : 1
            }
        }
    }

    fileprivate func resetImageView() {
        let preIndex: NSInteger = getActualCurrentPage(calculatedPage: currentIndex - 1)
        let nextIndex: NSInteger = getActualCurrentPage(calculatedPage: currentIndex + 1)

        if imageUrls.count == 0 {
            return
        }

        imageArray[0].sd_setImage(with: URL(string: imageUrls[preIndex]), placeholderImage: nil, options: [.refreshCached, .retryFailed])
        imageArray[1].sd_setImage(with: URL(string: imageUrls[currentIndex]), placeholderImage: nil, options: [.refreshCached, .retryFailed])
        imageArray[2].sd_setImage(with: URL(string: imageUrls[nextIndex]), placeholderImage: nil, options: [.refreshCached, .retryFailed])

        scrollNode.contentOffset = CGPoint(x: frame.width, y: 0) // 这里不可以使用setcontentOffset:animate的方法，否则滑动过快会出现bug
    }

    /// 根据下一页的计算值获取实际下一页的值
    /// - Parameter page: 通过+1或-1得到的下一页的值
    /// - Returns: 实际值
    fileprivate func getActualCurrentPage(calculatedPage page: NSInteger) -> NSInteger {
        if page == imageUrls.count {
            return 0
        } else if page == -1 {
            return imageUrls.count - 1
        } else {
            return page
        }
    }

    /// lazy func
    private func createScrollView() -> UIScrollView {
        let node = UIScrollView()
        node.scrollsToTop = false
        node.isPagingEnabled = true
        node.bounces = false
        node.frame = bounds
        node.delegate = self
        node.showsHorizontalScrollIndicator = false
        node.decelerationRate = UIScrollView.DecelerationRate(rawValue: 1)
        node.setContentOffset(CGPoint(x: frame.width, y: 0), animated: false)
        node.contentSize = CGSize(width: frame.size.width * 3.0, height: 0)
        return node
    }

    private func createPageControl() -> WPPageControl {
        let node = WPPageControl(frame: CGRect(x: 15, y: Int(frame.height - 14), width: 10 * imageUrls.count, height: 6))
        node.center.x = center.x
        node.numberOfPages = imageUrls.count
        return node
    }
}
