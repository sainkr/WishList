//
//  AddWishImageCollectionViewCell.swift
//  WishList
//
//  Created by 홍승아 on 2021/08/11.
//

import UIKit

class AddImageCollectionViewCell: UICollectionViewCell{
  static let identifier = "AddImageCollectionViewCell"
  
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

  @IBAction func deleteButtonTapped(_ sender: Any) {
    deleteButtonTapHandler?()
  }
}

