import UIKit
import MobileCoreServices
import Foundation

@objc(FileMovePlugin) class FileMovePlugin: CDVPlugin, UIDocumentPickerDelegate {
    var callbackId: String?

    @objc(moveFolders:)
    func moveFolders(command: CDVInvokedUrlCommand) {
        self.callbackId = command.callbackId
        NSLog("moveFolders called")  // Log when the function is called

        let fileManager = FileManager.default
        let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!

        let contentsURL = documentsURL.appendingPathComponent("Contents")
        let pioneerURL = documentsURL.appendingPathComponent("PIONEER")

        var allFiles = [URL]()
        do {
            let contentsFiles = try fileManager.contentsOfDirectory(at: contentsURL, includingPropertiesForKeys: nil, options: [])
            let pioneerFiles = try fileManager.contentsOfDirectory(at: pioneerURL, includingPropertiesForKeys: nil, options: [])
            allFiles = contentsFiles + pioneerFiles
            NSLog("Files found: \(allFiles)")  // Log the files found
        } catch {
            NSLog("Failed to list files: \(error)")  // Log error
            self.sendPluginResult(success: false, message: "Failed to list files: \(error)")
            return
        }

        if #available(iOS 14, *) {
            NSLog("Presenting document picker")  // Log before presenting picker
            let picker = UIDocumentPickerViewController(forExporting: allFiles, asCopy: true)
            picker.shouldShowFileExtensions = true
            picker.delegate = self
            self.viewController.present(picker, animated: true, completion: nil)
        } else {
            NSLog("Unsupported iOS version")  // Log for unsupported iOS version
            self.sendPluginResult(success: false, message: "Unsupported iOS version")
        }
    }

    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        NSLog("documentPicker didPickDocumentsAt: \(urls)")  // Log picked documents
        if urls.count > 0 {
            self.sendPluginResult(success: true, message: "Files moved successfully.")
        } else {
            self.sendPluginResult(success: false, message: "User cancelled the operation.")
        }
    }

    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        NSLog("documentPickerWasCancelled")  // Log when picker is cancelled
        self.sendPluginResult(success: false, message: "The dialog has been cancelled")
    }

    private func sendPluginResult(success: Bool, message: String) {
        NSLog("sendPluginResult: \(success ? "Success" : "Error"), \(message)")  // Log result
        let pluginResult = CDVPluginResult(status: success ? CDVCommandStatus_OK : CDVCommandStatus_ERROR, messageAs: message)
        self.commandDelegate.send(pluginResult, callbackId: self.callbackId)
    }
}
