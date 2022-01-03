//
// Copyright © 2021 osy. All rights reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

import SwiftUI

@available(macOS 12, *)
struct VMConfigAppleDisplayView: View {
    private struct NamedResolution: Identifiable {
        let name: String
        let resolution: Display.Resolution
        var id: String {
            name
        }
    }
    private let defaultResolution = Display.Resolution(width: 1920, height: 1200)
    
    private let resolutions = [
        NamedResolution(name: "1024x640", resolution: Display.Resolution(width: 1024, height: 640)),
        NamedResolution(name: "1024x665", resolution: Display.Resolution(width: 1024, height: 665)),
        NamedResolution(name: "1024x768", resolution: Display.Resolution(width: 1024, height: 768)),
        NamedResolution(name: "1147x745", resolution: Display.Resolution(width: 1147, height: 745)),
        NamedResolution(name: "1152x720", resolution: Display.Resolution(width: 1152, height: 720)),
        NamedResolution(name: "1168x755", resolution: Display.Resolution(width: 1168, height: 755)),
        NamedResolution(name: "1280x800", resolution: Display.Resolution(width: 1280, height: 800)),
        NamedResolution(name: "1280x1024", resolution: Display.Resolution(width: 1280, height: 1024)),
        NamedResolution(name: "1312x848", resolution: Display.Resolution(width: 1312, height: 848)),
        NamedResolution(name: "1344x840", resolution: Display.Resolution(width: 1344, height: 840)),
        NamedResolution(name: "1352x878", resolution: Display.Resolution(width: 1352, height: 878)),
        NamedResolution(name: "1440x900", resolution: Display.Resolution(width: 1440, height: 900)),
        NamedResolution(name: "1496x967", resolution: Display.Resolution(width: 1496, height: 967)),
        NamedResolution(name: "1512x982", resolution: Display.Resolution(width: 1512, height: 982)),
        NamedResolution(name: "1680x1050", resolution: Display.Resolution(width: 1680, height: 1050)),
        NamedResolution(name: "1728x1117", resolution: Display.Resolution(width: 1728, height: 1117)),
        NamedResolution(name: "1792x1120", resolution: Display.Resolution(width: 1792, height: 1120)),
        NamedResolution(name: "1800x1169", resolution: Display.Resolution(width: 1800, height: 1169)),
        NamedResolution(name: "1920x1080", resolution: Display.Resolution(width: 1920, height: 1080)),
        NamedResolution(name: "1920x1200", resolution: Display.Resolution(width: 1920, height: 1200)),
        NamedResolution(name: "2048x1280", resolution: Display.Resolution(width: 2048, height: 1280)),
        NamedResolution(name: "2056x1329", resolution: Display.Resolution(width: 2056, height: 1329)),
        NamedResolution(name: "2240x1260", resolution: Display.Resolution(width: 2240, height: 1260)),
        NamedResolution(name: "2560x1440", resolution: Display.Resolution(width: 2560, height: 1440)),
        NamedResolution(name: "2560x1600", resolution: Display.Resolution(width: 2560, height: 1600)),
        NamedResolution(name: "2880x1800", resolution: Display.Resolution(width: 2880, height: 1800)),
        NamedResolution(name: "3024x1964", resolution: Display.Resolution(width: 3024, height: 1964)),
        NamedResolution(name: "3072x1920", resolution: Display.Resolution(width: 3072, height: 1920)),
        NamedResolution(name: "3456x2234", resolution: Display.Resolution(width: 3456, height: 2234)),
        NamedResolution(name: "4480x2520", resolution: Display.Resolution(width: 4480, height: 2520)),
        NamedResolution(name: "5120x2880", resolution: Display.Resolution(width: 5120, height: 2880)),
    ]
    
    @ObservedObject var config: UTMAppleConfiguration
    
    private var displayResolution: Binding<Display.Resolution> {
        Binding<Display.Resolution> {
            if let display = config.displays.first {
                return Display.Resolution(width: display.widthInPixels, height: display.heightInPixels)
            } else {
                return defaultResolution
            }
        } set: { newValue in
            var newDisplay: Display
            if config.displays.isEmpty {
                newDisplay = Display(for: newValue, isHidpi: false)
            } else {
                newDisplay = config.displays.first!
                newDisplay.widthInPixels = newValue.width
                newDisplay.heightInPixels = newValue.height
            }
            config.displays = [newDisplay]
        }
    }
    
    private var isHidpi: Binding<Bool> {
        Binding<Bool> {
            if let display = config.displays.first {
                return display.pixelsPerInch >= 226
            } else {
                return false
            }
        } set: { newValue in
            var newDisplay: Display
            if config.displays.isEmpty {
                newDisplay = Display(for: defaultResolution, isHidpi: newValue)
            } else {
                newDisplay = config.displays.first!
                newDisplay.pixelsPerInch = newValue ? 226 : 80
            }
            config.displays = [newDisplay]
        }
    }
    
    var body: some View {
        Form {
            Picker("Display Mode", selection: $config.isConsoleDisplay) {
                Text("Console Mode")
                    .tag(true)
                Text("Full Graphics")
                    .tag(false)
            }.onChange(of: config.isConsoleDisplay) { newValue in
                if newValue {
                    config.isSerialEnabled = true
                }
            }
            if config.isConsoleDisplay {
                VMConfigDisplayConsoleView(config: config)
            } else {
                Picker("Resolution", selection: displayResolution) {
                    ForEach(resolutions) { item in
                        Text(item.name)
                            .tag(item.resolution)
                    }
                }
                Toggle("HiDPI (Retina)", isOn: isHidpi)
            }
        }
    }
}

@available(macOS 12, *)
struct VMConfigAppleDisplayView_Previews: PreviewProvider {
    @State static private var config = UTMAppleConfiguration()
    
    static var previews: some View {
        VMConfigAppleDisplayView(config: config)
    }
}
