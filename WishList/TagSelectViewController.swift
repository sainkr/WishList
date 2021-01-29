//
//  TagSelectViewController.swift
//  WishList
//
//  Created by 홍승아 on 2021/01/28.
//

import UIKit
import SnapKit

class TagSelectViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var tableView: UITableView!
    
    var message = ["# 향수","# 딥디크","# 에어팟 맥스","# 아이패드","# 매직 마우스"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    private func setupView() {
         view.backgroundColor = .white
         setupCollectionView()
     }
     
     private func setupCollectionView() {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.minimumLineSpacing = .zero
        flowLayout.minimumInteritemSpacing = 10
        flowLayout.scrollDirection = .horizontal
        flowLayout.sectionInset = .init(top: 10, left: 16, bottom: 10, right: 16)
       
        collectionView.setCollectionViewLayout(flowLayout, animated: false)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = .white
        collectionView.register(TagCell.self, forCellWithReuseIdentifier: "TagCell")
     }
     
    

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }

    @IBAction func backButonTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func doneButtonTapped(_ sender: Any){
        dismiss(animated: true, completion: nil)
    }

}

extension TagSelectViewController: UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return message.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TagCell", for: indexPath) as? TagCell else {
            return UICollectionViewCell()
        }
        
        cell.configure(name: message[indexPath.item])
        
        return cell
    }
}

extension TagSelectViewController : UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
         return TagCell.fittingSize(availableHeight: 45, name: message[indexPath.item])
     }
}


class TagCell: UICollectionViewCell{
    static func fittingSize(availableHeight: CGFloat, name: String?) -> CGSize {
        let cell = TagCell()
        cell.configure(name: name)
        
        let targetSize = CGSize(width: UIView.layoutFittingCompressedSize.width, height: availableHeight)
        return cell.contentView.systemLayoutSizeFitting(targetSize, withHorizontalFittingPriority: .fittingSizeLevel, verticalFittingPriority: .required)
    }
    
    private let titleLabel: UILabel = UILabel()
     
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    override func layoutSubviews() {
       super.layoutSubviews()
       layer.cornerRadius = frame.height / 2
   }
   
   private func setupView() {
       backgroundColor = #colorLiteral(red: 0.03379072994, green: 0, blue: 0.9970340133, alpha: 1)
       titleLabel.textAlignment = .center
       titleLabel.textColor = .white
        titleLabel.font = UIFont.boldSystemFont(ofSize: UIFont.labelFontSize)
       
       contentView.addSubview(titleLabel)
       titleLabel.snp.makeConstraints { (make) in
           make.edges.equalToSuperview().inset(15)
       }
   }
   
   func configure(name: String?) {
       titleLabel.text = name
   }
}



