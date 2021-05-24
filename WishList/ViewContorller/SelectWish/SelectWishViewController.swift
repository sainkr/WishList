//
//  WishSelectViewController.swift
//  WishList
//
//  Created by 홍승아 on 2021/02/07.
//

import UIKit
import Kingfisher
import MapKit
import CoreLocation

class SelectWishViewController: UIViewController {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var bar: UINavigationBar!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var menuButton: UIButton!
    @IBOutlet weak var linkButton: UIButton!
    
    let wishViewModel = WishViewModel()
    let wishListViewModel = WishListViewModel()
    
    var showTagViewController = SelectTagViewController()
    
    let ChangeImageNotification: Notification.Name = Notification.Name("ChangeImageNotification")
    
    // 받아온 데이터
    var wishFavoriteType: WishFavoriteType = .mywish
    var selectIndex: Int = -1
    
    @IBOutlet weak var imageViewWidth: NSLayoutConstraint!
    @IBOutlet weak var imageViewBottom: NSLayoutConstraint!
    @IBOutlet weak var mapViewHeight: NSLayoutConstraint!
    @IBOutlet weak var mapViewWidth: NSLayoutConstraint!
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "tag" {
            let destinationVC = segue.destination as? SelectTagViewController
            showTagViewController = destinationVC!
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setConstant()
        setWish()
        setNavigationBar()
        setGesture()
        setMap()
        
        NotificationCenter.default.addObserver(self, selector: #selector(getPhoto(_ :)), name: ChangeImageNotification, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        setWish()
        
        // 사진이 없는 경우 체크
        if wishViewModel.wish.img.count > 0 || wishViewModel.wish.photo.count > 0{
            imageView.isHidden = false
            pageControl.isHidden = false
            
            cancelButton.tintColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
            menuButton.tintColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
            
            setPageControl()
        } else {
            imageView.isHidden = true
            pageControl.isHidden = true
            
            cancelButton.tintColor = #colorLiteral(red: 0.1158123985, green: 0.1258583069, blue: 0.5349373817, alpha: 1)
            menuButton.tintColor = #colorLiteral(red: 0.1158123985, green: 0.1258583069, blue: 0.5349373817, alpha: 1)
        }
        
        // 링크 설정 안한 경우 체크
        if wishViewModel.wish.link == "" {
            linkButton.isHidden = true
        } else {
            linkButton.isHidden = false
        }
        
        // 장소 설정 안한 경우 체크
        if wishViewModel.wish.placeName == "None"{
            mapView.isHidden = true
        } else {
            mapView.isHidden = false
            setMap()
        }
        
    }
}

extension SelectWishViewController{
    func setConstant(){
        let width = view.bounds.width
        imageViewWidth.constant = width
        imageViewBottom.constant = width + 10
        
        mapViewWidth.constant = width - 20
        mapViewHeight.constant = (width - 20) * 3 / 4
    }
    
    func setNavigationBar(){
        bar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        bar.shadowImage = UIImage()
        bar.backgroundColor = UIColor.clear
    }
    
    func setWish(){
        if wishFavoriteType == .favoriteWish { //favorite wish
            wishViewModel.setWish(wishListViewModel.favoriteWishs[selectIndex])
        } else { // my wish
            wishViewModel.setWish(wishListViewModel.wishList[selectIndex])
        }
        
        setContent()
    }
    
    func setContent(){
        nameLabel.text = wishViewModel.wish.name
        contentLabel.text = wishViewModel.wish.content
    }
    
    func setGesture(){
        imageView.isUserInteractionEnabled = true
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(SelectWishViewController.respondToSwipeGesture(_:)))
        swipeLeft.direction = UISwipeGestureRecognizer.Direction.left
        self.imageView.addGestureRecognizer(swipeLeft)
        
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(SelectWishViewController.respondToSwipeGesture(_:)))
        swipeRight.direction = UISwipeGestureRecognizer.Direction.right
        self.imageView.addGestureRecognizer(swipeRight)
        
