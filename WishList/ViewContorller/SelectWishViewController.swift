//
//  WishSelectViewController.swift
//  WishList
//
//  Created by 홍승아 on 2021/02/07.
//

import UIKit

class SelectWishViewController: UIViewController {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var bar: UINavigationBar!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var pageControl: UIPageControl!
    
    let wishListViewModel = WishViewModel()
    let tagViewModel = TagViewModel()
    
    var selectTagViewController = SelectTagViewController()
    
    var paramIndex: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tagViewModel.setTag(wishListViewModel.wishs[paramIndex].tag)
        self.nameLabel.text = wishListViewModel.wishs[paramIndex].name
        self.contentLabel.text = wishListViewModel.wishs[paramIndex].content
        
        setNavigationBar()
        setPageControl()
        setSiwpe()
    }
    
    func setSiwpe(){
        imageView.isUserInteractionEnabled = true
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(SelectWishViewController.respondToSwipeGesture(_:)))
        swipeLeft.direction = UISwipeGestureRecognizer.Direction.left
        self.imageView.addGestureRecognizer(swipeLeft)

        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(SelectWishViewController.respondToSwipeGesture(_:)))
        swipeRight.direction = UISwipeGestureRecognizer.Direction.right
        self.imageView.addGestureRecognizer(swipeRight)
    }
    
    func setPageControl(){
        pageControl.numberOfPages = wishListViewModel.wishs[paramIndex].photo.count
        pageControl.currentPage = 0
        pageControl.pageIndicatorTintColor = UIColor.lightGray
        pageControl.currentPageIndicatorTintColor = UIColor.white
        imageView.image = wishListViewModel.wishs[paramIndex].photo[0]
    }
    
    func setNavigationBar(){
        bar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        bar.shadowImage = UIImage()
        bar.backgroundColor = UIColor.clear
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "tag" {
            let destinationVC = segue.destination as? SelectTagViewController
            selectTagViewController = destinationVC!
        }
    }
    

    @objc func respondToSwipeGesture(_ gesture: UIGestureRecognizer) {
        // 만일 제스쳐가 있다면
        if let swipeGesture = gesture as? UISwipeGestureRecognizer{
            
            switch swipeGesture.direction {
                case UISwipeGestureRecognizer.Direction.left :
                    pageControl.currentPage += 1
                    imageView.image = wishListViewModel.wishs[paramIndex].photo[pageControl.currentPage]
                case UISwipeGestureRecognizer.Direction.right :
                    pageControl.currentPage -= 1
                    imageView.image = wishListViewModel.wishs[paramIndex].photo[pageControl.currentPage]
                default:
                  break
            }

        }

    }
    
    @IBAction func linkButtonTapped(_ sender: Any) {
        //사파리로 링크열기
        if let url = URL(string: wishListViewModel.wishs[paramIndex].link) {
            UIApplication.shared.open(url, options: [:])
        }
    }
    @IBAction func pageChanged(_ sender: Any) {
        imageView.image = wishListViewModel.wishs[paramIndex].photo[pageControl.currentPage]
    }
    
    @IBAction func backButtonTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func menuButtonTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }

}
