//
//  LoadUIImage.swift
//  WishList
//
//  Created by 홍승아 on 2021/09/14.
//

import UIKit

class LoadUIImage{
  
  private var itemProviders: [NSItemProvider] = []
  
  init(_ itemProvdiers: [NSItemProvider]){
    self.itemProviders = itemProvdiers
  }
  
  func image(completion: @escaping (([UIImage]) -> ())){
    var iterator: IndexingIterator<[NSItemProvider]> = itemProviders.makeIterator()
    var images: [UIImage] = []
    while true {
      guard let itemProvider = iterator.next(), itemProvider.canLoadObject(ofClass: UIImage.self) else { break }
      itemProvider.loadObject(ofClass: UIImage.self) { image, error in
        if let error = error {
          print("loadImageError : \(error)")
          return
        }
        guard let image = image as? UIImage else { return }
        images.append(image)
        if images.count == self.itemProviders.count{
          completion(images)
        }
      }
    }
  }
}
