//
//  PhotoViewModel.swift
//  WishList
//
//  Created by 홍승아 on 2021/04/01.
//

import UIKit

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
