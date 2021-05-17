//
//  Post.swift
//  Continuum
//
//  Created by James Chun on 5/11/21.
//  Copyright © 2021 trevorAdcock. All rights reserved.
//

import UIKit
import CloudKit

class Post {
    
    //JCHUN - do I need weak var delegate: SearchableRecord?
    var photoData: Data?
    let timestamp: Date
    let caption: String
    var comments: [Comment]
    var photo: UIImage? {
        get {
            guard let photoData = photoData else { return nil }
            return UIImage(data: photoData)
        }
        set(newImage) {
            photoData = newImage?.jpegData(compressionQuality: 0.5)
        }
    }//end of property
    
    var commentCount: Int
    
    let recordID: CKRecord.ID
    var photoAsset: CKAsset? {
        get {
            let tempDirectory = NSTemporaryDirectory()
            let tempDirectoryURL = URL(fileURLWithPath: tempDirectory)
            let fileURL = tempDirectoryURL.appendingPathComponent(UUID().uuidString)
            
            do {
                try photoData?.write(to: fileURL)
            } catch {
                print("Error in \(#function) : On Line \(#line) : \(error.localizedDescription) \n---\n \(error)")
            }
            
            return CKAsset(fileURL: fileURL)
        }
    }//end of property
    
    init(photo: UIImage?, caption: String, timestamp: Date = Date(), comments: [Comment] = [], recordID: CKRecord.ID = CKRecord.ID(recordName: UUID().uuidString), commentCount: Int = 0) {
        self.recordID = recordID
        self.caption = caption
        self.timestamp = timestamp
        self.comments = comments
        self.commentCount = commentCount
        self.photo = photo
    }
    
}//End of class


//MARK: - Extensions

extension CKRecord {

    convenience init(post: Post) {
        self.init(recordType: PostStrings.postTypeKey, recordID: post.recordID)
        
        self.setValuesForKeys([
            PostStrings.captionKey : post.caption,
            PostStrings.timestampKey : post.timestamp,
            PostStrings.commentCountKey : post.commentCount
        ])
        
        if let photoAsset = post.photoAsset {
            self.setValue(photoAsset, forKey: PostStrings.photoAssetKKey)
        }
    }
    
}//End of extension

extension Post {
        
    convenience init?(ckRecord: CKRecord) {
        
        var foundPhoto: UIImage?
        
        if let photoAsset = ckRecord[PostStrings.photoAssetKKey] as? CKAsset {
            do {
                guard let url = photoAsset.fileURL else { return nil }
                let data = try Data(contentsOf: url)
                foundPhoto = UIImage(data: data)
            } catch {
                print("Error in \(#function) : On Line \(#line) : \(error.localizedDescription) \n---\n \(error)")
            }
        }
        
        guard let caption = ckRecord[PostStrings.captionKey] as? String,
              let timestamp = ckRecord[PostStrings.timestampKey] as? Date,
              let commentCount = ckRecord[PostStrings.commentCountKey] as? Int else { return nil }
        
        let comments = [Comment]()
                
        self.init(photo: foundPhoto, caption: caption, timestamp: timestamp, comments: comments, recordID: ckRecord.recordID, commentCount: commentCount)
        
    }
    
}//End of extension

extension Post: SearchableRecord {
    func matches(searchTerm: String) -> Bool {
        if self.caption.lowercased().contains(searchTerm.lowercased()) {
            return true
        } else {
            return false
        }
    }
}//End of extension
