//
//  MerchantModel.swift
//  QR 
//
//  Created by AEON_Sreang on 22/1/26.
//

import Foundation

struct MerchantModel: Codable {
    let merchantInfo: [MerchantInfo]?

    enum CodingKeys: String, CodingKey {
        case merchantInfo = "merchant_info"
    }
}

struct MerchantInfo: Codable {
    let id: Int?
    let payload_format_indicator: String?
    let merchantId: String?
    let merchantName: String?
    let merchantCity: String?
    let merchant_category_code: String?
    let merchantLogo: String?
    let merchantCountryCode: String?
    let merchantCurrencyNumeric: String?
    let merchantIsDynamic: Bool?
    let transaction_currency_code: String?
    let transaction_amount: String?
    let country_code: String?
    let crc: String?

    enum CodingKeys: String, CodingKey {
        case id
        case payload_format_indicator = "payload_format_indicator"
        case merchantId = "merchant_id"
        case merchantName = "merchant_name"
        case merchantCity = "merchant_city"
        case merchant_category_code = "merchant_category_code"
        case merchantLogo = "merchant_logo"
        case merchantCountryCode = "merchant_country_code"
        case merchantCurrencyNumeric = "merchant_currency_numeric"
        case merchantIsDynamic = "merchant_isDynamic"
        case transaction_currency_code = "transaction_currency_code"
        case transaction_amount = "transaction_amount"
        case country_code = "country_code"
        case crc
    }
}

func loadDummyMerchants() -> [MerchantInfo] {
    let json = """
    {
      "merchant_info": [
        {
          "id": 1,
          "payload_format_indicator": "01",
          "merchant_id": "MCH-0001",
          "merchant_name": "Brown Coffee",
          "merchant_city": "Phnom Penh",
          "merchant_category_code": "5812",
          "merchant_logo": "brown_logo",
          "merchant_country_code": "KH",
          "merchant_currency_numeric": "840",
          "merchant_isDynamic": true,
          "transaction_currency_code": "840",
          "transaction_amount": "5.50",
          "country_code": "KH",
          "crc": "6304A13F"
        },
        {
          "id": 2,
          "payload_format_indicator": "01",
          "merchant_id": "MCH-0002",
          "merchant_name": "Starbucks",
          "merchant_city": "Phnom Penh",
          "merchant_category_code": "5814",
          "merchant_logo": "starbuck_logo",
          "merchant_country_code": "KH",
          "merchant_currency_numeric": "840",
          "merchant_isDynamic": false,
          "transaction_currency_code": "840",
          "transaction_amount": "0.00",
          "country_code": "KH",
          "crc": "6304B27C"
        },
        {
          "id": 3,
          "payload_format_indicator": "01",
          "merchant_id": "MCH-0003",
          "merchant_name": "KFC",
          "merchant_city": "Siem Reap",
          "merchant_category_code": "5814",
          "merchant_logo": "kfc_logo",
          "merchant_country_code": "KH",
          "merchant_currency_numeric": "116",
          "merchant_isDynamic": true,
          "transaction_currency_code": "116",
          "transaction_amount": "25000",
          "country_code": "KH",
          "crc": "6304C9D2"
        }
      ]
    }
    """

    do {
        let data = Data(json.utf8)
        let decoder = JSONDecoder()
        let result = try decoder.decode(MerchantModel.self, from: data)
        return result.merchantInfo ?? []
    } catch {
        print("❌ Decode error:", error)
        return []
    }
}
