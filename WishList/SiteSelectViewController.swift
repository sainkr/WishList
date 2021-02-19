//
//  SiteSelectViewController.swift
//  WishList
//
//  Created by 홍승아 on 2021/01/31.
//

import UIKit

class SiteSelectViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    let siteViewModel = SiteViewModel()
    
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
        flowLayout.minimumInteritemSpacing = 0
        flowLayout.scrollDirection = .horizontal
        flowLayout.sectionInset = .init(top: 10, left: 0, bottom: 10, right: 0)
        
        collectionView.setCollectionViewLayout(flowLayout, animated: false)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = .white
        collectionView.register(SiteCell.self, forCellWithReuseIdentifier: "SiteCell")
    }
     
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }

}

extension SiteSelectViewController: UICollectionViewDataSource{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return siteViewModel.sites.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SiteCell", for: indexPath) as? SiteCell else {
            return UICollectionViewCell()
        }
        
        let site = siteViewModel.sites[indexPath.item]
        cell.configure(site: site)
        
        cell.deleteButtonTapHandler = {
            self.siteViewModel.deleteSite(site)
            self.collectionView.reloadData()
        }
        
        return cell
    }
}

extension SiteSelectViewController : UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        // let width =
        return CGSize(width: 100, height: 100
        )
    }
}

class SiteCell: UICollectionViewCell{
    
    /*static func fittingSize(availableHeight: CGFloat, site: String) -> CGSize {
        let cell = SiteCell()
        cell.configure(site: site)
        let targetSize = CGSize(width: UIView.layoutFittingCompressedSize.width, height: availableHeight)
        return cell.contentView.systemLayoutSizeFitting(targetSize, withHorizontalFittingPriority: .fittingSizeLevel, verticalFittingPriority: .required)
    }*/
    
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
        deleteButton.setBackgroundImage(#imageLiteral(resourceName: "Image"), for: UIControl.State.normal)
        deleteButton.addTarget(self, action:#selector(TagCell.deleteButtonTapped(_:)), for: .touchUpInside)

        contentView.addSubview(titleBackView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(deleteButton)
        
        titleBackView.snp.makeConstraints{(make) in
            make.top.equalToSuperview()
            make.leading.equalToSuperview().inset(5)
            make.bottom.equalToSuperview()
        }
        titleLabel.snp.makeConstraints { (make) in
            make.edges.equalTo(titleBackView).inset(15)
        }
        deleteButton.snp.makeConstraints {(make) in
            make.width.equalTo(30)
            make.top.equalToSuperview().inset(9)
            make.leading.equalTo(titleBackView.snp.trailing).offset(3)
            make.trailing.equalToSuperview()
            make.bottom.equalToSuperview().inset(9)
        }
    }
    
    func configure(site: String) {
        titleLabel.text = site
    }
    
    @objc func deleteButtonTapped(_ sender:UIButton!){
        // print("---> 클릭")
        deleteButtonTapHandler?()
    }
    

}
