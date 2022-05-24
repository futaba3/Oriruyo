//
//  ContentViewController.swift
//  Oriruyo
//
//  Created by 工藤彩名 on 2022/05/24.
//

import UIKit

class ContentViewController: UIViewController {

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
    }
    

}
