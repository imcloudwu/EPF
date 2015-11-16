//
//  PhotoManageViewCtrl.swift
//  EPF
//
//  Created by Cloud on 10/7/15.
//  Copyright (c) 2015 ischool. All rights reserved.
//

import UIKit

class PhotoManageViewCtrl: UIViewController,UITableViewDelegate,UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    var _Data = [GelleryItem]()
    
    var DefaultImg = UIImage(named: "Gallery-64.png")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "相片管理"
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "Menu-24.png"), style: UIBarButtonItemStyle.Plain, target: self, action: "ToggleSideMenu")
        
        tableView.delegate = self
        tableView.dataSource = self
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    func SetGelleryData(){
        
        var datas = [GelleryItem]()
        
        for group in Global.TeacherGroups{
            datas.append(GelleryItem(group: group))
        }
        
        _Data = datas
        
        for data in _Data{
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), {
                
                var needReload = self.GetPreviewData(data)
                
                dispatch_async(dispatch_get_main_queue(), {
                    
                    if needReload{
                        self.tableView.reloadData()
                    }
                    
                })
            })
            
        }
    }
    
    func ToggleSideMenu(){
        var app = UIApplication.sharedApplication().delegate as! AppDelegate
        
        app.centerContainer?.toggleDrawerSide(MMDrawerSide.Left, animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(animated: Bool) {
        SetGelleryData()
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return _Data.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
        
        let data = _Data[indexPath.row]
        
        let cell = tableView.dequeueReusableCellWithIdentifier("PhotoGalleryCell") as! PhotoGalleryCell
        
        cell.GalleryPhoto.image = data.Photo
        cell.GalleryName.text = data.Name
        cell.GalleryCount.text = data.Count
        
        if data.NeedLoad{
            cell.Activity.startAnimating()
        }
        else{
            cell.Activity.stopAnimating()
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath){
    
        let data = _Data[indexPath.row]
        
        let nextView = storyboard?.instantiateViewControllerWithIdentifier("PhotoPreviewViewCtrl") as! PhotoPreviewViewCtrl
        
        nextView.GroupData = data.Group
        
        self.navigationController?.pushViewController(nextView, animated: true)
    }
    
    func GetPreviewData(gellery:GelleryItem) -> Bool{
        
        var con = GetCommonConnect(gellery.Group.DSNS, Global.TeacherContractName)
        
        var err : DSFault!
        
        var rsp = con.SendRequest("main.GetGroupPreviewData", bodyContent: "<Request><RefGroupId>\(gellery.Group.GroupId)</RefGroupId></Request>", &err)
        
        gellery.NeedLoad = false
        gellery.Photo = DefaultImg!
        
        if rsp == "" {
            return false
        }
        
        var nserr : NSError?
        var xml = AEXMLDocument(xmlData: rsp.dataValue, error: &nserr)
        
        if nserr != nil{
            return false
        }
        
        if let count = xml?.root["Response"]["Count"].stringValue{
            gellery.Count = count
        }
        
        if let photo = xml?.root["Response"]["Photo"].stringValue where !photo.isEmpty{
            gellery.Photo = GetImageFromBase64(photo)
        }
        
        return true
    }
}

class GelleryItem{
    
    var Group : GroupItem
    var Photo : UIImage
    var Name : String
    var Count : String
    var NeedLoad : Bool
    
    init(group:GroupItem){
        Group = group
        Photo = UIImage()
        Name = group.GroupName
        Count = ""
        NeedLoad = true
    }
}




