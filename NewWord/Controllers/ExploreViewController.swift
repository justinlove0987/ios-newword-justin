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
        
        
//        let title = "Ukraine: A Land of Surprising History and Unyielding Spirit!"
//        
//        let content = """
//        Ukraine, a nation with roots stretching back millennia, is not just a country but a testament to resilience, culture, and innovation. This Eastern European land, often known for its rich black soil and the tragic Chernobyl disaster, harbors secrets that continue to fascinate the world.
//
//        Did you know that Ukraine is home to the world’s first constitution? Drafted in 1710 by Hetman Pylyp Orlyk, this pioneering document laid down the rights of citizens and the government long before other nations caught up. Ukraine's legacy of democracy continued with the Zaporizhzhya Sich, a Cossack-run society from the 16th century, hailed as one of the earliest examples of democratic governance.
//
//        But Ukraine's influence isn't limited to governance. Its cultural contributions are just as remarkable. Take, for instance, the world's oldest map, etched into a mammoth bone, discovered in Mezhyrichchia, Ukraine. Or the Ukrainian lullaby that inspired George Gershwin's famous "Summertime." Even space exploration has a Ukrainian twist, with the first song ever sung in space being performed by Ukrainian cosmonaut Pavlo Popovych.
//
//        However, Ukraine's story isn't just about its past; it's also about its indomitable spirit today. Despite the ongoing conflict, Ukrainians continue to show the world their strength, creativity, and dedication to freedom. Whether it's in the face of foreign invasions or in the efforts to rebuild and innovate, Ukraine stands as a beacon of courage.
//
//        From the vast Carpathian Mountains to the bustling city streets of Kyiv, Ukraine is a land full of surprises, where history and modernity blend seamlessly. This nation, with its deep cultural roots and unwavering resolve, is not just surviving but thriving, proving to the world that Ukraine is indeed an amazing and unbreakable people.
//        """
//        
//        let text = "\(title)\n\n\(content)"
//        
//        GoogleTTSService.shared.downloadSSML(text) { result in
//            guard let result else {
//                print("foo - download ssml failed")
//                return
//            }
//            guard let audioData = result.audioData else { return }
//            
//            FirestoreManager.shared.uploadAudio(audioId: result.audioId, audioData: audioData) { isDownloadSuccessful, url in
//                print("foo upload audio \(isDownloadSuccessful)")
//                
//                let article = FSArticle(title: title, content: content, imageId: UUID().uuidString, uploadedDate: Date(), ttsSynthesisResult: result)
//                
//                FirestoreManager.shared.uploadArticle(article) { isDownloadSuccessful in
//                    print("foo - upload article \(isDownloadSuccessful)")
//                    
                            self.fetchArticles()
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
            cell.imageView.image = currentArticle.hasImage ? currentArticle.fetchedImage : UIImage(named: "loading")
            
            if !currentArticle.hasImage {
                self.fetchImage(at: indexPath)
            }
            
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
    
    func fetchImage(at indexPath: IndexPath) {
        FirestoreManager.shared.getImage(for: self.articles[indexPath.row].imageId) { result in
            switch result {
            case .success(let image):
                self.articles[indexPath.row].fetchedImage = image
                
            case .failure(_):
                self.articles[indexPath.row].fetchedImage = UIImage(named: "loading")
            }
            
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
        }
    }
}

extension ExploreViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let controller = ServerProvidedArticleViewController.instantiate()
        
        controller.article = articles[indexPath.row]
        
        navigationController?.pushViewControllerWithCustomTransition(controller)
    }
}
