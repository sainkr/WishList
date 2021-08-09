//
//  ShowImageViewController.swift
//  WishList
//
//  Created by 홍승아 on 2021/02/26.
//

import UIKit

class ShowImageViewController: UIViewController {
  static let identifier = "ShowImageViewController"
  
  @IBOutlet weak var pageControl: UIPageControl!
  @IBOutlet weak var deleteButton: UIButton!
  
  let pageViewController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
  let wishViewModel = WishViewModel()
  var type: ImageType = .none
  var index: Int = 0
  var imgIndex: Int = 0
  
  var imageViewControllers: [ImageViewController] = []
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setPageControl()
    setPageViewController()
  }
  
  func setPageControl(){
    if type == .uiImage {
      pageControl.numberOfPages = wishViewModel.wishs[index].img.count
    }else if type == .url{
      pageControl.numberOfPages = wishViewModel.wishs[index].imgURL.count
    }
    pageControl.currentPage = imgIndex
    pageControl.pageIndicatorTintColor = UIColor.lightGray
    pageControl.currentPageIndicatorTintColor = UIColor.white
  }
  
  func setImageViewControllers(){
    if type == .uiImage{
      for imgIndex in wishViewModel.wishs[index].img.indices{
        let imageVC = ImageViewController()
        imageVC.imageType = type
        imageVC.sizeType = .large
        imageVC.index = index
        imageVC.imgIndex = imgIndex
        imageViewControllers.append(imageVC)
      }
    }else if type == .url{
      for imgIndex in wishViewModel.wishs[index].imgURL.indices{
        let imageVC = ImageViewController()
        imageVC.imageType = type
        imageVC.sizeType = .large
        imageVC.index = index
        imageVC.imgIndex = imgIndex
        imageViewControllers.append(imageVC)
      }
    }
  }
  
  func setPageViewController(){
    pageViewController.delegate = self
    pageViewController.dataSource = self
    view.backgroundColor = .black
    addChild(pageViewController)
    view.addSubview(pageViewController.view)
    view.addSubview(pageControl)
    view.addSubview(deleteButton)
    setImageViewControllers()
    pageViewController.setViewControllers([imageViewControllers[imgIndex]], direction: .forward, animated: true, completion: nil)
  }

  
  @IBAction func deleteButtonTapped(_ sender: Any) {
    dismiss(animated: true, completion: nil)
  }
}

extension ShowImageViewController: UIPageViewControllerDataSource{
  func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
    guard let vc = viewController as? ImageViewController, let index = imageViewControllers.firstIndex(of: vc) else { return nil }
    let previousIndex = index - 1
    if previousIndex < 0 {
      return nil
    }
    return imageViewControllers[previousIndex]
  }
  
  func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
    guard let vc = viewController as? ImageViewController, let index = imageViewControllers.firstIndex(of: vc) else { return nil }
    let nextIndex = index + 1
    if nextIndex == imageViewControllers.count {
      return nil
    }
    return imageViewControllers[nextIndex]
  }
}

extension ShowImageViewController: UIPageViewControllerDelegate{
  func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
    guard completed else { return }
    guard let vc = pageViewController.viewControllers?[0] as? ImageViewController, let index = imageViewControllers.firstIndex(of: vc) else{ return }
    pageControl.currentPage = index
  }
}
