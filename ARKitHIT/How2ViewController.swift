//  ARKitHIT 2022/01/15 by Tatsuaki Kuroda
//  How2ViewController.swift
//
//

import UIKit

class How2ViewController: UIViewController {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var exitButton: UIButton!
    func setButtonProperty(_ button:UIButton,x:CGFloat,y:CGFloat,w:CGFloat,h:CGFloat,_ color:UIColor){
        button.frame   = CGRect(x:x, y:y, width: w, height: h)
        button.layer.cornerRadius = 5
    }
    func firstLang() -> String {
        let prefLang = Locale.preferredLanguages.first
        return prefLang!
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        /*
         let ww=view.bounds.width
         let wh=view.bounds.height
         let top:CGFloat=40//CGFloat(UserDefaults.standard.float(forKey: "top"))
         let bottom:CGFloat=20//CGFloat( UserDefaults.standard.float(forKey: "bottom"))
         let sp:CGFloat=5
         let bw:CGFloat=(ww-10*sp)/7//最下段のボタンの高さ、幅と同じ
         let bh=bw
         let by1=wh-bottom-2*sp-bh
         */
        let ww=view.bounds.width
        let wh=view.bounds.height
        let top:CGFloat=40//CGFloat(UserDefaults.standard.float(forKey: "top"))
        let bottom:CGFloat=20//CGFloat( UserDefaults.standard.float(forKey: "bottom"))
        let sp:CGFloat=5
        let bw:CGFloat=(ww-10*sp)/7//最下段のボタンの高さ、幅と同じ
        let bh=bw
        let by1=wh-bottom-2*sp-bh
//        let by1=by0-bh-sp//2段目
        setButtonProperty(exitButton,x:sp*7.5+bw*5.5,y:by1,w:bw,h: bh,UIColor.blue)
 
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
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    override var prefersHomeIndicatorAutoHidden: Bool {
        return true
    }
    
}

