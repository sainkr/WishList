//
//  MapViewController.swift
//  WishList
//
//  Created by 홍승아 on 2021/02/06.
//

import UIKit
import MapKit
import CoreLocation

class MapViewController: UIViewController {
  @IBOutlet weak var mapView: MKMapView!
  @IBOutlet weak var searchView: UIView!
  @IBOutlet weak var addPlaceButton: UIButton!
  @IBOutlet weak var deleteButon: UIButton!
  @IBOutlet weak var placeLabel: UILabel!
  @IBOutlet weak var searchImage: UIImageView!
  @IBOutlet weak var currentLoacaionButton: UIButton!
  @IBOutlet weak var navigationBar: UINavigationBar!
  
  var locationManager: CLLocationManager = CLLocationManager()
  var currentLocation: CLLocation!
  let placeAnnotation = MKPointAnnotation()
  
  let wishViewModel = WishViewModel()
  var place: Place?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    requestLocation()
    setView()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(true)
    setMapView()
  }
}

extension MapViewController{
  func setView(){
    mapView.delegate = self
    setNavigationBar()
    setSearchView()
    setAddPlaceButton()
    setCurrentLocationButton()
  }
  
  func setNavigationBar() {
    navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
    navigationBar.shadowImage = UIImage()
    navigationBar.backgroundColor = UIColor.clear
  }
  
  func setSearchView() {
    let searchViewGesture: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(searchViewTapped(_:)))
    searchView.addGestureRecognizer(searchViewGesture)
    decorateView(uiView: searchView, cornerRadius: 20, shadowColor: UIColor.black.cgColor, masksToBounds: false, shadowOffset: CGSize(width: 0, height: 4), shadowRadius: 8, shadowOpacity: 0.3)
  }
  
  func setAddPlaceButton() {
    decorateView(uiView: addPlaceButton, cornerRadius: 15, shadowColor: UIColor.black.cgColor, masksToBounds: false, shadowOffset: CGSize(width: 0, height: 4), shadowRadius: 8, shadowOpacity: 0.3)
  }
  
  func setCurrentLocationButton(){
    decorateView(uiView: currentLoacaionButton, cornerRadius: 15, shadowColor: UIColor.black.cgColor, masksToBounds: false, shadowOffset: CGSize(width: 0, height: 4), shadowRadius: 8, shadowOpacity: 0.3)
  }
  
  func decorateView(uiView: UIView, cornerRadius: CGFloat, shadowColor: CGColor, masksToBounds: Bool, shadowOffset: CGSize, shadowRadius: CGFloat, shadowOpacity: Float){
    uiView.layer.cornerRadius = cornerRadius
    uiView.layer.shadowColor = shadowColor
    uiView.layer.masksToBounds = masksToBounds
    uiView.layer.shadowOffset = shadowOffset
    uiView.layer.shadowRadius = shadowRadius
    uiView.layer.shadowOpacity = shadowOpacity
  }
  
  func setMapView(){
    for i in mapView.annotations{
      self.mapView.removeAnnotation(i)
    }
    for i in wishViewModel.wishs.indices {
      guard let place = wishViewModel.wishs[i].place else { continue }
      let coordinate = CLLocationCoordinate2D(latitude: place.lng, longitude: place.lng)
      let annotation = MKPointAnnotation()
      annotation.coordinate = coordinate
      annotation.title = place.name
      self.mapView.addAnnotation(annotation)
    }
  }
}

// MARK: - IBAction
extension MapViewController {
  @objc func searchViewTapped(_ gesture: UITapGestureRecognizer) {
    guard let searchPlaceVC = storyboard?.instantiateViewController(identifier: SearchPlaceViewController.identifier) as? SearchPlaceViewController else { return }
    searchPlaceVC.mapViewDelegate = self
    present(searchPlaceVC, animated: true, completion: nil)
  }
  
