//
//  OneTimePassword.swift
//  totosPackageDescription
//
//  Created by Andy Sherwood on 3/15/18.
//

import Foundation

public struct OneTimePassword : CustomStringConvertible {

    public var value:Int;
    public var expires:Int64;

    public var description: String {
        get {
            let expiry = Date.init(timeIntervalSince1970: TimeInterval(self.expires))
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            formatter.timeStyle = .medium
            let expiryText = formatter.string(from: expiry)
            let text = String(format: "%06d", self.value)

            return "\(text) - \(expiryText)"
        }
    }
}
