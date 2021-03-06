//
//  ScanCodeViewCtrl.swift
//  oneCampusParent
//
//  Created by Cloud on 8/25/15.
//  Copyright (c) 2015 ischool. All rights reserved.
//

import UIKit
import AVFoundation

class ScanCodeViewCtrl: UIViewController,AVCaptureMetadataOutputObjectsDelegate,UIAlertViewDelegate,UIWebViewDelegate {
    
    var _captureSession: AVCaptureSession? = nil
    var _videoPreviewLayer: AVCaptureVideoPreviewLayer? = nil
    
    @IBOutlet var _videoPreview: UIView!
    
    var webView : UIWebView!
    
    var _DsnsItem : DsnsItem!
    var _Code : String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //self.view.backgroundColor = UIColor(patternImage: UIImage(named: "childBackground.jpg")!)
        
        webView = UIWebView()
        webView.hidden = true
        webView.delegate = self
        
        _videoPreview.layer.masksToBounds = true
        _videoPreview.layer.cornerRadius = 5
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(animated: Bool) {
        
        self.webView.frame = self.view.bounds
        self.view.addSubview(self.webView)
        
        startReading()
    }
    
    override func viewWillDisappear(animated: Bool) {
        stopReading()
    }
    
    func startReading() -> Bool{
        
        //lblResult.text = "Scanning..."
        
        var error: NSError?
        
        let captureDevice: AVCaptureDevice = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
        
        let input: AVCaptureDeviceInput?
        do {
            input = try AVCaptureDeviceInput(device: captureDevice)
        } catch var error1 as NSError {
            error = error1
            input = nil
        }
        
        var output: AVCaptureMetadataOutput = AVCaptureMetadataOutput()
        
        _captureSession = AVCaptureSession()
        _captureSession?.addInput(input)
        _captureSession?.addOutput(output)
        
        var dispatchQueue: dispatch_queue_t = dispatch_queue_create("myQueue", nil);
        
        output.setMetadataObjectsDelegate(self, queue: dispatchQueue)
        output.metadataObjectTypes = [AVMetadataObjectTypeQRCode]
        
        _videoPreviewLayer = AVCaptureVideoPreviewLayer(session: _captureSession)
        _videoPreviewLayer?.videoGravity = AVLayerVideoGravityResizeAspectFill
        _videoPreviewLayer?.frame = _videoPreview.layer.bounds
        
        _videoPreview.layer.addSublayer(_videoPreviewLayer!)
        
        _captureSession?.startRunning()
        
        return true
    }
    
    func stopReading() {
        _captureSession?.stopRunning()
        _captureSession = nil
        
        _videoPreviewLayer?.removeFromSuperlayer()
    }
    
    func captureOutput(captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [AnyObject]!, fromConnection connection: AVCaptureConnection!){
        
        if metadataObjects != nil && metadataObjects.count > 0 {
            var metadataObj: AVMetadataMachineReadableCodeObject = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
            
            dispatch_async(dispatch_get_main_queue()) {() -> Void in
                
                let fullNameArr = metadataObj.stringValue.componentsSeparatedByString("@")
                
                if fullNameArr.count == 2{
                    
                    self._Code = fullNameArr[0]
                    var server:String = fullNameArr[1]
                    
                    self.AddApplicationRef(server)
                }
                else{
                    ShowErrorAlert(self, title: "系統提示", msg: "代碼格式不正確")
                }
            }
            
            stopReading()
        }
        
    }
    
