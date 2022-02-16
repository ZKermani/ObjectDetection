//
//  ViewController.swift
//  HotDog
//
//  Created by Zahra Sadeghipoor on 2/15/22.
//

import UIKit
import CoreML
import Vision

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var imageView: UIImageView!
    let imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        imagePicker.delegate = self
        imagePicker.sourceType = .camera
    }
    
    
    @IBAction func cameraButtonPressed(_ sender: UIBarButtonItem) {
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else {
            fatalError("Cannot convert to UIImage")
        }
        imageView.image = pickedImage
        self.dismiss(animated: true, completion: nil)
        guard let ciimage = CIImage(image: pickedImage) else {
            fatalError("Cannot convert to CIImage")
        }
        detect(image: ciimage)
    }
    
    // TODO: Following should probably be in the model module
    func detect(image: CIImage) {
        
        // Shouldn't/couldn't this model be a property of the class?
        guard let model = try? VNCoreMLModel(for: Inceptionv3().model) else {
            fatalError("Cannot create ML model")
        }
        
        let request = VNCoreMLRequest(model: model) { request, error in
            guard let results = request.results as? [VNClassificationObservation] else {
                fatalError("Model failed to process image")
            }
            let detectedClass = results.first?.identifier
            print(detectedClass)
            self.navigationItem.title = detectedClass
        }
        
        let handler = VNImageRequestHandler(ciImage:image)
        do {
            try handler.perform([request])
        } catch {
            print(error)
        }
    }
}

