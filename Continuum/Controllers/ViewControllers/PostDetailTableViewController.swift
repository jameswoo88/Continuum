//
//  PostDetailTableViewController.swift
//  Continuum
//
//  Created by James Chun on 5/11/21.
//  Copyright © 2021 trevorAdcock. All rights reserved.
//

import UIKit

class PostDetailTableViewController: UITableViewController {
    
    //MARK: - Outlets
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var followPostButton: UIButton!
    @IBOutlet weak var buttonStackView: UIStackView!
    
    //MARK: - Properties
    //Landing Pad
    var post: Post? {
        didSet {
            loadViewIfNeeded()
            updateViews()
        }
    }
    
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let post = post else { return }
        PostController.sharedInstance.fetchComments(for: post) { (_) in
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    //MARK: - Actions
    @IBAction func commentButtonTapped(_ sender: Any) {
        presentAlertController()
    }
    
    @IBAction func shareButtonTapped(_ sender: Any) {
        guard let post = post else { return }
        
        if let image = post.photo {
            let items: [Any] = [post.caption, image]
            let activityVC = UIActivityViewController(activityItems: items, applicationActivities: [])
            present(activityVC, animated: true, completion: nil)
        }
    }
    
    @IBAction func followPostButtonTapped(_ sender: Any) {
        guard let post = post else { return }
        
        PostController.sharedInstance.toggleSubscriptionTo(commentsForPost: post) { (success, error) in
            if let error = error {
                print("Error in \(#function) : On Line \(#line) : \(error.localizedDescription) \n---\n \(error)")
                return
            }
            
            self.updateFollowButton()
        }
    }
    
    //MARK: - Functions
    func updateViews() {
        guard let post = post else { return }
        
        photoImageView.image = post.photo
        tableView.reloadData()
        updateFollowButton()
    }
    
//    func updateFollowButton(){
//
//        guard let post = post else { return }
//
//        PostController.sharedInstance.checkSubscription(to: post) { (found) in
//
//            DispatchQueue.main.async {
//                let followPostButtonText = found ? "Unfollow Post" : "Follow Post"
//                self.followPostButton.setTitle(followPostButtonText, for: .normal)
//                self.buttonStackView.layoutIfNeeded()
//            }
//        }
//    }
    
    func updateFollowButton() {
        guard let post = post else { return }

        PostController.sharedInstance.checkSubscription(to: post) { (isSubscribed) in
            DispatchQueue.main.async {
                if isSubscribed {
                    self.followPostButton.setTitle("Following", for: .normal)
                    self.followPostButton.setTitleColor(.systemGreen, for: .normal)
                } else {
                    self.followPostButton.setTitle("Follow Post", for: .normal)
                    self.followPostButton.setTitleColor(.systemBlue, for: .normal)
                }
                self.buttonStackView.layoutIfNeeded()
            }
        }
    }//end of func
    
    func presentAlertController() {
        let alertController = UIAlertController(title: "Add a comment!", message: "What do you way about this post?", preferredStyle: .alert)
        
        alertController.addTextField { (textField) in
            textField.placeholder = "add comment here..."
            textField.autocorrectionType = .yes
            textField.autocapitalizationType = .sentences
            textField.delegate = self
        }
        
        let okAction = UIAlertAction(title: "OK", style: .default) { (_) in
            
            guard let comment = alertController.textFields?.first?.text, !comment.isEmpty,
                  let post = self.post else {
                
                let errorAlertController = ErrorAlert.customAlertController(image: nil, text: alertController.textFields?.first?.text)
                self.present(errorAlertController, animated: true, completion: nil)
                
                return
            }
                        
            PostController.sharedInstance.addComment(text: comment, post: post) { result in
                
            }
            self.tableView.reloadData()
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alertController.addAction(okAction)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true, completion: nil)
        
    }//end of func
    
    
    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let post = post else { return 0 }
        return post.comments.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "postDetailCell", for: indexPath)
        
        guard let post = post else { return UITableViewCell() }

        let comment = post.comments[indexPath.row]
        
        cell.textLabel?.text = comment.text
        cell.detailTextLabel?.text = comment.timestamp.dateToString()
        
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

}//End of class

//MARK: - Extensions
extension PostDetailTableViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}//End of extension
