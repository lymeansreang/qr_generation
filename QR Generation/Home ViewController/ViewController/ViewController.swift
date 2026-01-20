//
//  ViewController.swift
//  QR Generation
//
//  Created by AEON_Sreang on 20/1/26.
//

import UIKit

final class ViewController: UIViewController {

    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.delaysContentTouches = false
        scrollView.canCancelContentTouches = true
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()

    private let containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    private var items: [Model] = [
        .init(icon: "qrcode.viewfinder", title: "Scan Any QR", subtitle: "Instant scan and pay", promo: "FASTEST", action: .scanQR),
        .init(icon: "KHQR available here - logo with bg", title: "KHQR Payment", subtitle: "Local Bakong standard", promo: nil, action: .khqr),
        .init(icon: "VISA", title: "VISA QR", subtitle: "International payments", promo: nil, action: .visaQR)
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupView()
        reloadStack()
    }

    // If you want to remove the "floating bar" (nav bar), uncomment this:
    // override func viewWillAppear(_ animated: Bool) {
    //     super.viewWillAppear(animated)
    //     navigationController?.setNavigationBarHidden(true, animated: false)
    // }

    private func setupView() {
        view.addSubview(scrollView)
        scrollView.addSubview(containerView)
        containerView.addSubview(stackView)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            containerView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            containerView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            containerView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor),

            stackView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 16),
            stackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 18),
            stackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -18),
            stackView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -16)
        ])
    }

    private func reloadStack() {
        stackView.arrangedSubviews.forEach {
            stackView.removeArrangedSubview($0)
            $0.removeFromSuperview()
        }

        for (index, model) in items.enumerated() {
            let card = createCard(model: model, index: index)
            stackView.addArrangedSubview(card)
        }
    }

    @objc private func cardTapped(_ sender: UIControl) {
        let model = items[sender.tag]
        print("🔥 Tapped:", model.title)

        switch model.action {
        case .scanQR:
            let scanVC = ScanKHQRViewController()
            if let nav = navigationController {
                nav.pushViewController(scanVC, animated: true)
            } else {
                let nav = UINavigationController(rootViewController: scanVC)
                nav.setNavigationBarHidden(true, animated: false)
                nav.modalPresentationStyle = .fullScreen
                present(nav, animated: true)
            }

        case .khqr:
            let khqrVC = KHQRViewController()
            if let nav = navigationController {
                nav.pushViewController(khqrVC, animated: true)
            } else {
                let nav = UINavigationController(rootViewController: khqrVC)
                nav.setNavigationBarHidden(true, animated: false)
                nav.modalPresentationStyle = .fullScreen
                present(nav, animated: true)
            }
            
        case .visaQR:
            let visaVC = VISAViewController()
            if let nav = navigationController {
                nav.pushViewController(visaVC, animated: true)
            } else {
                let nav = UINavigationController(rootViewController: visaVC)
                nav.setNavigationBarHidden(true, animated: false)
                nav.modalPresentationStyle = .fullScreen
                present(nav, animated: true)
            }
            
        }
    }
}

extension ViewController {

