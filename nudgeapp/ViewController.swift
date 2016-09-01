//
//  ViewController.swift
//  nudgeapp
//
//  Created by Diana on 8/28/16.
//  Copyright © 2016 diana. All rights reserved.
//

import UIKit
import CoreLocation
import CoreData

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, CLLocationManagerDelegate {


    // MARK: - View Did Load
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.delegate = self
        getCurrentDateTime()
        getLocation()
    }

    // MARK: - Outlets
    @IBOutlet weak var happyEmoji: UIButton!
    @IBOutlet weak var sadEmoji: UIButton!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!



    // MARK: - Interactions
    @IBAction func didTapHappyButton(sender: UIButton) {
        didClickHappy = true
        launchCameraRoll()
    }

    @IBAction func didTapSadButton(sender: UIButton) {
        didClickSad = true
        launchCameraRoll()
    }

    // global constants
    var didClickHappy = false
    var didClickSad = false

    let happy = "Feeling: 😀"
    let sad = "Feeling: 😭"

    // MARK: - Core Data
    var managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext

    func saveEntry(image: UIImage?) {
        var myEntry: String = ""
        if didClickHappy == true {
            myEntry = happy
        }

        if didClickSad == true {
            myEntry = sad
        }

        let location = locationLabel.text
        let date = NSDate()

        if let image = image {
            let image = UIImage(CGImage: image.CGImage!, scale: image.scale, orientation:.LeftMirrored)
            Api().saveNudge(myEntry, date: date, location: location, image: UIImageJPEGRepresentation(image, 0.75)!)
        }
    }


    // MARK: - Camera Roll
    // When User Selects Photo
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        saveEntry(info[UIImagePickerControllerOriginalImage] as? UIImage)
        dismissViewControllerAnimated(true, completion: nil)
    }

    // Launch Camera
    func launchCameraRoll() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self


        if UIImagePickerController.isSourceTypeAvailable(.Camera) {
            imagePicker.sourceType = .Camera
            UIImagePickerControllerSourceType.Camera
            imagePicker.cameraDevice = UIImagePickerControllerCameraDevice.Front
        } else {
            imagePicker.sourceType = .PhotoLibrary
        }

        presentViewController(imagePicker, animated: true, completion: nil)
        print("did launch camera roll")
    }


    // MARK: - Location Manager
    let locationManager = CLLocationManager()

    // MARK: CLLocation Manager Delegate
    func locationManager(manager: CLLocationManager, didUpdateToLocation newLocation: CLLocation, fromLocation oldLocation: CLLocation) {
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(manager.location!) { (placemarks, error) in
            if error != nil {
                print("Error: \(error?.localizedDescription)")
            } else if placemarks?.count > 0 {
                print(placemarks![0])
                let firstPlacemark = placemarks![0]
                self.convertLocationDataToWords(firstPlacemark)
            }
        }
    }

    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print("Error: \(error.localizedDescription)")
    }

    // MARK: Location Functions
    func getLocation() {
        locationManager.requestWhenInUseAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyKilometer
        locationManager.startUpdatingLocation()
    }

    func convertLocationDataToWords(placemark: CLPlacemark) {
        locationManager.stopUpdatingHeading()
        let city = placemark.locality!
        let state = placemark.administrativeArea!
        let zipCode = placemark.postalCode!
        let country = placemark.ISOcountryCode!
        let location = "\(city), \(state) \(zipCode), \(country)"

        locationLabel.text = location
    }

    // MARK: Current Date and Time
    func getCurrentDateTime () {
        dateLabel.text = NSDateFormatter.localizedStringFromDate(
            NSDate(),
            dateStyle: NSDateFormatterStyle.LongStyle,
            timeStyle: NSDateFormatterStyle.ShortStyle);
    }
}