    func AddApplicationRef(server:String){
        
        self._DsnsItem = DsnsItem(name: "", accessPoint: server)
        
        if !Global.DsnsList.contains(self._DsnsItem){
            
            var err : DSFault!
            var con = Connection()
            con.connect("https://auth.ischool.com.tw:8443/dsa/greening", "user", SecurityToken.createOAuthToken(Global.AccessToken), &err)
            
            if err != nil{
                ShowErrorAlert(self, title: "過程發生錯誤", msg: err.message)
                return
            }
            
            var rsp = con.SendRequest("AddApplicationRef", bodyContent: "<Request><Applications><Application><AccessPoint>\(server)</AccessPoint><Type>dynpkg</Type></Application></Applications></Request>", &err)
            
            if err != nil{
                ShowErrorAlert(self, title: "過程發生錯誤", msg: err.message)
                return
            }
            
            Global.DsnsList.append(self._DsnsItem)
            
            ShowWebView()
        }
        else{
            JoinAsParent()
        }
    }
    
    func ShowWebView(){
        
        let target = "https://auth.ischool.com.tw/oauth/authorize.php?client_id=\(Global.clientID)&response_type=token&redirect_uri=http://_blank&scope=User.Mail,User.BasicInfo,1Campus.Notification.Read,1Campus.Notification.Send,*:auth.guest,*:1campus.mobile.parent&access_token=\(Global.AccessToken)"
        
        let urlobj = NSURL(string: target)
        let request = NSURLRequest(URL: urlobj!)
        
        self.webView.loadRequest(request)
        self.webView.hidden = false
    }
    
    func JoinAsParent(){
        
        var err : DSFault!
        var con = Connection()
        con.connect(_DsnsItem.AccessPoint, "auth.guest", SecurityToken.createOAuthToken(Global.AccessToken), &err)
        
        if err != nil{
            ShowErrorAlert(self, title: "過程發生錯誤", msg: err.message)
            return
        }
        
        var rsp = con.SendRequest("Join.AsParent", bodyContent: "<Request><ParentCode>\(_Code)</ParentCode><Relationship>iOS Parent</Relationship></Request>", &err)
        
        if err != nil{
            ShowErrorAlert(self, title: "過程發生錯誤", msg: err.message)
            return
        }
        
        //var nserr : NSError?
        let xml: AEXMLDocument?
        do {
            xml = try AEXMLDocument(xmlData: rsp.dataValue)
        } catch _ {
            xml = nil
        }
        
        if let success = xml?.root["Body"]["Success"]{
            
            let alert = UIAlertController(title: "加入成功", message: "", preferredStyle: UIAlertControllerStyle.Alert)
            
            alert.addAction(UIAlertAction(title: "確認", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
                
                Global.NeedRefreshChildList = true
                
                self.navigationController?.popViewControllerAnimated(true)
            }))
            
            self.presentViewController(alert, animated: true, completion: nil)
            
        }
        else{
            ShowErrorAlert(self, title: "加入失敗", msg: "發生不明的錯誤,請回報給開發人員")
        }

    }
    
    func webView(webView: UIWebView, didFailLoadWithError error: NSError?){
        
        //網路異常
        if let err = error where err.code == -1009 || err.code == -1003{
            
            if UpdateTokenFromError(err){
                JoinAsParent()
            }
            else{
                ShowErrorAlert(self, title: "連線過程發生錯誤", msg: "若此情況重複發生,建議重登後再嘗試")
            }
        }
    }
    
    func UpdateTokenFromError(error: NSError) -> Bool{
        
        var accessToken : String!
        var refreshToken : String!
        
        if let url = error.userInfo["NSErrorFailingURLStringKey"] as? String{
            
            let stringArray = url.componentsSeparatedByString("&")
            
            if stringArray.count != 5{
                return false
            }
            
            if let range1 = stringArray[0].rangeOfString("http://_blank/#access_token="){
                accessToken = stringArray[0]
                accessToken.removeRange(range1)
            }
            
            if let range2 = stringArray[4].rangeOfString("refresh_token="){
                refreshToken = stringArray[4]
                refreshToken.removeRange(range2)
            }
        }
        
        if accessToken != nil && refreshToken != nil{
            Global.SetAccessTokenAndRefreshToken((accessToken: accessToken, refreshToken: refreshToken))
            return true
        }
        
        return false
    }
    
}
