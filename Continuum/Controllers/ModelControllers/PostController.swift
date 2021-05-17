//
//  PostController.swift
//  Continuum
//
//  Created by James Chun on 5/11/21.
//  Copyright © 2021 trevorAdcock. All rights reserved.
//

import UIKit
import CloudKit

class PostController {
    //MARK: - Properties
    //sharedInstance
    static let sharedInstance = PostController()
    
    //SOT
    var posts: [Post] = []
    
    let publicDB = CKContainer.default().publicCloudDatabase
    
    private init() {
        subscribeToNewPosts(completion: nil)
    }
    
    //MARK: - CKMethods (Create)
    func addComment(text: String, post: Post, completion: @escaping (Result<Comment, PostError>) -> Void) {
        let newComment = Comment(text: text, post: post)
        
        let commentRecord = CKRecord(comment: newComment)
        
        publicDB.save(commentRecord) { record, error in
            if let error = error {
                completion(.failure(.thrownError(error))); return
            }
            
            guard let record = record else { return completion(.failure(.noData)) }
            guard let savedComment = Comment(ckRecord: record, post: post) else { return completion(.failure(.unableToDecode)) }
            
            post.comments.insert(savedComment, at: 0)
            
            self.incrementCommentCount(post: post, completion: nil)
            
            completion(.success(savedComment))
        }
    }//end of func
    
    func createPostWith(image: UIImage, caption: String, completion: @escaping (Result<Post?, PostError>) -> Void) {
        let post = Post(photo: image, caption: caption)
        
        let postRecord = CKRecord(post: post)
        
        publicDB.save(postRecord) { record, error in
            if let error = error {
                completion(.failure(.thrownError(error))); return
            }
            
            guard let record = record else { return completion(.failure(.noData)) }
            guard let savedPost = Post(ckRecord: record) else { return completion(.failure(.unableToDecode)) }
            
            self.posts.insert(savedPost, at: 0)
            return completion(.success(savedPost))
        }
    }//end of func
    
    //MARK: - CK Methods (Read)
    func fetchPosts(completion: @escaping (Result<[Post]?, PostError>) -> Void) {
        
        let predicate = NSPredicate(value: true)
        
        let query = CKQuery(recordType: PostStrings.postTypeKey, predicate: predicate)
        
        publicDB.perform(query, inZoneWith: nil) { records, error in
            if let error = error {
                print("Error in \(#function) : On Line \(#line) : \(error.localizedDescription) \n---\n \(error)")
            }
            
            guard let records = records else { return completion(.failure(.noData)) }
            
            let posts = records.compactMap({Post(ckRecord: $0)})
            let sortedPosts = posts.sorted(by: {$0.timestamp > $1.timestamp})
            
            self.posts = sortedPosts
            completion(.success(sortedPosts))
        }
    }//end of func
    
    func fetchComments(for post: Post, completion: @escaping (Result<[Comment], PostError>) -> Void) {
        let postReference = post.recordID
        let predicate = NSPredicate(format: "%K == %@", CommentStrings.postRefernceKey, postReference)
        let commentIDs = post.comments.compactMap( {$0.recordID} )
        let predicate2 = NSPredicate(format: "NOT(recordID IN %@)", commentIDs)
        let compoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [predicate, predicate2])
        let query = CKQuery(recordType: "Comment", predicate: compoundPredicate)
        
