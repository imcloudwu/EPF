import UIKit

class FakerViewCtrl: UIViewController,UICollectionViewDelegateFlowLayout,UICollectionViewDataSource{
    
    let CellId = "cell3"
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var _UICollectionReusableView : GroupHeader!
    
    var GroupNames = [String]()
    var GroupSortDatas = [String:[PreviewData]]()
    
    var StudentData : Student!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        
        if GroupSortDatas.count == 0 {
            
            self.DoMeAFavor()
        }
        
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
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(CellId, forIndexPath: indexPath) as! UICollectionViewCell
        
        var imgView = cell.viewWithTag(100) as! UIImageView
        
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
        nextView.Uids = groupDatas.map({return $0.Uid})
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
            _UICollectionReusableView = collectionView.dequeueReusableSupplementaryViewOfKind(UICollectionElementKindSectionHeader, withReuseIdentifier: "GroupHeader2", forIndexPath: indexPath) as! GroupHeader
            
            _UICollectionReusableView.title.text = GroupNames[indexPath.section]
        }
        
        return _UICollectionReusableView
    }
    
    func InitDetailImage(pd:PreviewData,name:String){
        
        if let img = PhotoCoreData.LoadPreviewData(pd){
            pd.Photo = img
        }
        else{
            pd.Photo = UIImage(named: name)?.GetResizeImage(0.33)
            PhotoCoreData.SaveCatchData(pd)
            PhotoCoreData.UpdateCatchData(pd, detail: pd.Photo)
        }
    }
    
    func DoMeAFavor(){
        
        GroupNames = ["學習單","獎狀集","美術集","作文集"]
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), {
            
            var aaa = [PreviewData]()
            var bbb = [PreviewData]()
            var ccc = [PreviewData]()
            var ddd = [PreviewData]()
            
            if self.StudentData.Name == "黃小翔"{
                aaa.append(PreviewData(dsns: "dev.sh_d", uid: "30124學習單4.jpg", group: "學習單"))
                aaa.append(PreviewData(dsns: "dev.sh_d", uid: "30124學習單5.jpg", group: "學習單"))
                aaa.append(PreviewData(dsns: "dev.sh_d", uid: "30124學習單7.jpg", group: "學習單"))
                
                bbb.append(PreviewData(dsns: "dev.sh_d", uid: "30124獎狀1.jpg", group: "獎狀集"))
                bbb.append(PreviewData(dsns: "dev.sh_d", uid: "30124獎狀2.jpg", group: "獎狀集"))
                bbb.append(PreviewData(dsns: "dev.sh_d", uid: "30124獎狀3.jpg", group: "獎狀集"))
                
                ccc.append(PreviewData(dsns: "dev.sh_d", uid: "30124美勞1.jpg", group: "美術集"))
                ccc.append(PreviewData(dsns: "dev.sh_d", uid: "30124美勞2.jpg", group: "美術集"))
                ccc.append(PreviewData(dsns: "dev.sh_d", uid: "30124美勞3.jpg", group: "美術集"))
                
                ddd.append(PreviewData(dsns: "dev.sh_d", uid: "30124國語考券1.jpg", group: "作文集"))
                ddd.append(PreviewData(dsns: "dev.sh_d", uid: "30124國語考券2.jpg", group: "作文集"))
                ddd.append(PreviewData(dsns: "dev.sh_d", uid: "30124數學考券1.jpg", group: "作文集"))
            }
            else{
                aaa.append(PreviewData(dsns: "dev.sh_d", uid: "30121學習單1.jpg", group: "學習單"))
                aaa.append(PreviewData(dsns: "dev.sh_d", uid: "30121學習單2.jpg", group: "學習單"))
                aaa.append(PreviewData(dsns: "dev.sh_d", uid: "30121學習單3.jpg", group: "學習單"))
                aaa.append(PreviewData(dsns: "dev.sh_d", uid: "30121學習單4.jpg", group: "學習單"))
                aaa.append(PreviewData(dsns: "dev.sh_d", uid: "30121學習單5.jpg", group: "學習單"))
                aaa.append(PreviewData(dsns: "dev.sh_d", uid: "30121學習單6.jpg", group: "學習單"))
                
                bbb.append(PreviewData(dsns: "dev.sh_d", uid: "30121-1獎狀.jpg", group: "獎狀集"))
                bbb.append(PreviewData(dsns: "dev.sh_d", uid: "30121-2獎狀.jpg", group: "獎狀集"))
                bbb.append(PreviewData(dsns: "dev.sh_d", uid: "30121-3獎狀.jpg", group: "獎狀集"))
                bbb.append(PreviewData(dsns: "dev.sh_d", uid: "30121-4獎狀.jpg", group: "獎狀集"))
                bbb.append(PreviewData(dsns: "dev.sh_d", uid: "30121-5獎狀.jpg", group: "獎狀集"))
                bbb.append(PreviewData(dsns: "dev.sh_d", uid: "30121-6獎狀.jpg", group: "獎狀集"))
                
                ccc.append(PreviewData(dsns: "dev.sh_d", uid: "30121美勞畫像.jpg", group: "美術集"))
                ccc.append(PreviewData(dsns: "dev.sh_d", uid: "30121美勞花瓶.jpg", group: "美術集"))
                ccc.append(PreviewData(dsns: "dev.sh_d", uid: "30121美勞蝴蝶.jpg", group: "美術集"))
                ccc.append(PreviewData(dsns: "dev.sh_d", uid: "30121美勞魚.jpg", group: "美術集"))
                
                ddd.append(PreviewData(dsns: "dev.sh_d", uid: "30121-作文12.jpg", group: "作文集"))
                ddd.append(PreviewData(dsns: "dev.sh_d", uid: "30121-作文13.jpg", group: "作文集"))
                ddd.append(PreviewData(dsns: "dev.sh_d", uid: "30121-作文14.jpg", group: "作文集"))
                ddd.append(PreviewData(dsns: "dev.sh_d", uid: "30121-作文15.jpg", group: "作文集"))
                ddd.append(PreviewData(dsns: "dev.sh_d", uid: "30121-作文16.jpg", group: "作文集"))
                ddd.append(PreviewData(dsns: "dev.sh_d", uid: "30121-作文21.jpg", group: "作文集"))
            }
            
            for a in aaa{
                self.InitDetailImage(a, name: a.Uid)
            }
            
            for b in bbb{
                self.InitDetailImage(b, name: b.Uid)
            }
            
            for c in ccc{
                self.InitDetailImage(c, name: c.Uid)
            }
            
            for d in ddd{
                self.InitDetailImage(d, name: d.Uid)
            }
            
            dispatch_async(dispatch_get_main_queue(), {
                
                self.GroupSortDatas["學習單"] = aaa
                self.GroupSortDatas["獎狀集"] = bbb
                self.GroupSortDatas["美術集"] = ccc
                self.GroupSortDatas["作文集"] = ddd
                
                self.collectionView.reloadData()
            })
        })
    }
    
}

