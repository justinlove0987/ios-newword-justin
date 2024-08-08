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
            updateSnapshot()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        fetchArticles()
//        uploadArticle()
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

    private func uploadArticle() {

        let article = FSArticle(title: "The Role of Nutrition in Mental Health: A Comprehensive Overview", content: """
Nutrition plays a significant role in mental health, influencing mood, cognitive function, and overall psychological well-being. Research has increasingly shown that dietary patterns and specific nutrients can impact mental health outcomes and contribute to the management of various mental health conditions.

Certain nutrients, such as omega-3 fatty acids, found in fish and flaxseeds, are known to support brain function and reduce symptoms of depression. Omega-3s help maintain the integrity of cell membranes and have anti-inflammatory effects that can positively impact mood regulation.

B vitamins, including folate, B6, and B12, are essential for neurotransmitter synthesis and brain health. Deficiencies in these vitamins have been linked to mood disorders and cognitive decline, highlighting the importance of a balanced diet rich in these nutrients.

Antioxidants, such as vitamins C and E, found in fruits and vegetables, protect the brain from oxidative stress and inflammation, which are associated with mental health issues. A diet high in antioxidants may contribute to improved cognitive function and emotional resilience.

Additionally, the gut-brain connection underscores the influence of gut health on mental well-being. Probiotics and prebiotics, which support a healthy gut microbiome, can affect mood and cognitive function, emphasizing the importance of a balanced diet for overall mental health.

Maintaining a well-rounded diet with a variety of nutrients is crucial for supporting mental health. Adopting healthy eating habits, combined with other lifestyle factors such as regular exercise and adequate sleep, can contribute to improved mental well-being and overall quality of life.
""", imageId: UUID().uuidString)



        FirestoreManager.shared.uploadArticle(article) { _ in
            self.fetchArticles()
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
        let cell = collectionView.cellForItem(at: indexPath) as! ExploreCell

        controller.inputText = articles[indexPath.row].content
        controller.image = cell.imageView.image

        navigationController?.pushViewControllerWithCustomTransition(controller)
    }
}
