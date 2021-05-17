//
//  Comment.swift
//  Continuum
//
//  Created by James Chun on 5/16/21.
//  Copyright © 2021 trevorAdcock. All rights reserved.
//

import UIKit
import CloudKit

class Comment {
    let text: String
    let timestamp: Date
    weak var post: Post?
    let recordID: CKRecord.ID
    
    var postReference: CKRecord.Reference? {
        guard let post = post else { return nil }
        return CKRecord.Reference(recordID: post.recordID, action: .deleteSelf)
    }
    
    init(text: String, timestamp: Date = Date(), post: Post?, recordID: CKRecord.ID = CKRecord.ID(recordName: UUID().uuidString)) {
        self.text = text
        self.timestamp = timestamp
        self.post = post
        self.recordID = recordID
    }
    
}//End of class

//MARK: - Extensions
extension Comment {
    
    convenience init? (ckRecord: CKRecord, post: Post) {
        guard let text = ckRecord[CommentStrings.textKey] as? String,
              let timestamp = ckRecord[CommentStrings.timestampKey] as? Date else { return nil }
        
        self.init(text: text, timestamp: timestamp, post: post, recordID: ckRecord.recordID)
    }
    
}//End of extension

extension CKRecord {
    
    convenience init(comment: Comment) {
        self.init(recordType: CommentStrings.commentTypeKey, recordID: comment.recordID)
        
        setValuesForKeys([
            CommentStrings.textKey : comment.text,
            CommentStrings.timestampKey : comment.timestamp,
        ])
        
        if let reference = comment.postReference {
            setValue(reference, forKey: CommentStrings.postRefernceKey)
        }
    }
    
}
