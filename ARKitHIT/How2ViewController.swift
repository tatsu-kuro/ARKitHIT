//  ARKitHIT 2022/01/15 by Tatsuaki Kuroda
//  How2ViewController.swift
//
//

import UIKit

class How2ViewController: UIViewController {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var exitButton: UIButton!
//    override func viewDidLoad() {
//        super.viewDidLoad()
//
//        // Do any additional setup after loading the view.
//    }
    func setButtonProperty(_ button:UIButton,x:CGFloat,y:CGFloat,w:CGFloat,h:CGFloat,_ color:UIColor){
        button.frame   = CGRect(x:x, y:y, width: w, height: h)
//        button.layer.borderColor = UIColor.black.cgColor
//        button.layer.borderWidth = 1.0
        button.layer.cornerRadius = 5
//        button.backgroundColor = color
    }
    func firstLang() -> String {
        let prefLang = Locale.preferredLanguages.first
        return prefLang!
    }
    override func viewDidLoad() {
        super.viewDidLoad()
//        let top:CGFloat=40//CGFloat(UserDefaults.standard.float(forKey: "topPadding"))
//        let bottom:CGFloat=20//CGFloat(UserDefaults.standard.float(forKey: "bottomPadding"))
   //     let left=CGFloat(UserDefaults.standard.float(forKey: "leftPadding"))
    //    let right=CGFloat(UserDefaults.standard.float(forKey: "rightPadding"))
        
        let ww=view.bounds.width
        let wh=view.bounds.height
        let top:CGFloat=40//CGFloat(UserDefaults.standard.float(forKey: "top"))
        let bottom:CGFloat=20//CGFloat( UserDefaults.standard.float(forKey: "bottom"))
        let sp:CGFloat=5
        let bw:CGFloat=(ww-10*sp)/7//最下段のボタンの高さ、幅と同じ
        let bh=bw
        let by0=wh-bottom-2*sp-bh
        let by1=by0-bh-sp//2段目
    //        let by2=by1-bh-sp//videoSlider
//            setButtonProperty(mailButton,x:sp*2.5+bw*0.5,y:by1,w:bw,h:bh,UIColor.blue)
        setButtonProperty(exitButton,x:sp*7.5+bw*5.5,y:by1,w:bw,h: bh,UIColor.blue)
        
//
//
//
//        let ww=view.bounds.width
//        let wh=view.bounds.height-(top+bottom)
//        let sp=ww/120//間隙
//        let bw=(ww-sp*10)/7//ボタン幅
//        let bh=bw*240/440
//        let by=wh-bh-sp
//        // 画面サイズ取得
//  //      setButtonProperty(exitButton,x:bw*6+sp*8,y:view.bounds.height-sp-bh,w:bw,h:bh,UIColor.darkGray)
//        setButtonProperty(exitButton,x:bw*6+sp*8,y:wh-sp-bh,w:bw,h:bh,UIColor.darkGray)
        scrollView.frame = CGRect(x:0,y:top,width: ww,height: exitButton.frame.minY)
          var img = UIImage(named:"helpEng")!
        if firstLang().contains("ja"){
            img = UIImage(named: "helpJap")!
        }
        // 画像のサイズ
        let imgW = img.size.width
        let imgH = img.size.height
        let image = img.resize(size: CGSize(width:ww, height:ww*imgH/imgW))
        // UIImageView 初期化
        let imageView = UIImageView(image: image)//jellyfish)
        // UIScrollViewに追加
        scrollView.addSubview(imageView)
        // UIScrollViewの大きさを画像サイズに設定
        scrollView.contentSize = CGSize(width: ww, height: ww*imgH/imgW)
        // スクロールの跳ね返り無し
        scrollView.bounces = true
        let helpString = "iPhoneを被験者の眼前25cmに置き、そのカメラ部分を注視させた状態で，被験者の頭部を急速に 10°~20°回旋させる時、半規管機能が正常であれば，前庭眼反射(VOR:VestibularOcularReflex)が働き視標を注視できる。機能が低下していると，十分な VOR が働かず眼位と視標にズレが生じ、それを補正するために急速眼球運動が生じる。これをCUS(Catch Up Saccade)と呼ぶ。iPhoneのカメラで眼球運動を観察し、このCUSの有無を判別する。右耳を後方へ回転させた時にCUSがあれば、右外側半規管機能低下と判断できる."
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    override var prefersHomeIndicatorAutoHidden: Bool {
        return true
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
/*
 
 import UIKit
 

 class How2ViewController: UIViewController {
     let someFunctions = myFunctions()
     
     @IBOutlet weak var scrollView: UIScrollView!
     @IBOutlet weak var exitButton: UIButton!
     
     override func viewDidLoad() {
         super.viewDidLoad()
         let top=CGFloat(UserDefaults.standard.float(forKey: "topPadding"))
         let bottom=CGFloat(UserDefaults.standard.float(forKey: "bottomPadding"))
         let left=CGFloat(UserDefaults.standard.float(forKey: "leftPadding"))
         let right=CGFloat(UserDefaults.standard.float(forKey: "rightPadding"))
         let ww=view.bounds.width-(left+right)
         let wh=view.bounds.height-(top+bottom)
         let sp=ww/120//間隙
         let bw=(ww-sp*10)/7//ボタン幅
         let bh=bw*240/440
         let by=wh-bh-sp
         // 画面サイズ取得
         scrollView.frame = CGRect(x:left,y:top,width: ww,height: wh)
         someFunctions.setButtonProperty(exitButton,x:left+bw*6+sp*8,y:view.bounds.height-sp-bh,w:bw,h:bh,UIColor.darkGray)
         var img = UIImage(named:"helpEng")!
         if someFunctions.firstLang().contains("ja"){
             img = UIImage(named: "helpJap")!
         }
         // 画像のサイズ
         let imgW = img.size.width
         let imgH = img.size.height
         let image = img.resize(size: CGSize(width:ww, height:ww*imgH/imgW))
         // UIImageView 初期化
         let imageView = UIImageView(image: image)//jellyfish)
         // UIScrollViewに追加
         scrollView.addSubview(imageView)
         // UIScrollViewの大きさを画像サイズに設定
         scrollView.contentSize = CGSize(width: ww, height: ww*imgH/imgW)
         // スクロールの跳ね返り無し
         scrollView.bounces = true
     }
     
     override var prefersStatusBarHidden: Bool {
         return true
     }
     override var prefersHomeIndicatorAutoHidden: Bool {
         return true
     }
     
 }
 */
