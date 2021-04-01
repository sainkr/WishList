//
//  TagViewModel.swift
//  WishList
//
//  Created by 홍승아 on 2021/04/01.
//

import Foundation

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
