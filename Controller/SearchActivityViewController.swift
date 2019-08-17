//
//  SearchActivityViewController.swift
//  cycle
//
//  Created by boy setiawan on 15/08/19.
//  Copyright © 2019 boy setiawan. All rights reserved.
//

import UIKit
import MapKit

class SearchActivityViewController : UITableViewController {

    var handleActivitySearchDelegate:HandleActivitySearch? = nil
    var matchingItems:[Activity] = []
}

protocol HandleActivitySearch {
    func dropActivity(activity:Activity)
    func cancelActivity()
}

extension SearchActivityViewController {
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedItem = matchingItems[indexPath.row]
        handleActivitySearchDelegate?.dropActivity(activity: selectedItem)
        dismiss(animated: true, completion: nil)
        
    }
}

extension SearchActivityViewController: UISearchBarDelegate {
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        handleActivitySearchDelegate?.cancelActivity()
    }
    
    
}

extension SearchActivityViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return matchingItems.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")!
        let selectedItem = matchingItems[indexPath.row]
        cell.textLabel?.text = selectedItem.activityID
        //cell.detailTextLabel?.text = ""
        cell.detailTextLabel?.text = selectedItem.activityID
        return cell
    }
}

extension SearchActivityViewController : UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchBarText = searchController.searchBar.text else { return }
        
        let kegiatan = Activity()
        
        kegiatan.searchActivity(activityID: searchBarText.uppercased()) { (activities) in
            
            self.matchingItems = activities
            print("\(activities)-\(searchBarText)")
            self.tableView.reloadData()
        }
        
        }
    }
    
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        if !searchController.isActive {
            print("Cancelled")
        }
        
    }

