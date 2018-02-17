//
//  TextViewController.swift
//  NotificationDecoder
//
//  Created by Tim Ekl on 2018.02.17.
//  Copyright © 2018 Tim Ekl. All rights reserved.
//

import Cocoa

class TextViewController: NSViewController, NSTextViewDelegate {
    
    @IBOutlet private var textView: NSTextView!
    
    var text: String {
        return textView.string
    }
    
    func textDidChange(_ notification: Notification) {
        NotificationCenter.default.post(name: .ReplacementInfoDidChange, object: self)
    }
    
}
