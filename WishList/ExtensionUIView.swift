//
//  ExtensionUIView.swift
//  WishList
//
//  Created by 홍승아 on 2021/02/23.
//

import UIKit

extension UIView {
    
    @IBInspectable var borderWidth: CGFloat { // 테두리 굵기
        set {
            layer.borderWidth = newValue
        }
        get {
            return layer.borderWidth
        }
    }
    
    @IBInspectable var cornerRadius: CGFloat { // 굴곡
        set {
            layer.cornerRadius = newValue
        }
        get {
            return layer.cornerRadius
        }
    }
    
    @IBInspectable var borderColor: UIColor? { // 테두리 색상
        set {
            guard let uiColor = newValue else { return }
            layer.borderColor = uiColor.cgColor
        }
        get {
            guard let color = layer.borderColor else { return nil }
            return UIColor(cgColor: color)
        }
    }
    
}
