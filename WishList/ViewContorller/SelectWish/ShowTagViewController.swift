//
//  ShowTagViewController.swift
//  WishList
//
//  Created by 홍승아 on 2021/02/08.
//

import UIKit
import SnapKit

class ShowTagViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    let wishViewModel = WishViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
    }
    
    private func setupView() {
        view.backgroundColor = UIColor.clear
        setupCollectionView()
    }
    
    private func setupCollectionView() {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.minimumLineSpacing = .zero
        flowLayout.minimumInteritemSpacing = 10
        flowLayout.scrollDirection = .horizontal
        flowLayout.sectionInset = .init(top: 10, left: 10, bottom: 10, right: 10)
        
        collectionView.setCollectionViewLayout(flowLayout, animated: false)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = UIColor.clear
        collectionView.register(ShowTagCell.self, forCellWithReuseIdentifier: "ShowTagCell")
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        collectionView.reloadData()
    }
    
}

extension ShowTagViewController: UICollectionViewDataSource{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return wishViewModel.tags.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ShowTagCell", for: indexPath) as? ShowTagCell else {
            return UICollectionViewCell()
        }
        
        let tag = wishViewModel.tags[indexPath.item]
        cell.configure(tag: tag)
        
        return cell
    }
}

extension ShowTagViewController : UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return ShowTagCell.fittingSize(availableHeight: 45, tag: wishViewModel.tags[indexPath.item])
    }
}

class ShowTagCell: UICollectionViewCell{
    static func fittingSize(availableHeight: CGFloat, tag: String) -> CGSize {
        let cell = ShowTagCell()
        cell.configure(tag: tag)
        let targetSize = CGSize(width: UIView.layoutFittingCompressedSize.width, height: availableHeight)
        return cell.contentView.systemLayoutSizeFitting(targetSize, withHorizontalFittingPriority: .fittingSizeLevel, verticalFittingPriority: .required)
    }
    
    private let titleBackView: UIView = UIView()
    private let titleLabel: UILabel = UILabel()
    
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
        
        contentView.addSubview(titleBackView)
        contentView.addSubview(titleLabel)
        
        titleBackView.snp.makeConstraints{(make) in
            make.top.equalToSuperview()
            make.trailing.equalToSuperview()
            make.leading.equalToSuperview().inset(7)
            make.bottom.equalToSuperview()
        }
        titleLabel.snp.makeConstraints { (make) in
            make.edges.equalTo(titleBackView).inset(15)
        }
    }
    
    func configure(tag: String) {
        titleLabel.text = tag
    }
}
