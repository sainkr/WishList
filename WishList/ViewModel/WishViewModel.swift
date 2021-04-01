//
//  WishViewModel.swift
//  WishList
//
//  Created by 홍승아 on 2021/04/01.
//

import UIKit
import CoreLocation

class WishViewModel {
    private let manager = WishManager.shareed
    
    var wishs: [Wish]{
        return manager.wishs
    }
    
    var filterWishs: [Wish]{
        return manager.filterWishs
    }
    
    func addWish(_ wish: Wish){
        manager.addWish(wish)
    }
    
    func deleteWish(_ wish: Wish){
        manager.deleteWish(wish)
    }
    
    func updateFavorite(_ wish: Wish){
        manager.updateFavorite(wish)
    }
    
    func updatePhoto(_ index: Int, _ photo: [UIImage]){
        manager.updatePhotoWish(index, photo)
    }
    
    func updateWish(_ index: Int, _ wish: Wish){
        manager.updateWish(index, wish)
    }
    
    func favoriteWishs()-> [Wish]{
        return manager.favoriteWishs()
    }
    
    func filterWish(_ name: String, _ tag: String, _ type: Int)-> [Wish]{
        return manager.filterWish(name, tag, type)
    }
    
    func updateFilterWish(_ wish: Wish){
        return manager.updateFilterWish(wish)
    }
    
    func setWish(_ wish: [Wish]){
        manager.setWish(wish)
    }

    func findWish(_ coordinate: CLLocationCoordinate2D)-> Int{
        manager.findWish(coordinate)
    }
    
    func loadTasks(){
        manager.retrieveWish()
    }
}
