//
//  WishListCell.swift
//  WishList
//
//  Created by 홍승아 on 2021/05/20.
//

import UIKit

class WishListCell: UICollectionViewCell {
    @IBOutlet weak var thumbnailImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var lineView: UIView!
    @IBOutlet weak var favoriteButton: UIButton!
    @IBOutlet weak var tagLabel: UILabel!
    
    var favoriteButtonTapHandler: (() -> Void )?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func updateUI(_ wish: Wish){
        thumbnailImageView.layer.cornerRadius = 10
        
        if wish.photo.count > 0 {
            thumbnailImageView.image = wish.photo[0]
        }
        else {
            if wish.img.count > 0 {
                let url = URL(string: wish.img[0])
                thumbnailImageView.kf.setImage(with: url)
            }
            else {
                thumbnailImageView.image = UIImage(systemName: "face.smiling")
                thumbnailImageView.tintColor = #colorLiteral(red: 0.03379072994, green: 0, blue: 0.9970340133, alpha: 1)
            }
        }
        
        nameLabel.text = wish.name
        
        tagLabel.text = wish.tagString
        
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
