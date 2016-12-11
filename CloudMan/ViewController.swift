//
//  ViewController.swift
//  CloudMan
//
//  Created by Satish Garlapati on 12/7/16.
//  Copyright © 2016 Satish Garlapati. All rights reserved.
//

import UIKit
import SwiftyJSON

class ViewController: UIViewController {

    @IBOutlet weak var viResponse: UIView!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var getBtn: UIButton!
    @IBOutlet weak var responseTimeLbl: UILabel!
    @IBOutlet weak var responseSizeLbl: UILabel!
    @IBOutlet weak var responseBodyTextView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.viResponse.isHidden = true
        // Do any additional setup after loading the view, typically from a nib.
    }
    func validateUrl (urlString: String?) -> Bool {
        let urlRegEx = "(http|https)://((\\w)*|([0-9]*)|([-|_])*)+([\\.|/]((\\w)*|([0-9]*)|([-|_])*))+"
        return NSPredicate(format: "SELF MATCHES %@", urlRegEx).evaluate(with: urlString)
    }
    @IBAction func getTheDetailsBtn(_ sender: Any) {
        self.view.endEditing(true)
        self.viResponse.isHidden = true

//        if (textField.text?.characters.count)! > 0
//        {
//            if  validateUrl(urlString: textField.text) == false {
//                showAlertViewController()
//                return
//            }
//        }
        JSONModel.sharedInstance.makeHTTPGetRequest(path: textField.text!, onCompletion: { (data,executionTime, err) in
            
            if err != nil
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
            }
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

}

