//
//  PhotoSelectorViewController.swift
//  Continuum
//
//  Created by James Chun on 5/12/21.
//  Copyright © 2021 trevorAdcock. All rights reserved.
//

import UIKit

protocol PhotoSelectorViewControllerDelegate: AnyObject {
    func photoSelectorViewControllerSelected(image: UIImage)
}

class PhotoSelectorViewController: UIViewController {
    //MARK: - Outlets
    @IBOutlet weak var selectImageButton: UIButton!
    @IBOutlet weak var photoImageView: UIImageView!

    //MARK: - Properties
    weak var delegate: PhotoSelectorViewControllerDelegate?
    
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        selectImageButton.setTitle("Select Image", for: .normal)
        photoImageView.image = nil
    }
    
    //MARK: - Action
    @IBAction func selectImageButtonTapped(_ sender: Any) {
        presentImagePickerActionSheet()
    }

    //MARK: - Functions
    func presentImagePickerActionSheet() {
        
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        
        let alertController = UIAlertController(title: "Pick your photo!", message: "Select source of your photo", preferredStyle: .actionSheet)
        
        let cameraAction = UIAlertAction(title: "Camera", style: .default) { _ in
            imagePicker.sourceType = .camera
            imagePicker.allowsEditing = true
            self.present(imagePicker, animated: true, completion: nil)
        }
        
        let galleryAction = UIAlertAction(title: "Photo Gallery", style: .default) { _ in
            imagePicker.sourceType = .photoLibrary
            imagePicker.allowsEditing = true
            self.present(imagePicker, animated: true, completion: nil)
        }
        
        let albumAction = UIAlertAction(title: "Camera Roll Album", style: .default) { _ in
            imagePicker.sourceType = .savedPhotosAlbum
            imagePicker.allowsEditing = true
            self.present(imagePicker, animated: true, completion: nil)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            alertController.addAction(cameraAction)
        }
        
        alertController.addAction(galleryAction)
        alertController.addAction(albumAction)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true, completion: nil)
        
    }//end of func
    
}//End of class

//MARK: - Extensions

extension PhotoSelectorViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[.originalImage] as? UIImage {
            photoImageView.contentMode = .scaleAspectFill
            photoImageView.image = image
            selectImageButton.setTitle("", for: .normal)
            
            self.delegate?.photoSelectorViewControllerSelected(image: image)
        }
        
        picker.dismiss(animated: true, completion: nil)
    }
    
}//End of extension
