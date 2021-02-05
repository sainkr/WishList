//
//  AddWishListViewController.swift
//  WishList
//
//  Created by 홍승아 on 2021/01/28.
//

import UIKit


class AddWishListViewController: UIViewController{
    
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var tagSelectTextField: UITextField!
    @IBOutlet weak var linkTextField: UITextField!
    @IBOutlet var gestureRecognizer: UITapGestureRecognizer!

    var tageselectViewController: TagSelectViewController!
    var photoselectViewController: PhotoAddViewController!
    
    let wishViewModel = WishViewModel()
    let tagViewModel = TagViewModel()
    let photoViewModel = PhotoViewModel()
   
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "tag" {
            let destinationVC = segue.destination as? TagSelectViewController
            tageselectViewController = destinationVC
        } else if segue.identifier == "photo" {
            let destinationVC = segue.destination as? PhotoAddViewController
            photoselectViewController = destinationVC
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tagSelectTextField.delegate = self
        gestureRecognizer.cancelsTouchesInView = false
    }

    
    @IBAction func backButtonTapped(_ sender: Any){
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func doneButtonTapped(_ sender: Any){
        
        let timestamp = Date().timeIntervalSince1970.rounded()
        wishViewModel.addWish(Wish(timestamp: timestamp, name: self.nameTextField.text ?? "ghdtmddk", tag: tagViewModel.tags, content: "zzzz" , photo: self.photoViewModel.photos, link: self.linkTextField.text ?? "sainkr.kakao.com" , place: "cafe"))
        tagViewModel.resetTag()
        photoViewModel.resetPhoto()
        dismiss(animated: true, completion: nil)
    }
    
    // 탭 했을때, 키보드 내려옴
    @IBAction func tapBG(_ sender: Any) {
        nameTextField.resignFirstResponder()
        tagSelectTextField.resignFirstResponder()
        linkTextField.resignFirstResponder()
    }
    
    
    /* func textFieldDidBeginEditing(_ textField: UITextField) {
     let addWishListStoryboard = UIStoryboard.init(name: "AddWishList", bundle: nil)
     guard let addTagVC = addWishListStoryboard.instantiateViewController(identifier: "TagSelectViewController") as? TagSelectViewController else { return }
     addTagVC.modalPresentationStyle = .fullScreen
     
     present(addTagVC, animated: true, completion: nil)
     }*/
}
extension AddWishListViewController: UITextFieldDelegate, UICollectionViewDelegate{
    
    // textfield 엔터하면 append
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == tagSelectTextField{
            guard let tag = tagSelectTextField.text, tag.isEmpty == false else { return false }
            let tagText = tag
            tageselectViewController.tagViewModel.addTag(tagText)
            tageselectViewController.collectionView.reloadData()
            
            tagSelectTextField.text = ""
        }
        return true
    }
}





