//
//  Tag.swift
//  WishList
//
//  Created by 홍승아 on 2021/01/30.
//

import UIKit

class TagManager {
    static let shared = TagManager()
    
    var tags: [String] = []
    
    func addTag(_ tag: String){
        tags.append(tag)
    }
    
    func deleteTag(_ index: Int){
        tags.remove(at: index)
    }
    
    func resetTag(){
        tags = []
    }
    
    func setTag(_ tag:[String]){
        tags = tag
    }
    
    func getTagString()-> String{
        var tagString = ""
        for i in 0..<tags.count{
            tagString += "# \(tags[i]) "
        }
    
        return tagString
    }
    
}

class TagViewModel {
    private let manager = TagManager.shared
    
    var tags: [String]{
        return manager.tags
    }
    
    func addTag(_ tag: String){
        manager.addTag(tag)
    }
    
    func deleteTag(_ index: Int){
        manager.deleteTag(index)
    }
    
    func resetTag(){
        manager.resetTag()
    }
    
    func setTag(_ tag: [String]){
        manager.setTag(tag)
    }
    
    func getTagString() -> String{
        return manager.getTagString()
    }

}

