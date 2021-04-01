//
//  PlaceViewModel.swift
//  WishList
//
//  Created by 홍승아 on 2021/04/01.
//

import Foundation

class PlaceViewModel {
    private let manager = PlaceManager.shareed
    
    var place: Place{
        return manager.place
    }
    
    func addPlace(_ place: Place){
        manager.addPlace(place)
    }
    
    func setPlace(_ name: String){
        manager.setPlace(name)
    }
    
    func resetPlace(){
        manager.resetPlace()
    }
}
