//
//  ImagePageViewController.swift
//  WishList
//
//  Created by 홍승아 on 2021/07/29.
//

import UIKit

class ImagePageViewController: UIViewController{
  
  @IBOutlet weak var pageControl: UIPageControl!
  
  static let identifier = "ImagePageViewController"
  var currentPage = 0
  let pageViewController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
  
  let wishViewModel = WishViewModel()
  var index: Int = 0
  
  var imageViewControllers: [UIViewController] = []
  
  override func viewDidLoad() {
    super.viewDidLoad()
    pageViewController.delegate = self
    pageViewController.dataSource = self
    setPageControl()
    view.backgroundColor = .white
    addChild(pageViewController)
    view.addSubview(pageViewController.view)
    view.addSubview(pageControl)
    setImageViewControllers()
    pageViewController.setViewControllers([imageViewControllers[0]], direction: .forward, animated: true, completion: nil)
  }
  
  func setPageControl(){
    if wishViewModel.wishs[index].img.count > 0 {
      pageControl.numberOfPages = wishViewModel.wishs[index].img.count
    }else if wishViewModel.wishs[index].imgURL.count > 0{
      pageControl.numberOfPages = wishViewModel.wishs[index].imgURL.count
    }else{
      pageControl.isHidden = true
      return
    }
    pageControl.currentPage = 0
    pageControl.pageIndicatorTintColor = UIColor.lightGray
    pageControl.currentPageIndicatorTintColor = UIColor.white
  }
  
  func imageViewController(currentPage: Int)-> UIViewController{
    let vc = UIViewController()
    let imageView = UIImageView()
    imageView.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: view.bounds.width)
    if !wishViewModel.wishs[index].img.isEmpty{
      imageView.image = wishViewModel.wishs[index].img[currentPage]
    }else if !wishViewModel.wishs[index].imgURL.isEmpty{
      let url = URL(string: wishViewModel.wishs[index].imgURL[currentPage])
      imageView.kf.setImage(with: url)
    }
    pageControl.currentPage = currentPage
    vc.view.addSubview(imageView)
    return vc
  }
  
  func setImageViewControllers(){
    if !wishViewModel.wishs[index].img.isEmpty{
      for img in wishViewModel.wishs[index].img{
        let vc = UIViewController()
        let imageView = UIImageView()
        imageView.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: view.bounds.width)
        imageView.image = img
        vc.view.addSubview(imageView)
        imageViewControllers.append(vc)
      }
    }else if !wishViewModel.wishs[index].imgURL.isEmpty{
      for url in wishViewModel.wishs[index].imgURL{
        let vc = UIViewController()
        let imageView = UIImageView()
        imageView.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: view.bounds.width)
        imageView.kf.setImage(with: URL(string: url))
        vc.view.addSubview(imageView)
        imageViewControllers.append(vc)
      }
    }
  }
  
  func presentShowImageVC(){
    let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
    guard let showImageVC = storyboard.instantiateViewController(identifier: "ShowImageViewController") as? ShowImageViewController else { return }
    showImageVC.modalPresentationStyle = .fullScreen
    showImageVC.currentIndex = self.pageControl.currentPage
    
    self.present(showImageVC, animated: true, completion: nil)
  }
  
  @objc func imageViewTapped(_ gesture: UITapGestureRecognizer) {
    /*if wishViewModel.wishs[selectedIndex].img.count > 0 {
     presentShowImageVC()
     } else {
     LoadingHUD.show(1)
     }*/
  }
}

extension ImagePageViewController: UIPageViewControllerDataSource{
  func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
    guard let index = imageViewControllers.firstIndex(of: viewController) else { return nil }
    let previousIndex = index - 1
    if previousIndex < 0 {
      return nil
    }
    return imageViewControllers[previousIndex]
  }
  
  func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
    guard let index = imageViewControllers.firstIndex(of: viewController) else { return nil }
    let nextIndex = index + 1
    if nextIndex == imageViewControllers.count {
      return nil
    }
    return imageViewControllers[nextIndex]
  }
}

extension ImagePageViewController: UIPageViewControllerDelegate{
  func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
    guard completed else { return }
    guard let currentViewController = pageViewController.viewControllers?[0], let index = imageViewControllers.firstIndex(of: currentViewController) else{ return }
    pageControl.currentPage = index
  }
}
