//
//  Created by Alvin Perlas on 2/15/19.
//  Copyright © 2019 alvinperlas. All rights reserved.
//

import UIKit




//Write the protocol declaration here:
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
        
        let searchFilter = YelpSearchFilter(category: category!, rating: rating,price: price,open: open)
    
        delegate?.userEnteredFilter(data: searchFilter)
        self.dismiss(animated: true, completion: nil)
    }
    
    
    
    @IBAction func backButtonPressed(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    
    
    
    
    
    
}
