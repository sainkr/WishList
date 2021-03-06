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

class PhotoViewModel {
    private let manager = PhotoManager.shared
    
    var photos: [UIImage]{
        return manager.photos
    }
    
    func addPhoto(_ photo: UIImage){
        manager.addPhoto(photo)
    }
    
    func deletePhoto(_ photo: UIImage){
        manager.deletePhoto(photo)
    }

    func resetPhoto(){
        manager.resetPhoto()
    }
    
    func setPhoto(_ index: Int, _ photo: UIImage){
        manager.setPhoto(index, photo)
    }
    
    func setPhoto(_ photos: [UIImage]){
        manager.setPhoto(photos)
    }
}

