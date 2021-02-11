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
        for i in 0..<wish.photo.count{
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
                        // print("--> url : \(url?.absoluteString)")
                        print("---> \(i)")
                        imgURL.append(url!.absoluteString)
                        if imgURL.count == wish.photo.count  {
                            print("--->imgurl..length : \(imgURL.count)")
                            db.childByAutoId().setValue([ "timestamp" : wish.timestamp, "name": wish.name ,  "tag" : wish.tag, "img" : imgURL, "content" : wish.content , "link" : wish.link, "place" : wish.place])
                        }
                    }
                }
            }
        }
    }
    
    func loadData(){
        var wishList: [WishDB] = []
        var wishs: [Wish] = []
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
                wishList = wish.sorted{ $0.timestamp > $1.timestamp}
 
                // UIImage로 바꾸는 작업
                for i in 0..<wishList.count{
                    var img: [UIImage] = []
                    for j in 0..<wishList[i].img.count{
                        guard let url = URL(string: wishList[i].img[j]) else { return  }
                        let data = NSData(contentsOf: url)
                        let image = UIImage(data : data! as Data)!
                        img.append(image)
                    }
                    var tagString = ""
                    
                    for j in 0..<wishList[i].tag.count{
                        tagString += "# \(wishList[i].tag[j])"
                    }
                    
                    let wish = Wish(
                        timestamp: wishList[i].timestamp, name: wishList[i].name, tag: wishList[i].tag, tagString : tagString, content: wishList[i].content, photo: img, link: wishList[i].link, place: wishList[i].place)
                    wishs.append(wish)
                }
                
                NotificationCenter.default.post(name: DidReceiveWishsNotification, object: nil, userInfo: ["wishs" :wishs])
            }
            catch {
                print("---> error : \(error)")
            }
        }
    }
}

