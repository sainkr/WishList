//
//  Photo.swift
//  WishList
//
//  Created by 홍승아 on 2021/02/02.
//

import UIKit

class PhotoManager {
    static let shared = PhotoManager()
    
    var photos: [UIImage] = []
    
    func addPhoto(_ photo: UIImage){
        photos.append(photo)
    }
    
    func deletePhoto(_ photo: UIImage){
        photos = photos.filter { $0 != photo}
    }
    
    func resetPhoto(){
        photos = []
    }
    
    func setPhoto(_ index: Int, _ photo: UIImage){
        photos[index] = photo
    }
    
    func setPhoto(_ photo: [UIImage]){
        photos = photo
    }
    
}


