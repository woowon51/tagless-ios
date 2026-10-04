//
//  screen5_M1.swift
//  TSI_Scanner
//
//  Created by HO on 10/2/26.
//
//  원생 등록 M1
//

import SwiftUI

struct Screen5_M1: View {
    
    @ObservedObject var ble: BleScanMain
    let fingerprint: String
    
    let existingMemberId: Int?
    let existingSenderDeviceId: Int?

    let existingStudentName: String
    let existingStudentPhone: String
    let existingSchoolName: String
    let existingGrade: String
    let existingGuardianType: String
    let existingGuardianPhone: String
    
    @State private var studentName = ""
    @State private var studentPhone = ""
    @State private var school = ""
    @State private var grade = "미취학"
    @State private var guardianType = "어머니"
    @State private var guardianPhone = ""
    @State private var guardianMemo = ""
    @State private var agreed = false
    @State private var registrationDone = false
    @State private var goM3 = false

    var body: some View {

        NavigationStack {
            Form {

                // 상단 탭
                Section {
                    HStack(spacing: 0) {

                        Text("원생 등록")
                            .font(.headline)
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(.blue)

                        Text("강사/직원 등록")
                            .font(.headline)
                            .foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                    }
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .listRowInsets(
                    EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
                )

                // 원생 이름
                Section {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("원생 이름")
                            .fontWeight(.bold)

                        TextField("", text: $studentName)
                    }
                }

                // 원생 전화번호
                Section {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("원생 전화번호")
                            .fontWeight(.bold)

                        TextField("010-0000-0000", text: $studentPhone)
                            .keyboardType(.phonePad)
                            .onChange(of: studentPhone) { _, newValue in
                                studentPhone = formatPhone(newValue)
                            }
                    }
                }

                // 학교 / 학년
                Section {
                    HStack(alignment: .top, spacing: 16) {

                        VStack(alignment: .leading, spacing: 8) {
                            Text("학교")
                                .fontWeight(.bold)

                            SchoolNamePicker(
                                businessId: ble.businessId,
                                schoolName: $school
                            )
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .contentShape(Rectangle())

                        VStack(alignment: .leading, spacing: 8) {
                            Text("학년")
                                .fontWeight(.bold)

                            Menu {
                                Button("1") { grade = "1" }
                                Button("2") { grade = "2" }
                                Button("3") { grade = "3" }
                                Button("4") { grade = "4" }
                                Button("5") { grade = "5" }
                                Button("6") { grade = "6" }
                                Button("미취학") { grade = "미취학" }
                            } label: {
                                HStack {
                                    Text(grade)
                                        .foregroundStyle(.secondary)

                                    Image(systemName: "chevron.up.chevron.down")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                            }
                            .buttonStyle(.plain)
                        }
                        .frame(width: 90, alignment: .leading)
                    }
                }

                // 보호자 / 보호자 전화
                Section {
                    HStack(alignment: .top, spacing: 16) {

                        VStack(alignment: .leading, spacing: 8) {
                            Text("보호자")
                                .fontWeight(.bold)

                            Picker("", selection: $guardianType) {
                                Text("어머니").tag("어머니")
                                Text("아버지").tag("아버지")
                                Text("직접입력").tag("직접입력")
                            }
                            .labelsHidden()

                            if guardianType == "직접입력" {
                                TextField("관계 입력", text: $guardianMemo)
                            }
                        }
                        .frame(maxWidth: .infinity)

                        VStack(alignment: .leading, spacing: 8) {
                            Text("보호자 전화")
                                .fontWeight(.bold)

                            TextField("010-0000-0000", text: $guardianPhone)
                                .keyboardType(.phonePad)
                                .onChange(of: guardianPhone) { _, newValue in
                                    guardianPhone = formatPhone(newValue)
                                }
                        }
                        .frame(maxWidth: .infinity)
                    }
                }

                // 동의 내용
                Section {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("동의 내용")
                            .fontWeight(.bold)

                        Text(
                            "본인은 MeHere 출결서비스 이용을 위해 학생 정보 및 기기 식별 정보가 출석 확인 목적으로 사용되는 것에 동의합니다."
                        )
                        .font(.subheadline)
                    }
                }

                Section {
                    Toggle(
                        "위 내용에 동의합니다.",
                        isOn: $agreed
                    )
                    .tint(.blue)                }

                // 등록
                Section {
                    Button {

                        Task {

                            let result = await TSI_SessionInfo.registerMember(
                                fingerprint: fingerprint,
                                receiverDeviceId: ble.receiverDeviceId,
                                businessId: ble.businessId,
                                classId: ble.classId,
                                studentName: studentName,
                                studentPhone: studentPhone,
                                schoolName: school,
                                grade: grade,
                                guardianType: guardianType,
                                guardianPhone: guardianPhone,
                                guardianMemo: guardianMemo,
                                businessMemberId: existingMemberId                            )

                            if let result {
                                print(
                                    "[BLEQ Screen5_M1] 등록 결과",
                                    "success =", result.success,
                                    "business_member_id =", result.business_member_id ?? 0,
                                    "sender_device_id =", result.sender_device_id ?? 0,
                                    "error =", result.error ?? ""
                                )
                                if result.success {
                                    registrationDone = true
                                }
                            }
                        }

                    } label: {
                        Text("동의 및 등록")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 8)
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                    .disabled(
                        !agreed ||
                        studentName.isEmpty ||
                        studentPhone.isEmpty ||
                        school.isEmpty ||
                        grade.isEmpty ||
                        guardianPhone.isEmpty ||
                        (guardianType == "직접입력" && guardianMemo.isEmpty)
                    )
                }
                .listRowInsets(
                    EdgeInsets(top: 8, leading: 20, bottom: 8, trailing: 20)
                )
                .listRowBackground(Color.clear)
            }
            
            .onAppear {
                if existingMemberId != nil {
                    studentName = existingStudentName
                    studentPhone = existingStudentPhone
                    school = existingSchoolName
                    grade = existingGrade

                    if existingGuardianType == "어머니" ||
                       existingGuardianType == "아버지" {
                        guardianType = existingGuardianType
                    } else {
                        guardianType = "직접입력"
                        guardianMemo = existingGuardianType
                    }

                    guardianPhone = existingGuardianPhone

                    print(
                        "[BLEQ Screen5_M1] EXISTING DATA 적용",
                        "bm_id =", existingMemberId ?? 0,
                        "sender_device_id =", existingSenderDeviceId ?? 0
                    )
                }
                print(
                    "[BLEQ Screen5_M1] M1 BLE DATA",
                    "receiver_device_id =", ble.receiverDeviceId,
                    "business_id =", ble.businessId,
                    "class_id =", ble.classId
                )
            }
            .overlay {
                if registrationDone {
                    ZStack {
                        Color.black.opacity(0.25)
                            .ignoresSafeArea()

                        VStack(spacing: 20) {
                            Text("등록되었습니다.")
                                .font(.headline)

                            Button {
                                registrationDone = false
                                goM3 = true
                            } label: {
                                Text("다음")
                                    .font(.headline)
                                    .foregroundStyle(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 12)
                                    .background(.blue)
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                            }
                        }
                        .padding(24)
                        .frame(maxWidth: 310)
                        .background(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                        .shadow(radius: 12)
                    }
                }
            }
            .navigationDestination(isPresented: $goM3) {
                Screen5_M3()
            }
        }
    }

    private func formatPhone(_ value: String) -> String {

        let numbers = value.filter { $0.isNumber }

        if numbers.count <= 3 {
            return numbers
        }

        if numbers.count <= 7 {
            return
                String(numbers.prefix(3))
                + "-"
                + String(numbers.dropFirst(3))
        }

        return
            String(numbers.prefix(3))
            + "-"
            + String(numbers.dropFirst(3).prefix(4))
            + "-"
            + String(numbers.dropFirst(7).prefix(4))
    }
}

struct SchoolNamePicker: View {

