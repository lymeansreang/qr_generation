//
//  ListMerchantViewController.swift
//  QR 
//
//  Created by AEON_Sreang on 22/1/26.
//

import UIKit

class ListMerchantViewController: UIViewController {
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.backgroundColor = .white
        tableView.register(
            MerchantListingTableViewCell.self,
            forCellReuseIdentifier: MerchantListingTableViewCell.reuseID
        )
        tableView.separatorStyle = .none
        tableView.backgroundColor = .clear
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()

    // Use the type returned by loadDummyMerchants()
    private var merchants: [MerchantMerchantInfo] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        merchants = loadDummyMerchants()
        setupView()
        tableView.reloadData()
    }
    
    private func setupView() {
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
}

extension ListMerchantViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return merchants.count
    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: MerchantListingTableViewCell.reuseID,
            for: indexPath
        ) as? MerchantListingTableViewCell else {
            return UITableViewCell()
        }

        let merchant = merchants[indexPath.row]

        let logo = merchant.merchantLogo ?? ""
        let name = merchant.merchantName ?? "Unknown Merchant"
        let id = merchant.merchantId ?? "-"

        cell.configure(
            merchantLogo: logo,
            merchantName: name,
            merchantID: id
        )

        cell.onTap = { [weak self] in
            guard let self else { return }
            let vc = VISAViewController()
            vc.userName = merchant.merchantName ?? name
            vc.merchantId = merchant.merchantId ?? id
            vc.merchantCity = merchant.merchantCity ?? "Phnom Penh"
            vc.merchantCurrencyNumeric = merchant.merchantCurrencyNumeric ?? "116"
            self.navigationController?.pushViewController(vc, animated: true)
        }

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
