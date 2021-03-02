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
    var favorite: Int
    
    mutating func update(_ wish: Wish) {
        self.name = wish.name
        self.tag = wish.tag
        self.tagString = wish.tagString
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
    }
    
    mutating func updateFavorite(){
        self.favorite *= -1
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
    var favorite: Int
}

class WishManager {
    static let shareed = WishManager()
    
    var wishs: [Wish] = []
    var filterWishs: [Wish] = []
    
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
        wishs[index].update(wish)
        
        DataBaseManager.shared.updateWish(wish)
    }
    
    func updatePhotoWish(_ index: Int, _ photo : [UIImage]){
        wishs[index].updatePhoto(photo)
    }
    
    func updateFavorite(_ wish: Wish){
        var index = 0
        let wishCnt = wishs.count
        
        for i in 0..<wishCnt{
            if wishs[i].timestamp == wish.timestamp {
                index = i
                break
            }
        }
        
        wishs[index].updateFavorite()
 
        DataBaseManager.shared.updateWish(wishs[index])
    }
    
    func favoriteWishs()-> [Wish]{
        return wishs.filter{ $0.favorite == 1}
    }
    
    func sortedWish(){
        wishs = wishs.sorted{ $0.timestamp > $1.timestamp}
    }
    
    func filterWish(_ name: String, _ tag: String, _ type: Int)-> [Wish]{
        if type == 0 { // 아무것도 입력 X
            filterWishs = wishs
            
        } else if type == 1 { // 이름만
            filterWishs = wishs.filter{
                $0.name.localizedStandardContains(name)
            }
            
        } else if type == 2 { // 태그만
            filterWishs = wishs.filter{
                $0.tagString.localizedStandardContains(tag)
            }
        }
        else { // 이름 태그 둘다 
            filterWishs = wishs.filter{
                $0.name.localizedStandardContains(name) ||  $0.tagString.localizedStandardContains(tag)
            }
        }
        
        return filterWishs
        
    }
    
    func updateFilterWish(_ wish: Wish){
        let filterwishsCnt = filterWishs.count
        for i in 0..<filterwishsCnt{
            if wish.timestamp == filterWishs[i].timestamp{
                filterWishs[i] = Wish(timestamp: wish.timestamp, name: wish.name, tag: wish.tag, tagString: wish.tagString, content: wish.content, photo: wish.photo, img: wish.img, link: wish.link, placeName: wish.placeName, placeLat: wish.placeLat, placeLng: wish.placeLng, favorite: wish.favorite * (-1))
                break
            }
        }
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
    
    func loadTasks(){
        manager.retrieveWish()
    }
}
