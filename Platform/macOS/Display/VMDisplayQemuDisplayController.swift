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

class VMDisplayQemuWindowController: VMDisplayWindowController {
    var qemuVM: UTMQemuVirtualMachine! {
        vm as? UTMQemuVirtualMachine
    }
    
    var vmQemuConfig: UTMQemuConfiguration! {
        vmConfiguration as? UTMQemuConfiguration
    }
    
    override func enterLive() {
        startPauseToolbarItem.isEnabled = true
        #if arch(x86_64)
        if vmQemuConfig.useHypervisor {
            // currently x86_64 HVF doesn't support suspending
            startPauseToolbarItem.isEnabled = false
        }
        #endif
        drivesToolbarItem.isEnabled = vmQemuConfig.countDrives > 0
        sharedFolderToolbarItem.isEnabled = qemuVM.hasShareDirectoryEnabled
        usbToolbarItem.isEnabled = qemuVM.hasUsbRedirection
        window!.title = vmQemuConfig.name
        super.enterLive()
    }
    
    override internal func didStartVirtualMachine(_ vm: UTMVirtualMachine) {
        qemuVM.ioDelegate = self
    }
}

// MARK: - Removable drives

@objc extension VMDisplayQemuWindowController {
    @IBAction override func drivesButtonPressed(_ sender: Any) {
        let menu = NSMenu()
        menu.autoenablesItems = false
        let item = NSMenuItem()
        item.title = NSLocalizedString("Querying drives status...", comment: "VMDisplayWindowController")
        item.isEnabled = false
        menu.addItem(item)
        DispatchQueue.global(qos: .userInitiated).async {
            let drives = self.qemuVM.drives
            DispatchQueue.main.async {
                self.updateDrivesMenu(menu, drives: drives)
            }
        }
        if let event = NSApplication.shared.currentEvent {
            NSMenu.popUpContextMenu(menu, with: event, for: sender as! NSView)
        }
    }
    
    func updateDrivesMenu(_ menu: NSMenu, drives: [UTMDrive]) {
        menu.removeAllItems()
        if drives.count == 0 {
            let item = NSMenuItem()
            item.title = NSLocalizedString("No drives connected.", comment: "VMDisplayWindowController")
            item.isEnabled = false
            menu.addItem(item)
        }
        for drive in drives {
            let item = NSMenuItem()
            item.title = drive.label
            if drive.status == .fixed {
                item.isEnabled = false
            } else {
                let submenu = NSMenu()
                submenu.autoenablesItems = false
                let eject = NSMenuItem(title: NSLocalizedString("Eject", comment: "VMDisplayWindowController"),
                                       action: #selector(ejectDrive),
                                       keyEquivalent: "")
                eject.target = self
                eject.tag = drive.index
                eject.isEnabled = drive.status != .ejected
                submenu.addItem(eject)
                let change = NSMenuItem(title: NSLocalizedString("Change", comment: "VMDisplayWindowController"),
                                        action: #selector(changeDriveImage),
                                        keyEquivalent: "")
                change.target = self
                change.tag = drive.index
                change.isEnabled = true
                submenu.addItem(change)
                item.submenu = submenu
            }
            menu.addItem(item)
        }
        menu.update()
    }
    
    func ejectDrive(sender: AnyObject) {
        guard let menu = sender as? NSMenuItem else {
            logger.error("wrong sender for ejectDrive")
            return
        }
        let drive = qemuVM.drives[menu.tag]
        DispatchQueue.global(qos: .background).async {
            do {
                try self.qemuVM.ejectDrive(drive, force: false)
            } catch {
                DispatchQueue.main.async {
                    self.showErrorAlert(error.localizedDescription)
                }
            }
        }
    }
    
    func openDriveImage(forDrive drive: UTMDrive) {
        let openPanel = NSOpenPanel()
        openPanel.title = NSLocalizedString("Select Drive Image", comment: "VMDisplayWindowController")
        openPanel.allowedContentTypes = [.data]
        openPanel.beginSheetModal(for: window!) { response in
            guard response == .OK else {
                return
            }
            guard let url = openPanel.url else {
                logger.debug("no file selected")
                return
            }
            DispatchQueue.global(qos: .background).async {
                do {
                    try self.qemuVM.changeMedium(for: drive, url: url)
                } catch {
                    DispatchQueue.main.async {
                        self.showErrorAlert(error.localizedDescription)
                    }
                }
            }
        }
    }
    
    func changeDriveImage(sender: AnyObject) {
        guard let menu = sender as? NSMenuItem else {
            logger.error("wrong sender for ejectDrive")
            return
        }
        let drive = qemuVM.drives[menu.tag]
        openDriveImage(forDrive: drive)
    }
}

// MARK: - Shared folders

extension VMDisplayQemuWindowController {
    @IBAction override func sharedFolderButtonPressed(_ sender: Any) {
        let openPanel = NSOpenPanel()
        openPanel.title = NSLocalizedString("Select Shared Folder", comment: "VMDisplayWindowController")
        openPanel.canChooseDirectories = true
        openPanel.canChooseFiles = false
        openPanel.beginSheetModal(for: window!) { response in
            guard response == .OK else {
                return
            }
            guard let url = openPanel.url else {
                logger.debug("no directory selected")
                return
            }
            DispatchQueue.global(qos: .background).async {
                do {
                    try self.qemuVM.changeSharedDirectory(url)
                } catch {
                    DispatchQueue.main.async {
                        self.showErrorAlert(error.localizedDescription)
                    }
                }
            }
        }
    }
}
