//
//  AddWishListViewController.swift
//  WishList
//
//  Created by 홍승아 on 2021/01/28.
//

import UIKit
import MapKit
import CoreLocation

class AddWishViewController: UIViewController{
  static let identifier = "AddWishViewController"
  
  @IBOutlet weak var nameTextField: UITextField!
  @IBOutlet weak var tagSelectTextField: UITextField!
  @IBOutlet weak var linkTextField: UITextField!
  @IBOutlet var gestureRecognizer: UITapGestureRecognizer!
  @IBOutlet weak var memoTextView: UITextView!
  @IBOutlet weak var placeTextField: UITextField!
  @IBOutlet weak var mapView: MKMapView!
  @IBOutlet weak var linkdeleteButton: UIButton!
  @IBOutlet weak var placedeleteButton: UIButton!
  @IBOutlet weak var navigationBar: UINavigationBar!
  
  var addWishTagViewController: AddWishTagViewController!
  var addWishImageViewController: AddWishImageViewController!
  
  let wishViewModel = WishViewModel()
  let annotation = MKPointAnnotation()
  var wishType: WishType = .wishAdd
  var index: Int = 0
  var place: Place?
  var searchViewDelegate: SearchViewDelegate?
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "tag" {
      let destinationVC = segue.destination as? AddWishTagViewController
      addWishTagViewController = destinationVC
    } else if segue.identifier == "photo" {
      let destinationVC = segue.destination as? AddWishImageViewController
      addWishImageViewController = destinationVC
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    memoTextView.delegate = self
    placeTextField.delegate = self
    tagSelectTextField.delegate = self
    setView()
  }
}

extension AddWishViewController {
  func setView(){
    setNavigationBar()
    setMemoTextView()
    setMapView()
    wishViewModel.addWish()
    if wishType == .wishUpdate{
      wishViewModel.setWish(index: index)
      setContent()
    }else if wishType == .wishPlaceAdd{
      guard let place = place else { return }
      wishViewModel.setPlace(place: place)
      setMapContent(place: place)
    }
  }
  
  func setNavigationBar(){
    navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
    navigationBar.shadowImage = UIImage()
    navigationBar.backgroundColor = UIColor.clear
    navigationBar.titleTextAttributes = [ NSAttributedString.Key.font : UIFont.systemFont(ofSize: 18, weight: .bold) ]
    navigationBar.topItem?.title = wishType == .wishUpdate ? "Wish 수정" : "Wish 추가"
  }
  
  func setMemoTextView(){
    memoTextView.text = "간단 메모"
    memoTextView.textColor = .lightGray
  }
  
  func setMapView(){
    mapView.layer.cornerRadius = 15
    mapView.showsUserLocation = true
    mapView.setUserTrackingMode(.follow, animated: true)
  }
  
  func setContent(){
    let wish = wishViewModel.wishs[index]
    nameTextField.text = wish.name
    memoTextView.text = wish.memo.count > 0 ? wish.memo : "간단 메모"
    memoTextView.textColor = wish.memo.count > 0 ? .black : .lightGray
    linkTextField.text = wish.link
    linkdeleteButton.isHidden = wish.link.count > 0 ? false : true
    guard let place = wish.place else { return }
    setMapContent(place: place)
  }
  
  func setMapContent(place: Place){
    convertToAddressWith(coordinate: CLLocation(latitude: place.lat, longitude: place.lng))
    let coordinate = CLLocationCoordinate2D(latitude: place.lat , longitude: place.lng)
    let span = MKCoordinateSpan(latitudeDelta: 0.003, longitudeDelta: 0.003)
    let region = MKCoordinateRegion(center: coordinate, span: span)
    mapView.setRegion(region, animated: true)
    annotation.coordinate = coordinate
    annotation.title = place.name
    mapView.addAnnotation(annotation)
    placeTextField.text = place.name
    placedeleteButton.isHidden = false
  }
  
  func setAnnotaion(){
    let wish = wishViewModel.wishs[wishViewModel.wishs.count - 1]
    guard let place = wish.place else { return }
    let coordinate = CLLocationCoordinate2D(latitude: place.lat , longitude: place.lng)
    let span = MKCoordinateSpan(latitudeDelta: 0.003, longitudeDelta: 0.003)
    let region = MKCoordinateRegion(center: coordinate, span: span)
    mapView.setRegion(region, animated: true)
    annotation.coordinate = coordinate
    annotation.title = place.name
    mapView.addAnnotation(annotation)
    placeTextField.text = place.name
    placedeleteButton.isHidden = false
  }
  
