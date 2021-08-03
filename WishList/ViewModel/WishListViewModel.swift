//
//  WishViewModel.swift
//  WishList
//
//  Created by 홍승아 on 2021/04/01.
//

import UIKit
import CoreLocation

// FireBase 사용
class WishManager {
  static let shared = WishManager()
  
  var wishs: [Wish] = []
  var filterWishs: [Wish] = []
  var tags: [String] = []
  var imgs: [UIImage] = []
  var place: Place?
  
  func createWish(name: String, memo: String, tag: [String], link: String)-> Wish{
    return Wish(
      timestamp: Int(Date().timeIntervalSince1970.rounded()),
      name: name,
      tag: tag,
      memo: memo,
      img: [],
      imgURL: [],
      link: link,
      place: Place(name: "None", lat: 0, lng: 0),
      favorite: -1)
  }
  
  func createWish(timestamp: Int, name: String, memo: String, link: String, favorite: Int)-> Wish{
    return Wish(
      timestamp: timestamp,
      name: name,
      tag: tags,
      memo: memo,
      img: imgs,
      imgURL: [],
      link: link,
      place: place ?? Place(name: "None", lat: 0, lng: 0),
      favorite: favorite)
  }
  
  func addTag(tag: String){
    tags.append(tag)
  }
  
  func deleteTag(index: Int){
    tags.remove(at: index)
  }
  
  func setTag(tag: [String]){
    tags = tag
  }
  
  func setPlace(place: Place){
    self.place = place
  }
  
  func addImage(img: UIImage){
    imgs.append(img)
  }
  
  func deleteImage(_ index: Int){
    imgs.remove(at: index)
  }
  
  func setImage(img: [UIImage]){
   imgs = img
  }
  
  func setImage(index: Int, img: UIImage){
    imgs[index] = img
  }
  
  func resetData(){
    tags = []
    imgs = []
    place = nil
  }
  // --> 기존
  // wishs
  func addWish(_ wish: Wish){ // Wish 추가
    wishs.append(wish)
    sortedWish()
    
    DataBaseManager.shared.saveWish(wish)
  }
  
  func updateWish(_ index: Int,_ wish: Wish){ // Wish 수정
    let imgCnt = wishs[index].img.count
    wishs[index].update(wish)
    
    DataBaseManager.shared.updateWish(wish, imgCnt)
  }
  
  func updateFavorite(_ wish: Wish){ // 즐겨찾는 Wish 수정
    let index = findWish(wish)
    
    wishs[index].favorite *= -1
    DataBaseManager.shared.updateFavoriteWish(wishs[index])
  }
  
  func loadWish(){ // Wish 조회
    DataBaseManager.shared.loadData()
  }
  
  func deleteWish(_ index: Int){ // Wish 삭제
    let wish = wishs[index]
    wishs.remove(at: index)
    DataBaseManager.shared.deleteWish(wish)
  }
  
  // filter
  func filterWish(_ name: String, _ tag: String, _ type: SearchType){
    if type == .none {
      filterWishs = wishs
    }else if type == .name {
      filterWishs = wishs.filter{
        $0.name.localizedStandardContains(name)
      }
    }else if type == .tag {
      filterWishs = wishs.filter{
        $0.tag.contains(tag)
      }
    }else {
      filterWishs = wishs.filter{
        $0.name.localizedStandardContains(name) || $0.tag.contains(tag)
      }
    }
  }
  
  func updateFilterWish(_ wish: Wish){
    let filterwishsCnt = filterWishs.count
    for i in 0..<filterwishsCnt{
      if wish.timestamp == filterWishs[i].timestamp{
        filterWishs[i] = Wish(timestamp: wish.timestamp, name: wish.name, tag: wish.tag, memo: wish.memo, img: wish.img, imgURL: wish.imgURL, link: wish.link, place: wish.place, favorite: wish.favorite * (-1))
        break
      }
    }
  }
  
  func findWish(_ wish: Wish) -> Int{
    for i in wishs.indices{
      if wishs[i].timestamp == wish.timestamp {
        return i
      }
    }
    return 0
  }
  func favoriteWishs()-> [Wish]{
    return wishs.filter{ $0.favorite == 1}
  }
  
