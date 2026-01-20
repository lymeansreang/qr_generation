//
//  VISAViewController.swift
//  QR Generation
//
//  Created by AEON_Sreang on 20/1/26.
//

import UIKit

class VISAViewController: UIViewController {
    
    private let qrContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 26
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.2
        view.layer.shadowOffset = .zero
        view.layer.shadowRadius = 8
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let pinkStripView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemPink
        view.clipsToBounds = true
        view.layer.cornerRadius = 20
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let visaLogoImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "VISA"))
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let visaDescriptionLabel: UILabel = {
        let label = UILabel()
        label.text = "GLOBAL PAYMENT STANDARD"
        label.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
        label.textColor = .gray
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let visaQRContainerView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 18
        view.layer.borderColor = UIColor.lightGray.cgColor
        view.layer.borderWidth = 2
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let visaQRImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let userNameLabel: UILabel = {
        let label = UILabel()
        label.text = "Ly Mean Sreang"
        label.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        label.textColor = .black
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let accountNumberLabel: UILabel = {
        let label = UILabel()
        label.text = "ID: 4444 3333 2222 1111"
        label.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        label.textColor = .lightGray
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let buttonStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 8
        stackView.distribution = .equalSpacing
        return stackView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationItem.title = "My VISA QR"
    }
    
    private func setupView() {
        view.addSubview(qrContainerView)
        qrContainerView.addSubview(pinkStripView)
        qrContainerView.addSubview(visaLogoImageView)
        qrContainerView.addSubview(visaDescriptionLabel)
        qrContainerView.addSubview(visaQRContainerView)
        visaQRContainerView.addSubview(visaQRImageView)
        qrContainerView.addSubview(userNameLabel)
        qrContainerView.addSubview(accountNumberLabel)
        
        
        NSLayoutConstraint.activate([
            qrContainerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            qrContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            qrContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32),
            qrContainerView.heightAnchor.constraint(equalToConstant: CGRectGetHeight(UIScreen.main.bounds) * 0.7),
            
            pinkStripView.topAnchor.constraint(equalTo: qrContainerView.topAnchor),
            pinkStripView.widthAnchor.constraint(equalTo: qrContainerView.widthAnchor),
            pinkStripView.heightAnchor.constraint(equalToConstant: 32),
            
            visaLogoImageView.topAnchor.constraint(equalTo: pinkStripView.bottomAnchor, constant: 16),
            visaLogoImageView.centerXAnchor.constraint(equalTo: qrContainerView.centerXAnchor),
            visaLogoImageView.widthAnchor.constraint(equalToConstant: 80),
            visaLogoImageView.heightAnchor.constraint(equalToConstant: 50),
            
            visaDescriptionLabel.topAnchor.constraint(equalTo: visaLogoImageView.bottomAnchor),
            visaDescriptionLabel.centerXAnchor.constraint(equalTo: visaLogoImageView.centerXAnchor),
            
            visaQRContainerView.topAnchor.constraint(equalTo: visaDescriptionLabel.bottomAnchor, constant: 12),
            visaQRContainerView.leadingAnchor.constraint(equalTo: qrContainerView.leadingAnchor, constant: 28),
            visaQRContainerView.trailingAnchor.constraint(equalTo: qrContainerView.trailingAnchor, constant: -28),
            visaQRContainerView.heightAnchor.constraint(equalToConstant: CGRectGetHeight(UIScreen.main.bounds) * 0.35),
            
            userNameLabel.topAnchor.constraint(equalTo: visaQRContainerView.bottomAnchor, constant: 18),
            userNameLabel.centerXAnchor.constraint(equalTo: visaQRContainerView.centerXAnchor),
            
            accountNumberLabel.topAnchor.constraint(equalTo: userNameLabel.bottomAnchor, constant: 4),
            accountNumberLabel.centerXAnchor.constraint(equalTo: visaQRContainerView.centerXAnchor),
        ])
    }
}

extension VISAViewController {
    
}
