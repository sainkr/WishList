//
//  WishList.swift
//  WishList
//
//  Created by 홍승아 on 2021/01/28.
//

import UIKit
import CoreLocation

struct Wish: Equatable{
  var timestamp: Int
  var name: String
  var tag: [String]
  var memo: String
  var img: [UIImage]
  var imgURL: [String]
  var link: String
  var place: Place?
  var favorite: Bool
  
  mutating func update(_ wish: Wish) {
    self.name = wish.name
    self.tag = wish.tag
    self.memo = wish.memo
    self.img = wish.img
    self.imgURL = wish.imgURL
    self.link = wish.link
    self.place = wish.place
  }
}

struct WishDB: Codable{
  var timestamp: Int
  var name: String
  var tag: [String]
  var memo: String
  var imgURL: [String]
  var link: String
  var placeName: String
  var placeLat: Double
  var placeLng: Double
  var favorite: Bool
}

enum WishType{
  case wishAdd
  case wishUpdate
  case wishPlaceAdd
  case wishDelete
}

struct Place: Codable, Equatable{
  var name: String
  var lat: Double
  var lng: Double
}

enum SearchType{
  case name
  case tag
  case all
  case none
}

enum ImageType{
  case uiImage
  case url
  case none
}

enum ImageSizeType{
  case small
  case large
}
