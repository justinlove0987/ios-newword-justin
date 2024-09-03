//
//  PracticeSequence.swift
//  NewWord
//
//  Created by justin on 2024/9/3.
//

import UIKit
import SwiftData


@Model
class PracticeSequence: Identifiable {
    var practices: [Practice] = []

    init(practices: [Practice]) {
        self.practices = practices
    }
}
