//
//  ViewController.swift
//  WishList
//
//  Created by 홍승아 on 2021/01/28.
//

import UIKit
import Kingfisher

class WishViewController: UIViewController {
    
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var addButton: UIButton!
    
    let wishListViewModel = WishViewModel()
    let tagViewModel = TagViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    
        // favoriteButton.backgroun
        view.addSubview(addButton)
        NotificationCenter.default.addObserver(self, selector: #selector(self.didReciveWishsNotification(_:)), name: DidReceiveWishsNotification , object: nil)
    }
        
    @objc func didReciveWishsNotification(_ noti: Notification){
        guard let wishs = noti.userInfo?["wishs"] as? [Wish] else { return }
        self.wishListViewModel.setWish(wishs)
        print("--> wishs count : \(wishs.count)")
        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        collectionView.reloadData()
    }
    
    @IBAction func searchButtonTapped(_ sender: Any) {
        let searchStoryboard = UIStoryboard.init(name: "Search", bundle: nil)
        guard let searchVC = searchStoryboard.instantiateViewController(identifier: "SearchViewController") as? SearchViewController else { return }
        searchVC.modalPresentationStyle = .fullScreen
        
        present(searchVC, animated: true, completion: nil)
    }
    
    @IBAction func addButtonTapped(_ sender: Any) {
        let addWishListStoryboard = UIStoryboard.init(name: "AddWishList", bundle: nil)
        guard let addWishListVC = addWishListStoryboard.instantiateViewController(identifier: "AddWishListViewController") as? AddWishListViewController else { return }
        addWishListVC.modalPresentationStyle = .fullScreen
        addWishListVC.paramIndex = -1
        
        present(addWishListVC, animated: true, completion: nil)
    }
    
}

extension WishViewController: UICollectionViewDataSource{
    
    // 섹션 몇개
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    // 아이템 수
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0 {
            return wishListViewModel.favoriteWishs().count
        }
        else {
            return wishListViewModel.wishs.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if indexPath.section == 0 {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "WishListCell", for: indexPath) as? WishListCell else {
                return UICollectionViewCell()
            }
            
            /*cell.favoriteButtonTapHandler = {
                cell.updateFavorite(self.wishListViewModel.wishs[indexPath.item].favorite)
                self.wishListViewModel.updateFavorite(indexPath.item)
            }*/
            
            cell.updateUI(wishListViewModel.favoriteWishs()[indexPath.item])
            
            return cell
        }
        else {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "WishListCell", for: indexPath) as? WishListCell else {
                return UICollectionViewCell()
            }
            
            cell.favoriteButtonTapHandler = {
                cell.updateFavorite(self.wishListViewModel.wishs[indexPath.item].favorite)
                self.wishListViewModel.updateFavorite(indexPath.item)
                collectionView.reloadData()
            }
            
            cell.updateUI(wishListViewModel.wishs[indexPath.item])
            
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            guard let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "WishListHeaderView", for: indexPath) as? WishListHeaderView else {
                return UICollectionReusableView()
            }
            
            if indexPath.section == 0{
                header.updateUI("즐겨찾는 Wish")
            }
            else {
                header.updateUI("나의 Wish")
            }
            
            return header
        default:
            return UICollectionReusableView ()
        }
    }
    
}

extension WishViewController: UICollectionViewDelegate{
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let selectWishStoryboard = UIStoryboard.init(name: "Main", bundle: nil)
        guard let selectWishVC = selectWishStoryboard.instantiateViewController(identifier: "SelectWishViewController") as? SelectWishViewController else { return }
        selectWishVC.modalPresentationStyle = .fullScreen
        
        selectWishVC.paramIndex = indexPath.item
        
        present(selectWishVC, animated: true, completion: nil)
    }
}

extension WishViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width: CGFloat = collectionView.bounds.width
        let height: CGFloat = 110
        
        return CGSize(width: width, height: height)
    }
}

class WishListHeaderView: UICollectionReusableView{
    @IBOutlet weak var titleLabel: UILabel!
    
    func updateUI(_ title: String){
        titleLabel.text = title
    }
}


class WishListCell: UICollectionViewCell {
    @IBOutlet weak var thumbnailImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var tagLabel: UILabel!
    @IBOutlet weak var lineView: UIView!
    @IBOutlet weak var favoriteButton: UIButton!
    
    var favoriteButtonTapHandler: (() -> Void )?
    
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
                thumbnailImageView.image = #imageLiteral(resourceName: "Image-1")
            }
        }
        if wish.tag.count > 0{
            tagLabel.text = wish.tagString
        } else{
            tagLabel.text = ""
        }
        
        nameLabel.text = wish.name
        
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
        // print("---> 클릭")
        favoriteButtonTapHandler?()
    }
}
