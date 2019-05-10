//
//  YelpDataModel.swift
//  FoodFinds
//
//  Created by Alvin Perlas on 2/15/19.
//  Copyright © 2019 alvinperlas. All rights reserved.
//
import UIKit
import Foundation



class YelpCategory{
    var alias : String = ""
    var title : String = ""
}
class YelpCoordinate{
    var latitude : Double!
    var longitude : Double!
}
class YelpLocation{
    var address1 : String = ""
    var address2 : String = ""
    var address3 : String = ""
    var city : String = ""
    var zip_code : String = ""
    var country : String = ""
    var state : String = ""
}
/*
"categories": [
{
"alias": "bubbletea",
"title": "Bubble Tea"
}*/

class YelpDataModel{
    var businessID : String = ""
    var alias : String = ""
    var name : String = ""
    var image_url : String = ""
    var is_closed : Bool = true
    var url : String = ""
    var review_count : Int = 0
    //var categories : [YelpCategory]!
    var rating : Double = 0
    var coordinate : YelpCoordinate!
    var transaction : [String]!
    var price : String = ""
    var location : YelpLocation!
    var phone : String!
    var displayPhone : String = ""
    var distance : Double!
  
  var categoryList : [String]!
}

class YelpSearchFilter{
    var category : String!
    var rating : Int!
    var price : String!
    var open : Bool!
    
    init(category: String, rating: Int, price: String, open: Bool){
        self.category = category
        self.rating = rating
        self.price = price
        self.open = open
    }
}
/*
 {
 "businesses": [
 {
 "id": "CoWXE9RoL2vuZBjuKque8Q",
 "alias": "luckys-boba-tea-tucson",
 "name": "Lucky's Boba Tea",
 "image_url": "https://s3-media2.fl.yelpcdn.com/bphoto/mMcRsxkSWj5tg-J87JTcBQ/o.jpg",
 "is_closed": false,
 "url": "https://www.yelp.com/biz/luckys-boba-tea-tucson?adjust_creative=VgKiArW_QzF_M0scNN5CMg&utm_campaign=yelp_api_v3&utm_medium=api_v3_business_search&utm_source=VgKiArW_QzF_M0scNN5CMg",
 "review_count": 13,
 "categories": [
     {
     "alias": "bubbletea",
     "title": "Bubble Tea"
     }
    ],
 "rating": 4.5,
 "coordinates": {
 "latitude": 32.3744049072266,
 "longitude": -111.124366760254
 },
 "transactions": [],
 "price": "$",
 "location": {
     "address1": "7455 W Twin Peaks Rd",
     "address2": "",
     "address3": "",
     "city": "Tucson",
     "zip_code": "85743",
     "country": "US",
     "state": "AZ",
     "display_address": [
     "7455 W Twin Peaks Rd",
     "Tucson, AZ 85743"
     ]
 },
 "phone": "+15203288710",
 "display_phone": "(520) 328-8710",
 "distance": 97.18359299641602
 }
 ],
 "total": 1,
 "region": {
 "center": {
 "longitude": -111.125525,
 "latitude": 32.374331
 }
 }
 }*/
