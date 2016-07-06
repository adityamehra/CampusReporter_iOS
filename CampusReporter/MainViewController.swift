//
//  ViewController.swift
//  CampusReporter
//
//  Created by Aditya  Mehra on 6/14/16.
//  Copyright © 2016 Aditya  Mehra. All rights reserved.
//

import UIKit
import MessageUI
import CoreLocation

class MainViewController: UIViewController,
                            MFMailComposeViewControllerDelegate,
                            UIImagePickerControllerDelegate,
                            UINavigationControllerDelegate,
                            CLLocationManagerDelegate{
    
    
    @IBOutlet weak var record: UIButton!
    
    @IBOutlet weak var play: UIButton!
    
    @IBOutlet weak var camera: UIButton!
    
    @IBOutlet weak var send: UIButton!
    
    @IBOutlet weak var stop: UIButton!
    
    @IBOutlet weak var textView: UITextView!
    
    var imageToattach : UIImage!
    
    var locationManager: CLLocationManager!
    
    var latitude : String!
    
    var longitude : String!
    
    override func viewWillAppear(animated: Bool) {
        play.enabled = false
        stop.enabled = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        textView.text = "Placeholders"
        textView.textColor = UIColor.lightGrayColor()
        
        self.locationManager = CLLocationManager()
        
        locationManager.delegate = self
        
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        locationManager.startUpdatingLocation()
        
        locationManager.requestAlwaysAuthorization()
        
    }
    
    override func didReceiveMemoryWarning() {
        
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func shouldAutorotate() -> Bool {
        return false
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.Portrait
    }
    
    @IBAction func recordAudio(sender: AnyObject) {
        print("Audio recording!");
        stop.enabled = true
    }
    
    @IBAction func playAudio(sender: AnyObject) {
        print("Playing Audio!");
    }
    
    @IBAction func stopAudio(sender: AnyObject) {
        print("Stop Audio")
        play.enabled = true
    }
    
    @IBAction func takePhoto(sender: AnyObject) {
        
        print("Taking Photo!");
        
        let picker = UIImagePickerController()
        
        picker.delegate = self
        
        picker.sourceType = .Camera
        
        presentViewController(picker, animated:true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        UIImageWriteToSavedPhotosAlbum (image, self, #selector(MainViewController.image(_:didFinishSavingWithError:contextInfo:)), nil)
        imageToattach = image
    }
    
    func image(image: UIImage, didFinishSavingWithError error: NSError?, contextInfo:UnsafePointer<Void>) {
        if error == nil {
            let ac = UIAlertController(title: "Saved!", message: "Your altered image has been saved to your photos.", preferredStyle: .Alert)
            ac.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
            self.dismissViewControllerAnimated(true, completion: nil)
            //presentViewController(ac, animated: true, completion: nil)
        } else {
            let ac = UIAlertController(title: "Save error", message: error?.localizedDescription, preferredStyle: .Alert)
            ac.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
            self.dismissViewControllerAnimated(true, completion: nil)
            //presentViewController(ac, animated: true, completion: nil)
        }
    }

    
    @IBAction func sendMail(sender: AnyObject) {
        
        print("Send Email!");
        
        if !MFMailComposeViewController.canSendMail() {
            print("Mail services are not available")
            
            let alertController = UIAlertController(title: "Alert", message: "Setup your Mail App.", preferredStyle: .Alert)
            
            let oKAction = UIAlertAction(title: "OK", style: .Default) { (action) in
                // ...
            }
            alertController.addAction(oKAction)
            
            
            self.presentViewController(alertController, animated: true) {
                // ...
            }
        }else{
            
            let composeVC = MFMailComposeViewController()
            
            composeVC.mailComposeDelegate = self
            
            // Configure the fields of the interface.
            composeVC.setToRecipients(["adityamehra@aggiemail.usu.edu"])
            composeVC.setSubject("Regarding CampusReporter")
            composeVC.setMessageBody("https://www.google.com/maps/?q=\(latitude),\(longitude)&z=17", isHTML: false)
            
            if let image = imageToattach {
                let data : NSData
                data = UIImageJPEGRepresentation(image, 1.0)!
                composeVC.addAttachmentData(data, mimeType: "image/jpg", fileName: "image")
            }
            
            // Present the view controller modally.
            self.presentViewController(composeVC, animated: true, completion: nil)
        }
    }
    
    func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func locationManager(manager: CLLocationManager, didUpdateToLocation newLocation: CLLocation, fromLocation oldLocation: CLLocation) {
        
        let currentLocation : CLLocation = newLocation
        
        
        latitude = "\(currentLocation.coordinate.latitude)"
        longitude = "\(currentLocation.coordinate.longitude)"
        print("longitude \(self.latitude)")
        print("latitude \(self.longitude)")
        
        
    }
}

