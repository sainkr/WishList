//
//  ConverToAddress.swift
//  WishList
//
//  Created by 홍승아 on 2021/08/11.
//

import Foundation
import CoreLocation

class ConvertToAddress {
  static func convertToAddressWith(latitude: Double, longitude: Double, completion:  @escaping (_ address: String) -> Void){
    let geoCoder = CLGeocoder()
    let locale = Locale(identifier: "Ko-kr")
    let coordinate = CLLocation(latitude: latitude, longitude: longitude)
    geoCoder.reverseGeocodeLocation(coordinate, preferredLocale: locale, completionHandler: {(placemarks, error) in
      if let placeMark: [CLPlacemark] = placemarks {
        if let address: String = placeMark.last?.name {
          completion(address)
        }
      }
    })
  }
}

