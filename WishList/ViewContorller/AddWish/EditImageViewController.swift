//
//  EditImageViewController.swift
//  WishList
//
//  Created by 홍승아 on 2021/03/06.
//

import UIKit

import Mantis
import SnapKit

class EditImageViewController: UIViewController{
  static let identifier = "EditImageViewController"
  
  @IBOutlet weak var editButton: UIButton!
  @IBOutlet weak var navigationBar: UINavigationBar!
  
  private let pageViewController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
  private let wishViewModel = WishViewModel()
  private var currentPage: Int = 0
  private var imageViewControllers: [ImageViewController] = []
  var images: [UIImage] = []
  
  override func viewDidLoad() {
    super.viewDidLoad()
    configureNavigtaionBar()
    configurePageViewController()
  }
}

extension EditImageViewController {
  private func configureNavigtaionBar(){
    navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
    navigationBar.shadowImage = UIImage()
    navigationBar.backgroundColor = UIColor.clear
    navigationBar.titleTextAttributes = [ NSAttributedString.Key.font : UIFont.systemFont(ofSize: 20, weight: .bold) ]
    navigationBar.topItem?.title = "\(currentPage+1) / \(images.count)"
  }
  
  private func configureImageViewControllers(){
    imageViewControllers = []
    for image in images{
      let imageVC = ImageViewController()
      imageVC.imageType = .uiImage
      imageVC.sizeType = .large
      imageVC.image = image
      imageViewControllers.append(imageVC)
    }
  }
  
  private func configurePageViewController(){
    pageViewController.delegate = self
    pageViewController.dataSource = self
    view.backgroundColor = .white
    addChild(pageViewController)
    view.addSubview(pageViewController.view)
    pageViewController.view.snp.makeConstraints{ (make) in
      make.top.equalTo(navigationBar.snp.bottom)
      make.bottom.equalTo(editButton.snp.top)
      make.leading.equalToSuperview()
      make.trailing.equalToSuperview()
    }
    configureImageViewControllers()
    pageViewController.setViewControllers([imageViewControllers[currentPage]], direction: .forward, animated: true, completion: nil)
  }
  
  private func updatePageViewController(){
    configureImageViewControllers()
    pageViewController.setViewControllers([imageViewControllers[currentPage]], direction: .forward, animated: true, completion: nil)
  }
}

// MARK: - IBAction
extension EditImageViewController {
  @IBAction func backButtonDidTap(_ sender: Any) {
    dismiss(animated: true, completion: nil)
  }

  @IBAction func doneButtonDidTap(_ sender: Any) {
    wishViewModel.setImage(images: images)
    dismiss(animated: true, completion: nil)
  }

  @IBAction func editButtonDidTap(_ sender: Any) {
    let cropViewController = Mantis.cropViewController(image: images[currentPage])
    cropViewController.delegate = self
    cropViewController.modalPresentationStyle = .fullScreen
    self.present(cropViewController, animated: true, completion: nil)
  }
}

// MARK: - UIPageViewControllerDataSource
extension EditImageViewController: UIPageViewControllerDataSource{
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

// MARK: - UIPageViewControllerDelegate
extension EditImageViewController: UIPageViewControllerDelegate{
  func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
    guard completed else { return }
    guard let vc = pageViewController.viewControllers?[0] as? ImageViewController, let index = imageViewControllers.firstIndex(of: vc) else{ return }
    currentPage = index
    navigationBar.topItem?.title = "\(index + 1) / \(images.count)"
  }
}

// MARK: - CropViewControllerDelegate
extension EditImageViewController: CropViewControllerDelegate{
  func cropViewControllerDidCrop(_ cropViewController: CropViewController, cropped: UIImage, transformation: Transformation) {
    images[currentPage] = cropped
    updatePageViewController()
    dismiss(animated: true, completion: nil)
  }
  
  func cropViewControllerDidCancel(_ cropViewController: CropViewController, original: UIImage) {
    dismiss(animated: true, completion: nil)
  }
}
