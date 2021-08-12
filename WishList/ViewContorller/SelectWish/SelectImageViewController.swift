//
//  ImagePageViewController.swift
//  WishList
//
//  Created by 홍승아 on 2021/07/29.
//

import UIKit

class SelectImageViewController: UIViewController{
  static let identifier = "ImagePageViewController"
  
  @IBOutlet weak var pageControl: UIPageControl!
  
  private let pageViewController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
  private var imageViewControllers: [ImageViewController] = []
  private let wishViewModel = WishViewModel()
  var type: ImageType = .none
  var index: Int = 0
  
  override func viewDidLoad() {
    super.viewDidLoad()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(true)
    type = wishViewModel.imageType(index)
    configurePageControl()
    if type == .uiImage || type == .url{
      configurePageViewController()
    }
  }
  
  private func configurePageControl(){
    if type == .uiImage {
      pageControl.numberOfPages = wishViewModel.imageCount(index)
    }else if type == .url{
      pageControl.numberOfPages = wishViewModel.imageURLCount(index)
    }
    pageControl.pageIndicatorTintColor = UIColor.lightGray
    pageControl.currentPageIndicatorTintColor = UIColor.white
  }
  
  private func configureImageViewControllers(){
    imageViewControllers = []
    let type = wishViewModel.imageType(index)
    if type == .uiImage{
      for imgIndex in wishViewModel.image(index).indices{
        let imageVC = ImageViewController()
        imageVC.imageType = type
        imageVC.sizeType = .small
        imageVC.index = index
        imageVC.imgIndex = imgIndex
        imageVC.image = wishViewModel.image(index: index, imageIndex: imgIndex)
        imageViewControllers.append(imageVC)
      }
    }else if type == .url{
      for imgIndex in wishViewModel.imageURL(index).indices{
        let imageVC = ImageViewController()
        imageVC.imageType = type
        imageVC.sizeType = .small
        imageVC.index = index
        imageVC.imgIndex = imgIndex
        imageVC.imageURL = wishViewModel.imageURL(index: index, imageIndex: imgIndex)
        imageViewControllers.append(imageVC)
      }
    }else{
      pageControl.isHidden = true
    }
  }
  
  private func configurePageViewController(){
    pageViewController.delegate = self
    pageViewController.dataSource = self
    view.backgroundColor = .white
    configurePageControl()
    addChild(pageViewController)
    view.addSubview(pageViewController.view)
    view.addSubview(pageControl)
    configureImageViewControllers()
    
    pageViewController.view.snp.makeConstraints{ make in
      make.top.equalToSuperview()
      make.bottom.equalToSuperview()
      make.leading.equalToSuperview()
      make.trailing.equalToSuperview()
    }
    pageViewController.setViewControllers([imageViewControllers[0]], direction: .forward, animated: true, completion: nil)
  }
}

// MARK:- UIPageViewControllerDataSource
extension SelectImageViewController: UIPageViewControllerDataSource{
  func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
    guard let vc = viewController as? ImageViewController, let index = imageViewControllers.firstIndex(of: vc) else { return nil }
    let previousIndex = index - 1
    if previousIndex < 0 { return nil }
    return imageViewControllers[previousIndex]
  }
  
  func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
    guard let vc = viewController as? ImageViewController, let index = imageViewControllers.firstIndex(of: vc) else { return nil }
    let nextIndex = index + 1
    if nextIndex == imageViewControllers.count { return nil }
    return imageViewControllers[nextIndex]
  }
}

// MARK:- UIPageViewControllerDelegate
extension SelectImageViewController: UIPageViewControllerDelegate{
  func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
    guard completed else { return }
    guard let vc = pageViewController.viewControllers?[0] as? ImageViewController, let index = imageViewControllers.firstIndex(of: vc) else{ return }
    print(index)
  }
}
