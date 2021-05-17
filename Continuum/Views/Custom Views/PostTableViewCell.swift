//
//  PostTableViewCell.swift
//  Continuum
//
//  Created by James Chun on 5/11/21.
//  Copyright © 2021 trevorAdcock. All rights reserved.
//

import UIKit

class PostTableViewCell: UITableViewCell {
    
    //MARK: - Outlets
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var captionLabel: UILabel!
    @IBOutlet weak var commentCountLabel: UILabel!
    
    //MARK: - Properties
    var post: Post? {
        didSet {
            updateViews()
        }
    }
    
    //MARK: - Actions
    
    
    //MARK: - Functions
    func updateViews() {
        guard let post = post else { return }
        
        photoImageView.image = post.photo
        captionLabel.text = post.caption
        commentCountLabel.text = "Comments: \(post.commentCount)"
    }
    
}//End of class
