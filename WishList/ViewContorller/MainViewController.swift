//
//  ViewController.swift
//  WishList
//
//  Created by 홍승아 on 2021/01/28.
//

import UIKit

import Kingfisher

class MainViewController: UIViewController {
  @IBOutlet weak var searchButton: UIButton!
  @IBOutlet weak var addButton: UIButton!
  @IBOutlet weak var wishTableView: UITableView!
  
  private let wishViewModel = WishViewModel()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    registerWishTableViewCells()
    addShareWish()
    configureAddButton()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    NotificationCenter.default.addObserver(self, selector: #selector(self.didReciveWishsNotification(_:)), name: DidReceiveWishsNotification , object: nil)
    wishTableView.reloadData()
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    NotificationCenter.default.removeObserver(self, name: DidReceiveWishsNotification, object: nil)
  }
  
  override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
    super.viewWillTransition(to: size, with: coordinator)
    wishTableView.reloadData()
  }
  
  private func registerWishTableViewCells(){
    let wishTableViewCellNib = UINib(nibName: WishListTableViewCell.identifier, bundle: nil)
    wishTableView.register(wishTableViewCellNib, forCellReuseIdentifier: WishListTableViewCell.identifier)
  }
  
  private func configureAddButton(){
    addButton.layer.shadowColor = UIColor.black.cgColor
    addButton.layer.masksToBounds = false
    addButton.layer.shadowOffset = CGSize(width: 0, height: 1)
    addButton.layer.shadowRadius = 2
    addButton.layer.shadowOpacity = 0.3
  }
  
  @objc func didReciveWishsNotification(_ noti: Notification){
    guard let wishList = noti.userInfo?["wishs"] as? [Wish] else { return }
    wishViewModel.setWishList(wishList)
    DispatchQueue.main.async {
      self.wishTableView.reloadData()
    }
  }
  
  private func addShareWish(){ // Share extension에서 추가한 wish 저장
    let defaults = UserDefaults(suiteName: "group.com.sainkr.WishList")
    guard let name = defaults?.string(forKey: "Name") else { return }
    guard let memo = defaults?.string(forKey: "Memo") else { return }
    guard let tag = defaults?.stringArray(forKey: "Tag") else { return }
    guard let url = defaults?.string(forKey: "URL") else { return }
    wishViewModel.addWish(name, memo, tag, url)
    wishTableView.reloadData()
    defaults?.removeObject(forKey: "Name")
    defaults?.removeObject(forKey: "Memo")
    defaults?.removeObject(forKey: "Tag")
    defaults?.removeObject(forKey: "URL")
  }
}

// MARK:- IBAction
extension MainViewController{
  @IBAction func searchButtonDidTap(_ sender: Any) {
    guard let searchVC = storyboard?.instantiateViewController(identifier: SearchWishViewController.identifier ) as? SearchWishViewController else { return }
    searchVC.modalPresentationStyle = .fullScreen
    present(searchVC, animated: true, completion: nil)
  }
  
  @IBAction func mapButtonDidTap(_ sender: Any) {
    guard let mapVC = storyboard?.instantiateViewController(identifier: "MapViewController") as? MapViewController else { return }
    mapVC.modalPresentationStyle = .fullScreen
    present(mapVC, animated: true, completion: nil)
  }
  
  @IBAction func favoriteButtonDidTap(_ sender: Any) {
    guard let searchVC = storyboard?.instantiateViewController(identifier: FavoriteWishViewController.identifier ) as? FavoriteWishViewController else { return }
    searchVC.modalPresentationStyle = .fullScreen
    present(searchVC, animated: true, completion: nil)
  }
  
  @IBAction func addButtonDidTap(_ sender: Any) {
    guard let addWishListVC = storyboard?.instantiateViewController(identifier: AddWishViewController.identifier) as? AddWishViewController else { return }
    addWishListVC.modalPresentationStyle = .fullScreen
    addWishListVC.wishType = WishType.wishAdd
    present(addWishListVC, animated: true, completion: nil)
  }
}

// MARK:- UITableViewDataSource
extension MainViewController: UITableViewDataSource{
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return wishViewModel.wishsCount
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard let cell = tableView.dequeueReusableCell(withIdentifier: WishListTableViewCell.identifier, for: indexPath) as? WishListTableViewCell else {
      return UITableViewCell()
    }
    
    cell.favoriteButtonTapHandler = {
      self.wishViewModel.updateFavorite(indexPath.item)
      cell.updateFavorite(favorite: self.wishViewModel.favorite(indexPath.item))
      tableView.reloadData()
    }
    
    cell.updateUI(wish: wishViewModel.wish(indexPath.item),
                  imageType: wishViewModel.imageType(indexPath.item))
    
    return cell
  }
}

// MARK:- UITableViewDelegate
extension MainViewController: UITableViewDelegate{
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
    guard let selectWishVC = storyboard?.instantiateViewController(identifier: SelectWishViewController.identifier) as? SelectWishViewController else { return }
    selectWishVC.modalPresentationStyle = .fullScreen
    selectWishVC.index = indexPath.item
    present(selectWishVC, animated: true, completion: nil)
  }
  
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return WishListTableViewCell.height
  }
}
