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
        let imgCnt = wish.photo.count
        
        if imgCnt > 0 {
            for i in 0..<imgCnt{
                let image: UIImage = wish.photo[i]
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
                            if imgURL.count == wish.photo.count  {
                                print("--->imgurl..length : \(imgURL.count)")
                                print("---> timestamp : \(String(wish.timestamp))")
                                db.child(String(wish.timestamp)).setValue([ "timestamp" : wish.timestamp, "name": wish.name ,  "tag" : wish.tag, "img" : imgURL, "tagString" : wish.tagString , "content" : wish.content , "link" : wish.link, "placeName" : wish.placeName, "placeLat" : wish.placeLat, "placeLng" : wish.placeLng])
                            }
                        }
                    }
                }
            }
        }
        else{
            db.child(String(wish.timestamp)).setValue([ "timestamp" : wish.timestamp, "name": wish.name ,  "tag" : wish.tag, "img" : ["-"], "tagString" : wish.tagString , "content" : wish.content , "link" : wish.link, "placeName" : wish.placeName, "placeLat" : wish.placeLat, "placeLng" : wish.placeLng])
        }
    }
    
    func updateWish(_ wish: Wish, _ imgCnt: Int){
        // 스토리지 파일 삭제
        for i in 0..<imgCnt{
            let imageName = "\(wish.timestamp)\(i)"
            storage.reference().child(imageName).delete(completion: nil)
        }
        var imgURL: [String] = []
        let imgCnt = wish.photo.count
        for i in 0..<imgCnt{
            let image: UIImage = wish.photo[i]
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
                        if imgURL.count == wish.photo.count  {
                            print("--->imgurl..length : \(imgURL.count)")
                            db.child(String(wish.timestamp)).updateChildValues([ "timestamp" : wish.timestamp, "name": wish.name ,  "tag" : wish.tag, "img" : imgURL, "tagString" : wish.tagString , "content" : wish.content , "link" : wish.link, "placeName" : wish.placeName, "placeLat" : wish.placeLat, "placeLng" : wish.placeLng ])
                        }
                    }
                }
            }
        }
    }
    
    func deleteWish(_ wish: Wish){
        // 스토리지 파일 삭제
        for i in 0..<wish.photo.count{
            let imageName = "\(wish.timestamp)\(i)"
            storage.reference().child(imageName).delete(completion: nil)
        }
        db.child(String(wish.timestamp)).removeValue()
    }
    
    func loadData(){
        db.observeSingleEvent(of:.value) { (snapshot) in
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
               
                for i in wishDB{
                    if i.img[0] == "-" {
                        wishList.append(Wish(timestamp: i.timestamp , name: i.name , tag: i.tag, tagString: i.tagString , content: i.content , photo: [] , img: [] , link: i.link, placeName : i.placeName, placeLat : i.placeLat, placeLng : i.placeLng ))
                    }
                    else {
                        wishList.append(Wish(timestamp: i.timestamp , name: i.name , tag: i.tag, tagString: i.tagString , content: i.content , photo: [] , img: i.img, link: i.link, placeName : i.placeName, placeLat : i.placeLat, placeLng : i.placeLng ))
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

