//
//  AddPostTableViewController.swift
//  Continuum
//
//  Created by James Chun on 5/11/21.
//  Copyright © 2021 trevorAdcock. All rights reserved.
//

import UIKit

class AddPostTableViewController: UITableViewController {
    
    //MARK: - Outlets
    @IBOutlet weak var captionTextField: UITextField!
    
    //MARK: - Properties
    var selectedImage: UIImage?
    
    //MARK: - Lifecycle
    override func viewDidLoad() {
        captionTextField.delegate = self
        
        super.viewDidLoad()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        captionTextField.text = ""
    }
        
    //MARK: - Actions
    
    @IBAction func addPostButtonTapped(_ sender: Any) {
        guard let image = selectedImage,
              let caption = captionTextField.text, !caption.isEmpty else {
            
            let errorAlertController = ErrorAlert.customAlertController(image: selectedImage, text: captionTextField.text)
            present(errorAlertController, animated: true, completion: nil)
            
            return
        }
        
        PostController.sharedInstance.createPostWith(image: image, caption: caption) { result in
        }
        
        self.tabBarController?.selectedIndex = 0
    }//end of func
    
    @IBAction func cancelButtonTapped(_ sender: Any) {
        self.tabBarController?.selectedIndex = 0
    }
    
    // MARK: - Table view data source
    
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
        if segue.identifier == "toPhotoSelectorContainer" {
            guard let destinationVC = segue.destination as? PhotoSelectorViewController else { return }
            destinationVC.delegate = self
        }
    }

}//End of class

//MARK: - Extensions
extension AddPostTableViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
    }
    
}//End of extension

extension AddPostTableViewController: PhotoSelectorViewControllerDelegate {
    func photoSelectorViewControllerSelected(image: UIImage) {
        selectedImage = image
    }
    
}//End of extension
