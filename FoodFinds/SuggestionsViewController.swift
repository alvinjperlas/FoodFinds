//
//  SuggestionsViewController.swift
//  FoodFinds
//
//  Created by Alvin Perlas on 3/10/19.
//  Copyright © 2019 Ken Toh. All rights reserved.
//

import Foundation
import UIKit




class SuggestionsViewController: UIViewController, UITableViewDataSource{
  
  var delegate : UITableViewDelegate?
  
  
  
  private var data: [String] = []
  var suggestedPlaces : [String:YelpDataModel] = [:] //business
  
  @IBOutlet weak var tableView: UITableView!
  
 /*
   
   // Get the index path from the cell that was tapped
   
   // Get the Row of the Index Path and set as index
  
   // Get in touch with the DetailViewController
   let detailViewController = segue.destinationViewController as! DetailViewController
   // Pass on the data to the Detail ViewController by setting it's indexPathRow value
   detailViewController.index = index          */
  
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "seeBusiness" {
      let destinationVC = segue.destination as! BusinessViewController
      let indexPath = tableView.indexPathForSelectedRow
      let index = indexPath?.row
      let businessID = data[index!]
      destinationVC.BusinessData = suggestedPlaces[businessID]!
    }
  }
    
    
  
  func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
//
//    for i in 0...1000 {
//      data.append("\(i)")
//    }
    
    for names in suggestedPlaces.keys{
      data.append(names)
    }
    
    tableView.dataSource = self
  }

  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return data.count
  }
  
  



  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "cellReuseIdentifier") as! CustomTableViewCell
    
    let businessID = data[indexPath.row]
    
    cell.Name.text = suggestedPlaces[businessID]?.name
    cell.Category.text = suggestedPlaces[businessID]?.categoryList.joined(separator: ", ")
    return cell
  }
}


class CustomTableViewCell: UITableViewCell{
  
  
  @IBOutlet weak var Name: UILabel!
  
  @IBOutlet weak var Category: UILabel!
  
  
  override func awakeFromNib() {
    super.awakeFromNib()
  }
  
  override func setSelected(_ selected: Bool, animated: Bool){
    super.setSelected(selected, animated: animated)
  }
  
  
  
}

