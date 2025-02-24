//
//  LatencyView.swift
//  PocketPad Client
//
//  Created by Krish Shah on 2/21/25.
//

import CoreBluetooth
import SwiftUI

struct LatencyView : View {
    @StateObject private var bluetoothManager = BluetoothManager.shared
    @State private var latency: Double = 0.0
    
    var latencyColor: Color {
        switch latency {
        case ..<50:
            return .green
        case 50..<150:
            return .yellow
        default:
            return .red
        }
    }
    
    var body: some View {
        VStack {
            HStack {
                Image(systemName: "dot.radiowaves.up.forward")
                    .resizable()
                    .scaledToFit()
                    .foregroundColor(latencyColor)
                Text("\(String(format: "%.2f", latency))ms")
                    .foregroundColor(latencyColor)
                    .font(.system(size: 13))
            }
            .frame(height: 10)
        }
    }
}

#Preview {
    struct PreviewLatencyView : View {
        @State var latency: Double = 0.0
        
        var latencyColor: Color {
            switch latency {
            case ..<40:
                return .green
            case 40..<100:
                return .yellow
            default:
                return .red
            }
        }
        
        var body: some View {
            HStack(spacing: 4) {
                Image(systemName: "dot.radiowaves.up.forward")
                    .resizable()
                    .scaledToFit()
                    .foregroundColor(latencyColor)
                Text("\(String(format: "%.2f", latency))ms")
                    .foregroundColor(latencyColor)
                    .font(.system(size: 13))
            }
            .frame(height: 10)
            .onAppear {
                Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { timer in
                    latency = Double(Int.random(in: 0...200))
                }
            }
        }
    }
    
    return PreviewLatencyView()
}
