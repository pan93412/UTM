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
struct VMConfigAppleSharingView: View {
    @ObservedObject var config: UTMAppleConfiguration
    @EnvironmentObject private var data: UTMData
    @State private var selected: SharedDirectory?
    @State private var isImporterPresented: Bool = false
    @State private var isAddReadOnly: Bool = false
    
    var body: some View {
        Form {
            Text("Note: Shared directories will not be saved and will be reset when UTM quits.")
            Table(config.sharedDirectories, selection: $selected) {
                TableColumn("Shared Path") { share in
                    Text(share.directoryURL?.path ?? "")
                }
                TableColumn("Read Only?") { share in
                    Toggle("", isOn: .constant(share.isReadOnly))
                }
            }.frame(minHeight: 300)
            HStack {
                Spacer()
                Button("Delete") {
                    config.sharedDirectories.removeAll { share in
                        share == selected
                    }
                }.disabled(selected == nil)
                Button("Add") {
                    isImporterPresented.toggle()
                }
            }.fileImporter(isPresented: $isImporterPresented, allowedContentTypes: [.folder]) { result in
                data.busyWorkAsync {
                    let url = try result.get()
                    if config.sharedDirectories.contains(where: { existing in
                        url == existing.directoryURL
                    }) {
                        throw NSLocalizedString("This directory is already being shared.", comment: "VMConfigAppleSharingView")
                    }
                    config.sharedDirectories.append(SharedDirectory(directoryURL: url, isReadOnly: isAddReadOnly))
                }
            }
            HStack {
                Spacer()
                Toggle("Add read only", isOn: $isAddReadOnly)
            }
        }
    }
}

@available(macOS 12, *)
struct VMConfigAppleSharingView_Previews: PreviewProvider {
    @State static private var config = UTMAppleConfiguration()
    
    static var previews: some View {
        VMConfigAppleSharingView(config: config)
    }
}
