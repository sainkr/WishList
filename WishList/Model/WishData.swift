//
//  WishData.swift
//  WishList
//
//  Created by 홍승아 on 2021/08/11.
//

import Foundation

class WishData {
  static let shared = WishData()
  var wishs: [Wish] = []
  private init() { }
}
