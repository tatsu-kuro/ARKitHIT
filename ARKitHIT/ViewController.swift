//  ViewController.swift

import UIKit
import SceneKit
import ARKit
import AssetsLibrary
import Photos
//import WebKit
extension UIImage {
    func resize(size _size: CGSize) -> UIImage? {
        let widthRatio = _size.width / size.width
        let heightRatio = _size.height / size.height
        let ratio = widthRatio < heightRatio ? widthRatio : heightRatio
        
        let resizedSize = CGSize(width: size.width * ratio, height: size.height * ratio)
        
        UIGraphicsBeginImageContextWithOptions(resizedSize, false, 0.0) // 変更
        draw(in: CGRect(origin: .zero, size: resizedSize))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return resizedImage
    }
}
@available(iOS 13.0, *)
class ViewController: UIViewController, ARSCNViewDelegate, ARSessionDelegate {
    @IBOutlet weak var typeButton: UIButton!
    @IBOutlet weak var listButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var waveClearButton: UIButton!
    @IBOutlet weak var ARStartButton: UIButton!
    @IBOutlet weak var setteiButton: UIButton!
    @IBOutlet weak var how2Button: UIButton!
    @IBOutlet weak var waveBoxView: UIImageView!
    @IBOutlet weak var vHITBoxView: UIImageView!
    @IBOutlet var sceneView: ARSCNView!
    @IBOutlet weak var lookAtPositionXLabel: UILabel!
    @IBOutlet weak var lookAtPositionYLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    
    @IBOutlet weak var sceneCopyView: UIImageView!
    @IBOutlet weak var waveSlider: UISlider!
    var defaultAlbumName:String = "ARvHIT"
    
    @IBOutlet weak var dataTypeLabel: UILabel!
    var multiEye:CGFloat=100
    var multiFace:CGFloat=100
    var arKitDisplayMode:Bool=true
    var faceAnchorFlag:Bool=false
     var dataType:Int=0
    @IBAction func onTypeButton(_ sender: Any) {
        dataType += 1
        if dataType>5{
            dataType=0
        }
        var text1="angle\n"
        if dataType>2{
        text1="anglar velocity\n"
        }
        if dataType%3==0{
            dataTypeLabel.text=text1 + "red:eyeRoll, black:headRoll"
        }else if dataType%3==1{
            dataTypeLabel.text=text1 + "red:eyePitch, black:headPitch"
        }else{//} dataType>=2{
            dataTypeLabel.text=text1 + "red:eyeYaw, black:headYaw"
        }
    }
    struct vHIT {
        var isRight : Bool
        var frameN : Int
        var dispOn : Bool
        var currDispOn : Bool
        var eye = [CGFloat](repeating:0,count:31)
        var face = [CGFloat](repeating:0,count:31)
    }
    struct wave{
        var eye:CGFloat
   //     var rtEye:CGFloat
        var face:CGFloat
        var date:String
    }
    var waves=[wave]()
    
    var vHITs = [vHIT]()
    var vHITwave = [CGFloat](repeating: 0, count: 31)
    func append_vHITs(isRight:Bool,frameN:Int,dispOn:Bool,currDispOn:Bool){
        let temp=vHIT(isRight: isRight,frameN: frameN, dispOn: dispOn, currDispOn: currDispOn,eye:vHITwave,face:vHITwave)
        vHITs.append(temp)
    }
    
    //    var faceNode: SCNNode = SCNNode()
    //ここで表示、
    var faceNode: SCNNode = {
        let geometry = SCNCone(topRadius: 0.005, bottomRadius: 0, height: 0.2)
        geometry.radialSegmentCount = 3
        geometry.firstMaterial?.diffuse.contents = UIColor.blue
        let node = SCNNode()
        node.geometry = geometry
        node.eulerAngles.x = -.pi / 2
        node.position.z = 0.1
        let parentNode = SCNNode()
        parentNode.addChildNode(node)
        return parentNode
    }()
    var eyeLNode: SCNNode = {
        let geometry = SCNCone(topRadius: 0.005, bottomRadius: 0, height: 0.2)
        geometry.radialSegmentCount = 3
        geometry.firstMaterial?.diffuse.contents = UIColor.blue
        let node = SCNNode()
        node.geometry = geometry
        node.eulerAngles.x = -.pi / 2
        node.position.z = 0.1
        let parentNode = SCNNode()
        parentNode.addChildNode(node)
        return parentNode
    }()
    
    var eyeRNode: SCNNode = {
        let geometry = SCNCone(topRadius: 0.005, bottomRadius: 0, height: 0.2)
        geometry.radialSegmentCount = 3
        geometry.firstMaterial?.diffuse.contents = UIColor.blue
        let node = SCNNode()
        node.geometry = geometry
        node.eulerAngles.x = -.pi / 2
        node.position.z = 0.1
        let parentNode = SCNNode()
        parentNode.addChildNode(node)
        return parentNode
    }()
    
    var lookAtTargetEyeLNode: SCNNode = SCNNode()
    var lookAtTargetEyeRNode: SCNNode = SCNNode()
    
    // actual physical size of iPhoneX screen
    let phoneScreenSize = CGSize(width: 0.0623908297, height: 0.135096943231532)
    
    // actual point size of iPhoneX screen
    let phoneScreenPointSize = CGSize(width: 375, height: 812)
    
    var virtualPhoneNode: SCNNode = SCNNode()
    
    var virtualScreenNode: SCNNode = {
        
        let screenGeometry = SCNPlane(width: 1, height: 1)
        screenGeometry.firstMaterial?.isDoubleSided = true
        screenGeometry.firstMaterial?.diffuse.contents = UIColor.green
        
        return SCNNode(geometry: screenGeometry)
    }()
    
    var eyeLookAtPositionXs: [CGFloat] = []
    
