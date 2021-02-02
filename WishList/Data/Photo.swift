//
//  Photo.swift
//  WishList
//
//  Created by 홍승아 on 2021/02/02.
//

import UIKit

struct Photo: Codable {
    var img: String
}

/*class TagManager {
    static let shared = TagManager()
    
    var tags: [Tag] = []
    
    func addTag(_ tag: Tag){
        tags.append(tag)
    }
    
    func deleteTag(_ tag: Tag){
        tags = tags.filter { $0.tag != tag.tag}
    }
    
    func saveWish(){
        
    }
    
    func retrieveWish() {
        
    }
    
}

class TagViewModel {
    private let manager = TagManager.shared
    
    var tags: [Tag]{
        return manager.tags
    }
    
    func addTag(_ tag: Tag){
        manager.addTag(tag)
    }
    
    func deleteTag(_ tag: Tag){
        manager.deleteTag(tag)
    }

}*/

