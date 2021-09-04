//
//  SearchPlaceTableViewCell.swift
//  WishList
//
//  Created by 홍승아 on 2021/09/05.
//

import UIKit

class SearchPlaceTableViewCell: UITableViewCell {
  static let identifier = "SearchPlaceTableViewCell"
  
  @IBOutlet weak var placeLabel: UILabel!
  @IBOutlet weak var addressLabel: UILabel!
  
  static let height: CGFloat = 85.5
  
  override func awakeFromNib() {
    super.awakeFromNib()
    // Initialization code
  }
  
  override func setSelected(_ selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
  }
  
  func updateUI(_ place: String, _ address: String){
    placeLabel.text = place
    addressLabel.text = address
  }
}
