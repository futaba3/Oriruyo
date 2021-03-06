//
//  SetDestFloatingPanelLayout.swift
//  Oriruyo
//
//  Created by 工藤彩名 on 2022/06/04.
//

import UIKit
import FloatingPanel

class SetDestFloatingPanelLayout: FloatingPanelLayout {
    
    let position: FloatingPanelPosition = .bottom

    let initialState: FloatingPanelState = .half
    
    var anchors: [FloatingPanelState : FloatingPanelLayoutAnchoring] {
        return [
//            .full: FloatingPanelLayoutAnchor(absoluteInset: 16.0, edge: .top, referenceGuide: .safeArea),
            .half: FloatingPanelLayoutAnchor(absoluteInset: 280, edge: .bottom, referenceGuide: .safeArea)
//            .tip: FloatingPanelLayoutAnchor(absoluteInset: 50.0, edge: .bottom, referenceGuide: .safeArea)
        ]
    }
    
}
