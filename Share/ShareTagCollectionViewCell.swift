//
//  ShareTagCollectionViewCell.swift
//  Share
//
//  Created by 홍승아 on 2021/08/18.
//

import UIKit

class ShareTagCollectionViewCell: UICollectionViewCell{
  static let identifier = "ShareTagCollectionViewCell"
  
  static func fittingSize(availableHeight: CGFloat, tag: String) -> CGSize {
    let cell = ShareTagCollectionViewCell()
    cell.configure(tag: tag)
    let targetSize = CGSize(width: UIView.layoutFittingCompressedSize.width, height: availableHeight)
    return cell.contentView.systemLayoutSizeFitting(targetSize, withHorizontalFittingPriority: .fittingSizeLevel, verticalFittingPriority: .required)
  }
  
  private let titleBackView: UIView = UIView()
  private let titleLabel: UILabel = UILabel()
  private let deleteButton: UIButton = UIButton()
  
  var deleteButtonTapHandler: (() -> Void)?
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    configureView()
  }
  
  required init?(coder: NSCoder) {
    super.init(coder: coder)
    configureView()
  }
  
  private func configureView() {
    titleBackView.backgroundColor = #colorLiteral(red: 0.03379072994, green: 0, blue: 0.9970340133, alpha: 1)
    titleBackView.layer.cornerRadius = frame.height / 2
    titleLabel.textAlignment = .center
    titleLabel.textColor = .white
    titleLabel.font = UIFont.boldSystemFont(ofSize: UIFont.labelFontSize)
    
    deleteButton.setBackgroundImage(UIImage(systemName: "xmark.circle.fill"), for: UIControl.State.normal)
    deleteButton.tintColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
    
    deleteButton.addTarget(self, action:#selector(ShareTagCollectionViewCell.deleteButtonTapped(_:)), for: .touchUpInside)
    
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
