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

@available(iOS 14, macOS 11, *)
struct BigButtonStyle: ButtonStyle {
    let width: CGFloat
    let height: CGFloat
    
    fileprivate struct BigButtonView: View {
        let width: CGFloat
        let height: CGFloat
        let configuration: BigButtonStyle.Configuration
        @Environment(\.isEnabled) private var isEnabled: Bool
        
        #if os(macOS)
        let defaultColor = Color(NSColor.controlColor)
        let pressedColor = Color(NSColor.controlAccentColor)
        let foregroundColor = Color(NSColor.controlTextColor)
        let foregroundDisabledColor = Color(NSColor.disabledControlTextColor)
        let foregroundPressedColor = Color(NSColor.selectedControlColor)
        #else
        let defaultColor = Color(UIColor.secondarySystemBackground)
        let pressedColor = Color(UIColor.systemFill)
        let foregroundColor = Color(UIColor.secondaryLabel)
        let foregroundDisabledColor = Color(UIColor.systemGray)
        let foregroundPressedColor = Color(UIColor.secondaryLabel)
        #endif
        
        var body: some View {
            ZStack {
                RoundedRectangle(cornerRadius: 10.0)
                    .fill(configuration.isPressed ? pressedColor : defaultColor)
                configuration.label
                    .foregroundColor(isEnabled ? (configuration.isPressed ? foregroundPressedColor : foregroundColor) : foregroundDisabledColor)
            }.frame(width: width, height: height)
        }
    }
    
    func makeBody(configuration: Configuration) -> some View {
        BigButtonView(width: width, height: height, configuration: configuration)
    }
}

#if os(macOS)
typealias BrowseButtonStyle = DefaultButtonStyle
#else
@available(iOS 14, *)
struct BrowseButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        BigButtonStyle.BigButtonView(width: 150, height: 50, configuration: configuration)
    }
}
#endif
