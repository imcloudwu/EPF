//  Created by Cloud on 6/12/15.
//  Copyright (c) 2015 ischool. All rights reserved.
//

import UIKit
//import Parse

class PrepareViewCtrl: UIViewController {
    
    @IBOutlet weak var CancelBtn: UIButton!
    @IBOutlet weak var loadingLabel: UILabel!
    
    @IBOutlet weak var kycp: KYCircularProgress!
    
    var code : String!
    var refreshToken : String!
    
    var Success = false
    
    var Timer : NSTimer?
    
    func StartProgress(){
        Timer?.invalidate()
        Timer = NSTimer.scheduledTimerWithTimeInterval(0.33, target: self, selector: "timerCallback", userInfo: nil, repeats: true)
        kycp.progress = 0.0
    }
    
    func StopProgress(){
        kycp.progress = 1.0
        Timer?.invalidate()
        Timer = nil
    }
    
    func timerCallback() {
        
        if kycp.progress >= 0.95{
            kycp.progress = 0.95
        }
        else{
            kycp.progress += 0.05
        }
        
        switch loadingLabel.text!{
            
        case "Loading...":
            loadingLabel.text = "Loading."
            break
        case "Loading..":
            loadingLabel.text = "Loading..."
            break
        default:
            loadingLabel.text = "Loading.."
            break
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        CancelBtn.hidden = true
        
        CancelBtn.layer.cornerRadius = 5
        CancelBtn.layer.masksToBounds = true
        
        kycp.showProgressGuide = true
        kycp.lineWidth = 15.0
        
        kycp.progressGuideColor = UIColor(red: 33.0/255, green: 150.0/255, blue: 243.0/255, alpha: 0.1)
        kycp.colors = [UIColor(red: 33.0/255, green: 150.0/255, blue: 243.0/255, alpha: 0.8)]
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewDidAppear(animated: Bool) {
        
        FaceppAPI.initWithApiKey("4857f2b710d440edf1055a4fb2b97c5a", andApiSecret: "4ItoLGR6ED0irFYzuF1qLuoUU23UZ4MZ", andRegion: APIServerRegionCN)
        
        FaceppAPI.setDebugMode(true)
        
        FaceppAPI.group().createWithGroupName("epf")
        
        // create KYCircularProgress
        StartProgress()
        
        //self.statusLabel.text = "取得AccessToken..."
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), {
            
            if self.code != nil{
                GetAccessTokenAndRefreshToken(self.code)
            }
            else if self.refreshToken != nil{
                RenewRefreshToken(self.refreshToken)
            }
            
            dispatch_async(dispatch_get_main_queue(), {
                
                if Global.AccessToken != nil && Global.RefreshToken != nil{
                    self.Success = true
                    self.GetMyAccountInfo()
                    self.GetMyPhotoFromLocal()
                }
                
                //self.statusLabel.text = "取得DSNS清單..."
                
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), {
                    
                    self.GetDsnsList()
                    
                    dispatch_async(dispatch_get_main_queue(), {
                        
                        if self.Success{
                            //self.statusLabel.text = "註冊裝置..."
                            
                            NotificationService.Register(Global.MyDeviceToken, accessToken: Global.AccessToken) { () -> () in
                                
                                self.StopProgress()
                                
                                EnableSideMenu()
                                
                                //let nextView = self.storyboard?.instantiateViewControllerWithIdentifier("ClassQuery") as! UIViewController
                                let nextView = self.storyboard?.instantiateViewControllerWithIdentifier("LastNews")
                                
                                ChangeContentView(nextView)
                            }
                            
                        }
                        else{
                            //self.statusLabel.text = "登錄過程發生失敗..."
                            
                            self.StopProgress()
                            
                            UIView.animateWithDuration(1, animations: { () -> Void in
                                self.CancelBtn.hidden = false
                                self.CancelBtn.alpha = 0.8
                            })
                            
                        }
                        //self.presentViewController(nextView, animated: true, completion: nil)
                    })
                })
            })
        })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func CancelLogin(sender: AnyObject) {
        let backView = self.storyboard?.instantiateViewControllerWithIdentifier("StartView") as! UINavigationController
        ChangeContentView(backView)
    }
    
    func GetDsnsList(){
        
        var dsnsList = [DsnsItem]()
        
        var nserr : NSError?
        var dserr : DSFault!
        
        let con = Connection()
        
        if let at = Global.AccessToken{
            if con.connect("https://auth.ischool.com.tw:8443/dsa/greening", "user", SecurityToken.createOAuthToken(at), &dserr){
                let rsp = con.sendRequest("GetApplicationListRef", bodyContent: "<Request><Type>dynpkg</Type></Request>", &dserr)
                
                let xml: AEXMLDocument?
                do {
                    xml = try AEXMLDocument(xmlData: rsp.dataValue)
                } catch _ {
                    xml = nil
                }
                //println(xml?.xmlString)
                
                if let apps = xml?.root["Response"]["User"]["App"].all {
                    for app in apps{
                        let title = app.attributes["Title"]
                        let accessPoint = app.attributes["AccessPoint"]
                        let dsns = DsnsItem(name: title, accessPoint: accessPoint)
                        if !dsnsList.contains(dsns){
                            dsnsList.append(dsns)
                        }
                    }
                }
                
                if let apps = xml?.root["Response"]["Domain"]["App"].all {
                    for app in apps{
                        let title = app.attributes["Title"]
                        let accessPoint = app.attributes["AccessPoint"]
                        let dsns = DsnsItem(name: title, accessPoint: accessPoint)
                        if !dsnsList.contains(dsns){
                            dsnsList.append(dsns)
                        }
                    }
                }
            }
        }
        
        Global.DsnsList = dsnsList
        
        self.GetMyGroups()
        //Global.HasPrivilege = IsValidated()
        
    }
    
    func GetMyGroups(){
        
        var tmp = [GroupItem]()
        
        for dsns in Global.DsnsList{
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), {
                
                tmp += self.GetGroupData(dsns.AccessPoint)
                
                dispatch_async(dispatch_get_main_queue(), {
                    
                    Global.MyGroups = tmp
                })
            })
        }
    }
    
    func GetMyAccountInfo(){
        
        Global.MyName = "My name"
        Global.MyEmail = "My e-mail"
        
        let rsp = try? HttpClient.Get("https://auth.ischool.com.tw/services/me.php?access_token=\(Global.AccessToken)")
        
        //println(NSString(data: rsp!, encoding: NSUTF8StringEncoding))
        
        if let data = rsp{
            
            let json = JSON(data: data)
            
            Global.MyName = json["firstName"].stringValue + " " + json["lastName"].stringValue
            Global.MyEmail = json["mail"].stringValue
            Global.MyUUID = json["uuid"].stringValue
        }
    }
    
    func GetMyPhotoFromLocal(){
        
        let fm = NSFileManager()
        
        if fm.fileExistsAtPath(Global.MyPhotoLocalPath){
            //Global.MyPhoto = UIImage(named: Global.MyPhotoLocalPath)
            Global.MyPhoto = UIImage(contentsOfFile: Global.MyPhotoLocalPath)
        }
        else{
            Global.MyPhoto = UIImage(named: "default photo.jpg")
        }
    }
    
    func GetGroupData(dsns:String) -> [GroupItem] {
        
        var retVal = [GroupItem]()
        
        let rsp = try? HttpClient.Get("http://dsns.1campus.net/\(dsns)/sakura/GetMyGroup?stt=PassportAccessToken&AccessToken=\(Global.AccessToken)")
        
        if rsp == nil{
            return retVal
        }
        
        //var nserr : NSError?
        var xml: AEXMLDocument?
        do {
            xml = try AEXMLDocument(xmlData: rsp!)
        } catch _ {
            xml = nil
            return retVal
        }
        
        if let groups = xml?.root["Group"].all{
            
            for group in groups{
                
                let groupId = group["GroupId"].stringValue
                let groupName = group["GroupName"].stringValue
                let isTeacher = group["IsTeacher"].stringValue == "true" ? true : false
                let isParent = group["IsParent"].stringValue == "true" ? true : false
                let isStudent = group["IsStudent"].stringValue == "true" ? true : false
                
                let gi = GroupItem(DSNS: dsns, GroupId: groupId, GroupName: groupName, IsTeacher: isTeacher)
                
                //if !isStudent{
                    retVal.append(gi)
                //}
                
            }
        }
        
        return retVal
    }
}

class DsnsItem : Equatable{
    
    var Name : String
    var AccessPoint : String
    
    init(name:String?,accessPoint:String?){
        
        self.Name = ""
        self.AccessPoint = ""
        
        if let n = name{
           self.Name = n
        }
        
        if let a = accessPoint{
            self.AccessPoint = a
        }
    }
}

func ==(lhs: DsnsItem, rhs: DsnsItem) -> Bool {
    return lhs.AccessPoint == rhs.AccessPoint
}

