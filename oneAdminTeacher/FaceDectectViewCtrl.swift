//
//  FaceDectectViewCtrl.swift
//  EPF
//
//  Created by Cloud on 12/25/15.
//  Copyright © 2015 ischool. All rights reserved.
//

import UIKit

class FaceDectectViewCtrl: UIViewController,UITableViewDataSource,UITableViewDelegate {
    
    var _TagSelector : TagSelector!
    
    var _TmpTagSelector = TagSelector()
    
    var ImageDatas : [UIImage]?
    
    var _faces = [FaceItem]()
    
    var _aimCell : FaceCell?
    
    var _aimData : FaceItem?
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var activity: UIActivityIndicatorView!
    
    var saveBtn : UIBarButtonItem?
    
    var Menu = UIAlertController(title: "這是誰呢？", message: "", preferredStyle: UIAlertControllerStyle.ActionSheet)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        saveBtn = UIBarButtonItem(title: "確認", style: UIBarButtonItemStyle.Done, target: self, action: "Save")

        self.navigationItem.rightBarButtonItem = saveBtn
        
        saveBtn?.enabled = false
        
        activity.startAnimating()
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(animated: Bool) {
        
        _TmpTagSelector.Selected = _TagSelector.Selected
        
        if self.ImageDatas == nil || self.ImageDatas?.count == 0{
            return
        }
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), {
            print("This is run on the background queue")
            
            let ciDetector = CIDetector(ofType: CIDetectorTypeFace, context: nil, options: [
                CIDetectorAccuracy: CIDetectorAccuracyHigh
                ])
            
            var count = 0
            
            var tmpFaces = [FaceItem]()
            
            //抓出人臉
            for img in self.ImageDatas!{
                
                count++
                
                let ciImage = CIImage(CGImage: img.CGImage!)
                
                let features = ciDetector.featuresInImage(ciImage)
                
                for feature in features {
                    //face
                    var faceRect = (feature as! CIFaceFeature).bounds
                    faceRect.origin.y = img.size.height - faceRect.origin.y - faceRect.size.height
                    
                    let rect: CGRect = CGRectMake(faceRect.origin.x, faceRect.origin.y, faceRect.width, faceRect.height)
                    
                    // Create bitmap image from context using the rect
                    let imageRef = CGImageCreateWithImageInRect(img.CGImage, rect)
                    
                    // Create a new image based on the imageRef and rotate back to the original orientation
                    let face_img = UIImage(CGImage: imageRef!, scale: img.scale, orientation: img.imageOrientation)
                    
                    tmpFaces.append(FaceItem(face: face_img, name: "辨識中..."))
                }
                
                //last one
                if count == self.ImageDatas!.count{
                    
                    dispatch_async(dispatch_get_main_queue()) { () -> Void in
                        
                        self.activity.hidden = true
                        self.activity.stopAnimating()
                        self.saveBtn?.enabled = true
                        
                        self._faces = tmpFaces
                        self.tableView.reloadData()
                    }
                }
            }
        })
    }
    
    func Save(){
        
        for face in _faces{
            
            if face.NeedCreated && face.Name != "請點擊標記..." {
                
                let result = FaceppAPI.person().createWithPersonName(face.Name, andFaceId: [face.FaceId], andTag: nil, andGroupId: nil, orGroupName: ["epf"])
                
                if result.error != nil && result.error.errorCode == 1503{
                    FaceppAPI.person().addFaceWithPersonName(face.Name, orPersonId: nil, andFaceId: [face.FaceId])
                }
            }
        }
        
        FaceppAPI.train().trainAsynchronouslyWithId(nil, orName: "epf", andType: FaceppTrainIdentify)
        
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    func Recognize(data:FaceItem){
        
        data.Recognized = true
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), {
            
            let result = FaceppAPI.detection().detectWithURL(nil, orImageData: UIImageJPEGRepresentation(data.Face,0.5))
            
            if result.content == nil{
                
                dispatch_async(dispatch_get_main_queue(), {
                    
                    data.Name = "can not find the face..."
                    
                    self.tableView.reloadData()
                })
                
                return
            }
            
            let content = JSON(result.content)
            
            let faces = content["face"].arrayValue
            
            if faces.count == 0{
                
                dispatch_async(dispatch_get_main_queue(), {
                    
                    data.Name = "can not find the face..."
                    self.tableView.reloadData()
                })
            }
            else{
                
                let face_id = faces[0]["face_id"].stringValue
                data.FaceId = face_id
                
                let recognize = FaceppAPI.recognition().identifyWithGroupId(nil, orGroupName: "epf", andURL: nil, orImageData: nil, orKeyFaceId: [face_id], async: false)
                
                if let recognize_content = recognize.content{
                    
                    let content = JSON(recognize_content)
                    
                    let faces = content["face"].arrayValue
                    
                    if faces.count > 0 {
                        
                        let candidate = faces[0]["candidate"].arrayValue
                        
                        if candidate.count > 0{
                            
                            let person_name = candidate[0]["person_name"].stringValue
                            
                            dispatch_async(dispatch_get_main_queue(), {
                                data.Name = person_name
                                self.tableView.reloadData()
                            })
                            
                        }
                    }
                }
                else{
                    
                    dispatch_async(dispatch_get_main_queue(), {
                        data.NeedCreated = true
                        data.Name = "請點擊標記..."
                    })
                    
                }
            }
            
        })
        
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return _faces.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
        
        let data = _faces[indexPath.row]
        
        let cell = tableView.dequeueReusableCellWithIdentifier("FaceCell") as! FaceCell
        
        cell.Face.image = data.Face
        cell.Name.text = data.Name
        
        if !data.Recognized{
            Recognize(data)
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath){
        
        self._aimCell = tableView.cellForRowAtIndexPath(indexPath) as! FaceCell
        
        self._aimData = self._faces[indexPath.row]
        
        if Menu.actions.count == 0{
            
            Menu.addAction(UIAlertAction(title: "取消", style: UIAlertActionStyle.Cancel, handler: nil))
            
            for s in _TagSelector.List{
                
                Menu.addAction(UIAlertAction(title: s.StudentName, style: UIAlertActionStyle.Default, handler: { (aa) -> Void in
                    
                    self._aimData?.Name = s.StudentName
                    self._aimCell?.Name.text = s.StudentName
                    
                    self._aimData?.NeedCreated = true
                }))
            }
        }
        
        self.presentViewController(Menu, animated: true, completion: {
            self.tableView.reloadData()
        })
    }
    
}

class FaceItem{
    var Face : UIImage
    var Name : String
    var Recognized : Bool
    
    var FaceId : String
    var NeedCreated : Bool
    
    init(face:UIImage,name:String){
        Face = face
        Name = name
        Recognized = false
        
        FaceId = ""
        NeedCreated = false
    }
}
