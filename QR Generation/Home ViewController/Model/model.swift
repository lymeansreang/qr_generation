//
//  model.swift
//  QR Generation
//
//  Created by AEON_Sreang on 20/1/26.
//

import Foundation

struct Model {
    var icon: String
    var title: String
    var subtitle: String
    var promo: String?
    let action: ActionType
}

enum ActionType {
    case scanQR
    case khqr
    case visaQR
}
