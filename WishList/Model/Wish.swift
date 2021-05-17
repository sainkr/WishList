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
    var tagString: String
    var content: String
    var photo: [UIImage]
    var img: [String]
    var link: String
    var placeName: String
    var placeLat: Double
    var placeLng : Double
    var favorite: Int
    
    mutating func update(_ wish: Wish) {
        self.name = wish.name
        self.tag = wish.tag
        self.tagString = wish.tagString
        self.content = wish.content
        self.photo = wish.photo
        self.img = wish.img
        self.link = wish.link
        self.placeName = wish.placeName
        self.placeLat = wish.placeLat
        self.placeLng = wish.placeLng
    }
}

struct WishDB: Codable{
    var timestamp: Int
    var name: String
    var tag: [String]
    var tagString: String
    var content: String
    var img: [String]
    var link: String
    var placeName: String
    var placeLat: Double
    var placeLng : Double
    var favorite: Int
}


enum WishType{
    case wishAdd
    case wishUpdate
    case wishPlaceAdd
}

enum WishFavoriteType{
    case mywish
    case favoriteWish
}
