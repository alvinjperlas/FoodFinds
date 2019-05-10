//
//  FiltersViewController.swift
//  FoodFinds
//
//  Created by Alvin Perlas on 3/10/19.
//  Copyright © 2019 Ken Toh. All rights reserved.
//

import Foundation
import UIKit


protocol FiltersDelegate {
  func userEnteredFilter(data: YelpSearchFilter)
}


class FiltersViewController: UIViewController {
  
  var delegate : FiltersDelegate?
  
  @IBOutlet weak var categoryTextField: UITextField!
  @IBOutlet weak var ratingControl: UISegmentedControl!
  @IBOutlet weak var priceControl: UISegmentedControl!
  @IBOutlet weak var isOpen: UISwitch!
  
  @IBAction func startExploring(_ sender: Any) {
    let category = categoryTextField.text
    let price = String(priceControl.selectedSegmentIndex)
    let rating = ratingControl.selectedSegmentIndex
    let open = isOpen.isOn
    let searchFilter = YelpSearchFilter(
      category: category!,
      rating: rating,
      price: price,
      open: open)
 
    delegate?.userEnteredFilter(data: searchFilter)
    
    //return to previous view
    _ = navigationController?.popViewController(animated: true)
  }
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.hideKeyboardWhenTappedAround()
  }
  
  
  func textFieldShouldReturn(textField: UITextField) -> Bool {
    textField.resignFirstResponder()
    return true
  }
  


}


