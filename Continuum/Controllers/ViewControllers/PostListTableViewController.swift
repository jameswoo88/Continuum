//
//  PostListTableViewController.swift
//  Continuum
//
//  Created by James Chun on 5/11/21.
//  Copyright © 2021 trevorAdcock. All rights reserved.
//

import UIKit

class PostListTableViewController: UITableViewController {
    
    //MARK: - Outlet
    @IBOutlet weak var postSearchBar: UISearchBar!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var activityView: UIView!
    
    //MARK: - Properties
    var resultsArray: [SearchableRecord] = []
    var isSearching: Bool = false
    var dataSource: [SearchableRecord] {
        return isSearching ? resultsArray : PostController.sharedInstance.posts
    }

    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        postSearchBar.delegate = self
        performFullSync(completion: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        DispatchQueue.main.async {
            self.resultsArray = PostController.sharedInstance.posts
            self.performFullSync(completion: nil)
            self.tableView.reloadData() //JCHUN - Table view does not automatically reload data after adding a post..
        }
    }
    
    //MARK: - Functions
    func performFullSync(completion: ((Bool) -> Void)?) {
        
        activityView.isHidden = false
        activityIndicator.startAnimating()
        
        PostController.sharedInstance.fetchPosts { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let posts):
                    self.activityView.isHidden = true
                    self.activityIndicator.stopAnimating()
                    self.tableView.reloadData()
                    completion?(posts != nil)
                case .failure(let error):
                    self.presentSimpleAlertWith(title: "Error", message: error.localizedDescription)
                    print("Error in \(#function) : On Line \(#line) : \(error.localizedDescription) \n---\n \(error)")
                    completion?(false)
                }
            }
        }
    }//end of func
    

    // MARK: - Table view data source

    /*
     override func numberOfSections(in tableView: UITableView) -> Int {
     // #warning Incomplete implementation, return the number of sections
     return 0
     }
     */

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "postListCell", for: indexPath) as? PostTableViewCell else { return UITableViewCell() }
        
        let post = dataSource[indexPath.row] as? Post
        cell.post = post

        return cell
    }

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //IIDOO
        if segue.identifier == "toPostDetailVC" {
            guard let indexPath = tableView.indexPathForSelectedRow,
                  let destinationVC = segue.destination as? PostDetailTableViewController else { return }
            
            let postToSend = dataSource[indexPath.row] as? Post
            
            destinationVC.post = postToSend
        }
    }

}//End of class

//MARK: - Extensions
extension PostListTableViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        if !searchText.isEmpty {
            let filteredArray = PostController.sharedInstance.posts.filter{ $0.matches(searchTerm: searchText) }
            resultsArray = filteredArray
        } else {
            resultsArray = PostController.sharedInstance.posts
        }
        
        tableView.reloadData()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        resultsArray = PostController.sharedInstance.posts
        searchBar.text = ""
        searchBar.resignFirstResponder()
        tableView.reloadData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        isSearching = true
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        isSearching = false
        searchBar.text = ""
    }
    
}//End of extension
