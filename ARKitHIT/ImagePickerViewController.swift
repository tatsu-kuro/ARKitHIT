//  ARKitHIT 2022/01/15 by Tatsuaki Kuroda
//  ImagePickerViewController.swift
//

import UIKit
import Photos
import AssetsLibrary
import MessageUI
class ImagePickerViewController: UIViewController, MFMailComposeViewControllerDelegate,UIImagePickerControllerDelegate, UINavigationControllerDelegate{


//    override func viewDidLoad() {
//        super.viewDidLoad()
//
//        // Do any additional setup after loading the view.
//    }
    
    @IBOutlet weak var exitButton: UIButton!
    @IBOutlet weak var mailButton: UIButton!
    var picker: UIImagePickerController!
    var button: UIButton!
    var mailImage:UIImage!
    func setButtonProperty(_ button:UIButton,x:CGFloat,y:CGFloat,w:CGFloat,h:CGFloat,_ color:UIColor){
        button.frame   = CGRect(x:x, y:y, width: w, height: h)
 //       button.layer.borderColor = UIColor.black.cgColor
   //     button.layer.borderWidth = 1.0
        button.layer.cornerRadius = 5
//        button.backgroundColor = color
    }
    func setButtons(){
        let ww=view.bounds.width
        let wh=view.bounds.height
//        let top:CGFloat=40//CGFloat(UserDefaults.standard.float(forKey: "top"))
        let bottom:CGFloat=20//CGFloat( UserDefaults.standard.float(forKey: "bottom"))
        let sp:CGFloat=5
        let bw:CGFloat=(ww-10*sp)/7//最下段のボタンの高さ、幅と同じ
        let bh=bw
        let by1=wh-bottom-2*sp-bh
//        let by1=by0-bh-sp//2段目
//        let by2=by1-bh-sp//videoSlider
        setButtonProperty(mailButton,x:sp*2.5+bw*0.5,y:by1,w:bw,h:bh,UIColor.blue)
        setButtonProperty(exitButton,x:sp*7.5+bw*5.5,y:by1,w:bw,h: bh,UIColor.blue)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
//        exitButton.layer.cornerRadius = 5
//        exitButton.layer.borderWidth = 2
//        exitButton.layer.borderColor = UIColor.black.cgColor
//        mailButton.layer.cornerRadius = 5
//        mailButton.layer.borderWidth = 2
//        mailButton.layer.borderColor = UIColor.black.cgColor
        setButtons()
        view.backgroundColor = .white

        picker = UIImagePickerController()
        picker.delegate = self
//        picker.sourceType = UIImagePickerController.SourceType.photoLibrary
        picker.sourceType = UIImagePickerController.SourceType.savedPhotosAlbum

        picker.allowsEditing = false // Whether to make it possible to edit the size etc after selecting the image
        // set picker's navigationBar appearance
        picker.view.backgroundColor = .white
        picker.navigationBar.isTranslucent = false
        picker.navigationBar.barTintColor = .blue
        picker.navigationBar.tintColor = .white
        picker.navigationBar.titleTextAttributes = [
            NSAttributedString.Key.foregroundColor: UIColor.white
        ] // Title color
        button = UIButton()
        button.addTarget(self, action: #selector(touchUpInside(_:)), for: UIControl.Event.touchUpInside)
        let width = view.frame.width
        button.setTitle("", for: UIControl.State.normal)
        button.frame.size = CGSize(width: width, height: width*2/3)//vog:1600/2400 vhit:800/2000
        button.titleLabel?.font = UIFont.systemFont(ofSize: 28)
        button.center = view.center
        button.backgroundColor = .clear
        view.addSubview(button)
        touchUpInside(button)

        self.setNeedsStatusBarAppearanceUpdate()
    }
    @objc func touchUpInside(_ sender: UIButton) {
        // show picker modal
        print("touchupinside")
        present(picker, animated: true, completion: nil)
    }
    func startMailer(videoView:UIImage, imageName:String) {
        let mailViewController = MFMailComposeViewController()
  
        mailViewController.mailComposeDelegate = self
        mailViewController.setSubject("ARKitHIT")
        let imageDataq = videoView.jpegData(compressionQuality: 1.0)
        mailViewController.addAttachmentData(imageDataq!, mimeType: "image/jpg", fileName: imageName)
        present(mailViewController, animated: true, completion: nil)
    }
    @IBAction func mailOne(_ sender: Any) {
        print("mailoneButton")
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd_HH:mm:ss"
        let str="\(formatter.string(from: Date())).jpg"
        if mailImage == nil{
            return
        }
        self.startMailer(videoView:mailImage,imageName:str)
    }
    
    override var prefersHomeIndicatorAutoHidden: Bool {
        return true
    }
    override var prefersStatusBarHidden: Bool {
        return true
    }

    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {//errorの時に通る
        
        switch result {
        case .cancelled:
            print("cancel1")
        case .saved:
            print("save")
        case .sent:
            print("send")
        case .failed:
            print("fail")
        @unknown default:
            print("unknown error")
        }
        self.dismiss(animated: true, completion: nil)
        self.dismiss(animated: true, completion: nil)
    }
    func get500x200(image:UIImage) ->UIImage{//vhit は　vogに合わせる
        // Create a context of the starting image size and set it as the current one
        let size=CGSize(width: 2000, height: 2000*2/3)
        UIGraphicsBeginImageContext(size)
        image.draw(at: CGPoint(x:0,y:2000/6))//.zero)
        let image1 = UIGraphicsGetImageFromCurrentImageContext()
        // イメージ処理の終了
        UIGraphicsEndImageContext()
        return image1!
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        if let editedImage:UIImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            print("imageSize:",editedImage.size)
            if editedImage.size.width==2000 && editedImage.size.height==800//vHIT
            {
                button.setBackgroundImage(get500x200(image: editedImage), for: .normal)
            }else{
                button.setBackgroundImage(editedImage, for: .normal)
            }
            mailImage=editedImage
            //            mailButton.isEnabled=true
            print("1:kkohadocchi-sentakusitatoki")//sentaku no toki koko wo tooru
        } else if let originalImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            button.setBackgroundImage(originalImage, for: .normal)
            print("2:korehadocchi")//dokokawakaranai
        }
        print("3:korehadocchi")//dokokawakaranai
        
