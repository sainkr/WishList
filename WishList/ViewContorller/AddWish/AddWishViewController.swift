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
  @IBOutlet weak var tagViewHeight: NSLayoutConstraint!
  
  static let identifier = "AddWishViewController"
  var addTagViewController: AddTagViewController!
  var addPhotoViewController: AddPhotoViewController!
  
  let wishViewModel = WishViewModel()
  
  let PlaceAddCompleteNotification: Notification.Name = Notification.Name("PlaceAddCompleteNotification")
  let WishAddCompleteNotification: Notification.Name = Notification.Name("WishAddCompleteNotification")
  let TagNotingNotification: Notification.Name = Notification.Name("TagNotingNotification")
  
  let annotation = MKPointAnnotation()
  
  var wishType: WishType = .wishAdd
  var index: Int = 0
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "tag" {
      let destinationVC = segue.destination as? AddTagViewController
      addTagViewController = destinationVC
    } else if segue.identifier == "photo" {
      let destinationVC = segue.destination as? AddPhotoViewController
      addPhotoViewController = destinationVC
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    memoTextView.delegate = self
    placeTextField.delegate = self
    tagSelectTextField.delegate = self
    setView()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(true)
    NotificationCenter.default.addObserver(self, selector: #selector(placeAddCompleteNotification(_:)), name: PlaceAddCompleteNotification, object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(tagNotingNotification(_:)), name: TagNotingNotification, object: nil)
    if wishViewModel.tags.count == 0 {
      tagViewHeight.constant = 0
    }
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(true)
    NotificationCenter.default.removeObserver(self)
  }
}

extension AddWishViewController{
  func setView(){
    memoTextView.text = "간단 메모"
    memoTextView.textColor = .lightGray
    mapView.layer.cornerRadius = 15
    mapView.showsUserLocation = true
    mapView.setUserTrackingMode(.follow, animated: true)
    gestureRecognizer.cancelsTouchesInView = false
    navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
    navigationBar.shadowImage = UIImage()
    navigationBar.backgroundColor = UIColor.clear
    navigationBar.titleTextAttributes = [ NSAttributedString.Key.font : UIFont.systemFont(ofSize: 18, weight: .bold) ]
    navigationBar.topItem?.title = wishType == .wishUpdate ? "Wish 수정" : "Wish 추가"
    setContent()
  }
  
  func setContent(){
    if wishType == .wishUpdate{
      let wish = wishViewModel.wishs[index]
      nameTextField.text = wish.name
      memoTextView.text = wish.memo.count > 0 ? wish.memo : "간단 메모"
      memoTextView.textColor = wish.memo.count > 0 ? .black : .lightGray
      linkTextField.text = wish.link
      wishViewModel.setTag(tag: wish.tag)
      wishViewModel.setImage(img: wish.img)
      wishViewModel.setPlace(place: wish.place)
    }
    setMap()
  }
  
  func setMap(){
    guard let place = wishViewModel.place else { return }
    let coordinate = CLLocationCoordinate2D(latitude: place.lat , longitude: place.lng)
    let span = MKCoordinateSpan(latitudeDelta: 0.003, longitudeDelta: 0.003)
    let region = MKCoordinateRegion(center: coordinate, span: span)
    self.mapView.setRegion(region, animated: true)
    annotation.coordinate = coordinate
    annotation.title = place.name
    self.mapView.addAnnotation(annotation)
    if place.name == ""{
      convertToAddressWith(coordinate: CLLocation(latitude: place.lat, longitude: place.lng))
    } else {
      self.placeTextField.text = place.name
    }
  }
  
  func convertToAddressWith(coordinate: CLLocation){
    let geoCoder = CLGeocoder()
    let locale = Locale(identifier: "Ko-kr")
    geoCoder.reverseGeocodeLocation(coordinate, preferredLocale: locale, completionHandler: {(placemarks, error) in
      if let address: [CLPlacemark] = placemarks {
        if let name: String = address.last?.name {
          DispatchQueue.main.async {
            self.placeTextField.text = name
          }
        }
      }
    })
  }
  
  // Notifi
  @objc func placeAddCompleteNotification(_ noti: Notification){ // delegate로 바꿀것
    setMap()
    placedeleteButton.isHidden = false
  }
  
  @objc func tagNotingNotification(_ noti: Notification){ // delegate로 바꿀것
    tagViewHeight.constant = 0
  }
  
  func addAlert(message: String, title: String){
    let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
    let okAction = UIAlertAction(title: title , style: UIAlertAction.Style.default, handler: nil)
    alert.addAction(okAction)
    self.present(alert, animated: true, completion: nil)
  }
}

// MARK:- IBAction
extension AddWishViewController{
  @IBAction func backButtonTapped(_ sender: Any){
    wishViewModel.resetData()
    dismiss(animated: true, completion: nil)
  }
  
  @IBAction func doneButtonTapped(_ sender: Any){
    if nameTextField.text == "" {
      addAlert(message:"이름을 입력하세요." , title: "확인")
    }
    let name = nameTextField.text
    let memo = memoTextView.text == "간단 메모" ? "" : memoTextView.text
    let link = linkTextField.text
    
    if wishType == .wishUpdate{
      let wish = wishViewModel.wishs[index]
      let updateWish = wishViewModel.createWish(
        timestamp: wish.timestamp,
        name: name ?? "-",
        memo: memo ?? "-",
        link: link ?? "-",
        favorite: wish.favorite)
      wishViewModel.updateWish(index, updateWish)
     }else {
      let addWish = wishViewModel.createWish(
        timestamp: Int(Date().timeIntervalSince1970.rounded()),
        name: name ?? "-",
        memo: memo ?? "-",
        link: link ?? "-",
        favorite: -1)
      wishViewModel.addWish(addWish)
     }
    
    // MapVC로 보낸다
    NotificationCenter.default.post(name: self.WishAddCompleteNotification, object: nil, userInfo: nil)
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
      let addWishListStoryboard = UIStoryboard.init(name: "Main", bundle: nil)
      guard let searchPlaceVC = addWishListStoryboard.instantiateViewController(identifier: SearchPlaceViewController.identifier) as? SearchPlaceViewController else { return }
      present(searchPlaceVC, animated: true, completion: nil)
    }
  }
  
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    if textField == tagSelectTextField{
      guard let tag = tagSelectTextField.text, tag.isEmpty == false else { return false }
      wishViewModel.addTag(tag: tag)
      if tagViewHeight.constant == 0 {
        tagViewHeight.constant = 65
      }
      self.addTagViewController.collectionView.reloadData()
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
