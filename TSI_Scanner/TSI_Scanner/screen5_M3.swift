//
//  screen5_M3.swift
//  TSI_Scanner
//
//  Created by HO on 10/5/26.
//
import SwiftUI

struct Screen5_M3: View {

    var body: some View {

        VStack(spacing: 24) {

            Text("내 시간표")
                .font(.title2)
                .fontWeight(.bold)

            Text("M3")
                .foregroundStyle(.secondary)
        }
        .navigationTitle("내 시간표")
    }
}
