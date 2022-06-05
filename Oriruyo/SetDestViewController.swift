//
//  SetDestViewController.swift
//  Oriruyo
//
//  Created by 工藤彩名 on 2022/05/22.
//

import UIKit
import MapKit
import CoreLocation

class SetDestViewController: UIViewController {
    
    @IBOutlet var alertDestNameLabel: UILabel!
    @IBOutlet var alertDestAdressLabel: UILabel!
    @IBOutlet var alertDistanceLabel: UILabel!
    
    @IBOutlet var setAlertButton: UIButton!
    
    var alertIsOn: Bool = false
    
    var location: CLLocationCoordinate2D?
    var destName: String?
    
    var mapViewController = MapViewController()

    override func viewDidLoad() {
        super.viewDidLoad()
        // 常にライトモード（明るい外観）を指定することでダークモード適用を回避
        self.overrideUserInterfaceStyle = .light
        
        view.backgroundColor = .white

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
        mapViewController = (windowScene?.windows.first?.rootViewController as? MapViewController)!
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
        alertDistanceLabel.text = "通知位置　1000m手前"
        
    }
    
    // staticはどこからでも呼び出せる静的なメソッド,　StoryBoardをfpcに導入できるようにする
    static func fromStoryboard(_ storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)) -> SetDestViewController {
            let controller = storyboard.instantiateViewController(withIdentifier: "SetDestViewController") as! SetDestViewController
            return controller
        }
    
    @IBAction func changeAlertDistance() {
        
    }
    
    @IBAction func setAlert() {
        if alertIsOn == false {
            // 通知設定前
            alertIsOn = true
            setAlertButton.setTitle("通知解除", for: .normal)
            
        } else if alertIsOn == true {
            // 通知設定中
            alertIsOn = false
            setAlertButton.setTitle("ORIRUYO", for: .normal)
        }
    }
    
    @IBAction func backToSearchVC() {
        
    }

}