        dismiss(animated: true, completion: nil)
    }

    // called when cancel select image
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        // close picker modal
        print("cancel")
//        mailButton.isEnabled=false//cancel の時はmailbuttonは効かなくする
        dismiss(animated: true, completion: nil)
        dismiss(animated: true, completion: nil)
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
class ImagePickerViewController: UIViewController, MFMailComposeViewControllerDelegate,UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    @IBOutlet weak var mailButton: UIButton!
    @IBOutlet weak var exitButton: UIButton!
    var picker: UIImagePickerController!
    var button: UIButton!
    var mailImage:UIImage!
    override func viewDidLoad() {
        super.viewDidLoad()
        exitButton.layer.cornerRadius = 5
        exitButton.layer.borderWidth = 2
        exitButton.layer.borderColor = UIColor.black.cgColor
        mailButton.layer.cornerRadius = 5
        mailButton.layer.borderWidth = 2
        mailButton.layer.borderColor = UIColor.black.cgColor
        view.backgroundColor = .white

        picker = UIImagePickerController()
        picker.delegate = self
//        picker.sourceType = UIImagePickerController.SourceType.photoLibrary
        picker.sourceType = UIImagePickerController.SourceType.savedPhotosAlbum

        picker.allowsEditing = false // Whether to make it possible to edit the size etc after selecting the image
        // set picker's navigationBar appearance
        picker.view.backgroundColor = .white
        picker.navigationBar.isTranslucent = false
        picker.navigationBar.barTintColor = .blue
        picker.navigationBar.tintColor = .white
        picker.navigationBar.titleTextAttributes = [
            NSAttributedString.Key.foregroundColor: UIColor.white
        ] // Title color
        button = UIButton()
        button.addTarget(self, action: #selector(touchUpInside(_:)), for: UIControl.Event.touchUpInside)
        let width = view.frame.width
        button.setTitle("", for: UIControl.State.normal)
        button.frame.size = CGSize(width: width, height: width*2/3)//vog:1600/2400 vhit:800/2000
        button.titleLabel?.font = UIFont.systemFont(ofSize: 28)
        button.center = view.center
        button.backgroundColor = .clear
        view.addSubview(button)
        touchUpInside(button)

        self.setNeedsStatusBarAppearanceUpdate()
    }
    @objc func touchUpInside(_ sender: UIButton) {
        // show picker modal
        print("touchupinside")
        present(picker, animated: true, completion: nil)
    }

    // MARK: ImageVicker Delegate Methods
    // called when image picked

    func get500x200(image:UIImage) ->UIImage{//vhit は　vogに合わせる
      // Create a context of the starting image size and set it as the current one
        let size=CGSize(width: 2000, height: 2000*2/3)
        UIGraphicsBeginImageContext(size)
        image.draw(at: CGPoint(x:0,y:2000/6))//.zero)
      let image1 = UIGraphicsGetImageFromCurrentImageContext()
      // イメージ処理の終了
      UIGraphicsEndImageContext()
      return image1!
  }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        if let editedImage:UIImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            print(editedImage.size)
            if editedImage.size.width==2000 && editedImage.size.height==800
            {
                button.setBackgroundImage(get500x200(image: editedImage), for: .normal)
            }else{
                button.setBackgroundImage(editedImage, for: .normal)
            }
            mailImage=editedImage
//            mailButton.isEnabled=true
            print("1:kkohadocchi-sentakusitatoki")//sentaku no toki koko wo tooru
        } else if let originalImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            button.setBackgroundImage(originalImage, for: .normal)
            print("2:korehadocchi")//dokokawakaranai
        }
        print("3:korehadocchi")//dokokawakaranai

        dismiss(animated: true, completion: nil)
    }

    // called when cancel select image
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        // close picker modal
        print("cancel")
//        mailButton.isEnabled=false//cancel の時はmailbuttonは効かなくする
        dismiss(animated: true, completion: nil)
        dismiss(animated: true, completion: nil)
    }
    
    func startMailer(videoView:UIImage, imageName:String) {
        let mailViewController = MFMailComposeViewController()
  
        mailViewController.mailComposeDelegate = self
        mailViewController.setSubject("vHIT96da")
        let imageDataq = videoView.jpegData(compressionQuality: 1.0)
        mailViewController.addAttachmentData(imageDataq!, mimeType: "image/jpg", fileName: imageName)
        present(mailViewController, animated: true, completion: nil)
    }
    
    @IBAction func mailOne(_ sender: Any) {
        print("mailoneButton")
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd_HH:mm:ss"
        let str="\(formatter.string(from: Date())).jpg"
        if mailImage == nil{
            return
        }
        self.startMailer(videoView:mailImage,imageName:str)
    }
    
    override var prefersHomeIndicatorAutoHidden: Bool {
        return true
    }
    override var prefersStatusBarHidden: Bool {
        return true
    }

    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {//errorの時に通る
        
        switch result {
        case .cancelled:
            print("cancel1")
        case .saved:
            print("save")
        case .sent:
            print("send")
        case .failed:
            print("fail")
        @unknown default:
            print("unknown error")
        }
        self.dismiss(animated: true, completion: nil)
        self.dismiss(animated: true, completion: nil)
    }
}
 */
