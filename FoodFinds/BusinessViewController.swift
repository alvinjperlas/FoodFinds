//
//  BusinessViewController.swift
//  FoodFinds
//
//  Created by Alvin Perlas on 4/25/19.
//  Copyright © 2019 Ken Toh. All rights reserved.
//

import Foundation
import UIKit


class BusinessViewController: UIViewController {


  @IBOutlet weak var Name: UILabel!
  @IBOutlet weak var Category: UILabel!
  @IBOutlet weak var Price: UILabel!
  @IBOutlet weak var Stars: UILabel!
  @IBOutlet weak var Address1: UILabel!
  @IBOutlet weak var Address2: UILabel!
  @IBOutlet weak var Address3: UILabel!
  
  
  var BusinessData : YelpDataModel?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    UpdateBusinessPage(data: BusinessData!)
  }
  
  
  func UpdateBusinessPage(data: YelpDataModel){
    Name.text = data.name
    Category.text = data.categoryList.joined(separator: ", ")
    Price.text = data.price
    Stars.text = String(format:"%f", data.rating)
    Address1.text = data.location.address1
    Address2.text = data.location.address2
    Address3.text = data.location.city + ", " + data.location.state
    
  }
  
}
