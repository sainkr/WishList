//
//  WishSelectViewController.swift
//  WishList
//
//  Created by 홍승아 on 2021/02/07.
//

import UIKit
import Kingfisher
import MapKit
import CoreLocation
import NVActivityIndicatorView

class SelectWishViewController: UIViewController {
  static let identifier = "SelectWishViewController"
  
  @IBOutlet weak var nameLabel: UILabel!
  @IBOutlet weak var contentLabel: UILabel!
  @IBOutlet weak var bar: UINavigationBar!
  @IBOutlet weak var mapView: MKMapView!
  @IBOutlet weak var cancelButton: UIButton!
  @IBOutlet weak var menuButton: UIButton!
  @IBOutlet weak var linkButton: UIButton!
  @IBOutlet weak var tagCollectionView: UICollectionView!
  @IBOutlet weak var nameLabelTop: NSLayoutConstraint!
  @IBOutlet weak var mapViewHeight: NSLayoutConstraint!
  @IBOutlet weak var mapViewWidth: NSLayoutConstraint!
  
  private let wishViewModel = WishViewModel()
  private let ChangeImageNotification: Notification.Name = Notification.Name("ChangeImageNotification")
  private var selectImageViewController: SelectImageViewController!
  private var indicator: NVActivityIndicatorView!
  var index: Int = 0
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "image"{
      let destinationVC = segue.destination as! SelectImageViewController
      destinationVC.index = index
      selectImageViewController = destinationVC
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    configureNavigationBar()
    configureCollectionView()
    nameLabelTop.constant = view.bounds.width + 10
    indicator = NVActivityIndicatorView(frame: CGRect(
                                          x: view.bounds.width / 2 - 25,
                                          y: view.bounds.height / 2 - 25,
                                          width: 50,
                                          height: 50),
                                        type: .ballRotateChase,
                                        color: .white,
                                        padding: 0)
    view.addSubview(indicator)
    NotificationCenter.default.addObserver(self, selector: #selector(convertToUIImageComplete(_ :)), name: ChangeImageNotification, object: nil)
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(true)
    configureView()
    configureMapView()
    tagCollectionView.reloadData()
  }
}

extension SelectWishViewController{
  private func configureNavigationBar(){
    bar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
    bar.shadowImage = UIImage()
    bar.backgroundColor = UIColor.clear
  }
  
  private func configureView(){
    nameLabel.text = wishViewModel.name(index)
    contentLabel.text = wishViewModel.memo(index)
    if wishViewModel.imageType(index) == .uiImage || wishViewModel.imageType(index) == .url {
      cancelButton.tintColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
      menuButton.tintColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
    }else {
      cancelButton.tintColor = #colorLiteral(red: 0.1158123985, green: 0.1258583069, blue: 0.5349373817, alpha: 1)
      menuButton.tintColor = #colorLiteral(red: 0.1158123985, green: 0.1258583069, blue: 0.5349373817, alpha: 1)
    }
    if wishViewModel.link(index) == "" {
      linkButton.isHidden = true
    } else {
      linkButton.isHidden = false
    }
    if wishViewModel.place(index) == nil{
      mapView.isHidden = true
    } else {
      mapView.isHidden = false
      configureMapView()
    }
  }
  
  private func configureMapView(){
    let width = view.bounds.width
    mapViewWidth.constant = width - 20
    mapViewHeight.constant = (width - 20) * 3 / 4
    mapView.layer.cornerRadius = 15
    guard let place = wishViewModel.place(index) else { return }
    let coordinate = CLLocationCoordinate2D(latitude: place.lat, longitude: place.lng)
    let span = MKCoordinateSpan(latitudeDelta: 0.003, longitudeDelta: 0.003)
    let region = MKCoordinateRegion(center: coordinate, span: span)
    self.mapView.setRegion(region, animated: true)
    let annotation = MKPointAnnotation()
    annotation.coordinate = coordinate
    annotation.title = place.name
    self.mapView.addAnnotation(annotation)
  }
  
  private func configureCollectionView() {
    let flowLayout = UICollectionViewFlowLayout()
    flowLayout.minimumLineSpacing = .zero
    flowLayout.minimumInteritemSpacing = 10
    flowLayout.scrollDirection = .horizontal
    flowLayout.sectionInset = .init(top: 10, left: 10, bottom: 10, right: 10)
    
    tagCollectionView.setCollectionViewLayout(flowLayout, animated: false)
    tagCollectionView.backgroundColor = UIColor.clear
    tagCollectionView.register(SelectTagCollectionViewCell.self, forCellWithReuseIdentifier: SelectTagCollectionViewCell.identifier)
  }
  
  @objc func convertToUIImageComplete(_ noti: Notification){
    DispatchQueue.main.async {
      self.indicator.stopAnimating()
      self.presentAddWishListVC()
    }
  }
  
  private func presentAddWishListVC(){
    guard let addWishListVC = storyboard?.instantiateViewController(identifier: AddWishViewController.identifier) as? AddWishViewController else { return }
    addWishListVC.modalPresentationStyle = .fullScreen
    addWishListVC.wishType = .wishUpdate
    
    self.present(addWishListVC, animated: true, completion: nil)
  }
}

// MARK:- @IBAction
extension SelectWishViewController{
  @IBAction func linkButtonTapped(_ sender: Any) {
    //사파리로 링크열기
    guard let url = URL(string: wishViewModel.link(index)),
          UIApplication.shared.canOpenURL(url) else {
      let alert = UIAlertController(title: nil, message: "유효하지 않은 링크 입니다.", preferredStyle: UIAlertController.Style.alert)
      let okAction = UIAlertAction(title: "확인", style: .default, handler : nil )
      alert.addAction(okAction)
      present(alert, animated: true, completion: nil)
      return
    }
    UIApplication.shared.open(url, options: [:], completionHandler: nil)
  }
  
  @IBAction func backButtonTapped(_ sender: Any) {
    dismiss(animated: true, completion: nil)
  }
  
  @IBAction func menuButtonTapped(_ sender: Any) {
    // UIAlertController 초기화
    let actionsheetController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
    
    // UIAlertAction 설정
    let editWish = UIAlertAction(title: "수정", style: .default) { action in
      if !self.wishViewModel.image(self.index).isEmpty{
        self.presentAddWishListVC()
      }else {
        self.wishViewModel.changeUIImage(index: self.index)
        self.indicator.startAnimating()
      }
    }
    
    let deleteWish = UIAlertAction(title: "삭제", style: .destructive, handler: { action in
      self.wishViewModel.removeWish(self.index)
      self.dismiss(animated: true, completion: nil)
    })
    
    let actionCancel = UIAlertAction(title: "취소", style: .cancel, handler: nil)
    
    actionsheetController.addAction(editWish)
    actionsheetController.addAction(deleteWish)
    actionsheetController.addAction(actionCancel)
    
    self.present(actionsheetController, animated: true)
  }
}

// MARK:- TagCollectionView
extension SelectWishViewController: UICollectionViewDataSource{
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return wishViewModel.tags(index).count
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SelectTagCollectionViewCell.identifier, for: indexPath) as? SelectTagCollectionViewCell else {
      return UICollectionViewCell()
    }
    let tag = wishViewModel.tags(index)[indexPath.item]
    cell.configure(tag: tag)
    return cell
  }
}

extension SelectWishViewController: UICollectionViewDelegateFlowLayout {
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    return SelectTagCollectionViewCell.fittingSize(availableHeight: 45, tag: wishViewModel.tags(index)[indexPath.item])
  }
}

