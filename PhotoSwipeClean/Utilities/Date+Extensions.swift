//
//  Date+Extensions.swift
//  PhotoSwipeClean
//
//  Created by Ayush Gupta on 22/11/25.
//

import Foundation

extension Date {
    func isSameDay(as other: Date) -> Bool {
        let calendar = Calendar.current
        return calendar.isDate(self, inSameDayAs: other)
    }
}

