//
//  Model.swift
//  NotificationDecoder
//
//  Created by Tim Ekl on 2018.02.17.
//  Copyright © 2018 Tim Ekl. All rights reserved.
//

import Foundation

struct Replacement: Equatable {
    var pointer: UInt64
    var text: String
    
    static func ==(lhs: Replacement, rhs: Replacement) -> Bool {
        return lhs.pointer == rhs.pointer && lhs.text == rhs.text
    }
}

struct Observation {
    enum Object: Equatable {
        case raw(UInt64)
        case named(Replacement)
        
        static func ==(lhs: Object, rhs: Object) -> Bool {
            switch (lhs, rhs) {
            case (.raw(let lhsp), .raw(let rhsp)):
                return lhsp == rhsp
            case (.named(let lhsr), .named(let rhsr)):
                return lhsr == rhsr
            default:
                return false
            }
        }
        
        var displayName: String {
            switch self {
            case .raw(let pointer):
                return String(formattedPointer: pointer)
            case .named(let replacement):
                return replacement.text
            }
        }
    }
    
    var name: String
    var object: Object
    var observer: Object
    var options: Int
    
    var hasReplacementMatch: Bool {
        if case .named = object {
            return true
        } else if case .named = observer {
            return true
        } else {
            return false
        }
    }
}

// MARK: String parsing

extension Observation.Object {
    init?(pointerString: String, replacements: [Replacement]) {
        guard let pointer = UInt64(pointerString: pointerString) else { return nil }
        if let replacement = replacements.first(where: { $0.pointer == pointer }) {
            self = .named(replacement)
        } else {
            self = .raw(pointer)
        }
    }
}

extension Observation {
    init?(line: String, replacements: [Replacement]) {
        let parts = line.components(separatedBy: ", ")
        guard parts.count == 4 else { return nil }
        
        self.name = parts[0]
        
        guard let object = Observation.Object(pointerString: parts[1], replacements: replacements),
            let observer = Observation.Object(pointerString: parts[2], replacements: replacements)
            else { return nil }
        self.object = object
        self.observer = observer
        
        guard let options = Int(parts[3]) else { return nil }
        self.options = options
    }
}

// MARK: Formatting conveniences

extension String {
    init(formattedPointer value: UInt64) {
        self.init(format: "0x%016lx", value)
    }
}

extension UInt64 {
    init?(pointerString: String) {
        self.init(pointerString.replacingOccurrences(of: "0x", with: ""), radix: 16)
    }
}
