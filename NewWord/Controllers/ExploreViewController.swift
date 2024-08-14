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
//         uploadArticles()
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
            
            print("foo - \(newArticles)")
            
            self.articles = newArticles
        }
    }

    private func uploadArticles() {
        let articles: [FSArticle] = [
            FSArticle(
                title: "The Impact of Climate Change on Global Agriculture",
                content: """
                Climate change is increasingly affecting global agriculture, posing challenges to food security and rural livelihoods. Rising temperatures, shifting precipitation patterns, and more frequent extreme weather events are disrupting crop yields and livestock production, leading to potential food shortages and increased prices.

                One of the most significant impacts of climate change on agriculture is the alteration of growing seasons. In many regions, warmer temperatures are causing crops to mature more quickly, which can lead to lower yields as plants have less time to develop. Additionally, changes in rainfall patterns are creating drought conditions in some areas, while others may experience excessive rainfall, both of which can damage crops and reduce productivity.

                Climate change also exacerbates the spread of pests and diseases. Warmer temperatures and increased humidity provide favorable conditions for the proliferation of insects, fungi, and bacteria that can devastate crops. This presents a particular challenge for farmers who must adapt to new threats and implement more resilient agricultural practices.

                Livestock production is similarly affected by climate change. Heat stress can reduce the productivity of animals, impacting milk production, growth rates, and reproduction. Furthermore, the availability of feed and water resources may be compromised by changing environmental conditions, leading to increased costs and reduced output.

                To address these challenges, researchers and policymakers are advocating for the adoption of climate-smart agricultural practices. These include the development of drought-resistant crop varieties, improved water management techniques, and the diversification of farming systems to enhance resilience. Additionally, efforts to reduce greenhouse gas emissions from agriculture, such as improving soil health and promoting sustainable land use practices, are crucial for mitigating the long-term impacts of climate change on global food systems.

                As the global population continues to grow, ensuring the sustainability and resilience of agriculture in the face of climate change is essential for maintaining food security and supporting rural communities worldwide.
                """,
                imageId: UUID().uuidString,
                uploadedDate: Date()
            )
        ]

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
