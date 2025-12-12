import Cocoa
import FinderSync

class FinderSync: FIFinderSync {
    override init() {
        super.init()

        let rootURL = URL(fileURLWithPath: "/")
        FIFinderSyncController.default().directoryURLs = Set([rootURL])

        NSLog("FinderSync initialized")
        NSLog("Monitoring root directory for global coverage")
    }

    
    override func menu(for menu: FIMenuKind) -> NSMenu? {
        // only allow for dictionary
        guard menu == .contextualMenuForContainer else { return nil }
        
        let newMenu = NSMenu()
        let parentMenuItem = NSMenuItem(title: "New File", action: nil, keyEquivalent: "")
        let submenu = NSMenu()


        for (index, template) in defaultTemplates.enumerated() {
            let item = NSMenuItem(title: template.displayName, action: #selector(createFileFromTemplate(_:)), keyEquivalent: "")
            item.tag = index
            item.target = self
            
            if let icon = template.icon {
                item.image = NSImage(resource: icon)
            }
            
            submenu.addItem(item)
        }

        
        parentMenuItem.submenu = submenu
        newMenu.addItem(parentMenuItem)
        newMenu.addItem(terminalMenuItem)
        
        return newMenu
    }
    
    
    @objc func createFileFromTemplate(_ sender: NSMenuItem) {
        guard let targetFolder = FIFinderSyncController.default().targetedURL() else {
            NSApp.showException("Failed to get the target URL from FIFinderSyncController, check FinderSync is enabled.")
            return NSLog("No target URL")
        }

        let template = defaultTemplates[sender.tag]
        let fileName = "\(template.fileName ?? "New File").\(template.fileExtension)"
        
        createFile(at: targetFolder, name: fileName, content: template.content)
        NSWorkspace.shared.selectFile(targetFolder.appending(path: fileName).path, inFileViewerRootedAtPath: "")
    }
    
    
    var terminalMenuItem: NSMenuItem {
        let item = NSMenuItem(title: "Terminal", action: #selector(openCurrentDicInTerminal), keyEquivalent: "")
        item.image = NSImage(resource: .terminalIcon)
        item.toolTip = "Open Terminal in current directory"
        
        return item
    }

    
    func createFile(at directory: URL, name: String, content: String) {
        NSLog("Attempting to create file: \(name) at: \(directory.path)")
        
        do {
            let fileURL = directory.appendingPathComponent(name)
            try content.write(to: fileURL, atomically: true, encoding: .utf8)
            NSLog("File successfully created: \(fileURL.path)")
        } catch {
            NSApp.showException(error.localizedDescription)
            NSLog("Error creating file: \(error.localizedDescription)")
        }
    }
    
    
    @objc func openCurrentDicInTerminal(_ sender: AnyObject?) {
        guard let url = FIFinderSyncController.default().targetedURL() else { return }

        let task = Process()
        task.currentDirectoryURL = url
        task.executableURL = URL(fileURLWithPath: "/usr/bin/open")
        task.arguments = ["-a", "Terminal", url.path]
        
        do {
            try task.run()
        } catch {
            print("Failed to launch terminal:", error)
            NSApp.showException(error.localizedDescription)
        }
    }
    

    var defaultTemplates: [FileTemplate] {
        return [
            FileTemplate("Swift File", fileExtension: "swift", icon: .swiftLang, content: DefaultContent.swiftFile),
            FileTemplate("Text File", fileExtension: "txt", icon: .textFile, content: DefaultContent.generic),
            FileTemplate("Markdown File", fileExtension: "md", icon: .markdownFile, content: DefaultContent.markdown),
            FileTemplate("Metal File", fileExtension: "metal", icon: .metal, content: DefaultContent.metal),
            FileTemplate("JSON File", fileExtension: "json", icon: .json, content: DefaultContent.generic),
            FileTemplate("Plist File", fileExtension: "plist", icon: .plist, content: DefaultContent.plistFile),
        ]
    }
}



struct FileTemplate {
    var displayName: String
    var fileName: String?
    var icon: ImageResource?
    var fileExtension: String
    var content: String
    var isEnabled: Bool
    
    init(_ displayName: String, fileName: String? = nil, fileExtension: String, icon: ImageResource? = nil, content: String, isEnabled: Bool = true) {
        self.displayName = displayName
        self.fileName = fileName
        self.icon = icon
        self.fileExtension = fileExtension
        self.content = content
        self.isEnabled = isEnabled
    }
}


enum DefaultContent {
    static var swiftFile: String {
        return "import Foundation\n\nprint(\"Hello, World!\")\n"
    }
    
    static var markdown: String {
        return "# Title\n\n"
    }
    
    static var generic: String {
        return ""
    }
    
    static var plistFile: String {
        return
"""
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
</dict>
</plist>
"""
    }
    
    static var metal: String {
"""
#include <metal_stdlib>
using namespace metal;\n\n
"""
    }
}

extension NSApplication {
    func showException(_ localizedDescription: String) {
        let exception = NSException(name: .genericException, reason: localizedDescription, userInfo: nil)
        self.perform(Selector(("_showException:")), with: exception)
    }
}
