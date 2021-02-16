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
    @IBOutlet weak var bar: UINavigationBar!
    @IBOutlet weak var memoTextView: UITextView!
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tagSelectTextField.delegate = self
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
    }
    
    @IBAction func doneButtonTapped(_ sender: Any){
        if paramIndex > -1{
            let timestamp = wishViewModel.wishs[paramIndex].timestamp
            print("---> update")
            wishViewModel.updateWish(paramIndex, Wish(timestamp: timestamp, name: self.nameTextField.text ?? "-", tag: tagViewModel.tags, tagString : tagViewModel.getTagString() ,content: self.memoTextView.text ?? "-" , photo: self.photoViewModel.photos, link: self.linkTextField.text ?? "-"))
        }
        else{
            let timestamp = Int(Date().timeIntervalSince1970.rounded())
            wishViewModel.addWish(Wish(timestamp: timestamp, name: self.nameTextField.text ?? "-", tag: tagViewModel.tags, tagString : tagViewModel.getTagString() ,content: self.memoTextView.text ?? "-" , photo: self.photoViewModel.photos, link: self.linkTextField.text ?? "-"))
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
            selectTagViewController.tagViewModel.addTag(tagText)
            selectTagViewController.collectionView.reloadData()
            
            tagSelectTextField.text = ""
        }
        return true
    }
}





