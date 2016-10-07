//
//  InterfaceController.swift
//  BitPrice WatchKit Extension
//
//  Created by Nick Walter on 9/29/16.
//  Copyright © 2016 Zappy Code. All rights reserved.
//

import WatchKit
import Foundation


class InterfaceController: WKInterfaceController {
    
    @IBOutlet var updatingLabel: WKInterfaceLabel!
    @IBOutlet var priceLabel: WKInterfaceLabel!
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        
        if let price = UserDefaults.standard.value(forKey: "price") as? NSNumber {
            // We have a previous price
            updatingLabel.setText("Updating...")
            let formatter = NumberFormatter()
            formatter.numberStyle = .currency
            formatter.locale = Locale(identifier: "en_US")
            
            self.priceLabel.setText(formatter.string(from: price))
        } else {
            priceLabel.setText("Getting Price...")
            updatingLabel.setText("")
        }
        
        getPrice()
        
        
        
    }
    
    func getPrice() {
        
        let url = URL(string: "https://api.coindesk.com/v1/bpi/currentprice.json")!
        
        URLSession.shared.dataTask(with: url) { (data:Data?, response:URLResponse?, error:Error?) in
            if error == nil {
                print("It worked")
                
                if data != nil {
                    do {
                        let json = try JSONSerialization.jsonObject(with: data!, options: []) as! [String:Any]
                        
                        guard let bpi = json["bpi"] as? [String:Any], let USD = bpi["USD"] as? [String:Any], let price = USD["rate_float"] as? NSNumber else {
                            return
                        }
                        
                        let formatter = NumberFormatter()
                        formatter.numberStyle = .currency
                        formatter.locale = Locale(identifier: "en_US")
                        
                        self.priceLabel.setText(formatter.string(from: price))
                        self.updatingLabel.setText("Updated")
                        
                        UserDefaults.standard.set(price, forKey: "price")
                        UserDefaults.standard.synchronize()
                        
                        if CLKComplicationServer.sharedInstance().activeComplications != nil {
                            
                            for comp in CLKComplicationServer.sharedInstance().activeComplications! {
                                CLKComplicationServer.sharedInstance().reloadTimeline(for: comp)
                            }
                        }
                        
                    } catch {}
                    
                    
                }
                
            } else {
                print("It's broke!")
            }
            }.resume()
    }
    
}
