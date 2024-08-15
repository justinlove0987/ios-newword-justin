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
        
        
//        let title = "Test"
//        
//        let content = """
//        Nestled within the heart of the vibrant metropolis, there existed a small café that had become a sanctuary for those seeking respite from the relentless pace of city life. The café, with its rustic wooden façade and large glass windows, exuded a charm that was both inviting and timeless. As patrons stepped inside, they were greeted by the rich aroma of freshly ground coffee beans, a scent that instantly soothed the senses and promised comfort in every sip. The décor was an eclectic mix of vintage furniture and modern art, creating an atmosphere that was both cozy and intellectually stimulating. Soft, cushioned chairs were scattered around wooden tables, each adorned with a small vase of fresh flowers that added a splash of color to the earthy tones of the room.
//
//        The walls were lined with shelves filled with books, from classic literature to contemporary novels, offering something for every type of reader. In one corner, an old record player quietly spun vinyl records, filling the space with the soothing sounds of jazz and blues, a perfect backdrop to the murmur of conversations and the occasional clink of a spoon against a ceramic cup. The café was a haven for artists, writers, and thinkers, a place where ideas flowed as freely as the coffee. Many found inspiration here, penning poetry on napkins or sketching in notebooks, their creativity fueled by the tranquil environment.
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
//                let article = FSArticle(title: "Test", content: content, imageId: UUID().uuidString, uploadedDate: Date(), ttsSynthesisResult: result)
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
