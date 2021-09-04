//
//  SearchViewController.swift
//  WishList
//
//  Created by 홍승아 on 2021/02/08.
//

import UIKit

import SnapKit

class SearchWishViewController: UIViewController {
  static let identifier = "SearchWishViewController"
  
  @IBOutlet weak var searchBar: UISearchBar!
  @IBOutlet weak var nameSwitch: UISwitch!
  @IBOutlet weak var tagSwitch: UISwitch!
  @IBOutlet weak var wishTableView: UITableView!
  
  private let filterWishViewModel = FilterWishViewModel()
  private let wishViewModel = WishViewModel()
  private var searchText = ""
  private var searchType: SearchType = .none
  
  override func viewDidLoad() {
    super.viewDidLoad()
    registerWishTableViewCells()
  }
  
  private func registerWishTableViewCells(){
    let wishTableViewCellNib = UINib(nibName: WishListTableViewCell.identifier, bundle: nil)
    wishTableView.register(wishTableViewCellNib, forCellReuseIdentifier: WishListTableViewCell.identifier)
  }
  
  @IBAction func backButtonDidTap(_ sender: Any) {
    dismiss(animated: true, completion: nil)
  }
}

extension SearchWishViewController: UITableViewDataSource{
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return filterWishViewModel.filterWishsCount(text: searchText, type: searchType)
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard let cell = tableView.dequeueReusableCell(withIdentifier: WishListTableViewCell.identifier, for: indexPath) as? WishListTableViewCell else {
      return UITableViewCell()
    }
    
    let filterWish = self.filterWishViewModel.filterWish(text: self.searchText, type: self.searchType, index: indexPath.item)
    let index = self.wishViewModel.findWish(filterWish)
    
    cell.favoriteButtonTapHandler = {
      self.wishViewModel.updateFavorite(index)
      cell.updateFavorite(favorite: !filterWish.favorite)
      self.wishTableView.reloadData()
    }
    
    cell.updateUI(wish: filterWish, imageType: wishViewModel.imageType(index))
    
    return cell
  }
}

// MARK: - UITableViewDelegate
extension SearchWishViewController: UITableViewDelegate{
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
    guard let selectWishVC = storyboard?.instantiateViewController(identifier: SelectWishViewController.identifier) as? SelectWishViewController else { return }
    let filterWish = self.filterWishViewModel.filterWish(text: self.searchText, type: self.searchType, index: indexPath.item)
    let index = self.wishViewModel.findWish(filterWish)
    selectWishVC.modalPresentationStyle = .fullScreen
    selectWishVC.index = index
    present(selectWishVC, animated: true, completion: nil)
  }
  
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return WishListTableViewCell.height
  }
}

// MARK: - UISearchBarDelegate
extension SearchWishViewController: UISearchBarDelegate{
  private func dismissKeyboard(){
    searchBar.resignFirstResponder()
  }
  
  private func searchWish(){
    guard let searchTerm = searchBar.text, searchTerm.isEmpty == false else {
      searchText = ""
      wishTableView.reloadData()
      return
    }
    searchText = searchTerm
    if nameSwitch.isOn, tagSwitch.isOn {
      searchType = .all
    }else if nameSwitch.isOn{
      searchType = .name
    }else if tagSwitch.isOn{
      searchType = .tag
    }
    wishTableView.reloadData()
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
