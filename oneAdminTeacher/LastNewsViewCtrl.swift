//
//  LastNewsViewCtrl.swift
//  EPF
//
//  Created by Cloud on 10/23/15.
//  Copyright (c) 2015 ischool. All rights reserved.
//

import UIKit

class LastNewsViewCtrl: UIViewController,UITableViewDelegate,UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    var _LastNewItems = [LastNewItem]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "Menu-24.png"), style: UIBarButtonItemStyle.Plain, target: self, action: "ToggleSideMenu")
        
        self.navigationItem.title = "最新動態"
        
        tableView.estimatedRowHeight = 262
        tableView.rowHeight = UITableViewAutomaticDimension
        
        tableView.delegate = self
        tableView.dataSource = self
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewDidAppear(animated: Bool) {
        ReloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func ReloadData(){
        
        var lastNewItems = [LastNewItem]()
        
        for dsns in Global.DsnsList{
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), {
                
                var groups = GetMyChildGroup(dsns)
                
                for group in groups{
                    
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), {
                        var lnis = self.GetLastNewsItems(group)
                        
                        if lnis.count > 0{
                            
                            dispatch_async(dispatch_get_main_queue(), {
                                
                                lastNewItems += lnis
                                
                                var sortingBox = [LastNewItem]()
                                
                                for lni in lnis{
                                    if !contains(sortingBox, lni){
                                        sortingBox.append(lni)
                                    }
                                }
                                
                                if sortingBox.count > 0 {
                                    sortingBox.sort({ $0.Date > $1.Date })
                                    
                                    self._LastNewItems = sortingBox
                                    
                                    self.tableView.reloadData()
                                }
                            })
                        }
                    })
                    
                }
            })
        }
        
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return _LastNewItems.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
    
        let data = _LastNewItems[indexPath.row]
        
        let cell = tableView.dequeueReusableCellWithIdentifier("LastNewsCell") as! LastNewsCell
        
        cell.Group.text = data.GroupData.GroupName
        
        cell.Date.text = data.Date.stringValue
        
        cell.Comment.text = data.Commment
        
        if data.PreData.Photo == nil {
            if let catch = PhotoCoreData.LoadPreviewData(data.PreData) {
                data.PreData.Photo = catch
            }
            else{
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), {
                    UpdatePreviewData(data.PreData)
                    
                    dispatch_async(dispatch_get_main_queue(), {
                        PhotoCoreData.SaveCatchData(data.PreData)
                        cell.Photo.image = data.PreData.Photo
                    })
                })
            }
        }
        
        cell.Photo.image = data.PreData.Photo
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath){
        
        let data = _LastNewItems[indexPath.row]
        
        let nextView = self.storyboard?.instantiateViewControllerWithIdentifier("PhotoDetailViewCtrl") as! PhotoDetailViewCtrl
        
        nextView.Base = data.PreData
        nextView.Uids = _LastNewItems.map({return $0.PreData.Uid})
        nextView.CurrentIndex = indexPath.row
        
        self.navigationController?.pushViewController(nextView, animated: true)
        
    }
    
    func GetLastNewsItems(group:GroupItem) -> [LastNewItem]{
        
        let format:NSDateFormatter = NSDateFormatter()
        format.dateFormat = "yyyy-MM-dd HH:mm:ss.SSSSS"
        
        var retVal = [LastNewItem]()
        
        var con = GetCommonConnect(group.DSNS, Global.BasicContractName)
        
        var err : DSFault!
        
        var rsp = con.SendRequest("album.GetLastNewData", bodyContent: "<Request><RefGroupId>\(group.GroupId)</RefGroupId></Request>", &err)
        
        if rsp.isEmpty{
            return retVal
        }
        
        var nserr : NSError?
        var xml = AEXMLDocument(xmlData: rsp.dataValue, error: &nserr)
        
        if nserr != nil{
            return retVal
        }
        
        if let datas = xml?.root["Response"]["Epf.data"].all{
            
            for data in datas{
                
                let uid = data["Uid"].stringValue
                let comment = data["Comment"].stringValue
                
                let date = data["Date"].stringValue
                let nsDate = format.dateFromString(date)
                
                let preData = PreviewData(dsns: group.DSNS, uid: uid, group: group.GroupId)
                
                let lni = LastNewItem(preData: preData, groupData: group, date: nsDate!, comment: comment)
                
                retVal.append(lni)
            }
        }
        
        return retVal
    }
    
    func ToggleSideMenu(){
        var app = UIApplication.sharedApplication().delegate as! AppDelegate
        
        app.centerContainer?.toggleDrawerSide(MMDrawerSide.Left, animated: true, completion: nil)
    }
    
}

class LastNewItem : Equatable{
    var Commment : String
    var Date : NSDate
    var PreData : PreviewData
    var GroupData : GroupItem
    
    init(preData:PreviewData,groupData:GroupItem,date:NSDate,comment:String){
        
        PreData = preData
        GroupData = groupData
        Date = date
        Commment = comment
    }
}

func ==(lhs: LastNewItem, rhs: LastNewItem) -> Bool {
    return lhs.PreData.Dsns == rhs.PreData.Dsns && lhs.PreData.Uid == rhs.PreData.Uid
}