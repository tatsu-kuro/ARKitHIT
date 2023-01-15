//
//  SetteiViewController.swift
//  Eyes Tracking
//
//  Created by 黒田建彰 on 2023/01/08.
//  Copyright © 2023 virakri. All rights reserved.
//

import UIKit

@available(iOS 13.0, *)
class SetteiViewController: UIViewController {
    @IBOutlet weak var defaultButton: UIButton!
    
    @IBOutlet weak var multiEye: UILabel!
    @IBOutlet weak var multiEyeText: UILabel!
    @IBOutlet weak var multiFace: UILabel!
    @IBOutlet weak var multiFaceText: UILabel!
    @IBOutlet weak var exitButton: UIButton!
    func setLabelProperty(_ label:UILabel,x:CGFloat,y:CGFloat,w:CGFloat,h:CGFloat,_ color:UIColor){
        label.frame = CGRect(x:x, y:y, width: w, height: h)
        label.layer.borderColor = UIColor.black.cgColor
        label.layer.borderWidth = 1.0
        label.layer.masksToBounds = true
        label.layer.cornerRadius = 3
        label.backgroundColor = color
    }
    func getUserDefault(str:String,ret:Int) -> Int{//getUserDefault_one
        if (UserDefaults.standard.object(forKey: str) != nil){//keyが設定してなければretをセット
            return UserDefaults.standard.integer(forKey:str)
        }else{
            UserDefaults.standard.set(ret, forKey: str)
            return ret
        }
    }
    func Field2value(field:UITextField) -> Int {
        if field.text?.count != 0 {
            return Int(field.text!)!
        }else{
            return 0
        }
    }

