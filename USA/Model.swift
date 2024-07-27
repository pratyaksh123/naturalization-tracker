//
//  Model.swift
//  USA
//
//  Created by Pratyaksh Tyagi on 7/26/24.
//

import Foundation

struct Trip: Identifiable, Codable, Equatable {
    var id = UUID()
    var title: String
    var startDate: Date
    var endDate: Date
    var emoji: String
    
    var duration: Int {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: startDate, to: endDate)
        return components.day ?? 0
    }
    
    static func == (lhs: Trip, rhs: Trip) -> Bool {
        return lhs.id == rhs.id
    }
}
