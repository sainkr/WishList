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
    if wish.img.isEmpty {
      db
      .child(String(wish.timestamp))
      .setValue([
                  "timestamp" : wish.timestamp,
                  "name": wish.name ,
                  "tag" : wish.tag,
                  "imgURL" : ["-"],
                  "memo" : wish.memo,
                  "link" : wish.link,
                  "placeName" : wish.place?.name ?? "-",
                  "placeLat": wish.place?.lat ?? 0,
                  "placeLng": wish.place?.lng ?? 0,
                  "favorite": wish.favorite])
    }else {
      convertUIImagetoImageURL(wish: wish){ [weak self] imageURL in
        self?.db
          .child(String(wish.timestamp))
          .setValue([
                      "timestamp" : wish.timestamp,
                      "name": wish.name ,
                      "tag" : wish.tag,
                      "imgURL" : imageURL,
                      "memo" : wish.memo,
                      "link" : wish.link,
                      "placeName" : wish.place?.name ?? "-",
                      "placeLat": wish.place?.lat ?? 0,
                      "placeLng": wish.place?.lng ?? 0,
                      "favorite": wish.favorite])
      }
    }
  }
  
  func updateWish(_ wish: Wish, _ imgCnt: Int){
    deleteImage(wish: wish, imgCnt: imgCnt, wishType: .wishUpdate)
    convertUIImagetoImageURL(wish: wish){ [weak self] imageURL in
      self?.db
        .child(String(wish.timestamp))
        .setValue([
                            "timestamp" : wish.timestamp,
                            "name": wish.name ,
                            "tag" : wish.tag,
                            "imgURL" : imageURL,
                            "memo" : wish.memo,
                            "link" : wish.link,
                            "placeName" : wish.place?.name ?? "-",
                            "placeLat": wish.place?.lat ?? 0,
                            "placeLng": wish.place?.lng ?? 0,
                            "favorite": wish.favorite])
    }
  }
  
private func convertUIImagetoImageURL(wish: Wish, completion: @escaping (_ imageURL: [String]) -> Void){
  var imageURL: [String] = []
  for i in wish.img.indices{
    let image: UIImage = wish.img[i]
    // 지정된 이미지를 JPEG 형식으로 포함하는 데이터 개체를 반환합니다., JPEG 이미지의 품질 최대 압축 ~ 최소 압축
    let data = image.jpegData(compressionQuality: 0.1)!
    let metaData = StorageMetadata()
    metaData.contentType = "image/png"
    let imageName = "\(wish.timestamp)\(i)"
    storage.reference().child(imageName).putData(data, metadata: metaData) { (data, err) in
      if let error = err {
        print("--> error:\(error.localizedDescription)")
        return
      }
      self.storage.reference().child(imageName).downloadURL { (url, err) in
        if let error = err {
          print("--> error: \(error.localizedDescription)")
          return
        }
        guard let url = url else {
          print("--> urlError")
          return
        }
        imageURL.append(url.absoluteString)
        if imageURL.count == wish.img.count {
          completion(imageURL)
        }
      }
    }
  }
}
  
  func updateFavoriteWish(_ wish: Wish){
    let imgURL = wish.imgURL.isEmpty ? ["-"] : wish.imgURL
    db.child(String(wish.timestamp)).setValue([ "timestamp" : wish.timestamp, "name": wish.name ,  "tag" : wish.tag, "imgURL" : imgURL, "memo" : wish.memo, "link" : wish.link, "placeName" : wish.place?.name ?? "-", "placeLat": wish.place?.lat ?? 0, "placeLng": wish.place?.lng ?? 0, "favorite": wish.favorite])
  }
  
  func deleteWish(_ wish: Wish){
    deleteImage(wish: wish, imgCnt: 0, wishType: .wishDelete)
    db.child(String(wish.timestamp)).removeValue()
  }
  
  private func deleteImage(wish: Wish, imgCnt: Int, wishType: WishType){
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
          print(Array(wishValue.values))
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
