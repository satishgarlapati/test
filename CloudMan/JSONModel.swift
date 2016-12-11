//
//  JSONModel.swift
//  CloudMan
//
//  Created by Satish Garlapati on 12/7/16.
//  Copyright © 2016 Satish Garlapati. All rights reserved.
//

import UIKit
import SwiftyJSON

typealias ServiceResponse = (Any,CFTimeInterval, NSError?) -> Void

class JSONModel: NSObject {
    static let sharedInstance = JSONModel()
    
    var baseURL = "https://api.weather.com/v3/location/point?geocode=37.556111,126.91&language=en&format=json&apiKey=3d498bd0777076fb2aa967aa67114c7e"
    
    func getRandomUser(onCompletion: @escaping (Any,CFTimeInterval, NSError?) -> Void) {
        makeHTTPGetRequest(path: baseURL, onCompletion: { data,executionTime, err in
            onCompletion(data,executionTime, err )
        })
    }
    
    // MARK: Perform a GET Request
    func makeHTTPGetRequest(path: String, onCompletion: @escaping ServiceResponse) {
        
        var urlStr: String = path
        if path.characters.count == 0 {
            urlStr = baseURL
        }
        let request = NSMutableURLRequest(url: NSURL(string: urlStr)! as URL)
        
        let session = URLSession.shared
        let start = CFAbsoluteTimeGetCurrent()
        let task = session.dataTask(with: request as URLRequest, completionHandler: {data, response, error -> Void in
            let executionTime = CFAbsoluteTimeGetCurrent() - start
            if let jsonData = data {
                //let json:JSON = JSON(data: jsonData)
                onCompletion(jsonData, executionTime,  error as NSError?)
            } else {
                onCompletion(JSON.null,executionTime, error as NSError?)
            }
        })
        task.resume()
    }
    
    // MARK: Perform a POST Request
    private func makeHTTPPostRequest(path: String, body: [String: AnyObject], onCompletion: @escaping ServiceResponse) {
        let request = NSMutableURLRequest(url: NSURL(string: path)! as URL)
        
        // Set the method to POST
        request.httpMethod = "POST"
        let start = CFAbsoluteTimeGetCurrent()

        do {
            // Set the POST body for the request
            let jsonBody = try JSONSerialization.data(withJSONObject: body, options: .prettyPrinted)
            request.httpBody = jsonBody
            let session = URLSession.shared
            
            let task = session.dataTask(with: request as URLRequest, completionHandler: {data, response, error -> Void in
                let executionTime = CFAbsoluteTimeGetCurrent() - start
                if let jsonData = data {
                    //let json:JSON = JSON(data: jsonData)
                    onCompletion(jsonData, executionTime,  error as NSError?)
                } else {
                    onCompletion(JSON.null, executionTime,  error as NSError?)
                }
            })
            task.resume()
        } catch {
            let executionTime = CFAbsoluteTimeGetCurrent() - start
            // Create your personal error
            onCompletion(JSON.null, executionTime,  error as NSError?)
        }
    }
}
