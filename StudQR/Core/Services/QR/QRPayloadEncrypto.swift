//
//  QRPayloadEncrypto.swift
//  Attentify
//
//  Created by Andrew Belik on 9/13/25.
//

import Foundation
import CryptoKit

// MARK: - AES-GCM шифрование payload
func encryptPayload(sessionKey: String, payload: [String: Any]) throws -> String {
    // сериализуем payload
    let data = try JSONSerialization.data(withJSONObject: payload)

    // подгоняем ключ до 32 байт (AES-256)
    var keyData = Data(sessionKey.utf8)
    if keyData.count > 32 {
        keyData = keyData.prefix(32)
    } else if keyData.count < 32 {
        keyData.append(contentsOf: repeatElement(0, count: 32 - keyData.count))
    }

    let symmetricKey = SymmetricKey(data: keyData)

    // генерируем IV (12 байт)
    let nonce = AES.GCM.Nonce()
    let sealedBox = try AES.GCM.seal(data, using: symmetricKey, nonce: nonce)

    // объединяем IV + ciphertext + tag
    let combined = nonce.data + sealedBox.ciphertext + sealedBox.tag
    return combined.base64EncodedString()
}

extension AES.GCM.Nonce {
    var data: Data { Data(self) }
}
