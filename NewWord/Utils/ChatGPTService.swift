//
//  ChatGPTService.swift
//  NewWord
//
//  Created by justin on 2024/8/12.
//

import Foundation

// 定義回應結構體，用來解析 OpenAI 的回應
struct ChatGPTResponse: Decodable {
    struct Choice: Decodable {
        struct Message: Decodable {
            let role: String
            let content: String
        }
        let message: Message
    }
    let choices: [Choice]
}

// 定義 ChatGPTService，負責與 ChatGPT API 進行互動
class ChatGPTService {
    private let apiKey: String
    private let baseURL: URL

    init(apiKey: String) {
        self.apiKey = apiKey
        self.baseURL = URL(string: "https://api.openai.com/v1/chat/completions")!
    }

    // 發送請求給 ChatGPT API 的方法
    func sendChatGPTRequest(prompt: String, completion: @escaping (Result<String, Error>) -> Void) {
        let parameters: [String: Any] = [
            "model": "gpt-3.5-turbo",
            "messages": [
                ["role": "user", "content": prompt]
            ],
            "max_tokens": 150
        ]

        var request = URLRequest(url: baseURL)
        request.httpMethod = "POST"
        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters)
        } catch {
            completion(.failure(error))
            return
        }

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data else {
                completion(.failure(NSError(domain: "dataNilError", code: -10001, userInfo: nil)))
                return
            }

            do {
                let chatGPTResponse = try JSONDecoder().decode(ChatGPTResponse.self, from: data)
                let message = chatGPTResponse.choices.first?.message.content ?? "No response"
                completion(.success(message))
            } catch {
                completion(.failure(error))
            }
        }

        task.resume()
    }
}
