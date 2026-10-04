//
//  TSI_Fingerprint.swift
//
//  iPhone Sender Fingerprint
//
//  역할
//  ------------------------------------------------------------
//  1. Keychain에 저장된 fingerprint가 있으면 그대로 반환
//  2. 없으면 UUID를 새로 생성
//  3. 생성한 UUID를 Keychain에 저장
//  4. 이후 동일 fingerprint를 반환
//
//  목적
//  ------------------------------------------------------------
//  TSI 신규 / 기존 기기 판정에 사용
//
//  테스트
//  ------------------------------------------------------------
//  앱 실행 → fingerprint 확인
//  앱 삭제 → Xcode 재설치 → fingerprint 재확인
//

import Foundation
import Security


final class TSI_Fingerprint {

    private static let service = "com.tagless.tsios.fingerprint"
    private static let account = "sender_fingerprint"


    static func getFingerprint() -> String {

        // --------------------------------------------------------
        // 1. 기존 fingerprint 조회
        // --------------------------------------------------------

        let readQuery: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var item: CFTypeRef?

        let readStatus = SecItemCopyMatching(
            readQuery as CFDictionary,
            &item
        )

        if readStatus == errSecSuccess,
           let data = item as? Data,
           let fingerprint = String(data: data, encoding: .utf8) {

            print("[FP] 기존 fingerprint =", fingerprint)
            return fingerprint
        }


        // --------------------------------------------------------
        // 2. 없으면 새 fingerprint 생성
        // --------------------------------------------------------

        let fingerprint = UUID().uuidString

        guard let data = fingerprint.data(using: .utf8) else {
            return fingerprint
        }


        // --------------------------------------------------------
        // 3. Keychain 저장
        // --------------------------------------------------------

        let saveQuery: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecValueData as String: data
        ]

        let saveStatus = SecItemAdd(
            saveQuery as CFDictionary,
            nil
        )

        if saveStatus == errSecSuccess {
            print("[FP] 신규 fingerprint 저장 =", fingerprint)
        } else {
            print("[FP] Keychain 저장 실패 =", saveStatus)
        }


        // --------------------------------------------------------
        // 4. 반환
        // --------------------------------------------------------

        return fingerprint
    }
}
