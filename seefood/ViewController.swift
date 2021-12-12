//
//  ViewController.swift
//  seefood
//
//  Created by Thiago Antonio Ramalho on 10/12/21.
//

import UIKit
import CoreML
import Vision

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var imageView: UIImageView!
    
    private let imagePickerController =  UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imagePickerController.delegate = self
        imagePickerController.sourceType = .camera
        imagePickerController.allowsEditing = false
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let safeImage = info[.originalImage] as? UIImage {
            imageView.image = safeImage
            
            guard let ciImage = CIImage(image: safeImage) else {
                fatalError("is not possible convert UIImage into CIImage")
            }
            
            detect(image: ciImage)
        }
        
        imagePickerController.dismiss(animated: true, completion: nil)
    }
    
    private func detect(image: CIImage) {
        
        
        
        guard let model = try? VNCoreMLModel(for: Inceptionv3(contentsOf: Inceptionv3.urlOfModelInThisBundle).model) else {
            fatalError("Load core model failed")
        }
        
        let request = VNCoreMLRequest(model: model) { request, error in
            
            guard let results = request.results as? [VNClassificationObservation] else {
                fatalError("model failed to process image")
            }
            
            var finalTitle = "Not a hotdog"
            
            if let firstResult = results.first, firstResult.identifier.contains("hotdog") {
                finalTitle = "Hotdog!"
            }
            
            self.navigationItem.title = finalTitle
        }
        
        guard let cgImage = image.cgImage else {
            fatalError("image do not have cgImage")
        }
        
        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        
        do {
            try handler.perform([request])
        } catch {
            print(error.localizedDescription)
        }
    }
    

    @IBAction func cameraTapped(_ sender: UIBarButtonItem) {
        present(imagePickerController, animated: true, completion: nil)
    }
    
}

