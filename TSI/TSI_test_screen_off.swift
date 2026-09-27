//
//  TSI_test_screen_off.swift
//  TSI
//
//  Created by HO on 9/26/26.
//

import CoreBluetooth

final class TSI_test_screen_off: NSObject, CBPeripheralManagerDelegate {

    private var peripheral: CBPeripheralManager!

    override init() {
        super.init()
        
        print("TSI BLE : init")

        peripheral = CBPeripheralManager(
            delegate: self,
            queue: nil
        )
    }

    func peripheralManagerDidUpdateState(
        _ peripheral: CBPeripheralManager
    ) {
        guard peripheral.state == .poweredOn else {
            print("TSI BLE : Bluetooth not ready =", peripheral.state.rawValue)
            return
        }

        let uuid = CBUUID(
            string: "00000036-5029-55a4-90ed-370194b05a34"
        )

        peripheral.startAdvertising([
            CBAdvertisementDataServiceUUIDsKey: [uuid]
        ])

        print("TSI BLE : advertising requested")
    }

    func peripheralManagerDidStartAdvertising(
        _ peripheral: CBPeripheralManager,
        error: Error?
    ) {
        if let error {
            print("TSI BLE : advertising ERROR =", error)
        } else {
            print("TSI BLE : advertising STARTED")
        }
    }
}
