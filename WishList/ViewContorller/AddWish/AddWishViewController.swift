//
//  AddWishListViewController.swift
//  WishList
//
//  Created by 홍승아 on 2021/01/28.
//

import CoreLocation
import MapKit
import UIKit

import SnapKit

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
  
  private var addTagViewController: AddTagViewController!
  private var addImageViewController: AddImageViewController!
  private let wishViewModel = WishViewModel()
  private let annotation = MKPointAnnotation()
  var wishType: WishType = .wishAdd
  var index: Int = 0
  var place: Place?
  var searchViewDelegate: SearchViewDelegate?
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "tag" {
      let destinationVC = segue.destination as? AddTagViewController
      addTagViewController = destinationVC
    } else if segue.identifier == "photo" {
      let destinationVC = segue.destination as? AddImageViewController
      addImageViewController = destinationVC
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    memoTextView.delegate = self
    placeTextField.delegate = self
    linkTextField.delegate = self
    tagSelectTextField.delegate = self
    configureView()
  }
}

extension AddWishViewController {
  private func configureView(){
    gestureRecognizer.cancelsTouchesInView = false
    configureNavigationBar()
    configureMemoTextView()
    configureMapView()
    wishViewModel.addWish()
    if wishType == .wishUpdate{
      wishViewModel.setWish(index)
      configureContent()
    }else if wishType == .wishPlaceAdd{
      guard let place = place else { return }
      wishViewModel.setPlace(place: place)
      configureMapContent(place: place)
    }
  }
  
  private func configureNavigationBar(){
    navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
    navigationBar.shadowImage = UIImage()
    navigationBar.backgroundColor = UIColor.clear
    navigationBar.titleTextAttributes = [ NSAttributedString.Key.font : UIFont.systemFont(ofSize: 18, weight: .bold) ]
    navigationBar.topItem?.title = wishType == .wishUpdate ? "Wish 수정" : "Wish 추가"
  }
  
  private func configureMemoTextView(){
    memoTextView.text = "간단 메모"
    memoTextView.textColor = .lightGray
  }
  
  private func configureMapView(){
    mapView.layer.cornerRadius = 15
    mapView.showsUserLocation = true
    mapView.setUserTrackingMode(.follow, animated: true)
    mapView.snp.makeConstraints{ make in
      make.bottom.equalToSuperview().inset(20)
    }
  }
  
  private func configureContent(){
    nameTextField.text = wishViewModel.name(index)
    if wishViewModel.memo(index).count > 0{
      memoTextView.text = wishViewModel.memo(index)
      memoTextView.textColor = .black
    }else{
      memoTextView.text = "간단 메모"
      memoTextView.textColor = .lightGray
    }
    linkTextField.text = wishViewModel.link(index)
    linkdeleteButton.isHidden = wishViewModel.link(index).count > 0 ? false : true
    guard let place = wishViewModel.place(index) else { return }
    configureMapContent(place: place)
  }
  
  private func configureMapContent(place: Place){
    ConvertToAddress.convertToAddressWith(
      latitude: place.lat,
      longitude: place.lng,
      completion: { [weak self] address in
        self?.placeTextField.text = address
      })
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
  
  private func configureAnnotaion(){
    guard let place = wishViewModel.place(wishViewModel.lastWishIndex) else { return }
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
  
  private func addAlert(message: String, title: String){
    let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
    let okAction = UIAlertAction(title: title , style: UIAlertAction.Style.default, handler: nil)
    alert.addAction(okAction)
    self.present(alert, animated: true, completion: nil)
  }
}

// MARK: - MapViewDelegate
extension AddWishViewController: MapViewDelegate{
  func mapViewUpdate(place: Place) {
    wishViewModel.setPlace(place: place)
    configureAnnotaion()
    placedeleteButton.isHidden = false
  }
}

// MARK: - IBAction
extension AddWishViewController{
  @IBAction func backButtonDidTap(_ sender: Any) {
    wishViewModel.removeLastWish()
    dismiss(animated: true, completion: nil)
  }
  
  @IBAction func doneButtonDidTap(_ sender: Any) {
    if nameTextField.text == "" {
      addAlert(message:"이름을 입력하세요." , title: "확인")
      return
    }
    if wishViewModel.tagCount(wishViewModel.lastWishIndex) == 0 {
      addAlert(message:"적어도 한 개의 태그를 입력하세요." , title: "확인")
      return
    }
    let name = nameTextField.text ?? ""
    let memo = memoTextView.text == "간단 메모" ? "" : memoTextView.text ?? ""
    let link = linkTextField.text ?? ""
    wishViewModel.setLastWish(name: name, memo: memo, link: link)
    if wishType == .wishUpdate {
      wishViewModel.updateWish(index)
    }else {
      wishViewModel.saveWish(wishViewModel.lastWishIndex)
    }
    if wishType == .wishPlaceAdd{
      searchViewDelegate?.searchViewUpdate()
    }
    dismiss(animated: true, completion: nil)
  }
  
  @IBAction func linkDeleteButtonDidTap(_ sender: Any) {
    linkTextField.text = ""
    linkdeleteButton.isHidden = true
  }
  
  @IBAction func placeDeleteButtonDidTap(_ sender: Any) {
    placeTextField.text = ""
    mapView.removeAnnotation(annotation)
    placedeleteButton.isHidden = true
  }
  
  @IBAction func viewDidTap(_ sender: Any) {
    view.endEditing(true)
  }
}

// MARK:- UITextFieldDelegate
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
    if textField == tagSelectTextField { 
      guard let tag = tagSelectTextField.text, tag.isEmpty == false else { return false }
      wishViewModel.addTag(tag)
      self.addTagViewController.tagCollectionView.reloadData()
      tagSelectTextField.text = ""
    }
    return true
  }
  
  func textFieldDidEndEditing(_ textField: UITextField) {
    if textField == linkTextField {
      if linkTextField.text?.isEmpty == true {
        linkdeleteButton.isHidden = true
      }
    }
  }
  
  func textFieldDidChangeSelection(_ textField: UITextField) {
    if textField == linkTextField {
     linkdeleteButton.isHidden = linkTextField.text?.isEmpty == true ? true : false
   }
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
