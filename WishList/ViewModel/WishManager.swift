//
//  WishManager.swift
//  WishList
//
//  Created by 홍승아 on 2021/08/07.
//

import UIKit
import CoreLocation

// FireBase 사용
class WishManager {
  static let shared = WishManager()
  
  var wishs: [Wish] = []
  
  func createWish(name: String, memo: String, tag: [String], link: String)-> Wish{
    return Wish(
      timestamp: Int(Date().timeIntervalSince1970.rounded()),
      name: name,
      tag: tag,
      memo: memo,
      img: [],
      imgURL: [],
      link: link,
      place: Place(name: "-", lat: 0, lng: 0),
      favorite: false)
  }
  
  func addWish(_ wish: Wish){ // Wish 추가
    wishs.append(wish)
    sortedWish()
    saveWish(wish)
  }
    
  func loadWish(){ // Wish 조회
    DataBaseManager.shared.loadData()
  }
  
  func sortedWish(){
    wishs.sort{ $0.timestamp > $1.timestamp}
  }
  
  func addImage(_ image: UIImage){
    wishs[wishs.count - 1].img.append(image)
  }
}

// MARK: - MainVC
extension WishManager{
  func setWishList(_ wishList: [Wish]){
    wishs = wishList
  }
  
  func addWish(_ name: String,_ memo: String,_ tag: [String],_ link: String){
    wishs.append(Wish(timestamp: Int(Date().timeIntervalSince1970.rounded()), name: name, tag: tag, memo: memo, img: [], imgURL: [], link: link, place: Place(name: "-", lat: 0, lng: 0), favorite: false))
    saveWish(wishs[wishs.count - 1])
  }
  
  func updateFavorite(_ index: Int){
    wishs[index].favorite = !wishs[index].favorite
    DataBaseManager.shared.updateFavoriteWish(wishs[index])
  }
}

// MARK: - AddWish
extension WishManager{
  // AddWishListVC
  func addWish(){
    wishs.append(Wish(timestamp: Int(Date().timeIntervalSince1970.rounded()), name: "", tag: [], memo: "-", img: [], imgURL: [], link: "", place: Place(name: "-", lat: 0, lng: 0), favorite: false))
  }
  
  func setWish(_ index: Int){
    wishs[wishs.count - 1] = wishs[index]
  }
  
  func removeLastWish(){
    wishs.removeLast()
  }
  
  func setLastWish(name: String, memo: String, link: String){
    wishs[wishs.count - 1].name = name
    wishs[wishs.count - 1].memo = memo
    wishs[wishs.count - 1].link = link
  }
  
  func saveWish(index: Int, wishType: WishType){
    if wishType == .wishAdd || wishType == .wishPlaceAdd {
      saveWish(wishs[wishs.count - 1])
    }else if wishType == .wishUpdate {
      updateWish(index)
    }
  }
  
  func saveWish(_ wish: Wish){
    DataBaseManager.shared.saveWish(wish)
  }
  
  func updateWish(_ index: Int){ // Wish 수정
    let imgCnt = wishs[index].img.count
    wishs[index].update(wishs.removeLast())
    DataBaseManager.shared.updateWish(wishs[index], imgCnt)
  }
  
  func addTag(_ tag: String){
    wishs[wishs.count - 1].tag.append(tag)
  }
  
  // AddWishImageVC
  func removeImage(_ index: Int){
    wishs[wishs.count - 1].img.remove(at: index)
  }
  
  func wishImages(images: [UIImage])-> [UIImage]{
    var wishImages = wishs[wishs.count - 1].img
    wishImages.append(contentsOf: images)
    return wishImages
  }
  
  // AddWishTagVC
  func removeTag(_ index: Int){
    wishs[wishs.count - 1].tag.remove(at: index)
  }
  
  // EditImageVC
  func setImage(images: [UIImage]){
    wishs[wishs.count - 1].img = images
  }
}

// MARK: - SelectWish
extension WishManager{
  // SelectWishVC
  func changeUIImage(index: Int){
    let ChangeImageNotification: Notification.Name = Notification.Name("ChangeImageNotification")
    DispatchQueue.global(qos: .userInteractive).async {
      var img: [UIImage] = []
      for imgURL in self.wishs[index].imgURL{
        guard let url = URL(string: imgURL) else { return  }
        let data = NSData(contentsOf: url)
        let image = UIImage(data : data! as Data)!
        img.append(image)
      }
      self.wishs[index].img = img
      NotificationCenter.default.post(name: ChangeImageNotification, object: nil)
    }
  }
  
  func removeWish(_ index: Int){
    let wish = wishs[index]
    wishs.remove(at: index)
    DataBaseManager.shared.deleteWish(wish)
  }
  
  // SelectWishImageVC
  // ShowImageVC
}

// MARK: - SearchPlaceVC
extension WishManager{
  func setPlace(place: Place){
    wishs[wishs.count - 1].place = place
  }
}

// MARK: - MapVC
extension WishManager{
  func findWish(_ coordinate: CLLocationCoordinate2D)-> Int?{
    for i in wishs.indices {
      guard let place = wishs[i].place else { continue }
      if place.lat == coordinate.latitude && place.lng == coordinate.longitude{
        return i
      }
    }
    return nil
  }
}

// MARK: - SearchWishVC
extension WishManager{
  func filterWishs(text: String, type: SearchType)-> [Wish]{
    if type == .none {
      return wishs
    }else if type == .name {
      return wishs.filter{
        $0.name.localizedStandardContains(text)
      }
    }else if type == .tag {
      return wishs.filter{
        $0.tag.contains(text)
      }
    }else {
      return wishs.filter{
        $0.name.localizedStandardContains(text) || $0.tag.contains(text)
      }
    }
  }
  
  func findWish(filterWish: Wish)-> Int{
    for index in wishs.indices {
      if wishs[index].timestamp == filterWish.timestamp{
        return index
      }
    }
    return 0
  }
}

// MARK: - FavorieWishVC
extension WishManager{
  func favoriteWishs()-> [Wish]{
    return wishs.filter{ $0.favorite }
  }
}
