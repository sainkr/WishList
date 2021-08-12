//
//  SearchPlaceTableViewCell.swift
//  WishList
//
//  Created by 홍승아 on 2021/08/11.
//

import UIKit

class SearchPlaceTableViewCell: UITableViewCell {
  static let identifier = "SearchPlaceTableViewCell"
  
  @IBOutlet weak var placeLabel: UILabel!
  @IBOutlet weak var addressLabel: UILabel!
  
  func updateUI(_ place: String, _ address: String){
    placeLabel.text = place
    addressLabel.text = address
  }
}
