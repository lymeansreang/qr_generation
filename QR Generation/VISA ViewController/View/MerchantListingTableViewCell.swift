//
//  MerchantListingTableViewCell.swift
//  QR 
//
//  Created by AEON_Sreang on 22/1/26.
//

import UIKit

final class MerchantListingTableViewCell: UITableViewCell {

    static let reuseID = "MerchantListingTableViewCell"
    var onTap: (() -> Void)?

    private let containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .white
        view.layer.cornerRadius = 16
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.systemGray4.cgColor
        return view
    }()

    private let tapButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.backgroundColor = .clear
        return btn
    }()

    private let logoImageView: UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    private let nameLabel: UILabel = {
        let lb = UILabel()
        lb.translatesAutoresizingMaskIntoConstraints = false
        lb.font = .systemFont(ofSize: 16, weight: .medium)
        lb.textColor = .black
        lb.numberOfLines = 1
        lb.setContentHuggingPriority(.defaultLow, for: .horizontal)
        return lb
    }()

    private let idLabel: UILabel = {
        let lb = UILabel()
        lb.translatesAutoresizingMaskIntoConstraints = false
        lb.font = .systemFont(ofSize: 14, weight: .regular)
        lb.textColor = .gray
        lb.textAlignment = .right
        lb.numberOfLines = 1
        lb.setContentHuggingPriority(.required, for: .horizontal)
        return lb
    }()

    private let spacer = UIView()

    private lazy var stackView: UIStackView = {
        let sv = UIStackView(arrangedSubviews: [logoImageView, nameLabel, spacer, idLabel])
        sv.axis = .horizontal
        sv.alignment = .center
        sv.spacing = 12
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.backgroundColor = .white
        setupView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        logoImageView.image = nil
        nameLabel.text = nil
        idLabel.text = nil
        onTap = nil
    }

    private func setupView() {
        selectionStyle = .none
        contentView.backgroundColor = .white
        backgroundColor = .clear

        contentView.addSubview(containerView)
        containerView.addSubview(stackView)
        containerView.addSubview(tapButton)

        tapButton.addTarget(self, action: #selector(didTap), for: .touchUpInside)

        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),

            stackView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 12),
            stackView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -12),
            stackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),

            logoImageView.widthAnchor.constraint(equalToConstant: 40),
            logoImageView.heightAnchor.constraint(equalToConstant: 40),

            tapButton.topAnchor.constraint(equalTo: containerView.topAnchor),
            tapButton.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            tapButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            tapButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
        ])
    }

    func configure(merchantLogo: String, merchantName: String, merchantID: String) {
        logoImageView.image = UIImage(named: merchantLogo)
        nameLabel.text = merchantName
        idLabel.text = merchantID
    }

    @objc private func didTap() {
        onTap?()
    }
}
