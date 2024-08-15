//
//  ExploreViewController.swift
//  NewWord
//
//  Created by 曾柏楊 on 2024/8/1.
//

import UIKit

class ExploreViewController: UIViewController, StoryboardGenerated {
    
    static var storyboardName: String = K.Storyboard.main
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    private var dataSource: UICollectionViewDiffableDataSource<Int,FSArticle>!
    
    private var articles: [FSArticle] = [] {
        didSet {
            articles.sort { $0.uploadedDate > $1.uploadedDate }
            updateSnapshot()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        fetchArticles()
        
//        let title = "Test"
//        
//        let content = """
//        The sun dipped below the horizon, casting a golden hue over the tranquil sea. Gentle waves lapped at the shore, creating a soothing rhythm that matched the peaceful evening.
//        """
//        
//        let text = "\(title)\n\n\(content)"
//        
//        GoogleTTSService.shared.downloadSSML(text) { result in
//            guard let result else { return }
//            guard let audioData = result.audioData else { return }
//            
//            FirestoreManager.shared.uploadAudio(audioId: result.audioId, audioData: audioData) { isDownloadSuccessful, url in
//                let article = FSArticle(title: "Test", content: text, imageId: UUID().uuidString, uploadedDate: Date(), ttsSynthesisResult: result)
//                
//                FirestoreManager.shared.uploadArticle(article) { isDownloadSuccessful in
//                    
//                }
//            }
//        }
        
    }
    
    private func setup() {
        setupCollectionView()
    }
    
    private func fetchArticles() {
        FirestoreManager.shared.fetchAllArticles { articles in
            var newArticles: [FSArticle] = []
            
            for article in articles {
                newArticles.append(article)
            }
            
            self.articles = newArticles
        }
    }
    
    private func uploadArticles() {
        let articles: [FSArticle] = []
        
        FirestoreManager.shared.uploadArticles(articles) { uploaded in
            if uploaded {
                print("foo - uploaded")
            }
        }
    }
    
    private func setupCollectionView() {
        collectionView.register(UINib(nibName: ExploreCell.reuseIdentifier, bundle: nil), forCellWithReuseIdentifier: ExploreCell.reuseIdentifier)
        dataSource = createDataSource()
        collectionView.dataSource = dataSource
        collectionView.collectionViewLayout = createCollectionViewLayout()
        collectionView.delegate = self
        updateSnapshot()
    }
    
    private func createDataSource() -> UICollectionViewDiffableDataSource<Int, FSArticle> {
        let dataSource = UICollectionViewDiffableDataSource<Int, FSArticle>(collectionView: collectionView,
                                                                            cellProvider: { collectionView, indexPath, itemIdentifier in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ExploreCell.reuseIdentifier, for: indexPath) as! ExploreCell
            
            let currentArticle = self.articles[indexPath.row]
            
            cell.updateUI(currentArticle)
            cell.imageDidSetCallback = { self.articles[indexPath.row].image = $0 }
            
            return cell
        })
        
        return dataSource
    }
    
    private func createCollectionViewLayout() -> UICollectionViewCompositionalLayout {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0), // 每個item占用全寬
            heightDimension: .fractionalHeight(1.0)        // 固定高度為100
        )
        
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .fractionalHeight(0.382)
        )
        
        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: groupSize,
            subitems: [item]
        )
        
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 20  // 可選：設置組之間的間距
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 15, bottom: 0, trailing: 15)
        
        return UICollectionViewCompositionalLayout(section: section)
    }
    
    private func updateSnapshot() {
        var snapshot = NSDiffableDataSourceSnapshot<Int, FSArticle>()
        snapshot.appendSections([0])
        snapshot.appendItems(articles)
        dataSource.apply(snapshot, animatingDifferences: false)
    }
}

extension ExploreViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let controller = ServerProvidedArticleViewController.instantiate()
        
        controller.article = articles[indexPath.row]
        
        navigationController?.pushViewControllerWithCustomTransition(controller)
    }
}
