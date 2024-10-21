//
//  Language.swift
//  NewWord
//
//  Created by 曾柏楊 on 2024/10/21.
//

import Foundation


enum Language: String {
    // 英語
    case americanEnglish = "en-US" // 美國英語
    case britishEnglish = "en-GB" // 英國英語
    case australianEnglish = "en-AU" // 澳大利亞英語
    case canadianEnglish = "en-CA" // 加拿大英語
    case indianEnglish = "en-IN" // 印度英語

    // 中文
    case simplifiedChinese = "zh-CN" // 簡體中文
    case traditionalChinese = "zh-TW" // 繁體中文
    case cantoneseChinese = "zh-HK" // 粵語

    // 西班牙語
    case europeanSpanish = "es-ES" // 歐洲西班牙語
    case mexicanSpanish = "es-MX" // 墨西哥西班牙語
    case americanSpanish = "es-US" // 美國西班牙語

    // 法語
    case french = "fr-FR" // 法國法語
    case canadianFrench = "fr-CA" // 加拿大法語

    // 德語
    case german = "de-DE" // 德國德語
    case austrianGerman = "de-AT" // 奧地利德語
    case swissGerman = "de-CH" // 瑞士德語

    // 其他語言
    case italian = "it-IT" // 意大利語
    case japanese = "ja-JP" // 日語
    case korean = "ko-KR" // 韓語
    case brazilianPortuguese = "pt-BR" // 巴西葡萄牙語
    case europeanPortuguese = "pt-PT" // 葡萄牙葡萄牙語
    case russian = "ru-RU" // 俄語
    case arabic = "ar-SA" // 阿拉伯語
    case hindi = "hi-IN" // 印地語
    case turkish = "tr-TR" // 土耳其語
    case dutch = "nl-NL" // 荷蘭語
    case danish = "da-DK" // 丹麥語
    case finnish = "fi-FI" // 芬蘭語
    case norwegian = "no-NO" // 挪威語
    case swedish = "sv-SE" // 瑞典語
}
