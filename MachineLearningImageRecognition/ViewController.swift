//
//  ViewController.swift
//  MachineLearningImageRecognition
//
//  Created by ismail harmanda on 20.11.2023.
//

import UIKit
import CoreML
import Vision

class ViewController: UIViewController, UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    
    var chosenImage = CIImage()
    
    
    @IBOutlet weak var imageView: UIImageView!
    
    
    @IBOutlet weak var resultLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    
    @IBAction func onPressChange(_ sender: UIButton) {
        
        let picker = UIImagePickerController()
        picker.delegate = self
        
        picker.sourceType = .photoLibrary
        
        present(picker,animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
      
        
        if let safeImage = info[.originalImage] as? UIImage {
            imageView.image = info[.originalImage] as? UIImage
            
            let ciImage = CIImage(image: safeImage)
            
            chosenImage = ciImage!
            
            recognizeImage(image: chosenImage)
            
            self.dismiss(animated: true, completion: nil)
        }
        
    
    }
    
    func recognizeImage(image: CIImage){
        if let model = try? VNCoreMLModel(for: MobileNetV2().model){
            
            let request = VNCoreMLRequest(model: model) { vnRequest, error in
                
                if let results = vnRequest.results as? [VNClassificationObservation]{
                    if results.count>0{
                        let topResult = results.first
                        
                        DispatchQueue.main.async {
                            let confidenceLevel = Int((topResult?.confidence ?? 0) * 100)

                            self.resultLabel.text = "\(confidenceLevel)% it's \(topResult!.identifier)"
                        }
                    }
                }
            }
            
            let handler = VNImageRequestHandler(ciImage: image)
            
            DispatchQueue.global(qos: .userInteractive).async{
                do{
                    try handler.perform([request])
                } catch {
                    print(error)
                }
            }
        }
        
   
    }
    
}

