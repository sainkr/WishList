//
//  Loading.swift
//  WishList
//
//  Created by 홍승아 on 2021/05/15.
//

import Foundation
import UIKit

class LoadingHUD: NSObject {
  static let sharedInstance = LoadingHUD()
  private var popupView: UIImageView?
  var type: Int = 0
  
  class func show(_ type : Int) {
    sharedInstance.type = type
    let popupView = UIImageView(frame: CGRect(x: 0, y: 0, width: 150, height: 150))
    
    popupView.backgroundColor = UIColor.clear
    popupView.animationImages = LoadingHUD.getAnimationImageArray()
    popupView.animationDuration = 0.8
    popupView.animationRepeatCount = 0
    
    if let window = UIApplication.shared.windows.first {
      window.addSubview(popupView)
      popupView.center = window.center
      popupView.startAnimating()
      sharedInstance.popupView?.removeFromSuperview()
      sharedInstance.popupView = popupView
    }
  }
  
  class func hide() {
    if let popupView = sharedInstance.popupView {
      popupView.stopAnimating()
      popupView.removeFromSuperview()
    }
  }
  
  private class func getAnimationImageArray() -> [UIImage] {
    var animationArray: [UIImage] = []
    animationArray.append(UIImage(named: "Loading1")!)
    animationArray.append(UIImage(named: "Loading2")!)
    animationArray.append(UIImage(named: "Loading3")!)
    
    return animationArray
  }
}
