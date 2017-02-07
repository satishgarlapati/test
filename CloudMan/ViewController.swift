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


class ViewController: UIViewController , UITextFieldDelegate, HistoryApiSelectionDelegate {

    @IBOutlet weak var viResponse: UIView!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var getBtn: UIButton!
    
    @IBOutlet weak var requestLbl: UILabel!
    @IBOutlet weak var httpStatusLbl: UILabel!
    @IBOutlet weak var responseTimeLbl: UILabel!
    @IBOutlet weak var responseSizeLbl: UILabel!
    @IBOutlet weak var responseBodyTextView: UITextView!
    
    @IBOutlet weak var openWebBtnHeight: NSLayoutConstraint!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let emptyObj = Response(jsonData: JSON.null,executionTime: 0,httpStatusCode: 0,error: nil)
        updateUIBasedOnResponse(responceObj: emptyObj)
        textField.delegate = self;
        openWebBtnHeight.constant = 0;
        // Do any additional setup after loading the view, typically from a nib.
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    func validateUrl (urlString: String?) -> Bool {
        let urlRegEx = "(http|https)://((\\w)*|([0-9]*)|([-|_])*)+([\\.|/]((\\w)*|([0-9]*)|([-|_])*))+"
        return NSPredicate(format: "SELF MATCHES %@", urlRegEx).evaluate(with: urlString)
    }
    @IBAction func showApiInWebView(_ sender: UIButton) {
        
        self.performSegue(withIdentifier: "webviewController", sender:self)
        
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
                self.requestLbl.attributedText = self.createAttrString(string: String(format: "%@ Not Available", REQUEST_TEXT), boldStr: REQUEST_TEXT)
                self.httpStatusLbl.attributedText = self.createAttrString(string: String(format: "%@ Not Available", HTTP_STATUS_TEXT), boldStr: HTTP_STATUS_TEXT)
                self.responseTimeLbl.attributedText = self.createAttrString(string: String(format: "%@ Not Available", EXECUTION_TIME_TEXT), boldStr: EXECUTION_TIME_TEXT)
                self.responseSizeLbl.attributedText = self.createAttrString(string: String(format: "%@ Not Available", RESPONSE_SIZE_TEXT), boldStr: RESPONSE_SIZE_TEXT)
                self.responseBodyTextView.attributedText = self.createAttrString(string: String(format: "%@ Not Available", RESPONSE_TEXT), boldStr: RESPONSE_TEXT)
                return
            }
            
            if responceObj.error != nil
            {
                self.requestLbl.text = String(format: "%@ %@", REQUEST_TEXT ,self.textField.text!)
                self.httpStatusLbl.text = String(format: "%@ %d", HTTP_STATUS_TEXT, responceObj.httpStatusCode)

                self.responseTimeLbl.text = String(format: "%@ %.2f", FAILED_EXECUTION_TIME_TEXT, CGFloat(responceObj.executionTime))
                self.responseSizeLbl.text = ""
                self.responseBodyTextView.text = ""
                self.openWebBtnHeight.constant = 0;
            }else
            {
                self.requestLbl.text = String(format: "%@ %@", REQUEST_TEXT ,self.textField.text!)
                self.httpStatusLbl.text = String(format: "%@ %d", HTTP_STATUS_TEXT, responceObj.httpStatusCode)

                self.responseTimeLbl.text = String(format: "%@ %.2f", EXECUTION_TIME_TEXT ,CGFloat(responceObj.executionTime))
                let jsonData: NSData = responceObj.jsonData as! NSData
                self.responseSizeLbl.text = String(format: "%@ %.2f", RESPONSE_SIZE_TEXT, Double(jsonData.length)/1024.00)
                
                let dataString : String? = String(data: jsonData as Data, encoding: String.Encoding.utf8)
                
                guard let str = dataString else{
                    self.responseBodyTextView.text = String(format: "%@ %@", RESPONSE_TEXT, "RESPONSE IS NOT HTML")
                    self.openWebBtnHeight.constant = 40;
                    return
                }
                self.responseBodyTextView.text = String(format: "%@ %@", RESPONSE_TEXT, str)
                self.openWebBtnHeight.constant = 40;
                
            }/*
            let alertController = UIAlertController(title: "CloudMan", message: "You can view the API in webview, Do you want to open in webview ?", preferredStyle: .alert)
            
            let cancelAction: UIAlertAction = UIAlertAction(title: "Cancel", style: .default) { action -> Void in
                //Just dismiss the action sheet
            }
            alertController.addAction(cancelAction)
            
            let openAction: UIAlertAction = UIAlertAction(title: "Open", style: .destructive) { action -> Void in
                self.performSegue(withIdentifier: "webviewController", sender:self)
            }
            alertController.addAction(openAction)
            self.present(alertController, animated: true, completion: nil)
            */
            //if !self.canOpenURL(url: self.textField.text!){}
            
        }
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.destination is webviewController {
            let dVC = segue.destination as! webviewController
            dVC.apiURL = textField.text!
        }else if segue.destination is HistoryVC {
            let dVC = segue.destination as! HistoryVC
            dVC.delegate = self
        }
    }
    func canOpenURL(url: String ) -> Bool {
        let urlRegEx = "^http(?:s)?://(?:w{3}\\.)?(?!w{3}\\.)(?:[\\p{L}a-zA-Z0-9\\-]+\\.){1,}(?:[\\p{L}a-zA-Z]{2,})/(?:\\S*)?$"
        let urlTest = NSPredicate(format: "SELF MATCHES %@", urlRegEx)
        return urlTest.evaluate(with: url)
    }
    func createAttrString(string:String, boldStr:String) -> NSMutableAttributedString {
        
        let attrString = NSMutableAttributedString(string: string);
        let myAttributes = [NSFontAttributeName : UIFont.boldSystemFont(ofSize: 15)]
        attrString.addAttributes(myAttributes, range: NSMakeRange(0, boldStr.characters.count))
        return attrString
    }
    func goForSelectedAPI(_ apiURL: String) {
        textField.text = apiURL
        openWebBtnHeight.constant = 0;

    }
    //Mark -- TextView Delegate
    func textFieldDidBeginEditing(_ textField: UITextField)
    {
        self.openWebBtnHeight.constant = 0;
    }
}

