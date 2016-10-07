//
//  ComplicationController.swift
//  BitPrice WatchKit Extension
//
//  Created by Nick Walter on 9/29/16.
//  Copyright © 2016 Zappy Code. All rights reserved.
//

import ClockKit


class ComplicationController: NSObject, CLKComplicationDataSource {
    
    // MARK: - Timeline Configuration
    
    func getSupportedTimeTravelDirections(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTimeTravelDirections) -> Void) {
        handler([])
    }
    
    // MARK: - Timeline Population
    
    func getCurrentTimelineEntry(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTimelineEntry?) -> Void) {
        // Call the handler with the current timeline entry
        
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
                        
                        let intPrice = Int(price)
                        
                        if complication.family == .modularSmall {
                            let template = CLKComplicationTemplateModularSmallStackText()
                            template.line1TextProvider = CLKSimpleTextProvider(text: "BIT")
                            template.line2TextProvider = CLKSimpleTextProvider(text: "\(intPrice)")
                            
                            let entry = CLKComplicationTimelineEntry(date: Date(), complicationTemplate: template)
                            handler(entry)
                        }
                        if complication.family == .modularLarge {
                            let template = CLKComplicationTemplateModularLargeStandardBody()
                            template.headerTextProvider = CLKSimpleTextProvider(text: "BitPrice")
                            
                            let formatter = NumberFormatter()
                            formatter.numberStyle = .currency
                            formatter.locale = Locale(identifier: "en_US")
                            
                            template.body1TextProvider = CLKSimpleTextProvider(text: formatter.string(from: price)!)
                            
                            let entry = CLKComplicationTimelineEntry(date: Date(), complicationTemplate: template)
                            handler(entry)
                        }
                        
                    } catch {}
                    
                    
                }
                
            } else {
                print("It's broke!")
            }
            }.resume()
        
        
        
    }
    
    // MARK: - Placeholder Templates
    
    func getLocalizableSampleTemplate(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTemplate?) -> Void) {
        // This method will be called once per supported complication, and the results will be cached
        
        if complication.family == .modularSmall {
            let template = CLKComplicationTemplateModularSmallStackText()
            template.line1TextProvider = CLKSimpleTextProvider(text: "BIT")
            template.line2TextProvider = CLKSimpleTextProvider(text: "$$$")
            handler(template)
        }
        if complication.family == .modularLarge {
            let template = CLKComplicationTemplateModularLargeStandardBody()
            template.headerTextProvider = CLKSimpleTextProvider(text: "BitPrice")
            template.body1TextProvider = CLKSimpleTextProvider(text: "$1,456.78")
            
            handler(template)
        }
    }
    
}
