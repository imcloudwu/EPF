//
//  StudentAlbumViewCtrl.swift
//  EPF
//
//  Created by Cloud on 10/21/15.
//  Copyright (c) 2015 ischool. All rights reserved.
//

import UIKit

class StudentAlbumViewCtrl: UIViewController,UICollectionViewDelegateFlowLayout,UICollectionViewDataSource{
    
    let CellId = "cell2"
    
    let MyTagString = "被標註的照片"
    
    var StudentData : Student!
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var _UICollectionReusableView : GroupHeader!
    
    var GroupSortDatas = [String:[PreviewData]]()
    var GroupNames = [String]()
    
    var MyGroups : [GroupItem]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Global.PhotoNeedReload = true
    
        collectionView.alwaysBounceVertical = true
        
        collectionView.delegate = self
        collectionView.dataSource = self
    
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(animated: Bool) {
        
        if !Global.PhotoNeedReload{
            return
        }
        
        Global.PhotoNeedReload = false
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), {
            
            let myGroups = GetMyChildGroup(self.StudentData)
            let myTags = self.GetMyTagPreviewDatas()
            
            dispatch_async(dispatch_get_main_queue(), {
                
                if myTags.count > 0{
                    self.GroupSortDatas[self.MyTagString] = myTags
                    self.GroupNames.append(self.MyTagString)
                }
               
                self.MyGroups = myGroups
                
                for group in self.MyGroups{
                    
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), {
                        
                        let datas = self.GetPreviewDatas(group.GroupId)
                        
                        dispatch_async(dispatch_get_main_queue(), {
                            
                            if datas.count > 0{
                                self.GroupSortDatas[group.GroupName] = datas
                                self.GroupNames.append(group.GroupName)
                                
                                self.collectionView.reloadData()
                            }
                        })
                    })
                    
                }
                
            })
        })
        
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int{
        
        let groupName = GroupNames[section]
        
        if let list:[PreviewData] = GroupSortDatas[groupName]{
            return list.count
        }
        
        return 0
    }
    
    // The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell{
        
        let groupName = GroupNames[indexPath.section]
        
        let groupDatas = GroupSortDatas[groupName]!
        
        let data = groupDatas[indexPath.row]
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(CellId, forIndexPath: indexPath) 
        
        let imgView = cell.viewWithTag(100) as! UIImageView
        
        if data.Photo == nil {
            
            dispatch_async(dispatch_get_main_queue(), {
                
                if let `catch` = PhotoCoreData.LoadPreviewData(data) {
                    data.Photo = `catch`
                    imgView.image = data.Photo
                }
                else{
                    
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), {
                        
                        UpdatePreviewData(data,contract: Global.BasicContractName)
                        
                        dispatch_async(dispatch_get_main_queue(), {
                            
                            PhotoCoreData.SaveCatchData(data)
                            
                            if let tempCell = collectionView.cellForItemAtIndexPath(indexPath){
                                
                                let tempImgView = tempCell.viewWithTag(100) as! UIImageView
                                
                                tempImgView.image = data.Photo
                            }
                            
                        })
                    })
                }
                
            })
        }
        
        imgView.image = data.Photo
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        
        switch Global.ScreenSize.width{
        case 414 :
            return CGSizeMake((collectionView.bounds.size.width - 4) / 4, (collectionView.bounds.size.width - 4) / 4)
        case 375 :
            return CGSizeMake((collectionView.bounds.size.width - 3) / 3, (collectionView.bounds.size.width - 3) / 3)
        default :
            return CGSizeMake((collectionView.bounds.size.width - 3) / 3, (collectionView.bounds.size.width - 3) / 3)
        }
        
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 1.0
    }
    
    //call when item is clicked
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath){
        
        let groupName = GroupNames[indexPath.section]
        
        let groupDatas = GroupSortDatas[groupName]!
        
        let data = groupDatas[indexPath.row]
        
        let nextView = self.storyboard?.instantiateViewControllerWithIdentifier("PhotoDetailViewCtrl") as! PhotoDetailViewCtrl
        
        nextView.Base = data
        nextView.POs = groupDatas.map({return $0.PO})
        nextView.CurrentIndex = indexPath.row
        
        self.navigationController?.pushViewController(nextView, animated: true)
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int{
        return GroupNames.count
    }
    
    //Get Header
    func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView{
        
        _UICollectionReusableView = nil
        
        if kind == UICollectionElementKindSectionHeader{
            _UICollectionReusableView = collectionView.dequeueReusableSupplementaryViewOfKind(UICollectionElementKindSectionHeader, withReuseIdentifier: "GroupHeader", forIndexPath: indexPath) as! GroupHeader
            
            _UICollectionReusableView.title.text = GroupNames[indexPath.section]
        }
        
        return _UICollectionReusableView
    }
    
    func GetMyTagPreviewDatas() -> [PreviewData]{
        
        var retVal = [PreviewData]()
        
        var con = GetCommonConnect(StudentData.DSNS, contract: Global.BasicContractName)
        
        var err : DSFault!
        
        var rsp = con.SendRequest("album.GetMyTags", bodyContent: "<Request><RefStudentId>\(StudentData.ID)</RefStudentId></Request>", &err)
        
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
        
        if let datas = xml?.root["Response"]["Epf.data.tag"].all{
            
            for data in datas{
                
                let uid = data["RefDataId"].stringValue
                
                retVal.append(PreviewData(dsns:StudentData.DSNS,uid: uid,group: MyTagString))
            }
        }
        
        return retVal

    }
    
    func GetPreviewDatas(groupId:String) -> [PreviewData]{
        
        var retVal = [PreviewData]()
        
        var con = GetCommonConnect(StudentData.DSNS, contract: Global.BasicContractName)
        
        var err : DSFault!
        
        var rsp = con.SendRequest("album.GetGroupPhotoUids", bodyContent: "<Request><RefGroupId>\(groupId)</RefGroupId></Request>", &err)
        
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
                
                retVal.append(PreviewData(dsns:StudentData.DSNS,uid: uid,group: groupId))
            }
        }
        
        return retVal
    }
    
}

