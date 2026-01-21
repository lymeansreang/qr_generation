//
//  EnvBanner.swift
//  QR Generation
//
//  Created by AEON_Sreang on 21/1/26.
//

import Foundation
import UIKit

enum AppEnv: String {
    case dev, uat, prod

    static var current: AppEnv {
        let v = Bundle.main.object(forInfoDictionaryKey: "APP_ENV") as? String ?? "prod"
        return AppEnv(rawValue: v.lowercased()) ?? .prod
    }

    var title: String {
        switch self {
        case .dev: return "DEV"
        case .uat: return "UAT"
        case .prod: return ""
        }
    }

    var isVisible: Bool { self != .prod }
}

final class EnvBanner: UIView {
    private let label = UILabel()

    init() {
        super.init(frame: .zero)
        isUserInteractionEnabled = false

        layer.cornerRadius = 10
        layer.masksToBounds = true

        label.font = .systemFont(ofSize: 12, weight: .bold)
        label.textColor = .white
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false

        addSubview(label)
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: topAnchor, constant: 6),
            label.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -6),
            label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            label.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
        ])
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    func configure(for env: AppEnv) {
        guard env.isVisible else {
            isHidden = true
            return
        }

        isHidden = false
        label.text = env.title

        // simple color coding
        switch env {
        case .dev:
            backgroundColor = UIColor.systemRed.withAlphaComponent(0.9)
        case .uat:
            backgroundColor = UIColor.systemOrange.withAlphaComponent(0.9)
        case .prod:
            backgroundColor = .clear
        }
    }
}
