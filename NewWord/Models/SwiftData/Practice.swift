//
//  Practice.swift
//  NewWord
//
//  Created by 曾柏楊 on 2024/9/2.
//

import UIKit
import SwiftData

@Model
class Practice {

    var id: UUID
    var presetId: UUID

    init(id: UUID = UUID(), presetId: UUID = UUID()) {
        self.id = id
        self.presetId = presetId
    }
}
