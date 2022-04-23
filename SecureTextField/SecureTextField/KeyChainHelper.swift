//
//  KeyChainHelper.swift
//  SecureTextField
//
//  Created by hanwe on 2022/04/23.
//

import UIKit

class KeyChainHelper {
    
    static func loadKey(name: String) -> SecKey? {
        guard let tag = name.data(using: .utf8) else { return nil }
        let query: [String: Any] = [
            kSecClass as String: kSecClassKey,
            kSecAttrApplicationTag as String: tag,
            kSecAttrKeyType as String: kSecAttrKeyTypeEC,
            kSecReturnRef as String: true
        ]
        
        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        guard status == errSecSuccess else {
            return nil
        }
        return (item as! SecKey)
    }
    
    static func makeAndStoreKey(name: String, requiresBiometry: Bool = false) throws -> SecKey? {
        removeKey(name: name)

        let flags: SecAccessControlCreateFlags
        if #available(iOS 11.3, *) {
            flags = requiresBiometry ? [.privateKeyUsage, .biometryCurrentSet] : .privateKeyUsage
        } else {
            flags = requiresBiometry ? [.privateKeyUsage, .touchIDCurrentSet] : .privateKeyUsage
        }
        guard let access = SecAccessControlCreateWithFlags(kCFAllocatorDefault, kSecAttrAccessibleWhenUnlockedThisDeviceOnly, flags, nil) else { return nil }
        guard let tag = name.data(using: .utf8) else { return nil }
        let attributes: [String: Any] = [
            kSecAttrKeyType as String: kSecAttrKeyTypeEC,
            kSecAttrKeySizeInBits as String: 256,
            kSecAttrTokenID as String: kSecAttrTokenIDSecureEnclave,
            kSecPrivateKeyAttrs as String : [
                kSecAttrIsPermanent as String: true,
                kSecAttrApplicationTag as String: tag,
                kSecAttrAccessControl as String: access
            ]
        ]
        
        var error: Unmanaged<CFError>?
        guard let privateKey = SecKeyCreateRandomKey(attributes as CFDictionary, &error) else {
            throw error!.takeRetainedValue() as Error
        }
        
        return privateKey
    }
    
    static func removeKey(name: String) {
        guard let tag = name.data(using: .utf8) else { return }
        let query: [String: Any] = [
            kSecClass as String: kSecClassKey,
            kSecAttrApplicationTag as String: tag
        ]
        SecItemDelete(query as CFDictionary)
    }
}
