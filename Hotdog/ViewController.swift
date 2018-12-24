//
//  ViewController.swift
//  Hotdog
//
//  Created by Alex on 08/11/2018.
//  Copyright © 2018 Overdensity. All rights reserved.
//

import UIKit
import CoreML
import Vision


class ViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    
    @IBOutlet weak var imageView: UIImageView!
    let imagePicker = UIImagePickerController()

    
    // MARK: VIEW DID LOAD
    // ===================================
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = false
    }
    
    
    // MARK: CAMERA BUTTON
    // ===================================
    @IBAction func cameraButton_touchUpInside(_ sender: Any) {
        present(imagePicker, animated: true, completion: nil)
    }
    
    
    // MARK: IMAGE PICKER
    // ===================================
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let pickedImage = info[.originalImage] as? UIImage {
            imageView.image = pickedImage
            imagePicker.dismiss(animated: true, completion: nil)
            
            guard let ciImage = CIImage(image: pickedImage) else {
                fatalError("Image could not be converted.")
            }
            
            detect(image: ciImage)
        }
    }
    
    
    // MARK: DETECT
    // ===================================
    func detect(image: CIImage) {
        
        guard let model = try? VNCoreMLModel(for: Inceptionv3().model) else {
            fatalError("Loading model failed.")
        }
        
        let request = VNCoreMLRequest(model: model) {
            (request, error) in
            guard let results = request.results as? [VNClassificationObservation] else {
                fatalError("Model failed to process image.")
            }
            
            if let firstResult = results.first {
                if firstResult.identifier.contains("hotdog") {
                    self.navigationItem.title = "hotdog"
                } else {
                    self.navigationItem.title = "not hotdog"
                }
            }
        }
        
        let handler = VNImageRequestHandler(ciImage: image)
        
        do {
            try handler.perform([request])
        }
        catch {
            print(error)
        }
    }
}
