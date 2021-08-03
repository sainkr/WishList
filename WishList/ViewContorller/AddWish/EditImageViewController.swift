//
//  EditImageViewController.swift
//  WishList
//
//  Created by 홍승아 on 2021/03/06.
//

import UIKit
import Mantis

class EditImageViewController: UIViewController{
  
  @IBOutlet weak var countLabel: UILabel!
  @IBOutlet weak var imageView: UIImageView!
  
  let wishViewModel = WishViewModel()
  var currentPage: Int = 0
  
  let DoneEditNotification: Notification.Name = Notification.Name("DoneEditNotification")
  
  override func viewDidLoad() {
    super.viewDidLoad()
    imageView.image = wishViewModel.imgs[currentPage]
    countLabel.text = "\(currentPage+1) / \(wishViewModel.imgs.count)"
  }
  
  @IBAction func cancleButtonTapped(_ sender: Any) {
    dismiss(animated: true, completion: nil)
  }
  
  @IBAction func doneButtonTapped(_ sender: Any) {
    NotificationCenter.default.post(name: DoneEditNotification, object: nil, userInfo: nil)
    dismiss(animated: true, completion: nil)
  }
  
  @IBAction func editButtonTapped(_ sender: Any) {
    let cropViewController = Mantis.cropViewController(image: self.wishViewModel.imgs[self.currentPage])
    cropViewController.delegate = self
    cropViewController.modalPresentationStyle = .fullScreen
    self.present(cropViewController, animated: true, completion: nil)
  }
}

extension EditImageViewController: CropViewControllerDelegate{
  func cropViewControllerDidCrop(_ cropViewController: CropViewController, cropped: UIImage, transformation: Transformation) {
    wishViewModel.setImage(index: currentPage, img: cropped)
    imageView.image = wishViewModel.imgs[currentPage]
    dismiss(animated: true, completion: nil)
  }
  
  func cropViewControllerDidCancel(_ cropViewController: CropViewController, original: UIImage) {
    dismiss(animated: true, completion: nil)
  }
}
