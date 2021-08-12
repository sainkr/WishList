//
//  ImageViewController.swift
//  WishList
//
//  Created by 홍승아 on 2021/08/03.
//

import UIKit

import Kingfisher
import SnapKit

class ImageViewController: UIViewController {
  private var imageView = UIImageView()
  var imageType: ImageType = .none
  var sizeType: ImageSizeType = .small
  var index: Int = 0
  var imgIndex: Int = 0
  var image: UIImage?
  var imageURL: String?
  
  let wishViewModel = WishViewModel()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    configureImage()
  }
  
  private func configureImage(){
    if let image = image {
      imageView.image = image
    }else if let imageURL = imageURL {
      let url = URL(string: imageURL)
      imageView.kf.setImage(with: url)
    }
    view.addSubview(imageView)
    imageView.snp.makeConstraints{(make) in
      make.top.equalToSuperview()
      make.bottom.equalToSuperview()
      make.leading.equalToSuperview()
      make.trailing.equalToSuperview()
    }
    if sizeType == .small{
      imageView.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: view.bounds.width)
      imageView.contentMode = .scaleAspectFill
      imageView.isUserInteractionEnabled = true
      let imageViewTap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageViewTapped(_:)))
      self.imageView.addGestureRecognizer(imageViewTap)
    }else if sizeType == .large{
      imageView.contentMode = .scaleAspectFit
    }
  }
  
  @objc func imageViewTapped(_ gesture: UITapGestureRecognizer) {
    let storyboard = UIStoryboard(name: "Main", bundle: nil)
    guard let showImageVC = storyboard.instantiateViewController(withIdentifier: ShowImageViewController.identifier) as? ShowImageViewController else { return }
    showImageVC.index = index
    showImageVC.type = imageType
    showImageVC.imgIndex = imgIndex
    showImageVC.modalPresentationStyle = .fullScreen
    present(showImageVC, animated: true, completion: nil)
  }
}
