//
//  DICKeyManager.swift
//  DeviceInfoCollector
//
//  Created by Ahsan on 21/06/2023.
//

import CryptoKit
import Security
import SwiftUI

enum KeyGenerationError: Error {
    case keyGenerationFailed
}

class DICKeyManager {
    private let keychainService: String
    private let keychainAccount: String
    private var cachedKey: Data?

    init(keychainService: String, keychainAccount: String) {
        self.keychainService = keychainService
        self.keychainAccount = keychainAccount
    }

    func generateAndStoreKey() -> String {
        // Check if the key already exists in the Keychain
        if let existingKey = getKeyFromKeychain() {
            return "Key already exists in Keychain: \(existingKey)"
        }

        do {
            // Generate a new key
            let key = try generateKey()

            // Save the key in the Keychain
            saveKeyToKeychain(key)

            // Cache the key for future use
            cacheKey(key)
            return "Key generated, stored in Keychain, and cached: \(key)"
        } catch {
            return "Error generating or storing the key: \(error)"
        }
    }

    private func generateKey() throws -> Data {
        var keyData = Data(count: 32)
        let result = keyData.withUnsafeMutableBytes { mutableBytes in
            if let baseAddress = mutableBytes.baseAddress, mutableBytes.count > 0 {
                return SecRandomCopyBytes(kSecRandomDefault, 32, baseAddress)
            }
            return errSecAllocate
        }

        guard result == errSecSuccess else {
            throw KeyGenerationError.keyGenerationFailed
        }

        return keyData
    }

    private func getKeyFromKeychain() -> Data? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: keychainService,
            kSecAttrAccount as String: keychainAccount,
            kSecReturnData as String: true
        ]

        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)

        guard status == errSecSuccess,
              let keyData = item as? Data else {
            return nil
        }

        return keyData
    }

    private func saveKeyToKeychain(_ key: Data) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: keychainService,
            kSecAttrAccount as String: keychainAccount,
            kSecValueData as String: key,
            kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly
        ]

        let status = SecItemAdd(query as CFDictionary, nil)

        guard status == errSecSuccess else {
            print("Error saving key to Keychain:", status)
            return
        }

        print("Key saved to Keychain")
    }

    private func cacheKey(_ key: Data) {
        cachedKey = key
    }
}


