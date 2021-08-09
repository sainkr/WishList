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

// Firebase : nil값이면 저장 안됨

class DataBaseManager {
  static let shared = DataBaseManager()
  
  let db =  Database.database().reference().child("myWhisList")
  let storage = Storage.storage()
  
  func saveWish(_ wish: Wish){
    if wish.img.isEmpty {
        db
        .child(String(wish.timestamp))
        .setValue([
                    "timestamp" : wish.timestamp,
                    "name": wish.name ,
                    "tag" : wish.tag,
                    "imgURL" : [],
                    "memo" : wish.memo,
                    "link" : wish.link,
                    "placeName" : wish.place?.name ?? "-",
                    "placeLat": wish.place?.lat ?? 0,
                    "placeLng": wish.place?.lng ?? 0,
                    "favorite": wish.favorite])
    }else {
      convertUIImagetoImageURL(wish: wish, wishType: .wishAdd)
    }
  }
  
  func updateWish(_ wish: Wish, _ imgCnt: Int){
    deleteImage(wish: wish, imgCnt: imgCnt, wishType: .wishUpdate)
    convertUIImagetoImageURL(wish: wish, wishType: .wishUpdate)
  }
  
  func convertUIImagetoImageURL(wish: Wish, wishType: WishType){
    var imgURL: [String] = []
    for i in wish.img.indices{
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
            if imgURL.count == wish.img.count {
              print("--->imgurl..length : \(imgURL.count)")
              if wishType == .wishAdd {
                db
                  .child(String(wish.timestamp))
                  .setValue([
                              "timestamp" : wish.timestamp,
                              "name": wish.name ,
                              "tag" : wish.tag,
                              "imgURL" : imgURL,
                              "memo" : wish.memo,
                              "link" : wish.link,
                              "placeName" : wish.place?.name ?? "-",
                              "placeLat": wish.place?.lat ?? 0,
                              "placeLng": wish.place?.lng ?? 0,
                              "favorite": wish.favorite])
              }else if wishType == .wishUpdate {
                db
                  .child(String(wish.timestamp))
                  .updateChildValues([
                                      "timestamp" : wish.timestamp,
                                      "name": wish.name ,
                                      "tag" : wish.tag,
                                      "imgURL" : imgURL,
                                      "memo" : wish.memo,
                                      "link" : wish.link,
                                      "placeName" : wish.place?.name ?? "-",
                                      "placeLat": wish.place?.lat ?? 0,
                                      "placeLng": wish.place?.lng ?? 0,
                                      "favorite": wish.favorite])
              }
            }
          }
        }
      }
    }
  }
  
  func updateFavoriteWish(_ wish: Wish){
    let imgURL = wish.imgURL.isEmpty ? ["-"] : wish.imgURL
    db.child(String(wish.timestamp)).updateChildValues([ "timestamp" : wish.timestamp, "name": wish.name ,  "tag" : wish.tag, "imgURL" : imgURL, "memo" : wish.memo, "link" : wish.link, "placeName" : wish.place!.name, "placeLat": wish.place!.lat, "placeLng": wish.place!.lng, "favorite": wish.favorite])
  }
  
  func deleteWish(_ wish: Wish){
    deleteImage(wish: wish, imgCnt: 0, wishType: .wishDelete)
    db.child(String(wish.timestamp)).removeValue()
  }
  
  func deleteImage(wish: Wish, imgCnt: Int, wishType: WishType){
    var cnt = 0
    if wishType == .wishUpdate{
      cnt = imgCnt
    }else if wishType == .wishDelete{
      cnt = !wish.img.isEmpty ? wish.img.count : wish.imgURL.count
    }
    for i in 0..<cnt{
      let imageName = "\(wish.timestamp)\(i)"
      storage.reference().child(imageName).delete(completion: nil)
    }
  }
  
  func loadData(){
    DispatchQueue.global(qos: .userInteractive).async {
      self.db.observeSingleEvent(of:.value) { (snapshot) in
        guard let wishValue = snapshot.value as? [String:Any] else { return }
        // print("---> snapshot : \(wishValue.values)")
        do {
          let data = try JSONSerialization.data(withJSONObject: Array(wishValue.values), options: [])
          let decoder = JSONDecoder()
          // 현재 data는 Array안에 Dictionary가 있는 형태인데 [Wish]로 디코딩 하기
          let wish = try decoder.decode([WishDB].self, from: data)
          let wishDB: [WishDB] = wish.sorted{ $0.timestamp > $1.timestamp}
          var wishList: [Wish] = []
          for wish in wishDB{
            let imgURL = wish.imgURL[0] == "-" ? [] : wish.imgURL
            let place = wish.placeName == "-" ? nil : Place(name: wish.placeName, lat: wish.placeLat, lng: wish.placeLng)
            wishList.append(
              Wish(
                timestamp: wish.timestamp,
                name: wish.name,
                tag: wish.tag,
                memo: wish.memo,
                img: [],
                imgURL: imgURL ,
                link: wish.link,
                place: place,
                favorite: wish.favorite))
          }
          NotificationCenter.default.post(name: DidReceiveWishsNotification, object: nil, userInfo: ["wishs" :wishList])
        }catch {
          print("---> error : \(error)")
        }
      }
    }
  }
}