  func convertToAddressWith(coordinate: CLLocation){
    let geoCoder = CLGeocoder()
    let locale = Locale(identifier: "Ko-kr")
    geoCoder.reverseGeocodeLocation(coordinate, preferredLocale: locale, completionHandler: {(placemarks, error) in
      if let address: [CLPlacemark] = placemarks {
        if let name: String = address.last?.name {
          self.placeTextField.text = name
        }
      }
    })
  }
  
  func addAlert(message: String, title: String){
    let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
    let okAction = UIAlertAction(title: title , style: UIAlertAction.Style.default, handler: nil)
    alert.addAction(okAction)
    self.present(alert, animated: true, completion: nil)
  }
}

extension AddWishViewController: MapViewDelegate{
  func mapViewUpdate(place: Place) {
    wishViewModel.setPlace(place: place)
    setAnnotaion()
    placedeleteButton.isHidden = false
  }
}

// MARK: - IBAction
extension AddWishViewController{
  @IBAction func backButtonTapped(_ sender: Any){
    wishViewModel.removeLastWish()
    dismiss(animated: true, completion: nil)
  }
  
  @IBAction func doneButtonTapped(_ sender: Any){
    if nameTextField.text == "" {
      addAlert(message:"이름을 입력하세요." , title: "확인")
      return
    }
    let name = nameTextField.text ?? ""
    let memo = memoTextView.text == "간단 메모" ? "" : memoTextView.text ?? ""
    let link = linkTextField.text ?? ""
    wishViewModel.setLastWish(name: name, memo: memo, link: link)
    wishViewModel.saveWish(index: index, wishType: wishType)
    if wishType == .wishPlaceAdd{
      searchViewDelegate?.searchViewUpdate()
    }
    dismiss(animated: true, completion: nil)
  }
  
  @IBAction func linkDeleteButtonTapped(_ sender: Any) {
    linkTextField.text = ""
    linkdeleteButton.isHidden = true
  }
  
  @IBAction func placeDeleteButtonTapped(_ sender: Any) {
    placeTextField.text = ""
    mapView.removeAnnotation(annotation)
    placedeleteButton.isHidden = true
  }
  
  // 탭 했을때, 키보드 내려옴
  @IBAction func tapBG(_ sender: Any) {
    view.endEditing(true)
  }
  
  @IBAction func linkTextFieldChange(_ sender: Any) {
    linkdeleteButton.isHidden = linkTextField.text?.isEmpty ?? false ? true : false
  }
  
  @IBAction func linkTextFiledDidEnd(_ sender: Any) {
    if linkTextField.text?.isEmpty == true {
      linkdeleteButton.isHidden = true
    }
  }
}

// MARK:- TextFieldDelegate
extension AddWishViewController: UITextFieldDelegate{
  func textFieldDidBeginEditing(_ textField: UITextField) {
    if textField == placeTextField {
      view.endEditing(true)
      guard let searchPlaceVC = storyboard?.instantiateViewController(identifier: SearchPlaceViewController.identifier) as? SearchPlaceViewController else { return }
      searchPlaceVC.mapViewDelegate = self
      present(searchPlaceVC, animated: true, completion: nil)
    }
  }
  
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    if textField == tagSelectTextField{
      guard let tag = tagSelectTextField.text, tag.isEmpty == false else { return false }
      wishViewModel.addTag(tag: tag)
      self.addWishTagViewController.collectionView.reloadData()
      tagSelectTextField.text = ""
    }
    return true
  }
}

// MARK:- UITextViewDelegate
extension AddWishViewController: UITextViewDelegate{
  func textViewDidBeginEditing(_ textView: UITextView) {
    if textView.textColor == UIColor.lightGray {
      textView.text = ""
      textView.textColor = UIColor.black
    }
  }
  
  func textViewDidEndEditing(_ textView: UITextView) {
    if textView.text.isEmpty {
      textView.text = "간단 메모"
      textView.textColor = .lightGray
      let newPosition = textView.beginningOfDocument
      textView.selectedTextRange = textView.textRange(from: newPosition, to: newPosition)
    }
  }
}
