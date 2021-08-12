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
  
  var favoriteWishs: [Wish]{
    return manager.wishs.filter{ $0.favorite }
  }
  
  var favoriteWishsCount: Int{
    return favoriteWishs.count
  }
  
  func favoriteWish(_ index: Int)-> Wish{
    return favoriteWishs[index]
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
  
  func filterWishs(text: String, type: SearchType)-> [Wish]{
    if type == .none {
      return manager.wishs
    }else if type == .name {
      return manager.wishs.filter{
        $0.name.localizedStandardContains(text)
      }
    }else if type == .tag {
      return manager.wishs.filter{
        $0.tag.contains(text)
      }
    }else {
      return manager.wishs.filter{
        $0.name.localizedStandardContains(text) || $0.tag.contains(text)
      }
    }
  }
  
  func filterWishsCount(text: String, type: SearchType)-> Int{
    return filterWishs(text: text, type: type).count
  }
  
  func filterWish(text: String, type: SearchType, index: Int)-> Wish{
    return filterWishs(text: text, type: type)[index]
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
  
  func addWish(_ name: String,_ memo: String,_ tag: [String],_ link: String){
    manager.wishs.append(Wish(timestamp: Int(Date().timeIntervalSince1970.rounded()), name: name, tag: tag, memo: memo, img: [], imgURL: [], link: link, place: Place(name: "-", lat: 0, lng: 0), favorite: false))
    saveWish(lastWishIndex)
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
    manager.wishs.append(Wish(timestamp: Int(Date().timeIntervalSince1970.rounded()), name: "", tag: [], memo: "-", img: [], imgURL: [], link: "", place: Place(name: "-", lat: 0, lng: 0), favorite: false))
  }
  
  func setWish(_ index: Int){
    manager.wishs[manager.wishs.count - 1] = manager.wishs[index]
  }
  
  func removeLastWish(){
    manager.wishs.removeLast()
  }
  
  func setLastWish(name: String, memo: String, link: String){
    manager.wishs[manager.wishs.count - 1].name = name
    manager.wishs[manager.wishs.count - 1].memo = memo
    manager.wishs[manager.wishs.count - 1].link = link
  }
  
  func saveWish(_ index: Int){
    FireBase.saveWish(manager.wishs[index])
  }
  
  func updateWish(_ index: Int){
    let imgCnt = manager.wishs[index].img.count
    manager.wishs[index].update(manager.wishs.removeLast())
    FireBase.updateWish(manager.wishs[index], imgCnt)
  }
  
  func addTag(_ tag: String){
    manager.wishs[manager.wishs.count - 1].tag.append(tag)
  }
  
  // AddWishImageVC
  func removeImage(_ index: Int){
    manager.wishs[manager.wishs.count - 1].img.remove(at: index)
  }
  
  func wishImages(images: [UIImage])-> [UIImage]{
    var wishImages = manager.wishs[manager.wishs.count - 1].img
    wishImages.append(contentsOf: images)
    return wishImages
  }
  
  // AddWishTagVC
  func removeTag(_ index: Int){
    manager.wishs[manager.wishs.count - 1].tag.remove(at: index)
  }
  
  // EditImageVC
  func setImage(images: [UIImage]){
    manager.wishs[manager.wishs.count - 1].img = images
  }
}

// MARK: - SelectWish
extension WishViewModel {
  // SelectWishVC
  func changeUIImage(index: Int){
    let ChangeImageNotification: Notification.Name = Notification.Name("ChangeImageNotification")
    DispatchQueue.global(qos: .userInteractive).async {
      var img: [UIImage] = []
      for imgURL in self.manager.wishs[index].imgURL{
        guard let url = URL(string: imgURL) else { return  }
        let data = NSData(contentsOf: url)
        let image = UIImage(data : data! as Data)!
        img.append(image)
      }
      self.manager.wishs[index].img = img
      NotificationCenter.default.post(name: ChangeImageNotification, object: nil)
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
    manager.wishs[manager.wishs.count - 1].place = place
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

// MARK: - SearchWishVC
extension WishViewModel {
  func findWish(filterWish: Wish)-> Int{
    for index in manager.wishs.indices {
      if manager.wishs[index].timestamp == filterWish.timestamp{
        return index
      }
    }
    return 0
  }
}
