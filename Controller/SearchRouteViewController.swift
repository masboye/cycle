//
//  SearchRouteViewController.swift
//  cycle
//
//  Created by boy setiawan on 15/08/19.
//  Copyright © 2019 boy setiawan. All rights reserved.
//

import UIKit
import MapKit

class SearchRouteViewController : UITableViewController {

    var mapView: MKMapView? = nil
    var matchingItems:[MKMapItem] = []
}

extension SearchRouteViewController : UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let mapView = mapView,
            let searchBarText = searchController.searchBar.text else { return }
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = searchBarText
        request.region = mapView.region
        let search = MKLocalSearch(request: request)
        search.start { response, _ in
            guard let response = response else {
                return
            }
            
            self.matchingItems = response.mapItems
            self.tableView.reloadData()
        }
    }
    
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        print("Control")
        
    }
}
