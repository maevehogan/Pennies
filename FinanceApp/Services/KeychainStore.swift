//  KeychainStore.swift
//  FinanceApp
//
//  Thin wrapper around the iOS Keychain for storing a single string value
//  (the JWT auth token). Unlike UserDefaults, Keychain entries are encrypted
//  at rest using the device's hardware key and excluded from unencrypted backups.

import Foundation
import Security

enum KeychainStore {

    private static let service = Bundle.main.bundleIdentifier ?? "com.financeapp"

    /// Saves or overwrites a string value for the given key.
    static func set(_ value: String, forKey key: String) {
        let data = Data(value.utf8)

        // Try an update first; if the item doesn't exist yet, add it.
        if SecItemUpdate(query(for: key) as CFDictionary, [kSecValueData: data] as CFDictionary) == errSecItemNotFound {
            var attrs = query(for: key)
            attrs[kSecValueData as String] = data
            SecItemAdd(attrs as CFDictionary, nil)
        }
    }

    /// Returns the stored string for the given key, or nil if not found.
    static func get(forKey key: String) -> String? {
        var attrs = query(for: key)
        attrs[kSecReturnData as String] = true
        attrs[kSecMatchLimit as String] = kSecMatchLimitOne

        var result: AnyObject?
        guard SecItemCopyMatching(attrs as CFDictionary, &result) == errSecSuccess,
              let data = result as? Data else { return nil }
        return String(data: data, encoding: .utf8)
    }

    /// Deletes the stored value for the given key. Safe to call when no value exists.
    static func delete(forKey key: String) {
        SecItemDelete(query(for: key) as CFDictionary)
    }

    private static func query(for key: String) -> [String: Any] {
        [
            kSecClass as String:       kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
        ]
    }
}
