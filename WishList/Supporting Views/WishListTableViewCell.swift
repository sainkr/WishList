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
  
  func updateUI(_ wish: Wish){
    thumbnailImageView.layer.cornerRadius = 10
    if wish.img.count > 0 {
      thumbnailImageView.image = wish.img[0]
    }else if wish.imgURL.count > 0 {
      let url = URL(string: wish.imgURL[0])
      thumbnailImageView.kf.setImage(with: url)
    }else {
      thumbnailImageView.image = UIImage(systemName: "face.smiling")
      thumbnailImageView.tintColor = #colorLiteral(red: 0.03379072994, green: 0, blue: 0.9970340133, alpha: 1)
    }
    nameLabel.text = wish.name
    contentLabel.text = wish.memo
    if let place = wish.place{
      convertToAddressWith(coordinate: CLLocation(latitude: place.lat, longitude: place.lng))
    }
    favoriteButton.addTarget(self, action:#selector(WishListTableViewCell.favoriteButtonTapped(_:)), for: .touchUpInside)
    if wish.favorite{
      favoriteButton.setImage(UIImage(systemName: "heart.fill"), for: .normal)
      favoriteButton.tintColor = #colorLiteral(red: 1, green: 0.3110373616, blue: 0.312485069, alpha: 1)
    } else {
      favoriteButton.setImage(UIImage(systemName: "heart"), for: .normal)
      favoriteButton.tintColor = #colorLiteral(red: 0.6666666865, green: 0.6666666865, blue: 0.6666666865, alpha: 1)
    }
  }
  
  func updateFavorite(_ current: Bool){
    if current{
      favoriteButton.setImage(UIImage(systemName: "heart"), for: .normal)
    } else {
      favoriteButton.setImage(UIImage(systemName: "heart.fill"), for: .normal)
    }
  }
  
  @objc func favoriteButtonTapped(_ sender:UIButton!){
    favoriteButtonTapHandler?()
  }

  func convertToAddressWith(coordinate: CLLocation){
    let geoCoder = CLGeocoder()
    let locale = Locale(identifier: "Ko-kr")
    geoCoder.reverseGeocodeLocation(coordinate, preferredLocale: locale, completionHandler: {(placemarks, error) in
      if let address: [CLPlacemark] = placemarks {
        if let name: String = address.last?.name {
          self.addressLabel.text = name
        }
      }
    })
  }
}
