//
//  ViewController.swift
//  CloudMan
//
//  Created by Satish Garlapati on 12/7/16.
//  Copyright © 2016 Satish Garlapati. All rights reserved.
//


let REQUEST_TEXT = "Request:"
let HTTP_STATUS_TEXT = "HTTP Status Code:"
let EXECUTION_TIME_TEXT = "Execution Time:"
let RESPONSE_SIZE_TEXT = "Size in KB:"
let RESPONSE_TEXT = "Response:"

let FAILED_EXECUTION_TIME_TEXT = "Failed, Execution Time:"


import UIKit
import SwiftyJSON

class ViewController: UIViewController {

    @IBOutlet weak var viResponse: UIView!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var getBtn: UIButton!
    
    @IBOutlet weak var requestLbl: UILabel!
    @IBOutlet weak var httpStatusLbl: UILabel!
    @IBOutlet weak var responseTimeLbl: UILabel!
    @IBOutlet weak var responseSizeLbl: UILabel!
    @IBOutlet weak var responseBodyTextView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let emptyObj = Response(jsonData: JSON.null,executionTime: 0,httpStatusCode: 0,error: nil)
        updateUIBasedOnResponse(responceObj: emptyObj)

        
        // Do any additional setup after loading the view, typically from a nib.
    }
    func validateUrl (urlString: String?) -> Bool {
        let urlRegEx = "(http|https)://((\\w)*|([0-9]*)|([-|_])*)+([\\.|/]((\\w)*|([0-9]*)|([-|_])*))+"
        return NSPredicate(format: "SELF MATCHES %@", urlRegEx).evaluate(with: urlString)
    }
    @IBAction func getTheDetailsBtn(_ sender: Any) {
        self.view.endEditing(true)
        //self.viResponse.isHidden = true

//        if (textField.text?.characters.count)! > 0
//        {
//            if  validateUrl(urlString: textField.text) == false {
//                showAlertViewController()
//                return
//            }
//        }
        JSONModel.sharedInstance.makeHTTPGetRequest(path: textField.text!, onCompletion: { (responseInfo) in
            
            self.updateUIBasedOnResponse(responceObj: responseInfo)
            /*if err != nil
            {
                DispatchQueue.main.async {
                   self.viResponse.isHidden = false
                    self.responseTimeLbl.text = String(format: "Failed, Execution Time: %.2f", CGFloat(executionTime))
                    self.responseSizeLbl.text = ""
                    self.responseBodyTextView.text = ""
                }
                
            }else
            {
                let jsonData: NSData = data as! NSData
                DispatchQueue.main.async {
                    self.viResponse.isHidden = false
                    self.responseTimeLbl.text = String(format: "Execution Time: %.2f", CGFloat(executionTime))
                    self.responseSizeLbl.text = String(format: "Size in KB: %.2f", Double(jsonData.length)/1024.00)
                    
                    let dataString = String(data: jsonData as Data, encoding: String.Encoding.utf8)
                    self.responseBodyTextView.text = dataString
                }
                
                
            }*/
//            let jsonData: NSData = data as! NSData
//            print("The size is length:\(jsonData.length)")
//            print("The size is KB    :\(Double(jsonData.length)/1024.00)")
//            print("The Time is       :\(CGFloat(executionTime))")
//            let json:JSON = JSON(data: jsonData as Data)
//            print("The content is :\(json)")
        })

        /*
        JSONModel.sharedInstance.getRandomUser { (data,executionTime, err) in
            let jsonData: NSData = data as! NSData
            print("The size is length:\(jsonData.length)")
            print("The size is KB    :\(Double(jsonData.length)/1024.00)")
            print("The Time is       :\(CGFloat(executionTime))")
            
            let json:JSON = JSON(data: jsonData as Data)
            print("The content is :\(json)")
        }*/
        
    }
    func showAlertViewController() -> Void {
        let alert = UIAlertController(title: "CloudMan", message: "Inavalid URL Format", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    func updateUIBasedOnResponse(responceObj:Response) -> Void{
        DispatchQueue.main.async {
            
            if (responceObj.error == nil && responceObj.httpStatusCode == 0 && responceObj.executionTime == 0)
            {
                self.requestLbl.text = String(format: "%@ Not Available", REQUEST_TEXT)
                self.httpStatusLbl.text = String(format: "%@ Not Available", HTTP_STATUS_TEXT)
                self.responseTimeLbl.text = String(format: "%@ Not Available", EXECUTION_TIME_TEXT)
                self.responseSizeLbl.text = String(format: "%@ Not Available", RESPONSE_SIZE_TEXT)
                self.responseBodyTextView.text = String(format: "%@ Not Available", RESPONSE_TEXT)
                return
            }
            
            if responceObj.error != nil
            {
                self.requestLbl.text = self.textField.text!
                self.httpStatusLbl.text = String(format: "%@ %d", HTTP_STATUS_TEXT, responceObj.httpStatusCode)

                self.responseTimeLbl.text = String(format: "%@ %.2f", FAILED_EXECUTION_TIME_TEXT, CGFloat(responceObj.executionTime))
                self.responseSizeLbl.text = ""
                self.responseBodyTextView.text = ""
                
            }else
            {
                self.requestLbl.text = self.textField.text!
                self.httpStatusLbl.text = String(format: "%@ %d", HTTP_STATUS_TEXT, responceObj.httpStatusCode)

                self.responseTimeLbl.text = String(format: "%@ %.2f", EXECUTION_TIME_TEXT ,CGFloat(responceObj.executionTime))
                let jsonData: NSData = responceObj.jsonData as! NSData
                self.responseSizeLbl.text = String(format: "%@ %.2f", RESPONSE_SIZE_TEXT, Double(jsonData.length)/1024.00)
                
                let dataString = String(data: jsonData as Data, encoding: String.Encoding.utf8)
                self.responseBodyTextView.text = String(format: "%@ %@", RESPONSE_TEXT, dataString!)
                
            }
        }
    }
}

