//
//  SearchViewController.swift
//  WishList
//
//  Created by 홍승아 on 2021/02/08.
//

import UIKit

class SearchViewController: UIViewController {

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var nameSwitch: UISwitch!
    @IBOutlet weak var tagSwitch: UISwitch!
    
    let wishViewModel = WishViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        wishViewModel.filterWish("", "", 0)
    }

    @IBAction func backButtonTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}

extension SearchViewController: UICollectionViewDataSource{
    // 아이템 수
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return wishViewModel.filterWishs.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "WishListCell", for: indexPath) as? WishListCell else {
            return UICollectionViewCell()
        }
        
        cell.favoriteButtonTapHandler = {
            cell.updateFavorite(self.wishViewModel.filterWishs[indexPath.item].favorite)
            self.wishViewModel.updateFavorite(self.wishViewModel.filterWishs[indexPath.item])
            self.wishViewModel.updateFilterWish(self.wishViewModel.filterWishs[indexPath.item])
            self.collectionView.reloadData()
        }
        
        cell.updateUI(self.wishViewModel.filterWishs[indexPath.item])
        
        return cell
    }
    
}

extension SearchViewController: UICollectionViewDelegate{
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let selectWishStoryboard = UIStoryboard.init(name: "Main", bundle: nil)
        guard let selectWishVC = selectWishStoryboard.instantiateViewController(identifier: "SelectWishViewController") as? SelectWishViewController else { return }
        selectWishVC.modalPresentationStyle = .fullScreen
        
        var index = -1
        
        for i in 0..<wishViewModel.wishs.count{
            if wishViewModel.wishs[i].timestamp == wishViewModel.filterWishs[indexPath.item].timestamp{
                index = i
                break
            }
        }
        
        selectWishVC.paramIndex = index
        
        present(selectWishVC, animated: true, completion: nil)
    }
}

extension SearchViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width: CGFloat = collectionView.bounds.width
        let height: CGFloat = 110
        
        return CGSize(width: width, height: height)
    }
}

extension SearchViewController: UISearchBarDelegate{
    
    private func dismissKeyboard(){
        searchBar.resignFirstResponder()
    }
    
    private func searchWish(){
        guard let searchTerm = searchBar.text,
              searchTerm.isEmpty == false else {
            wishViewModel.filterWish("", "", 0)
            collectionView.reloadData()
            return }
        
        print("--> searchTerm : \(searchTerm)")
  
        if nameSwitch.isOn && tagSwitch.isOn { // 둘 다 선택되어있을 때
            self.wishViewModel.filterWish(searchTerm, searchTerm, 3)
        }
        else {
            if nameSwitch.isOn { // 이름만 선택되어 있을 때
                self.wishViewModel.filterWish(searchTerm, searchTerm, 1)
            } else if tagSwitch.isOn { // 태그만 선택되어 있을 때
                self.wishViewModel.filterWish(searchTerm, searchTerm, 2)
            }
        }
        
        collectionView.reloadData()
    }
    
    // 텍스트 변경 될 때 마다
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchWish()
    }
        
    // 키보드 search 버튼 누른 후
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        dismissKeyboard()
        searchWish()
    }
}
