//
//  InitialWindowController.swift
//  iina
//
//  Created by lhc on 27/6/2017.
//  Copyright © 2017 lhc. All rights reserved.
//

import Cocoa

class InitialWindowController: NSWindowController {

  override var windowNibName: String {
    return "InitialWindowController"
  }

  weak var playerCore: PlayerCore!


  @IBOutlet weak var recentFilesTableView: NSTableView!
  @IBOutlet weak var appIcon: NSImageView!
  @IBOutlet weak var versionLabel: NSTextField!
  @IBOutlet weak var visualEffectView: NSVisualEffectView!
  @IBOutlet weak var mainView: NSView!

  lazy var recentDocuments: [URL] = NSDocumentController.shared().recentDocumentURLs

  init(playerCore: PlayerCore) {
    self.playerCore = playerCore
    super.init(window: nil)
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func windowDidLoad() {
    super.windowDidLoad()
    window?.appearance = NSAppearance(named: NSAppearanceNameVibrantDark)
    window?.titlebarAppearsTransparent = true
    mainView.wantsLayer = true
    mainView.layer?.backgroundColor = CGColor(gray: 0.1, alpha: 1)
    appIcon.image = NSApp.applicationIconImage

    let infoDic = Bundle.main.infoDictionary!
    let version = infoDic["CFBundleShortVersionString"] as! String
    let build = infoDic["CFBundleVersion"] as! String
    versionLabel.stringValue = "\(version) Build \(build)"

    recentFilesTableView.delegate = self
    recentFilesTableView.dataSource = self

    if #available(OSX 10.11, *) {
      visualEffectView.material = .ultraDark
    }
  }

  @IBAction func openBtnAction(_ sender: NSButton) {
    (NSApp.delegate as! AppDelegate).openFile(playerCore)
    sender.layer?.backgroundColor = CGColor(gray: 0, alpha: 0)
  }

  @IBAction func openURLBtnAction(_ sender: NSButton) {
    (NSApp.delegate as! AppDelegate).openURL(playerCore)
    sender.layer?.backgroundColor = CGColor(gray: 0, alpha: 0)
  }
}


extension InitialWindowController: NSTableViewDelegate, NSTableViewDataSource {

  func numberOfRows(in tableView: NSTableView) -> Int {
    return recentDocuments.count
  }

  func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
    let url = recentDocuments[row]
    return [
      "filename": url.lastPathComponent,
      "docIcon": NSWorkspace.shared().icon(forFile: url.path)
    ]
  }

  func tableViewSelectionDidChange(_ notification: Notification) {
    guard recentFilesTableView.selectedRow >= 0 else { return }
    playerCore.openURL(recentDocuments[recentFilesTableView.selectedRow], isNetworkResource: false)
    recentFilesTableView.deselectAll(nil)
  }

}


class InitialWindowViewActionButton: NSButton {

  override func awakeFromNib() {
    self.wantsLayer = true
    self.layer?.cornerRadius = 4
    self.addTrackingArea(NSTrackingArea(rect: self.bounds, options: [.activeInKeyWindow, .mouseEnteredAndExited], owner: self, userInfo: nil))
  }

  override func mouseEntered(with event: NSEvent) {
    self.layer?.backgroundColor = CGColor(gray: 0, alpha: 0.15)
  }

  override func mouseExited(with event: NSEvent) {
    self.layer?.backgroundColor = CGColor(gray: 0, alpha: 0)
  }
  
}