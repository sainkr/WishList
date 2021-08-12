//
//  AddTagCollectionViewCell.swift
//  WishList
//
//  Created by 홍승아 on 2021/08/11.
//

import UIKit

class AddTagCollectionViewCell: UICollectionViewCell{
  static let identifier = "AddTagCollectionViewCell"
  
  static func fittingSize(availableHeight: CGFloat, tag: String) -> CGSize {
    let cell = AddTagCollectionViewCell()
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
    configureView()
  }
  
  required init?(coder: NSCoder) {
    super.init(coder: coder)
  }
  
  private func configureView() {
    titleBackView.backgroundColor = #colorLiteral(red: 0.03379072994, green: 0, blue: 0.9970340133, alpha: 1)
    titleBackView.layer.cornerRadius = frame.height / 2
    titleLabel.textAlignment = .center
    titleLabel.textColor = .white
    titleLabel.font = UIFont.boldSystemFont(ofSize: UIFont.labelFontSize)
    
    deleteButton.setBackgroundImage(UIImage(systemName: "xmark.circle.fill"), for: UIControl.State.normal)
    deleteButton.tintColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
    
    deleteButton.addTarget(self, action:#selector(AddTagCollectionViewCell.deleteButtonTapped(_:)), for: .touchUpInside)
    
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
      make.top.equalToSuperview().inset(7)
      make.leading.equalTo(titleBackView.snp.trailing).offset(3)
      make.trailing.equalToSuperview()
      make.bottom.equalToSuperview().inset(7)
    }
  }
  
  func configure(tag: String) {
    titleLabel.text = tag
  }
  
  @objc func deleteButtonTapped(_ sender:UIButton!){
    deleteButtonTapHandler?()
  }
}
