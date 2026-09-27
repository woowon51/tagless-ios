//
//  TSI_Live.swift
//  TSI
//
//  Created by HO on 9/27/26.
//
import ActivityKit

struct TSI_Live: ActivityAttributes {

    struct ContentState: Codable, Hashable {
        var status: String
    }
}

func startLive() {

    let attributes = TSI_Live()
    let state = TSI_Live.ContentState(
        status: "BLE TEST"
    )

    do {
        let activity = try Activity<TSI_Live>.request(
            attributes: attributes,
            content: ActivityContent(
                state: state,
                staleDate: nil
            )
        )
        print("TSI LIVE : ID =", activity.id)
        print("TSI LIVE : COUNT =", Activity<TSI_Live>.activities.count)
        print("TSI LIVE : STARTED")
    } catch {
        print("TSI LIVE : ERROR =", error)
    }
}
