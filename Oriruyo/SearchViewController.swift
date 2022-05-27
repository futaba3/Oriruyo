//
//  SearchViewController.swift
//  Oriruyo
//
//  Created by 工藤彩名 on 2022/05/27.
//

import UIKit
import MapKit
import CoreLocation

class SearchViewController: UIViewController, UISearchBarDelegate {

    @IBOutlet var searchBar: UISearchBar!
    
    var searchedDestList: [MKMapItem] = []
    

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
        
        searchBar.delegate = self
    }
    
    // staticはどこからでも呼び出せる静的なメソッド,　StoryBoardをfpcに導入できるようにする
    static func fromStoryboard(_ storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)) -> SearchViewController {
            let controller = storyboard.instantiateViewController(withIdentifier: "SearchViewController") as! SearchViewController
            return controller
        }
    
    // 検索バーで入力する時
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        // キャンセルボタンを表示
        searchBar.setShowsCancelButton(true, animated: true)
        return true
    }
    
    // 検索バーのキャンセルがタップされた時
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        // キャンセルボタンを非表示
        searchBar.showsCancelButton = false
        // キーボードを閉じる
        searchBar.resignFirstResponder()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.endEditing(true)
        
        geocodeing()
        
    }
    
    func geocodeing() {
        // 未入力なら無視
        if "" == searchBar.text {
            return
        }
        
        // 検索
        if let searchedDest = searchBar.text {
            print(searchedDest)
            
            CLGeocoder().geocodeAddressString(searchedDest, completionHandler: { (placemarks, error) in
                
                for placemark in placemarks! {
                    // locationにplacemark.locationをCLLocationとして代入する
                    let location: CLLocation = placemark.location!
                    print("Latitude: \(location.coordinate.latitude)")
                    print("Longitude: \(location.coordinate.longitude)")
                    
                    let name: String = placemark.name!
                    print(name)
                    
 
                }
                
            })
            
        }
//        CLGeocoder().geocodeAddressString(searchedDest) { placemarks, error in
//            if let lat = placemarks?.first?.location?.coordinate.latitude {
//                print("緯度 : \(lat)")
//            }
//            if let lng = placemarks?.first?.location?.coordinate.longitude {
//                print("経度 : \(lng)")
//            }
//            if let name = placemarks.name {
//                print(name)
//            }
//            // 今は横浜を入れると横浜市役所が出てくるから駅名表示できるようにしたい
//        }
        
//        CLGeocoder().geocodeAddressString(dest) { placemarks, error in
//            if let destName = placemarks {
//
//                print("緯度 : \(destName)")
//            }
//            if let lng = placemarks?.first?.location?.coordinate.longitude {
//                print("経度 : \(lng)")
//            }
//        }
        
    }



}
