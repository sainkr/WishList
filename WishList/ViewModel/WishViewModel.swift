//
//  WishViewModel.swift
//  WishList
//
//  Created by 홍승아 on 2021/05/17.
//

import Foundation
import UIKit

/*
func addTag(_ tag: String){
  wish.tag.append(tag)
}

func deleteTag(_ index: Int){
  wish.tag.remove(at: index)
}

func addPhoto(_ img: UIImage){
  wish.photo.append(img)
}

func deletePhoto(_ index: Int){
  if wish.photo.count > 0 {
    print("---> photo : \(wish.photo)")
    print("---> index : \(index)")
    wish.photo.remove(at: index - 1)
  }
}

func setPhoto(_ index: Int, _ img: UIImage){
  wish.photo[index] = img
}

func addPlace(_ place: Place){
  wish.placeName = place.name
  wish.placeLat = place.lat
  wish.placeLng = place.lng
}

func setPlace(_ name: String){
  wish.placeName = name
}
*/
/*class WishViewModel{
  private let manager = WishManager.shared
  
  var wish: Wish {
    return manager.wish
  }
  
  func resetWish(){
    manager.resetWish()
  }
  
  func setWish(_ w: Wish){
    manager.setWish(w)
  }
  
  func createWish(timestamp: Int, name: String, memo: String, tags: [String], url: String, photo: [UIImage], place: Place, favorite: Int) -> Wish{
    return manager.createWish(timestamp: timestamp, name: name, memo: memo, tags: tags, url: url, photo: photo, place: place, favorite: favorite)
  }
  
  func addTag(_ tag: String){
    manager.addTag(tag)
  }
  
  func deleteTag(_ index: Int){
    manager.deleteTag(index)
  }
  
  func addPhoto(_ img: UIImage){
    manager.addPhoto(img)
  }
  
  func deletePhoto(_ index: Int){
    manager.deletePhoto(index)
  }
  
  func setPhoto(_ index: Int, _ img: UIImage){
    manager.setPhoto(index, img)
  }
  
  func addPlace(_ place: Place){
    manager.addPlace(place)
  }
  
  func setPlace(_ name: String){
    manager.setPlace(name)
  }
}
*/
