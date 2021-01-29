//
//  TagSelectViewController.swift
//  WishList
//
//  Created by 홍승아 on 2021/01/28.
//

import UIKit

class TagSelectViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var tableView: UITableView!
    
    var message = ["# 향수","# 에어팟","# 버즈","# 안녕하세요","# Work It!"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
         collectionView.delegate = self
         collectionView.dataSource = self
         /*
         // ios 10
         let flowLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout
         
         // self sizing 의 경우
        flowLayout?.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        */
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
        
        cell.updateUI(message: message[indexPath.item])
        
        return cell
    }
    
    
}

extension TagSelectViewController : UICollectionViewDelegateFlowLayout {

   // 플로우 레이아웃에서 각 아이템의 사이즈를 얻기위해 호출되는 함수로 아이템별로 사이즈를 지정할 수 있음
   // 이 메쏘드는 collectionView.estimatedItemSize 와 같음.
   func collectionView(_ collectionView: UICollectionView,
            layout collectionViewLayout: UICollectionViewLayout,
                sizeForItemAt indexPath: IndexPath) -> CGSize {
                
 
      // index에 따른 너비 리턴 예제
      // 문자열로 사이즈계산 : 폰트 크기를 사용한 방법
    let message = self.message[indexPath.item]
    let size = CGSize( width: self.view.frame.width, height: 1000)
    let options = NSStringDrawingOptions.usesFontLeading.union( .usesLineFragmentOrigin )
    let stringRect = NSString( string:message )
        .boundingRect(
            with: size,
              options:options,
            attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14)],
              context: nil
          )
    
    return CGSize( width: self.view.frame.width, height: stringRect.height )
      
      
      
      // 기본 사이즈 리턴 : layout에 sectionInset 등이 설정되어 있는 경우 해당 값 제외하고 리턴해야 함.
      // return CGSize(width:self.view.frame.width, height:80 )
   }

   /* // 섹션별 셀간의 간격을 조정
   func collectionView(_ collectionView: UICollectionView,
            layout collectionViewLayout: UICollectionViewLayout,
            minimumInteritemSpacingForSectionAt section: Int ) -> CGFloat {
      return CGFloat(10)
   } */
}


class TagCell: UICollectionViewCell{
    @IBOutlet weak var tagLabel: UILabel!
    @IBOutlet weak var cancelIamgeView: UIImageView!
    
    func updateUI(message: String){
        // thumbnailImageView.image = wish.
        tagLabel.text = message
    }
}

