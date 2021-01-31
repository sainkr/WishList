//
//  PhotosSelectViewController.swift
//  WishList
//
//  Created by 홍승아 on 2021/01/31.
//

import UIKit

class PhotosSelectViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    let imagePickerController = UIImagePickerController()
    
    var img:[UIImage] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePickerController.delegate = self
    }
}

extension PhotosSelectViewController:  UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return img.count + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCell", for: indexPath) as? PhotoCell else {
            return UICollectionViewCell()
        }
        
        if indexPath.item != 0 {
            print("=---> img\(img.count)  \(indexPath.item)")
            cell.updateUI(img[indexPath.item-1])
        }
        return cell
    }
    
}

extension PhotosSelectViewController: UICollectionViewDelegate{
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.item == 0 {
            self.imagePickerController.sourceType = .photoLibrary
            self.present(imagePickerController, animated: true, completion: nil)
        }
    }
}

extension PhotosSelectViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width: CGFloat = 100
        let height: CGFloat = 100
        
        return CGSize(width: width, height: height)
    }
}

extension PhotosSelectViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey.originalImage]{
            img.append(image as! UIImage)

            collectionView.reloadData()
        }
        
        dismiss(animated: true, completion: nil)
    }
}

class PhotoCell: UICollectionViewCell{
    @IBOutlet weak var thumbnailImageView: UIImageView!

    func updateUI(_ image: UIImage){
        thumbnailImageView.image = image
    }
}

