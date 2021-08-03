//
//  MapViewController.swift
//  WishList
//
//  Created by 홍승아 on 2021/02/06.
//

import UIKit
import MapKit
import CoreLocation

class MapViewController: UIViewController, CLLocationManagerDelegate {
  @IBOutlet weak var mapView: MKMapView!
  @IBOutlet weak var searchView: UIView!
  @IBOutlet weak var addPlaceButton: UIButton!
  @IBOutlet weak var deleteButon: UIButton!
  @IBOutlet weak var placeLabel: UILabel!
  @IBOutlet weak var searchImage: UIImageView!
  @IBOutlet weak var currentLoacaionButton: UIButton!
  
  var locationManager: CLLocationManager = CLLocationManager() // location manager
  var currentLocation: CLLocation! // 내 위치 저장.
  let placeAnnotation = MKPointAnnotation()
  
  let wishViewModel = WishViewModel()
  
  let PlaceAddCompleteNotification: Notification.Name = Notification.Name("PlaceAddCompleteNotification")
  let WishAddCompleteNotification: Notification.Name = Notification.Name("WishAddCompleteNotification")
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    setMapView()
    setView()
    
    mapView.delegate = self
    
    NotificationCenter.default.addObserver(self, selector: #selector(placeAddCompleteNotification(_:)), name: PlaceAddCompleteNotification, object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(wishAddCompleteNotification(_:)), name: WishAddCompleteNotification, object: nil)
    
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(true)
    setMap()
  }
  
  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    locationManager = manager
    if CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
      currentLocation = locationManager.location
    }
  }
  
  func setMapView(){
    if CLLocationManager.locationServicesEnabled() {
      if CLLocationManager.authorizationStatus() == .denied || CLLocationManager.authorizationStatus() == .restricted {
        let alert = UIAlertController(title: "오류 발생", message: "위치 서비스 기능이 꺼져있음", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil)
        alert.addAction(okAction)
        self.present(alert, animated: true, completion: nil)
      } else {
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        
        self.currentLocation = locationManager.location
        
        self.mapView.showsUserLocation = true
        self.mapView.setUserTrackingMode(.follow, animated: true)
      }
    } else {
      let alert = UIAlertController(title: "오류 발생", message: "위치 서비스 제공 불가", preferredStyle: .alert)
      let okAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil)
      alert.addAction(okAction)
      self.present(alert, animated: true, completion: nil)
    }
    
  }
  
  func setView(){
    let searchViewGesture: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(searchViewTapped(_:)))
    searchView.addGestureRecognizer(searchViewGesture)
    
    searchView.layer.cornerRadius = 20
    searchView.layer.shadowColor = UIColor.black.cgColor // 검정색 사용
    searchView.layer.masksToBounds = false
    searchView.layer.shadowOffset = CGSize(width: 0, height: 4) // 반경에 대해서 너무 적용이 되어서 4point 정도 ㅐ림.
    searchView.layer.shadowRadius = 8 // 반경?
    searchView.layer.shadowOpacity = 0.3 // alpha값입니다.
    
    addPlaceButton.layer.cornerRadius = 15
    addPlaceButton.layer.shadowColor = UIColor.black.cgColor // 검정색 사용
    addPlaceButton.layer.masksToBounds = false
    addPlaceButton.layer.shadowOffset = CGSize(width: 0, height: 4) // 반경에 대해서 너무 적용이 되어서 4point 정도 ㅐ림.
    addPlaceButton.layer.shadowRadius = 8 // 반경?
    addPlaceButton.layer.shadowOpacity = 0.3 // alpha값입니다.
    
    currentLoacaionButton.layer.cornerRadius = 15
    currentLoacaionButton.layer.shadowColor = UIColor.black.cgColor // 검정색 사용
    currentLoacaionButton.layer.masksToBounds = false
    currentLoacaionButton.layer.shadowOffset = CGSize(width: 0, height: 4) // 반경에 대해서 너무 적용이 되어서 4point 정도 ㅐ림.
    currentLoacaionButton.layer.shadowRadius = 8 // 반경?
    currentLoacaionButton.layer.shadowOpacity = 0.3 // alpha값입니다.
  }
  
  func setMap(){
    // 먼저 다 지우기
    for i in mapView.annotations{
      self.mapView.removeAnnotation(i)
    }
    for i in wishViewModel.wishs {
      if i.place.name != "None" {
        let coordinate = CLLocationCoordinate2D(latitude: i.place.lng, longitude: i.place.lng)
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        annotation.title = i.place.name
        self.mapView.addAnnotation(annotation)
      }
    }
    setSearchMap()
  }
  
  func setSearchMap(){
    /*if wishViewModel.wish.placeName != "None" {
      let coordinate = CLLocationCoordinate2D(latitude: wishViewModel.place?.lat , longitude: wishViewModel.wish.placeLng)
      let span = MKCoordinateSpan(latitudeDelta: 0.003, longitudeDelta: 0.003)
      let region = MKCoordinateRegion(center: coordinate, span: span)
      self.mapView.setRegion(region, animated: true)
      
      placeAnnotation.coordinate = coordinate
      placeAnnotation.title = wishViewModel.wish.placeName
      self.mapView.addAnnotation(placeAnnotation)
    }*/
  }
  
  
  @objc func wishAddCompleteNotification(_ noti: Notification){
    placeLabel.text = "여기서 검색"
    placeLabel.textColor = .darkGray
    searchImage.isHidden = false
    addPlaceButton.setTitle("    현재 위치 추가    ", for: .normal)
    deleteButon.isHidden = true
    self.mapView.removeAnnotation(placeAnnotation)
  }
  
  @objc func placeAddCompleteNotification(_ noti: Notification){ // SearchPlaceVC에서 -->
    setMap()
    /*if wishViewModel.wish.placeName != "None" {
      placeLabel.text = wishViewModel.wish.placeName
      placeLabel.textColor = .black
      searchImage.isHidden = true
      addPlaceButton.setTitle("    장소 추가    ", for: .normal)
      deleteButon.isHidden = false
    }*/
  }
  
  @objc func searchViewTapped(_ gesture: UITapGestureRecognizer) {
    let addWishListStoryboard = UIStoryboard.init(name: "AddWishList", bundle: nil)
    guard let searchPlaceVC = addWishListStoryboard.instantiateViewController(identifier: "SearchPlaceViewController") as? SearchPlaceViewController else { return }
    searchPlaceVC.modalPresentationStyle = .fullScreen
    
    present(searchPlaceVC, animated: true, completion: nil)
  }
  
  
  @IBAction func delteButtonTapped(_ sender: Any) {
    placeLabel.text = "여기서 검색"
    placeLabel.textColor = .darkGray
    searchImage.isHidden = false
    addPlaceButton.setTitle("    현재 위치 추가    ", for: .normal)
    deleteButon.isHidden = true
    
    //wishViewModel.resetWish()
    self.mapView.removeAnnotation(placeAnnotation)
  }
  
  @IBAction func placeAddButtonTapped(_ sender: Any) {
    /*wishViewModel.resetWish()
    let addWishListStoryboard = UIStoryboard.init(name: "AddWishList", bundle: nil)
    guard let addWishListVC = addWishListStoryboard.instantiateViewController(identifier: "AddWishListViewController") as? AddWishListViewController else { return }
    addWishListVC.modalPresentationStyle = .fullScreen
    addWishListVC.wishType = .wishPlaceAdd
    
    if wishViewModel.wish.placeName == "None" {
      wishViewModel.addPlace(Place(name: "", lat: currentLocation.coordinate.latitude, lng: currentLocation.coordinate.longitude))
    }
    
    present(addWishListVC, animated: true, completion: nil)*/
  }
  
  @IBAction func currentLoacaionButtonTapped(_ sender: Any) {
    self.currentLocation = locationManager.location
    
    self.mapView.showsUserLocation = true
    self.mapView.setUserTrackingMode(.follow, animated: true)
  }
}

extension MapViewController: MKMapViewDelegate{
  func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
    /*let index = wishListViewModel.findWish((view.annotation?.coordinate)!)
    
    if index > -1 {
      let selectWishStoryboard = UIStoryboard.init(name: "Main", bundle: nil)
      guard let selectWishVC = selectWishStoryboard.instantiateViewController(identifier: "SelectWishViewController") as? SelectWishViewController else { return }
      selectWishVC.modalPresentationStyle = .fullScreen
      
      selectWishVC.selectedIndex = index
      
      present(selectWishVC, animated: true, completion: nil)
    }*/
  }
}
