//
//  MapViewController.swift
//  WishList
//
//  Created by 홍승아 on 2021/02/06.
//

import UIKit
import NMapsMap

class MapViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let mapView = NMFMapView(frame: view.frame)
        view.addSubview(mapView)
        // Do any additional setup after loading the view.
    }
    

}
