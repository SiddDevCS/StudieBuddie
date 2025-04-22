//
//  Calendar+Extensions.swift
//  Tasker
//
//  Created by Siddharth Sehgal on 27/02/2025.
//

import Foundation
import SwiftUI

extension Calendar {
    func generateDates(
        for dateInterval: DateInterval,
        matching components: DateComponents
    ) -> [Date?] {
        var dates: [Date?] = []
        dates.append(contentsOf: stride(
            from: startOfDay(for: dateInterval.start),
            to: startOfDay(for: dateInterval.end),
            by: 24 * 60 * 60
        ).map { date in
            self.date(bySettingHour: components.hour ?? 0,
                     minute: components.minute ?? 0,
                     second: components.second ?? 0,
                     of: date)
        })
        return dates
    }
}
