//
//  WishListCell.swift
//  WishList
//
//  Created by 홍승아 on 2021/05/20.
//

import UIKit
import CoreLocation

class WishListTableViewCell: UITableViewCell {
  static let identifier = "WishListTableViewCell"
  static let height: CGFloat = 120
  
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
  
  func updateUI(wish: Wish, imageType: ImageType){
    favoriteButton.addTarget(self, action:#selector(WishListTableViewCell.favoriteButtonTapped(_:)), for: .touchUpInside)
    updateThumbnail(image: wish.img, imageURL: wish.imgURL, imageType: imageType)
    updateLabel(name: wish.name, memo: wish.memo, place: wish.place)
    updateFavorite(favorite: wish.favorite)
  }
  
  private func updateThumbnail(image: [UIImage], imageURL: [String], imageType: ImageType){
    thumbnailImageView.layer.cornerRadius = 10
    if imageType == .uiImage{
      thumbnailImageView.image = image[0]
    }else if imageType == .url{
      let url = URL(string: imageURL[0])
      thumbnailImageView.kf.setImage(with: url)
    }else {
      thumbnailImageView.image = UIImage(systemName: "face.smiling")
      thumbnailImageView.tintColor = #colorLiteral(red: 0.03379072994, green: 0, blue: 0.9970340133, alpha: 1)
    }
  }
  
  private func updateLabel(name: String, memo: String, place: Place?){
    nameLabel.text = name
    contentLabel.text = memo
    self.addressLabel.text = name
    if let place = place{
      ConvertToAddress.convertToAddressWith(
        latitude: place.lat, longitude: place.lng,
        completion: { [weak self] address in
          self?.addressLabel.text = address
        })
    }
  }
  
  func updateFavorite(favorite: Bool){
    if favorite{
      favoriteButton.setImage(UIImage(systemName: "heart.fill"), for: .normal)
      favoriteButton.tintColor = .red
    } else {
      favoriteButton.setImage(UIImage(systemName: "heart"), for: .normal)
      favoriteButton.tintColor = .lightGray
    }
  }
  
  @objc func favoriteButtonTapped(_ sender:UIButton!){
    favoriteButtonTapHandler?()
  }
}
