//
//  FavoriteWishViewController.swift
//  WishList
//
//  Created by 홍승아 on 2021/08/09.
//

import UIKit

class FavoriteWishViewController: UIViewController {
  static let identifier = "FavoriteWishViewController"
  
  @IBOutlet weak var navigationBar: UINavigationBar!
  @IBOutlet weak var wishTableView: UITableView!
  
  private let wishViewModel = WishViewModel()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    configureNavigationBar()
    registerWishTableViewCells()
  }
  
  private func registerWishTableViewCells(){
    let wishTableViewCellNib = UINib(nibName: WishListTableViewCell.identifier, bundle: nil)
    wishTableView.register(wishTableViewCellNib, forCellReuseIdentifier: WishListTableViewCell.identifier)
  }
  
  private func configureNavigationBar() {
    navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
    navigationBar.shadowImage = UIImage()
    navigationBar.backgroundColor = UIColor.clear
    navigationBar.titleTextAttributes = [ NSAttributedString.Key.font : UIFont.systemFont(ofSize: 18, weight: .bold) ]
  }
  
  @IBAction func backButtonTapped(_ sender: Any) {
    dismiss(animated: true, completion: nil)
  }
}

extension FavoriteWishViewController: UITableViewDataSource{
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return wishViewModel.favoriteWishs.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard let cell = tableView.dequeueReusableCell(withIdentifier: WishListTableViewCell.identifier, for: indexPath) as? WishListTableViewCell else {
      return UITableViewCell()
    }
    
    let favoriteWish = self.wishViewModel.favoriteWishs[indexPath.item]
    let index = self.wishViewModel.findWish(filterWish: favoriteWish)
    
    cell.favoriteButtonTapHandler = {
      self.wishViewModel.updateFavorite(index)
      cell.updateFavorite(favorite: !favoriteWish.favorite)
      self.wishTableView.reloadData()
    }
    
    cell.updateUI(wish: favoriteWish,
                  imageType: wishViewModel.imageType(index))
    
    return cell
  }
}

extension FavoriteWishViewController: UITableViewDelegate{
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
    guard let selectWishVC = storyboard?.instantiateViewController(identifier: SelectWishViewController.identifier) as? SelectWishViewController else { return }
    let favoriteWish = self.wishViewModel.favoriteWishs[indexPath.item]
    let index = self.wishViewModel.findWish(filterWish: favoriteWish)
    selectWishVC.modalPresentationStyle = .fullScreen
    selectWishVC.index = index
    present(selectWishVC, animated: true, completion: nil)
  }
  
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return WishListTableViewCell.height
  }
}
