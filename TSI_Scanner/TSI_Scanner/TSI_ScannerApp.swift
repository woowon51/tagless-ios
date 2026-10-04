import SwiftUI

@main struct TSI_ScannerApp: App {
    
    let ble = BleScanMain()
    let fingerprint = TSI_Fingerprint.getFingerprint()

    init() {
        print("[BLEQ TSI_ScannerApp FP] =", fingerprint)
    }

    var body: some Scene {
        WindowGroup {
            TSI_AfterScan(
                ble: ble,
                fingerprint: fingerprint)
        }
    }
}
