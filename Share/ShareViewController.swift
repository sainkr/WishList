//
//  ShareViewController.swift
//  Share
//
//  Created by 홍승아 on 2021/03/08.
//

import UIKit
import Social
import MobileCoreServices

import Firebase
import FirebaseStorage

class ShareViewController: UIViewController{
  
  @IBOutlet weak var nameTextField: UITextField!
  @IBOutlet weak var tagTextField: UITextField!
  @IBOutlet weak var tagCollectionView: UICollectionView!
  @IBOutlet weak var memoTextView: UITextView!
  @IBOutlet weak var linkTextField: UITextField!
  
  private var tagViewModel = TagViewModel()
  private var currentURL: String = ""
  
  override func viewDidLoad() {
    super.viewDidLoad()
    confgiureView()
    getLink()
    setupCollectionView()
  }
  
  @IBAction func cancelButtonTapped(_ sender: Any) {
    self.extensionContext!.cancelRequest(withError: NSError(domain: "com.domain.name", code: 0, userInfo: nil))
  }
  
  @IBAction func doneButtonTapped(_ sender: Any) {
    if nameTextField.text == "" {
      addAlert(message:"이름을 입력하세요." , title: "확인")
      return
    }
    if tagViewModel.isNotExistTag() {
      addAlert(message:"적어도 한 개의 태그를 입력하세요." , title: "확인")
      return
    }
    saveWish()
    dismiss(animated: true){
      self.extensionContext!.completeRequest(returningItems: nil, completionHandler: nil)
    }
  }
}

extension ShareViewController {
  private func confgiureView(){
    tagTextField.delegate = self
    memoTextView.delegate = self
    memoTextView.text = "간단 메모"
    memoTextView.textColor = .lightGray
  }
  
  private func getLink(){
    if let item = extensionContext?.inputItems.first as? NSExtensionItem {
      if let attachments = item.attachments {
        for attachment: NSItemProvider in attachments {
          if attachment.hasItemConformingToTypeIdentifier("public.url") {
            attachment.loadItem(forTypeIdentifier: "public.url", options: nil, completionHandler: { (url, error) in
              if let shareURL = url as? NSURL {
                DispatchQueue.main.async {
                  self.currentURL = shareURL.absoluteString!
                  self.linkTextField.text = self.currentURL
                }
              }
            })
          }
        }
      }
    }
  }
  
  private func setupCollectionView() {
    let flowLayout = UICollectionViewFlowLayout()
    flowLayout.minimumLineSpacing = .zero
    flowLayout.minimumInteritemSpacing = 0
    flowLayout.scrollDirection = .horizontal
    flowLayout.sectionInset = .init(top: 10, left: 0, bottom: 10, right: 0)
    tagCollectionView.setCollectionViewLayout(flowLayout, animated: false)
    tagCollectionView.delegate = self
    tagCollectionView.dataSource = self
    tagCollectionView.backgroundColor = UIColor.clear
    tagCollectionView.register(AddTagCollectionViewCell.self, forCellWithReuseIdentifier: AddTagCollectionViewCell.identifier)
  }
  
  private func addAlert(message: String, title: String){
    let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
    let okAction = UIAlertAction(title: title , style: UIAlertAction.Style.default, handler: nil)
    alert.addAction(okAction)
    self.present(alert, animated: true, completion: nil)
  }
  
  private func saveWish(){
    let memoTextViewText = memoTextView.text == "간단 메모" ? "" : memoTextView.text ?? ""
    let wish = Wish(timestamp: Int(Date().timeIntervalSince1970.rounded()), name: nameTextField.text ?? "", tag: tagViewModel.tags, memo: memoTextViewText, img: [], imgURL: [], link: currentURL, place: nil, favorite: false)
    FirebaseApp.configure()
    DataBaseManager.shared.saveWish(wish)
  }
}

// MARK:- UICollectionViewDataSource
extension ShareViewController: UICollectionViewDataSource {
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return tagViewModel.tagsCount
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: AddTagCollectionViewCell.identifier, for: indexPath) as? AddTagCollectionViewCell else {
      return UICollectionViewCell()
    }
    cell.configureTitleLabelText(tag: tagViewModel.tag(indexPath.item))
    cell.deleteButtonTapHandler = {
      self.tagViewModel.removeTag(indexPath.item)
      self.tagCollectionView.reloadData()
    }
    return cell
  }
}

// MARK:- UICollectionViewDelegateFlowLayout
extension ShareViewController : UICollectionViewDelegateFlowLayout {
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    return AddTagCollectionViewCell.fittingSize(availableHeight: 45, tag: tagViewModel.tag(indexPath.item))
  }
}

// MARK:- UICollectionViewDelegateFlowLayout
extension ShareViewController: UITextFieldDelegate {
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    if textField == tagTextField {
      guard let tag = tagTextField.text, tag.isEmpty == false else { return false }
      tagViewModel.addTag(tag)
      tagTextField.text = ""
      tagCollectionView.reloadData()
    }
    return true
  }
}

// MARK:- UITextViewDelegate
extension ShareViewController: UITextViewDelegate {
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
