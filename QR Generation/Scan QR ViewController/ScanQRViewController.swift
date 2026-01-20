//
//  ScanKHQRViewController.swift
//  QR Generation
//
//  Created by AEON_Sreang on 20/1/26.
//

import UIKit
import AVFoundation

final class ScanKHQRViewController: UIViewController {

    // MARK: - Camera
    private let session = AVCaptureSession()
    private let sessionQueue = DispatchQueue(label: "khqr.session.queue")
    private var previewLayer: AVCaptureVideoPreviewLayer?
    private let metadataOutput = AVCaptureMetadataOutput()

    private var didScanOnce = false

    // MARK: - UI
    private let overlayLayer = CAShapeLayer()
    private let frameView = UIView()

    private let titleLabel: UILabel = {
        let lb = UILabel()
        lb.text = "Scan KHQR"
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

    // Frame sizing
    private var scanFrame: CGRect {
        let size = min(view.bounds.width, view.bounds.height) * 0.68
        let x = (view.bounds.width - size) / 2
        let y = (view.bounds.height - size) / 2
        return CGRect(x: x, y: y, width: size, height: size)
    }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black

        setupUI()
        checkCameraPermissionAndSetup()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        previewLayer?.frame = view.bounds
        layoutScanFrame()
        updateOverlay()
        updateRectOfInterest()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        startSession()
        didScanOnce = false
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopSession()
        setTorch(false)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - UI Setup
    private func setupUI() {
        // Overlay layer
        overlayLayer.fillRule = .evenOdd
        overlayLayer.fillColor = UIColor.black.withAlphaComponent(0.55).cgColor
        view.layer.addSublayer(overlayLayer)

        // Frame
        frameView.layer.borderWidth = 2
        frameView.layer.borderColor = UIColor.white.cgColor
        frameView.layer.cornerRadius = 18
        frameView.backgroundColor = .clear
        view.addSubview(frameView)

        // Labels + buttons
        view.addSubview(titleLabel)
        view.addSubview(hintLabel)
        view.addSubview(torchButton)

        torchButton.addTarget(self, action: #selector(toggleTorch), for: .touchUpInside)

        // Torch availability
        torchButton.isHidden = !(AVCaptureDevice.default(for: .video)?.hasTorch ?? false)

        NSLayoutConstraint.activate([

            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 14),

            hintLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            hintLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 6),

            torchButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            torchButton.topAnchor.constraint(equalTo: view.bottomAnchor, constant: -110)
        ])
    }

    private func layoutScanFrame() {
        frameView.frame = scanFrame
    }

    private func updateOverlay() {
        let path = UIBezierPath(rect: view.bounds)
        let cutout = UIBezierPath(roundedRect: scanFrame, cornerRadius: 18)
        path.append(cutout)
        overlayLayer.path = path.cgPath
    }

    private func updateRectOfInterest() {
        guard let previewLayer else { return }
        let rect = previewLayer.metadataOutputRectConverted(fromLayerRect: scanFrame)
        metadataOutput.rectOfInterest = rect
    }

    // MARK: - Permission
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

    // MARK: - Camera Configure
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

                // ✅ Important: include common types (some KHQR stickers get encoded weirdly)
                self.metadataOutput.metadataObjectTypes = [.qr, .pdf417, .aztec, .dataMatrix]
            }

            self.session.commitConfiguration()

            DispatchQueue.main.async {
                let layer = AVCaptureVideoPreviewLayer(session: self.session)
                layer.videoGravity = .resizeAspectFill
                layer.frame = self.view.bounds
                self.view.layer.insertSublayer(layer, at: 0)
                self.previewLayer = layer

                // Force layout for rectOfInterest
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

    // MARK: - Actions
    @objc private func closeTapped() {
        dismiss(animated: true)
    }

    @objc private func toggleTorch() {
        let device = AVCaptureDevice.default(for: .video)
        guard let device, device.hasTorch else { return }
        setTorch(device.torchMode != .on)
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

        // Print raw output (what you asked for)
        print("✅ SCANNED RAW:\n\(raw)\n")

        // Try parse KHQR/EMV (best-effort)
        let parsed = EMVTLVParser.parse(raw)

        // Make a readable message
        var message = "RAW:\n\(raw)\n\n"
        if parsed.isEmpty {
            message += "Parsed: (no TLV detected)\n"
        } else {
            message += "PARSED (TLV):\n"
            for (k, v) in parsed.sorted(by: { $0.key < $1.key }) {
                message += "• \(k): \(v)\n"
            }

            // Handy shortcuts for common EMV fields (if present)
            if let merchantName = parsed["59"] { message += "\nMerchant: \(merchantName)" }
            if let amount = parsed["54"] { message += "\nAmount: \(amount)" }
            if let ccy = parsed["53"] { message += "\nCurrency: \(ccy)" }
        }

        // Pause session for the alert
        stopSession()

        let alert = UIAlertController(title: "KHQR Result", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Copy", style: .default) { _ in
            UIPasteboard.general.string = raw
            self.didScanOnce = false
            self.startSession()
        })
        alert.addAction(UIAlertAction(title: "Scan Again", style: .default) { _ in
            self.didScanOnce = false
            self.startSession()
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
    /// Parses an EMVCo-like string (tag-length-value) where:
    /// - Tag is 2 digits (sometimes 4 digits; we handle that lightly)
    /// - Length is 2 digits (decimal)
    /// - Value length is `Length` characters
    static func parse(_ input: String) -> [String: String] {
        let s = input.trimmingCharacters(in: .whitespacesAndNewlines)
        guard s.count >= 4 else { return [:] }

        // Many KHQR are like "000201...." (EMV string)
        // We'll parse sequential TLV.
        var i = s.startIndex
        var out: [String: String] = [:]

        func read(_ n: Int) -> String? {
            guard let end = s.index(i, offsetBy: n, limitedBy: s.endIndex) else { return nil }
            let sub = String(s[i..<end])
            i = end
            return sub
        }

        while i < s.endIndex {
            // Tag: usually 2 chars. Some are 4 (e.g., "00" then subtemplates etc),
            // but EMV tags in QR are typically 2-digit. We'll keep it 2-digit.
            guard let tag = read(2) else { break }
            guard let lenStr = read(2), let len = Int(lenStr) else { break }
            guard let value = read(len) else { break }

            // Store
            out[tag] = value

            // If value itself is a nested TLV template (like 26, 62),
            // we could parse it too, but keep it simple and useful.
        }

        return out
    }
}
