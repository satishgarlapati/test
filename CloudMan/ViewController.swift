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


class ViewController: UIViewController , UITextFieldDelegate, HistoryApiSelectionDelegate,UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var viResponse: UIView!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var getBtn: UIButton!
    @IBOutlet weak var openWebviewBtn: UIButton!
    
    @IBOutlet weak var headersTblView: UITableView!
    @IBOutlet weak var segmentControl: UISegmentedControl!
    @IBOutlet weak var httpStatusLbl: UILabel!
    @IBOutlet weak var responseTimeLbl: UILabel!
    @IBOutlet weak var responseSizeLbl: UILabel!
    @IBOutlet weak var bodyTextView: UITextView!
    
    var myResponseObj : Response?
    @IBOutlet weak var openWebBtnHeight: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        myResponseObj = Response(jsonData: JSON.null,executionTime: 0,httpURLResponse: HTTPURLResponse(),error: nil)
        updateUIBasedOnResponse(responceObj: myResponseObj!)
        headersTblView.tableFooterView = UIView()
        textField.delegate = self;

        openWebviewBtn.isEnabled = false;
        segmentControl.selectedSegmentIndex = 0
        headersTblView.isHidden = true
        showOrHideOpenWebButton(isShow: false)
        self.textField.text = "http://"
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    @IBAction func showApiInWebView(_ sender: UIButton) {
        
        self.performSegue(withIdentifier: "webviewController", sender:self)
        
    }
    
    @IBAction func onSegmentSelection(_ sender: UISegmentedControl) {
        
        switch sender.selectedSegmentIndex {
        case 0:
            bodyTextView.isHidden = false
            headersTblView.isHidden = true
        case 1 :
            bodyTextView.isHidden = true
            headersTblView.isHidden = false
            headersTblView .reloadData()
        case 2:
            bodyTextView.isHidden = true
            headersTblView.isHidden = false
            headersTblView .reloadData()
        default: break
        }
    }
    
    @IBAction func getTheDetailsBtn(_ sender: Any) {
        self.view.endEditing(true)
        
        if (textField.text?.characters.count)! > 0
        {
            if validateUrl(string: textField.text) == false{
                showAlertViewController()
                return
            }
        }
        
        JSONModel.sharedInstance.makeHTTPGetRequest(path: textField.text!, onCompletion: { (responseInfo) in
            self.updateUIBasedOnResponse(responceObj: responseInfo)
        })
        NotificationCenter.default.addObserver(self, selector: #selector(showAlertViewController), name: Notification.Name("invalid url"), object: nil)
    }
    
    func validateUrl(string: String?) -> Bool {
        guard let urlString = string else {return false}
        guard let url = NSURL(string: urlString) else {return false}
        if !UIApplication.shared.canOpenURL(url as URL) {return false}
        
        let regEx = "((https|http)://)((\\w|-)+)(([.]|[/])((\\w|-)+))+"
        let predicate = NSPredicate(format:"SELF MATCHES %@", argumentArray:[regEx])
        return predicate.evaluate(with: string)
    }
    
    func showAlertViewController() -> Void {
        let alert = UIAlertController(title: "CloudMan", message: "Inavalid URL Format", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func updateUIBasedOnResponse(responceObj:Response) -> Void{
        weak var weakSelf = self
        weakSelf?.myResponseObj = responceObj;
        weakSelf?.headersTblView.reloadData()
        DispatchQueue.main.async {
            let httpResp = responceObj.httpURLResponse as HTTPURLResponse
            
            let cookiesArr = HTTPCookie.cookies(withResponseHeaderFields: httpResp.allHeaderFields as! [String : String], for: NSURL(string: (weakSelf?.textField.text)!)! as URL)
            print(cookiesArr)
            
            if (responceObj.error == nil && httpResp.statusCode == 0 && responceObj.executionTime == 0)
            {
                weakSelf?.httpStatusLbl.attributedText = weakSelf?.createAttrString(string: String(format: "%@ NA", HTTP_STATUS_TEXT), boldStr: HTTP_STATUS_TEXT)
                weakSelf?.responseTimeLbl.attributedText = weakSelf?.createAttrString(string: String(format: "%@ NA", EXECUTION_TIME_TEXT), boldStr: EXECUTION_TIME_TEXT)
                weakSelf?.responseSizeLbl.attributedText = weakSelf?.createAttrString(string: String(format: "%@ NA", RESPONSE_SIZE_TEXT), boldStr: RESPONSE_SIZE_TEXT)
                return
            }
            
            if responceObj.error != nil
            {
                weakSelf?.httpStatusLbl.text = String(format: "%@ %d", HTTP_STATUS_TEXT, httpResp.statusCode)

                weakSelf?.responseTimeLbl.text = String(format: "%@ %.2f", FAILED_EXECUTION_TIME_TEXT, CGFloat(responceObj.executionTime))
                weakSelf?.responseSizeLbl.text = ""
                self.bodyTextView.text = ""
                weakSelf?.showOrHideOpenWebButton(isShow: false)
            }else
            {
                weakSelf?.httpStatusLbl.text = String(format: "%@ %d", HTTP_STATUS_TEXT, httpResp.statusCode)

                weakSelf?.responseTimeLbl.text = String(format: "%@ %.2f", EXECUTION_TIME_TEXT ,CGFloat(responceObj.executionTime))
                let jsonData: NSData = responceObj.jsonData as! NSData
                weakSelf?.responseSizeLbl.text = String(format: "%@ %.2f", RESPONSE_SIZE_TEXT, Double(jsonData.length)/1024.00)
                
                let dataString : String? = String(data: jsonData as Data, encoding: String.Encoding.utf8)
                
                guard let str = dataString else{
                    weakSelf?.showOrHideOpenWebButton(isShow: true)
                    return
                }
                self.bodyTextView.text = String(format: "%@ %@", RESPONSE_TEXT, str)
                weakSelf?.showOrHideOpenWebButton(isShow: true)
            }
        }
    }
    
    func showOrHideOpenWebButton(isShow:Bool) -> Void {
        if isShow {
            openWebviewBtn.alpha = 1
            openWebviewBtn.isHidden = false
        }else
        {
            openWebviewBtn.alpha = 0.6
            openWebviewBtn.isHidden = true
        }
        openWebviewBtn.isEnabled = isShow;
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
    
    func createAttrString(string:String, boldStr:String) -> NSMutableAttributedString {
        
        let attrString = NSMutableAttributedString(string: string);
        let myAttributes = [NSFontAttributeName : UIFont.boldSystemFont(ofSize: 15)]
        attrString.addAttributes(myAttributes, range: NSMakeRange(0, boldStr.characters.count))
        return attrString
    }
    
    func goForSelectedAPI(_ apiURL: String) {
        textField.text = apiURL
        showOrHideOpenWebButton(isShow: false)

    }
    
    //Mark -- TextView Delegate    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let  char = string.cString(using: String.Encoding.utf8)!
        let isBackSpace = strcmp(char, "\\b")
        
        if (isBackSpace == -92) {
            showOrHideOpenWebButton(isShow: false)
        }
        return true
    }
    
    //Pragma Mark:- TableViewDataSourceAnd Delgate
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        if myResponseObj == nil{
            return 0
        }
        if segmentControl.selectedSegmentIndex == 0 {
            return (myResponseObj?.httpURLResponse.allHeaderFields.count)!
        }
        return (myResponseObj?.httpURLResponse.allHeaderFields.count)!

    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        let cell = tableView.dequeueReusableCell(withIdentifier: "UITableViewCell", for:indexPath)
        let headerFieldsDict = myResponseObj?.httpURLResponse.allHeaderFields as? Dictionary<String, AnyObject>
        let contentKey = Array(headerFieldsDict!.keys)[indexPath.row]
        let contentValue = headerFieldsDict![contentKey] as! String
        
        let attrString = NSMutableAttributedString(string: contentKey + " → " + contentValue);
        let myAttributes = [NSFontAttributeName : UIFont.boldSystemFont(ofSize: 15)]
        attrString.addAttributes(myAttributes, range: NSMakeRange(0, contentKey.characters.count))
        
        cell.textLabel?.attributedText = attrString//contentKey + " → " + contentValue
        //createAttrString(string: contentValue , boldStr: contentKey + " ➡ ")
        return cell
    }
}

