//
//  QRGenerator.swift
//  QR
//
//  Created by AEON_Sreang on 21/1/26.
//

//import Foundation
//import CoreImage
//import UIKit
//import QRGenerator
//
//enum QRCodeGenerator {
//    static func makeQR(from text: String, scale: CGFloat = 10) -> UIImage? {
//        let data = Data(text.utf8)
//        guard let filter = CIFilter(name: "CIQRCodeGenerator") else { return nil }
//        filter.setValue(data, forKey: "inputMessage")
//        filter.setValue("M", forKey: "inputCorrectionLevel")
//
//        guard let output = filter.outputImage else { return nil }
//        let transformed = output.transformed(by: CGAffineTransform(scaleX: scale, y: scale))
//        return UIImage(ciImage: transformed)
//    }
//}
//
//// MARK: - Minimal EMV MPQR builder (starter)
//struct EMVQR {
//    static func tlv(_ tag: String, _ value: String) -> String {
//        let len = String(format: "%02d", value.count)
//        return "\(tag)\(len)\(value)"
//    }
//
//    static func buildMerchantPresented(
//        merchantName: String,
//        merchantCity: String,
//        countryCode: String = "KH",
//        currencyNumeric: String = "116",
//        amount: String? = nil,
//        isDynamic: Bool = true
//    ) -> String {
//
//        var stringPayload = ""
//        stringPayload += tlv("00", "01")                 // Payload Format Indicator
//        stringPayload += tlv("01", isDynamic ? "12" : "11") // POI Method
//        stringPayload += tlv("52", "0000")               // MCC
//        stringPayload += tlv("53", currencyNumeric)      // Currency
//
//        if let amount, !amount.isEmpty {
//            stringPayload += tlv("54", amount)           // Amount
//        }
//
//        stringPayload += tlv("58", countryCode)          // Country
//        stringPayload += tlv("59", merchantName)         // Merchant Name
//        stringPayload += tlv("60", merchantCity)         // Merchant City
//
//        // CRC placeholder then compute
//        stringPayload += "6304"
//        let crc = crc16ccitt(stringPayload)
//        stringPayload += String(format: "%04X", crc)
//
//        return stringPayload
//    }
//
//    // CRC16-CCITT (FALSE) used by EMVCo MPQR
//    static func crc16ccitt(_ input: String) -> UInt16 {
//        let bytes = [UInt8](input.utf8)
//        var crc: UInt16 = 0xFFFF
//
//        for b in bytes {
//            crc ^= UInt16(b) << 8
//            for _ in 0..<8 {
//                if (crc & 0x8000) != 0 {
//                    crc = (crc << 1) ^ 0x1021
//                } else {
//                    crc <<= 1
//                }
//            }
//        }
//        return crc
//    }
//}

import Foundation
import CoreImage
import UIKit

// MARK: - QR Image Rendering (keep this)
enum QRCodeGenerator {

    /// Generates a crisp QR UIImage from a payload string.
    /// Uses CIContext -> CGImage to avoid blurry / scaled CIImage rendering issues.
    static func makeQR(from text: String, scale: CGFloat = 10) -> UIImage? {
        let data = Data(text.utf8)
        
        guard let filter = CIFilter(name: "CIQRCodeGenerator") else { return nil }
        filter.setValue(data, forKey: "inputMessage")
        filter.setValue("M", forKey: "inputCorrectionLevel")
//        QR
        guard let output = filter.outputImage else { return nil }

        let transformed = output.transformed(by: CGAffineTransform(scaleX: scale, y: scale))

        let context = CIContext()
        guard let cgImage = context.createCGImage(transformed, from: transformed.extent) else { return nil }

        return UIImage(cgImage: cgImage)
    }
}

// MARK: - Merchant QR Payload (SDK-first)
// Your app should only depend on this interface.
// Internally, this will call Visa SDK once you wire it.
struct MerchantQRPayload {

    struct Input {
        let merchantName: String
        let merchantCity: String
        let countryCode: String
        let currencyNumeric: String
        let amount: String?
        let isDynamic: Bool

        init(
            merchantName: String,
            merchantCity: String,
            countryCode: String = "KH",
            currencyNumeric: String = "116",
            amount: String? = nil,
            isDynamic: Bool = true
        ) {
            self.merchantName = merchantName
            self.merchantCity = merchantCity
            self.countryCode = countryCode
            self.currencyNumeric = currencyNumeric
            self.amount = amount
            self.isDynamic = isDynamic
        }
    }

    /// Plug your Visa SDK builder here once you know the SDK API.
    /// This avoids polluting your app code with SDK details everywhere.
    static var visaSDKBuilder: ((Input) -> String)?

    /// Build payload string to encode inside the QR.
    static func build(_ input: Input) -> String {
        if let builder = visaSDKBuilder {
            return builder(input)
        }

        // If you want to force “SDK only”, replace this with:
        // fatalError("Visa SDK payload builder is not wired yet.")
        return EMVQRFallback.buildMerchantPresented(
            merchantName: input.merchantName,
            merchantCity: input.merchantCity,
            countryCode: input.countryCode,
            currencyNumeric: input.currencyNumeric,
            amount: input.amount,
            isDynamic: input.isDynamic
        )
    }
}

// MARK: - Fallback (Optional) - remove later when SDK works
// Keep this only while you're wiring the Visa SDK API.
// Once the SDK is generating payload, delete this entire struct.
private struct EMVQRFallback {

    private static func tlv(_ tag: String, _ value: String) -> String {
        let len = String(format: "%02d", value.count)
        return "\(tag)\(len)\(value)"
    }

    static func buildMerchantPresented(
        merchantName: String,
        merchantCity: String,
        countryCode: String,
        currencyNumeric: String,
        amount: String?,
        isDynamic: Bool
    ) -> String {

        var payload = ""
        payload += tlv("00", "01")                      // Payload Format Indicator
        payload += tlv("01", isDynamic ? "12" : "11")   // POI Method
        payload += tlv("52", "0000")                    // MCC (placeholder)
        payload += tlv("53", currencyNumeric)           // Currency

        if let amount, !amount.isEmpty {
            payload += tlv("54", amount)                // Amount
        }

        payload += tlv("58", countryCode)               // Country
        payload += tlv("59", merchantName)              // Merchant Name
        payload += tlv("60", merchantCity)              // Merchant City

        // CRC placeholder then compute
        payload += "6304"
        let crc = crc16ccitt(payload)
        payload += String(format: "%04X", crc)

        return payload
    }

    // CRC16-CCITT (FALSE)
    private static func crc16ccitt(_ input: String) -> UInt16 {
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
