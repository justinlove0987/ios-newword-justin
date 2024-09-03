//
//  FSDataModel.swift
//  NewWord
//
//  Created by justin on 2024/9/3.
//

import Foundation


class FSTimepointInformation {

    var id: String?
    var rangeLocation: Int?
    var rangeLength: Int?
    var markName: String
    var timeSeconds: Double

    // 初始化方法
    init(id: String?, location: Int?, length: Int?, markName: String, timeSeconds: Double) {
        self.id = id
        self.rangeLocation = location
        self.rangeLength = length
        self.markName = markName
        self.timeSeconds = timeSeconds
    }
}

class FSPracticeAudio {
    var id: String?
    var data: Data?
    var timepoints: [FSTimepointInformation] = []

    init(id: String? = nil,
         data: Data? = nil,
         timepoints: [FSTimepointInformation] = []) {

        self.id = id
        self.data = data
        self.timepoints = timepoints
    }
}

class FSPracticeImage{

    // MARK: - Properties

    var id: String?
    var data: Data?

    init(id: String? = nil, data: Data? = nil) {
        self.id = id
        self.data = data
    }
}

class FSPracticeArticle {

    var id: String?
    var title: String?
    var content: String?
    var uploadedDate: Date?
    var audioResource: FSPracticeAudio?
    var imageResource: FSPracticeImage?
    var cefrType: Int?

    // 初始化方法
    init(id: String? = UUID().uuidString,
         title: String? = nil,
         content: String? = nil,
         uploadedDate: Date? = nil,
         audioResource: FSPracticeAudio? = nil,
         imageResource: FSPracticeImage? = nil,
         cefrType: Int? = nil) {

        self.id = id
        self.title = title
        self.content = content
        self.uploadedDate = uploadedDate
        self.audioResource = audioResource
        self.imageResource = imageResource
        self.cefrType = cefrType
    }
}


