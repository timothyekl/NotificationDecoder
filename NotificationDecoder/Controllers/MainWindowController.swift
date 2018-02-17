//
//  MainWindowController.swift
//  NotificationDecoder
//
//  Created by Tim Ekl on 2018.02.17.
//  Copyright © 2018 Tim Ekl. All rights reserved.
//

import Cocoa

extension Notification.Name {
    static let ReplacementInfoDidChange = Notification.Name("ReplacementInfoDidChangeNotification")
}

fileprivate extension NSViewController {
    fileprivate func descendantViewController(matching predicate: @escaping ((NSViewController) -> Bool)) -> NSViewController? {
        if predicate(self) { return self }
        return childViewControllers.lazy.flatMap({ $0.descendantViewController(matching: predicate) }).first
    }
    
    fileprivate func descendantViewController<T>(of type: T.Type) -> T? {
        return descendantViewController(matching: { $0 is T }) as! T?
    }
}

class MainWindowController: NSWindowController {
    
    override func windowDidLoad() {
        super.windowDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(MainWindowController.replacementInfoDidChange(_:)), name: .ReplacementInfoDidChange, object: nil)
    }
    
    @objc dynamic private func replacementInfoDidChange(_ notification: Notification) {
        let replacements = replacementViewController.replacements
        let inputText = textViewController.text
        let results = inputText.components(separatedBy: "\n").flatMap({ Observation(line: $0, replacements: replacements) })
        resultViewController.matches = results.filter({ $0.hasReplacementMatch })
    }
    
}

extension MainWindowController {

    var replacementViewController: ReplacementTableViewController {
        return contentViewController!.descendantViewController(of: ReplacementTableViewController.self)!
    }
    
    var textViewController: TextViewController {
        return contentViewController!.descendantViewController(of: TextViewController.self)!
    }
    
    var resultViewController: ResultsTableViewController {
        return contentViewController!.descendantViewController(of: ResultsTableViewController.self)!
    }
    
}

extension MainWindowController {
    
    @IBAction func newReplacement(_ sender: Any?) {
        replacementViewController.newReplacement(sender)
    }
    
}
