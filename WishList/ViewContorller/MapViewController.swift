//
//  MapViewController.swift
//  WishList
//
//  Created by 홍승아 on 2021/02/06.
//

import CoreLocation
import MapKit
import UIKit

class MapViewController: UIViewController {
  @IBOutlet weak var mapView: MKMapView!
  @IBOutlet weak var searchView: UIView!
  @IBOutlet weak var addPlaceButton: UIButton!
  @IBOutlet weak var deleteButon: UIButton!
  @IBOutlet weak var placeLabel: UILabel!
  @IBOutlet weak var searchImage: UIImageView!
  @IBOutlet weak var currentLoacaionButton: UIButton!
  @IBOutlet weak var navigationBar: UINavigationBar!
  
  private var locationManager: CLLocationManager = CLLocationManager()
  private var currentLocation: CLLocation!
  private let placeAnnotation = MKPointAnnotation()
  private let wishViewModel = WishViewModel()
  private var place: Place?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    requestLocation()
    configureView()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(true)
    configuretMapView()
  }
}

extension MapViewController{
  private func configureView(){
    mapView.delegate = self
    configureNavigationBar()
    configureSearchView()
    configureAddPlaceButton()
    configureCurrentLocationButton()
  }
  
  private func configureNavigationBar() {
    navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
    navigationBar.shadowImage = UIImage()
    navigationBar.backgroundColor = UIColor.clear
  }
  
  private func configureSearchView() {
    let searchViewGesture: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(searchViewDidTap(_:)))
    searchView.addGestureRecognizer(searchViewGesture)
    decorateView(uiView: searchView, cornerRadius: 20, shadowColor: UIColor.black.cgColor, masksToBounds: false, shadowOffset: CGSize(width: 0, height: 4), shadowRadius: 8, shadowOpacity: 0.3)
  }
  
  private func configureAddPlaceButton() {
    decorateView(uiView: addPlaceButton, cornerRadius: 15, shadowColor: UIColor.black.cgColor, masksToBounds: false, shadowOffset: CGSize(width: 0, height: 4), shadowRadius: 8, shadowOpacity: 0.3)
  }
  
  private func configureCurrentLocationButton(){
    decorateView(uiView: currentLoacaionButton, cornerRadius: 15, shadowColor: UIColor.black.cgColor, masksToBounds: false, shadowOffset: CGSize(width: 0, height: 4), shadowRadius: 8, shadowOpacity: 0.3)
  }
  
  private func decorateView(uiView: UIView, cornerRadius: CGFloat, shadowColor: CGColor, masksToBounds: Bool, shadowOffset: CGSize, shadowRadius: CGFloat, shadowOpacity: Float){
    uiView.layer.cornerRadius = cornerRadius
    uiView.layer.shadowColor = shadowColor
    uiView.layer.masksToBounds = masksToBounds
    uiView.layer.shadowOffset = shadowOffset
    uiView.layer.shadowRadius = shadowRadius
    uiView.layer.shadowOpacity = shadowOpacity
  }
  
  private func configuretMapView(){
    for i in mapView.annotations{
      self.mapView.removeAnnotation(i)
    }
    for place in wishViewModel.places {
      guard let place = place else { continue }
      let coordinate = CLLocationCoordinate2D(latitude: place.lng, longitude: place.lng)
      let annotation = MKPointAnnotation()
      annotation.coordinate = coordinate
      annotation.title = place.name
      self.mapView.addAnnotation(annotation)
    }
  }
  
  private func resetSearchView(){
    addPlaceButton.isHidden = false
    placeLabel.text = "여기서 검색"
    placeLabel.textColor = .darkGray
    searchImage.isHidden = false
    addPlaceButton.setTitle("    현재 위치 추가    ", for: .normal)
    deleteButon.isHidden = true
    self.mapView.removeAnnotation(placeAnnotation)
  }
}

// MARK: - IBAction
extension MapViewController {
  @IBAction func backButtonDidTap(_ sender: Any) {
    dismiss(animated: true, completion: nil)
  }
  
  @IBAction func deleteButtonDidTap(_ sender: Any) {
    resetSearchView()
  }
  
  @IBAction func placeAddButtonDidTap(_ sender: Any) {
    guard let addWishListVC = storyboard?.instantiateViewController(identifier: AddWishViewController.identifier) as? AddWishViewController else { return }
    addWishListVC.modalPresentationStyle = .fullScreen
    addWishListVC.wishType = .wishPlaceAdd
    addWishListVC.place = place
    addWishListVC.searchViewDelegate = self
    present(addWishListVC, animated: true, completion: nil)
  }
  
  @IBAction func currentLocationButtonDidTap(_ sender: Any) {
    setCurrentLoacation()
  }
  
  @objc func searchViewDidTap(_ gesture: UITapGestureRecognizer) {
    guard let searchPlaceVC = storyboard?.instantiateViewController(identifier: SearchPlaceViewController.identifier) as? SearchPlaceViewController else { return }
    searchPlaceVC.mapViewDelegate = self
    present(searchPlaceVC, animated: true, completion: nil)
  }
}

// MARK:- CLLocationManagerDelegate
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

// MARK:- MapViewDelegate
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

// MARK:- SearchViewDelegate
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

// MARK:- MKMapViewDelegate
extension MapViewController: MKMapViewDelegate{
  func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
    guard let index = wishViewModel.findWish((view.annotation?.coordinate)!) else { return }
    guard let selectWishVC = storyboard?.instantiateViewController(identifier: SelectWishViewController.identifier) as? SelectWishViewController else { return }
    selectWishVC.modalPresentationStyle = .fullScreen
    selectWishVC.index = index
    present(selectWishVC, animated: true, completion: nil)
  }
}
