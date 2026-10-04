import Foundation

struct SessionInfoResult: Decodable {
    let status: String
    let user_type: String?
    let business_member_id: Int?
    let sender_device_id: Int?
    let student_name: String?
    let student_phone: String?
    let school_name: String?
    let grade: String?
    let guardian_type: String?
    let guardian_phone: String?
    let guardian_memo: String?
}

struct MemberRegisterResult: Decodable {
    let success: Bool
    let business_member_id: Int?
    let sender_device_id: Int?
    let error: String?
}

final class TSI_SessionInfo {

    static func exchangeSessionInfo(
        fingerprint: String,
        receiverDeviceId: String,
        businessId: Int,
        classId: Int
    ) async -> SessionInfoResult? {

        guard let url = URL(
            string: "https://taglesscheck.com/ios/member/check-fingerprint"
        ) else {
            print("[BLEQ TSI_SessionInfo] SessionInfo URL 오류")
            return nil
        }

        let body: [String: Any] = [
            "fingerprint": fingerprint,
            "receiver_device_id": receiverDeviceId,
            "business_id": businessId,
            "class_id": classId
        ]

        do {
            var request = URLRequest(url: url)

            request.httpMethod = "POST"
            request.setValue(
                "application/json",
                forHTTPHeaderField: "Content-Type"
            )

            request.httpBody =
                try JSONSerialization.data(withJSONObject: body)

            print(
                "[BLEQ TSI_SessionInfo] SessionInfo 전송",
                "fingerprint =", fingerprint,
                "receiver_device_id =", receiverDeviceId,
                "business_id =", businessId,
                "class_id =", classId
            )

            let (data, response) =
                try await URLSession.shared.data(for: request)

            if let http = response as? HTTPURLResponse {
                print(
                    "[BLEQ TSI_SessionInfo] SessionInfo HTTP =",
                    http.statusCode
                )
            }

            let result =
                try JSONDecoder().decode(
                    SessionInfoResult.self,
                    from: data
                )

            print(
                "[BLEQ TSI_SessionInfo] SessionInfo status =",
                result.status
            )

            return result

        } catch {
            print(
                "[BLEQ TSI_SessionInfo] SessionInfo 오류 =",
                error
            )

            return nil
        }
    }
    
    static func registerMember(
        fingerprint: String,
        receiverDeviceId: String,
        businessId: Int,
        classId: Int,
        studentName: String,
        studentPhone: String,
        schoolName: String,
        grade: String,
        guardianType: String,
        guardianPhone: String,
        guardianMemo: String,
        businessMemberId: Int?,
    ) async -> MemberRegisterResult? {

        guard let url = URL(
            string: "https://taglesscheck.com/ios/member/register"
        ) else {
            print("[BLEQ TSI_SessionInfo] MemberRegister URL 오류")
            return nil
        }

        var body: [String: Any] = [
            "fingerprint": fingerprint,
            "receiver_device_id": receiverDeviceId,
            "business_id": businessId,
            "class_id": classId,
            "student_name": studentName,
            "student_phone": studentPhone,
            "school_name": schoolName,
            "grade": grade,
            "guardian_type": guardianType,
            "guardian_phone": guardianPhone,
            "guardian_memo": guardianMemo
        ]

        if let businessMemberId {
            body["business_member_id"] = businessMemberId
        }

        do {

            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue(
                "application/json",
                forHTTPHeaderField: "Content-Type"
            )
            request.httpBody =
                try JSONSerialization.data(withJSONObject: body)

            print(
                "[BLEQ TSI_SessionInfo] MemberRegister 전송",
                body
            )

            let (data, response) =
                try await URLSession.shared.data(for: request)

            if let http = response as? HTTPURLResponse {
                print(
                    "[BLEQ TSI_SessionInfo] MemberRegister HTTP =",
                    http.statusCode
                )
            }

            let result =
                try JSONDecoder().decode(
                    MemberRegisterResult.self,
                    from: data
                )

            print(
                "[BLEQ TSI_SessionInfo] MemberRegister 결과",
                "success =", result.success,
                "business_member_id =", result.business_member_id ?? 0,
                "sender_device_id =", result.sender_device_id ?? 0
            )

            return result

        } catch {

            print(
                "[BLEQ TSI_SessionInfo] MemberRegister 오류 =",
                error
            )

            return nil
        }
    }
    
}
