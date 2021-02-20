//
//  AddWishListViewController.swift
//  WishList
//
//  Created by 홍승아 on 2021/01/28.
//

import UIKit
import GoogleMaps
import GooglePlaces

class AddWishListViewController: UIViewController, GMSAutocompleteViewControllerDelegate {
    
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var tagSelectTextField: UITextField!
    @IBOutlet weak var linkTextField: UITextField!
    @IBOutlet var gestureRecognizer: UITapGestureRecognizer!
    @IBOutlet weak var bar: UINavigationBar!
    @IBOutlet weak var memoTextView: UITextView!
    @IBOutlet weak var placeTextField: UITextField!
    @IBOutlet weak var placeMapView: GMSMapView!
    
    var selectTagViewController: SelectTagViewController!
    var selectPhotoViewController: AddPhotoViewController!
    
    let wishViewModel = WishViewModel()
    let tagViewModel = TagViewModel()
    let photoViewModel = PhotoViewModel()
    
    let autocompleteController = GMSAutocompleteViewController()

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
         
         let camera = GMSCameraPosition.camera(withLatitude: -33.86, longitude: 151.20, zoom: 6.0)
        placeMapView.camera = camera
         
         let marker = GMSMarker()
         marker.position = CLLocationCoordinate2D(latitude: -33.86, longitude: 151.20)
         marker.title = "Sydney"
         marker.snippet = "Australia"
         marker.map = placeMapView
        
        autocompleteController.delegate = self //딜리게이트
           
        placeTextField.delegate = self
        
        gestureRecognizer.cancelsTouchesInView = false
        setNavigationBar()
        
        if paramIndex > -1 {
            setContent()
        }
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
        print("---> 클릭")
        if textField == placeTextField {
            placeTextField.resignFirstResponder()
            print("---> 클릭")
            present(autocompleteController, animated: true, completion: nil)
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

extension AddWishListViewController { //해당 뷰컨트롤러를 익스텐션으로 딜리게이트를 달아준다.
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        print("--> Place name: \(String(describing: place.name))") //셀탭한 글씨출력
        
        // self.placeMapView.backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        
        let camera = GMSCameraPosition.camera(withLatitude: place.coordinate.latitude, longitude: place.coordinate.longitude, zoom: 6.0)
        let mapView = GMSMapView.map(withFrame: CGRect.zero, camera: camera)
       
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2D(latitude: place.coordinate.latitude, longitude: place.coordinate.longitude)
        marker.title = "place.name"
   
        marker.map = mapView
       
       placeMapView = mapView
       
     
        dismiss(animated: true, completion: nil)
    }
    
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        print(error.localizedDescription)
    }
    
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        dismiss(animated: true, completion: nil)
    }
    
}





