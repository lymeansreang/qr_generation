//
//  CopyQRView.swift
//  QR 
//
//  Created by Sreang on 21/1/26.
//

import UIKit

class CopyQRView: UIView {
    
    private let containerImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "visa_copy")
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let userNameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let qrImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    var userName: String? {
        didSet {
            userNameLabel.text = userName
        }
    }
    
    var qrImage: UIImage? {
        didSet {
            qrImageView.image = qrImage
        }
    }
    
    override init(frame: CGRect) {
        super .init(frame: frame)
        backgroundColor = .white
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        addSubview(containerImageView)
        containerImageView.addSubview(userNameLabel)
        containerImageView.addSubview(qrImageView)
        
        NSLayoutConstraint.activate([
            containerImageView.topAnchor.constraint(equalTo: topAnchor),
            containerImageView.bottomAnchor.constraint(equalTo: bottomAnchor),
            containerImageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            containerImageView.trailingAnchor.constraint(equalTo: trailingAnchor),
            
            userNameLabel.centerXAnchor.constraint(equalTo: containerImageView.centerXAnchor),
            userNameLabel.topAnchor.constraint(equalTo: containerImageView.topAnchor, constant: 50),
            
            qrImageView.centerXAnchor.constraint(equalTo: containerImageView.centerXAnchor),
            qrImageView.centerYAnchor.constraint(equalTo: containerImageView.centerYAnchor),
            qrImageView.widthAnchor.constraint(lessThanOrEqualTo: containerImageView.widthAnchor, multiplier: 0.6),
            qrImageView.heightAnchor.constraint(equalTo: qrImageView.widthAnchor)
        ])
    }
    
}
