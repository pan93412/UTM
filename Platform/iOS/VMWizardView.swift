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

@available(iOS 14, *)
struct VMWizardView: View {
    @StateObject var wizardState = VMWizardState()
    @Environment(\.presentationMode) private var presentationMode: Binding<PresentationMode>
    
    var body: some View {
        NavigationView {
            WizardWrapper(page: .start, wizardState: wizardState) {
                presentationMode.wrappedValue.dismiss()
            }
        }.navigationViewStyle(StackNavigationViewStyle())
        .alert(item: $wizardState.alertMessage) { msg in
            Alert(title: Text(msg.message))
        }
    }
}

@available(iOS 14, *)
fileprivate struct WizardWrapper: View {
    let page: VMWizardPage
    @ObservedObject var wizardState: VMWizardState
    @State private var nextPage: VMWizardPage?
    let onDismiss: () -> Void
    @EnvironmentObject private var data: UTMData
    
    var body: some View {
        VStack {
            switch page {
            case .start:
                VMWizardStartView(wizardState: wizardState).padding()
            case .operatingSystem:
                VMWizardOSView(wizardState: wizardState).padding()
            case .macOSBoot:
                EmptyView()
            case .linuxBoot:
                VMWizardOSLinuxView(wizardState: wizardState).padding()
            case .windowsBoot:
                VMWizardOSWindowsView(wizardState: wizardState).padding()
            case .otherBoot:
                VMWizardOSOtherView(wizardState: wizardState).padding()
            case .hardware:
                VMWizardHardwareView(wizardState: wizardState).padding()
            case .drives:
                VMWizardDrivesView(wizardState: wizardState).padding()
            case .sharing:
                VMWizardSharingView(wizardState: wizardState).padding()
            case .summary:
                VMWizardSummaryView(wizardState: wizardState)
            }
            NavigationLink(destination: WizardWrapper(page: .start, wizardState: wizardState, onDismiss: onDismiss), tag: .start, selection: $nextPage) {}
            NavigationLink(destination: WizardWrapper(page: .operatingSystem, wizardState: wizardState, onDismiss: onDismiss), tag: .operatingSystem, selection: $nextPage) {}
            NavigationLink(destination: WizardWrapper(page: .linuxBoot, wizardState: wizardState, onDismiss: onDismiss), tag: .linuxBoot, selection: $nextPage) {}
            NavigationLink(destination: WizardWrapper(page: .windowsBoot, wizardState: wizardState, onDismiss: onDismiss), tag: .windowsBoot, selection: $nextPage) {}
            NavigationLink(destination: WizardWrapper(page: .otherBoot, wizardState: wizardState, onDismiss: onDismiss), tag: .otherBoot, selection: $nextPage) {}
            NavigationLink(destination: WizardWrapper(page: .hardware, wizardState: wizardState, onDismiss: onDismiss), tag: .hardware, selection: $nextPage) {}
            NavigationLink(destination: WizardWrapper(page: .drives, wizardState: wizardState, onDismiss: onDismiss), tag: .drives, selection: $nextPage) {}
            NavigationLink(destination: WizardWrapper(page: .sharing, wizardState: wizardState, onDismiss: onDismiss), tag: .sharing, selection: $nextPage) {}
            NavigationLink(destination: WizardWrapper(page: .summary, wizardState: wizardState, onDismiss: onDismiss), tag: .summary, selection: $nextPage) {}
        }
        .textFieldStyle(RoundedBorderTextFieldStyle())
        .pickerStyle(MenuPickerStyle())
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                if wizardState.currentPage == .start {
                    Button("Close") {
                        onDismiss()
                    }
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                if wizardState.hasNextButton {
                    Button("Next") {
                        wizardState.next()
                    }
                } else if wizardState.currentPage == .summary {
                    Button("Save") {
                        onDismiss()
                        data.busyWork {
                            let config = try wizardState.generateConfig()
                            try data.create(config: config) { vm in
                                data.selectedVM = vm
                                if wizardState.isOpenSettingsAfterCreation {
                                    data.showSettingsModal = true
                                }
                                if let qemuVm = vm as? UTMQemuVirtualMachine {
                                    data.busyWork {
                                        try wizardState.qemuPostCreate(with: qemuVm)
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        .onChange(of: nextPage) { newPage in
            if newPage == nil {
                wizardState.currentPage = page
                wizardState.nextPageBinding = $nextPage
            }
        }
        .onAppear {
            wizardState.currentPage = page
            wizardState.nextPageBinding = $nextPage
        }
    }
}

@available(iOS 14, *)
struct VMWizardView_Previews: PreviewProvider {
    static var previews: some View {
        VMWizardView()
    }
}
