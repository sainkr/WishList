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
    
    let wishListViewModel = WishListViewModel()
    let wishViewModel = WishViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let nibName = UINib(nibName: "WishListCell", bundle: nil)

        collectionView.register(nibName, forCellWithReuseIdentifier: "WishListCell")
        
        addShareWish()
        setaddButton()
        
        // DB에서 데이터 다 받았을 때
        NotificationCenter.default.addObserver(self, selector: #selector(self.didReciveWishsNotification(_:)), name: DidReceiveWishsNotification , object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        collectionView.reloadData()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        collectionView.reloadData()
    }
    
    func addShareWish(){ // Share extension에서 추가한 wish 저장
        let defaults = UserDefaults(suiteName: "group.com.sainkr.WishList")
        guard let name = defaults?.string(forKey: "Name") else { return }
        guard let memo = defaults?.string(forKey: "Memo") else { return }
        guard let tags = defaults?.stringArray(forKey: "Tag") else { return }
        guard let url = defaults?.string(forKey: "URL") else { return }
        
        let wish = wishViewModel.createWish(timestamp: Int(Date().timeIntervalSince1970.rounded()),name: name, memo: memo, tags: tags, url: url, photo: [], place: Place(name: "None", lat: 0, lng: 0), favorite: -1)
        
        wishListViewModel.addWish(wish)
        
        collectionView.reloadData()
        
        defaults?.removeObject(forKey: "Name")
        defaults?.removeObject(forKey: "Memo")
        defaults?.removeObject(forKey: "Tag")
        defaults?.removeObject(forKey: "URL")
    }
    
    func setaddButton(){
        view.addSubview(addButton)
        
        addButton.layer.shadowColor = UIColor.black.cgColor // 검정색 사용
        addButton.layer.masksToBounds = false
        addButton.layer.shadowOffset = CGSize(width: 0, height: 1) // 반경에 대해서 너무 적용이 되어서 4point 정도 내림.
        addButton.layer.shadowRadius = 2 // 반경?
        addButton.layer.shadowOpacity = 0.3 // alpha값입니다.
    }
    
    @objc func didReciveWishsNotification(_ noti: Notification){ 
        guard let wishList = noti.userInfo?["wishs"] as? [Wish] else { return }
        self.wishListViewModel.setWishList(wishList)
        wishListViewModel.changeUIImage()
        
        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
    }
}

// IBAction
extension WishViewController{
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
        addWishListVC.wishType = WishType.wishAdd
        
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
            return wishListViewModel.favoriteWishs.count
        }
        else {
            return wishListViewModel.wishList.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.section == 0 {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "WishListCell", for: indexPath) as? WishListCell else {
                return UICollectionViewCell()
            }
            
            cell.favoriteButtonTapHandler = {
                cell.updateFavorite(self.wishListViewModel.favoriteWishs[indexPath.item].favorite)
                self.wishListViewModel.updateFavorite(self.wishListViewModel.favoriteWishs[indexPath.item])
                collectionView.reloadData()
            }
            
            cell.updateUI(wishListViewModel.favoriteWishs[indexPath.item])
            
            return cell
        }
        else {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "WishListCell", for: indexPath) as? WishListCell else {
                return UICollectionViewCell()
            }
            
            cell.favoriteButtonTapHandler = {
                cell.updateFavorite(self.wishListViewModel.wishList[indexPath.item].favorite)
                self.wishListViewModel.updateFavorite(self.wishListViewModel.wishList[indexPath.item])
                
                collectionView.reloadData()
            }
            
            cell.updateUI(wishListViewModel.wishList[indexPath.item])
            
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
        
        if indexPath.section == 0 { // favorite wish
            selectWishVC.wishFavoriteType = .favoriteWish
        }
        else { // my wish
            selectWishVC.wishFavoriteType = .mywish
        }
        
        selectWishVC.selectIndex = indexPath.item
       
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


