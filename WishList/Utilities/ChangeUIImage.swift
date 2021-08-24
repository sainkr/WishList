//
//  ChangeUIImage.swift
//  WishList
//
//  Created by 홍승아 on 2021/08/23.
//

import UIKit

class ChangeUIImage{
  static func changeUIImage(imageURL: [String], completion: @escaping (_ img: [UIImage])-> Void){
    DispatchQueue.global(qos: .userInteractive).async {
      var img: [UIImage] = []
      for imgURL in imageURL{
        guard let url = URL(string: imgURL) else { return  }
        let data = NSData(contentsOf: url)
        let image = UIImage(data : data! as Data)!
        img.append(image)
      }
      completion(img)
    }
  }
}
