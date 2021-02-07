//
//  WishSelectViewController.swift
//  WishList
//
//  Created by 홍승아 on 2021/02/07.
//

import UIKit

class SelectWishViewController: UIViewController {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var bar: UINavigationBar!

    let wishListViewModel = WishViewModel()
    let tagViewModel = TagViewModel()
    
    var selectTagViewController = SelectTagViewController()
    
    var paramIndex: Int = 0
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setNavigationBar()
        
        var wish = wishListViewModel.wishs[paramIndex]
        
        self.nameLabel.text = wish.name
        self.contentLabel.text = wish.content
        tagViewModel.setTag(wish.tag)
    }
    
    func setNavigationBar(){
        bar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        bar.shadowImage = UIImage()
        bar.backgroundColor = UIColor.clear
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "tag" {
            let destinationVC = segue.destination as? SelectTagViewController
            selectTagViewController = destinationVC!
        }
    }
    
    @IBAction func backButtonTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func menuButtonTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func linkButtonTapped(_ sender: Any) {
    }
}
