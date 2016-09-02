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
import AVFoundation
import Toast_Swift

class MainViewController: UIViewController,
                            UITextViewDelegate,
                            MFMailComposeViewControllerDelegate,
                            UIImagePickerControllerDelegate,
                            UINavigationControllerDelegate,
                            CLLocationManagerDelegate,
                            AVAudioPlayerDelegate,
                            AVAudioRecorderDelegate{
    
    
    @IBOutlet weak var record: UIButton!
    @IBOutlet weak var play: UIButton!
    @IBOutlet weak var camera: UIButton!
    @IBOutlet weak var send: UIButton!
    @IBOutlet weak var stop: UIButton!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var scrollView: UIScrollView!
    
    var imageToattach : UIImage!
    var locationManager: CLLocationManager!
    var latitude : String!
    var longitude : String!
    
    
    //Variables for recording/playing sound.
    var soundRecorder : AVAudioRecorder!
    var soundPlayer :AVAudioPlayer!
    var fileName = "audioFile.m4a"
    var filePath : NSURL!
    
    override func viewWillAppear(animated: Bool) {
        play.enabled = false
        stop.enabled = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        
        textView.text = "1. Write/Record the problem, building, and room number.\n\n2.Take a photo (optional).\n\n3.Send it.\n\nThank you."
        textView.textColor = UIColor.lightGrayColor()
        
        
        //setting delegate on locationManager
        self.locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
        locationManager.requestAlwaysAuthorization()
        
        
        //setting delegate on textView
        textView.delegate = self
        
        //Making an IBAction for UIScrollView
        let tapGestureRecognizer = UITapGestureRecognizer(target:self, action:#selector(MainViewController.scrollViewTapped(_:)))
        scrollView.userInteractionEnabled = true
        scrollView.addGestureRecognizer(tapGestureRecognizer)
        
    }
    
    //Removing first responder from textViewArea when ScrollView is tapped
    func scrollViewTapped(img: AnyObject){
        textView.resignFirstResponder()
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
    
    
    func setupRecorder(){
        
        
        let recordSettings : [String : AnyObject] =
            [
                AVFormatIDKey: NSNumber(unsignedInt: kAudioFormatAppleLossless),
                AVEncoderAudioQualityKey : AVAudioQuality.Max.rawValue as NSNumber,
                AVEncoderBitRateKey : 320000 as NSNumber,
                AVNumberOfChannelsKey: 2 as NSNumber,
                AVSampleRateKey : 44100.0
        ]
        
        filePath = getFileURL()
        
        let session = AVAudioSession.sharedInstance()
        //try! session.overrideOutputAudioPort(AVAudioSessionPortOverride.Speaker)
        try! session.setCategory(AVAudioSessionCategoryPlayAndRecord)
        
        var error : NSError?
        
        do {
            soundRecorder = try AVAudioRecorder(URL: filePath, settings: recordSettings)
        } catch let error1 as NSError {
            error = error1
            soundRecorder = nil
        }
        
        if error != nil{
            
            NSLog("Something Wrong")
        }
            
        else {
            
            soundRecorder.delegate = self
            soundRecorder.prepareToRecord()
            
        }
        
    }
    
    func getCacheDirectory() -> String {
        
        let path = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true)
        
        return path[0] as String
        
    }
    
    func getFileURL() -> NSURL{
        
        let path = NSURL.fileURLWithPathComponents([getCacheDirectory(), fileName])
        
        return path!
        
    }
    
    @IBAction func recordAudio(sender: UIButton) {
        //print("Audio recording!");
        
        //setting up recorder
        setupRecorder()
        
        soundRecorder.record()
        
        stop.enabled = true
        
        self.view.makeToast("Recording Audio...", duration: 2.0, position: .Bottom)
    }
    
    @IBAction func playAudio(sender: UIButton) {
        //print("Playing Audio!");
        
        preparePlayer()
        soundPlayer.play()
        
        self.view.makeToast("Playing Audio...",  duration: 2.0, position: .Bottom)
    }
    
    @IBAction func stopAudio(sender: UIButton) {
        //print("Stop Audio")
        play.enabled = true
        soundRecorder.stop()
        
        let audioSession = AVAudioSession.sharedInstance()
        try! audioSession.overrideOutputAudioPort(AVAudioSessionPortOverride.Speaker)
        try! audioSession.setActive(false)
        
        self.view.makeToast("Recording Stopped...",  duration: 2.0, position: .Bottom)
    }
    
    func preparePlayer(){
        
        var error : NSError?
        do {
            soundPlayer = try AVAudioPlayer(contentsOfURL: filePath)
        } catch let error1 as NSError {
            error = error1
            soundPlayer = nil
        }
        
        if error != nil{
            
            NSLog("sjkaldfhjakds")
        }
        else{
            soundPlayer.delegate = self
            soundPlayer.prepareToPlay()
            soundPlayer.volume = 2.0
        }
        
    }
    
    
    func audioRecorderDidFinishRecording(recorder: AVAudioRecorder, successfully flag: Bool) {
        play.enabled = true
    }
    
    func audioPlayerDidFinishPlaying(player: AVAudioPlayer, successfully flag: Bool) {
        record.enabled = true
        play.enabled = false
    }
    
    @IBAction func takePhoto(sender: AnyObject) {
        
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
        } else {
            let ac = UIAlertController(title: "Save error", message: error?.localizedDescription, preferredStyle: .Alert)
            ac.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
            self.dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
    @IBAction func sendMail(sender: AnyObject) {
        
        //print("Send Email!");
        
        //print(filePath);

        
        if !MFMailComposeViewController.canSendMail() {
            //print("Mail services are not available")
            
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
            composeVC.setToRecipients(["saveenergy@usu.edu"])
            composeVC.setSubject("Regarding CampusReporter")
            
            if textView.text == "1. Write/Record the problem, building, and room number.\n\n2.Take a photo (optional).\n\n3.Send it.\n\nThank you."{
                //print(textView.text)
                composeVC.setMessageBody("Location - https://www.google.com/maps/?q=\(latitude),\(longitude)&z=17", isHTML: false)
            }else{
                //print("else")
            composeVC.setMessageBody(textView.text + "\n\n" + "Location - https://www.google.com/maps/?q=\(latitude),\(longitude)&z=17",isHTML:false)
            }
            
            // Attaching the captured image to the email.
            if let image = imageToattach {
                let data : NSData
                data = UIImageJPEGRepresentation(image, 1.0)!
                composeVC.addAttachmentData(data, mimeType: "image/jpeg", fileName: "image.jpeg")
            }
            
            
            if filePath != nil{
                let fileManager = NSFileManager.defaultManager()
                let filecontent = fileManager.contentsAtPath(getCacheDirectory() + "/" + fileName)
                composeVC.addAttachmentData(filecontent!, mimeType: "audio/x-wav", fileName: fileName)
            }
            
            // Present the view controller modally.
            self.presentViewController(composeVC, animated: true, completion: nil)
        }
        
        filePath = nil
        imageToattach = nil
    }
    
    func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    //This function is used to get the current location of the user.
    func locationManager(manager: CLLocationManager, didUpdateToLocation newLocation: CLLocation, fromLocation oldLocation: CLLocation) {
        
        let currentLocation : CLLocation = newLocation
        latitude = "\(currentLocation.coordinate.latitude)"
        longitude = "\(currentLocation.coordinate.longitude)"
    }
    
    //Removes first responder when view is touched
    override func touchesBegan(touches:Set<UITouch>, withEvent event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    //Removes the text from textView when it is edited
    func textViewDidBeginEditing(textView: UITextView) {
        
        if textView.text == "1. Write/Record the problem, building, and room number.\n\n2.Take a photo (optional).\n\n3.Send it.\n\nThank you."{
            textView.text = ""
        }
    }
}

