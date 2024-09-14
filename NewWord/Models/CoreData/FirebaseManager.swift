//
//  FirestoreManager.swift
//  NewWord
//
//  Created by 曾柏楊 on 2024/8/7.
//

import Foundation


import FirebaseFirestore
import FirebaseStorage

class FirebaseManager {
    static let shared = FirebaseManager()
    private let db = Firestore.firestore()
    private let storage = Storage.storage()

    private init() {}
    
    @MainActor
    func fetchArticle(articleId: String, completion: @escaping (CDPracticeArticle?) -> Void) {
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
    
    func fetchAllArticles(completion: @escaping ([CDPracticeArticle]) -> Void) {
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
            
            var articles: [CDPracticeArticle] = []

            for document in documents {
                guard let article = self.parseArticle(from: document) else { continue }
                
                articles.append(article)
            }
            
            completion(articles)
        }
    }


    func parseArticle(from document: DocumentSnapshot) -> CDPracticeArticle? {
        guard let data = document.data() else {
            return nil
        }

        let practiceAudioResource = CoreDataManager.shared.createEntity(ofType: CDPracticeAudio.self)
        let practiceImageResource = CoreDataManager.shared.createEntity(ofType: CDPracticeImage.self)
        let article = CoreDataManager.shared.createEntity(ofType: CDPracticeArticle.self)

        let id = data["id"] as? String
        let title = data["title"] as? String
        let content = data["content"] as? String
        let cefrRawValue = data["cefrType"] as? Int
        let timestamp = data["uploadedDate"] as? Timestamp
        let uploadedDate = timestamp?.dateValue()

        if let imageResource = data["imageResource"] as? [String: Any] {
            practiceImageResource.id = imageResource["id"] as? String
        }

        if let audioResource = data["audioResource"] as? [String: Any] {

            if let id = audioResource["id"] as? String {
                practiceAudioResource.id = id
            }

            if let parsingTmepoints = audioResource["timepoints"] as? [[String: Any]] {

                var timepoints: [CDTimepointInformation] = []

                for timepoint in parsingTmepoints {
                    let location = timepoint["rangeLocation"] as? Int ?? 0
                    let length = timepoint["rangeLength"] as? Int ?? 0
                    let markName = timepoint["markName"] as? String ?? ""
                    let timeSeconds = timepoint["timeSeconds"] as? Double ?? 0.0
                    

                    let timepoint = CoreDataManager.shared.createEntity(ofType: CDTimepointInformation.self)

                    timepoint.rangeLength = length.toInt64
                    timepoint.rangeLocation = location.toInt64
                    timepoint.timeSeconds = timeSeconds
                    timepoint.markName = markName

                    timepoints.append(timepoint)

                    article.addToTimepoints(timepoint)
                }
            }
        }

        article.id = id
        article.cefrRawValue = cefrRawValue.toInt64 ?? CEFR.none.rawValue.toInt64
        article.title = title
        article.content = content
        article.text = article.createText()
        article.uploadedDate = uploadedDate
        article.audioResource = practiceAudioResource
        article.imageResource = practiceImageResource

        return article
    }

    func uploadArticle(_ article: CDPracticeArticle, completion: @escaping (Bool) -> Void) {
        var articleData: [String: Any] = [
            "id": article.id!,
            "title": article.title!,
            "content": article.content!,
            "uploadedDate": article.uploadedDate!
        ]

        // 處理 imageResource
        if let imageResource = article.imageResource {
            var resource: [String: Any] = [:]
            
            if let imageId = imageResource.id {
                resource["id"] = imageId
            }

            articleData["imageResource"] = resource
        }

        // 處理 audioResource
        
        if let audioResource = article.audioResource {
            var resource: [String: Any] = [:]
            
            resource["id"] = audioResource.id
            
            articleData["audioResource"] = resource
        }
        
        // 處理 timepoints
        
        let timepoints = CoreDataManager.shared.getUserGeneratedTimepoints(from: article)
        
        let timepointsArray = timepoints.map { timepoint in
            [
                "rangeLocation": timepoint.rangeLocation as Any,
                "rangeLength": timepoint.rangeLength as Any,
                "markName": timepoint.markName as Any,
                "timeSeconds": timepoint.timeSeconds as Any
            ]
        }
        
        articleData["timepoints"] = timepointsArray
        
        articleData["cefrRawValue"] = article.cefrRawValue

        db.collection("articles").addDocument(data: articleData) { error in
            if let error = error {
                print("Error uploading article: \(error)")
                completion(false)
                return
            }
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

    func getImage(for id: String, completion: @escaping (Result<Data, Error>) -> Void) {
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
                        if UIImage(data: data) != nil {
                            completion(.success(data))

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

enum CEFR: Int, CaseIterable, Codable {
    case none = -1
    case a1 = 0
    case a2
    case b1
    case b2
    case c1
    case c2

    var title: String {
        switch self {
        case .none:
            return "未分類"
        case .a1:
            return "A1"
        case .a2:
            return "A2"
        case .b1:
            return "B1"
        case .b2:
            return "B2"
        case .c1:
            return "C1"
        case .c2:
            return "C2"
        }
    }
}

struct FSArticle: Hashable {
    
    let title: String
    let content: String
    let imageId: String
    let uploadedDate: Date
    var ttsSynthesisResult: TTSSynthesisResult? = nil
    var cefrRawValue: Int?
    
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
    
    var cefr: CEFR? {
        guard let cefrRawValue else { return nil }
        
        let crfr = CEFR(rawValue: cefrRawValue)
        
        return crfr
    }
}