        let imageViewTap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageViewTapped(_:)))
        self.imageView.addGestureRecognizer(imageViewTap)
        
    }
    
    func setPageControl(){
        if wishViewModel.wish.photo.count > 0 {
            pageControl.numberOfPages = wishViewModel.wish.photo.count
            imageView.image = wishViewModel.wish.photo[0]
        }
        else {
            if wishViewModel.wish.img.count > 0 {
                pageControl.numberOfPages = wishViewModel.wish.img.count
                let url = URL(string: wishViewModel.wish.img[0])
                imageView.kf.setImage(with: url)
            }
        }
        pageControl.currentPage = 0
        pageControl.pageIndicatorTintColor = UIColor.lightGray
        pageControl.currentPageIndicatorTintColor = UIColor.white
    }
    
    func setMap(){
        mapView.layer.cornerRadius = 15
        
        if wishViewModel.wish.placeName != "None" {
            let coordinate = CLLocationCoordinate2D(latitude: wishViewModel.wish.placeLat, longitude: wishViewModel.wish.placeLng)
            let span = MKCoordinateSpan(latitudeDelta: 0.003, longitudeDelta: 0.003)
            let region = MKCoordinateRegion(center: coordinate, span: span)
            self.mapView.setRegion(region, animated: true)
            
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            annotation.title = wishViewModel.wish.placeName
            self.mapView.addAnnotation(annotation)
        }
    }
    
    @objc func getPhoto(_ noti: Notification){
        DispatchQueue.main.async {
            self.setWish()
            LoadingHUD.hide()
            if LoadingHUD.sharedInstance.type == 1 {
                self.presentShowImageVC()
            } else if LoadingHUD.sharedInstance.type == 2 {
                self.presentAddWishListVC()
            }
        }
    }
    
    func presentShowImageVC(){
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        guard let showImageVC = storyboard.instantiateViewController(identifier: "ShowImageViewController") as? ShowImageViewController else { return }
        showImageVC.modalPresentationStyle = .fullScreen
        showImageVC.currentIndex = self.pageControl.currentPage
        
        self.present(showImageVC, animated: true, completion: nil)
    }
    
    func presentAddWishListVC(){
        let addWishListStoryboard = UIStoryboard.init(name: "AddWishList", bundle: nil)
        guard let addWishListVC = addWishListStoryboard.instantiateViewController(identifier: "AddWishListViewController") as? AddWishListViewController else { return }
        addWishListVC.modalPresentationStyle = .fullScreen
        addWishListVC.wishType = .wishUpdate
        addWishListVC.selectIndex = self.selectIndex
        
        self.present(addWishListVC, animated: true, completion: nil)
    }
}

// @IBAction
extension SelectWishViewController{
    @objc func respondToSwipeGesture(_ gesture: UIGestureRecognizer) {
        // 만일 제스쳐가 있다면
        if let swipeGesture = gesture as? UISwipeGestureRecognizer{
            
            switch swipeGesture.direction {
            case UISwipeGestureRecognizer.Direction.left :
                pageControl.currentPage += 1
                if wishViewModel.wish.photo.count > 0 {
                    imageView.image = wishViewModel.wish.photo[pageControl.currentPage]
                }
                else {
                    if wishViewModel.wish.img.count > 0 {
                        let url = URL(string: wishViewModel.wish.img[pageControl.currentPage])
                        imageView.kf.setImage(with: url)
                    }
                }
            case UISwipeGestureRecognizer.Direction.right :
                pageControl.currentPage -= 1
                if wishViewModel.wish.photo.count > 0 {
                    imageView.image = wishViewModel.wish.photo[pageControl.currentPage]
                }
                else {
                    if wishViewModel.wish.img.count > 0 {
                        let url = URL(string:  wishViewModel.wish.img[pageControl.currentPage])
                        imageView.kf.setImage(with: url)
                    }
                }
            default:
                break
            }
        }
    }
    
    @objc func imageViewTapped(_ gesture: UITapGestureRecognizer) {
        if wishViewModel.wish.photo.count > 0 {
            presentShowImageVC()
        } else {
            LoadingHUD.show(1)
        }
    }
    
    @IBAction func pageChanged(_ sender: Any) {
        imageView.image = wishViewModel.wish.photo[pageControl.currentPage]
    }
    
    @IBAction func linkButtonTapped(_ sender: Any) {
        //사파리로 링크열기
        guard let url = URL(string: wishViewModel.wish.link),
              UIApplication.shared.canOpenURL(url) else {
            
            let alert = UIAlertController(title: nil, message: "유효하지 않은 링크 입니다.", preferredStyle: UIAlertController.Style.alert)
            let okAction = UIAlertAction(title: "확인", style: .default, handler : nil )
            alert.addAction(okAction)
            present(alert, animated: true, completion: nil)
            
            return
        }
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
    
    @IBAction func backButtonTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func menuButtonTapped(_ sender: Any) {
        // UIAlertController 초기화
        let actionsheetController = UIAlertController(title:    nil, message: nil, preferredStyle: .actionSheet)
        
        // UIAlertAction 설정
        let editWish = UIAlertAction(title: "수정", style: .default) { action in
            if self.wishViewModel.wish.img.count == 0 || self.wishViewModel.wish.photo.count > 0{
                self.presentAddWishListVC()
            } else {
                LoadingHUD.show(2)
            }
        }
        
        let deleteWish = UIAlertAction(title: "삭제", style: .destructive, handler: { action in
            self.wishListViewModel.deleteWish(self.wishViewModel.wish)
            self.wishViewModel.resetWish()
            self.dismiss(animated: true, completion: nil)
        })
        
        let actionCancel = UIAlertAction(title: "취소", style: .cancel, handler: nil)
        
        actionsheetController.addAction(editWish)
        actionsheetController.addAction(deleteWish)
        actionsheetController.addAction(actionCancel)
        
        self.present(actionsheetController, animated: true)
    }
}
