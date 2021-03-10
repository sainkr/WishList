//
//  Place.swift
//  WishList
//
//  Created by 홍승아 on 2021/02/22.
//

import UIKit

struct Place{
    var name: String
    var lat: Double
    var lng: Double
}

class PlaceManager {
    static let shareed = PlaceManager()
    
    var place: Place = Place(name: "None", lat: 0, lng: 0)
    
    func addPlace(_ place: Place){
        self.place = place
    }
    
    func setPlace(_ name: String){
        self.place.name = name
    }
    
    func resetPlace(){
        place = Place(name: "None", lat: 0, lng: 0)
    }
}

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

