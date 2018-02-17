//
//  ReplacementTableViewController.swift
//  NotificationDecoder
//
//  Created by Tim Ekl on 2018.02.17.
//  Copyright © 2018 Tim Ekl. All rights reserved.
//

import Cocoa

fileprivate enum Column {
    case pointer
    case replacement
    
    init?(columnIdentifier: NSUserInterfaceItemIdentifier) {
        switch columnIdentifier.rawValue {
        case "pointerColumn": self = .pointer
        case "replacementColumn": self = .replacement
        default: return nil
        }
    }
    
    init?(index: Int) {
        switch index {
        case 0: self = .pointer
        case 1: self = .replacement
        default: return nil
        }
    }
    
    var cellIdentifier: NSUserInterfaceItemIdentifier {
        switch self {
        case .pointer: return NSUserInterfaceItemIdentifier("pointerCell")
        case .replacement: return NSUserInterfaceItemIdentifier("replacementCell")
        }
    }
    
    func displayValue(from replacement: Replacement) -> String {
        switch self {
        case .pointer: return String(formattedPointer: replacement.pointer)
        case .replacement: return replacement.text
        }
    }
    
    func updatingValue(_ text: String, from replacement: Replacement) -> Replacement {
        var result = replacement
        switch self {
        case .pointer:
            result.pointer = UInt64(pointerString: text) ?? 0
        case .replacement:
            result.text = text
        }
        return result
    }
}

class ReplacementTableViewController: NSViewController, NSTableViewDelegate, NSTableViewDataSource, NSTextFieldDelegate {
    
    @IBOutlet private var tableView: NSTableView!
    
    private(set) var replacements: [Replacement] = []
    
    func newReplacement(_ sender: Any?) {
        let newReplacement = Replacement(pointer: 0xdeadbeef, text: "Replacement text")
        let row = replacements.count
        replacements.append(newReplacement)
        tableView.insertRows(at: IndexSet(integer: row), withAnimation: .slideDown)
    }
    
    // MARK: NSTableViewDataSource & NSTableViewDelegate
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return replacements.count
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        guard let tableColumn = tableColumn, let column = Column(columnIdentifier: tableColumn.identifier) else { return nil }
        guard let cellView = tableView.makeView(withIdentifier: column.cellIdentifier, owner: nil) as? NSTableCellView else { return nil }
        let replacement = replacements[row]
        cellView.textField?.stringValue = column.displayValue(from: replacement)
        cellView.textField?.delegate = self
        return cellView
    }
    
    func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
        return replacements[row]
    }
    
    // MARK: NSTextFieldDelegate
    
    override func controlTextDidEndEditing(_ obj: Notification) {
        guard let textField = obj.object as? NSTextField else { return }
        
        let row = tableView.row(for: textField)
        guard row != -1 else { return }
        guard let column = Column(index: tableView.column(for: textField)) else { return }
        
        let updated = column.updatingValue(textField.stringValue, from: replacements[row])
        replacements[row] = updated
        tableView.reloadData(forRowIndexes: IndexSet(integer: row), columnIndexes: IndexSet(0..<tableView.tableColumns.count))
        
        NotificationCenter.default.post(name: .ReplacementInfoDidChange, object: self)
    }
    
}
