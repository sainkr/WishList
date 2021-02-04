//
//  PhotosSelectViewController.swift
//  WishList
//
//  Created by 홍승아 on 2021/01/31.
//

import UIKit
import PhotosUI

class PhotoAddViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    let photoViewModel = PhotoViewModel()

    var itemProviders: [NSItemProvider] = []
    var iterator: IndexingIterator<[NSItemProvider]>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
}

extension PhotoAddViewController:  UICollectionViewDataSource{
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
            // self.tagViewModel.deleteTag(tag)
            self.collectionView.reloadData()
        }
        
        return cell
    }
    
}

extension PhotoAddViewController: UICollectionViewDelegate{
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.item == 0 {
            
        if #available(iOS 14, *) {
            // var configuration = PHPickerConfiguration()
            var configuration = PHPickerConfiguration(photoLibrary: PHPhotoLibrary.shared())
            configuration.selectionLimit = 5
            configuration.filter = .any(of: [.images])
            
            let picker = PHPickerViewController(configuration: configuration)
            picker.delegate = self
            self.present(picker, animated: true, completion: nil)
        } else {
            // Fallback on earlier versions
        }
            
            /* let addWishListStoryboard = UIStoryboard.init(name: "AddWishList", bundle: nil)
             guard let photoLibraryVC = addWishListStoryboard.instantiateViewController(identifier: "PhotoLibraryViewController") as? PhotoLibraryViewController else { return }
             photoLibraryVC.modalPresentationStyle = .fullScreen
             
             present(photoLibraryVC, animated: true, completion: nil)
             */
        }
    }
}

extension PhotoAddViewController: PHPickerViewControllerDelegate {
    @available(iOS 14, *)
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true) // 1
        
        itemProviders = results.map(\.itemProvider)
        iterator = itemProviders.makeIterator()

        if itemProviders.count + photoViewModel.photos.count > 5{
            let alert = UIAlertController(title: "사진 선택", message: "최대 5개까지 가능임 ㅇㅇ", preferredStyle: UIAlertController.Style.alert)
            let okAction = UIAlertAction(title: "OK", style: .default, handler : nil )
            alert.addAction(okAction)
            present(alert, animated: true, completion: nil)
        } else {
            while true {
                if let itemProvider = iterator?.next(), itemProvider.canLoadObject(ofClass: UIImage.self) {
                    itemProvider.loadObject(ofClass: UIImage.self) { [weak self] image, error in
                        guard let self = self, let image = image as? UIImage else {return}
                        self.photoViewModel.addPhoto(Photo(image: image))
                        DispatchQueue.main.async {
                            self.collectionView.reloadData()
                        }
                    }
                } else {
                    break
                }
            }
            
        }
    }
}

extension PhotoAddViewController: UICollectionViewDelegateFlowLayout {
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
    
    func updateUI(_ photo: Photo){
        thumbnailImageView.image = photo.image
        deleteButton.isHidden = false
    }
    
    func updateUI(){
        thumbnailImageView.image = #imageLiteral(resourceName: "Image-1")
        deleteButton.isHidden = true
    }
    
    @IBAction func deleteButonTapped(_ sender: Any) {
        deleteButtonTapHandler?()
    }
}

