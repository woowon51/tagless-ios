//
//  BleScanMain.swift
//  TSI_Scanner
//
//  Created by HO on 9/30/26.
//
import Foundation
import CoreBluetooth
import Combine

final class BleScanMain: NSObject, ObservableObject,
            CBCentralManagerDelegate, CBPeripheralDelegate {

    private var central: CBCentralManager!
    
    private var treBB: CBPeripheral?

    // TRE_BB의 고유 Receiver ID.
    // 기존 TRE와 동일하게 /attendance/transaction 서버 전송에 사용한다.
    @Published private(set) var receiverDeviceId = ""

    // TRE_CONFIG에서 받아 보관만 한다.
    // /attendance/transaction 서버에는 보내지 않는다. 기존 TRE와 동일하게
    @Published private(set) var businessId = 0

    // TRE_CONFIG에서 받아 보관만 한다.
    // /attendance/transaction 서버에는 보내지 않는다. 기존 TRE와 동일하게
    @Published private(set) var classId = 0
    
    override init() {
        super.init()
        print("[BLEQ BleScanMain] BleScanMain init")
        central = CBCentralManager(delegate: self, queue: nil)
    }

    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        guard central.state == .poweredOn else {
            print("[BLE] Bluetooth state =", central.state.rawValue)
            return
        }

        print("[BLEQ BleScanMain] Scan 시작")

        central.scanForPeripherals(
            withServices: [CBUUID(string: "e747f937-5029-55a4-90ed-370194b05a34")],
            options: [CBCentralManagerScanOptionAllowDuplicatesKey: true]
        )
    }

    func centralManager(
        _ central: CBCentralManager,
        didDiscover peripheral: CBPeripheral,
        advertisementData: [String: Any],
        rssi RSSI: NSNumber
    ) {
        print("[BLE] didDiscover", peripheral.identifier, "RSSI =", RSSI)
        
        if treBB == nil {
            treBB = peripheral
            peripheral.delegate = self

            print("[BLEQ BleScanMain] TRE_BB 연결 시도", peripheral.identifier)
            central.connect(peripheral)
        }
        
        guard let data =
            advertisementData[CBAdvertisementDataManufacturerDataKey] as? Data
        else { return }

        let uuid = Data([
            0x37, 0xf9, 0x47, 0xe7,
            0x29, 0x50, 0xa4, 0x55,
            0x90, 0xed, 0x37, 0x01,
            0x94, 0xb0, 0x5a, 0x34
        ])

        guard data.count >= 18,
              data[0] == 0xfe,
              data[1] == 0xff,
              data.dropFirst(2).prefix(16) == uuid
        else { return }

        print("[BRE TSI] TRE FOUND  RSSI =", RSSI)
    }
    
    func centralManager(
        _ central: CBCentralManager,
        didConnect peripheral: CBPeripheral
    ) {
        print("[BLEQ BleScanMain] TRE_BB 연결 성공", peripheral.identifier)

        peripheral.discoverServices([
            CBUUID(string: "e747f937-5029-55a4-90ed-370194b05a34")
        ])
    }
    
    func peripheral(
        _ peripheral: CBPeripheral,
        didDiscoverServices error: Error?
    ) {
        if let error = error {
            print("[BLEQ BleScanMain] Service 검색 실패:", error)
            return
        }

        guard let services = peripheral.services else { return }

        for service in services {
            print("[BLEQ BleScanMain] Service 발견", service.uuid)

            if service.uuid == CBUUID(
                string: "e747f937-5029-55a4-90ed-370194b05a34"
            ) {
                print("[BLEQ BleScanMain] Tagless Service 확인")

                peripheral.discoverCharacteristics(
                    [CBUUID(string: "e747f937-5029-55a4-90ed-370194b05a35")],
                    for: service
                )
            }
        }
    }
    
    func peripheral(
        _ peripheral: CBPeripheral,
        didDiscoverCharacteristicsFor service: CBService,
        error: Error?
    ) {
        if let error = error {
            print("[BLEQ BleScanMain] Characteristic 검색 실패:", error)
            return
        }

        guard let characteristics = service.characteristics else { return }

        for characteristic in characteristics {
            print("[BLEQ BleScanMain] Characteristic 발견", characteristic.uuid)

            if characteristic.uuid == CBUUID(
                string: "e747f937-5029-55a4-90ed-370194b05a35"
            ) {
                print("[BLEQ BleScanMain] TRE_CONFIG 확인")
                peripheral.readValue(for: characteristic)
            }
        }
    }
    
    func peripheral(
        _ peripheral: CBPeripheral,
        didUpdateValueFor characteristic: CBCharacteristic,
        error: Error?
    ) {
        if let error = error {
            print("[BLEQ BleScanMain] TRE_CONFIG 읽기 실패:", error)
            return
        }

        guard let data = characteristic.value,
              let text = String(data: data, encoding: .utf8)
        else {
            print("[BLEQ BleScanMain] TRE_CONFIG 값 없음")
            return
        }

        print("[BLEQ BleScanMain] TRE_CONFIG =", text)
        
        guard let config = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let receiverDeviceId = config["receiver_device_id"] as? String,
              let businessId = config["business_id"] as? Int,
              let classId = config["class_id"] as? Int
        else {
            print("[BLEQ BleScanMain] TRE_CONFIG JSON 해석 실패")
            return
        }

        self.receiverDeviceId = receiverDeviceId
        self.businessId = businessId
        self.classId = classId

        print(
            "[BLEQ BleScanMain] CONFIG 저장",
            "receiver_device_id =", receiverDeviceId,
            "business_id =", businessId,
            "class_id =", classId
        )
            
    }
}
