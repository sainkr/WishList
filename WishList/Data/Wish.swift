//
//  WishList.swift
//  WishList
//
//  Created by 홍승아 on 2021/01/28.
//

import UIKit

struct Wish: Codable {
    var timestamp: Double // = Date().timeIntervalSince1970.rounded()
    var name: String
    var tag: [String]
    var content: String
    var photo: [String]
    var site: [String]
    var place: [String]
}

class WishManager {
    static let shareed = WishManager()
    
    var wishs: [Wish] = []
    
    func addWish(_ wish: Wish){
        wishs.append(wish)
    }
    
    func deleteWish(_ wish: Wish){
        
    }
    
    func updateWish(_ wish: Wish){
        
    }
    
    func saveWish(){
        
    }
    
    func retrieveWish() {
        
    }
    
}

class WishViewModel {
    private let manager = WishManager.shareed
    
    var wishs: [Wish]{
        return manager.wishs
    }
    
    func addWish(_ wish: Wish){
        manager.addWish(wish)
    }
    
    func deleteWish(_ wish: Wish){
        manager.deleteWish(wish)
    }
    
    func updateWish(_ wish: Wish){
        manager.updateWish(wish)
    }
    
    func loadTasks() {
        manager.retrieveWish()
    }
}
