//
//  FavoriteWishViewModel.swift
//  WishList
//
//  Created by 홍승아 on 2021/09/05.
//

import Foundation

class FavoriteWishViewModel {
  private var manager = WishData.shared
  
  var favoriteWishs: [Wish]{
    return manager.wishs.filter{ $0.favorite }
  }
  
  var favoriteWishsCount: Int{
    return favoriteWishs.count
  }
  
  func favoriteWish(_ index: Int)-> Wish{
    return favoriteWishs[index]
  }
}
