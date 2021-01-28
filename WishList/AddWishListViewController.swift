//
//  AddWishListViewController.swift
//  WishList
//
//  Created by 홍승아 on 2021/01/28.
//

import UIKit

class AddWishListViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var tagSelectTextField: UITextField!
    @IBOutlet weak var siteTextField: UITextField!
    
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
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
  
        let addWishListStoryboard = UIStoryboard.init(name: "AddWishList", bundle: nil)
        guard let addTagVC = addWishListStoryboard.instantiateViewController(identifier: "TagSelectViewController") as? TagSelectViewController else { return }
        addTagVC.modalPresentationStyle = .fullScreen
        
        present(addTagVC, animated: true, completion: nil)
    }
}

