//
//  PhotosSelectViewController.swift
//  WishList
//
//  Created by 홍승아 on 2021/01/31.
//

import PhotosUI
import UIKit

import Mantis

class AddImageViewController: UIViewController{
  @IBOutlet weak var imageCollectionView: UICollectionView!
  
  private let wishViewModel = WishViewModel()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    registerAddImageCollectionViewCells()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(true)
    imageCollectionView.reloadData()
  }
  
  private func registerAddImageCollectionViewCells(){
    let addImageCollectionCellNib = UINib(nibName: AddImageCollectionViewCell.identifier, bundle: nil)
    imageCollectionView.register(addImageCollectionCellNib, forCellWithReuseIdentifier: AddImageCollectionViewCell.identifier)
  }
}

// MARK: -  UICollectionViewDataSource
extension AddImageViewController:  UICollectionViewDataSource{
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return wishViewModel.imageCount(wishViewModel.lastWishIndex) + 1
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: AddImageCollectionViewCell.identifier, for: indexPath) as? AddImageCollectionViewCell else {
      return UICollectionViewCell()
    }
    if indexPath.item == 0 {
      cell.updateUI()
    }else {
      let photo = wishViewModel.image(index: wishViewModel.lastWishIndex, imageIndex: indexPath.item - 1)
      cell.updateUI(photo)
    }
    cell.deleteButtonTapHandler = {
      self.wishViewModel.removeImage(indexPath.item - 1)
      self.imageCollectionView.reloadData()

    }
    return cell
  }
}

// MARK: -  UICollectionViewDelegate
extension AddImageViewController: UICollectionViewDelegate{
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    if indexPath.item == 0 {
      if #available(iOS 14, *) {
        var configuration = PHPickerConfiguration()
        configuration.selectionLimit = 0
        configuration.filter = .any(of: [.images])
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = self
        picker.modalPresentationStyle = .fullScreen
        self.present(picker, animated: true, completion: nil)
      }
    }
  }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension AddImageViewController: UICollectionViewDelegateFlowLayout {
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    return CGSize(width: AddImageCollectionViewCell.width, height: AddImageCollectionViewCell.height)
  }
}

// MARK: - PHPickerViewControllerDelegate
extension AddImageViewController: PHPickerViewControllerDelegate {
  private func presentEditImageViewController(_ images: [UIImage]){
    DispatchQueue.main.async {
      guard let editImageVC = self.storyboard?.instantiateViewController(identifier: EditImageViewController.identifier) as? EditImageViewController else { return }
      editImageVC.modalPresentationStyle = .fullScreen
      editImageVC.images = self.wishViewModel.wishImages(images: images)
      self.present(editImageVC, animated: true, completion: nil)
    }
  }
  
  @available(iOS 14, *)
  func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
    picker.dismiss(animated: true)
    let loadUIImage = LoadUIImage(results.map(\.itemProvider))
    loadUIImage.image{ images in
      self.presentEditImageViewController(images)
    }
  }
}

// MARK: - CropViewControllerDelegate
extension AddImageViewController: CropViewControllerDelegate {
  func cropViewControllerDidCrop(_ cropViewController: CropViewController, cropped: UIImage, transformation: Transformation) {
    dismiss(animated: true, completion: nil)
  }
  
  func cropViewControllerDidCancel(_ cropViewController: CropViewController, original: UIImage) {
    dismiss(animated: true, completion: nil)
  }
}
