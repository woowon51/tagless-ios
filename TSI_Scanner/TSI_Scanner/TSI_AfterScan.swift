import SwiftUI

struct TSI_AfterScan: View {

    @ObservedObject var ble: BleScanMain
    let fingerprint: String

    @State private var sessionInfoSent = false
    @State private var sessionStatus = ""
    @State private var sessionResult: SessionInfoResult?
    
    var body: some View {

        Group {
            if sessionStatus == "NEW" {
                Screen5_M1(
                    ble: ble,
                    fingerprint: fingerprint,
                    existingMemberId: nil,
                    existingSenderDeviceId: nil,
                    existingStudentName: "",
                    existingStudentPhone: "",
                    existingSchoolName: "",
                    existingGrade: "",
                    existingGuardianType: "",
                    existingGuardianPhone: ""
                )
            } else if sessionStatus == "EXISTING",
                      let result = sessionResult {

                Screen5_M1(
                    ble: ble,
                    fingerprint: fingerprint,
                    existingMemberId: result.business_member_id,
                    existingSenderDeviceId: result.sender_device_id,
                    existingStudentName: result.student_name ?? "",
                    existingStudentPhone: result.student_phone ?? "",
                    existingSchoolName: result.school_name ?? "",
                    existingGrade: result.grade ?? "",
                    existingGuardianType: result.guardian_type ?? "",
                    existingGuardianPhone: result.guardian_phone ?? ""
                )

            } else {
                ProgressView("사용자 정보 확인 중...")
            }
        }
        .onChange(of: ble.receiverDeviceId) { _, _ in
            sendSessionInfo()
        }
        .onChange(of: ble.businessId) { _, _ in
            sendSessionInfo()
        }
        .onChange(of: ble.classId) { _, _ in
            sendSessionInfo()
        }
    }

    private func sendSessionInfo() {

        guard !sessionInfoSent,
              !fingerprint.isEmpty,
              !ble.receiverDeviceId.isEmpty,
              ble.businessId > 0,
              ble.classId > 0
        else { return }

        sessionInfoSent = true

        print("[BLEQ TSI_AfterScan] SessionInfo 호출")

        Task {
            if let result =
                await TSI_SessionInfo.exchangeSessionInfo(
                    fingerprint: fingerprint,
                    receiverDeviceId: ble.receiverDeviceId,
                    businessId: ble.businessId,
                    classId: ble.classId
                ) {

                sessionStatus = result.status
                sessionResult = result
                
                if result.status == "EXISTING" {
                    print(
                        "[BLEQ TSI_AfterScan] EXISTING DATA",
                        "bm_id =", result.business_member_id ?? 0,
                        "sender_device_id =", result.sender_device_id ?? 0,
                        "name =", result.student_name ?? "",
                        "phone =", result.student_phone ?? "",
                        "school =", result.school_name ?? "",
                        "grade =", result.grade ?? "",
                        "guardian_type =", result.guardian_type ?? "",
                        "guardian_phone =", result.guardian_phone ?? ""
                    )
                }
                print(
                    "[BLEQ TSI_AfterScan] SessionInfo 결과 =",
                    sessionStatus
                )
            }
        }
    }
}

#Preview {
    TSI_AfterScan(
        ble: BleScanMain(),
        fingerprint: "[BLEQ TSI_AfterScan] fingerprint put test"
    )
}
