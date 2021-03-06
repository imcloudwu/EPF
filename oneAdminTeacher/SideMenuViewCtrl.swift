//
//  SideMenuViewCtrl.swift
//  oneAdminTeacher
//
//  Created by Cloud on 7/10/15.
//  Copyright (c) 2015 ischool. All rights reserved.
//

import UIKit

class SideMenuViewCtrl: UIViewController{
    
    @IBOutlet weak var MyPhoto: UIImageView!
    @IBOutlet weak var MyName: UILabel!
    @IBOutlet weak var MyEmail: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        MyPhoto.layer.cornerRadius = MyPhoto.frame.width / 2
        MyPhoto.layer.masksToBounds = true
        
        MyPhoto.layer.borderWidth = 3.0
        MyPhoto.layer.borderColor = UIColor.whiteColor().CGColor
        
//        var background = UIImageView(image: UIImage(named: "sidebackground.jpg"))
//        background.frame = self.view.bounds
//        background.contentMode = UIViewContentMode.ScaleToFill
//        self.view.insertSubview(background, atIndex: 0)
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        MyName.text = Global.MyName
        MyEmail.text = Global.MyEmail
        
        MyPhoto.image = Global.MyPhoto
    }
    
    @IBAction func NewsBtnClick(sender: AnyObject) {
        
        //        let nextView = self.storyboard?.instantiateViewControllerWithIdentifier("ClassQuery") as! UIViewController
        let nextView = self.storyboard?.instantiateViewControllerWithIdentifier("LastNews")
        
        ChangeContentView(nextView)
    }
    
    @IBAction func Btn1(sender: AnyObject) {
        
//        let nextView = self.storyboard?.instantiateViewControllerWithIdentifier("ClassQuery") as! UIViewController
        let nextView = self.storyboard?.instantiateViewControllerWithIdentifier("ChildMainView")
        
        ChangeContentView(nextView)
    }
    
    @IBAction func Btn2(sender: AnyObject) {
        
        let nextView = self.storyboard?.instantiateViewControllerWithIdentifier("MessageQuery")
        
        ChangeContentView(nextView)
    }
    
    @IBAction func Btn3(sender: AnyObject) {
        
        let alert = UIAlertController(title: "確認要登出嗎？", message: "", preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Destructive, handler: { (action) -> Void in
            self.Logout()
        }))
        
        self.presentViewController(alert, animated: true, completion: nil)
        
//        let nextView = self.storyboard?.instantiateViewControllerWithIdentifier("Message") as! UIViewController
//        
//        ChangeContentView(nextView)
    }
    
    @IBAction func SuperBuy(sender: AnyObject) {
        
        let nextView = self.storyboard?.instantiateViewControllerWithIdentifier("PurchaseMain")
        
        ChangeContentView(nextView)
    }
    
    @IBAction func PhotoManageBtnClick(sender: AnyObject) {
        
        let nextView = self.storyboard?.instantiateViewControllerWithIdentifier("PhotoManage")
        
        ChangeContentView(nextView)
    }
    
    func Logout(){
        
        Global.Reset()
        
        DisableSideMenu()
        
        NotificationService.UnRegister(Global.MyDeviceToken, accessToken: Global.AccessToken)
        
        MessageCoreData.DeleteAll()
        
        var storage : NSHTTPCookieStorage = NSHTTPCookieStorage.sharedHTTPCookieStorage()
        for cookie in storage.cookies!
        {
            storage.deleteCookie(cookie)
        }
        
        NSURLCache.sharedURLCache().removeAllCachedResponses()
        
        NSUserDefaults.standardUserDefaults()
        
        Keychain.delete("refreshToken")
        
        let backView = self.storyboard?.instantiateViewControllerWithIdentifier("StartView") as! UINavigationController
        ChangeContentView(backView)
    }
    
}

struct MenuItem {
    var Name : String
}
