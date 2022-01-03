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
struct VMWizardDrivesView: View {
    @ObservedObject var wizardState: VMWizardState
    
    var body: some View {
        VStack {
            Text("Storage")
                .font(.largeTitle)
            Text("Specify the size of the drive where data will be stored into.")
                .padding()
            HStack {
                NumberTextField("", number: $wizardState.storageSizeGib, onEditingChanged: { _ in
                    if wizardState.storageSizeGib < 1 {
                        wizardState.storageSizeGib = 1
                    }
                }).frame(maxWidth: 50)
                Text("GB")
            }
            Spacer()
        }
    }
}

@available(iOS 14, macOS 11, *)
struct VMWizardDrivesView_Previews: PreviewProvider {
    @StateObject static var wizardState = VMWizardState()
    
    static var previews: some View {
        VMWizardDrivesView(wizardState: wizardState)
    }
}
