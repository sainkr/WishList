//
//  AddWishListViewController.swift
//  WishList
//
//  Created by 홍승아 on 2021/01/28.
//

import UIKit
import MapKit
import CoreLocation

class AddWishListViewController: UIViewController{
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var tagSelectTextField: UITextField!
    @IBOutlet weak var linkTextField: UITextField!
    @IBOutlet var gestureRecognizer: UITapGestureRecognizer!
    @IBOutlet weak var memoTextView: UITextView!
    @IBOutlet weak var placeTextField: UITextField!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var tagViewHeight: NSLayoutConstraint!
    @IBOutlet weak var linkdeleteButton: UIButton!
    @IBOutlet weak var placedeleteButton: UIButton!
    @IBOutlet weak var navigationBar: UINavigationBar!
    
    var selectTagViewController: SelectTagViewController!
    var selectPhotoViewController: AddPhotoViewController!
    
    let wishListViewModel = WishListViewModel()
    let wishViewModel = WishViewModel()
    
    let PlaceAddCompleteNotification: Notification.Name = Notification.Name("PlaceAddCompleteNotification")
    let WishAddCompleteNotification: Notification.Name = Notification.Name("WishAddCompleteNotification")
    let TagNotingNotification: Notification.Name = Notification.Name("TagNotingNotification")
    
    let annotation = MKPointAnnotation()
    
    // 받아온 데이터
    var wishType: WishType = .wishAdd
    var wishFavoriteType: WishFavoriteType = .mywish
    var selectIndex: Int = -1
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "tag" {
            let destinationVC = segue.destination as? SelectTagViewController
            selectTagViewController = destinationVC
        } else if segue.identifier == "photo" {
            let destinationVC = segue.destination as? AddPhotoViewController
            selectPhotoViewController = destinationVC
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        memoTextView.delegate = self
        placeTextField.delegate = self
        tagSelectTextField.delegate = self
        
        if wishType == .wishUpdate { // 글 수정
            setWish() // favorite인지 일반인지
            navigationBar.topItem?.title = "Wish 수정"
        } else {
            navigationBar.topItem?.title = "Wish 추가"
            if wishType == .wishPlaceAdd { // 장소 추가 누른 경우
                setMap()
            }else{
                wishViewModel.resetWish()
            }
        }
    
        setView()
        
        NotificationCenter.default.addObserver(self, selector: #selector(placeAddCompleteNotification(_:)), name: PlaceAddCompleteNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(tagNotingNotification(_:)), name: TagNotingNotification, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        if wishViewModel.wish.tag.count == 0 {
            tagViewHeight.constant = 0
        }
    }
}

extension AddWishListViewController{
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
    }
    
    func setWish(){
        /*if wishFavoriteType == .favoriteWish { //favorite wish
            wish = wishListViewModel.favoriteWishs[selectIndex]
        } else { // my wish
            wish = wishListViewModel.wishList[selectIndex]
        }*/
        
        setContent()
    }
    
    func setContent(){
        nameTextField.text = wishViewModel.wish.name
        memoTextView.text = wishViewModel.wish.content
        memoTextView.textColor = .black
        linkTextField.text = wishViewModel.wish.link
        
        wishViewModel.addPlace(Place(name: wishViewModel.wish.placeName, lat: wishViewModel.wish.placeLat, lng: wishViewModel.wish.placeLng))
        setMap()
    }
    
    func setMap(){
        if wishViewModel.wish.placeName != "None" {
            let coordinate = CLLocationCoordinate2D(latitude: wishViewModel.wish.placeLat , longitude: wishViewModel.wish.placeLng)
            let span = MKCoordinateSpan(latitudeDelta: 0.003, longitudeDelta: 0.003)
            let region = MKCoordinateRegion(center: coordinate, span: span)
            self.mapView.setRegion(region, animated: true)
            
            annotation.coordinate = coordinate
            annotation.title = wishViewModel.wish.placeName
            self.mapView.addAnnotation(annotation)
            
            if wishViewModel.wish.placeName == ""{
                convertToAddressWith(coordinate: CLLocation(latitude: wishViewModel.wish.placeLat, longitude: wishViewModel.wish.placeLng))
            } else {
                self.placeTextField.text = wishViewModel.wish.placeName
            }
        }
    }
    
    func convertToAddressWith(coordinate: CLLocation){
        let geoCoder = CLGeocoder()
        let locale = Locale(identifier: "Ko-kr") //원하는 언어의 나라 코드를 넣어주시면 됩니다.
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
    @objc func placeAddCompleteNotification(_ noti: Notification){
        setMap()
        placedeleteButton.isHidden = false
    }
    
    @objc func tagNotingNotification(_ noti: Notification){
        tagViewHeight.constant = 0
    }
    
    func addAlert(message: String, title: String){
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: title , style: UIAlertAction.Style.default, handler: nil)
        alert.addAction(okAction)
        self.present(alert, animated: true, completion: nil)
    }
}

