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
    @IBOutlet weak var siteTextField: UITextField!
    
    // var message = ["# 향수","# 딥디크","# 에어팟 맥스","# 아이패드","# 매직 마우스"]
    
    let tagViewModel = TagViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tagSelectTextField.delegate = self
    }

    
    @IBAction func backButtonTapped(_ sender: Any){
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func doneButtonTapped(_ sender: Any){
        dismiss(animated: true, completion: nil)
    }
    
    // 탭 했을때, 키보드 내려옴
    @IBAction func tapBG(_ sender: Any) {
        nameTextField.resignFirstResponder()
        tagSelectTextField.resignFirstResponder()
        siteTextField.resignFirstResponder()
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
            let tagText = Tag(tag: tag)
            tagViewModel.addTag(tagText)
            // collectionView.reloadData()
            
            tagSelectTextField.text = ""
        }
        return true
    }
}