    var eyeLookAtPositionYs: [CGFloat] = []
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }
    func getUserDefault(str:String,ret:Int) -> Int{//getUserDefault_one
        if (UserDefaults.standard.object(forKey: str) != nil){//keyが設定してなければretをセット
            return UserDefaults.standard.integer(forKey:str)
        }else{
            UserDefaults.standard.set(ret, forKey: str)
            return ret
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        onTypeButton(0)
        // Setup Design Elements
        //        eyePositionIndicatorView.layer.cornerRadius = eyePositionIndicatorView.bounds.width / 2
        
        //        sceneView.layer.cornerRadius = 28
        
        // Set the view's delegate
        multiEye=CGFloat(getUserDefault(str:"multiEye" , ret:100))
        multiFace=CGFloat(getUserDefault(str:"multiFace" , ret:100))

        sceneView.delegate = self
        //        sceneView.session.delegate = self//無くてもok?
        //        sceneView.automaticallyUpdatesLighting = true//無くてもok?
        
        // Setup Scenegraph
        sceneView.scene.rootNode.addChildNode(faceNode)//無くても計算ok?表示はされない
        sceneView.scene.rootNode.addChildNode(virtualPhoneNode)//無いとだめ
        virtualPhoneNode.addChildNode(virtualScreenNode)
        faceNode.addChildNode(eyeLNode)//無いとだめ
        faceNode.addChildNode(eyeRNode)//無いとだめ
        eyeLNode.addChildNode(lookAtTargetEyeLNode)//無くてもok?
        eyeRNode.addChildNode(lookAtTargetEyeRNode)//無くてもok?
        
        // Set LookAtTargetEye at 2 meters away from the center of eyeballs to create segment vector
        lookAtTargetEyeLNode.position.z = 2//無いと計算されない表示はされる
        lookAtTargetEyeRNode.position.z = 2//無いと計算されない表示はされる
        setButtons()
        currTime=CFAbsoluteTimeGetCurrent()
        arKitFlag=true
    }
    func setButtonProperty(_ button:UIButton,x:CGFloat,y:CGFloat,w:CGFloat,h:CGFloat,_ color:UIColor){
        button.frame   = CGRect(x:x, y:y, width: w, height: h)
        button.layer.borderColor = UIColor.black.cgColor
        button.layer.borderWidth = 1.0
        button.layer.cornerRadius = 5
        button.backgroundColor = color
    }
    func takeScreenShot() -> UIImage {
//        let width: CGFloat = UIScreen.main.bounds.size.width
//        let height: CGFloat = UIScreen.main.bounds.size.height
//        let bW=view.bounds.width
//        let bH=view.bounds.height
//        let sp=realWidth/120//間隙
//        let capHeight=bH*0.93
//        let capWidth=capHeight*4/3
        let size = CGSize(width: sceneViewRect!.width, height: sceneViewRect!.height)
        let capRect = sceneViewRect// CGRect(x:-capX,y:-sp,width:bW,height:bH)
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        view.drawHierarchy(in:capRect!, afterScreenUpdates: true)
        let screenShotImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return screenShotImage
    }
    var sceneViewRect:CGRect?
    func setButtons(){
        
        let ww=view.bounds.width
        let wh=view.bounds.height
        let top:CGFloat=40//CGFloat(UserDefaults.standard.float(forKey: "top"))
        let bottom:CGFloat=20//CGFloat( UserDefaults.standard.float(forKey: "bottom"))
        let sp:CGFloat=5
        let bw:CGFloat=(ww-10*sp)/7//最下段のボタンの高さ、幅と同じ
        let bh=bw
        let by0=wh-bottom-2*sp-bh
        let by1=by0-bh-sp//2段目
        let by2=by1-bh-sp//videoSlider
        lookAtPositionXLabel.frame=CGRect(x:sp,y:top+sp,width:200,height: bh/2)
        lookAtPositionYLabel.frame=CGRect(x:sp,y:top+sp+bh/2,width:200,height:bh/2)
        distanceLabel.frame=CGRect(x:sp,y:top+sp*2+bh*2/2,width:200,height:bh/2)
        setButtonProperty(listButton,x:sp*2.5+bw*0.5,y:by1,w:bw,h:bh,UIColor.white)
        setButtonProperty(saveButton,x:sp*3.5+bw*1.5,y:by1,w:bw,h:bh,UIColor.white)
        setButtonProperty(waveClearButton,x:sp*4.5+bw*2.5,y:by1,w:bw,h: bh,UIColor.white)
        setButtonProperty(ARStartButton,x:sp*5.5+bw*3.5,y:by1,w:bw,h: bh,UIColor.white)
        setButtonProperty(setteiButton,x:sp*6.5+bw*4.5,y:by1,w:bw,h: bh,UIColor.white)
        setButtonProperty(how2Button,x:sp*7.5+bw*5.5,y:by1,w:bw,h: bh,UIColor.white)
        waveBoxView.frame=CGRect(x:0,y:wh*340/568-ww*90/320,width:ww,height: ww*180/320)
        vHITBoxView.frame=CGRect(x:0,y:wh*160/568-ww/5,width :ww,height:ww*2/5)
        sceneView.frame=CGRect(x:view.bounds.width/3,y:vHITBoxView.frame.minY-sp-view.bounds.width/4,width: view.bounds.width/3,height: view.bounds.width/4)
        let y0=vHITBoxView.frame.maxY
        let y1=waveBoxView.frame.minY
        sceneViewRect=sceneView.frame
        sceneCopyView.frame=CGRect(x:sceneView.frame.maxX+sp,y:sceneView.frame.minY,width: sceneView.frame.width,height:sceneView.frame.height)
        
//        setButtonProperty(typeButton, x: sp*7.5+bw*5.5, y: y0+(y1-y0-bh)/2, w: bw, h: bh, UIColor.white)
        typeButton.frame=CGRect(x: sp*7.5+bw*5.5, y: y0+(y1-y0-bh)/2, width: bw, height: bh)
        dataTypeLabel.frame=CGRect(x:sp*2.5+bw*0.5,y:y0+(y1-y0-bh)/2,width:400,height:bh)
 
        waveSlider.frame=CGRect(x:sp*2,y:by2,width: ww-sp*4,height:20)//とりあえず
        let sliderHeight=waveSlider.frame.height
        waveSlider.frame=CGRect(x:sp*2,y:(waveBoxView.frame.maxY+by1)/2-sliderHeight/2,width:ww-sp*4,height:sliderHeight)
    
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        guard ARFaceTrackingConfiguration.isSupported else { return }
        let configuration = ARFaceTrackingConfiguration()
        configuration.isLightEstimationEnabled = true
        
        // Run the view's session
        sceneView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
    }
    @IBAction func unwind(_ segue: UIStoryboardSegue) {
        if let vc = segue.source as? SetteiViewController{
//            let Controller:SetteiViewController = vc
            multiEye=CGFloat(getUserDefault(str:"multiEye" , ret:100))
            multiFace=CGFloat(getUserDefault(str:"multiFace" , ret:100))
        }
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    // MARK: - ARSCNViewDelegate
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        if arKitFlag==true{
            faceNode.transform = node.transform
            guard let faceAnchor = anchor as? ARFaceAnchor else { return }
            
            update(withFaceAnchor: faceAnchor)
        }
    }
    func runSession() {
        // sessionを開始
        guard ARFaceTrackingConfiguration.isSupported else { return }
        let configuration = ARFaceTrackingConfiguration()
        configuration.isLightEstimationEnabled = true
        // Run the view's session
        sceneView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
    }

    func pauseSession() {
        // sessionを停止
        sceneView.session.pause()
    }
    // MARK: - update(ARFaceAnchor)
    var currTime=CFAbsoluteTimeGetCurrent()
    func update(withFaceAnchor anchor: ARFaceAnchor) {
        if arKitFlag==true{
            eyeRNode.simdTransform = anchor.rightEyeTransform
            eyeLNode.simdTransform = anchor.leftEyeTransform
            faceNode.simdTransform = anchor.transform
            DispatchQueue.main.async {
                let face = simd_quatf(anchor.transform)
                let rEye = simd_quatf(anchor.rightEyeTransform)
                let lEye = simd_quatf(anchor.leftEyeTransform)
                let fRoll = atan2f(2.0 * (face.axis.z * face.angle + face.axis.x * face.axis.y),
                                   face.axis.x * face.axis.x - face.axis.y * face.axis.y - face.axis.z * face.axis.z + face.angle * face.angle)
                let fPitch = asin(2.0 * (face.axis.x * face.axis.z - face.axis.y * face.angle))
                let fYaw = atan2f(2.0 * (face.axis.y * face.axis.z + face.axis.x * face.angle),
                                  face.axis.x*face.axis.x + face.axis.y * face.axis.y - face.axis.z * face.axis.z - face.angle * face.angle)
                
                let rRoll = atan2f(2.0 * (rEye.axis.z * rEye.angle + rEye.axis.x * rEye.axis.y),
                                   rEye.axis.x * rEye.axis.x - rEye.axis.y * rEye.axis.y - rEye.axis.z * rEye.axis.z + rEye.angle * rEye.angle)
                let rPitch = asin(2.0 * (rEye.axis.x * rEye.axis.z - rEye.axis.y * rEye.angle))
                let rYaw = atan2f(2.0 * (rEye.axis.y * rEye.axis.z + rEye.axis.x * rEye.angle),
                                  rEye.axis.x*rEye.axis.x + rEye.axis.y * rEye.axis.y - rEye.axis.z * rEye.axis.z - rEye.angle * rEye.angle)
                
                let lRoll = atan2f(2.0 * (lEye.axis.z * lEye.angle + lEye.axis.x * lEye.axis.y),
                                   lEye.axis.x * lEye.axis.x - lEye.axis.y * lEye.axis.y - lEye.axis.z * lEye.axis.z + lEye.angle * lEye.angle)
                let lPitch = asin(2.0 * (lEye.axis.x * lEye.axis.z - lEye.axis.y * lEye.angle))
                let lYaw = atan2f(2.0 * (lEye.axis.y * lEye.axis.z + lEye.axis.x * lEye.angle),
                                  lEye.axis.x*lEye.axis.x + lEye.axis.y * lEye.axis.y - lEye.axis.z * lEye.axis.z - lEye.angle * lEye.angle)

                let eRoll = (rRoll + lRoll)/2
                let ePitch = (rPitch + lPitch)/2
                let eYaw = (rYaw + lYaw)/2
                if self.dataType==0{
                    self.updateData(eye:CGFloat(eRoll),face:CGFloat(fRoll))
                }else if self.dataType==1{
                    self.updateData(eye:CGFloat(ePitch),face:CGFloat(fPitch))
                }else if self.dataType>=2{
                    self.updateData(eye:CGFloat(eYaw),face:CGFloat(fYaw))
//                }else if self.dataType==3{
//                    self.updateData(eye:CGFloat(eRoll),face:CGFloat(eYaw))
//                }else if self.dataType==4{
//                    self.updateData(eye:CGFloat(eRoll),face:CGFloat(eYaw))
//                }else if self.dataType>4{
//                    self.updateData(eye:CGFloat(eRoll),face:CGFloat(eYaw))
               }
            }
        }
    }
 /*
    func update(withFaceAnchor anchor: ARFaceAnchor) {//original
        if arKitFlag==true{
            eyeRNode.simdTransform = anchor.rightEyeTransform
            eyeLNode.simdTransform = anchor.leftEyeTransform
            faceNode.simdTransform = anchor.transform
            //----------------
            //            let temp = SCNNode(geometry: nil)
            //            temp.simdTransform = anchor.leftEyeTransform
            //ちゃんと1/60sec毎に通っている
            //        print("leftEye:",CFAbsoluteTimeGetCurrent()-currTime,temp.rotation.x)// temp.rotation.y,temp.rotation.z)
            //----------------------
            var eyeLLookAt = CGPoint()
            var eyeRLookAt = CGPoint()
            let heightCompensation: CGFloat = 312
            DispatchQueue.main.async {
                // Perform Hit test using the ray segments that are drawn by the center of the eyeballs to somewhere two meters away at direction of where users look at to the virtual plane that place at the same orientation of the phone screen
                let phoneScreenEyeRHitTestResults = self.virtualPhoneNode.hitTestWithSegment(from: self.lookAtTargetEyeRNode.worldPosition, to: self.eyeRNode.worldPosition, options: nil)
                
                let phoneScreenEyeLHitTestResults = self.virtualPhoneNode.hitTestWithSegment(from: self.lookAtTargetEyeLNode.worldPosition, to: self.eyeLNode.worldPosition, options: nil)
                
                for result in phoneScreenEyeRHitTestResults {
                    
                    eyeRLookAt.x = CGFloat(result.localCoordinates.x) / (self.phoneScreenSize.width / 2) * self.phoneScreenPointSize.width
                    
                    eyeRLookAt.y = CGFloat(result.localCoordinates.y) / (self.phoneScreenSize.height / 2) * self.phoneScreenPointSize.height + heightCompensation
                }
                
                for result in phoneScreenEyeLHitTestResults {
                    
                    eyeLLookAt.x = CGFloat(result.localCoordinates.x) / (self.phoneScreenSize.width / 2) * self.phoneScreenPointSize.width
                    
                    eyeLLookAt.y = CGFloat(result.localCoordinates.y) / (self.phoneScreenSize.height / 2) * self.phoneScreenPointSize.height + heightCompensation
                }
                
                // Add the latest position and keep up to 8 recent position to smooth with.
                let smoothThresholdNumber: Int = 10
                self.eyeLookAtPositionXs.append((eyeRLookAt.x + eyeLLookAt.x) / 2)
                self.eyeLookAtPositionYs.append(-(eyeRLookAt.y + eyeLLookAt.y) / 2)
                self.eyeLookAtPositionXs = Array(self.eyeLookAtPositionXs.suffix(smoothThresholdNumber))
                self.eyeLookAtPositionYs = Array(self.eyeLookAtPositionYs.suffix(smoothThresholdNumber))
                
                let smoothEyeLookAtPositionX = self.eyeLookAtPositionXs.average!
                let smoothEyeLookAtPositionY = self.eyeLookAtPositionYs.average!
                
                // update indicator position
                //            self.eyePositionIndicatorView.transform = CGAffineTransform(translationX: smoothEyeLookAtPositionX, y: smoothEyeLookAtPositionY)
                
                // update eye look at labels values
                self.lookAtPositionXLabel.text = "\(Int(round(smoothEyeLookAtPositionX + self.phoneScreenPointSize.width / 2)))"
                
                self.lookAtPositionYLabel.text = "\(Int(round(smoothEyeLookAtPositionY + self.phoneScreenPointSize.height / 2)))"
                
                // Calculate distance of the eyes to the camera
                let distanceL = self.eyeLNode.worldPosition - SCNVector3Zero
                let distanceR = self.eyeRNode.worldPosition - SCNVector3Zero
                
                // Average distance from two eyes
                let distance = (distanceL.length() + distanceR.length()) / 2
                
                // Update distance label value
                self.distanceLabel.text = "\(Int(round(distance * 100))) cm"
                print("leftEye:",CFAbsoluteTimeGetCurrent()-self.currTime)
                self.updateData(eye:smoothEyeLookAtPositionX,face:smoothEyeLookAtPositionY)
            }
        }
    }
 */
    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        if arKitFlag{
            virtualPhoneNode.transform = (sceneView.pointOfView?.transform)!
        }
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        if arKitFlag{
            faceNode.transform = node.transform
            guard let faceAnchor = anchor as? ARFaceAnchor else { return }
            update(withFaceAnchor: faceAnchor)
        }
    }
    
    var initDrawBoxF:Bool=true
    func drawWaveBox(){
        let endCnt = waves.count
        var startCnt = endCnt-60//点の数
        if startCnt<0{
            startCnt=0
        }
        if initDrawBoxF==true{
            initDrawBoxF=false
        }else{
            waveBoxView.layer.sublayers?.removeLast()
        }
        //波形を時間軸で表示
        let drawImage = drawWave(startCnt:startCnt,endCnt:endCnt)
        // イメージビューに設定する
        let waveView = UIImageView(image: drawImage)
        //        vhitBoxView = UIImageView(image: vhitBoxViewImage)
        waveBoxView.addSubview(waveView)
        //        print(view.subviews.count)
    }
    @IBAction func onARStartButton(_ sender: Any) {
        getVHITWaves()
        if arKitFlag==true && waves.count>60{
            arKitFlag=false
            setWaveSlider()
            ARStartButton.setImage(  UIImage(systemName:"play.circle"), for: .normal)
            waveSlider.isEnabled=true
            waveSlider.minimumTrackTintColor=UIColor.blue
            waveSlider.maximumTrackTintColor=UIColor.blue
            getVHITWaves()
            drawVHITBox()
            pauseSession()
            sceneView.isHidden=true
        }else{
            let configuration = ARFaceTrackingConfiguration()
            configuration.isLightEstimationEnabled = true
            arKitFlag=true
            waveSlider.isEnabled=false
            ARStartButton.setImage(  UIImage(systemName:"stop.circle"), for: .normal)
            waveSlider.minimumTrackTintColor=UIColor.gray
            waveSlider.maximumTrackTintColor=UIColor.gray
            runSession()
            sceneView.isHidden=false
        }
    }
   
    func setWaveSlider(){
        waveSlider.minimumValue = 60
        waveSlider.maximumValue = Float(waves.count)
        waveSlider.value=Float(waves.count)
        waveSlider.addTarget(self, action: #selector(onWaveSliderValueChange), for: UIControl.Event.valueChanged)
    }
    func drawWave(startCnt:Int,endCnt:Int) -> UIImage {
//        print("multiEye:",multiFace)
        let size = CGSize(width:view.bounds.width, height:view.bounds.width*18/32)
        UIGraphicsBeginImageContextWithOptions(size, false, 1.0)
        // 折れ線にする点の配列
        var pointList1 = Array<CGPoint>()
        var pointList2 = Array<CGPoint>()
        let pointCount:CGFloat = 60 // 点の個数
        // xの間隔
        let dx:CGFloat = view.bounds.width/pointCount
        let y1=view.bounds.width*18/32*2/6
        let y2=view.bounds.width*18/32*4/6
        var py1:CGFloat=0
        var py2:CGFloat=0
        if endCnt>5{
            for n in startCnt..<endCnt{
                let px = dx * CGFloat(n-startCnt)
                py1 = waves[n].face * multiFace + y1
                py2 = waves[n].eye * multiEye + y2
                let point1 = CGPoint(x: px, y: py1)
                let point2 = CGPoint(x: px, y: py2)
                pointList1.append(point1)
                pointList2.append(point2)
            }
            // イメージ処理の開始
            // パスの初期化
            let drawPath1 = UIBezierPath()
            // 始点に移動する
            drawPath1.move(to: pointList1[0])
            // 配列から始点の値を取り除く
            pointList1.removeFirst()
            // 配列から点を取り出して連結していく
            for pt in pointList1 {
                drawPath1.addLine(to: pt)
            }
            // 線幅
            drawPath1.lineWidth = 0.3
            // 線の色
            UIColor.black.setStroke()
            // 線を描く
            drawPath1.stroke()
            
            let drawPath2 = UIBezierPath()
            drawPath2.move(to: pointList2[0])
            // 配列から始点の値を取り除く
            pointList2.removeFirst()
            // 配列から点を取り出して連結していく
            for pt in pointList2 {
                drawPath2.addLine(to: pt)
            }
            drawPath2.lineWidth = 0.3
            UIColor.red.setStroke()
            drawPath2.stroke()
            var text=waves[endCnt-1].date
            var text2:String=""
            if arKitFlag==false && endCnt<waves.count-15{
                text += "  n:" + endCnt.description + " head:" + Int(-waves[endCnt-1].face*10000).description
                
#if DEBUG
                text2 += Int(-waves[endCnt-1].face*10000).description + ","
                text2 += Int(-waves[endCnt].face*10000).description + ","
                text2 += Int(-waves[endCnt+1].face*10000).description + ","
                text2 += Int(-waves[endCnt+2].face*10000).description + ","
                text2 += Int(-waves[endCnt+3].face*10000).description + ","
                text2 += Int(-waves[endCnt+4].face*10000).description + ","
                text2 += Int(-waves[endCnt+5].face*10000).description + ","
                text2 += Int(-waves[endCnt+6].face*10000).description + ","
                text2.draw(at:CGPoint(x:3,y:3+20),withAttributes: [
                    NSAttributedString.Key.foregroundColor : UIColor.black,
                    NSAttributedString.Key.font : UIFont.monospacedDigitSystemFont(ofSize: 13, weight: UIFont.Weight.regular)])
#endif
                
            }
            text.draw(at:CGPoint(x:3,y:3),withAttributes: [
                NSAttributedString.Key.foregroundColor : UIColor.black,
                NSAttributedString.Key.font : UIFont.monospacedDigitSystemFont(ofSize: 13, weight: UIFont.Weight.regular)])
        }
        //イメージコンテキストからUIImageを作る
        let image = UIGraphicsGetImageFromCurrentImageContext()
        // イメージ処理の終了
        UIGraphicsEndImageContext()
        return image!
    }
    func setCurrWave(frame:Int){
        let cnt=vHITs.count
        for i in 0..<cnt{
            if vHITs[i].frameN>frame-30-15 && vHITs[i].frameN<frame-30{
                vHITs[i].currDispOn = true //sellected
            }else{
                vHITs[i].currDispOn = false//not sellected
            }
        }
    }
    var tapPosleftRight:Int=0//left-eye,right=head最初にタップした位置で
    var arKitFlag:Bool=false
    
    var moveThumX:CGFloat=0
    var moveThumY:CGFloat=0
    var startMultiFace:CGFloat=0
    var startMultiEye:CGFloat=0
    var startCnt:Int=0
    @objc func onWaveSliderValueChange(){
//        print("multi:",multiEye,multiFace)
        if waves.count<60{
            return
        }
        let endCnt=Int(waveSlider.value)
        waveBoxView.layer.sublayers?.removeLast()
        let startCnt = endCnt-60//点の数
        //波形を時間軸で表示
        let drawImage = drawWave(startCnt:startCnt,endCnt:endCnt)
        // イメージビューに設定する
        let waveView = UIImageView(image: drawImage)
        waveBoxView.addSubview(waveView)
        setCurrWave(frame: endCnt)
        //        vHITwaves[0].currDispOn=true
        drawVHITBox()
    }
    
    var lastRtEyeX:CGFloat=0
    var lastLtEyeX:CGFloat=0
    var lastFaceX:CGFloat=0
    var faceVeloX0:CGFloat=0
    var ltEyeVeloX0:CGFloat=0
    var rtEyeVeloX0:CGFloat=0
    var initFlag:Bool=true
    
    var timerCnt:Int=0
    var lastEye:CGFloat=0
    var lastFace:CGFloat=0
    func updateData(eye:CGFloat,face:CGFloat){
        timerCnt += 1
        let date = Date()
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd HH:mm:ss"// 2019-10-19 17:01:09
        var eyeCurrent=eye
        var faceCurrent=face
        if dataType>2{
            eyeCurrent = eye - lastEye
            faceCurrent = face - lastFace
        }
        waves.append(wave(eye:eyeCurrent,face:faceCurrent,date:df.string(from:date)))
        lastEye=eye
        lastFace=face
        if waves.count>60*60*2{//2min
            waves.remove(at: 0)
        }
//        sceneCopyView.image=takeScreenShot()
        drawWaveBox()
        if timerCnt%60==0{
            getVHITWaves()
            drawVHITBox()
        }
//        sceneCopyView.image=takeScreenShot()
    }
    var initDrawVHITBoxFlag:Bool=true
    func drawVHITBox(){//解析結果のvHITwavesを表示する
        if initDrawVHITBoxFlag==true{
            initDrawVHITBoxFlag=false
        }else{
            vHITBoxView.layer.sublayers?.removeLast()
        }
        
        let drawImage = drawVHIT(width:500,height:200)
        let dImage = drawImage.resize(size: CGSize(width:view.bounds.width, height:view.bounds.width*2/5))
        let vhitView = UIImageView(image: dImage)
        // 画面に表示する
        vHITBoxView.addSubview(vhitView)
    }
    func upDownp(i:Int)->Int{//60hz -> 16.7ms
        let naf:Int=5//84ms  waveWidth*60/1000
        let raf:Int=2//33ms  widthRange*60/1000
        let sl:CGFloat=0.002//slope
        if waves[i].face>0.003 || waves[i].face < -0.003{
            return 0
        }
        let g1=waves[i+1].face-waves[i].face
        let g2=waves[i+2].face-waves[i+1].face
        let g3=waves[i+3].face-waves[i+2].face
        let ga=waves[i+naf-raf+1].face-waves[i+naf-raf].face
        let gb=waves[i+naf-raf+2].face-waves[i+naf-raf+1].face
        let gc=waves[i+naf+raf+1].face-waves[i+naf+raf].face
        let gd=waves[i+naf+raf+2].face-waves[i+naf+raf+1].face
        
        if       g1 > 0  && g2>g1 && g3>g2 && ga >  sl && gb > sl  && gc < -sl  && gd < -sl  {
            return 1
        }else if g1 < 0 && g2<g1 && g3<g2 && ga < -sl && gb < -sl && gc >  sl  && gd >  sl{
            return -1
        }
        return 0
    }
    
    func setVHITWaves(number:Int) -> Int {//0:波なし 1:上向き波？ -1:その反対向きの波
        let flatwidth:Int = 2//12frame-50ms
        let t = upDownp(i: number + flatwidth)
        if t != 0 {
            if t==1{
                append_vHITs(isRight:true,frameN:number,dispOn:true,currDispOn:false)
            }else{
                append_vHITs(isRight:false,frameN:number,dispOn:true,currDispOn:false)
            }
            let n=vHITs.count-1
            for i in 0..<31{//number..<number + 30{
                vHITs[n].eye[i]=waves[number+i].eye
                vHITs[n].face[i]=waves[number+i].face
            }
        }
        return t
    }
    func getVHITWaves(){
        vHITs.removeAll()
        if waves.count < 71 {// <1sec 16.7ms*60=1002ms
            return
        }
        var skipCnt:Int = 0
        for vcnt in 30..<(waves.count - 40) {//501ms 668ms
            if skipCnt > 0{
                skipCnt -= 1
            }else if setVHITWaves(number:vcnt) != 0{
                skipCnt = 30 //16.7ms*30=501ms 間はスキップ
            }
        }
    }
    var idString:String=""
    
    func drawVHIT(width w:CGFloat,height h:CGFloat) -> UIImage {
        let size = CGSize(width:w, height:h)
        var r:CGFloat=1//r:倍率magnification
        if w==500*4{//mail
            r=4
        }
        // イメージ処理の開始
        UIGraphicsBeginImageContextWithOptions(size, false, 1.0)
        // パスの初期化
        let drawPath = UIBezierPath()
        var date = waves.count == 0 ? "" : waves[waves.count-1].date.description
        if waves.count>0{
            let date1=date.components(separatedBy: ":")
            date=date1[0] + ":" + date1[1]
        }
        let str2 = "ID:" + idString
        let str3 = "ARKit"
        date.draw(at: CGPoint(x: 258*r, y: 180*r), withAttributes: [
            NSAttributedString.Key.foregroundColor : UIColor.black,
            NSAttributedString.Key.font : UIFont.monospacedDigitSystemFont(ofSize: 15*r, weight: UIFont.Weight.regular)])
        
        str2.draw(at: CGPoint(x: 5*r, y: 180*r), withAttributes: [
            NSAttributedString.Key.foregroundColor : UIColor.black,
            NSAttributedString.Key.font : UIFont.monospacedDigitSystemFont(ofSize: 15*r, weight: UIFont.Weight.regular)])
        str3.draw(at: CGPoint(x: 455*r, y: 180*r), withAttributes: [
            NSAttributedString.Key.foregroundColor : UIColor.black,
            NSAttributedString.Key.font : UIFont.monospacedDigitSystemFont(ofSize: 15*r, weight: UIFont.Weight.regular)])
        
        UIColor.black.setStroke()
        var pList = Array<CGPoint>()
        pList.append(CGPoint(x:0,y:0))
        pList.append(CGPoint(x:0,y:180*r))
        pList.append(CGPoint(x:240*r,y:180*r))
        pList.append(CGPoint(x:240*r,y:0))
        pList.append(CGPoint(x:260*r,y:0))
        pList.append(CGPoint(x:260*r,y:180*r))
        pList.append(CGPoint(x:500*r,y:180*r))
        pList.append(CGPoint(x:500*r,y:0))
        drawPath.lineWidth = 0.1*r
        drawPath.move(to:pList[0])
        drawPath.addLine(to:pList[1])
        drawPath.addLine(to:pList[2])
        drawPath.addLine(to:pList[3])
        drawPath.addLine(to:pList[0])
        drawPath.move(to:pList[4])
        drawPath.addLine(to:pList[5])
        drawPath.addLine(to:pList[6])
        drawPath.addLine(to:pList[7])
        drawPath.addLine(to:pList[4])
        for i in 0...4 {
            drawPath.move(to: CGPoint(x:30*r + CGFloat(i)*48*r,y:0))
            drawPath.addLine(to: CGPoint(x:30*r + CGFloat(i)*48*r,y:180*r))
            drawPath.move(to: CGPoint(x:290*r + CGFloat(i)*48*r,y:0))
            drawPath.addLine(to: CGPoint(x:290*r + CGFloat(i)*48*r,y:180*r))
        }
        drawPath.stroke()
        drawPath.removeAllPoints()
        var pointListEye = Array<CGPoint>()
        var pointListFace = Array<CGPoint>()
        let dx0=CGFloat(245.0/30.0)
        //r:4(mail)  r:1(screen)
        
        
        var posY0=135*r//faceEye upUp
        if arKitDisplayMode==true{//faceEye upDown
            posY0=90*r
        }
        //        print(posY0)
        let drawPathEye = UIBezierPath()
        let drawPathFace = UIBezierPath()
        var rightCnt:Int=0
        var leftCnt:Int=0
        for i in 0..<vHITs.count{
            pointListEye.removeAll()
            pointListFace.removeAll()
            var dx:CGFloat=0
            if vHITs[i].isRight==true{
                dx=0
                rightCnt += 1
            }else{
                dx=260*r
                leftCnt += 1
            }
            for n in 0..<30{
                let px = dx + CGFloat(n)*dx0*r
                var py1 = vHITs[i].eye[n]*r*multiEye// + posY0
                var py2 = vHITs[i].face[n]*r*multiFace// + posY0
                if arKitDisplayMode==false{
                    py2 = -py2
                }
                if vHITs[i].isRight==false{
                    py1 = -py1
                    py2 = -py2
                }
                py1 += posY0
                py2 += posY0
                let point1 = CGPoint(x:px,y:py1)
                let point2 = CGPoint(x:px,y:py2)
                pointListEye.append(point1)
                pointListFace.append(point2)
            }
            // イメージ処理の開始
            // パスの初期化
            // 始点に移動する
            drawPathEye.move(to: pointListEye[0])
            // 配列から始点の値を取り除く
            pointListEye.removeFirst()
            // 配列から点を取り出して連結していく
            for pt in pointListEye {
                drawPathEye.addLine(to: pt)
            }
            drawPathFace.move(to: pointListFace[0])
            // 配列から始点の値を取り除く
            pointListFace.removeFirst()
            // 配列から点を取り出して連結していく
            for pt in pointListFace {
                drawPathFace.addLine(to: pt)
            }
            // 線の色
            if vHITs[i].isRight==true{
                UIColor.red.setStroke()
            }else{
                UIColor.blue.setStroke()
            }
            // 線幅
            //            print("currOn:",i.description,vHITs[i].currDispOn)
            if vHITs[i].currDispOn==true && vHITs[i].dispOn==true {
                drawPathEye.lineWidth = 2
                drawPathFace.lineWidth = 2
            }else if vHITs[i].currDispOn==true && vHITs[i].dispOn==false {
                drawPathEye.lineWidth = 0.6
                drawPathFace.lineWidth = 0.6
            }else if vHITs[i].currDispOn==false && vHITs[i].dispOn==true {
                drawPathEye.lineWidth = 0.3
                drawPathFace.lineWidth = 0.3
            }else if vHITs[i].currDispOn==false && vHITs[i].dispOn==false {
                drawPathEye.lineWidth = 0
                drawPathFace.lineWidth = 0
            }
            if r==4 && vHITs[i].dispOn==true{
                drawPathEye.lineWidth = 1.2
                drawPathFace.lineWidth = 1.2
            }else if r==4 {
                drawPathEye.lineWidth = 0
                drawPathFace.lineWidth = 0
            }
            drawPathEye.stroke()
            drawPathEye.removeAllPoints()
            UIColor.black.setStroke()
            drawPathFace.stroke()
            drawPathFace.removeAllPoints()
#if DEBUG
            if vHITs[i].currDispOn==true{
                var text:String=""
                for j in 2..<10{
                    if j==6{
                        text += Int(-vHITs[i].face[j]*10000).description + ","
                    }else{
                        text += Int(-vHITs[i].face[j]*10000).description + ":"
                    }
                }
                text.description.draw(at: CGPoint(x: 3*r, y: 15), withAttributes: [
                    NSAttributedString.Key.foregroundColor : UIColor.black,
                    NSAttributedString.Key.font : UIFont.monospacedDigitSystemFont(ofSize: 15*r, weight: UIFont.Weight.regular)])
            }
#endif
        }
        
        rightCnt.description.draw(at: CGPoint(x: 3*r, y: 0), withAttributes: [
            NSAttributedString.Key.foregroundColor : UIColor.black,
            NSAttributedString.Key.font : UIFont.monospacedDigitSystemFont(ofSize: 15*r, weight: UIFont.Weight.regular)])
        
        leftCnt.description.draw(at: CGPoint(x: 263*r, y: 0), withAttributes: [
            NSAttributedString.Key.foregroundColor : UIColor.black,
            NSAttributedString.Key.font : UIFont.monospacedDigitSystemFont(ofSize: 15*r, weight: UIFont.Weight.regular)])
        
        //        // イメージコンテキストからUIImageを作る
        let image = UIGraphicsGetImageFromCurrentImageContext()
        // イメージ処理の終了
        UIGraphicsEndImageContext()
        return image!
    }
    var path2albumDoneFlag:Bool=false//不必要かもしれないが念の為
    func savePath2album(path:String){
        path2albumDoneFlag=false
        savePath2album_sub(path: path)
        while path2albumDoneFlag == false{
            sleep(UInt32(0.2))
        }
    }
    func getPHAssetcollection()->PHAssetCollection{
        let requestOptions = PHImageRequestOptions()
        requestOptions.isSynchronous = true
        requestOptions.isNetworkAccessAllowed = false
        requestOptions.deliveryMode = .highQualityFormat //これでもicloud上のvideoを取ってしまう
        //アルバムをフェッチ
        let assetFetchOptions = PHFetchOptions()
        assetFetchOptions.predicate = NSPredicate(format: "title == %@", defaultAlbumName)
        let assetCollections = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .smartAlbumVideos, options: assetFetchOptions)
        //アルバムはviewdidloadで作っているのであるはず？
        //        if (assetCollections.count > 0) {
        //同じ名前のアルバムは一つしかないはずなので最初のオブジェクトを使用
        return assetCollections.object(at:0)
    }
    func savePath2album_sub(path:String){
        
        if let dir = FileManager.default.urls( for: .documentDirectory, in: .userDomainMask ).first {
            
            let fileURL = dir.appendingPathComponent( path )
            
            PHPhotoLibrary.shared().performChanges({ [self] in
                let assetRequest = PHAssetChangeRequest.creationRequestForAssetFromImage(atFileURL: fileURL)!
                let albumChangeRequest = PHAssetCollectionChangeRequest(for:  getPHAssetcollection())
                let placeHolder = assetRequest.placeholderForCreatedAsset
                albumChangeRequest?.addAssets([placeHolder!] as NSArray)
            }) { (isSuccess, error) in
                if isSuccess {
                    self.path2albumDoneFlag=true
                    // 保存成功
                } else {
                    self.path2albumDoneFlag=true
                    // 保存失敗
                }
            }
        }
    }
    
    func saveImage2path(image:UIImage,path:String) {//imageを保存
        if let dir = FileManager.default.urls( for: .documentDirectory, in: .userDomainMask ).first {
            let path_url = dir.appendingPathComponent( path )
            let pngImageData = image.pngData()
            do {
                try pngImageData!.write(to: path_url, options: .atomic)
                //                saving2pathFlag=false
            } catch {
                print("write err")//エラー処理
            }
        }
    }
    
    func existFile(aFile:String)->Bool{
        if let dir = FileManager.default.urls( for: .documentDirectory, in: .userDomainMask ).first {
            
            let path_url = dir.appendingPathComponent( aFile )
            let fileManager = FileManager.default
            if fileManager.fileExists(atPath: path_url.path){
                return true
            }else{
                return false
            }
            
        }
        return false
    }
    @IBAction func onSaveButton(_ sender: Any) {
        print("onsaveButton")
        if waves.count<1{
            return
        }
        
        let alert = UIAlertController(title: "input ID", message: "", preferredStyle: .alert)
        let saveAction = UIAlertAction(title: "OK", style: .default) { [self] (action:UIAlertAction!) -> Void in
            
            // 入力したテキストをコンソールに表示
            let textField = alert.textFields![0] as UITextField
#if DEBUG
            print("\(String(describing: textField.text))")
#endif
            self.idString = textField.text!// Field2value(field: textField)
            
            //            let textField = alert.textFields![0] as UITextField
            //            idString = textField.text!
            let drawImage = drawVHIT(width:500*4,height:200*4)
            //まずtemp.pngに保存して、それをvHIT_VOGアルバムにコピーする
            saveImage2path(image: drawImage, path: "temp.jpeg")
            while existFile(aFile: "temp.jpeg") == false{
                sleep(UInt32(0.1))
            }
            savePath2album(path: "temp.jpeg")
            drawVHITBox()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .default) { (action:UIAlertAction!) -> Void in
            self.idString = ""//キャンセルしてもここは通らない？
        }
        // UIAlertControllerにtextFieldを追加
        alert.addTextField { (textField:UITextField!) -> Void in
            textField.keyboardType = UIKeyboardType.default//numbersAndPunctuation// decimalPad// default// denumberPad
            
        }
        alert.addAction(cancelAction)//この行と下の行の並びを変えるとCancelとOKの左右が入れ替わる。
        alert.addAction(saveAction)
        present(alert, animated: true, completion: nil)
    }
    @IBAction func onWaveClearButton(_ sender: Any) {
        if waves.count>59{
            waves.removeAll()
            vHITs.removeAll()
            drawVHITBox()//(width: 500, height: 200)
            drawWaveBox()//(startCnt: 0, endCnt: 0)
            waveSlider.isEnabled=false
            waveSlider.minimumTrackTintColor=UIColor.gray
            waveSlider.maximumTrackTintColor=UIColor.gray
        }
        print("waveClear")
        //        if arKitFlag==true && waves.count>60{
        //            session.pause()
        //            arKitFlag=false
        //            setWaveSlider()
        //            waveSlider.isEnabled=true
        //            waveSlider.minimumTrackTintColor=UIColor.blue
        //            waveSlider.maximumTrackTintColor=UIColor.blue
        //            getVHITWaves()
        //            drawVHITBox()
        //        }
    }
    func setDispONToggle(){
        let cnt=vHITs.count
        for i in 0..<cnt{
            if vHITs[i].currDispOn==true{
                vHITs[i].dispOn = !vHITs[i].dispOn
            }
        }
    }
    func getUserDefaultBool(str:String,ret:Bool) -> Bool{
        if (UserDefaults.standard.object(forKey: str) != nil){
            return UserDefaults.standard.bool(forKey: str)
        }else{//keyが設定してなければretをセット
            UserDefaults.standard.set(ret, forKey: str)
            return ret
        }
    }
    @IBAction func tapGesture(_ sender: UITapGestureRecognizer) {
        
        if arKitFlag==false{
            let loc=sender.location(in: view)
            if loc.y < vHITBoxView.frame.maxY && loc.y > vHITBoxView.frame.minY{
                UserDefaults.standard.set(!arKitDisplayMode,forKey: "arKitDisplayMode")
                arKitDisplayMode = getUserDefaultBool(str: "arKitDisplayMode", ret:true)
                
                drawVHITBox()
            }else{
                setDispONToggle()
                drawVHITBox()
            }
        }
    }
    
    @IBAction func panGesture(_ sender: UIPanGestureRecognizer) {
        if arKitFlag==true{
            return
        }
        let move:CGPoint = sender.translation(in: self.view)
        if sender.state == .began {
            moveThumX=0
            moveThumY=0
            if sender.location(in: view).y>waveBoxView.frame.minY{//} view.bounds.height*2/5{
                if sender.location(in: view).x<view.bounds.width/3{
                    tapPosleftRight=0
                    print("left")
                }else if sender.location(in: view).x<view.bounds.width*2/3{
                    tapPosleftRight=1
                }else{
                    tapPosleftRight=2
                    print("right")
                }
                startMultiEye=multiEye
                startMultiFace=multiFace
                startCnt=Int(waveSlider.value)
            }
        } else if sender.state == .changed {
            if sender.location(in: view).y>waveBoxView.frame.minY{//} bounds.height*2/5{
                
                moveThumX += move.x*move.x
                moveThumY += move.y*move.y
                
                moveThumX += move.x*move.x
                moveThumY += move.y*move.y
                if moveThumX>moveThumY{//横移動の和＞縦移動の和
                    //                    var endCnt=Int(waveSlider.value)
                    var endCnt=startCnt + Int(move.x/10)
                    if endCnt>waves.count-1{
                        endCnt=waves.count-1
                    }else if endCnt<60{
                        endCnt=60
                    }
                    //                    print("x:",move.x)
                    waveSlider.value=Float(endCnt)
                }else{
                    if tapPosleftRight==0{
                        multiEye=startMultiEye - move.y
                    }else if tapPosleftRight==1{
                        multiFace=startMultiFace - move.y
                        multiEye=startMultiEye - move.y
                    }else{
                        multiFace=startMultiFace - move.y
                    }
                    
                    if multiFace>4000{
                        multiFace=4000
                    }else if multiFace<10{
                        multiFace=10
                    }
                    
                    if multiEye>4000{
                        multiEye=4000
                    }else if multiEye<10{
                        multiEye=10
                    }
                }
                onWaveSliderValueChange()
            }
            
        }else if sender.state == .ended{
            UserDefaults.standard.set(multiFace, forKey: "multiFace")
            UserDefaults.standard.set(multiEye, forKey: "multiEye")
        }
        //        print("multiEye:",multiEye,multiFace)
 
    }
}
    /*
  
 
 
     override var shouldAutorotate: Bool {
         return false
     }
     override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
         return .portrait
     }
     
     override func viewDidAppear(_ animated: Bool) {
         super.viewDidAppear(animated)
                 let configuration = ARFaceTrackingConfiguration()
                 configuration.isLightEstimationEnabled = true
                 session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
     }
     */

