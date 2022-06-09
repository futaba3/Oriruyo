//
//  MapViewController.swift
//  Oriruyo
//
//  Created by 工藤彩名 on 2022/05/31.
//

import UIKit
import MapKit
import CoreLocation
import FloatingPanel
import UserNotifications

class MapViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate, FloatingPanelControllerDelegate {
    
    @IBOutlet var mapView: MKMapView!
    
    let pointOfInterestFilter = MKPointOfInterestFilter(including: [.airport, .publicTransport])
    
    var locationManager: CLLocationManager!

    var didStartUpdatingLocation = false
    var alertIsOn: Bool = false
    
    var userLocation: CLLocationCoordinate2D?
    var destLocation: CLLocationCoordinate2D?
    
    // fromSearchVC
    var request = MKLocalSearch.Request()
    var locaionName: String?
    
    // fromSetDestVC
    var alertDistance: Double?
    
    var fpc = FloatingPanelController()
    var setDestFpc = FloatingPanelController()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        // 常にライトモード（明るい外観）を指定することでダークモード適用を回避（そのうちダークモードに対応したい）
        self.overrideUserInterfaceStyle = .light
        
        // インスタンスを生成
        locationManager = CLLocationManager()
        locationManager.delegate = self
        // 数百メートルの誤差を認める
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        // 常に許可の場合、バックグラウンドでも取得できるようにする
        if CLLocationManager.authorizationStatus() == .authorizedAlways {
             // バックグラウンドでも取得する
             locationManager.allowsBackgroundLocationUpdates = true
        } else {
             // バックグラウンドでは取得しない
             locationManager.allowsBackgroundLocationUpdates = false
        }
        
        mapView.delegate = self
        mapView.pointOfInterestFilter = pointOfInterestFilter
        