    /// Card layout is done with stack views.
    /// Tap handling is done by UIControl wrapper (reliable inside scroll views).
    private func createCard(model: Model, index: Int) -> UIControl {

        // Tap wrapper
        let card = UIControl()
        card.tag = index
        card.backgroundColor = .white
        card.layer.cornerRadius = 24
        card.layer.borderWidth = 1
        card.layer.borderColor = UIColor.systemGray5.cgColor
        card.translatesAutoresizingMaskIntoConstraints = false
        card.addTarget(self, action: #selector(cardTapped(_:)), for: .touchUpInside)
        card.addTarget(self, action: #selector(cardTapped(_:)), for: .primaryActionTriggered)

        NSLayoutConstraint.activate([
            card.heightAnchor.constraint(equalToConstant: 96)
        ])

        // Root horizontal stack (icon | text | spacer | chevron)
        let rootStack = UIStackView()
        rootStack.axis = .horizontal
        rootStack.alignment = .center
        rootStack.spacing = 16
        rootStack.translatesAutoresizingMaskIntoConstraints = false
        rootStack.isUserInteractionEnabled = false // ✅ critical: let UIControl receive touches

        card.addSubview(rootStack)
        NSLayoutConstraint.activate([
            rootStack.topAnchor.constraint(equalTo: card.topAnchor),
            rootStack.bottomAnchor.constraint(equalTo: card.bottomAnchor),
            rootStack.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16),
            rootStack.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -16)
        ])

        // Icon container
        let iconContainer = UIView()
        iconContainer.backgroundColor = .systemGray6
        iconContainer.layer.cornerRadius = 18
        iconContainer.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            iconContainer.widthAnchor.constraint(equalToConstant: 56),
            iconContainer.heightAnchor.constraint(equalToConstant: 56)
        ])

        let iconImageView = UIImageView()
        iconImageView.image = UIImage(systemName: model.icon) ?? UIImage(named: model.icon)
        iconImageView.tintColor = .label
        iconImageView.contentMode = .scaleAspectFit
        iconImageView.translatesAutoresizingMaskIntoConstraints = false

        iconContainer.addSubview(iconImageView)
        NSLayoutConstraint.activate([
            iconImageView.centerXAnchor.constraint(equalTo: iconContainer.centerXAnchor),
            iconImageView.centerYAnchor.constraint(equalTo: iconContainer.centerYAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 28),
            iconImageView.heightAnchor.constraint(equalToConstant: 28)
        ])

        // Title + Promo
        let titleLabel = UILabel()
        titleLabel.text = model.title
        titleLabel.font = .systemFont(ofSize: 20, weight: .bold)
        titleLabel.textColor = .label

        let promoLabel = PaddingLabel()
        promoLabel.contentInsets = UIEdgeInsets(top: 4, left: 10, bottom: 4, right: 10)
        promoLabel.text = model.promo ?? ""
        promoLabel.font = .systemFont(ofSize: 12, weight: .bold)
        promoLabel.textColor = .white
        promoLabel.backgroundColor = .systemPink
        promoLabel.textAlignment = .center
        promoLabel.layer.cornerRadius = 10
        promoLabel.layer.masksToBounds = true

        let promoText = (model.promo ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        promoLabel.isHidden = promoText.isEmpty

        let titleRow = UIStackView(arrangedSubviews: [titleLabel, promoLabel])
        titleRow.axis = .horizontal
        titleRow.spacing = 8
        titleRow.alignment = .center

        // Subtitle
        let subtitleLabel = UILabel()
        subtitleLabel.text = model.subtitle
        subtitleLabel.font = .systemFont(ofSize: 15, weight: .semibold)
        subtitleLabel.textColor = .secondaryLabel
        subtitleLabel.numberOfLines = 1

        // Text vertical stack
        let textStack = UIStackView(arrangedSubviews: [titleRow, subtitleLabel])
        textStack.axis = .vertical
        textStack.spacing = 4
        textStack.alignment = .leading
        textStack.isUserInteractionEnabled = false

        // Chevron (with gray bubble like your old design)
        let chevronContainer = UIView()
        chevronContainer.backgroundColor = .systemGray6
        chevronContainer.layer.cornerRadius = 18
        chevronContainer.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            chevronContainer.widthAnchor.constraint(equalToConstant: 36),
            chevronContainer.heightAnchor.constraint(equalToConstant: 36)
        ])

        let chevronImage = UIImageView(image: UIImage(systemName: "chevron.right"))
        chevronImage.tintColor = .secondaryLabel
        chevronImage.translatesAutoresizingMaskIntoConstraints = false

        chevronContainer.addSubview(chevronImage)
        NSLayoutConstraint.activate([
            chevronImage.centerXAnchor.constraint(equalTo: chevronContainer.centerXAnchor),
            chevronImage.centerYAnchor.constraint(equalTo: chevronContainer.centerYAnchor)
        ])

        // Spacer (pushes chevron to the right)
        let spacer = UIView()
        spacer.translatesAutoresizingMaskIntoConstraints = false

        // Assemble
        rootStack.addArrangedSubview(iconContainer)
        rootStack.addArrangedSubview(textStack)
        rootStack.addArrangedSubview(spacer)
        rootStack.addArrangedSubview(chevronContainer)

        // Give the text stack priority so it expands
        textStack.setContentHuggingPriority(.defaultLow, for: .horizontal)
        spacer.setContentHuggingPriority(.defaultLow, for: .horizontal)
        chevronContainer.setContentHuggingPriority(.required, for: .horizontal)
        iconContainer.setContentHuggingPriority(.required, for: .horizontal)

        return card
    }
}

final class PaddingLabel: UILabel {

    var contentInsets = UIEdgeInsets(top: 4, left: 8, bottom: 4, right: 8)

    override func drawText(in rect: CGRect) {
        super.drawText(in: rect.inset(by: contentInsets))
    }

    override var intrinsicContentSize: CGSize {
        let size = super.intrinsicContentSize
        return CGSize(
            width: size.width + contentInsets.left + contentInsets.right,
            height: size.height + contentInsets.top + contentInsets.bottom
        )
    }
}
