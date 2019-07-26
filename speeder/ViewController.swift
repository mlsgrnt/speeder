//
//  ViewController.swift
//  speeder
//
//  Created by Miles Grant on 7/26/19.
//  Copyright © 2019 Blydro. All rights reserved.
//

import UIKit
import CoreLocation


class ViewController: UIViewController, CLLocationManagerDelegate {
    let lm = CLLocationManager()

    @IBOutlet weak var mainLabel: UILabel!
    @IBOutlet weak var addrLabel: UILabel!
    @IBOutlet weak var zipcodeLabel: UILabel!
    @IBOutlet weak var coordsLabel: UILabel!
    @IBOutlet weak var altitudeLabel: UILabel!
    
    @IBAction func screenTapped(_ sender: UILongPressGestureRecognizer) {
        UIView.animate(withDuration: 0.3, animations: {
            if(sender.state == .began) {
                self.coordsLabel.alpha = 0.9
                self.altitudeLabel.alpha = 0.8
            }
            
            if(sender.state == .ended) {
                self.coordsLabel.alpha = 0.0
                self.altitudeLabel.alpha = 0.0
            }
        })

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        lm.requestWhenInUseAuthorization()
        lm.delegate = self
        lm.startUpdatingLocation()
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // Get speed
        let speed = round(locations[0].speed) * 3.6 // Convert from m/s to km/h
        mainLabel.text = String(Int(speed))
        
        // Get Coordiantes
        let coordsString = String(format: "%.4f", locations[0].coordinate.latitude) + ", " + String(format: "%.4f", locations[0].coordinate.longitude) + " ±" + String(round(locations[0].horizontalAccuracy)) + "m"
        coordsLabel.text = coordsString
        
        // Get altitude
        let altitude = String(Int(round(locations[0].altitude))) + "m"
        altitudeLabel.text = altitude
        
        // Look up the current location
        lookUpCurrentLocation { (placemark) in
            guard let zipcode = placemark?.postalCode else {
                return
            }
            self.zipcodeLabel.text = zipcode

            
            guard let locality = placemark?.locality else {
                return
            }
            guard let thruFare = placemark?.thoroughfare else {
                self.addrLabel.text = "\(locality)"
                return
            }
            guard let subThrufare = placemark?.subThoroughfare else {
                self.addrLabel.text = "\(thruFare), \(locality)"
                return
            }
            guard let subLocality = placemark?.subLocality else {
                self.addrLabel.text = "\(subThrufare) \(thruFare), \(locality)"
                return
            }

            
            self.addrLabel.text = "\(subThrufare) \(thruFare), \(subLocality) \(locality)"
            
            
        }
    }

    func lookUpCurrentLocation(completionHandler: @escaping (CLPlacemark?)
        -> Void ) {
        // Use the last reported location.
        if let lastLocation = self.lm.location {
            let geocoder = CLGeocoder()
            
            // Look up the location and pass it to the completion handler
            geocoder.reverseGeocodeLocation(lastLocation,
                                            completionHandler: { (placemarks, error) in
                                                if error == nil {
                                                    let firstLocation = placemarks?[0]
                                                    completionHandler(firstLocation)
                                                }
                                                else {
                                                    // An error occurred during geocoding.
                                                    completionHandler(nil)
                                                }
            })
        }
        else {
            // No location was available.
            completionHandler(nil)
        }
    }

}

