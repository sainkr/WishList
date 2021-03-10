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
    let tagViewModel = TagViewModel()
    let photoViewModel = PhotoViewModel()
    
    var showTagViewController = SelectTagViewController()
    
    var wishType: Int = -1
    var paramIndex: Int = 0
    
    var wish: Wish!
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "tag" {
            let destinationVC = segue.destination as? SelectTagViewController
            showTagViewController = destinationVC!
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        setWish()
        setNavigationBar()
        setGesture()
        setMap()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        setWish()
        
        // 사진이 없는 경우 체크
        if wish.img.count > 0 || wish.photo.count > 0{
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
        
        photoViewModel.setPhoto(wish.photo)
        
        // 링크 설정 안한 경우 체크
        if wish.link == "" {
            linkButton.isHidden = true
        } else {
            linkButton.isHidden = false
        }
        
        // 장소 설정 안한 경우 체크
        if wish.placeName == "None"{
            mapView.isHidden = true
        } else {
            mapView.isHidden = false
            setMap()
        }
        
    }
    
    func setWish(){
        if wishType == 0 { //favorite wish
            wish = wishViewModel.favoriteWishs()[paramIndex]
        } else if wishType == 1 { // my wish
            wish = wishViewModel.wishs[paramIndex]
        }
        
        setContent()
        
        if wishViewModel.wishs[paramIndex].img.count > 0 {
            changeUIImage()
        }
    }
    
    func setNavigationBar(){
        bar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        bar.shadowImage = UIImage()
        bar.backgroundColor = UIColor.clear
    }
    
    func setContent(){
        self.tagViewModel.setTag(wish.tag)
        self.nameLabel.text = wish.name
        self.contentLabel.text = wish.content
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
        if wish.photo.count > 0 {
            pageControl.numberOfPages = wish.photo.count
            imageView.image = wish.photo[0]
        }
        else {
            if wish.img.count > 0 {
                pageControl.numberOfPages = wish.img.count
                let url = URL(string: wish.img[0])
                imageView.kf.setImage(with: url)
            }
        }
        pageControl.currentPage = 0
        pageControl.pageIndicatorTintColor = UIColor.lightGray
        pageControl.currentPageIndicatorTintColor = UIColor.white
    }
    
    func setMap(){
        mapView.layer.cornerRadius = 15
        
        if wish.placeName != "None" {
            let coordinate = CLLocationCoordinate2D(latitude: wish.placeLat, longitude: wish.placeLng)
            let span = MKCoordinateSpan(latitudeDelta: 0.003, longitudeDelta: 0.003)
            let region = MKCoordinateRegion(center: coordinate, span: span)
            self.mapView.setRegion(region, animated: true)
        
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            annotation.title = wish.placeName
            self.mapView.addAnnotation(annotation)
        }
    }
    
    func changeUIImage(){
        DispatchQueue.global(qos: .userInteractive).async {
            var img: [UIImage] = []
            let imgCnt = self.wish.img.count
            // UIImage로 바꾸는 작업
            for i in 0..<imgCnt{
                guard let url = URL(string: self.wish.img[i]) else { return  }
                let data = NSData(contentsOf: url)
                let image = UIImage(data : data! as Data)!
                img.append(image)
            }
            
            self.photoViewModel.setPhoto(img)
            self.wishViewModel.updatePhoto(self.paramIndex, img)
            
            DispatchQueue.main.async {
                LoadingHUD.hide()
                if LoadingHUD.sharedInstance.type == 1 {
                    let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
                    guard let showImageVC = storyboard.instantiateViewController(identifier: "ShowImageViewController") as? ShowImageViewController else { return }
                    showImageVC.modalPresentationStyle = .fullScreen
                    showImageVC.currentIndex = self.pageControl.currentPage
                    
                    self.present(showImageVC, animated: true, completion: nil)
                } else if LoadingHUD.sharedInstance.type == 2 {
                    let addWishListStoryboard = UIStoryboard.init(name: "AddWishList", bundle: nil)
                    guard let addWishListVC = addWishListStoryboard.instantiateViewController(identifier: "AddWishListViewController") as? AddWishListViewController else { return }
                    addWishListVC.modalPresentationStyle = .fullScreen
                    addWishListVC.paramIndex = self.paramIndex
                    addWishListVC.wishType = self.wishType
                    
                    self.present(addWishListVC, animated: true, completion: nil)
                }
            }
            
            print("---> 끝 !!!!!!!")
        }
    }
    
    @objc func respondToSwipeGesture(_ gesture: UIGestureRecognizer) {
        // 만일 제스쳐가 있다면
        if let swipeGesture = gesture as? UISwipeGestureRecognizer{
            
            switch swipeGesture.direction {
                case UISwipeGestureRecognizer.Direction.left :
                    pageControl.currentPage += 1
                    if wish.photo.count > 0 {
                        imageView.image = wish.photo[pageControl.currentPage]
                    }
                    else {
                        if wish.img.count > 0 {
                            let url = URL(string: wish.img[pageControl.currentPage])
                            imageView.kf.setImage(with: url)
                        }
                    }
                case UISwipeGestureRecognizer.Direction.right :
                    pageControl.currentPage -= 1
                    if wish.photo.count > 0 {
                        imageView.image = wish.photo[pageControl.currentPage]
                    }
                    else {
                        if wish.img.count > 0 {
                            let url = URL(string:  wish.img[pageControl.currentPage])
                            imageView.kf.setImage(with: url)
                        }
                    }
                default:
                  break
            }

        }

    }
    
    @objc func imageViewTapped(_ gesture: UITapGestureRecognizer) {
        if photoViewModel.photos.count > 0 {
            let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
            guard let showImageVC = storyboard.instantiateViewController(identifier: "ShowImageViewController") as? ShowImageViewController else { return }
            showImageVC.modalPresentationStyle = .fullScreen
            showImageVC.currentIndex = pageControl.currentPage
            
            present(showImageVC, animated: true, completion: nil)
        } else {
            if self.wish.photo.count > 0{
                LoadingHUD.show(1)
            }
        }
    }
    
    @IBAction func pageChanged(_ sender: Any) {
        imageView.image = wish.photo[pageControl.currentPage]
    }
    
    @IBAction func linkButtonTapped(_ sender: Any) {
        //사파리로 링크열기
        guard let url = URL(string: wish.link),
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
        resetData()
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func menuButtonTapped(_ sender: Any) {
        // UIAlertController 초기화
        let actionsheetController = UIAlertController(title:    nil, message: nil, preferredStyle: .actionSheet)

        // UIAlertAction 설정
        // handler : 액션 발생시 호출
        let editWish = UIAlertAction(title: "수정", style: .default) { action in
            
            if self.photoViewModel.photos.count > 0 || self.wish.photo.count == 0{
                let addWishListStoryboard = UIStoryboard.init(name: "AddWishList", bundle: nil)
                guard let addWishListVC = addWishListStoryboard.instantiateViewController(identifier: "AddWishListViewController") as? AddWishListViewController else { return }
                addWishListVC.modalPresentationStyle = .fullScreen
                addWishListVC.paramIndex = self.paramIndex
                addWishListVC.wishType = self.wishType
                
                self.present(addWishListVC, animated: true, completion: nil)
            } else {
                if self.wish.photo.count > 0{
                    LoadingHUD.show(2)
                }
            }
        }
        
        let deleteWish = UIAlertAction(title: "삭제", style: .destructive, handler: { action in
            self.wishViewModel.deleteWish(self.wish)
            self.resetData()
            self.dismiss(animated: true, completion: nil)
        })

        // **cancel 액션은 한개만 됩니다.
        let actionCancel = UIAlertAction(title: "취소", style: .cancel, handler: nil)

        actionsheetController.addAction(editWish)
        actionsheetController.addAction(deleteWish)
        actionsheetController.addAction(actionCancel)
        
        self.present(actionsheetController, animated: true)
    }
    
    func resetData(){
        tagViewModel.resetTag()
        photoViewModel.resetPhoto()
    }

}

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

        if let window = UIApplication.shared.keyWindow {
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