// IBAction
extension AddWishListViewController{
    @IBAction func backButtonTapped(_ sender: Any){
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func doneButtonTapped(_ sender: Any){
        if nameTextField.text == "" {
            addAlert(message:"이름을 입력하세요." , title: "확인")
        }
        else if wishViewModel.wish.tag.count == 0{
            addAlert(message:"적어도 하나의 태그는 반드시 입력바랍니다." , title: "확인")
        }
        else {
            if wishViewModel.wish.placeName != "None"{
                wishViewModel.setPlace(nameTextField.text!)
            }
            if self.memoTextView.text == "간단 메모"{
                self.memoTextView.text = ""
            }
            
            if wishType == .wishUpdate{
                let updateWish = wishViewModel.createWish(timestamp: wishViewModel.wish.timestamp, name: self.nameTextField.text ?? "-", memo: self.memoTextView.text ?? "-", tags: wishViewModel.wish.tag, url: self.linkTextField.text ?? "-", photo: wishViewModel.wish.photo, place: Place(name: wishViewModel.wish.placeName, lat: wishViewModel.wish.placeLat, lng: wishViewModel.wish.placeLng), favorite: wishListViewModel.wishList[selectIndex].favorite)
                
                wishListViewModel.updateWish(selectIndex, updateWish)
            }
            else{
                let addWish = wishViewModel.createWish(timestamp: Int(Date().timeIntervalSince1970.rounded()), name: self.nameTextField.text ?? "-", memo: self.memoTextView.text ?? "-", tags: wishViewModel.wish.tag, url: self.linkTextField.text ?? "-", photo: wishViewModel.wish.photo, place: Place(name: wishViewModel.wish.placeName, lat: wishViewModel.wish.placeLat, lng: wishViewModel.wish.placeLng), favorite: -1)
                wishListViewModel.addWish(addWish)
            }
            
            // MapVC로 보낸다
            NotificationCenter.default.post(name: self.WishAddCompleteNotification, object: nil, userInfo: nil)
            
            dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func linkDeleteButtonTapped(_ sender: Any) {
        linkTextField.text = ""
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
        if linkTextField.text?.isEmpty == false{
            linkdeleteButton.isHidden = false
        } else {
            linkdeleteButton.isHidden = true
        }
    }
    @IBAction func linkTextFiledDidEnd(_ sender: Any) {
        if linkTextField.text?.isEmpty == true {
            linkdeleteButton.isHidden = true
        }
    }
}

extension AddWishListViewController: UITextFieldDelegate, UICollectionViewDelegate{
    // textfield 클릭하면
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == placeTextField {
            view.endEditing(true)
            
            let addWishListStoryboard = UIStoryboard.init(name: "AddWishList", bundle: nil)
            guard let searchPlaceVC = addWishListStoryboard.instantiateViewController(identifier: "SearchPlaceViewController") as? SearchPlaceViewController else { return }
            
            present(searchPlaceVC, animated: true, completion: nil)
        }
    }
    
    // textfield 엔터하면 append
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == tagSelectTextField{
            if wishViewModel.wish.tag.count == 5 {
                let alert = UIAlertController(title: nil, message: "태그는 최대 5개까지 입력하실 수 있습니다.", preferredStyle: .alert)
                let okAction = UIAlertAction(title: "확인", style: UIAlertAction.Style.default, handler: nil)
                alert.addAction(okAction)
                self.present(alert, animated: true, completion: nil)
                
                tagSelectTextField.text = ""
                
                return false
            }
            
            guard let tag = tagSelectTextField.text, tag.isEmpty == false else { return false }
            
            let tagText = tag
            wishViewModel.addTag(tagText)
      
            if tagViewHeight.constant == 0 {
                tagViewHeight.constant = 65
            }
            
            self.selectTagViewController.collectionView.reloadData()
            
            tagSelectTextField.text = ""
        }
        return true
    }
}

extension AddWishListViewController: UITextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = ""
            textView.textColor = UIColor.black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "간단 메모"
            textView.textColor = UIColor.lightGray
            
            let newPosition = textView.beginningOfDocument
            textView.selectedTextRange = textView.textRange(from: newPosition, to: newPosition)
        }
    }
}
