//
//  CustomFloatingPanelLayout.swift
//  Oriruyo
//
//  Created by 工藤彩名 on 2022/05/27.
//

import UIKit
import FloatingPanel

class CustomFloatingPanelLayout: FloatingPanelLayout {
    
    let position: FloatingPanelPosition = .bottom

    let initialState: FloatingPanelState = .full
    
    var anchors: [FloatingPanelState : FloatingPanelLayoutAnchoring] {
        return [
            .full: FloatingPanelLayoutAnchor(absoluteInset: 16.0, edge: .top, referenceGuide: .safeArea),
            .half: FloatingPanelLayoutAnchor(fractionalInset: 0.5, edge: .bottom, referenceGuide: .safeArea),
//            .tip: FloatingPanelLayoutAnchor(absoluteInset: 50.0, edge: .bottom, referenceGuide: .safeArea)
        ]
    }
}
