//
//  FinderFileCreatorApp.swift
//  FinderFileCreator
    

import SwiftUI
import FinderSync

@main
struct FinderFileCreatorApp: App {
    init() {
        displayWindow()
    }
    
    var body: some Scene {
        _EmptyScene()
    }
    
    
    func displayWindow() {
        let windowStyles: NSWindow.StyleMask = [.titled, .utilityWindow, .hudWindow]
        let window = NSPanel.init(contentRect: .zero, styleMask: windowStyles, backing: .buffered, defer: true)
       
        window.title = ""
        window.titleVisibility = .hidden
        window.titlebarAppearsTransparent = true
        
        
        window.contentView = NSHostingView(rootView: ContentView())
        window.contentView!.wantsLayer = true
        window.contentView!.layer?.cornerRadius = 0.0
        window.contentView!.layer?.borderWidth = 0.0
        window.isOpaque = false
        window.alphaValue = 1.0
        window.isMovableByWindowBackground = true
        window.toolbarStyle = .automatic
        window.animationBehavior = .utilityWindow
        window.center()
        window.makeKeyAndOrderFront(nil)
        
        NSApp.activate(ignoringOtherApps: true)
    }
}


struct ContentView: View {
    @State private var isExtensionEnabled: Bool = false
    @State private var isValueLoaded: Bool = false
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 12) {
                Image(.finderIcon)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 30, height: 30)
                
                Text("Finder File Creator")
                    .font(.title.bold())
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.primary, .primary.opacity(0.88)],
                            startPoint: .topLeading, endPoint: .bottomTrailing
                        )
                    )
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            
            Divider().padding(.horizontal, -20).padding(.vertical, 15)
            Spacer()
            
            VStack(spacing: 25) {
                Image(systemName: isExtensionEnabled ? "checkmark" : "exclamationmark.triangle.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 40, height: 40)
                    .foregroundStyle(isExtensionEnabled ? Color.blue.gradient : Color.orange.gradient)
                    .contentTransition(.symbolEffect(.replace.upUp))
                
                Group {
                    if isExtensionEnabled {
                        Text("**Extension is enabled**\n You can close this host application.")
                    } else {
                        Text("**Extension is disabled**\n You won't be able to use the extension until you enable it.")
                    }
                }
                .foregroundStyle(.secondary)
                .padding(.horizontal)
                .multilineTextAlignment(.center)
                .redacted(reason: isValueLoaded ? .privacy : .placeholder)
            }
            
            Spacer()
            Divider().padding(.horizontal, -20).padding(.vertical, 15)
            
            
            HStack(spacing: 7) {
                Button("Close App", action: terminateApp)
                    .buttonStyle(BlackButtonStyle())
                
                Button(isExtensionEnabled ? "Disable Extension" : "Enable Extension", action: FIFinderSyncController.showExtensionManagementInterface)
                    .buttonStyle(BlackButtonStyle())
            }
            .frame(maxWidth: .infinity, alignment: .center)
        }
        .padding([.horizontal, .bottom])
        .frame(width: 420, height: 320)
        .onReceive(NotificationCenter.default.publisher(for: NSApplication.didBecomeActiveNotification)) { _ in
            withAnimation(.easeInOut) {
                isValueLoaded = true
                isExtensionEnabled = FIFinderSyncController.isExtensionEnabled
            }
        }
    }
    
    
    func terminateApp() {
        NSApplication.shared.terminate(nil)
    }
}


struct BlackButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundStyle(.white)
            .padding(.vertical, 10)
            .frame(width: 200)
            .background(.black.gradient, in: .capsule)
            .animation(.easeInOut, value: configuration.isPressed)
            .opacity(configuration.isPressed ? 0.8 : 1)
            .scaleEffect(configuration.isPressed ? 0.96 : 1)
            .onHover {
                $0 ? NSCursor.pointingHand.push() : NSCursor.pop()
            }
    }
}
