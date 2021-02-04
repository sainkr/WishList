//
//  Photo.swift
//  WishList
//
//  Created by 홍승아 on 2021/02/02.
//

import UIKit

struct Photo {
    var image: UIImage
}

class PhotoManager {
    static let shared = PhotoManager()
    
    var photos: [Photo] = []
    
    func addPhoto(_ photo: Photo){
        photos.append(photo)
    }
    
    func deletePhoto(_ photo: Photo){
        photos = photos.filter { $0.image != photo.image}
    }
    
    func resetPhoto(){
        photos = []
    }
    
}

class PhotoViewModel {
    private let manager = PhotoManager.shared
    
    var photos: [Photo]{
        return manager.photos
    }
    
    func addPhoto(_ photo: Photo){
        manager.addPhoto(photo)
    }
    
    func deletePhoto(_ photo: Photo){
        manager.deletePhoto(photo)
    }

    func resetPhoto(){
        manager.resetPhoto()
    }
}

