//
//  Extensions.swift
//  RunTracker
//
//  Created by nikita on 12/1/17.
//  Copyright © 2017 nerzie. All rights reserved.
//

import Foundation

extension TimeInterval {
    func toString(input: TimeInterval) -> (String) {
        let integerTime = Int(input)
        let hours = integerTime / 3600
        let mins = (integerTime / 60) % 60
        let secs = integerTime % 60
        var finalString = ""
        if hours > 0 {
            finalString += "\(hours) hrs, "
        }
        if mins > 0 {
            finalString += "\(mins) mins,"
        }
        if secs > 0 {
            finalString += "\(secs) secs"
        }
        return finalString
    }
}
