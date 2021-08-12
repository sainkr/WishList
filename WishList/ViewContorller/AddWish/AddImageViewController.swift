//
//  PhotosSelectViewController.swift
//  WishList
//
//  Created by 홍승아 on 2021/01/31.
//

import UIKit
import PhotosUI
import Mantis

class AddImageViewController: UIViewController{
  @IBOutlet weak var ImageCollectionView: UICollectionView!
  
  private let wishViewModel = WishViewModel()
  private var itemProviders: [NSItemProvider] = []
  private var iterator: IndexingIterator<[NSItemProvider]>?
  
  override func viewDidLoad() {
    super.viewDidLoad()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(true)
    ImageCollectionView.reloadData()
  }
}

extension AddImageViewController:  UICollectionViewDataSource{
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return wishViewModel.image(wishViewModel.wishsCount - 1).count + 1
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: AddImageCollectionViewCell.identifier, for: indexPath) as? AddImageCollectionViewCell else {
      return UICollectionViewCell()
    }
    if indexPath.item == 0 {
      cell.updateUI()
    }else {
      let photo = wishViewModel.image(wishViewModel.wishsCount - 1)[indexPath.item - 1]
      cell.updateUI(photo)
    }
    cell.deleteButtonTapHandler = {
      self.wishViewModel.removeImage(indexPath.item - 1)
      self.ImageCollectionView.reloadData()
    }
    return cell
  }
}

extension AddImageViewController: UICollectionViewDelegate{
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    if indexPath.item == 0 {
      if #available(iOS 14, *) {
        var configuration = PHPickerConfiguration(photoLibrary: PHPhotoLibrary.shared())
        configuration.selectionLimit = 100
        configuration.filter = .any(of: [.images])
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = self
        picker.modalPresentationStyle = .fullScreen
        self.present(picker, animated: true, completion: nil)
      }
    }
  }
}

extension AddImageViewController: PHPickerViewControllerDelegate {
  private func presentEditImageViewController(_ images: [UIImage]){
    guard let editImageVC = storyboard?.instantiateViewController(identifier: EditImageViewController.identifier) as? EditImageViewController else { return }
    editImageVC.modalPresentationStyle = .fullScreen
    editImageVC.images = wishViewModel.wishImages(images: images)
    present(editImageVC, animated: true, completion: nil)
  }
  
  @available(iOS 14, *)
  func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
    picker.dismiss(animated: true)
    itemProviders = results.map(\.itemProvider)
    iterator = itemProviders.makeIterator()
    var images: [UIImage] = []
    while true {
      guard let itemProvider = iterator?.next(), itemProvider.canLoadObject(ofClass: UIImage.self) else { break }
      itemProvider.loadObject(ofClass: UIImage.self) { image, error in
        guard let image = image as? UIImage else { return }
        images.append(image)
        if images.count == self.itemProviders.count{
          DispatchQueue.main.async {
            self.presentEditImageViewController(images)
          }
        }
      }
    }
  }
}

extension AddImageViewController: UICollectionViewDelegateFlowLayout {
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    let width: CGFloat = 100
    let height: CGFloat = 100
    return CGSize(width: width, height: height)
  }
}

extension AddImageViewController: CropViewControllerDelegate {
  func cropViewControllerDidCrop(_ cropViewController: CropViewController, cropped: UIImage, transformation: Transformation) {
    dismiss(animated: true, completion: nil)
  }
  
  func cropViewControllerDidCancel(_ cropViewController: CropViewController, original: UIImage) {
    dismiss(animated: true, completion: nil)
  }
}
