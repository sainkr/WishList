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
    
    var locationManager: CLLocationManager = CLLocationManager() // location manager
    var currentLocation: CLLocation! // 내 위치 저장
    
    var selectTagViewController: SelectTagViewController!
    var selectPhotoViewController: AddPhotoViewController!
    
    let wishViewModel = WishViewModel()
    let tagViewModel = TagViewModel()
    let photoViewModel = PhotoViewModel()

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
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        locationManager = manager
        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
            currentLocation = locationManager.location
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
         
        self.mapView.showsUserLocation = true
        self.currentLocation = locationManager.location
        self.mapView.setUserTrackingMode(.follow, animated: true)
        
        placeTextField.delegate = self
        
        gestureRecognizer.cancelsTouchesInView = false
        setNavigationBar()
        
        if paramIndex > -1 {
            setContent()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        let coordinate = CLLocationCoordinate2D(latitude: 37.52086970595338, longitude: 127.0227724313736)
        let span = MKCoordinateSpan(latitudeDelta: 0.003, longitudeDelta: 0.003)
        let region = MKCoordinateRegion(center: coordinate, span: span)
        self.mapView.setRegion(region, animated: true)

        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        annotation.title = "Apple 가로수길"
        self.mapView.addAnnotation(annotation)
        self.mapView.setUserTrackingMode(.follow, animated: true)
    }
    
    func setContent(){
        nameTextField.text = wishViewModel.wishs[paramIndex].name
        memoTextView.text = wishViewModel.wishs[paramIndex].content
        linkTextField.text = wishViewModel.wishs[paramIndex].link
        photoViewModel.setPhoto(wishViewModel.wishs[paramIndex].photo)
        tagViewModel.setTag(wishViewModel.wishs[paramIndex].tag)
    }

    func setNavigationBar(){
        bar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        bar.shadowImage = UIImage()
        bar.backgroundColor = UIColor.clear
    }
    
    @IBAction func backButtonTapped(_ sender: Any){
        dismiss(animated: true, completion: nil)
        
        tagViewModel.resetTag()
        photoViewModel.resetPhoto()
    }
    
    @IBAction func doneButtonTapped(_ sender: Any){
        if paramIndex > -1{
            let timestamp = wishViewModel.wishs[paramIndex].timestamp
            print("---> update")
            wishViewModel.updateWish(paramIndex, Wish(timestamp: timestamp, name: self.nameTextField.text ?? "-", tag: tagViewModel.tags, tagString : tagViewModel.getTagString(), content: self.memoTextView.text ?? "-" , photo: self.photoViewModel.photos , img: [] , link: self.linkTextField.text ?? "-"))
        }
        else{
            let timestamp = Int(Date().timeIntervalSince1970.rounded())
            wishViewModel.addWish(Wish(timestamp: timestamp, name: self.nameTextField.text ?? "-", tag: tagViewModel.tags, tagString : tagViewModel.getTagString() ,content: self.memoTextView.text ?? "-" , photo: self.photoViewModel.photos, img: [], link: self.linkTextField.text ?? "-"))
        }
        
        tagViewModel.resetTag()
        photoViewModel.resetPhoto()
        
        dismiss(animated: true, completion: nil)
    }
    
    // 탭 했을때, 키보드 내려옴
    @IBAction func tapBG(_ sender: Any) {
        nameTextField.resignFirstResponder()
        tagSelectTextField.resignFirstResponder()
        linkTextField.resignFirstResponder()
        placeTextField.resignFirstResponder()
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
            guard let tag = tagSelectTextField.text, tag.isEmpty == false else { return false }
            let tagText = tag
            selectTagViewController.tagViewModel.addTag(tagText)
            selectTagViewController.collectionView.reloadData()
            
            tagSelectTextField.text = ""
        }
        return true
    }
}