    @IBAction func onDefaultButton(_ sender: Any) {
        multiEye.text="100"
        multiFace.text="100"
        UserDefaults.standard.set(100, forKey: "multiEye")
        UserDefaults.standard.set(100, forKey: "multiFace")
    }
    
//    @IBAction func widthRangeButton(_ sender: Any) {
//        widthRange = Field2value(field:B2CInput)
//
    
    
    @IBAction func onTapGestureEye(_ sender: Any) {

        print("eyetap")
        let alert = UIAlertController(title: "", message: "", preferredStyle: .alert)
        let saveAction = UIAlertAction(title: "OK", style: .default) { [self] (action:UIAlertAction!) -> Void in
            // 入力したテキストをコンソールに表示
            let textField = alert.textFields![0] as UITextField
//            let ettString:String = textField.text!
//            let value=Int(textField.text!)
            if Int(textField.text!) != nil{//camera.checkEttString(ettStr: ettString){
                multiEye.text=textField.text
                UserDefaults.standard.set(Int(textField.text!), forKey: "multiEye")

            }else{
                let dialog = UIAlertController(title: "", message: "0123456789 are available.", preferredStyle: .alert)
                //ボタンのタイトル
                dialog.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                //実際に表示させる
                self.present(dialog, animated: true, completion: nil)
//                print(",:0123456789以外は受け付けません")
            }
//            print("\(String(describing: textField.text))")
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .default) { (action:UIAlertAction!) -> Void in
        }
        // UIAlertControllerにtextFieldを追加
        alert.addTextField { (textField:UITextField!) -> Void in
            textField.keyboardType = UIKeyboardType.numberPad//numbersAndPunctuation// default//.numberPad

        }
        alert.addAction(cancelAction)//この行と下の行の並びを変えるとCancelとOKの左右が入れ替わる。
        alert.addAction(saveAction)
        present(alert, animated: true, completion: nil)
        
    }
    /*
     @IBAction func tapOnEttText(_ sender: Any) {
         print("eyetap")
         let alert = UIAlertController(title: "", message: "", preferredStyle: .alert)
         let saveAction = UIAlertAction(title: "OK", style: .default) { [self] (action:UIAlertAction!) -> Void in
             // 入力したテキストをコンソールに表示
             let textField = alert.textFields![0] as UITextField
             let ettString:String = textField.text!

             if camera.checkEttString(ettStr: ettString){
                 if ettMode==0{
                     ettModeText0=ettString
                 }else if ettMode==1{
                     ettModeText1=ettString
                 }else if ettMode==2{
                     ettModeText2=ettString
                 }else{
                     ettModeText3=ettString
                 }
                 setUserDefaults()
                 ettText.text=ettString
             }else{
                 let dialog = UIAlertController(title: "", message: "0123456789,: are available.\nlike as 1,1:2:15,2:2:15", preferredStyle: .alert)
                 //ボタンのタイトル
                 dialog.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                 //実際に表示させる
                 self.present(dialog, animated: true, completion: nil)
 //                print(",:0123456789以外は受け付けません")
             }
 //            print("\(String(describing: textField.text))")
         }
         
         let cancelAction = UIAlertAction(title: "Cancel", style: .default) { (action:UIAlertAction!) -> Void in
         }
         // UIAlertControllerにtextFieldを追加
         alert.addTextField { (textField:UITextField!) -> Void in
             textField.keyboardType = UIKeyboardType.numbersAndPunctuation// default//.numberPad
             if self.ettMode==0{
                 textField.text=self.ettModeText0
             }else if self.ettMode==1{
                 textField.text=self.ettModeText1
             }else if self.ettMode==2{
                 textField.text=self.ettModeText2
             }else{
                 textField.text=self.ettModeText3
             }
         }
         alert.addAction(cancelAction)//この行と下の行の並びを変えるとCancelとOKの左右が入れ替わる。
         alert.addAction(saveAction)
         present(alert, animated: true, completion: nil)
         
     }
     */
    
    
    
    
    @IBAction func onTapGestureFace(_ sender: Any) {
        print("face")
        let alert = UIAlertController(title: "", message: "", preferredStyle: .alert)
        let saveAction = UIAlertAction(title: "OK", style: .default) { [self] (action:UIAlertAction!) -> Void in
            // 入力したテキストをコンソールに表示
            let textField = alert.textFields![0] as UITextField
//            let ettString:String = textField.text!
//            let value=Int(textField.text!)
            if Int(textField.text!) != nil{//camera.checkEttString(ettStr: ettString){
                multiFace.text=textField.text
                UserDefaults.standard.set(Int(textField.text!), forKey: "multiFace")
            }else{
                let dialog = UIAlertController(title: "", message: "0123456789 are available.", preferredStyle: .alert)
                //ボタンのタイトル
                dialog.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                //実際に表示させる
                self.present(dialog, animated: true, completion: nil)
//                print(",:0123456789以外は受け付けません")
            }
//            print("\(String(describing: textField.text))")
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .default) { (action:UIAlertAction!) -> Void in
        }
        // UIAlertControllerにtextFieldを追加
        alert.addTextField { (textField:UITextField!) -> Void in
            textField.keyboardType = UIKeyboardType.numberPad//numbersAndPunctuation// default//.numberPad

        }
        alert.addAction(cancelAction)//この行と下の行の並びを変えるとCancelとOKの左右が入れ替わる。
        alert.addAction(saveAction)
        present(alert, animated: true, completion: nil)
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        let ww=view.bounds.width
        let wh=view.bounds.height
        let top:CGFloat=40//CGFloat(UserDefaults.standard.float(forKey: "top"))
        let bottom:CGFloat=20//CGFloat( UserDefaults.standard.float(forKey: "bottom"))
        let sp:CGFloat=5
        let bw:CGFloat=(ww-10*sp)/7//最下段のボタンの高さ、幅と同じ
        let bh=bw
        let by0=top+sp+wh/30*2
        let by1=wh-bottom-3*sp-2*bh
        multiEye.text=getUserDefault(str:"multiEye" , ret:100).description
        multiFace.text=getUserDefault(str:"multiFace" , ret:100).description
        
        setLabelProperty(multiEye, x: sp*2.5+bw*0.5, y: by0, w: bw, h: wh/30, UIColor.systemGray5)
        multiEyeText.frame=CGRect(x: multiEye.frame.maxX+sp, y: by0, width: bw*10, height: wh/30)

        setLabelProperty(multiFace,x:sp*2.5+bw*0.5,y:by0+sp+wh/30,w: bw,h: wh/30,UIColor.systemGray5)
        multiFaceText.frame=CGRect(x: multiEye.frame.maxX+sp, y: by0+sp+wh/30, width: bw*10, height: wh/30)

//            setButtonProperty(mailButton,x:sp*2.5+bw*0.5,y:by1,w:bw,h:bh,UIColor.blue)

        defaultButton.frame=CGRect(x:sp*2.5+bw*0.5,y:by1,width: bw,height: bh)
        defaultButton.layer.cornerRadius=5
        
        exitButton.frame=CGRect(x:sp*7.5+bw*5.5,y:by1,width: bw,height: bh)
        exitButton.layer.cornerRadius=5
        

        // Do any additional setup after loading the view.
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
