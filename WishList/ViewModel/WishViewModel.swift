//
//  WishViewModel.swift
//  WishList
//
//  Created by 홍승아 on 2021/04/01.
//

import UIKit
import CoreLocation

class WishViewModel {
  private var manager = WishData.shared
  private let FireBase = DataBaseManager.shared
  
  var wishsCount: Int{
    return manager.wishs.count
  }
  
  var lastWishIndex: Int{
    return wishsCount - 1
  }
  
  var places: [Place?]{
    return manager.wishs.map{ $0.place }
  }

  func favorite(_ index: Int)-> Bool{
    return manager.wishs[index].favorite
  }
  
  func wish(_ index: Int)-> Wish{
    return manager.wishs[index]
  }
  
  func name(_ index: Int)-> String{
    return manager.wishs[index].name
  }
  
  func memo(_ index: Int)-> String{
    return manager.wishs[index].memo
  }
  
  func link(_ index: Int)-> String{
    return manager.wishs[index].link
  }
  
  func image(_ index: Int)-> [UIImage]{
    return manager.wishs[index].img
  }
  
  func image(index: Int, imageIndex: Int)-> UIImage{
    return manager.wishs[index].img[imageIndex]
  }
  
  func imageCount(_ index: Int)-> Int{
    return manager.wishs[index].img.count
  }
  
  func imageURL(_ index: Int)-> [String]{
    return manager.wishs[index].imgURL
  }
  
  func imageURL(index: Int, imageIndex: Int)-> String{
    return manager.wishs[index].imgURL[imageIndex]
  }
  
  func imageURLCount(_ index: Int)-> Int{
    return manager.wishs[index].imgURL.count
  }
  
  func tag(_ index: Int)-> [String]{
    return manager.wishs[index].tag
  }
  
  func tag(index: Int, tagIndex: Int)-> String{
    return manager.wishs[index].tag[tagIndex]
  }
  
  func tagCount(_ index: Int)-> Int{
    return manager.wishs[index].tag.count
  }
  
  func place(_ index: Int)-> Place?{
    return manager.wishs[index].place
  }
    
  func loadWish() {
    FireBase.loadData()
  }
  
  func imageType(_ index: Int)-> ImageType{
    if !manager.wishs[index].img.isEmpty{
      return .uiImage
    }else if !manager.wishs[index].imgURL.isEmpty{
      return .url
    }else{
      return .none
    }
  }
}

// MARK: - MainVC
extension WishViewModel {
  func setWishList(_ wishList: [Wish]){
    manager.wishs = wishList
  }
  
  func updateFavorite(_ index: Int){
    manager.wishs[index].favorite = !manager.wishs[index].favorite
    FireBase.updateFavoriteWish(manager.wishs[index])
  }
}

// MARK: - AddWish
extension WishViewModel {
  // AddWishListVC
  func addWish(){
    manager.wishs.append(Wish(timestamp: Int(Date().timeIntervalSince1970.rounded()), name: "", tag: [], memo: "-", img: [], imgURL: [], link: "", place: nil, favorite: false))
  }
  
  func setWish(_ index: Int){
    manager.wishs[lastWishIndex] = manager.wishs[index]
  }
  
  func removeLastWish(){
    manager.wishs.removeLast()
  }
  
  func setLastWish(name: String, memo: String, link: String){
    manager.wishs[lastWishIndex].name = name
    manager.wishs[lastWishIndex].memo = memo
    manager.wishs[lastWishIndex].link = link
  }
  
  func saveWish(_ index: Int){
    FireBase.saveWish(manager.wishs[index])
    sortWish()
  }
  
  func updateWish(_ index: Int){
    let imgCnt = manager.wishs[index].img.count
    manager.wishs[index].update(manager.wishs.removeLast())
    FireBase.updateWish(manager.wishs[index], imgCnt)
  }
  
  func addTag(_ tag: String){
    manager.wishs[lastWishIndex].tag.append(tag)
  }
  
  func sortWish(){
    manager.wishs.sort(by: {$0.timestamp > $1.timestamp})
  }
  
  // AddWishImageVC
  func removeImage(_ index: Int){
    manager.wishs[lastWishIndex].img.remove(at: index)
  }
  
  func wishImages(images: [UIImage])-> [UIImage]{
    var wishImages = manager.wishs[lastWishIndex].img
    wishImages.append(contentsOf: images)
    return wishImages
  }
  
  // AddWishTagVC
  func removeTag(_ index: Int){
    manager.wishs[lastWishIndex].tag.remove(at: index)
  }
  
  // EditImageVC
  func setImage(images: [UIImage]){
    manager.wishs[lastWishIndex].img = images
  }
}

// MARK: - SelectWishVC
extension WishViewModel {
  func changeUIImage(index: Int){
    ChangeUIImage.changeUIImage(imageURL: manager.wishs[index].imgURL){ [weak self] image in
      self?.manager.wishs[index].img = image
      NotificationCenter.default.post(name: NotificationName.ChangeImageNotification, object: nil)
    }
  }
  
  func removeWish(_ index: Int){
    let wish = manager.wishs[index]
    manager.wishs.remove(at: index)
    FireBase.deleteWish(wish)
  }
}

// MARK: - SearchPlaceVC
extension WishViewModel {
  func setPlace(place: Place){
    manager.wishs[lastWishIndex].place = place
  }
}

// MARK: - MapVC
extension WishViewModel {
  func findWish(_ coordinate: CLLocationCoordinate2D)-> Int?{
    for i in manager.wishs.indices {
      guard let place = manager.wishs[i].place else { continue }
      if place.lat == coordinate.latitude && place.lng == coordinate.longitude{
        return i
      }
    }
    return nil
  }
}

// MARK: - SearchWishVC, FavoriteWishVC
extension WishViewModel {
  func findWish(_ wish: Wish)-> Int{
    for index in manager.wishs.indices {
      if manager.wishs[index].timestamp == wish.timestamp{
        return index
      }
    }
    return 0
  }
}
