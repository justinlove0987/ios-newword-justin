//
//  GoogleCloudTranslationService.swift
//  NewWord
//
//  Created by justin on 2024/8/10.
//

import UIKit
import GoogleTranslateSwift
import SwiftKit

struct GoogleCloudTranslationService {

    private init() {}

    static let shared = GoogleCloudTranslationService()
    
    let service = GoogleTranslateApiService(apiKey: K.API.key)

    func translate(_ text: String, from: Locale, to: Locale, completion: @escaping ApiCompletion<GoogleTranslateTranslationResult>) {

        service.translate(text, from: from, to: to, completion: completion)
    }




}
