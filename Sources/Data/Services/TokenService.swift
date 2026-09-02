import Foundation
import CryptoKit

public protocol TokenService {
    func saveToken(_ token: String, forKey key: String)
    func retrieveToken(forKey key: String) -> String?
    func deleteToken(forKey key: String)
    func isTokenValid(_ token: String) -> Bool
}

public final class SecureTokenService: TokenService {
    public static let shared = SecureTokenService()
    
    private let keychain = KeychainService.shared
    private let tokenExpirationInterval: TimeInterval = 3600 * 24 // 24 hours
    
    private init() {}
    
    public func saveToken(_ token: String, forKey key: String) {
        let expirationTime = Date().addingTimeInterval(tokenExpirationInterval)
        let tokenData = [
            "token": token,
            "expiresAt": expirationTime.timeIntervalSince1970
        ] as [String: Any]
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: tokenData)
            keychain.save(jsonData, forKey: key)
        } catch {
            HamrahLogger.shared.error("Failed to save token", error: error)
        }
    }
    
    public func retrieveToken(forKey key: String) -> String? {
        guard let jsonData = keychain.retrieve(forKey: key),
              let tokenData = try? JSONSerialization.jsonObject(with: jsonData) as? [String: Any],
              let token = tokenData["token"] as? String,
              let expiresAt = tokenData["expiresAt"] as? TimeInterval else {
            return nil
        }
        
        let expirationDate = Date(timeIntervalSince1970: expiresAt)
        if Date() < expirationDate {
            return token
        }
        
        deleteToken(forKey: key)
        return nil
    }
    
    public func deleteToken(forKey key: String) {
        keychain.delete(forKey: key)
    }
    
    public func isTokenValid(_ token: String) -> Bool {
        return !token.isEmpty && token.count > 10
    }
}

public final class KeychainService {
    public static let shared = KeychainService()
    
    private init() {}
    
    public func save(_ data: Data, forKey key: String) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecValueData as String: data
        ]
        
        SecItemDelete(query as CFDictionary)
        SecItemAdd(query as CFDictionary, nil)
    }
    
    public func retrieve(forKey key: String) -> Data? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        return status == errSecSuccess ? result as? Data : nil
    }
    
    public func delete(forKey key: String) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key
        ]
        
        SecItemDelete(query as CFDictionary)
    }
}
