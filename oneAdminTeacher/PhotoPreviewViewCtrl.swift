//
//  PhotoPreviewViewCtrl.swift
//  EPF
//
//  Created by Cloud on 10/8/15.
//  Copyright (c) 2015 ischool. All rights reserved.
//

import UIKit

class PhotoPreviewViewCtrl: UIViewController,UICollectionViewDelegateFlowLayout,UICollectionViewDataSource{
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var GroupData : GroupItem!
    
    var PreviewDatas = [PreviewData]()
    
    var POs = [PhotoObj]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Global.PhotoNeedReload = true
        
        collectionView.alwaysBounceVertical = true
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Add, target: self, action: "AddPhoto")
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    func AddPhoto(){
        
        let editView = self.storyboard?.instantiateViewControllerWithIdentifier("PhotoEditViewCtrl") as! PhotoEditViewCtrl
        
        editView.GroupData = GroupData
        
        self.navigationController?.pushViewController(editView, animated: true)
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
        
        self.PreviewDatas = self.GetPreviewDatas()
        self.POs.removeAll(keepCapacity: true)
        
        self.POs = self.PreviewDatas.map({return $0.PO})
        
//        for data in self.PreviewDatas{
//            self.POs.append(data.PO)
//        }
        
        self.collectionView.reloadData()
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int{
        return PreviewDatas.count
    }
    
    // The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell{
        
        let data = PreviewDatas[indexPath.row]
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("cell1", forIndexPath: indexPath) 
        
        let imgView = cell.viewWithTag(100) as! UIImageView
        
        if data.Photo == nil {
            
            if let `catch` = PhotoCoreData.LoadPreviewData(data) {
                data.Photo = `catch`
            }
            else{
                
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), {
                    UpdatePreviewData(data,contract: Global.TeacherContractName)
                    
                    dispatch_async(dispatch_get_main_queue(), {
                        PhotoCoreData.SaveCatchData(data)
                        
                        if let tempCell = collectionView.cellForItemAtIndexPath(indexPath){
                            
                            let tempImgView = tempCell.viewWithTag(100) as! UIImageView
                            
                            tempImgView.image = data.Photo
                        }
                    })
                })
            }
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
        
        let data = PreviewDatas[indexPath.row]
        
        let nextView = self.storyboard?.instantiateViewControllerWithIdentifier("PhotoDetailViewCtrl") as! PhotoDetailViewCtrl
        
        nextView.Base = data
        nextView.POs = POs
        nextView.CurrentIndex = indexPath.row
        nextView.TeacherMode = true
        
        self.navigationController?.pushViewController(nextView, animated: true)
    }
    
    func GetPreviewDatas() -> [PreviewData]{
        
        var retVal = [PreviewData]()
        
        var con = GetCommonConnect(GroupData.DSNS, contract: Global.TeacherContractName)
        
        var err : DSFault!
        
        var rsp = con.SendRequest("main.GetGroupPhotoUids", bodyContent: "<Request><RefGroupId>\(GroupData.GroupId)</RefGroupId></Request>", &err)
        
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
                
                retVal.append(PreviewData(dsns:GroupData.DSNS,uid: uid,group:GroupData.GroupId))
            }
        }
        
        return retVal
    }
    
//    func UpdatePreviewData(data:PreviewData) -> Bool {
//        
//        var con = GetCommonConnect(GroupData.DSNS, Global.TeacherContractName)
//        
//        var err : DSFault!
//        
//        var rsp = con.SendRequest("main.GetPreviewData", bodyContent: "<Request><Uid>\(data.Uid)</Uid></Request>", &err)
//        
//        if rsp.isEmpty{
//            return false
//        }
//        
//        var nserr : NSError?
//        var xml = AEXMLDocument(xmlData: rsp.dataValue, error: &nserr)
//        
//        if nserr != nil{
//            return false
//        }
//        
//        if let previewData = xml?.root["Response"]["Epf.data"]["PreviewData"].stringValue{
//            data.Photo = GetImageFromBase64(previewData)
//            return true
//        }
//        
//        return false
//    }
}

class PreviewData{
    var Dsns : String
    var Uid : String
    var Group : String
    var Photo : UIImage!
    
    init(dsns:String,uid:String,group:String){
        Dsns = dsns
        Uid = uid
        Group = group
    }
    
    var Clone : PreviewData{
        return PreviewData(dsns: Dsns, uid: Uid, group: Group)
    }
    
    var PO : PhotoObj{
        return PhotoObj(Dsns : Dsns, Uid : Uid)
    }
}
