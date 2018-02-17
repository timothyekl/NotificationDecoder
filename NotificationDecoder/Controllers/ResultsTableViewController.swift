//
//  ResultsTableViewController.swift
//  NotificationDecoder
//
//  Created by Tim Ekl on 2018.02.17.
//  Copyright © 2018 Tim Ekl. All rights reserved.
//

import Cocoa

fileprivate enum Column {
    case name
    case object
    case observer
    case options
    
    init?(columnIdentifier: NSUserInterfaceItemIdentifier) {
        switch columnIdentifier.rawValue {
        case "nameColumn": self = .name
        case "objectColumn": self = .object
        case "observerColumn": self = .observer
        case "optionsColumn": self = .options
        default: return nil
        }
    }
    
    var cellIdentifier: NSUserInterfaceItemIdentifier {
        switch self {
        case .name: return NSUserInterfaceItemIdentifier("nameCell")
        case .object: return NSUserInterfaceItemIdentifier("objectCell")
        case .observer: return NSUserInterfaceItemIdentifier("observerCell")
        case .options: return NSUserInterfaceItemIdentifier("optionsCell")
        }
    }
    
    func displayValue(from match: Observation) -> String {
        switch self {
        case .name: return match.name
        case .object: return match.object.displayName
        case .observer: return match.observer.displayName
        case .options: return "\(match.options)"
        }
    }
}

class ResultsTableViewController: NSViewController, NSTableViewDataSource, NSTableViewDelegate {
    
    var matches: [Observation] = [] {
        didSet {
            if isViewLoaded {
                tableView.reloadData()
            }
        }
    }
    
    @IBOutlet var tableView: NSTableView!
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return matches.count
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        guard let tableColumn = tableColumn, let column = Column(columnIdentifier: tableColumn.identifier) else { return nil }
        guard let view = tableView.makeView(withIdentifier: column.cellIdentifier, owner: nil) as? NSTableCellView else { return nil }
        let match = matches[row]
        view.textField?.stringValue = column.displayValue(from: match)
        return view
    }
    
}
