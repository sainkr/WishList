//
//  AddImageCollectionViewCell.swift
//  WishList
//
//  Created by 홍승아 on 2021/09/05.
//

import UIKit

class AddImageCollectionViewCell: UICollectionViewCell {
  static let identifier = "AddImageCollectionViewCell"
  
  static let width: CGFloat = 100
  static let height: CGFloat = 100
  
  @IBOutlet weak var thumbnailImageView: UIImageView!
  @IBOutlet weak var deleteButton: UIButton!
  @IBOutlet weak var addImageView: UIImageView!
  
  var deleteButtonTapHandler: (() -> Void )?
  
  override func awakeFromNib() {
    super.awakeFromNib()
    // Initialization code
  }
  
  func updateUI(_ photo: UIImage){
    thumbnailImageView.isHidden = false
    deleteButton.isHidden = false
    addImageView.isHidden = true
    thumbnailImageView.image = photo
  }
  
  func updateUI(){
    thumbnailImageView.isHidden = true
    deleteButton.isHidden = true
    addImageView.isHidden = false
    addImageView.image = UIImage(systemName: "camera.circle")
    addImageView.tintColor = #colorLiteral(red: 0.05892608315, green: 0, blue: 0.9960646033, alpha: 1)
  }

  @IBAction func deleteButtonDidTap(_ sender: Any) {
    deleteButtonTapHandler?()
  }
}
