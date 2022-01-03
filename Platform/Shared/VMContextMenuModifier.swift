//
// Copyright © 2020 osy. All rights reserved.
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
struct VMContextMenuModifier: ViewModifier {
    @ObservedObject var vm: UTMVirtualMachine
    @EnvironmentObject private var data: UTMData
    @State private var showSharePopup = false
    @State private var confirmAction: ConfirmAction?
    
    func body(content: Content) -> some View {
        content.contextMenu {
            #if os(macOS)
            Button {
                NSWorkspace.shared.activateFileViewerSelecting([vm.path!])
            } label: {
                Label("Show in Finder", systemImage: "folder")
            }
            Divider()
            #endif
            Button {
                data.edit(vm: vm)
            } label: {
                Label("Edit", systemImage: "slider.horizontal.3")
            }.disabled(vm.viewState.suspended || vm.viewState.active)
            if vm.viewState.suspended || vm.viewState.active {
                Button {
                    confirmAction = .confirmStopVM
                } label: {
                    Label("Stop…", systemImage: "stop.fill")
                }
            } else {
                Button {
                    data.run(vm: vm)
                } label: {
                    Label("Run", systemImage: "play.fill")
                }
            }
            Button {
                showSharePopup.toggle()
            } label: {
                Label("Share", systemImage: "square.and.arrow.up")
            }
            Button {
                confirmAction = .confirmCloneVM
            } label: {
                Label("Clone…", systemImage: "doc.on.doc")
            }
            Divider()
            Button {
                confirmAction = .confirmDeleteVM
            } label: {
                Label("Delete…", systemImage: "trash")
                    .foregroundColor(.red)
            }
        }
        .modifier(VMShareItemModifier(isPresented: $showSharePopup) {
            .utmVm(vm.path!)
        })
        .modifier(VMConfirmActionModifier(vm: vm, confirmAction: $confirmAction) {
            
        })
    }
}
