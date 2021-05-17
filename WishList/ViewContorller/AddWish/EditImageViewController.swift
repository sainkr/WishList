//
//  EditImageViewController.swift
//  WishList
//
//  Created by 홍승아 on 2021/03/06.
//

import UIKit
import Mantis

class EditImageViewController: UIViewController{
    
    @IBOutlet weak var countLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    
    let wishViewModel = WishViewModel()
    var currentPage: Int = 0
    
    let DoneEditNotification: Notification.Name = Notification.Name("DoneEditNotification")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageView.image = wishViewModel.wish.photo[currentPage]
        countLabel.text = "\(currentPage+1) / \(wishViewModel.wish.photo.count)"
        setGesture()
    }
    
    func setGesture(){
        imageView.isUserInteractionEnabled = true
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(SelectWishViewController.respondToSwipeGesture(_:)))
        swipeLeft.direction = UISwipeGestureRecognizer.Direction.left
        self.imageView.addGestureRecognizer(swipeLeft)
        
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(SelectWishViewController.respondToSwipeGesture(_:)))
        swipeRight.direction = UISwipeGestureRecognizer.Direction.right
        self.imageView.addGestureRecognizer(swipeRight)
        
    }
    
    @objc func respondToSwipeGesture(_ gesture: UIGestureRecognizer) {
        // 만일 제스쳐가 있다면
        if let swipeGesture = gesture as? UISwipeGestureRecognizer{
            
            switch swipeGesture.direction {
            case UISwipeGestureRecognizer.Direction.left :
                if currentPage < wishViewModel.wish.photo.count - 1{
                    currentPage += 1
                    imageView.image = wishViewModel.wish.photo[currentPage]
                    self.countLabel.text = "\(currentPage+1) / \(wishViewModel.wish.photo.count)"
                    setGesture()
                }
                
            case UISwipeGestureRecognizer.Direction.right :
                if currentPage > 0 {
                    currentPage -= 1
                    imageView.image = wishViewModel.wish.photo[currentPage]
                    self.countLabel.text = "\(currentPage+1) / \(wishViewModel.wish.photo.count)"
                    setGesture()
                }
            default:
                break
            }
            
        }
        
    }
    
    
    @IBAction func cancleButtonTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func doneButtonTapped(_ sender: Any) {
        NotificationCenter.default.post(name: DoneEditNotification, object: nil, userInfo: nil)
        
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func editButtonTapped(_ sender: Any) {
        let cropViewController = Mantis.cropViewController(image: self.wishViewModel.wish.photo[self.currentPage])
        cropViewController.delegate = self
        cropViewController.modalPresentationStyle = .fullScreen
        self.present(cropViewController, animated: true, completion: nil)
    }
    
}

extension EditImageViewController: CropViewControllerDelegate{
    func cropViewControllerDidCrop(_ cropViewController: CropViewController, cropped: UIImage, transformation: Transformation) {
        wishViewModel.setPhoto(currentPage, cropped)
        imageView.image = wishViewModel.wish.photo[currentPage]
        dismiss(animated: true, completion: nil)
    }
    
    func cropViewControllerDidCancel(_ cropViewController: CropViewController, original: UIImage) {
        dismiss(animated: true, completion: nil)
    }
}
