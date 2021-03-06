//
//  PhotosSelectViewController.swift
//  WishList
//
//  Created by 홍승아 on 2021/01/31.
//

import UIKit
import PhotosUI
import Mantis

class AddPhotoViewController: UIViewController{
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    let photoViewModel = PhotoViewModel()

    var itemProviders: [NSItemProvider] = []
    var iterator: IndexingIterator<[NSItemProvider]>?
    
    let DoneEditNotification: Notification.Name = Notification.Name("DoneEditNotification")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.doneEditNotification(_:)), name: DoneEditNotification , object: nil)
    }
    
    @objc func doneEditNotification(_ noti: Notification){
        collectionView.reloadData()
    }
}

extension AddPhotoViewController:  UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photoViewModel.photos.count + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCell", for: indexPath) as? PhotoCell else {
            return UICollectionViewCell()
        }
        
        if indexPath.item == 0 {
            cell.updateUI()
        }
        else {
            let photo = photoViewModel.photos[indexPath.item - 1]
            cell.updateUI(photo)
        }
        
        cell.deleteButtonTapHandler = {
            let photo = self.photoViewModel.photos[indexPath.item - 1]
            self.photoViewModel.deletePhoto(photo)
            self.collectionView.reloadData()
        }
        
        return cell
    }
    
}

extension AddPhotoViewController: UICollectionViewDelegate{
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.item == 0 {
            if #available(iOS 14, *) {
                var configuration = PHPickerConfiguration(photoLibrary: PHPhotoLibrary.shared())
                configuration.selectionLimit = 5
                configuration.filter = .any(of: [.images])
                
                let picker = PHPickerViewController(configuration: configuration)
                picker.delegate = self
                picker.modalPresentationStyle = .fullScreen
                self.present(picker, animated: true, completion: nil)
            } else {
            }
        }
    }
}

extension AddPhotoViewController: PHPickerViewControllerDelegate {
    
    @available(iOS 14, *)
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true) // 1
        
        itemProviders = results.map(\.itemProvider)
        iterator = itemProviders.makeIterator()

        if itemProviders.count + photoViewModel.photos.count > 5{
            let alert = UIAlertController(title: nil, message: "사진은 최대 5개까지 선택  가능합니다.", preferredStyle: UIAlertController.Style.alert)
            let okAction = UIAlertAction(title: "확인", style: .default, handler : nil )
            alert.addAction(okAction)
            present(alert, animated: true, completion: nil)
        } else {
            var count = 0
            while true {
                if let itemProvider = iterator?.next(), itemProvider.canLoadObject(ofClass: UIImage.self) {
                    itemProvider.loadObject(ofClass: UIImage.self) { [weak self] image, error in
                        guard let self = self, let image = image as? UIImage else {return}
                        self.photoViewModel.addPhoto(image)
                        count += 1
                        if count == results.count {
                            DispatchQueue.main.async {
                                let addWishListStoryboard = UIStoryboard.init(name: "AddWishList", bundle: nil)
                                guard let editImageVC = addWishListStoryboard.instantiateViewController(identifier: "EditImageViewController") as? EditImageViewController else { return }
                                editImageVC.modalPresentationStyle = .fullScreen
                                
                                self.present(editImageVC, animated: true, completion: nil)
                            }
                        }
                    }
                }
                else {
                    break
                }
            }
        }
    }
}

extension AddPhotoViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width: CGFloat = 100
        let height: CGFloat = 100
        
        return CGSize(width: width, height: height)
    }
}

class PhotoCell: UICollectionViewCell{
    @IBOutlet weak var thumbnailImageView: UIImageView!
    @IBOutlet weak var deleteButton: UIButton!
    
    var deleteButtonTapHandler: (() -> Void )?
    
    func updateUI(_ photo: UIImage){
        thumbnailImageView.image = photo
        deleteButton.isHidden = false
    }
    
    func updateUI(){
        thumbnailImageView.image = UIImage(systemName: "camera.circle")
        deleteButton.isHidden = true
    }
    
    @IBAction func deleteButonTapped(_ sender: Any) {
        deleteButtonTapHandler?()
    }
}

extension AddPhotoViewController: CropViewControllerDelegate {
    func cropViewControllerDidCrop(_ cropViewController: CropViewController, cropped: UIImage, transformation: Transformation) {
        dismiss(animated: true, completion: nil)
    }
    
    func cropViewControllerDidCancel(_ cropViewController: CropViewController, original: UIImage) {
        dismiss(animated: true, completion: nil)
    }
}
