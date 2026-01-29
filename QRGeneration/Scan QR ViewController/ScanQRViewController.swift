//
//  ScanKHQRViewController.swift
//  QR Generation
//
//  Created by AEON_Sreang on 20/1/26.
//

import UIKit
import AVFoundation

class ScanKHQRViewController: UIViewController {

    private let session = AVCaptureSession()
    private let sessionQueue = DispatchQueue(label: "khqr.session.queue")
    private var previewLayer: AVCaptureVideoPreviewLayer?
    private let metadataOutput = AVCaptureMetadataOutput()

    private var didScanOnce = false

    private let titleLabel: UILabel = {
        let lb = UILabel()
        lb.text = "Scan QR"
        lb.textColor = .white
        lb.font = .systemFont(ofSize: 18, weight: .semibold)
        lb.translatesAutoresizingMaskIntoConstraints = false
        return lb
    }()

    private let hintLabel: UILabel = {
        let lb = UILabel()
        lb.text = "Align the KHQR inside the frame"
        lb.textColor = UIColor.white.withAlphaComponent(0.85)
        lb.font = .systemFont(ofSize: 14, weight: .regular)
        lb.translatesAutoresizingMaskIntoConstraints = false
        return lb
    }()

    private let torchButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle(" Flash", for: .normal)
        btn.setImage(UIImage(systemName: "flashlight.off.fill"), for: .normal)
        btn.tintColor = .white
        btn.backgroundColor = UIColor.black.withAlphaComponent(0.35)
        btn.layer.cornerRadius = 14
        btn.contentEdgeInsets = UIEdgeInsets(top: 10, left: 12, bottom: 10, right: 12)
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()

    // Move the scanning square a bit up by applying a vertical offset.
    // Increase/decrease verticalOffset to taste.
    private var scanFrame: CGRect {
        let size = min(view.bounds.width, view.bounds.height) * 0.68
        let x = (view.bounds.width - size) / 2

        let verticalOffset: CGFloat = 60 // positive moves up
        var y = (view.bounds.height - size) / 2 - verticalOffset

        // Keep it on-screen and away from the notch/status bar
        y = max(view.safeAreaInsets.top + 12, y)

        return CGRect(x: x, y: y, width: size, height: size)
    }
    
