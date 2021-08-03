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
  @IBOutlet weak var mapView: MKMapView!
  @IBOutlet weak var cancelButton: UIButton!
  @IBOutlet weak var menuButton: UIButton!
  @IBOutlet weak var linkButton: UIButton!
  
  static let identifier = "SelectWishViewController"
  let wishViewModel = WishViewModel()
  let ChangeImageNotification: Notification.Name = Notification.Name("ChangeImageNotification")
  
  var index: Int = -1
  
  @IBOutlet weak var mapViewHeight: NSLayoutConstraint!
  @IBOutlet weak var mapViewWidth: NSLayoutConstraint!
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "image"{
      let destinationVC = segue.destination as! ImagePageViewController
      destinationVC.index = index
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setNavigationBar()
    setLabel()
    setMapView()
    
    NotificationCenter.default.addObserver(self, selector: #selector(getPhoto(_ :)), name: ChangeImageNotification, object: nil)
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(true)
    // 사진이 없는 경우 체크
    if wishViewModel.wishs[index].img.count > 0 || wishViewModel.wishs[index].imgURL.count > 0{
      cancelButton.tintColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
      menuButton.tintColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
    } else {
      cancelButton.tintColor = #colorLiteral(red: 0.1158123985, green: 0.1258583069, blue: 0.5349373817, alpha: 1)
      menuButton.tintColor = #colorLiteral(red: 0.1158123985, green: 0.1258583069, blue: 0.5349373817, alpha: 1)
    }
  
    // 링크 설정 안한 경우 체크
    if wishViewModel.wishs[index].link == "" {
      linkButton.isHidden = true
    } else {
      linkButton.isHidden = false
    }
    
    // 장소 설정 안한 경우 체크
    if wishViewModel.wishs[index].place.name == "None"{
      mapView.isHidden = true
    } else {
      mapView.isHidden = false
      setMapView()
    }
  }
}

extension SelectWishViewController{

  func setNavigationBar(){
    bar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
    bar.shadowImage = UIImage()
    bar.backgroundColor = UIColor.clear
  }
  
  func setLabel(){
    nameLabel.text = wishViewModel.wishs[index].name
    contentLabel.text = wishViewModel.wishs[index].memo
  }
  
  func setMapView(){
    let width = view.bounds.width
    mapViewWidth.constant = width - 20
    mapViewHeight.constant = (width - 20) * 3 / 4
    mapView.layer.cornerRadius = 15
    let place = wishViewModel.wishs[index].place
    if place.name != "None" {
      let coordinate = CLLocationCoordinate2D(latitude: place.lat, longitude: place.lng)
      let span = MKCoordinateSpan(latitudeDelta: 0.003, longitudeDelta: 0.003)
      let region = MKCoordinateRegion(center: coordinate, span: span)
      self.mapView.setRegion(region, animated: true)
      let annotation = MKPointAnnotation()
      annotation.coordinate = coordinate
      annotation.title = place.name
      self.mapView.addAnnotation(annotation)
    }
  }
  
  @objc func getPhoto(_ noti: Notification){
    /*DispatchQueue.main.async {
      LoadingHUD.hide()
      if LoadingHUD.sharedInstance.type == 1 {
        self.presentShowImageVC()
      } else if LoadingHUD.sharedInstance.type == 2 {
        self.presentAddWishListVC()
      }
    }*/
  }
  
  /*func presentShowImageVC(){
    guard let showImageVC = storyboard?.instantiateViewController(identifier: "ShowImageViewController") as? ShowImageViewController else { return }
    showImageVC.modalPresentationStyle = .fullScreen
    showImageVC.currentIndex = self.pageControl.currentPage
    
    self.present(showImageVC, animated: true, completion: nil)
  }*/
  
  /*func presentAddWishListVC(){
    let addWishListStoryboard = UIStoryboard.init(name: "AddWishList", bundle: nil)
    guard let addWishListVC = addWishListStoryboard.instantiateViewController(identifier: "AddWishViewController") as? AddWishViewController else { return }
    addWishListVC.modalPresentationStyle = .fullScreen
    addWishListVC.wishType = .wishUpdate
    addWishListVC.selectIndex = selectedIndex
    
    self.present(addWishListVC, animated: true, completion: nil)
  }*/
}

// @IBAction
extension SelectWishViewController{
  @IBAction func linkButtonTapped(_ sender: Any) {
    //사파리로 링크열기
    guard let url = URL(string: wishViewModel.wishs[index].link),
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
    let actionsheetController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
    
    // UIAlertAction 설정
    let editWish = UIAlertAction(title: "수정", style: .default) { action in
      if self.wishViewModel.wishs[self.index].imgURL.count == 0 || self.wishViewModel.wishs[self.index].img.count > 0{
        // self.presentAddWishListVC()
      }else {
        LoadingHUD.show(2)
      }
    }
    
    let deleteWish = UIAlertAction(title: "삭제", style: .destructive, handler: { action in
      self.wishViewModel.deleteWish(self.index)
      self.dismiss(animated: true, completion: nil)
    })
    
    let actionCancel = UIAlertAction(title: "취소", style: .cancel, handler: nil)
    
    actionsheetController.addAction(editWish)
    actionsheetController.addAction(deleteWish)
    actionsheetController.addAction(actionCancel)
    
    self.present(actionsheetController, animated: true)
  }
}
