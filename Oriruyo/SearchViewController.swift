//
//  SearchViewController.swift
//  Oriruyo
//
//  Created by 工藤彩名 on 2022/05/27.
//

import UIKit
import MapKit
import CoreLocation

class SearchViewController: UIViewController, UISearchBarDelegate, MKLocalSearchCompleterDelegate, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet var searchBar: UISearchBar!
    
    @IBOutlet var table: UITableView!
    
    var mapVC = MapViewController()
    
    // 文字入れると検索候補が出る、クエリの補完
    let searchCompleter = MKLocalSearchCompleter()
    let pointOfInterestFilter = MKPointOfInterestFilter(including: [.airport, .publicTransport])

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
        mapVC = (windowScene?.windows.first?.rootViewController as? MapViewController)!
        
        searchBar.delegate = self
        // 空のUIImageを設定すると上下の黒い線が消える
        searchBar.backgroundImage = UIImage()
        
        searchCompleter.delegate = self
        searchCompleter.pointOfInterestFilter = pointOfInterestFilter
        searchCompleter.resultTypes = .pointOfInterest
        
        table.dataSource = self
        table.delegate = self
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
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        // キャンセルボタンを非表示
        searchBar.showsCancelButton = false
        // キーボードを閉じる
        searchBar.resignFirstResponder()
        
        table.reloadData()
    }
    
//    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
//        searchBar.endEditing(true)
//
//        if (searchBar.text != "") {
//            searchDest()
//        }
//    }
//
    // Completerを使って検索結果を表示する
    func searchBar(_ searchBar: UISearchBar, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if let searchText = searchBar.text {
            searchCompleter.queryFragment = searchText
            // searchCompleter.resultsに検索結果のMKLocalSearchCompletionが入る
        }
        
        return true
    }
    
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        table.reloadData()
    }
    
    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        print(error)
    }
    
    // セルの数
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.searchCompleter.results.count
    }
    
    // cellに表示する内容
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath as IndexPath)

        // カスタムセルではなくデフォルトの設定を取得する
        var content = cell.defaultContentConfiguration()
        
        content.text = searchCompleter.results[indexPath.row].title
//        content.secondaryText = searchCompleter.results[indexPath.row].subtitle
        content.image = UIImage(systemName: "mappin.circle")
        
        cell.contentConfiguration = content
        
        return cell
    }
    
    // cellが選択された時
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // キーボードを閉じる
        searchBar.resignFirstResponder()
        table.deselectRow(at: indexPath, animated: true)
        
        mapVC.request = MKLocalSearch.Request(completion: searchCompleter.results[indexPath.row])
        mapVC.locaionName = searchCompleter.results[indexPath.row].title
        
        mapVC.showPin()
        
    }

    // セクションの数
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
}
