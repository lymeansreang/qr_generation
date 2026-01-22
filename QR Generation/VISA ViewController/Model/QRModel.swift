//
//  QRModel.swift
//  QR 
//
//  Created by AEON_Sreang on 21/1/26.
//

import Foundation
import CoreImage
import UIKit

enum QRCodeGenerator {
    static func makeQR(from text: String, scale: CGFloat = 10) -> UIImage? {
        let data = Data(text.utf8)
        guard let filter = CIFilter(name: "CIQRCodeGenerator") else { return nil }
        filter.setValue(data, forKey: "inputMessage")
        filter.setValue("M", forKey: "inputCorrectionLevel")

        guard let output = filter.outputImage else { return nil }
        let transformed = output.transformed(by: CGAffineTransform(scaleX: scale, y: scale))
        return UIImage(ciImage: transformed)
    }
}

// MARK: - Minimal EMV MPQR builder (starter)
struct EMVQR {
    static func tlv(_ tag: String, _ value: String) -> String {
        let len = String(format: "%02d", value.count)
        return "\(tag)\(len)\(value)"
    }

    static func buildMerchantPresented(
        merchantName: String,
        merchantCity: String,
        countryCode: String = "KH",
        currencyNumeric: String = "116",
        amount: String? = nil,
        isDynamic: Bool = true
    ) -> String {

        var stringPayload = ""
        stringPayload += tlv("00", "01")                 // Payload Format Indicator
        stringPayload += tlv("01", isDynamic ? "12" : "11") // POI Method
        stringPayload += tlv("52", "0000")               // MCC
        stringPayload += tlv("53", currencyNumeric)      // Currency

        if let amount, !amount.isEmpty {
            stringPayload += tlv("54", amount)           // Amount
        }

        stringPayload += tlv("58", countryCode)          // Country
        stringPayload += tlv("59", merchantName)         // Merchant Name
        stringPayload += tlv("60", merchantCity)         // Merchant City

        // CRC placeholder then compute
        stringPayload += "6304"
        let crc = crc16ccitt(stringPayload)
        stringPayload += String(format: "%04X", crc)

        return stringPayload
    }

    // CRC16-CCITT (FALSE) used by EMVCo MPQR
    static func crc16ccitt(_ input: String) -> UInt16 {
        let bytes = [UInt8](input.utf8)
        var crc: UInt16 = 0xFFFF

        for b in bytes {
            crc ^= UInt16(b) << 8
            for _ in 0..<8 {
                if (crc & 0x8000) != 0 {
                    crc = (crc << 1) ^ 0x1021
                } else {
                    crc <<= 1
                }
            }
        }
        return crc
    }
}
