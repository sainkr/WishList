//
//  Stie.swift
//  WishList
//
//  Created by 홍승아 on 2021/01/31.
//

import UIKit

class SiteManager {
    static let shared = SiteManager()
    
    var sites: [String] = []
    
    func addSite(_ site: String){
        sites.append(site)
    }
    
    func deleteSite(_ site: String){
        sites = sites.filter { $0 != site}
    }
    
}

class SiteViewModel {
    private let manager = SiteManager.shared
    
    var sites: [String]{
        return manager.sites
    }
    
    func addSite(_ site: String){
        manager.addSite(site)
    }
    
    func deleteSite(_ site: String){
        manager.deleteSite(site)
    }

}