  @IBAction func delteButtonTapped(_ sender: Any) {
    addPlaceButton.isHidden = false
    placeLabel.text = "여기서 검색"
    placeLabel.textColor = .darkGray
    searchImage.isHidden = false
    addPlaceButton.setTitle("    현재 위치 추가    ", for: .normal)
    deleteButon.isHidden = true
    self.mapView.removeAnnotation(placeAnnotation)
  }
  
  @IBAction func placeAddButtonTapped(_ sender: Any) {
    guard let addWishListVC = storyboard?.instantiateViewController(identifier: AddWishViewController.identifier) as? AddWishViewController else { return }
    addWishListVC.modalPresentationStyle = .fullScreen
    addWishListVC.wishType = .wishPlaceAdd
    addWishListVC.place = place
    addWishListVC.searchViewDelegate = self
    present(addWishListVC, animated: true, completion: nil)
  }
  
  @IBAction func currentLoacaionButtonTapped(_ sender: Any) {
    setCurrentLoacation()
  }
  
  @IBAction func backButtonTapped(_ sender: Any) {
    dismiss(animated: true, completion: nil)
  }
}

// MARK: - Location Handling
extension MapViewController: CLLocationManagerDelegate {
   func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
  }
  
  func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
    if #available(iOS 14.0, *) {
      if manager.authorizationStatus == .authorizedWhenInUse {
        setCurrentLoacation()
      }
    } else {
      // Fallback on earlier versions
    }
  }
  
  func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
    print("Failed to get users location.")
  }
  
  private func requestLocation() {
    locationManager.delegate = self
    guard CLLocationManager.locationServicesEnabled() else {
      displayLocationServicesDisabledAlert()
      return
    }
    locationManager.requestWhenInUseAuthorization()
    locationManager.requestLocation()
    locationManager.desiredAccuracy = kCLLocationAccuracyBest
    setCurrentLoacation()
  }
  
  private func displayLocationServicesDisabledAlert() {
    let alert = UIAlertController(title: "오류 발생", message: "위치 서비스 기능이 꺼져있음", preferredStyle: .alert)
    let okAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil)
    alert.addAction(okAction)
    self.present(alert, animated: true, completion: nil)
  }
  
  private func setCurrentLoacation(){
    self.currentLocation = locationManager.location
    self.mapView.showsUserLocation = true
    self.mapView.setUserTrackingMode(.follow, animated: true)
  }
}

extension MapViewController: MapViewDelegate{
  func mapViewUpdate(place: Place) {
    self.place = place
    placeAnnotation.coordinate = CLLocationCoordinate2D(latitude: place.lat, longitude: place.lng)
    let span = MKCoordinateSpan(latitudeDelta: 0.003, longitudeDelta: 0.003)
    let region = MKCoordinateRegion(center: placeAnnotation.coordinate, span: span)
    mapView.setRegion(region, animated: true)
    guard wishViewModel.findWish(placeAnnotation.coordinate) != nil else{
      addPlaceButton.isHidden = true
      return
    }
    mapView.addAnnotation(placeAnnotation)
    placeLabel.text = "\(place.name)"
    placeLabel.textColor = .black
    searchImage.isHidden = true
    addPlaceButton.setTitle("    장소 추가    ", for: .normal)
    deleteButon.isHidden = false
  }
}

extension MapViewController: SearchViewDelegate{
  func searchViewUpdate() {
    placeLabel.text = "여기서 검색"
    placeLabel.textColor = .darkGray
    searchImage.isHidden = false
    addPlaceButton.setTitle("    현재 위치 추가    ", for: .normal)
    deleteButon.isHidden = true
    self.mapView.removeAnnotation(placeAnnotation)
  }
}

extension MapViewController: MKMapViewDelegate{
  func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
    guard let index = wishViewModel.findWish((view.annotation?.coordinate)!) else { return }
    guard let selectWishVC = storyboard?.instantiateViewController(identifier: SelectWishViewController.identifier) as? SelectWishViewController else { return }
    selectWishVC.modalPresentationStyle = .fullScreen
    selectWishVC.index = index
    present(selectWishVC, animated: true, completion: nil)
  }
}