    private let overlayLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.fillRule = .evenOdd
        layer.fillColor = UIColor.black.withAlphaComponent(0.55).cgColor
        return layer
    }()
    
    private let frameView: UIView = {
        let view = UIView()
        view.layer.borderWidth = 2
        view.layer.borderColor = UIColor.clear.cgColor
        view.layer.cornerRadius = 18
        view.clipsToBounds = true
        view.backgroundColor = .clear
        return view
    }()
    
    private let cornerLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.fillColor = UIColor.clear.cgColor
        layer.strokeColor = UIColor.color("B31E8D").cgColor
        layer.lineWidth = 6
        layer.lineCap = .round
        return layer
    }()
    
    private let scanLine: UIView = {
        let view = UIView()
        view.backgroundColor = .color("#B31E8D")
        view.layer.shadowColor = UIColor.color("#B31E8D").cgColor
        view.layer.shadowOpacity = 0.9
        view.layer.shadowRadius = 8
        view.layer.shadowOffset = .zero
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let buttonStackView: UIStackView = {
        let stackview = UIStackView()
        stackview.axis = .horizontal
        stackview.spacing = 16
        stackview.alignment = .center
        stackview.distribution = .equalSpacing
        stackview.backgroundColor = .clear
        stackview.translatesAutoresizingMaskIntoConstraints = false
        return stackview
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        customNavigationBar()
        setupView()
        checkCameraPermissionAndSetup()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        previewLayer?.frame = view.bounds
        layoutScanFrame()
        layoutScanLine()
        updateOverlay()
        updateCornerBrackets(in: frameView.frame)
        updateRectOfInterest()
        startScanLineAnimation()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.title = "Scan QR Code"
        startSession()
        didScanOnce = false
        startScanLineAnimation()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopSession()
        setTorch(false)
        scanLine.layer.removeAnimation(forKey: "scanLineGroup")
        scanLine.layer.removeAnimation(forKey: "scanLineY")
        scanLine.layer.removeAnimation(forKey: "scanLineOpacity")
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc private func closeTapped() {
        dismiss(animated: true)
    }

    @objc private func toggleTorch() {
        let device = AVCaptureDevice.default(for: .video)
        guard let device, device.hasTorch else { return }
        setTorch(device.torchMode != .on)
    }

    private func setupView() {
        
        let selectQRButton = customButton(icon: "photo", title: "Select QR")
        let flashButton = customButton(icon: "flashlight.on.fill", title: "Open Flash")

        buttonStackView.addArrangedSubview(selectQRButton)
        buttonStackView.addArrangedSubview(flashButton)
        buttonStackView.isLayoutMarginsRelativeArrangement = true
        buttonStackView.layoutMargins = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        
        let frame = scanFrame
        let full = UIBezierPath(rect: view.bounds)
        let hole = UIBezierPath(roundedRect: frame, cornerRadius: 18)
        full.append(hole)
        overlayLayer.path = full.cgPath
        overlayLayer.fillRule = .evenOdd
        updateCornerBrackets(in: frame)
        
        // Keep layers behind subviews
        overlayLayer.zPosition = -2
        cornerLayer.zPosition = -1
        
        view.layer.insertSublayer(overlayLayer, at: 0)
        view.layer.insertSublayer(cornerLayer, above: overlayLayer)

        view.addSubview(frameView)
        frameView.addSubview(scanLine)

        view.addSubview(buttonStackView)

        NSLayoutConstraint.activate([
            buttonStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            buttonStackView.heightAnchor.constraint(equalToConstant: 56),
            buttonStackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
        
        // Ensure buttons are always above layers
        view.bringSubviewToFront(frameView)
        view.bringSubviewToFront(buttonStackView)
//        torchButton.addTarget(self, action: #selector(toggleTorch), for: .touchUpInside)
//        torchButton.isHidden = !(AVCaptureDevice.default(for: .video)?.hasTorch ?? false)
    }
    
    private func customNavigationBar() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .clear
        appearance.titleTextAttributes = [
            .foregroundColor: UIColor.white,
            .font: UIFont.systemFont(ofSize: 18, weight: .semibold)
        ]

        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.compactAppearance = appearance
    }

    private func layoutScanFrame() {
        frameView.frame = scanFrame
        frameView.layer.cornerRadius = 18
    }

    private func updateOverlay() {
        let path = UIBezierPath(rect: view.bounds)
        let cutout = UIBezierPath(roundedRect: scanFrame, cornerRadius: 18)
        path.append(cutout)
        overlayLayer.path = path.cgPath
    }
    
    private func layoutScanLine() {
        guard frameView.bounds.width > 0, frameView.bounds.height > 0 else { return }
        let inset: CGFloat = 10
        let h: CGFloat = 5
        scanLine.frame = CGRect(x: inset, y: inset, width: frameView.bounds.width - inset * 2, height: h)
        scanLine.layer.cornerRadius = h / 2
    }

    // MARK: - Sweep animation (down, fade out, jump to top, repeat)
    private func startScanLineAnimation() {
        guard frameView.bounds.height > 20 else { return }

        // Remove any existing grouped animation so we can restart cleanly
        scanLine.layer.removeAnimation(forKey: "scanLineGroup")

        let inset: CGFloat = 10
        let startY = scanLine.layer.position.y
        let endY = frameView.bounds.height - inset - scanLine.bounds.height / 2

        // Position animation: straight down, no autoreverse
        let move = CABasicAnimation(keyPath: "position.y")
        move.fromValue = startY
        move.toValue = endY
        move.duration = 1.2
        move.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        move.isRemovedOnCompletion = false

        // Opacity animation: 1 → 0 as it reaches bottom
        let fade = CAKeyframeAnimation(keyPath: "opacity")
        fade.values = [1.0, 0.0]
        fade.keyTimes = [0.0, 1.0]
        fade.duration = move.duration
        fade.timingFunctions = [CAMediaTimingFunction(name: .easeInEaseOut)]
        fade.isRemovedOnCompletion = false

        // Group them and repeat forever
        let group = CAAnimationGroup()
        group.animations = [move, fade]
        group.duration = move.duration
        group.repeatCount = .infinity
        group.isRemovedOnCompletion = false
        group.delegate = self
        group.setValue(startY, forKey: "startY")
        group.setValue(endY, forKey: "endY")

        scanLine.layer.add(group, forKey: "scanLineGroup")
    }

    private func updateRectOfInterest() {
        guard let previewLayer else { return }
        let rect = previewLayer.metadataOutputRectConverted(fromLayerRect: scanFrame)
        metadataOutput.rectOfInterest = rect
    }

    private func checkCameraPermissionAndSetup() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            configureCamera()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                DispatchQueue.main.async {
                    guard let self else { return }
                    granted ? self.configureCamera() : self.showPermissionAlert()
                }
            }
        default:
            showPermissionAlert()
        }
    }

    private func configureCamera() {
        sessionQueue.async { [weak self] in
            guard let self else { return }

            if self.session.isRunning { return }

            self.session.beginConfiguration()
            self.session.sessionPreset = .high

            // Input
            guard let device = AVCaptureDevice.default(for: .video),
                  let input = try? AVCaptureDeviceInput(device: device),
                  self.session.canAddInput(input)
            else {
                DispatchQueue.main.async {
                    self.showAlert(title: "No Camera", message: "Camera not available.")
                }
                self.session.commitConfiguration()
                return
            }
            self.session.addInput(input)

            // Output
            if self.session.canAddOutput(self.metadataOutput) {
                self.session.addOutput(self.metadataOutput)
                self.metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
                self.metadataOutput.metadataObjectTypes = [.qr, .pdf417, .aztec, .dataMatrix]
            }

            self.session.commitConfiguration()

            DispatchQueue.main.async {
                let layer = AVCaptureVideoPreviewLayer(session: self.session)
                layer.videoGravity = .resizeAspectFill
                layer.frame = self.view.bounds
                // Keep preview at the very back
                self.view.layer.insertSublayer(layer, at: 0)
                self.previewLayer = layer

                self.view.setNeedsLayout()
                self.view.layoutIfNeeded()
                self.updateRectOfInterest()
            }
        }
    }

    private func startSession() {
        sessionQueue.async { [weak self] in
            guard let self else { return }
            if !self.session.isRunning {
                self.session.startRunning()
            }
        }
    }

    private func stopSession() {
        sessionQueue.async { [weak self] in
            guard let self else { return }
            if self.session.isRunning {
                self.session.stopRunning()
            }
        }
    }

    private func setTorch(_ on: Bool) {
        guard let device = AVCaptureDevice.default(for: .video), device.hasTorch else { return }
        do {
            try device.lockForConfiguration()
            if on {
                try device.setTorchModeOn(level: AVCaptureDevice.maxAvailableTorchLevel)
                torchButton.setImage(UIImage(systemName: "flashlight.on.fill"), for: .normal)
                torchButton.setTitle(" Flash On", for: .normal)
            } else {
                device.torchMode = .off
                torchButton.setImage(UIImage(systemName: "flashlight.off.fill"), for: .normal)
                torchButton.setTitle(" Flash", for: .normal)
            }
            device.unlockForConfiguration()
        } catch {
            showAlert(title: "Torch Error", message: error.localizedDescription)
        }
    }

    // MARK: - Result Handling
    private func handleScanned(value raw: String) {
        guard !didScanOnce else { return }
        didScanOnce = true

        print("✅ SCANNED RAW:\n\(raw)\n")

        let parsed = EMVTLVParser.parse(raw)

        var message = "RAW:\n\(raw)\n\n"
        if parsed.isEmpty {
            message += "Parsed: (no TLV detected)\n"
        } else {
            message += "PARSED (TLV):\n"
            for (k, v) in parsed.sorted(by: { $0.key < $1.key }) {
                message += "• \(k): \(v)\n"
            }
            if let merchantName = parsed["59"] { message += "\nMerchant: \(merchantName)" }
            if let amount = parsed["54"] { message += "\nAmount: \(amount)" }
            if let ccy = parsed["53"] { message += "\nCurrency: \(ccy)" }
        }

        stopSession()

        let alert = UIAlertController(title: "KHQR Result", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Copy", style: .default) { _ in
            UIPasteboard.general.string = raw
            self.didScanOnce = false
            self.startSession()
            self.startScanLineAnimation()
        })
        alert.addAction(UIAlertAction(title: "Scan Again", style: .default) { _ in
            self.didScanOnce = false
            self.startSession()
            self.startScanLineAnimation()
        })
        present(alert, animated: true)
    }

    // MARK: - Alerts
    private func showPermissionAlert() {
        showAlert(
            title: "Camera Permission Needed",
            message: "Settings → Privacy → Camera → enable for this app."
        )
    }

    private func showAlert(title: String, message: String) {
        guard presentedViewController == nil else { return }
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - AVCaptureMetadataOutputObjectsDelegate
extension ScanKHQRViewController: AVCaptureMetadataOutputObjectsDelegate {
    func metadataOutput(_ output: AVCaptureMetadataOutput,
                        didOutput metadataObjects: [AVMetadataObject],
                        from connection: AVCaptureConnection) {

        guard let obj = metadataObjects.first as? AVMetadataMachineReadableCodeObject else { return }
        guard let value = obj.stringValue, !value.isEmpty else { return }

        handleScanned(value: value)
    }
}

// MARK: - Simple EMVCo TLV Parser (best-effort)
private enum EMVTLVParser {
    static func parse(_ input: String) -> [String: String] {
        let s = input.trimmingCharacters(in: .whitespacesAndNewlines)
        guard s.count >= 4 else { return [:] }
        var i = s.startIndex
        var out: [String: String] = [:]
        func read(_ n: Int) -> String? {
            guard let end = s.index(i, offsetBy: n, limitedBy: s.endIndex) else { return nil }
            let sub = String(s[i..<end])
            i = end
            return sub
        }
        while i < s.endIndex {
            guard let tag = read(2) else { break }
            guard let lenStr = read(2), let len = Int(lenStr) else { break }
            guard let value = read(len) else { break }
            out[tag] = value
        }
        return out
    }
}

extension ScanKHQRViewController {
    private func updateCornerBrackets(in scanRectangle: CGRect) {

        let cornerArmLength: CGFloat = 44
        let cornerRadius: CGFloat = 18

        let minX = scanRectangle.minX
        let maxX = scanRectangle.maxX
        let minY = scanRectangle.minY
        let maxY = scanRectangle.maxY

        let cornerPath = UIBezierPath()

        // TOP-LEFT
        cornerPath.move( to: CGPoint(x: minX + cornerRadius + cornerArmLength, y: minY))
        cornerPath.addLine(to: CGPoint(x: minX + cornerRadius,y: minY))
        cornerPath.addArc(withCenter: CGPoint(x: minX + cornerRadius,y: minY + cornerRadius),
            radius: cornerRadius,
            startAngle: CGFloat(3 * Double.pi / 2),
            endAngle: CGFloat(Double.pi),
            clockwise: false
        )
        cornerPath.addLine(to: CGPoint(x: minX,y: minY + cornerRadius + cornerArmLength))

        // TOP-RIGHT
        cornerPath.move(to: CGPoint(x: maxX - cornerRadius - cornerArmLength,y: minY))
        cornerPath.addLine(to: CGPoint(x: maxX - cornerRadius,y: minY))
        cornerPath.addArc(withCenter: CGPoint(x: maxX - cornerRadius,y: minY + cornerRadius),
            radius: cornerRadius,
            startAngle: CGFloat(3 * Double.pi / 2),
            endAngle: 0,
            clockwise: true
        )
        cornerPath.addLine(to: CGPoint(x: maxX,y: minY + cornerRadius + cornerArmLength))

        // BOTTOM-LEFT
        cornerPath.move(to: CGPoint(x: minX + cornerRadius + cornerArmLength,y: maxY))
        cornerPath.addLine(to: CGPoint(x: minX + cornerRadius,y: maxY))
        cornerPath.addArc(withCenter: CGPoint(x: minX + cornerRadius,y: maxY - cornerRadius),
            radius: cornerRadius,
            startAngle: CGFloat(Double.pi / 2),
            endAngle: CGFloat(Double.pi),
            clockwise: true
        )
        cornerPath.addLine(to: CGPoint(x: minX,y: maxY - cornerRadius - cornerArmLength))

        // BOTTOM-RIGHT
        cornerPath.move(to: CGPoint(x: maxX - cornerRadius - cornerArmLength,y: maxY))
        cornerPath.addLine(to: CGPoint(x: maxX - cornerRadius,y: maxY))
        cornerPath.addArc(withCenter: CGPoint(x: maxX - cornerRadius,y: maxY - cornerRadius),
            radius: cornerRadius,
            startAngle: CGFloat(Double.pi / 2),
            endAngle: 0,
            clockwise: false
        )
        cornerPath.addLine(to: CGPoint(x: maxX,y: maxY - cornerRadius - cornerArmLength))

        cornerLayer.path = cornerPath.cgPath
    }
    
    func customButton(icon: String, title: String) -> UIButton {
        if #available(iOS 15.0, *) {
            var config = UIButton.Configuration.filled()
            config.image = UIImage(systemName: icon)
            config.title = title
            config.imagePadding = 10
            config.cornerStyle = .capsule

            config.baseBackgroundColor = .white
            config.baseForegroundColor = .black

            config.contentInsets = NSDirectionalEdgeInsets(
                top: 14,
                leading: 20,
                bottom: 14,
                trailing: 20
            )

            let button = UIButton(configuration: config)
            button.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
            return button
        }
        return UIButton()
    }

}

extension ScanKHQRViewController: CAAnimationDelegate {
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        // Reset the model layer to the start of the sweep for the next cycle
        // so the jump back to top is not visible between repeats.
        guard anim == scanLine.layer.animation(forKey: "scanLineGroup") else { return }

        let inset: CGFloat = 10
        let startY = inset + scanLine.bounds.height / 2
        scanLine.layer.position.y = startY
        scanLine.layer.opacity = 1.0
    }
}
