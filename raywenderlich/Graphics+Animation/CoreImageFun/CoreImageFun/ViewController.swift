//
//  ViewController.swift
//  CoreImageFun
//
//  Created by Abhijeet Mishra on 08/02/17.
//  Copyright © 2017 Abhijeet Mishra. All rights reserved.
//

import UIKit

enum SliderType:Int {
   case Sepia
    case Random
    case ColorControls
    case HardLightBlendMode
    case Vignette
}

class ViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var slider: UISlider!
    
    var context: CIContext!
    var filter: CIFilter!
    var beginImage: CIImage!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    
        let fileURL = Bundle.main.url(forResource: "image", withExtension: "png")
        
        beginImage = CIImage.init(contentsOf: fileURL!)
        
        
        filter = CIFilter.init(name: "CISepiaTone")
        filter?.setValue(beginImage, forKey: kCIInputImageKey)
        filter?.setValue(1, forKey: kCIInputIntensityKey)
       
        
        context = CIContext.init()

        let cgImage = context.createCGImage((filter?.outputImage)!, from: (filter?.outputImage?.extent)!)
        let newImage = UIImage.init(cgImage: cgImage!)
        
        //too expensive step as it creates its own CIContext --> very heavy operation !!!
      //  let newImage = UIImage.init(ciImage: (filter?.outputImage)!)
        imageView.image = newImage
        
    }

    @IBAction func sliderValueChanged(_ sender: UISlider) {
    
        let tag = sender.tag
        
        var filterName = ""
        
        switch tag {
        
        case SliderType.Sepia.rawValue: filterName = "CISepiaTone"; break
            
        case SliderType.Random.rawValue: filterName = "CIRandomGenerator"; break
            
        case SliderType.ColorControls.rawValue: filterName = "CIColorControls"; break
            
        case SliderType.HardLightBlendMode.rawValue: filterName = "CIHardLightBlendMode" ;break
            
        case SliderType.Vignette.rawValue: filterName = "CIVignette" ;break
          
        default: return
        
        }
        
        let sliderValue = sender.value
        filter = CIFilter.init(name: filterName)
        filter?.setValue(beginImage, forKey: kCIInputImageKey)
        filter?.setValue(sliderValue, forKey: kCIInputIntensityKey)
        
        imageView.image = UIImage.init(cgImage: context.createCGImage(filter.outputImage!, from: (filter.outputImage?.extent)!)!)
    }
}

