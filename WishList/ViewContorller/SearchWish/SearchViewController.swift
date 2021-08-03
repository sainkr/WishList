//
//  SearchViewController.swift
//  WishList
//
//  Created by 홍승아 on 2021/02/08.
//

import UIKit

class SearchWishViewController: UIViewController {
  
  @IBOutlet weak var searchBar: UISearchBar!
  @IBOutlet weak var tableView: UITableView!
  @IBOutlet weak var nameSwitch: UISwitch!
  @IBOutlet weak var tagSwitch: UISwitch!
  
  static let identifier = "SearchWishViewController"
  let wishViewModel = WishViewModel()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    let nibName = UINib(nibName: "WishListCell", bundle: nil)
    
    tableView.register(nibName, forCellReuseIdentifier: WishListCell.identifier)
    wishViewModel.filterWish("", "", .none)
  }
  
  @IBAction func backButtonTapped(_ sender: Any) {
    dismiss(animated: true, completion: nil)
  }
}

extension SearchWishViewController: UITableViewDataSource{
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return wishViewModel.filterWishs.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard let cell = tableView.dequeueReusableCell(withIdentifier: WishListCell.identifier, for: indexPath) as? WishListCell else {
      return UITableViewCell()
    }
    
    cell.favoriteButtonTapHandler = {
      cell.updateFavorite(self.wishViewModel.filterWishs[indexPath.item].favorite)
      self.wishViewModel.updateFavorite(self.wishViewModel.filterWishs[indexPath.item])
      self.wishViewModel.updateFilterWish(self.wishViewModel.filterWishs[indexPath.item])
      self.tableView.reloadData()
    }
    
    cell.updateUI(self.wishViewModel.filterWishs[indexPath.item])
    
    return cell
  }
}

extension SearchWishViewController: UITableViewDelegate{
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let selectWishStoryboard = UIStoryboard.init(name: "Main", bundle: nil)
    guard let selectWishVC = selectWishStoryboard.instantiateViewController(identifier: "SelectWishViewController") as? SelectWishViewController else { return }
    selectWishVC.modalPresentationStyle = .fullScreen
    
    let index = wishViewModel.findWish(wishViewModel.filterWishs[indexPath.item])
    selectWishVC.index = index
    
    present(selectWishVC, animated: true, completion: nil)
  }
}


extension SearchWishViewController: UISearchBarDelegate{
  private func dismissKeyboard(){
    searchBar.resignFirstResponder()
  }
  
  private func searchWish(){
    guard let searchTerm = searchBar.text,
          searchTerm.isEmpty == false else {
      wishViewModel.filterWish("", "", .none)
      tableView.reloadData()
      return }
    
    var searchType: SearchType = .none
    if nameSwitch.isOn, tagSwitch.isOn {
      searchType = .all
    }else if nameSwitch.isOn{
      searchType = .name
    }else if tagSwitch.isOn{
      searchType = .tag
    }
    self.wishViewModel.filterWish(searchTerm, searchTerm, searchType)
    tableView.reloadData()
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
