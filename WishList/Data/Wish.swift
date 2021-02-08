//
//  WishList.swift
//  WishList
//
//  Created by 홍승아 on 2021/01/28.
//

import UIKit
import Kingfisher

struct Wish{
    var timestamp: TimeInterval
    var name: String
    var tag: [String]
    var content: String
    var photo: [UIImage]
    var link: String
    var place: String
}

struct WishDB: Codable{
    var timestamp: TimeInterval
    var name: String
    var tag: [String]
    var content: String
    var img: [String]
    var link: String
    var place: String
}

class WishManager {
    static let shareed = WishManager()
    
    var wishs: [Wish] = []
    
    func addWish(_ wish: Wish){
        wishs.append(wish)
        sortedWish()
        saveWish(wish)
    }
    
    func deleteWish(_ wish: Wish){
        
    }
    
    func updateWish(_ wish: Wish){
        
    }
    
    func sortedWish(){
        wishs = wishs.sorted{ $0.timestamp > $1.timestamp}
    }
    
    func setWish(_ wish: [Wish]){
        wishs = wish
    }
    
    func saveWish(_ wish: Wish){
        DataBaseManager.shared.saveWish(wish)
    }
    
    
    func retrieveWish(){
        DataBaseManager.shared.loadData()
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
    
    func setWish(_ wish: [Wish]){
        manager.setWish(wish)
    }
    
    func loadTasks(){
        manager.retrieveWish()
    }
}
