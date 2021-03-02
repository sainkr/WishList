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
        
        gestureRecognizer.cancelsTouchesInView = false
        setNavigationBar()
        
        if paramIndex > -1 {
            setContent()
        } else if paramIndex == -2 {
            setMap()
        }
        
        mapView.layer.cornerRadius = 15
       
        NotificationCenter.default.addObserver(self, selector: #selector(placeAddCompleteNotification(_:)), name: PlaceAddCompleteNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(tagNotingNotification(_:)), name: TagNotingNotification, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        if tagViewModel.tags.count == 0 {
            tagViewHeight.constant = 0
        }
    }
    
    func setContent(){
        nameTextField.text = wishViewModel.wishs[paramIndex].name
        memoTextView.text = wishViewModel.wishs[paramIndex].content
        linkTextField.text = wishViewModel.wishs[paramIndex].link
        
        placeViewModel.addPlace(Place(name: wishViewModel.wishs[paramIndex].placeName, lat: wishViewModel.wishs[paramIndex].placeLat, lng: wishViewModel.wishs[paramIndex].placeLng ))
        photoViewModel.setPhoto(wishViewModel.wishs[paramIndex].photo)
        tagViewModel.setTag(wishViewModel.wishs[paramIndex].tag)
        
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
            if paramIndex > -1{
                let timestamp = wishViewModel.wishs[paramIndex].timestamp
                print("---> update")
                wishViewModel.updateWish(paramIndex, Wish(timestamp: timestamp, name: self.nameTextField.text ?? "-", tag: tagViewModel.tags, tagString : tagViewModel.getTagString(), content: self.memoTextView.text ?? "-" , photo: self.photoViewModel.photos , img: [] , link: self.linkTextField.text ?? "-", placeName: placeViewModel.place.name, placeLat: placeViewModel.place.lat, placeLng : placeViewModel.place.lng, favorite:  wishViewModel.wishs[paramIndex].favorite ))
            }
            else{
                let timestamp = Int(Date().timeIntervalSince1970.rounded())
                wishViewModel.addWish(Wish(timestamp: timestamp, name: self.nameTextField.text ?? "-", tag: tagViewModel.tags, tagString : tagViewModel.getTagString() ,content: self.memoTextView.text ?? "-" , photo: self.photoViewModel.photos, img: [], link: self.linkTextField.text ?? "-", placeName: placeViewModel.place.name, placeLat: placeViewModel.place.lat, placeLng : placeViewModel.place.lng, favorite: -1 ))
                print("--> photos.count \(photoViewModel.photos.count)")
                print("--> tags.count \(tagViewModel.tags.count)")
            }
            
            resetData()
            
            NotificationCenter.default.post(name: self.WishAddCompleteNotification, object: nil, userInfo: nil)
            
            dismiss(animated: true, completion: nil)
        }
    }
    
    @objc func placeAddCompleteNotification(_ noti: Notification){
       setMap()
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
            
            self.placeTextField.text = placeViewModel.place.name
        }
    }
    
    @IBAction func linkDeleteButtonTapped(_ sender: Any) {
        linkTextField.text = ""
    }
    
    // 탭 했을때, 키보드 내려옴
    @IBAction func tapBG(_ sender: Any) {
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
            placeTextField.resignFirstResponder()
            
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
            selectTagViewController.tagViewModel.addTag(tagText)
            
            if tagViewHeight.constant == 0 {
                tagViewHeight.constant = 65
            }
            
            selectTagViewController.collectionView.reloadData()
            
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
