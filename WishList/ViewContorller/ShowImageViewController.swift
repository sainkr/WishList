//
//  ShowImageViewController.swift
//  WishList
//
//  Created by 홍승아 on 2021/02/26.
//

import UIKit

class ShowImageViewController: UIViewController {
    
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var imageView: UIImageView!
    
    let photoViewModel = PhotoViewModel()
    var currentIndex = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .black
        
        setGesture()
        setPageControl()
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
    
    func setPageControl(){
        print("---> count : \(photoViewModel.photos.count)")
        pageControl.numberOfPages = photoViewModel.photos.count
        imageView.image = photoViewModel.photos[currentIndex]
        pageControl.currentPage = currentIndex
        pageControl.pageIndicatorTintColor = UIColor.lightGray
        pageControl.currentPageIndicatorTintColor = UIColor.white
    }
    
    @objc func respondToSwipeGesture(_ gesture: UIGestureRecognizer) {
        // 만일 제스쳐가 있다면
        if let swipeGesture = gesture as? UISwipeGestureRecognizer{
            
            switch swipeGesture.direction {
                case UISwipeGestureRecognizer.Direction.left :
                    pageControl.currentPage += 1
                    imageView.image = photoViewModel.photos[pageControl.currentPage]
                case UISwipeGestureRecognizer.Direction.right :
                    pageControl.currentPage -= 1
                    imageView.image = photoViewModel.photos[pageControl.currentPage]
                default:
                  break
            }

        }

    }

    @IBAction func deleteButtonTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func pageChanged(_ sender: Any) {
        imageView.image = photoViewModel.photos[pageControl.currentPage]
    }
}
