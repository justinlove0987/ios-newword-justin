//
//  FirestoreManager.swift
//  NewWord
//
//  Created by 曾柏楊 on 2024/8/7.
//

import Foundation


import FirebaseFirestore
import FirebaseStorage

class FirestoreManager {
    static let shared = FirestoreManager()
    private let db = Firestore.firestore()
    private let storage = Storage.storage()

    private init() {}
    
    func fetchArticle(articleId: String, completion: @escaping (FSArticle?) -> Void) {
        db.collection("articles").document(articleId).getDocument { (document, error) in
            guard let document = document, document.exists else {
                print("Article not found")
                completion(nil)
                return
            }
            
            guard let article = self.parseArticle(from: document) else {
                completion(nil)
                return
            }
            
            completion(article)
        }
    }
    
    func fetchAllArticles(completion: @escaping ([FSArticle]) -> Void) {
        db.collection("articles").getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Error fetching articles: \(error)")
                completion([])
                return
            }
            
            guard let documents = querySnapshot?.documents else {
                print("No articles found")
                completion([])
                return
            }
            
            var articles: [FSArticle] = []
            
            for document in documents {
                guard let article = self.parseArticle(from: document) else { continue }
                
                articles.append(article)
            }
            
            completion(articles)
        }
    }
    
    func parseArticle(from document: DocumentSnapshot) -> FSArticle? {
        let data = document.data()
        
        guard let title = data?["title"] as? String,
              let content = data?["content"] as? String,
              let imageUrl = data?["imageId"] as? String,
              let timestamp = data?["uploadedDate"] as? Timestamp else {
            return nil
        }
        
        let uploadedDate = timestamp.dateValue()
        
        // 解析 TTS Synthesis Result
        var ttsSynthesisResult: TTSSynthesisResult? = nil
        
        if let ttsData = data?["ttsSynthesisResult"] as? [String: Any],
           let audioId = ttsData["audioId"] as? String,
           let timepointsArray = ttsData["timepoints"] as? [[String: Any]] {
            
            var timepoints: [TimepointInfo] = []
            
            for timepoint in timepointsArray {
                let rangeData = timepoint["range"] as? [String: Any]
                let location = rangeData?["location"] as? Int ?? 0
                let length = rangeData?["length"] as? Int ?? 0
                let range = NSRange(location: location, length: length)
                let markName = timepoint["markName"] as? String ?? ""
                let timeSeconds = timepoint["timeSeconds"] as? Double ?? 0.0
                
                let timepointInfo = TimepointInfo(
                    range: range,
                    markName: markName,
                    timeSeconds: timeSeconds
                )
                timepoints.append(timepointInfo)
            }
            
            ttsSynthesisResult = TTSSynthesisResult(audioId: audioId, timepoints: timepoints)
        }
        
        let article = FSArticle(
            title: title,
            content: content,
            imageId: imageUrl,
            uploadedDate: uploadedDate,
            ttsSynthesisResult: ttsSynthesisResult
        )
        
        return article
    }

    func uploadArticle(_ article: FSArticle, completion: @escaping (Bool) -> Void) {
        var articleData: [String: Any] = [
            "title": article.title,
            "content": article.content,
            "imageId": article.imageId,
            "uploadedDate": article.uploadedDate
        ]
        
        if let ttsResult = article.ttsSynthesisResult {
            let timepointsArray: [[String: Any]] = ttsResult.timepoints.map { timepoint in
                var rangeDict: [String: Any] = [:]
                if let range = timepoint.range {
                    rangeDict["location"] = range.location
                    rangeDict["length"] = range.length
                }
                return [
                    "range": rangeDict,
                    "markName": timepoint.markName,
                    "timeSeconds": timepoint.timeSeconds
                ]
            }
            
            let ttsData: [String: Any] = [
                "audioId": ttsResult.audioId,
                "timepoints": timepointsArray
            ]
            
            articleData["ttsSynthesisResult"] = ttsData
        }

        db.collection("articles").addDocument(data: articleData) { error in
            if let error = error {
                print("Error uploading article: \(error)")
                completion(false)
                return
            }
            completion(true)
        }
    }

    func uploadArticles(_ articles: [FSArticle], completion: @escaping (Bool) -> Void) {
        let group = DispatchGroup()

        for article in articles {
            group.enter()
            let articleData: [String: Any] = [
                "title": article.title,
                "content": article.content,
                "imageId": article.imageId,
                "uploadedDate": article.uploadedDate
            ]

            db.collection("articles").addDocument(data: articleData) { error in
                if let error = error {
                    print("Error uploading article: \(error)")
                    group.leave()
                    completion(false)
                    return
                }
                group.leave()
            }
        }

        group.notify(queue: .main) {
            completion(true)
        }
    }
    
    func uploadAudio(audioId: String, audioData: Data, completion: @escaping (_ isDownloadSuccessful: Bool, _ url: String?) -> Void) {
        // 建立 Storage 參考
        let storageRef = Storage.storage().reference().child("audios/\(audioId).m4a")
        
        // 上傳音頻數據
        let metadata = StorageMetadata()
        metadata.contentType = "audio/m4a"  // 設定上傳文件的 MIME 類型
        
        storageRef.putData(audioData, metadata: metadata) { metadata, error in
            if let error = error {
                print("Error uploading audio: \(error.localizedDescription)")
                completion(false, nil)
                return
            }
            
            // 獲取下載 URL
            storageRef.downloadURL { url, error in
                if let error = error {
                    print("Error getting download URL: \(error.localizedDescription)")
                    completion(false, nil)
                    return
                }
                
                guard let downloadURL = url?.absoluteString else {
                    completion(false, nil)
                    return
                }
                
                print("Audio uploaded successfully. Download URL: \(downloadURL)")
                completion(true, downloadURL)
            }
        }
    }
    
    func downloadAudio(audioId: String, completion: @escaping (_ isDownloadSuccessful: Bool, _ audioData: Data?) -> Void) {
        // 建立 Storage 參考
        let storageRef = Storage.storage().reference().child("audios/\(audioId).m4a")
        
        // 下載音頻數據
        storageRef.getData(maxSize: 20 * 1024 * 1024) { data, error in
            if let error = error {
                print("Error downloading audio: \(error.localizedDescription)")
                completion(false, nil)
                return
            }
            
            guard let audioData = data else {
                completion(false, nil)
                return
            }
            
            print("Audio downloaded successfully.")
            completion(true, audioData)
        }
    }

    func getImage(for id: String, completion: @escaping (Result<UIImage, Error>) -> Void) {
        let storage = Storage.storage()
        let storageRef = storage.reference()

        let imagePath = "pictures/\(id).jpg"
        let imageRef = storageRef.child(imagePath)

        imageRef.downloadURL { url, error in
            if let error = error {
                completion(.failure(error))

            } else if let url = url {
                self.downloadImageData(from: url) { result in
                    switch result {
                    case .success(let data):
                        if let image = UIImage(data: data) {
                            completion(.success(image))

                        } else {
                            completion(.failure(NSError(domain: "ImageConversionError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to convert data to image"])))
                        }

                    case .failure(let error):
                        completion(.failure(error))
                    }
                }
            }
        }
    }

    private func downloadImageData(from url: URL, completion: @escaping (Result<Data, Error>) -> Void) {
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))

            } else if let data = data {
                completion(.success(data))
                
            } else {
                completion(.failure(NSError(domain: "DataError", code: -1, userInfo: [NSLocalizedDescriptionKey: "No data found"])))
            }
        }
        task.resume()
    }
    
    func mergeAudioToArticle() {
        let ttsSynthesisResultData: [String: Any] = [
            "audioData": "Base64-encoded-string",
            "timepoints": [
                [
                    "range": [
                        "location": 0,
                        "length": 5
                    ],
                    "markName": "Mark1",
                    "timeSeconds": 1.5
                ]
            ]
        ]
        
        db.collection("articles")
            .document("RBdjWUFe96nc1ccUkiCy")
            .setData([
            "ttsSynthesisResult": ttsSynthesisResultData
        ], merge: true)
    }
}

struct FSArticle: Hashable {
    let title: String
    let content: String
    let imageId: String
    let uploadedDate: Date
    var ttsSynthesisResult: TTSSynthesisResult? = nil
    
    var fetchedImage: UIImage?
    
    var formattedUploadedDate: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy/MM/dd"
        return dateFormatter.string(from: uploadedDate)
    }
    
    var text: String {
        return "\(title)\n\n\(content)"
    }
    
    var hasImage: Bool {
        return fetchedImage != nil
    }
}
