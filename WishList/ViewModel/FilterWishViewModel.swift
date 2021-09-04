//
//  FilterWishViewModel.swift
//  WishList
//
//  Created by 홍승아 on 2021/09/05.
//

import Foundation

class FilterWishViewModel {
  private var manager = WishData.shared
  
  func filterWishs(text: String, type: SearchType)-> [Wish]{
    if text == ""{
      return manager.wishs
    }
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
}
