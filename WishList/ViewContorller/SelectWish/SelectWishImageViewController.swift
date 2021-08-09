//
//  ImagePageViewController.swift
//  WishList
//
//  Created by 홍승아 on 2021/07/29.
//

import UIKit

class SelectWishImageViewController: UIViewController{
  @IBOutlet weak var pageControl: UIPageControl!
  
  static let identifier = "ImagePageViewController"
  let pageViewController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
  let wishViewModel = WishViewModel()
  var type: ImageType = .none
  var index: Int = 0
  
  var imageViewControllers: [ImageViewController] = []
  
  override func viewDidLoad() {
    super.viewDidLoad()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(true)
    type = imageType()
    setPageControl()
    if type == .uiImage || type == .url{
      setPageViewController()
    }
  }
  
  func setPageControl(){
    if type == .uiImage {
      pageControl.numberOfPages = wishViewModel.wishs[index].img.count
    }else if type == .url{
      pageControl.numberOfPages = wishViewModel.wishs[index].imgURL.count
    }
    pageControl.pageIndicatorTintColor = UIColor.lightGray
    pageControl.currentPageIndicatorTintColor = UIColor.white
  }
  
  func setImageViewControllers(){
    imageViewControllers = []
    let type = imageType()
    if type == .uiImage{
      for imgIndex in wishViewModel.wishs[index].img.indices{
        let imageVC = ImageViewController()
        imageVC.imageType = imageType()
        imageVC.sizeType = .small
        imageVC.index = index
        imageVC.imgIndex = imgIndex
        imageViewControllers.append(imageVC)
      }
    }else if type == .url{
      for imgIndex in wishViewModel.wishs[index].imgURL.indices{
        let imageVC = ImageViewController()
        imageVC.imageType = imageType()
        imageVC.sizeType = .small
        imageVC.index = index
        imageVC.imgIndex = imgIndex
        imageViewControllers.append(imageVC)
      }
    }else{
      pageControl.isHidden = true
    }
  }
  
  func setPageViewController(){
    pageViewController.delegate = self
    pageViewController.dataSource = self
    view.backgroundColor = .white
    setPageControl()
    addChild(pageViewController)
    view.addSubview(pageViewController.view)
    view.addSubview(pageControl)
    setImageViewControllers()
    
    pageViewController.view.snp.makeConstraints{ make in
      make.top.equalToSuperview()
      make.bottom.equalToSuperview()
      make.leading.equalToSuperview()
      make.trailing.equalToSuperview()
    }
    pageViewController.setViewControllers([imageViewControllers[0]], direction: .forward, animated: true, completion: nil)
  }
  
  func imageType()-> ImageType{
    if !wishViewModel.wishs[index].img.isEmpty{
      return .uiImage
    }else if !wishViewModel.wishs[index].imgURL.isEmpty{
      return .url
    }else{
      return .none
    }
  }
}

extension SelectWishImageViewController: UIPageViewControllerDataSource{
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

extension SelectWishImageViewController: UIPageViewControllerDelegate{
  func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
    guard completed else { return }
    guard let vc = pageViewController.viewControllers?[0] as? ImageViewController, let index = imageViewControllers.firstIndex(of: vc) else{ return }
    print(index)
  }
}
