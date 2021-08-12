//
//  SelectTagCollectionViewCell.swift
//  WishList
//
//  Created by 홍승아 on 2021/08/11.
//

import UIKit

class SelectTagCollectionViewCell: UICollectionViewCell{
  static let identifier = "SelectTagCollectionViewCell"
  
  private let titleBackView: UIView = UIView()
  private let titleLabel: UILabel = UILabel()
  
  static func fittingSize(availableHeight: CGFloat, tag: String) -> CGSize {
    let cell = SelectTagCollectionViewCell()
    cell.configure(tag: tag)
    let targetSize = CGSize(width: UIView.layoutFittingCompressedSize.width, height: availableHeight)
    return cell.contentView.systemLayoutSizeFitting(targetSize, withHorizontalFittingPriority: .fittingSizeLevel, verticalFittingPriority: .required)
  }
  
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
