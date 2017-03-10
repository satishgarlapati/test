//
//  JSONModel.swift
//  CloudMan
//
//  Created by Satish Garlapati on 12/7/16.
//  Copyright © 2016 Satish Garlapati. All rights reserved.
//

import UIKit
import SwiftyJSON

typealias ServiceResponse = (Response) -> Void

class JSONModel: NSObject {
    
    static let sharedInstance = JSONModel()
    
    var baseURL = "https://api.weather.com/v3/location/point?geocode=37.556111,126.91&language=en&format=json&apiKey=3d498bd0777076fb2aa967aa67114c7e"
    
    // MARK: Perform a GET Request
    func makeHTTPGetRequest(path: String, onCompletion: @escaping ServiceResponse) {
        
        var urlStr: String = path
        if path.characters.count == 0 {
            urlStr = baseURL
        }else if !path.contains("http") {
            urlStr = "http://" + path
        }
        let request = NSMutableURLRequest(url: NSURL(string: urlStr)! as URL)
        
        let session = URLSession.shared
        let start = CFAbsoluteTimeGetCurrent()
        let task = session.dataTask(with: request as URLRequest, completionHandler: {data, response, error -> Void in
            let executionTime = CFAbsoluteTimeGetCurrent() - start
            
            if response == nil {
                let nc = NotificationCenter.default
                nc.post(name: Notification.Name("invalid url"), object: nil)
                return
            }
            let httpResponse = response as! HTTPURLResponse
            //print("error \(httpResponse.statusCode)")
            if let jsonData = data {
                let responceObj = Response(jsonData: jsonData,executionTime: executionTime,httpURLResponse: httpResponse,error: nil)
                DBManager.sharedInstance.insertOrUpdateAPI(apiURL: urlStr, isSuccess: true)
                onCompletion(responceObj)
                //
            } else {
                let responceObj = Response(jsonData: JSON.null,executionTime: executionTime,httpURLResponse: httpResponse,error: error as! NSError)
                DBManager.sharedInstance.insertOrUpdateAPI(apiURL: urlStr, isSuccess: false)
                onCompletion(responceObj)
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
                let httpResponse = response as! HTTPURLResponse
                if let jsonData = data {
                    //let json:JSON = JSON(data: jsonData)
                    let responceObj = Response(jsonData: jsonData,executionTime: executionTime,httpURLResponse: httpResponse,error: error as! NSError)
                    onCompletion(responceObj)
                } else {
                    let responceObj = Response(jsonData: JSON.null,executionTime: executionTime,httpURLResponse: httpResponse,error: error as! NSError)
                    onCompletion(responceObj)

                }
            })
            task.resume()
        } catch {
            let executionTime = CFAbsoluteTimeGetCurrent() - start
            // Create your personal error
            let responceObj = Response(jsonData: JSON.null,executionTime: executionTime,httpURLResponse:HTTPURLResponse(),error:nil)
            onCompletion(responceObj)
        }
    }
}

class Response {
    var jsonData: Any
    var executionTime: CFTimeInterval
    var httpURLResponse : HTTPURLResponse
    var error: Any?

    init(jsonData: Any,executionTime: CFTimeInterval,httpURLResponse: HTTPURLResponse,error: Any?) {
        self.jsonData = jsonData
        self.executionTime = executionTime
        self.httpURLResponse = httpURLResponse
        self.error = error
    }
}
