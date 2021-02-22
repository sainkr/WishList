//
//  WishList.swift
//  WishList
//
//  Created by 홍승아 on 2021/01/28.
//

import UIKit
// import Kingfisher

struct Wish: Equatable{
    var timestamp: Int
    var name: String
    var tag: [String]
    var tagString: String
    var content: String
    var photo: [UIImage]
    var img: [String]
    var link: String
    var placeName: String
    var placeLat: Double
    var placeLng : Double
    
    mutating func update(_ wish: Wish) {
        self.name = wish.name
        self.tag = wish.tag
        self.content = wish.content
        self.photo = wish.photo
        self.img = wish.img
        self.link = wish.link
        self.placeName = wish.placeName
        self.placeLat = wish.placeLat
        self.placeLng = wish.placeLng
    }
    
    mutating func updatePhoto(_ photo: [UIImage]){
        self.photo = photo
        self.img = []
    }
}

struct WishDB: Codable{
    var timestamp: Int
    var name: String
    var tag: [String]
    var tagString: String
    var content: String
    var img: [String]
    var link: String
    var placeName: String
    var placeLat: Double
    var placeLng : Double
}

class WishManager {
    static let shareed = WishManager()
    
    var wishs: [Wish] = []
    
    func addWish(_ wish: Wish){
        wishs.append(wish)
        sortedWish()
        DataBaseManager.shared.saveWish(wish)
    }
    
    func deleteWish(_ wish: Wish){
        DataBaseManager.shared.deleteWish(wish)
        
        wishs = wishs.filter { $0 != wish}
    }
    
    func updateWish(_ index: Int,_ wish: Wish){
        let imgCnt = wishs[index].photo.count
        wishs[index].update(wish)
        
        DataBaseManager.shared.updateWish(wish, imgCnt)
    }
    
    func photoupdateWish(_ index: Int, _ photo : [UIImage]){
        wishs[index].updatePhoto(photo)
    }
    
    func sortedWish(){
        wishs = wishs.sorted{ $0.timestamp > $1.timestamp}
    }
    
    func setWish(_ wish: [Wish]){
        wishs = wish
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
    
    func photoupdateWish(_ index: Int, _ photo: [UIImage]){
        manager.photoupdateWish(index, photo)
    }
    
    func updateWish(_ index: Int, _ wish: Wish){
        manager.updateWish(index, wish)
    }
    
    func setWish(_ wish: [Wish]){
        manager.setWish(wish)
    }
    
    func loadTasks(){
        manager.retrieveWish()
    }
}
