//
//  SetDestViewController.swift
//  Oriruyo
//
//  Created by 工藤彩名 on 2022/05/22.
//

import UIKit
import MapKit
import CoreLocation

class SetDestViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet var alertDestNameLabel: UILabel!
    @IBOutlet var alertDestAdressLabel: UILabel!
    @IBOutlet var alertDistanceLabel: UILabel!
    
    @IBOutlet var setAlertButton: UIButton!
    @IBOutlet var backToSearchVCButton: UIButton!
    
    var alertDistance: Double? = 1000
    
    var alertIsOn: Bool = false
    
    // fromMapVC
    var location: CLLocationCoordinate2D?
    var destName: String?
    
    var mapVC = MapViewController()

    override func viewDidLoad() {
        super.viewDidLoad()
        // 常にライトモード（明るい外観）を指定することでダークモード適用を回避
        self.overrideUserInterfaceStyle = .light
        
        view.backgroundColor = .white
        
        backToSearchVCButton.layer.cornerRadius = 10
        setAlertButton.layer.cornerRadius = 10
        setAlertButton.backgroundColor = UIColor.black
        setAlertButton.setTitleColor(UIColor.white, for: .normal)
        setAlertButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 24)
        

//        // ダークモード対応用
//        view.backgroundColor = UIColor { (traitCollection: UITraitCollection) -> UIColor in
//            // ダークモードの場合
//            if traitCollection.userInterfaceStyle == .dark {
//                return .black
//            } else {
//                return .white
//            }
//        }
    
        // アプリのrootViewControllerを取得してMapViewControllerに代入する
        let scenes = UIApplication.shared.connectedScenes
        let windowScene = scenes.first as? UIWindowScene
        mapVC = (windowScene?.windows.first?.rootViewController as? MapViewController)!
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if alertIsOn == false {
            // 通知設定前
            setAlertButton.setTitle("ORIRUYO", for: .normal)
            
        } else if alertIsOn == true {
            // 通知設定中
            setAlertButton.setTitle("通知解除", for: .normal)
        }
    }
    
    func load() {
        // CLLocationCoordinate2DをCLLocationに変換する
        let destLocation: CLLocation = CLLocation(latitude: location!.latitude, longitude: location!.longitude)
        CLGeocoder().reverseGeocodeLocation(destLocation) { placemarks, error in
            if let placemark = placemarks?.first {
                // 都道府県
                let administrativeArea = placemark.administrativeArea ?? ""
                // 市区町村
                let locality = placemark.locality ?? ""
                // 地名(丁目)
                let thoroughfare = placemark.thoroughfare ?? ""
                // 番地
                let subThoroughfare = placemark.subThoroughfare ?? ""
                
                self.alertDestAdressLabel.text = "\(administrativeArea)\(locality)\(thoroughfare)\(subThoroughfare)"
            }
        }

        alertDestNameLabel.text = destName
        alertDistanceLabel.text = "通知位置　\(self.alertDistance ?? 1000)m手前"
        
    }
    
    // staticはどこからでも呼び出せる静的なメソッド,　StoryBoardをfpcに導入できるようにする
    static func fromStoryboard(_ storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)) -> SetDestViewController {
            let controller = storyboard.instantiateViewController(withIdentifier: "SetDestViewController") as! SetDestViewController
            return controller
        }
    
    @IBAction func changeAlertDistance() {
        var distanceTextField = UITextField()
        
        let alert = UIAlertController(title: "通知位置の距離を変更する", message: "メートル単位で指定してください。\nおすすめ距離\n電車:1000(m)\nバス:500(m)\n新幹線:3000(m)", preferredStyle: .alert)
        alert.addTextField{ (textField) in
            distanceTextField = textField
            distanceTextField.delegate = self
            distanceTextField.keyboardType = .decimalPad
            distanceTextField.placeholder = "1000"
            
        }
        alert.addAction(
            UIAlertAction(
                title: "決定",
                style: .default,
                handler: { [self]action in
                    if Double(distanceTextField.text!) == nil {
                        let numberAlert = UIAlertController(title: "数字で入力してください", message: "メートル単位です", preferredStyle: .alert)
                        numberAlert.addAction(UIAlertAction(
                            title: "はい",
                            style: .cancel))
                        self.present(numberAlert, animated: true, completion: nil)

                    } else {
                        self.alertDistance = Double(distanceTextField.text!)
                        self.alertDistanceLabel.text = "通知位置　\(self.alertDistance ?? 1000)m手前"
                        self.mapVC.alertDistance = alertDistance
                        self.mapVC.changeOverlay()
                    }
                }
            )
        )
        alert.addAction(
            UIAlertAction(
                title: "いいえ",
                style: .cancel,
                handler: {action in
                    print("いいえ")
                }
            )
        )
        present(alert, animated: true, completion: nil)
    }
    
    @IBAction func setAlert() {
        if alertIsOn == false {
            // 通知設定前

            // ユーザーの現在地が取得できていない場合は実行しない
            if mapVC.userLocation == nil {
                mapVC.showAlwaysPermissionAlert()
                
            } else {
                alertIsOn = true
                mapVC.setAlert()
                setAlertButton.backgroundColor = UIColor.white
                setAlertButton.setTitleColor(UIColor.black, for: .normal)
                setAlertButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 24)
                setAlertButton.layer.borderColor = UIColor.black.cgColor
                setAlertButton.layer.borderWidth = 3
                setAlertButton.setTitle("通知解除", for: .normal)
            }
            
        } else if alertIsOn == true {
            // 通知設定中
            
            let alert: UIAlertController = UIAlertController(title: "通知を解除しますか？", message: "", preferredStyle: .alert)
            alert.addAction(
                UIAlertAction(
                    title: "はい",
                    style: .destructive,
                    handler: { action in
                        
                        self.alertIsOn = false
                        self.mapVC.cancelAlert()
                        self.setAlertButton.layer.cornerRadius = 10
                        self.setAlertButton.backgroundColor = UIColor.black
                        self.setAlertButton.setTitleColor(UIColor.white, for: .normal)
                        self.setAlertButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 24)
                        self.setAlertButton.setTitle("ORIRUYO", for: .normal)
                        print("はい")
                    }
                )
            )
            alert.addAction(
                UIAlertAction(
                    title: "いいえ",
                    style: .cancel,
                    handler: {action in
                        print("いいえ")
                    }
                )
            )
            present(alert, animated: true, completion: nil)
        }
    }
    
    @IBAction func backToSearchVC() {
        let alert: UIAlertController = UIAlertController(title: "降りる場所を変更しますか？", message: "検索画面に戻ります", preferredStyle: .alert)
        // OKボタン
        alert.addAction(
            UIAlertAction(
                title: "はい",
                // .destructiveで赤文字になる
                style: .destructive,
                handler: { action in
                    if self.alertIsOn == true {
                        self.mapVC.cancelAlert()
                        self.alertIsOn = false
                    }
                    self.mapVC.removeOverlay()
                    self.mapVC.backToSearchVCFromSetDestVC()
                    print("検索画面に戻る")
                }
            )
        )
        // キャンセルボタン
        alert.addAction(
            UIAlertAction(
                title: "いいえ",
                style: .cancel,
                handler: {action in
                    print("降りる場所変えない")
                }
            )
        )
        present(alert, animated: true, completion: nil)
    }

}
