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
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // New: amount label shown below the name
    private let amountLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        label.textAlignment = .center
        label.textColor = .black
        label.isHidden = true
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
    
    private let bakongIconView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "bakong_qr"))
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
    
    var amountString: String? {
        
        didSet { updateAmountLabel() }
       
    }
    var currencyNumeric: String? {
        didSet { updateAmountLabel() }
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
        containerImageView.addSubview(amountLabel)
        containerImageView.addSubview(qrImageView)
        qrImageView.addSubview(bakongIconView)
        
        NSLayoutConstraint.activate([
            containerImageView.topAnchor.constraint(equalTo: topAnchor),
            containerImageView.bottomAnchor.constraint(equalTo: bottomAnchor),
            containerImageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            containerImageView.trailingAnchor.constraint(equalTo: trailingAnchor),
            
            userNameLabel.centerXAnchor.constraint(equalTo: containerImageView.centerXAnchor),
            userNameLabel.topAnchor.constraint(equalTo: containerImageView.topAnchor, constant: 40),
            
            amountLabel.centerXAnchor.constraint(equalTo: containerImageView.centerXAnchor),
            amountLabel.topAnchor.constraint(equalTo: userNameLabel.bottomAnchor, constant: 4),
            
            qrImageView.centerXAnchor.constraint(equalTo: containerImageView.centerXAnchor),
            qrImageView.centerYAnchor.constraint(equalTo: containerImageView.centerYAnchor),
            qrImageView.widthAnchor.constraint(lessThanOrEqualTo: containerImageView.widthAnchor, multiplier: 0.6),
            qrImageView.heightAnchor.constraint(equalTo: qrImageView.widthAnchor),
            
            bakongIconView.centerXAnchor.constraint(equalTo: qrImageView.centerXAnchor),
            bakongIconView.centerYAnchor.constraint(equalTo: qrImageView.centerYAnchor),
            bakongIconView.widthAnchor.constraint(equalToConstant: 32),
            bakongIconView.heightAnchor.constraint(equalToConstant: 32),
        ])
    }
    
    private func updateAmountLabel() {
        let raw = (amountString ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        guard !raw.isEmpty else {
            amountLabel.text = nil
            amountLabel.isHidden = true
            return
        }
        let isKHR = (currencyNumeric ?? "116") == "116"
        let symbol = isKHR ? "៛" : "$"
        amountLabel.text = "\(raw) \(symbol)"
        amountLabel.isHidden = false
    }
}
