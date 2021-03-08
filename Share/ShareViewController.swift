//
//  ShareViewController.swift
//  Share
//
//  Created by 홍승아 on 2021/03/08.
//

import UIKit
import Social
import MobileCoreServices

class ShareViewController: UIViewController{
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var tagTextField: UITextField!
    @IBOutlet weak var tagCollectionView: UICollectionView!
    @IBOutlet weak var memoTextView: UITextView!
    @IBOutlet weak var linkTextField: UITextField!
    @IBOutlet weak var tagCollectionViewHeight: NSLayoutConstraint!
    
    var tags: [String] = []
    var currentURL: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tagCollectionViewHeight.constant = 0
        tagTextField.delegate = self
        memoTextView.delegate = self
        
        memoTextView.text = "간단 메모"
        memoTextView.textColor = .lightGray
        
        getLink()
        setupCollectionView()
    }
    
    private func getLink(){
        if let item = extensionContext?.inputItems.first as? NSExtensionItem {
            if let attachments = item.attachments {
                for attachment: NSItemProvider in attachments {
                    if attachment.hasItemConformingToTypeIdentifier("public.url") {
                        attachment.loadItem(forTypeIdentifier: "public.url", options: nil, completionHandler: { (url, error) in
                            if let shareURL = url as? NSURL {
                                // Do stuff with your URL now.
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
        tagCollectionView.register(ShareTagCell.self, forCellWithReuseIdentifier: "ShareTagCell")
    }
    
    @IBAction func cancelButtonTapped(_ sender: Any) {
        self.extensionContext!.cancelRequest(withError: NSError(domain: "com.domain.name", code: 0, userInfo: nil))
    }
    
    @IBAction func doneButtonTapped(_ sender: Any) {
        if nameTextField.text == "" {
            nameTextField.placeholder = "이름을 입력 해주세요 !!! "
            return
        }
        
        if tags.count == 0 {
            tagTextField.placeholder = "태그는 최소 1개 입력 해주세요 !"
            return
        }
        
        let defaults = UserDefaults(suiteName: "group.com.sainkr.WishList")
        defaults?.set(nameTextField.text, forKey: "Name")
        defaults?.set(tags, forKey: "Tag")
        defaults?.set(memoTextView.text, forKey: "Memo")
        defaults?.set(currentURL, forKey: "URL")
        defaults?.synchronize()
        
        self.extensionContext!.completeRequest(returningItems: nil, completionHandler: nil)
    }
    
}

extension ShareViewController: UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return tags.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ShareTagCell", for: indexPath) as? ShareTagCell else {
            return UICollectionViewCell()
        }
        
        let tag = tags[indexPath.item]
        cell.configure(tag: tag)
        
        cell.deleteButtonTapHandler = {
            self.tags.remove(at: indexPath.item)
            self.tagCollectionView.reloadData()
            
            if self.tags.count == 0{
                self.tagCollectionViewHeight.constant = 0
            }
        }
        
        return cell
    }
}

extension ShareViewController : UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return ShareTagCell.fittingSize(availableHeight: 45, tag: tags[indexPath.item])
    }
}

extension ShareViewController: UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == tagTextField {
            if tags.count == 5 {
                tagTextField.text = ""
                return false
            }
            
            if tags.count == 0 {
                tagCollectionViewHeight.constant = 65
            }
            
            guard let tag = tagTextField.text, tag.isEmpty == false else { return false }
            tags.append(tag)
            tagTextField.text = ""
            tagCollectionView.reloadData()
        }
        
        return true
    }
}

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

class ShareTagCell: UICollectionViewCell{
    
    static func fittingSize(availableHeight: CGFloat, tag: String) -> CGSize {
        let cell = ShareTagCell()
        cell.configure(tag: tag)
        let targetSize = CGSize(width: UIView.layoutFittingCompressedSize.width, height: availableHeight)
        return cell.contentView.systemLayoutSizeFitting(targetSize, withHorizontalFittingPriority: .fittingSizeLevel, verticalFittingPriority: .required)
    }
    
    private let titleBackView: UIView = UIView()
    private let titleLabel: UILabel = UILabel()
    private let deleteButton: UIButton = UIButton()
    
    var deleteButtonTapHandler: (() -> Void )?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    private func setupView() {
        titleBackView.backgroundColor = #colorLiteral(red: 0.03379072994, green: 0, blue: 0.9970340133, alpha: 1)
        titleBackView.layer.cornerRadius = frame.height / 2
        titleLabel.textAlignment = .center
        titleLabel.textColor = .white
        titleLabel.font = UIFont.boldSystemFont(ofSize: UIFont.labelFontSize)
        
        deleteButton.setBackgroundImage(UIImage(systemName: "xmark.circle.fill"), for: UIControl.State.normal)
        deleteButton.tintColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        
        deleteButton.addTarget(self, action:#selector(ShareTagCell.deleteButtonTapped(_:)), for: .touchUpInside)

        titleBackView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        deleteButton.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(titleBackView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(deleteButton)
        
        titleBackView.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        titleBackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 5).isActive = true
        titleBackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
        
        titleLabel.topAnchor.constraint(equalTo: titleBackView.topAnchor).isActive = true
        titleLabel.bottomAnchor.constraint(equalTo: titleBackView.bottomAnchor).isActive = true
        titleLabel.leadingAnchor.constraint(equalTo: titleBackView.leadingAnchor, constant: 10).isActive = true
        titleLabel.trailingAnchor.constraint(equalTo: titleBackView.trailingAnchor, constant: -10).isActive = true
        
        deleteButton.widthAnchor.constraint(equalToConstant: 33).isActive = true
        
        deleteButton.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5).isActive = true
        deleteButton.leadingAnchor.constraint(equalTo: titleBackView.trailingAnchor, constant: 3).isActive = true
        deleteButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
        deleteButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -5).isActive = true
        
    }
    
    func configure(tag: String) {
        titleLabel.text = tag
    }
    
    @objc func deleteButtonTapped(_ sender:UIButton!){
        deleteButtonTapHandler?()
    }
}
