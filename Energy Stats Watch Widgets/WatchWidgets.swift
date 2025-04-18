//
//  BatteryStatusWidget.swift
//  Energy Stats Watch App
//
//  Created by Alistair Priest on 28/04/2024.
//

import Energy_Stats_Core
import SwiftUI
import WidgetKit

public enum WidgetKinds: String, CaseIterable {
    case circularWidget = "BatteryCircularWidget"
    case cornerWidget = "BatteryCornerWidget"
    case rectangularWidget = "BatteryRectangularWidget"
    case statusWidget = "BatteryStatusWidget"
}

struct BatteryGaugeView: View {
    let circularGradient = Gradient(colors: [.red, .orange, .yellow, .green])
    let value: Int
    let batteryPower: Double?

    var body: some View {
        Gauge(value: Double(value), in: 0 ... 100) {
            Image(systemName: "minus.plus.batteryblock.fill")
                .font(.system(size: 14))
                .foregroundStyle(batteryPower.tintColor)
        } currentValueLabel: {
            Text(value, format: .percent)
        }.gaugeStyle(CircularGaugeStyle(tint: circularGradient))
    }
}

struct CircularBatteryStatusWidget: Widget {
    let kind: String = WidgetKinds.circularWidget.rawValue

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: BatteryTimelineProvider(config: HomeEnergyStateManagerConfigManager())) { entry in
            Group {
                if let soc = entry.soc {
                    BatteryGaugeView(value: soc, batteryPower: entry.batteryPower)
                } else {
                    if let errorMessage = entry.errorMessage {
                        Text("")
                            .widgetLabel(errorMessage)
                    } else {
                        Text("??")
                    }
                }
            }
            .widgetCurvesContent()
            .containerBackground(for: .widget) {
                Color.clear
            }
        }
        .configurationDisplayName("Battery Status")
        .description("Shows the status of your home battery")
        .supportedFamilies([.accessoryCircular])
    }
}

struct CornerBatteryStatusWidget: Widget {
    let kind: String = WidgetKinds.cornerWidget.rawValue

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: BatteryTimelineProvider(config: HomeEnergyStateManagerConfigManager())) { entry in
            Group {
                if let soc = entry.soc {
                    Text(soc, format: .percent)
                        .widgetLabel("SoC")
                } else {
                    if let errorMessage = entry.errorMessage {
                        Text("")
                            .widgetLabel(errorMessage)
                    } else {
                        Text("??")
                    }
                }
            }
            .widgetCurvesContent()
            .containerBackground(for: .widget) {
                Color.clear
            }
        }
        .configurationDisplayName("Battery Status")
        .description("Shows the status of your home battery")
        .supportedFamilies([.accessoryCorner])
    }
}

struct RectangularBatteryStatusWidget: Widget {
    let kind: String = WidgetKinds.rectangularWidget.rawValue

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: BatteryTimelineProvider(config: HomeEnergyStateManagerConfigManager())) { entry in
            Group {
                if let soc = entry.soc {
                    HStack {
                        BatteryGaugeView(value: soc, batteryPower: entry.batteryPower)

                        VStack(alignment: .leading) {
                            if let power = entry.chargeStatusDescription {
                                Text(power)
                                //                            HStack(alignment: .center) {
                                //                                Text("\(Image(systemName: power > 0 ? "square.and.arrow.down" : "square.and.arrow.up")) \(power.kW(2))")
                                //                                    .foregroundStyle(power.tintColor)
                                //                                    .font(.footnote)
                                //                            }
                            }
                        }
                    }
                } else {
                    if let errorMessage = entry.errorMessage {
                        Text("")
                            .widgetLabel(errorMessage)
                    } else {
                        Text("??")
                    }
                }
            }
            .containerBackground(for: .widget) {
                Color.clear
            }
        }
        .configurationDisplayName("Battery Status")
        .description("Shows the status of your home battery")
        .supportedFamilies([.accessoryRectangular])
    }
}

struct BatteryStatusWidget: Widget {
    let kind: String = WidgetKinds.statusWidget.rawValue

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: BatteryTimelineProvider(config: HomeEnergyStateManagerConfigManager())) { entry in
            Group {
                if let soc = entry.soc {
                    Text(soc, format: .percent)
                        .widgetLabel {
                            Image(systemName: "minus.plus.batteryblock.fill")
                                .font(.system(size: 14))
                        }
                } else {
                    if let errorMessage = entry.errorMessage {
                        Text("")
                            .widgetLabel(errorMessage)
                    } else {
                        Text("??")
                    }
                }
            }
            .containerBackground(for: .widget) {
                Color.clear
            }
        }
        .configurationDisplayName("Battery Status")
        .description("Shows the status of your home battery")
        .supportedFamilies([.accessoryInline])
    }
}

#Preview("Rectangular", as: .accessoryRectangular) {
    RectangularBatteryStatusWidget()
} timeline: {
    BatteryTimelineEntry(date: .now, soc: 30, chargeStatusDescription: "Empty in 0 seconds", state: .loaded, errorMessage: nil, batteryPower: 2.0)
}

#Preview("Circular", as: .accessoryCircular) {
    CircularBatteryStatusWidget()
} timeline: {
    BatteryTimelineEntry(date: .now, soc: 30, chargeStatusDescription: "Empty in 0 seconds", state: .loaded, errorMessage: nil, batteryPower: 2.2)
}

#Preview("Inline", as: .accessoryInline) {
    BatteryStatusWidget()
} timeline: {
    BatteryTimelineEntry(date: .now, soc: 30, chargeStatusDescription: "Empty in 0 seconds", state: .loaded, errorMessage: nil, batteryPower: 2.2)
}

#Preview("Corner", as: .accessoryCorner) {
    CornerBatteryStatusWidget()
} timeline: {
    BatteryTimelineEntry(date: .now, soc: 30, chargeStatusDescription: "Empty in 0 seconds", state: .loaded, errorMessage: nil, batteryPower: 2.2)
}
