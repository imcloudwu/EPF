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
    
    var refreshControl : UIRefreshControl!
    
    var _LastNewItems = [LastNewItem]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.refreshControl = UIRefreshControl()
        self.refreshControl.attributedTitle = NSAttributedString(string: "")
        self.refreshControl.addTarget(self, action: "ReloadData", forControlEvents: UIControlEvents.ValueChanged)
        self.tableView.addSubview(refreshControl)
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "Menu-24.png"), style: UIBarButtonItemStyle.Plain, target: self, action: "ToggleSideMenu")
        
        self.navigationItem.title = "最新動態"
        
        tableView.estimatedRowHeight = 262
        tableView.rowHeight = UITableViewAutomaticDimension
        
        tableView.delegate = self
        tableView.dataSource = self
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewDidAppear(animated: Bool) {
        
        if _LastNewItems.count == 0{
            ReloadData()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func ReloadData(){
        
        self.refreshControl.endRefreshing()
        
        var lastNewItems = [LastNewItem]()
        
        self._LastNewItems = lastNewItems
        
        self.tableView.reloadData()
        
        for dsns in Global.DsnsList{
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), {
                
                let groups = GetMyChildGroup(dsns)
                
                let lnis = self.GetLastNewsItems(dsns.AccessPoint,groups: groups)
                
                if lnis.count > 0{
                    
                    dispatch_async(dispatch_get_main_queue(), {
                        
                        for lni in lnis{
                            if !lastNewItems.contains(lni){
                                lastNewItems.append(lni)
                            }
                        }
                        
                        if lastNewItems.count > 0 {
                            
                            lastNewItems.sortInPlace({ $0.Date > $1.Date })
                            
                            self._LastNewItems = lastNewItems
                            
                            self.tableView.reloadData()
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
            if let `catch` = PhotoCoreData.LoadPreviewData(data.PreData) {
                data.PreData.Photo = `catch`
            }
            else{
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), {
                    
                    UpdatePreviewData(data.PreData,contract: Global.BasicContractName)
                    
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
    
    func GetLastNewsItems(dsns:String,groups:[GroupItem]) -> [LastNewItem]{
        
        let format:NSDateFormatter = NSDateFormatter()
        format.dateFormat = "yyyy-MM-dd HH:mm:ss.SSSSS"
        
        var groupNames = [String:GroupItem]()
        var request = ""
        
        for group in groups{
            groupNames[group.GroupId] = group
            request += "<RefGroupId>\(group.GroupId)</RefGroupId>"
        }
        
        var retVal = [LastNewItem]()
        
        var con = GetCommonConnect(dsns, contract: Global.BasicContractName)
        
        var err : DSFault!
        
        var rsp = con.SendRequest("album.GetNews", bodyContent: "<Request>\(request)<Pagination><StartPage>1</StartPage><PageSize>20</PageSize></Pagination></Request>", &err)
        
        if rsp.isEmpty{
            return retVal
        }
        
        //var nserr : NSError?
        var xml: AEXMLDocument?
        do {
            xml = try AEXMLDocument(xmlData: rsp.dataValue)
        } catch _ {
            xml = nil
            return retVal
        }
        
        if let datas = xml?.root["Response"]["Epf.data"].all{
            
            for data in datas{
                
                let uid = data["Uid"].stringValue
                let comment = data["Comment"].stringValue
                let groupId = data["RefGroupId"].stringValue
                
                let date = data["Date"].stringValue
                let nsDate = format.dateFromString(date)
                
                let preData = PreviewData(dsns: dsns, uid: uid, group: groupId)
                
                let lni = LastNewItem(preData: preData, groupData: groupNames[groupId]!, date: nsDate!, comment: comment)
                
                retVal.append(lni)
            }
        }
        
        return retVal
    }
    
    func ToggleSideMenu(){
        let app = UIApplication.sharedApplication().delegate as! AppDelegate
        
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
