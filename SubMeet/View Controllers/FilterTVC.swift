//
//  FilterTVC.swift
//  SubMeet
//
//  Created by carlos arellano on 10/5/18.
//  Copyright © 2018 nyu.edu. All rights reserved.
//

import UIKit
import MapKit

class FilterTVC: UITableViewController {

    @IBOutlet weak var switchButton: UISwitch!
    @IBOutlet weak var LocationLabel: UILabel!
    @IBOutlet weak var DistanceLabel: UILabel!
    @IBOutlet weak var MyLocationLabel: UILabel!
    @IBOutlet weak var MaxDistanceLabel: UILabel!
    @IBOutlet weak var Slider: UISlider!
    var myLocation: CLLocation!
    var sliderValue: String!
    var isOn: Bool!
    var hasSpecificLocation = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchCountryAndCity(myLocation: myLocation)

        // Do any additional setup after loading the view.
    }
    
    
    

    override func viewWillAppear(_ animated: Bool) {
        
        UserDefaults.standard.set(Slider.value, forKey: "sliderValue")
        let sliderValue = UserDefaults.standard.string(forKey: "sliderValue")
        let UserIsOn = UserDefaults.standard.string(forKey: "isOn")
        if UserIsOn != nil{
            isOn = Bool(UserIsOn!)
            switchButton.isOn = isOn
            checkIfOn(isOn: isOn)
            if sliderValue != nil {
                Slider.value = Float(sliderValue!)!
            }
            else{
                Slider.value = 50
            }
            return
        }
        
        isOn = switchButton.isOn
        print("switch button is on:", isOn)
        checkIfOn(isOn: isOn)
        if sliderValue != nil {
            Slider.value = Float(sliderValue!)!
            DistanceLabel.text = "\(Int(Slider.value)) mi"
        }
        else{
            Slider.value = 50
            DistanceLabel.text = "\(Int(Slider.value)) mi"

        }
        
        

        
    }

    
    
    func fetchCountryAndCity(myLocation: CLLocation){
        print("fetching country!")
        CLGeocoder().reverseGeocodeLocation(myLocation, completionHandler: {placemarks, error in
            if error == nil {
                print("no error, changing location")
                if let city = placemarks?.first?.locality,
                    let state = placemarks?.first?.administrativeArea{
                    self.LocationLabel.text = "\(city), \(state)"
                }
                
                
            }
            else{
                print("error is not equal to nil!")
            }
        })
    }
    
    @IBAction func ChangeSwitchValue(_ sender: AnyObject){
        isOn = !isOn
        checkIfOn(isOn: isOn)

    }
    
    override func viewWillDisappear(_ animated: Bool) {
        UserDefaults.standard.set("\(isOn!)", forKey: "isOn")
        print("isOn", isOn)
    }
    
    func checkIfOn(isOn: Bool){
        let index1 = IndexPath(row: 1, section: 0)
        let index2 = IndexPath(row: 2, section: 0)
        if isOn{
            
            self.tableView.cellForRow(at: index1)?.isUserInteractionEnabled = false
            self.tableView.cellForRow(at: index2)?.isUserInteractionEnabled = false
            Slider.isEnabled = false
            hasSpecificLocation = false
            MyLocationLabel.textColor = .lightGray
            MaxDistanceLabel.textColor = .lightGray
            LocationLabel.textColor = .lightGray
            DistanceLabel.textColor = .lightGray
            
            
        }
        else{
            tableView.cellForRow(at: index1)?.isUserInteractionEnabled = true
            tableView.cellForRow(at: index2)?.isUserInteractionEnabled = true
            Slider.isEnabled = true
            hasSpecificLocation = true
            MyLocationLabel.textColor = .black
            MaxDistanceLabel.textColor = .black
            LocationLabel.textColor = .gray
            DistanceLabel.textColor = .gray
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    @IBAction func sliderValueChanged(_ sender: AnyObject){
        print("slider value", Slider.value)
        UserDefaults.standard.set(Slider.value, forKey: "sliderValue")
        DistanceLabel.text = "\(Int(Slider.value)) mi"

        
        
        
}
    
    @IBAction func Save(_ sender: AnyObject){
        
    }

}
