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
    
    var searchedDestList: [MKMapItem] = []
    
    // 文字を入れると検索候補出てくるやつ
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
        
        searchBar.delegate = self
        
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
        // キャンセルボタンを非表示
        searchBar.showsCancelButton = false
        searchBar.text = ""
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
        }
        
        return true
    }
    
//    func searchDest() {
//        // 検索条件を作成する
//        if let searchedDest = searchBar.text {
//            let request = MKLocalSearch.Request()
//            request.naturalLanguageQuery = searchedDest
//        }
//    }
    
    // セルの数
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.searchCompleter.results.count
    }
    
    // cellに表示する内容
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath as IndexPath)

        // カスタムセルではなくデフォルトのスタイルを使う（IB宣言いらない）
        var content = cell.defaultContentConfiguration()
        content.text = searchCompleter.results[indexPath.row].title
        content.image = UIImage(systemName: "mappin.circle")
        
        cell.contentConfiguration = content
        
        return cell
    }
    
    // cellが選択された時
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("aa")
    }

    // セクションの数
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        table.reloadData()
    }
    
    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        print(error)
    }
}
