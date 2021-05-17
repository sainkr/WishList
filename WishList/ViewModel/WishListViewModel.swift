//
//  WishViewModel.swift
//  WishList
//
//  Created by 홍승아 on 2021/04/01.
//

import UIKit
import CoreLocation

// FireBase 사용
class WishListManager {
    static let shared = WishListManager()
    
    var wishList: [Wish] = []
    var filterWishs: [Wish] = []
    
    // wishs
    func addWish(_ wish: Wish){ // Wish 추가
        wishList.append(wish)
        sortedWish()

        DataBaseManager.shared.saveWish(wish)
    }
    
    func updateWish(_ index: Int,_ wish: Wish){ // Wish 수정
        let imgCnt = wishList[index].photo.count
        wishList[index].update(wish)

        DataBaseManager.shared.updateWish(wish, imgCnt)
    }
    
    func updateFavorite(_ wish: Wish){ // 즐겨찾는 Wish 수정
        let index = findWish(wish)
        
        wishList[index].favorite *= -1
        DataBaseManager.shared.updateFavoriteWish(wishList[index])
    }
    
    func loadWish(){ // Wish 조회
        DataBaseManager.shared.loadData()
    }
    
    func deleteWish(_ wish: Wish){ // Wish 삭제
        wishList = wishList.filter { $0 != wish}
        
        DataBaseManager.shared.deleteWish(wish)
    }
    
    // filter
    func filterWish(_ name: String, _ tag: String, _ type: Int){
        if type == 0 { // 아무것도 입력 X
            filterWishs = wishList
            
        } else if type == 1 { // 이름만
            filterWishs = wishList.filter{
                $0.name.localizedStandardContains(name)
            }
            
        } else if type == 2 { // 태그만
            filterWishs = wishList.filter{
                $0.tagString.localizedStandardContains(tag)
            }
        }
        else { // 이름 태그 둘다
            filterWishs = wishList.filter{
                $0.name.localizedStandardContains(name) ||  $0.tagString.localizedStandardContains(tag)
            }
        }
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
    
    func findWish(_ wish: Wish) -> Int{
        for i in 0..<wishList.count{
            if wishList[i].timestamp == wish.timestamp {
                return i
            }
        }
        return 0
    }
    func favoriteWishs()-> [Wish]{
        return wishList.filter{ $0.favorite == 1}
    }
    
    func sortedWish(){
        wishList = wishList.sorted{ $0.timestamp > $1.timestamp}
    }
    
    func setWishList(_ wishList: [Wish]){
        self.wishList = wishList
    }
    
    func findWish(_ coordinate: CLLocationCoordinate2D)-> Int{
        let wishsCnt = wishList.count
        for i in 0..<wishsCnt {
            if (wishList[i].placeLat == coordinate.latitude) && (wishList[i].placeLng == coordinate.longitude){
                return i
            }
        }
        return 0
    }

    func changeUIImage(){
        let ChangeImageNotification: Notification.Name = Notification.Name("ChangeImageNotification")
        DispatchQueue.global(qos: .userInteractive).async {
            for k in 0..<self.wishList.count{
                var img: [UIImage] = []
                let imgCnt = self.wishList[k].img.count
                // UIImage로 바꾸는 작업
                for i in 0..<imgCnt{
                    guard let url = URL(string: self.wishList[k].img[i]) else { return  }
                    let data = NSData(contentsOf: url)
                    let image = UIImage(data : data! as Data)!
                    img.append(image)
                }
                self.wishList[k].photo = img
            }
            NotificationCenter.default.post(name: ChangeImageNotification, object: nil)
        }
    }
}

class WishListViewModel {
    private let manager = WishListManager.shared
    
    var wishList: [Wish]{
        return manager.wishList
    }
    
    var favoriteWishs: [Wish]{
        return manager.favoriteWishs()
    }
    
    var filterWishs: [Wish]{
        return manager.filterWishs
    }
    
    func addWish(_ wish: Wish){ 
        manager.addWish(wish)
    }

    func deleteWish(_ wish: Wish){ // Wish 삭제
        manager.deleteWish(wish)
    }
    
    func setWishList(_ wishList: [Wish]){
        manager.setWishList(wishList)
    }
    
    func findWish(_ wish: Wish) -> Int{
        return manager.findWish(wish)
    }
    func updateFavorite(_ wish: Wish){
        manager.updateFavorite(wish)
    }
    
    func updateWish(_ index: Int, _ wish: Wish){
        manager.updateWish(index, wish)
    }
    
    func filterWish(_ name: String, _ tag: String, _ type: Int){
        manager.filterWish(name, tag, type)
    }
    
    func updateFilterWish(_ wish: Wish){
        return manager.updateFilterWish(wish)
    }
    
    func findWish(_ coordinate: CLLocationCoordinate2D)-> Int{
        manager.findWish(coordinate)
    }
    
    func loadWish(){
        manager.loadWish()
    }
    
    func changeUIImage(){
        manager.changeUIImage()
    }
}
