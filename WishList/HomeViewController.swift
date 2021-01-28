//
//  ViewController.swift
//  WishList
//
//  Created by 홍승아 on 2021/01/28.
//

import UIKit

class HomeViewController: UIViewController {

    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var sliderButton: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var addButton: UIButton!
    
    let wishListViewModel = WishViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        // 데이터 불러오기
        wishListViewModel.loadTasks()
    }

    @IBAction func searchButtonTapped(_ sender: Any) {
    }
    
    @IBAction func sliderButtonTapped(_ sender: Any) {
    }
    
    @IBAction func addButtonTapped(_ sender: Any) {
        let addWishListStoryboard = UIStoryboard.init(name: "AddWishList", bundle: nil)
        guard let addWishListVC = addWishListStoryboard.instantiateViewController(identifier: "AddWishListViewController") as? AddWishListViewController else { return }
        addWishListVC.modalPresentationStyle = .fullScreen
        
        present(addWishListVC, animated: true, completion: nil)
    }
    
}

extension HomeViewController: UICollectionViewDataSource{
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

extension HomeViewController: UICollectionViewDelegate{
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    
        
    }
}

extension HomeViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width: CGFloat = collectionView.bounds.width
        let height: CGFloat = 110
        
        return CGSize(width: width, height: height)
    }
}

class WishListCell: UICollectionViewCell {
    @IBOutlet weak var thumbnailImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    
    func updateUI(_ wish: Wish){
        // thumbnailImageView.image = wish.
        nameLabel.text = wish.name
    }
}
