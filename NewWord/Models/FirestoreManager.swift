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
              let imageUrl = data?["imageId"] as? String else {
            return nil
        }
        
        let article = FSArticle(title: title,
                                content: content,
                                imageId: imageUrl)
        
        return article
    }

    func uploadArticle(_ article: FSArticle, completion: @escaping (Bool) -> Void) {
        let articleData: [String: Any] = [
            "title": article.title,
            "content": article.content,
            "imageId": article.imageId,
        ]

        db.collection("articles").addDocument(data: articleData) { error in
            if let error = error {
                print("Error uploading article: \(error)")
                completion(false)
                return
            }
            completion(true)
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
}

struct FSArticle: Hashable {
    let title: String
    let content: String
    let imageId: String
}
