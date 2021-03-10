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
    @IBOutlet weak var bar: UINavigationBar!
    @IBOutlet weak var memoTextView: UITextView!
    @IBOutlet weak var placeTextField: UITextField!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var tagViewHeight: NSLayoutConstraint!
    @IBOutlet weak var linkdeleteButton: UIButton!
    @IBOutlet weak var placedeleteButton: UIButton!
    @IBOutlet weak var navigationBar: UINavigationBar!
    
    var selectTagViewController: SelectTagViewController!
    var selectPhotoViewController: AddPhotoViewController!
    
    let wishViewModel = WishViewModel()
    let tagViewModel = TagViewModel()
    let photoViewModel = PhotoViewModel()
    let placeViewModel = PlaceViewModel()

    let PlaceAddCompleteNotification: Notification.Name = Notification.Name("PlaceAddCompleteNotification")
    let WishAddCompleteNotification: Notification.Name = Notification.Name("WishAddCompleteNotification")
    let TagNotingNotification: Notification.Name = Notification.Name("TagNotingNotification")
    
    let annotation = MKPointAnnotation()
    
    // 받아온 데이터
    var paramIndex = -1
    var wishType = -1
    
    var wish: Wish!
   
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
        
        memoTextView.text = "간단 메모"
        memoTextView.textColor = .lightGray
        
        mapView.layer.cornerRadius = 15
        
        gestureRecognizer.cancelsTouchesInView = false
        setNavigationBar()
        
        navigationBar.titleTextAttributes = [ NSAttributedString.Key.font : UIFont.systemFont(ofSize: 18, weight: .bold) ]
        
        if paramIndex > -1 { // 글 수정
            setWish()
            setContent()
            navigationBar.topItem?.title = "Wish 수정"
        } else {
            if paramIndex == -2 { // 장소 추가 누른 경우
                setMap()
            }
            navigationBar.topItem?.title = "Wish 추가"
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(placeAddCompleteNotification(_:)), name: PlaceAddCompleteNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(tagNotingNotification(_:)), name: TagNotingNotification, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        if tagViewModel.tags.count == 0 {
            tagViewHeight.constant = 0
        }
    }
    
    func setWish(){
        if wishType == 0 { //favorite wish
            wish = wishViewModel.favoriteWishs()[paramIndex]
        } else { // my wish
            wish = wishViewModel.wishs[paramIndex]
        }
    }
    
    func setContent(){
        nameTextField.text = wish.name
        memoTextView.text = wish.content
        memoTextView.textColor = .black
        linkTextField.text = wish.link
        
        placeViewModel.addPlace(Place(name: wish.placeName, lat: wish.placeLat, lng: wish.placeLng ))
        photoViewModel.setPhoto(wish.photo)
        tagViewModel.setTag(wish.tag)
        
        setMap()
    }

    func setNavigationBar(){
        bar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        bar.shadowImage = UIImage()
        bar.backgroundColor = UIColor.clear
    }
    
    func resetData(){
        tagViewModel.resetTag()
        photoViewModel.resetPhoto()
        placeViewModel.resetPlace()
    }
    
    @IBAction func backButtonTapped(_ sender: Any){
        dismiss(animated: true, completion: nil)
        
        resetData()
    }
    
    @IBAction func doneButtonTapped(_ sender: Any){
        if nameTextField.text == "" {
            let alert = UIAlertController(title: nil, message: "이름을 입력하세요.", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "확인", style: UIAlertAction.Style.default, handler: nil)
            alert.addAction(okAction)
            self.present(alert, animated: true, completion: nil)
        }
        else if tagViewModel.tags.count == 0{
            let alert = UIAlertController(title: nil, message: "적어도 하나의 태그는 반드시 입력바랍니다.", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "확인", style: UIAlertAction.Style.default, handler: nil)
            alert.addAction(okAction)
            self.present(alert, animated: true, completion: nil)
        }
        else {
            if placeViewModel.place.name != "None"{
                placeViewModel.setPlace(nameTextField.text!)
            }
            
            if self.memoTextView.text == "간단 메모"{
                self.memoTextView.text = ""
            }
            
            if paramIndex > -1{
                let timestamp = wish.timestamp
                wishViewModel.updateWish(paramIndex, Wish(timestamp: timestamp, name: self.nameTextField.text ?? "-", tag: tagViewModel.tags, tagString : tagViewModel.getTagString(), content: self.memoTextView.text ?? "-" , photo: self.photoViewModel.photos , img: [] , link: self.linkTextField.text ?? "-", placeName: placeViewModel.place.name, placeLat: placeViewModel.place.lat, placeLng : placeViewModel.place.lng, favorite:  wishViewModel.wishs[paramIndex].favorite ))
            }
            else{
                let timestamp = Int(Date().timeIntervalSince1970.rounded())
                wishViewModel.addWish(Wish(timestamp: timestamp, name: self.nameTextField.text ?? "-", tag: tagViewModel.tags, tagString : tagViewModel.getTagString() ,content: self.memoTextView.text ?? "-" , photo: self.photoViewModel.photos, img: [], link: self.linkTextField.text ?? "-", placeName: placeViewModel.place.name, placeLat: placeViewModel.place.lat, placeLng : placeViewModel.place.lng, favorite: -1 ))
            }
            
            resetData()
            
            NotificationCenter.default.post(name: self.WishAddCompleteNotification, object: nil, userInfo: nil)
            
            dismiss(animated: true, completion: nil)
        }
    }
    
    @objc func placeAddCompleteNotification(_ noti: Notification){
        setMap()
        placedeleteButton.isHidden = false
    }
    
    @objc func tagNotingNotification(_ noti: Notification){
       tagViewHeight.constant = 0
    }
    
    func setMap(){
        if placeViewModel.place.name != "None" {
            let coordinate = CLLocationCoordinate2D(latitude: placeViewModel.place.lat, longitude: placeViewModel.place.lng)
            let span = MKCoordinateSpan(latitudeDelta: 0.003, longitudeDelta: 0.003)
            let region = MKCoordinateRegion(center: coordinate, span: span)
            self.mapView.setRegion(region, animated: true)
        
            annotation.coordinate = coordinate
            annotation.title = placeViewModel.place.name
            self.mapView.addAnnotation(annotation)
            
            if placeViewModel.place.name == ""{
                convertToAddressWith(coordinate: CLLocation(latitude: placeViewModel.place.lat, longitude: placeViewModel.place.lng))
            } else {
                self.placeTextField.text = placeViewModel.place.name
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
    
    @IBAction func linkDeleteButtonTapped(_ sender: Any) {
        linkTextField.text = ""
    }
    
    @IBAction func placeDeleteButtonTapped(_ sender: Any) {
        placeViewModel.resetPlace()
        placeTextField.text = ""
        setMap()
        mapView.removeAnnotation(annotation)
        placedeleteButton.isHidden = true
    }
    
    // 탭 했을때, 키보드 내려옴
    @IBAction func tapBG(_ sender: Any) {
        lowerKeyboard()
    }
    
    func lowerKeyboard() {
        nameTextField.resignFirstResponder()
        tagSelectTextField.resignFirstResponder()
        linkTextField.resignFirstResponder()
        placeTextField.resignFirstResponder()
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
            lowerKeyboard()
            
            let addWishListStoryboard = UIStoryboard.init(name: "AddWishList", bundle: nil)
            guard let searchPlaceVC = addWishListStoryboard.instantiateViewController(identifier: "SearchPlaceViewController") as? SearchPlaceViewController else { return }

            present(searchPlaceVC, animated: true, completion: nil)
        }
    }
    
    // textfield 엔터하면 append
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == tagSelectTextField{
            if tagViewModel.tags.count == 5 {
                let alert = UIAlertController(title: nil, message: "태그는 최대 5개까지 입력하실 수 있습니다.", preferredStyle: .alert)
                let okAction = UIAlertAction(title: "확인", style: UIAlertAction.Style.default, handler: nil)
                alert.addAction(okAction)
                self.present(alert, animated: true, completion: nil)
                
                tagSelectTextField.text = ""
                
                return false
            }
            
            guard let tag = tagSelectTextField.text, tag.isEmpty == false else { return false }
            
            let tagText = tag
            tagViewModel.addTag(tagText)
            
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
