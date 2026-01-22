//
//  MerchantModel.swift
//  QR 
//
//  Created by AEON_Sreang on 22/1/26.
//

import Foundation

struct MerchantModel: Codable {
    let merchantInfo: [MerchantMerchantInfo]?

    enum CodingKeys: String, CodingKey {
        case merchantInfo = "merchant_info"
    }

    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.merchantInfo = try container.decodeIfPresent([MerchantMerchantInfo].self, forKey: .merchantInfo)
    }
}

struct MerchantMerchantInfo: Codable {
    let id: Int?
    let merchantLogo: String?
    let merchantName: String?
    let merchantId: String?
    let merchantCity: String?
    let merchantCountryCode: String?
    let merchantCurrencyNumeric: String?
    let merchantIsDynamic: String?

    enum CodingKeys: String, CodingKey {
        case id
        case merchantLogo = "merchant_logo"
        case merchantName = "merchant_name"
        case merchantId = "merchant_id"
        case merchantCity = "merchant_city"
        case merchantCountryCode = "merchant_country_code"
        case merchantCurrencyNumeric = "merchant_currency_numeric"
        case merchantIsDynamic = "merchant_isDynamic"
    }

    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decodeIfPresent(Int.self, forKey: .id)
        self.merchantLogo = try container.decodeIfPresent(String.self, forKey: .merchantLogo)
        self.merchantName = try container.decodeIfPresent(String.self, forKey: .merchantName)
        self.merchantId = try container.decodeIfPresent(String.self, forKey: .merchantId)
        self.merchantCity = try container.decodeIfPresent(String.self, forKey: .merchantCity)
        self.merchantCountryCode = try container.decodeIfPresent(String.self, forKey: .merchantCountryCode)
        self.merchantCurrencyNumeric = try container.decodeIfPresent(String.self, forKey: .merchantCurrencyNumeric)
        self.merchantIsDynamic = try container.decodeIfPresent(String.self, forKey: .merchantIsDynamic)
    }
}


func loadDummyMerchants() -> [MerchantMerchantInfo] {
    let json = """
    {
      "merchant_info": [
        {
          "id": 1,
          "merchant_logo": "brown_logo",
          "merchant_name": "Brown",
          "merchant_id": "MCH-0001",
          "merchant_city": "Phnom Penh",
          "merchant_country_code": "KH",
          "merchant_currency_numeric": "840",
          "merchant_isDynamic": "true"
        },
        {
          "id": 2,
          "merchant_logo": "starbuck_logo",
          "merchant_name": "Starbuck",
          "merchant_id": "MCH-0002",
          "merchant_city": "Phnom Penh",
          "merchant_country_code": "KH",
          "merchant_currency_numeric": "840",
          "merchant_isDynamic": "true"
        },
        {
          "id": 3,
          "merchant_logo": "kfc_logo",
          "merchant_name": "KFC",
          "merchant_id": "MCH-0003",
          "merchant_city": "Phnom Penh",
          "merchant_country_code": "KH",
          "merchant_currency_numeric": "116",
          "merchant_isDynamic": "true"
        }
      ]
    }
    """

    let data = Data(json.utf8)
    let decoder = JSONDecoder()

    do {
        let result = try decoder.decode(MerchantModel.self, from: data)
        return result.merchantInfo ?? []
    } catch {
        print("❌ Decode error:", error)
        return []
    }
}