        publicDB.perform(query, inZoneWith: nil) { records, error in
            if let error = error {
                print("Error in \(#function) : On Line \(#line) : \(error.localizedDescription) \n---\n \(error)")
            }
            
            guard let records = records else { return completion(.failure(.noData)) }
            
            let comments = records.compactMap( {Comment(ckRecord: $0, post: post)} )
            let sortedComments = comments.sorted(by: {$0.timestamp > $1.timestamp} )
            
            post.comments.append(contentsOf: sortedComments)
            completion(.success(sortedComments))
        }
    }//end of func
    
    //MARK: - CK Methods (Update)
    func incrementCommentCount(post: Post, completion: ((Bool) -> Void)?) {
        post.commentCount = post.comments.count
        
        let record = CKRecord(post: post)
        let operation = CKModifyRecordsOperation(recordsToSave: [record], recordIDsToDelete: nil)
        
        operation.savePolicy = .changedKeys
        operation.qualityOfService = .userInteractive
        
        operation.modifyRecordsCompletionBlock = { _, _, error in
            if let error = error {
                print("Error in \(#function) : On Line \(#line) : \(error.localizedDescription) \n---\n \(error)")
                completion?(false); return
            } else {
                completion?(true); return
            }
        }
        
        publicDB.add(operation)
    }//end of func
    
    //MARK: - CK Methods (Subscription)
    func subscribeToNewPosts(completion: ((Bool, Error?) -> Void)?) {
         let predicate = NSPredicate(value: true)
        
        let subscription = CKQuerySubscription(recordType: PostStrings.postTypeKey, predicate: predicate, subscriptionID: "AllPosts", options: .firesOnRecordCreation)
        
        let notificationInfo = CKSubscription.NotificationInfo()
        notificationInfo.alertBody = "New post has been added to Continuum"
        notificationInfo.shouldBadge = true
        notificationInfo.shouldSendContentAvailable = true
        notificationInfo.soundName = "default"
        
        subscription.notificationInfo = notificationInfo
        
        publicDB.save(subscription) { (subscription, error) in
            if let error = error {
                print("Error in \(#function) : On Line \(#line) : \(error.localizedDescription) \n---\n \(error)")
                completion?(false, error); return
            } else {
                completion?(true, nil); return
            }
        }
    }//end of func
    
    func addSubscriptionTo(commentsForPost post: Post, completion: ((Bool, Error?) -> Void)?) {
        let predicate = NSPredicate(format: "%K == %@", argumentArray: [CommentStrings.postRefernceKey, post.recordID])
        
        let subscription = CKQuerySubscription(recordType: CommentStrings.commentTypeKey, predicate: predicate, subscriptionID: post.recordID.recordName, options: .firesOnRecordCreation)
        
        let notificationInfo = CKSubscription.NotificationInfo()
        notificationInfo.alertBody = "New comment as been added to Continuum post: \(post.caption)"
        notificationInfo.shouldBadge = true
        notificationInfo.shouldSendContentAvailable = true
        notificationInfo.soundName = "default"
        notificationInfo.desiredKeys = [CommentStrings.textKey, CommentStrings.timestampKey]
        
        subscription.notificationInfo = notificationInfo
        
        publicDB.save(subscription) { (subscription, error) in
            if let error = error {
                print("Error in \(#function) : On Line \(#line) : \(error.localizedDescription) \n---\n \(error)")
                completion?(false, error); return
            } else {
                completion?(true,nil); return
            }
        }
    }//end of func
    
    func removeSubscriptionTo(commentsForPost post: Post, completion: ((Bool, Error?) -> Void)?) {
        let subscriptionID = post.recordID.recordName
        
        publicDB.delete(withSubscriptionID: subscriptionID) { (_, error) in
            if let error = error {
                print("Error in \(#function) : On Line \(#line) : \(error.localizedDescription) \n---\n \(error)")
                completion?(false, error); return
            } else {
                completion?(true, nil); return
            }
        }
    }//end of func
    
    func checkSubscription(to post: Post, completion: ((Bool) -> Void)?) {
        let subscriptionID = post.recordID.recordName
        
        publicDB.fetch(withSubscriptionID: subscriptionID) { subscription, error in
            if let error = error {
                print("Error in \(#function) : On Line \(#line) : \(error.localizedDescription) \n---\n \(error)")
                completion?(false); return
            }
            
            if subscription != nil {
                completion?(true)
            } else {
                completion?(false)
            }
        }
    }//end of func
    
    func toggleSubscriptionTo(commentsForPost post: Post, completion: ((Bool, Error?) -> Void)?) {
        checkSubscription(to: post) { (isSubscribed) in
            if isSubscribed {
                self.removeSubscriptionTo(commentsForPost: post) { (success, error) in
                    if let error = error {
                        print("Error in \(#function) : On Line \(#line) : \(error.localizedDescription) \n---\n \(error)")
                        completion?(false, error); return
                    }
                    
                    if success {
                        print("Successfully removed subscription to the post with caption: \(post.caption)")
                        completion?(true, nil)
                    } else {
                        print("Error removing subscription to the post with caption: \(post.caption)")
                        completion?(false, nil)
                    }
                }
                
            } else {
                self.addSubscriptionTo(commentsForPost: post) { (success, error) in
                    if let error = error {
                        print("Error in \(#function) : On Line \(#line) : \(error.localizedDescription) \n---\n \(error)")
                        completion?(false, error); return
                    }
                    
                    if success {
                        print("Successfully subscribed to post with caption: \(post.caption)")
                        completion?(true, error)
                    } else {
                        print("Erro subscribing to post with caption: \(post.caption)")
                        completion?(false, error)
                    }
                }
            }
        }
    }//end of func
    
}//End of class
