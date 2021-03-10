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
    
    let photoViewModel = PhotoViewModel()
    var currentPage: Int = 0
    
    let DoneEditNotification: Notification.Name = Notification.Name("DoneEditNotification")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
       
        imageView.image = photoViewModel.photos[currentPage]
        countLabel.text = "\(currentPage+1) / \(photoViewModel.photos.count)"
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
                    if currentPage < photoViewModel.photos.count - 1{
                        currentPage += 1
                        imageView.image = photoViewModel.photos[currentPage]
                        self.countLabel.text = "\(currentPage+1) / \(photoViewModel.photos.count)"
                    }
                    
                case UISwipeGestureRecognizer.Direction.right :
                    if currentPage > 0 {
                        currentPage -= 1
                        imageView.image = photoViewModel.photos[currentPage]
                        self.countLabel.text = "\(currentPage+1) / \(photoViewModel.photos.count)"
                    }
                default:
                  break
            }

        }

    }
    

    @IBAction func cancleButtonTapped(_ sender: Any) {
        photoViewModel.resetPhoto()
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func doneButtonTapped(_ sender: Any) {
        NotificationCenter.default.post(name: DoneEditNotification, object: nil, userInfo: nil)
        
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func editButtonTapped(_ sender: Any) {
        let cropViewController = Mantis.cropViewController(image: self.photoViewModel.photos[self.currentPage])
        cropViewController.delegate = self
        cropViewController.modalPresentationStyle = .fullScreen
        self.present(cropViewController, animated: true, completion: nil)
    }
    
}

extension EditImageViewController: CropViewControllerDelegate{
    func cropViewControllerDidCrop(_ cropViewController: CropViewController, cropped: UIImage, transformation: Transformation) {
        photoViewModel.setPhoto(currentPage, cropped)
        imageView.image = photoViewModel.photos[currentPage]
        dismiss(animated: true, completion: nil)
    }
    
    func cropViewControllerDidCancel(_ cropViewController: CropViewController, original: UIImage) {
        dismiss(animated: true, completion: nil)
    }
}
