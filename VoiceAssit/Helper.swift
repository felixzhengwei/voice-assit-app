//
//  Helper.swift
//  VoiceAssit
//
//  Created by Felix Wei on 2017-04-30.
//  Copyright © 2017 Felix Wei. All rights reserved.
//
import UIKit
import Foundation

class Helper{
    static func postRequest(message: String)  {
        let id = UIDevice.current.identifierForVendor!.uuidString
        // do a post request and return post data
        let json = ["patient_id": id, "transcription": message] as Dictionary<String, String>
        let jsonData = try? JSONSerialization.data(withJSONObject: json)
        
        let url = URL(string:"https://obscure-anchorage-60064.herokuapp.com/api/requests")!
        var request = URLRequest(url: url as URL)
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        request.httpBody = jsonData
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print(error?.localizedDescription ?? "No data")
                return
            }
            let responseJSON = try? JSONSerialization.jsonObject(with: data, options: [])
            if let responseJSON = responseJSON as? [String: Any] {
                print(responseJSON)
            }
        }
        task.resume()

    }
}
