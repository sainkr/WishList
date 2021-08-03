//
//  DataBase.swift
//  WishList
//
//  Created by 홍승아 on 2021/02/04.
//

import UIKit
import Firebase
import FirebaseStorage

let DidReceiveWishsNotification: Notification.Name = Notification.Name("DidReceiveWishsNotification")

class DataBaseManager {
  static let shared = DataBaseManager()
  
  let db =  Database.database().reference().child("myWhisList")
  let storage = Storage.storage()
  
  func saveWish(_ wish: Wish){
    var imgURL: [String] = []
    let imgCnt = wish.img.count
    
    if imgCnt > 0 {
      for i in 0..<imgCnt{
        let image: UIImage = wish.img[i]
        let data = image.jpegData(compressionQuality: 0.1)!
        let metaData = StorageMetadata()
        metaData.contentType = "image/png"
        let imageName = "\(wish.timestamp)\(i)"
        storage.reference().child(imageName).putData(data, metadata: metaData) { (data, err) in
          if let error = err {
            print("--> error1:\(error.localizedDescription)")
          }
          self.storage.reference().child(imageName).downloadURL { [self] (url, err) in
            print("url fetch")
            if let error = err {
              print("--> error2:\(error.localizedDescription)")
            }
            else {
              print("---> \(i)")
              imgURL.append(url!.absoluteString)
              if imgURL.count == wish.img.count  {
                print("--->imgurl..length : \(imgURL.count)")
                print("---> timestamp : \(String(wish.timestamp))")
                db.child(String(wish.timestamp)).setValue([ "timestamp" : wish.timestamp, "name": wish.name ,  "tag" : wish.tag, "imgURL" : imgURL, "memo" : wish.memo, "link" : wish.link, "placeName" : wish.place.name, "placeLat": wish.place.lat, "placeLng": wish.place.lng ,"favorite": wish.favorite])
              }
            }
          }
        }
      }
    }
    else{
      db.child(String(wish.timestamp)).setValue([ "timestamp" : wish.timestamp, "name": wish.name , "tag" : wish.tag, "imgURL" : ["-"], "memo" : wish.memo, "link" : wish.link, "placeName" : wish.place.name, "placeLat": wish.place.lat, "placeLng": wish.place.lng, "favorite": wish.favorite])
    }
  }
  
  func updateWish(_ wish: Wish, _ imgCnt: Int){
    for i in 0..<imgCnt{
      let imageName = "\(wish.timestamp)\(i)"
      storage.reference().child(imageName).delete(completion: nil)
    }
    var imgURL: [String] = []
    let imgCnt = wish.img.count
    for i in 0..<imgCnt{
      let image: UIImage = wish.img[i]
      let data = image.jpegData(compressionQuality: 0.1)!
      let metaData = StorageMetadata()
      metaData.contentType = "image/png"
      let imageName = "\(wish.timestamp)\(i)"
      storage.reference().child(imageName).putData(data, metadata: metaData) { (data, err) in
        if let error = err {
          print("--> error1:\(error.localizedDescription)")
        }
        self.storage.reference().child(imageName).downloadURL { [self] (url, err) in
          print("url fetch")
          if let error = err {
            print("--> error2:\(error.localizedDescription)")
          }
          else {
            print("---> \(i)")
            imgURL.append(url!.absoluteString)
            if imgURL.count == wish.img.count  {
              print("--->imgurl..length : \(imgURL.count)")
              db.child(String(wish.timestamp)).updateChildValues([ "timestamp" : wish.timestamp, "name": wish.name ,  "tag" : wish.tag, "imgURL" : imgURL, "memo" : wish.memo, "link" : wish.link, "placeName" : wish.place.name, "placeLat": wish.place.lat, "placeLng": wish.place.lng, "favorite": wish.favorite])
            }
          }
        }
      }
    }
  }
  
  func updateFavoriteWish(_ wish: Wish){
    if wish.img.count > 0 {
      db.child(String(wish.timestamp)).updateChildValues([ "timestamp" : wish.timestamp, "name": wish.name ,  "tag" : wish.tag, "imgURL" : wish.imgURL, "memo" : wish.memo, "link" : wish.link, "placeName" : wish.place.name, "placeLat": wish.place.lat, "placeLng": wish.place.lng, "favorite": wish.favorite])
    } else {
      db.child(String(wish.timestamp)).updateChildValues([ "timestamp" : wish.timestamp, "name": wish.name ,  "tag" : wish.tag, "imgURL" : ["-"], "memo" : wish.memo, "link" : wish.link, "placeName" : wish.place.name, "placeLat": wish.place.lat, "placeLng": wish.place.lng, "favorite": wish.favorite])
    }
  }
  
  func deleteWish(_ wish: Wish){
    // 스토리지 파일 삭제
    for i in 0..<wish.img.count{
      let imageName = "\(wish.timestamp)\(i)"
      storage.reference().child(imageName).delete(completion: nil)
    }
    db.child(String(wish.timestamp)).removeValue()
  }
  
  func loadData(){
    DispatchQueue.global(qos: .userInteractive).async {
      self.db.observeSingleEvent(of:.value) { (snapshot) in
        guard let wishValue = snapshot.value as? [String:Any] else {
          return
        }
        print("---> snapshot : \(wishValue.values)")
        do {
          let data = try JSONSerialization.data(withJSONObject: Array(wishValue.values), options: [])
          let decoder = JSONDecoder()
          // 현재 data는 Array안에 Dictionary가 있는 형태인데 [Wish]로 디코딩 하기
          let wish = try decoder.decode([WishDB].self, from: data)
          let wishDB: [WishDB] = wish.sorted{ $0.timestamp > $1.timestamp}
          var wishList: [Wish] = []
          
          for wish in wishDB{
            if wish.imgURL[0] == "-" {
              wishList.append(Wish(timestamp: wish.timestamp, name: wish.name, tag: wish.tag, memo: wish.memo, img: [], imgURL:[], link: wish.link, place: Place(name: wish.placeName, lat: wish.placeLat, lng: wish.placeLng), favorite: wish.favorite))
            }
            else {
              wishList.append(Wish(timestamp: wish.timestamp, name: wish.name, tag: wish.tag, memo: wish.memo, img: [], imgURL: wish.imgURL, link: wish.link, place: Place(name: wish.placeName, lat: wish.placeLat, lng: wish.placeLng), favorite: wish.favorite))
            }
          }
          NotificationCenter.default.post(name: DidReceiveWishsNotification, object: nil, userInfo: ["wishs" :wishList])
        }
        catch {
          print("---> error : \(error)")
        }
        
      }
    }
  }
}
