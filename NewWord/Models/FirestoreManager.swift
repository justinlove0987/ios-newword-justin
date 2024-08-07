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

    func saveArticle(title: String, content: String, imageData: Data, audioData: Data, author: String, completion: @escaping (Bool) -> Void) {
        let articleId = UUID().uuidString
        let imageRef = storage.reference().child("images/\(articleId).jpg")
        let audioRef = storage.reference().child("audio/\(articleId).mp3")
        
        // 上傳圖片
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        
        imageRef.putData(imageData, metadata: metadata) { [weak self] (metadata, error) in
            guard error == nil else {
                print("Error uploading image: \(error!)")
                completion(false)
                return
            }
            
            imageRef.downloadURL { (url, error) in
                guard let imageUrl = url else {
                    print("Error getting image URL: \(error!)")
                    completion(false)
                    return
                }
                
                // 上傳音檔
                let audioMetadata = StorageMetadata()
                audioMetadata.contentType = "audio/mpeg"
                
                audioRef.putData(audioData, metadata: audioMetadata) { (metadata, error) in
                    guard error == nil else {
                        print("Error uploading audio: \(error!)")
                        completion(false)
                        return
                    }
                    
                    audioRef.downloadURL { (url, error) in
                        guard let audioUrl = url else {
                            print("Error getting audio URL: \(error!)")
                            completion(false)
                            return
                        }
                        
                        // 儲存文章到 Firestore
                        let article: [String: Any] = [
                            "title": title,
                            "content": content,
                            "imageUrl": imageUrl.absoluteString,
                            "audioUrl": audioUrl.absoluteString,
                            "timestamp": Timestamp(date: Date()),
                            "author": author
                        ]
                        
                        self?.db.collection("articles").document(articleId).setData(article) { error in
                            if let error = error {
                                print("Error saving article: \(error)")
                                completion(false)
                            } else {
                                print("Article successfully saved!")
                                completion(true)
                            }
                        }
                    }
                }
            }
        }
    }
    
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
              let imageUrl = data?["imageUrl"] as? String,
              let audioUrl = data?["audioUrl"] as? String else {
            return nil
        }
        
        let article = FSArticle(title: title,
                                content: content,
                                imageUrl: imageUrl,
                                audioUrl: audioUrl)
        
        return article
    }
}

struct FSArticle: Hashable {
    let title: String
    let content: String
    let imageUrl: String
    let audioUrl: String
}
