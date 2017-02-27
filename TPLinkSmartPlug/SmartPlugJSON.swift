//
//  JsonUtils.swift
//  HS100-iOS
//
//  Created by Colin Harris on 24/2/17.
//  Copyright © 2017 ThoughtWorks. All rights reserved.
//

import Foundation

class SmartPlugJSON {
    
    class func toJson(_ content: [String: Any]) -> String? {
        do
        {
            let jsonData = try JSONSerialization.data(withJSONObject: content, options: .prettyPrinted)
            return String(data: jsonData, encoding: String.Encoding.ascii)
        } catch {
            print("Error encoding json: \(error.localizedDescription)")
            return nil
        }
    }
    
    class func fromJson(_ content: String) -> [String: Any]? {
        do
        {
            let object = try JSONSerialization.jsonObject(with: content.data(using: String.Encoding.ascii)!, options: .allowFragments)
            return object as? [String: Any]
        } catch {
            print("Error decoding json: \(error.localizedDescription)")
            return nil
        }
    }
    
}
