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
    
    var alertIsOn: Bool = false
    
    var location: CLLocationCoordinate2D?

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
        
//        let appDelegate = UIApplication.shared.delegate as! AppDelegate
//        print("😓")
//        print(appDelegate.locationLat)
//        print(appDelegate.locationLong)
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
            
        } else if alertIsOn == true {
            // 通知設定中
            
        }
    }

}
