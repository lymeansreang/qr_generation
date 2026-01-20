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
    
    private lazy var buttonStackView: UIStackView = {
        let scanButton = makeIconButton(
            title: "Save",
            systemImage: "square.and.arrow.down",
            action: #selector(didTapSave)
        )

        let generateButton = makeIconButton(
            title: "Share",
            systemImage: "square.and.arrow.up",
            action: #selector(didTapShare)
        )

        let stackView = UIStackView(arrangedSubviews: [scanButton, generateButton])
        stackView.axis = .horizontal
        stackView.spacing = 12
        stackView.distribution = .fillEqually
        stackView.translatesAutoresizingMaskIntoConstraints = false
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
    
    @objc private func didTapSave() {
        print("Save tapped")
    }

    @objc private func didTapShare() {
        print("Share tapped")
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
        qrContainerView.addSubview(buttonStackView)
        
        NSLayoutConstraint.activate([
            qrContainerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            qrContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            qrContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32),
            qrContainerView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -170),

            pinkStripView.topAnchor.constraint(equalTo: qrContainerView.topAnchor),
            pinkStripView.leadingAnchor.constraint(equalTo: qrContainerView.leadingAnchor),
            pinkStripView.trailingAnchor.constraint(equalTo: qrContainerView.trailingAnchor),
            pinkStripView.heightAnchor.constraint(equalToConstant: 32),

            visaLogoImageView.topAnchor.constraint(equalTo: pinkStripView.bottomAnchor, constant: 16),
            visaLogoImageView.centerXAnchor.constraint(equalTo: qrContainerView.centerXAnchor),
            visaLogoImageView.widthAnchor.constraint(equalToConstant: 80),
            visaLogoImageView.heightAnchor.constraint(equalToConstant: 50),

            visaDescriptionLabel.topAnchor.constraint(equalTo: visaLogoImageView.bottomAnchor, constant: 4),
            visaDescriptionLabel.centerXAnchor.constraint(equalTo: qrContainerView.centerXAnchor),

            visaQRContainerView.topAnchor.constraint(equalTo: visaDescriptionLabel.bottomAnchor, constant: 12),
            visaQRContainerView.leadingAnchor.constraint(equalTo: qrContainerView.leadingAnchor, constant: 28),
            visaQRContainerView.trailingAnchor.constraint(equalTo: qrContainerView.trailingAnchor, constant: -28),
            visaQRContainerView.heightAnchor.constraint(equalTo: qrContainerView.heightAnchor, multiplier: 0.5),

            visaQRImageView.topAnchor.constraint(equalTo: visaQRContainerView.topAnchor, constant: 12),
            visaQRImageView.bottomAnchor.constraint(equalTo: visaQRContainerView.bottomAnchor, constant: -12),
            visaQRImageView.leadingAnchor.constraint(equalTo: visaQRContainerView.leadingAnchor, constant: 12),
            visaQRImageView.trailingAnchor.constraint(equalTo: visaQRContainerView.trailingAnchor, constant: -12),

            userNameLabel.topAnchor.constraint(equalTo: visaQRContainerView.bottomAnchor, constant: 18),
            userNameLabel.centerXAnchor.constraint(equalTo: qrContainerView.centerXAnchor),

            accountNumberLabel.topAnchor.constraint(equalTo: userNameLabel.bottomAnchor, constant: 4),
            accountNumberLabel.centerXAnchor.constraint(equalTo: qrContainerView.centerXAnchor),

            buttonStackView.leadingAnchor.constraint(equalTo: qrContainerView.leadingAnchor, constant: 28),
            buttonStackView.trailingAnchor.constraint(equalTo: qrContainerView.trailingAnchor, constant: -28),
            buttonStackView.bottomAnchor.constraint(equalTo: qrContainerView.bottomAnchor, constant: -16),
            buttonStackView.heightAnchor.constraint(equalToConstant: 52),
        ])

    }
}

extension VISAViewController {
    
    private func makeIconButton( title: String, systemImage: String, action: Selector) -> UIButton {
        
        if #available(iOS 15.0, *) {
            var config = UIButton.Configuration.filled()
            config.title = title
            config.image = UIImage(systemName: systemImage)
            config.imagePlacement = .leading
            config.imagePadding = 8
            config.cornerStyle = .medium
            
            let button = UIButton(configuration: config)
            button.addTarget(self, action: action, for: .touchUpInside)
            
            return button
            
        }
        return UIButton()
    }
    
}
