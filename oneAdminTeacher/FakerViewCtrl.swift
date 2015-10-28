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
            
            GroupNames = ["學習單","獎狀集","美術集","作文集"]
            
            var aaa = [PreviewData]()
            var bbb = [PreviewData]()
            var ccc = [PreviewData]()
            var ddd = [PreviewData]()
            
            if StudentData.Name == "黃小翔"{
                ccc.append(PreviewData(dsns: "dev.sh_d", uid: "portfolio_01.jpg", group: "美術集"))
                ccc.append(PreviewData(dsns: "dev.sh_d", uid: "portfolio_02.jpg", group: "美術集"))
                ccc.append(PreviewData(dsns: "dev.sh_d", uid: "portfolio_03.jpg", group: "美術集"))
                ccc.append(PreviewData(dsns: "dev.sh_d", uid: "portfolio_04.jpg", group: "美術集"))
                ccc.append(PreviewData(dsns: "dev.sh_d", uid: "portfolio_05.jpg", group: "美術集"))
                ccc.append(PreviewData(dsns: "dev.sh_d", uid: "portfolio_06.jpg", group: "美術集"))
                ccc.append(PreviewData(dsns: "dev.sh_d", uid: "portfolio_08.jpg", group: "美術集"))
                ccc.append(PreviewData(dsns: "dev.sh_d", uid: "portfolio_09.jpg", group: "美術集"))
                ccc.append(PreviewData(dsns: "dev.sh_d", uid: "portfolio_11.jpg", group: "美術集"))
                ccc.append(PreviewData(dsns: "dev.sh_d", uid: "portfolio_13.jpg", group: "美術集"))
            }
            else{
                aaa.append(PreviewData(dsns: "dev.sh_d", uid: "b1.jpg", group: "學習單"))
                aaa.append(PreviewData(dsns: "dev.sh_d", uid: "b2.jpg", group: "學習單"))
                aaa.append(PreviewData(dsns: "dev.sh_d", uid: "b3.jpg", group: "學習單"))
                aaa.append(PreviewData(dsns: "dev.sh_d", uid: "b4.jpg", group: "學習單"))
                
                bbb.append(PreviewData(dsns: "dev.sh_d", uid: "c1.jpg", group: "獎狀集"))
                bbb.append(PreviewData(dsns: "dev.sh_d", uid: "c2.jpg", group: "獎狀集"))
                bbb.append(PreviewData(dsns: "dev.sh_d", uid: "c3.jpg", group: "獎狀集"))
                bbb.append(PreviewData(dsns: "dev.sh_d", uid: "c4.jpg", group: "獎狀集"))
                
                ccc.append(PreviewData(dsns: "dev.sh_d", uid: "a1.jpg", group: "美術集"))
                ccc.append(PreviewData(dsns: "dev.sh_d", uid: "a2.jpg", group: "美術集"))
                ccc.append(PreviewData(dsns: "dev.sh_d", uid: "a3.jpg", group: "美術集"))
                ccc.append(PreviewData(dsns: "dev.sh_d", uid: "a4.jpg", group: "美術集"))
                ccc.append(PreviewData(dsns: "dev.sh_d", uid: "IMAG0256.jpg", group: "美術集"))
                ccc.append(PreviewData(dsns: "dev.sh_d", uid: "IMAG0260.jpg", group: "美術集"))
                ccc.append(PreviewData(dsns: "dev.sh_d", uid: "IMAG0262.jpg", group: "美術集"))
                ccc.append(PreviewData(dsns: "dev.sh_d", uid: "IMAG0264.jpg", group: "美術集"))
                
                ddd.append(PreviewData(dsns: "dev.sh_d", uid: "d1.jpg", group: "作文集"))
                ddd.append(PreviewData(dsns: "dev.sh_d", uid: "d2.jpg", group: "作文集"))
                ddd.append(PreviewData(dsns: "dev.sh_d", uid: "d4.jpg", group: "作文集"))
                ddd.append(PreviewData(dsns: "dev.sh_d", uid: "d4.jpg", group: "作文集"))
            }
            
            for a in aaa{
                InitDetailImage(a, name: a.Uid)
            }
            
            for b in bbb{
                InitDetailImage(b, name: b.Uid)
            }
            
            for c in ccc{
                InitDetailImage(c, name: c.Uid)
            }
            
            for d in ddd{
                InitDetailImage(d, name: d.Uid)
            }
            
            GroupSortDatas["學習單"] = aaa
            GroupSortDatas["獎狀集"] = bbb
            GroupSortDatas["美術集"] = ccc
            GroupSortDatas["作文集"] = ddd
            
            self.collectionView.reloadData()
            

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
        
        pd.Photo = UIImage(named: name)?.GetResizeImage(0.33)
        
        if let img = PhotoCoreData.LoadDetailData(pd){
            //do nothing
        }
        else{
            PhotoCoreData.SaveCatchData(pd)
            PhotoCoreData.UpdateCatchData(pd, detail: pd.Photo)
        }
    }
    
}