  func sortedWish(){
    wishs.sort{ $0.timestamp > $1.timestamp}
  }
  
  func setWishList(_ wishList: [Wish]){
    self.wishs = wishList
  }
  
  func findWish(_ coordinate: CLLocationCoordinate2D)-> Int{
    let wishsCnt = wishs.count
    for i in 0..<wishsCnt {
      if (wishs[i].place.lat == coordinate.latitude) && (wishs[i].place.lng == coordinate.longitude){
        return i
      }
    }
    return 0
  }
  
  func changeUIImage(){
    let ChangeImageNotification: Notification.Name = Notification.Name("ChangeImageNotification")
    DispatchQueue.global(qos: .userInteractive).async {
      for k in 0..<self.wishs.count{
        var img: [UIImage] = []
        let imgCnt = self.wishs[k].imgURL.count
        // UIImage로 바꾸는 작업
        for i in 0..<imgCnt{
          guard let url = URL(string: self.wishs[k].imgURL[i]) else { return  }
          let data = NSData(contentsOf: url)
          let image = UIImage(data : data! as Data)!
          img.append(image)
        }
        self.wishs[k].img = img
      }
      NotificationCenter.default.post(name: ChangeImageNotification, object: nil)
    }
  }
}

class WishViewModel {
  private let manager = WishManager.shared
  
  var wishs: [Wish]{
    return manager.wishs
  }
  var filterWishs: [Wish]{
    return manager.filterWishs
  }
  var tags: [String]{
    return manager.tags
  }
  var imgs: [UIImage]{
    return manager.imgs
  }
  var place: Place?{
    return manager.place
  }
  var favoriteWishs: [Wish]{
    return manager.favoriteWishs()
  }
  
  func createWish(name: String, memo: String, tag: [String], link: String)-> Wish{
    return manager.createWish(name: name, memo: memo, tag: tag, link: link)
  }
  
  func createWish(timestamp: Int, name: String, memo: String, link: String, favorite: Int)-> Wish{
    return manager.createWish(timestamp: timestamp, name: name, memo: memo, link: link, favorite: favorite)
  }
  
  func addTag(tag: String){
    manager.addTag(tag: tag)
  }
  
  func deleteTag(_ index: Int){
    manager.deleteTag(index: index)
  }
  
  func setTag(tag: [String]){
    manager.setTag(tag: tag)
  }
  
  func setPlace(place: Place){
    manager.setPlace(place: place)
  }
  
  func addImage(_ img: UIImage){
    manager.addImage(img: img)
  }
  
  func deleteImage(_ index: Int){
    manager.deleteImage(index)
  }
  
  func setImage(img: [UIImage]){
    manager.setImage(img: img)
  }
  
  func setImage(index: Int, img: UIImage){
    manager.setImage(index: index, img: img)
  }
  
  func resetData(){
    manager.resetData()
  }

  func addWish(_ wish: Wish){
    manager.addWish(wish)
  }
  
  func deleteWish(_ index: Int){ // Wish 삭제
    manager.deleteWish(index)
  }
  
  func setWishList(_ wishList: [Wish]){
    manager.setWishList(wishList)
  }
  
  func findWish(_ wish: Wish) -> Int{
    return manager.findWish(wish)
  }
  func updateFavorite(_ wish: Wish){
    manager.updateFavorite(wish)
  }
  
  func updateWish(_ index: Int, _ wish: Wish){
    manager.updateWish(index, wish)
  }
  
  func filterWish(_ name: String, _ tag: String, _ type: SearchType){
    manager.filterWish(name, tag, type)
  }
  
  func updateFilterWish(_ wish: Wish){
    return manager.updateFilterWish(wish)
  }
  
  func findWish(_ coordinate: CLLocationCoordinate2D)-> Int{
    manager.findWish(coordinate)
  }
  
  func loadWish(){
    manager.loadWish()
  }
  
  func changeUIImage(){
    manager.changeUIImage()
  }
}
