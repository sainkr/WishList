//
//  WishListCell.swift
//  WishList
//
//  Created by 홍승아 on 2021/05/20.
//

import UIKit

class WishListCell: UITableViewCell {
  static let identifier = "WishListCell"
  @IBOutlet weak var thumbnailImageView: UIImageView!
  @IBOutlet weak var nameLabel: UILabel!
  @IBOutlet weak var lineView: UIView!
  @IBOutlet weak var favoriteButton: UIButton!
  @IBOutlet weak var contentLabel: UILabel!
  @IBOutlet weak var addressLabel: UILabel!
  
  var favoriteButtonTapHandler: (() -> Void )?
  
  override func awakeFromNib() {
    super.awakeFromNib()
  }
  
  func updateUI(_ wish: Wish){
    thumbnailImageView.layer.cornerRadius = 10
    
    if wish.img.count > 0 {
      thumbnailImageView.image = wish.img[0]
    }
    else {
      if wish.imgURL.count > 0 {
        let url = URL(string: wish.imgURL[0])
        thumbnailImageView.kf.setImage(with: url)
      }
      else {
        thumbnailImageView.image = UIImage(systemName: "face.smiling")
        thumbnailImageView.tintColor = #colorLiteral(red: 0.03379072994, green: 0, blue: 0.9970340133, alpha: 1)
      }
    }
    
    nameLabel.text = wish.name
    contentLabel.text = wish.memo
    addressLabel.text = wish.place.name == "None" ? "" : wish.place.name
    
    favoriteButton.addTarget(self, action:#selector(WishListCell.favoriteButtonTapped(_:)), for: .touchUpInside)
    
    if wish.favorite == 1{
      favoriteButton.setImage(UIImage(systemName: "heart.fill"), for: .normal)
    } else {
      favoriteButton.setImage(UIImage(systemName: "heart"), for: .normal)
    }
  }
  
  func updateFavorite(_ current: Int){
    if current == 1{
      favoriteButton.setImage(UIImage(systemName: "heart"), for: .normal)
    } else {
      favoriteButton.setImage(UIImage(systemName: "heart.fill"), for: .normal)
    }
  }
  
  @objc func favoriteButtonTapped(_ sender:UIButton!){
    favoriteButtonTapHandler?()
  }
}
