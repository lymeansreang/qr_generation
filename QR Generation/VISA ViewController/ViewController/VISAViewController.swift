//
//  VISAViewController.swift
//  QR Generation
//
//  Created by AEON_Sreang on 20/1/26.
//

import UIKit
import CoreImage
import Photos

final class VISAViewController: UIViewController {
    
    // MARK: - QR Payload (what QR encodes)
    private var currentPayload: String = ""
    
    // MARK: - UI
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
        view.clipsToBounds = true
        return view
    }()
    
    private let visaQRImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.layer.borderWidth = 2
        imageView.layer.borderColor = UIColor.white.cgColor
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
    
    private let userNameLabel: UILabel = {
        let label = UILabel()
        label.text = "Tazorng Cafe"
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
        let copyButton = makeIconButton(
            title: "Copy",
            systemImage: "copy",
            action: #selector(didTapCopy)
        )
        
        let saveButton = makeIconButton(
            title: "Save",
            systemImage: "save",
            action: #selector(didTapSave)
        )
        
        //        let shareButton = makeIconButton(
        //            title: "Share",
        //            systemImage: "share",
        //            action: #selector(didTapShare)
        //        )
        
        let stackView = UIStackView(arrangedSubviews: [copyButton, saveButton])
        stackView.axis = .horizontal
        stackView.spacing = 12
        stackView.distribution = .fillEqually
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    var userName: String?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupView()
        
        // Build payload + generate QR immediately
        generateAndRenderQR()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.title = "My VISA QR"
    }
    
    @objc private func didTapCopy() {
        let copyView = CopyQRView(frame: CGRect(x: 0, y: 0, width: 235, height: 350))
        copyView.userName = userName ?? userNameLabel.text
        copyView.qrImage = visaQRImageView.image
        
        copyView.setNeedsLayout()
        copyView.layoutIfNeeded()
        
        let composedImage = copyView.asImage()
        UIPasteboard.general.image = composedImage
        showToast("QR card copied")
    }
    
    @objc private func didTapShare() {
        // Compose a shareable image using CopyQRView template
        let copyView = CopyQRView(frame: CGRect(x: 0, y: 0, width: 235, height: 350))
        copyView.userName = userName ?? userNameLabel.text
        copyView.qrImage = visaQRImageView.image
        copyView.setNeedsLayout()
        copyView.layoutIfNeeded()
        let composedImage = copyView.asImage()
        
        let activityVC = UIActivityViewController(activityItems: [composedImage], applicationActivities: nil)
        if let popover = activityVC.popoverPresentationController {
            popover.sourceView = self.view
            popover.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.maxY - 100, width: 0, height: 0)
            popover.permittedArrowDirections = []
        }
        present(activityVC, animated: true)
    }
    
    @objc private func didTapSave() {
        // Compose a savable image using CopyQRView template
        let copyView = CopyQRView(frame: CGRect(x: 0, y: 0, width: 235, height: 350))
        copyView.userName = userName ?? userNameLabel.text
        copyView.qrImage = visaQRImageView.image
        copyView.setNeedsLayout()
        copyView.layoutIfNeeded()
        let composedImage = copyView.asImage()
        
        // Request permission and save
        requestPhotoAccessAndSave(composedImage)
    }
    
    @objc private func saveImageCompleted(_ image: UIImage,
                                          didFinishSavingWithError error: Error?,
                                          contextInfo: UnsafeRawPointer) {
        if let error = error {
            showToast("Save failed: \(error.localizedDescription)")
        } else {
            showToast("Saved to Photos ✅")
        }
    }
    
    private func requestPhotoAccessAndSave(_ image: UIImage) {
        if #available(iOS 14, *) {
            let status = PHPhotoLibrary.authorizationStatus(for: .addOnly)
            
            switch status {
            case .authorized, .limited:
                UIImageWriteToSavedPhotosAlbum(image, self, #selector(saveImageCompleted(_:didFinishSavingWithError:contextInfo:)), nil)
            case .notDetermined:
                PHPhotoLibrary.requestAuthorization(for: .addOnly) { [weak self] newStatus in
                    DispatchQueue.main.async {
                        guard let self = self else { return }
                        if newStatus == .authorized || newStatus == .limited {
                            UIImageWriteToSavedPhotosAlbum(image, self, #selector(self.saveImageCompleted(_:didFinishSavingWithError:contextInfo:)), nil)
                        } else {
                            self.presentPhotosDeniedAlert()
                        }
                    }
                }
            default:
                presentPhotosDeniedAlert()
            }
        }
    }
    
    private func presentPhotosDeniedAlert() {
        let alert = UIAlertController(title: "Allow Photo Access", message: "To save your QR card, allow Photos access in Settings.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Open Settings", style: .default, handler: { _ in
            if let url = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(url)
            }
        }))
        present(alert, animated: true)
    }
    
    private func generateAndRenderQR() {
        // Starter EMV-like payload (minimal template).
        // Later you can add real Visa Merchant Account Info (tag 26 etc).
        let payload = EMVQR.buildMerchantPresented(
            merchantName: "Tazorng Cafe",
            merchantCity: "Phnom Penh",
            countryCode: "KH",
            currencyNumeric: "116",
            amount: "10.00",
            isDynamic: true
        )
        
        currentPayload = payload
        
        visaQRImageView.image = QRCodeGenerator.makeQR(from: payload, scale: 10)
    }
    
    
    private func setupView() {
        view.addSubview(qrContainerView)
        qrContainerView.addSubview(pinkStripView)
        qrContainerView.addSubview(visaLogoImageView)
        qrContainerView.addSubview(visaDescriptionLabel)
        qrContainerView.addSubview(visaQRContainerView)
        visaQRContainerView.addSubview(visaQRImageView)
        visaQRImageView.addSubview(bakongIconView)
        qrContainerView.addSubview(userNameLabel)
        qrContainerView.addSubview(accountNumberLabel)
        qrContainerView.addSubview(buttonStackView)
        
        NSLayoutConstraint.activate([
            qrContainerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            qrContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            qrContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32),
            qrContainerView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -150),
            
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
            
            bakongIconView.centerXAnchor.constraint(equalTo: visaQRImageView.centerXAnchor),
            bakongIconView.centerYAnchor.constraint(equalTo: visaQRImageView.centerYAnchor),
            bakongIconView.widthAnchor.constraint(equalToConstant: 32),
            bakongIconView.heightAnchor.constraint(equalToConstant: 32),
            
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
    private func makeIconButton(title: String, systemImage: String, action: Selector) -> UIButton {
        if #available(iOS 15.0, *) {
            var config = UIButton.Configuration.filled()
            
            config.title = title
            config.image = UIImage(named: systemImage)?
                .resized(to: CGSize(width: 20, height: 20))
            
            config.imagePlacement = .leading
            config.imagePadding = 8
            config.cornerStyle = .large
            config.baseBackgroundColor = .white
            config.baseForegroundColor = .black
            
            let button = UIButton(configuration: config)
            button.addTarget(self, action: action, for: .touchUpInside)
            button.backgroundColor = .white
            button.clipsToBounds = true
            button.layer.borderWidth = 1
            button.layer.borderColor = UIColor.gray.cgColor
            return button
        }
        
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.addTarget(self, action: action, for: .touchUpInside)
        return button
    }
}


extension VISAViewController {
    private func showToast(_ message: String) {
        let label = UILabel()
        label.text = message
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 13, weight: .semibold)
        label.textColor = .green
        label.backgroundColor = UIColor.clear
        label.numberOfLines = 0
        label.layer.cornerRadius = 12
        label.clipsToBounds = true
        label.alpha = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(label)
        
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            label.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            label.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -24)
        ])
        
        UIView.animate(withDuration: 0.25) { label.alpha = 1 }
        UIView.animate(withDuration: 0.25, delay: 1.2, options: []) { label.alpha = 0 } completion: { _ in
            label.removeFromSuperview()
        }
    }
}

extension UIImage {
    func resized(to size: CGSize) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        draw(in: CGRect(origin: .zero, size: size))
        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return img ?? self
    }
}

extension UIView {
    func asImage() -> UIImage {
        let renderer = UIGraphicsImageRenderer(bounds: bounds)
        return renderer.image { context in
            layer.render(in: context.cgContext)
        }
    }
}

