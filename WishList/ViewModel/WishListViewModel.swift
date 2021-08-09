//
//  WishViewModel.swift
//  WishList
//
//  Created by 홍승아 on 2021/04/01.
//

import UIKit
import CoreLocation

class WishViewModel {
  private let manager = WishManager.shared
  
  var wishs: [Wish]{
    return manager.wishs
  }

  func addWish(_ wish: Wish){
    manager.addWish(wish)
  }
  
  func loadWish(){
    manager.loadWish()
  }
  
  func addImage(image: UIImage){
    manager.addImage(image)
  }
}

// MARK: - MainVC
extension WishViewModel{
  func setWishList(_ wishList: [Wish]){
    manager.setWishList(wishList)
  }
  
  func addWish(name: String, memo: String, tag: [String], link: String){
    manager.addWish(name, memo, tag, link)
  }
  
  func updateFavorite(index: Int){
    manager.updateFavorite(index)
  }
}

// MARK: - AddWish
extension WishViewModel{
  // AddWishListVC
  func addWish(){
    manager.addWish()
  }
  
  func setWish(index: Int){
    manager.setWish(index)
  }
  
  func removeLastWish(){
    manager.removeLastWish()
  }
  
  func setLastWish(name: String, memo: String, link: String){
    manager.setLastWish(name: name, memo: memo, link: link)
  }
  
  func saveWish(index: Int, wishType: WishType){
    manager.saveWish(index: index, wishType: wishType)
  }
  
  func addTag(tag: String){
    manager.addTag(tag)
  }
  
  // AddWishImageVC
  func removeImage(index: Int){
    manager.removeImage(index)
  }
  
  func wishImages(images: [UIImage])-> [UIImage]{
    return manager.wishImages(images: images)
  }
  
  // AddWishTagVC
  func removeTag(index: Int){
    manager.removeTag(index)
  }
  
  // EditImageVC
  func setImage(images: [UIImage]){
    manager.setImage(images: images)
  }
}

// MARK: - SelectWishListVC
extension WishViewModel{
  func changeUIImage(index: Int){
    manager.changeUIImage(index: index)
  }
  
  func removeWish(_ index: Int){
    manager.removeWish(index)
  }
}

// MARK: - SearchPlaceVC
extension WishViewModel{
  func setPlace(place: Place){
    manager.setPlace(place: place)
  }
}

// MARK: - MapVC
extension WishViewModel{
  func findWish(_ coordinate: CLLocationCoordinate2D)-> Int?{
    manager.findWish(coordinate)
  }
}

// MARK: - SearchVC
extension WishViewModel{
  func filterWishs(text: String, type: SearchType)-> [Wish]{
    return manager.filterWishs(text: text, type: type)
  }
  
  func findWish(filterWish: Wish)-> Int{
    return manager.findWish(filterWish: filterWish)
  }
}

// MARK: - FavorieWishVC
extension WishViewModel{
  func favoriteWishs()-> [Wish]{
    return manager.favoriteWishs()
  }
}
