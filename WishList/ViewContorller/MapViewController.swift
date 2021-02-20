//
//  MapViewController.swift
//  WishList
//
//  Created by 홍승아 on 2021/02/06.
//

import UIKit
import GoogleMaps
import GooglePlaces

class MapViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
         
         let camera = GMSCameraPosition.camera(withLatitude: -33.86, longitude: 151.20, zoom: 6.0)
         let mapView = GMSMapView.map(withFrame: CGRect.zero, camera: camera)
         
        view = mapView
         
         let marker = GMSMarker()
         marker.position = CLLocationCoordinate2D(latitude: -33.86, longitude: 151.20)
         marker.title = "Sydney"
         marker.snippet = "Australia"
         marker.map = mapView
    }
    
}

