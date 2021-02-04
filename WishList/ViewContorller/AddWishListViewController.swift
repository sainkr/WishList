//
//  AddWishListViewController.swift
//  WishList
//
//  Created by 홍승아 on 2021/01/28.
//

import UIKit
import Firebase
import FirebaseStorage

class AddWishListViewController: UIViewController{
    
    let db =  Database.database().reference().child("myWhisList")
    let storage = Storage.storage()
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var tagSelectTextField: UITextField!
    @IBOutlet weak var siteTextField: UITextField!
    @IBOutlet var gestureRecognizer: UITapGestureRecognizer!
    var url: String = ""
    
    
    // var message = ["# 향수","# 딥디크","# 에어팟 맥스","# 아이패드","# 매직 마우스"]
    
    var tageselectViewController: TagSelectViewController!
    var photoselectViewController: PhotoAddViewController!
    
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
        var imgURL: [String] = []
        for i in 0..<photoViewModel.photos.count{
            let image: UIImage = photoViewModel.photos[i].image
            let data = image.jpegData(compressionQuality: 0.1)!
            let timestamp: Double = Date().timeIntervalSince1970.rounded()
            let metaData = StorageMetadata()
            metaData.contentType = "image/png"
            let imageName = "\(timestamp)\(i)"
            storage.reference().child(imageName).putData(data, metadata: metaData) { (data, err) in
                if let error = err {
                    print("--> error1:\(error.localizedDescription)")
                }
                self.storage.reference().child(imageName).downloadURL { [self] (url, err) in
                    print("url fetch")
                    if let error = err {
                        print("--> error2:\(error.localizedDescription)")
                    }
                    else {
                        // print("--> url : \(url?.absoluteString)")
                        print("---> \(i)")
                        imgURL.append(url!.absoluteString)
                        if imgURL.count == photoViewModel.photos.count  {
                            print("--->imgurl..length : \(imgURL.count)")
                            // db.childByAutoId().setValue([ "timestamp" : timestamp, "name": nameTextField.text , "tag" : tagViewModel.tags, "img" : imgURL])
                        }
                    }
                }
            }
        }
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
            let tagText = tag
            tageselectViewController.tagViewModel.addTag(tagText)
            tageselectViewController.collectionView.reloadData()
            
            tagSelectTextField.text = ""
        }
        return true
    }
}





