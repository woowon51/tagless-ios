import ActivityKit
import WidgetKit
import SwiftUI

struct TSI_LiveLiveActivity: Widget {

    var body: some WidgetConfiguration {

        ActivityConfiguration(for: TSI_Live.self) { context in

            Text("Attendance BLE Active")

        } dynamicIsland: { context in

            DynamicIsland {
                DynamicIslandExpandedRegion(.center) {
                    Text("Attendance BLE Active")
                }
            } compactLeading: {
                Text("BLE")
            } compactTrailing: {
                Text("ON")
            } minimal: {
                Text("BLE")
            }
        }
    }
}
