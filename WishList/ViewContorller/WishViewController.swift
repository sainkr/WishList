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
    @IBOutlet weak var sliderButton: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var addButton: UIButton!
    
    let wishListViewModel = WishViewModel()
    let tagViewModel = TagViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        print("--> 실행")
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
        tagViewModel.resetTag()
    }
    
    @IBAction func searchButtonTapped(_ sender: Any) {
        let searchStoryboard = UIStoryboard.init(name: "Search", bundle: nil)
        guard let searchVC = searchStoryboard.instantiateViewController(identifier: "SearchViewController") as? SearchViewController else { return }
        searchVC.modalPresentationStyle = .fullScreen
        
        present(searchVC, animated: true, completion: nil)
    }
    
    @IBAction func sliderButtonTapped(_ sender: Any) {
        
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
    // 아이템 수
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return wishListViewModel.wishs.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "WishListCell", for: indexPath) as? WishListCell else {
            return UICollectionViewCell()
        }
        
        cell.updateUI(wishListViewModel.wishs[indexPath.item])
        
        return cell
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

class WishListCell: UICollectionViewCell {
    @IBOutlet weak var thumbnailImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var tagLabel: UILabel!
    
    func updateUI(_ wish: Wish){
        if wish.photo.count > 0 {
            thumbnailImageView.image = wish.photo[0]
        }
        else {
            if wish.img.count > 0 {
                let url = URL(string: wish.img[0])
                thumbnailImageView.kf.setImage(with: url)
            }
        }
        if wish.tag.count > 0{
            tagLabel.text = wish.tagString
        }
        nameLabel.text = wish.name
    }
}
