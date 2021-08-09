//
//  SearchPlaceViewController.swift
//  WishList
//
//  Created by 홍승아 on 2021/02/21.
//

import UIKit
import MapKit

class SearchPlaceViewController: UIViewController {
  static let identifier = "SearchPlaceViewController"
  private var searchCompleter = MKLocalSearchCompleter()
  private var searchResults = [MKLocalSearchCompletion]()
  
  @IBOutlet weak var searchBar: UISearchBar!
  @IBOutlet weak var searchResultTableView: UITableView!
  
  let wishViewModel = WishViewModel()

  var mapViewDelegate: MapViewDelegate?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.searchBar.showsCancelButton = true
    self.searchCompleter.delegate = self
    self.searchBar.becomeFirstResponder()
  }
}

extension SearchPlaceViewController: UISearchBarDelegate{
  func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
    if searchText == "" {
      searchResults.removeAll()
      searchResultTableView.reloadData()
    }
    searchCompleter.queryFragment = searchText
  }
  
  func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
    dismiss(animated: true, completion: nil)
  }
}

extension SearchPlaceViewController: MKLocalSearchCompleterDelegate  {
  func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
    searchResults = completer.results
    searchResultTableView.reloadData()
  }
  
  func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
    print("---> error : \(error)")
  }
}

extension SearchPlaceViewController: UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return searchResults.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard let cell = searchResultTableView.dequeueReusableCell(withIdentifier: "SearchPlaceCell", for: indexPath) as? SearchPlaceCell else { return UITableViewCell() }
    let searchResult = searchResults[indexPath.row]
    cell.updateUI(searchResult.title, searchResult.subtitle)
    return cell
  }
}

extension SearchPlaceViewController: UITableViewDelegate{
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let selectedResult = searchResults[indexPath.row]
    let searchRequest = MKLocalSearch.Request(completion: selectedResult)
    let search = MKLocalSearch(request: searchRequest)
    search.start { (response, error) in
      guard error == nil else {
        print("---> error : \(String(describing: error))")
        return
      }
      guard let placeMark = response?.mapItems[0].placemark else { return }
  
      self.mapViewDelegate?.mapViewUpdate(place: Place(name: selectedResult.title, lat: placeMark.coordinate.latitude, lng: placeMark.coordinate.longitude))
      self.dismiss(animated: true, completion: nil)
    }
  }
}

extension SearchPlaceViewController: UIScrollViewDelegate{
  func scrollViewDidScroll(_ scrollView: UIScrollView) {
    self.searchBar.resignFirstResponder()
  }
}

class SearchPlaceCell: UITableViewCell {
  @IBOutlet weak var placeLabel: UILabel!
  @IBOutlet weak var addressLabel: UILabel!
  
  func updateUI(_ place: String, _ address: String){
    placeLabel.text = place
    addressLabel.text = address
  }
}
