//
//  TagSelectViewController.swift
//  WishList
//
//  Created by 홍승아 on 2021/01/28.
//

import UIKit
import SnapKit

class AddTagViewController: UIViewController {
  @IBOutlet weak var tagCollectionView: UICollectionView!
  
  private let wishViewModel = WishViewModel()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    configureView()
    tagCollectionView.reloadData()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    tagCollectionView.reloadData()
  }
  
  private func configureView() {
    view.backgroundColor = UIColor.clear
    configureCollectionView()
  }
  
  private func configureCollectionView() {
    let flowLayout = UICollectionViewFlowLayout()
    flowLayout.minimumLineSpacing = .zero
    flowLayout.minimumInteritemSpacing = 0
    flowLayout.scrollDirection = .horizontal
    flowLayout.sectionInset = .init(top: 10, left: 0, bottom: 10, right: 0)
    
    tagCollectionView.setCollectionViewLayout(flowLayout, animated: false)
    tagCollectionView.backgroundColor = UIColor.clear
    tagCollectionView.register(AddTagCollectionViewCell.self, forCellWithReuseIdentifier: AddTagCollectionViewCell.identifier)
  }
}

extension AddTagViewController: UICollectionViewDataSource{
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return wishViewModel.tags(wishViewModel.wishsCount - 1).count
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: AddTagCollectionViewCell.identifier, for: indexPath) as? AddTagCollectionViewCell else {
      return UICollectionViewCell()
    }
    let tag = wishViewModel.tags(wishViewModel.wishsCount - 1)[indexPath.item]
    cell.configure(tag: tag)
    cell.deleteButtonTapHandler = {
      self.wishViewModel.removeTag(indexPath.item)
      self.tagCollectionView.reloadData()
    }
    return cell
  }
}

extension AddTagViewController: UICollectionViewDelegateFlowLayout {
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    return AddTagCollectionViewCell.fittingSize(availableHeight: 45, tag: wishViewModel.tags(wishViewModel.wishsCount - 1)[indexPath.item])
  }
}