        // floatingPanelの表示設定
        fpc.delegate = self
        fpc.layout = CustomFloatingPanelLayout()
        let appearance = SurfaceAppearance()
        appearance.cornerRadius = 9.5
        fpc.surfaceView.appearance = appearance
        // fromStoryboardメソッドでStoryBoardから使えるようにする
        let searchVC = SearchViewController.fromStoryboard()
        fpc.set(contentViewController: searchVC)
        fpc.track(scrollView: searchVC.table)
        fpc.addPanel(toParent: self)

    }
    
    override func viewDidAppear(_ animated: Bool) {
        initLocation()
    }
    
    func initLocation() {
        // 位置情報サービスの確認
        if !CLLocationManager.locationServicesEnabled() {
            print("No location service")
            return
        }
        
        // 位置情報許可のステータス
        switch CLLocationManager.authorizationStatus() {
        case .notDetermined:
            // 位置情報取得許可のアラートを表示
            locationManager.requestWhenInUseAuthorization()
            // 常に許可も選択できるアラートを強制表示させる
            locationManager.requestAlwaysAuthorization()
//            showAlwaysPermissionAlert()
        case .restricted, .denied:
            locationManager.requestWhenInUseAuthorization()
            locationManager.requestAlwaysAuthorization()
            showAlwaysPermissionAlert()
        case .authorizedWhenInUse:
            locationManager.requestAlwaysAuthorization()
        case .authorizedAlways:
            if !didStartUpdatingLocation {
                didStartUpdatingLocation = true
                locationManager.startUpdatingLocation()
            }
        @unknown default:
            break
        }
        
    }
    
    // 位置情報許可を「常に」にしてもらうアラート
    func showAlwaysPermissionAlert() {
        let alert = UIAlertController(title: "位置情報取得許可のお願い", message: "ORIRUYOアプリは位置情報が「常に」でない場合正しく動作しません。設定アプリから位置情報の「常に」を選択してください。", preferredStyle: .alert)
        alert.addAction(
            UIAlertAction(
                title: "設定アプリを開く",
                style: .default,
                handler: {action in
                    guard let settingsUrl =  URL(string: UIApplication.openSettingsURLString) else {
                        return
                    }
                    if UIApplication.shared.canOpenURL(settingsUrl) {
                        UIApplication.shared.open(settingsUrl, options: [:], completionHandler: nil)
                    }
                }
            )
        )
        self.present(alert, animated: true, completion: nil)
    }
    
    // 位置情報許可設定の変更に反応する
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedAlways {
            if !didStartUpdatingLocation {
                didStartUpdatingLocation = true
                locationManager.startUpdatingLocation()
            }
        } else if status == .restricted || status == .denied || status == .authorizedWhenInUse {
            showAlwaysPermissionAlert()
        }
    }
    
    // 位置情報取得できたらマップを更新
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            locationManager.stopUpdatingLocation()
            
            updateMap(currentLocation: location)
        }
    }
    
    // 位置情報を取得できなかった時のエラー
    func locationManager(_ manager: CLLocationManager, didFailWithError: Error) {
        print("Failed to find user's location")
    }
    
    
    func updateMap(currentLocation: CLLocation) {
        print("Location: \(currentLocation.coordinate.latitude), \(currentLocation.coordinate.longitude)")
        
        // 横方向（経度）の距離を5000mとする
        let horizonalRegionInMeters: Double = 5000
        
        let width = self.mapView.frame.width
        let height = self.mapView.frame.height
        
        // MapViewの画面サイズから縦横のアスペクト比を求め、縦方向（緯度）の距離を求める
        let verticalRegionInMeters = Double(height / width * CGFloat(horizonalRegionInMeters))
        
        let region: MKCoordinateRegion = MKCoordinateRegion(center: currentLocation.coordinate, latitudinalMeters: verticalRegionInMeters, longitudinalMeters: horizonalRegionInMeters)
        
        userLocation = currentLocation.coordinate
        
        mapView.setRegion(region, animated: true)
    }
    
    func showPin() {
        // floatingPanelの表示設定
        setDestFpc.delegate = self
        setDestFpc.layout = SetDestFloatingPanelLayout()
        let appearance = SurfaceAppearance()
        appearance.cornerRadius = 9.5
        setDestFpc.surfaceView.appearance = appearance
        // fromStoryboardメソッドでStoryBoardから使えるようにする（子VC内のメソッドかく）
        let setDestVC = SetDestViewController.fromStoryboard()
        setDestFpc.set(contentViewController: setDestVC)
        setDestFpc.addPanel(toParent: self)
        fpc.hide(animated: true)
        print("✋\(request)")

        let search = MKLocalSearch(request: request)

        search.start(completionHandler: {(response, error) in
            response?.mapItems.forEach { item in
                let pin = MKPointAnnotation()
                pin.coordinate = item.placemark.coordinate
                pin.title = item.placemark.title
                self.mapView.addAnnotation(pin)
                
                self.destLocation = item.placemark.coordinate
                
                setDestVC.location = item.placemark.coordinate
                setDestVC.destName = self.locaionName
                setDestVC.load()
            }
            self.mapView.showAnnotations(self.mapView.annotations, animated: true)
            self.mapView.region = MKCoordinateRegion(center: self.destLocation!, latitudinalMeters: 2500, longitudinalMeters: 2500)
            let overlay = MKCircle(center: self.destLocation!, radius: 1000)
            self.mapView.addOverlay(overlay)
        })
    }

    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let circleRenderer = MKCircleRenderer(overlay: overlay)
        circleRenderer.strokeColor = .gray
        circleRenderer.lineWidth = 1.0
        circleRenderer.fillColor = UIColor.gray.withAlphaComponent(0.2)
        return circleRenderer
    }
    
    func changeOverlay() {
        removeOverlay()
        let overlay = MKCircle(center: self.destLocation!, radius: alertDistance ?? 1000)
        self.mapView.addOverlay(overlay)
        
        let region: MKCoordinateRegion = MKCoordinateRegion(center: self.destLocation!, latitudinalMeters: self.alertDistance ?? 1000 * 2.5, longitudinalMeters: self.alertDistance ?? 1000 * 2.5)
        mapView.setRegion(region, animated: true)
    }
    
    func removeOverlay() {
        mapView.removeOverlays(mapView.overlays)
    }
    
    func setAlert() {
        alertIsOn = true
        
        let alert: UIAlertController = UIAlertController(title: "通知を設定しました", message: "多少の誤差がある他、位置情報を取得できなかった場合は適切な位置で通知を送信できないことがあります。", preferredStyle: .alert)
        alert.addAction(
            UIAlertAction(
                title: "OK",
                style: .default,
                handler: nil
            )
        )
        present(alert, animated: true, completion: nil)
        
        let content = UNMutableNotificationContent()
        content.title = "降りるよ‼️‼️‼️‼️‼️‼️‼️"
        content.body = "まもなく\(locaionName!)に到着します"
        content.sound = UNNotificationSound.default
        
        // ジオフェンス
        let region = CLCircularRegion(center: destLocation!, radius: alertDistance ?? 1000, identifier: "dest")
        // 円の中に入った時に通知、出た時は通知しない
        region.notifyOnEntry = true
        region.notifyOnExit = false
        let trigger = UNLocationNotificationTrigger.init(region: region, repeats: false)
        
        let request = UNNotificationRequest.init(identifier: "DestNotification", content: content, trigger: trigger)
        let center = UNUserNotificationCenter.current()
        center.add(request, withCompletionHandler: nil)
        print("😕通知設定しました")
        print(destLocation!)
        print(alertDistance ?? 1000)
        
//        // お試し通知（来ない）
//        let contents = UNMutableNotificationContent()
//        content.title = "test‼️‼️‼️‼️‼️‼️‼️"
//        content.body = "まもなく到着します"
//        content.sound = UNNotificationSound.default
//        let triggers = UNTimeIntervalNotificationTrigger.init(timeInterval: 60, repeats: true)
//        let requests = UNNotificationRequest.init(identifier: "identifier", content: contents, trigger: triggers)
//        center.add(requests, withCompletionHandler: nil)
    }
    
    

    func cancelAlert() {
        alertIsOn = false
        
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        print("😨通知解除")
    }

    
    func backToSearchVCFromSetDestVC() {
        mapView.removeAnnotations(mapView.annotations)
        setDestFpc.removePanelFromParent(animated: true)
        fpc.show()
    }

}