    let businessId: Int
    @Binding var schoolName: String

    @State private var schoolNames: [String] = []
    @State private var selectedSchool = "DIRECT"

    var body: some View {

        Menu {
            ForEach(schoolNames, id: \.self) { name in
                Button(name) {
                    selectedSchool = name
                    schoolName = name
                }
            }

            Button("직접입력") {
                selectedSchool = "DIRECT"
                schoolName = ""
            }

        } label: {
            HStack {
                Text(
                    selectedSchool == "DIRECT"
                    ? "직접입력"
                    : selectedSchool
                )
                .foregroundStyle(.secondary)

                Image(systemName: "chevron.up.chevron.down")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .buttonStyle(.plain)
        
        .task {
            await loadSchoolNames()
        }
        
        if selectedSchool == "DIRECT" {
            TextField("학교명을 입력하세요", text: $schoolName)
        }

    }

    private func loadSchoolNames() async {

        guard businessId > 0,
              let url = URL(
                string:
                    "https://taglesscheck.com/ios/member/school-names?business_id=\(businessId)"
              )
        else { return }

        do {

            let (data, response) =
                try await URLSession.shared.data(from: url)

            if let http = response as? HTTPURLResponse {
                print(
                    "[BLEQ SchoolNamePicker] HTTP =",
                    http.statusCode
                )
            }

            guard let json =
                    try JSONSerialization.jsonObject(with: data)
                        as? [String: Any],
                  let names = json["schools"] as? [String]
            else {
                print("[BLEQ SchoolNamePicker] 학교명 JSON 해석 실패")
                return
            }

            schoolNames = names

            print(
                "[BLEQ SchoolNamePicker] 학교명 =",
                schoolNames
            )

        } catch {

            print(
                "[BLEQ SchoolNamePicker] 학교명 조회 오류 =",
                error
            )
        }
    }
}
