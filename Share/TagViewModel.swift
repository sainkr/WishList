//
//  TagViewModel.swift
//  Share
//
//  Created by 홍승아 on 2021/09/08.
//

import Foundation

class TagViewModel {
  var tags: [String] = []
  
  var tagsCount: Int {
    return tags.count
  }
  
  func tag(_ index: Int)-> String {
    return tags[index]
  }
  
  func addTag(_ tag: String) {
    tags.append(tag)
  }
  
  func removeTag(_ index: Int) {
    tags.remove(at: index)
  }
  
  func isNotExistTag()-> Bool {
    return tags.count == 0 ? true : false
  }
}
