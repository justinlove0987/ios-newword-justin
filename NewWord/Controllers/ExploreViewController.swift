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
        
        
//        let title = "Black Myth: Wukong – A Global Success Story of Chinese Culture in Gaming"
//        
//        let content = """
//        This week, the video gaming community was abuzz following the release of the highly anticipated Chinese game, Black Myth: Wukong. The game quickly became a major hit, breaking records on the streaming platform Steam, where it attracted over 2.1 million concurrent players and sold more than 4.5 million copies within just 24 hours of its release.
//
//        Black Myth: Wukong is an action game that draws inspiration from the classic Chinese novel Journey to the West. Players take on the role of a powerful monkey with supernatural abilities, reminiscent of the legendary character Sun Wukong from the original story. The game is seen as a significant moment for Chinese storytelling in popular media, as it brings traditional Chinese culture to a global audience.
//
//        The game’s success has not been without controversy. Some content creators revealed that a company connected to the game's development sent them a list of topics to avoid while livestreaming, such as "feminist propaganda" and other potentially divisive subjects. This has led to discussions about censorship and freedom of speech, with some creators choosing to ignore the guidelines.
//
//        Despite these controversies, the game’s reception has been overwhelmingly positive. It has sparked a sense of national pride in China and has showcased Chinese culture to the world. Black Myth: Wukong stands as a significant achievement in the Chinese video game industry, demonstrating the global appeal of Chinese stories.
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
    
    private func fetchImage(at indexPath: IndexPath) {
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
        
        controller.addCallback = {
            self.selectTab(at: 1)
            
            if let deck = CoreDataManager.shared.findFirstDeckWithCard() {
                guard let navigationController = self.tabBarController?.selectedViewController as? UINavigationController else { return }
                
                let controller = ShowCardsViewController.instantiate()
                controller.deck = deck
                
                navigationController.pushViewControllerWithCustomTransition(controller)
                
                self.navigationController?.popViewController(animated: true)
                
            } else {
                self.navigationController?.popViewController(animated: true)
            }
        }
        
        controller.article = articles[indexPath.row]
        
        navigationController?.pushViewControllerWithCustomTransition(controller)
    }
    
    func selectTab(at index: Int, withAnimation animated: Bool = false) {
        guard let tabBarController = self.tabBarController else { return }
        guard let count = tabBarController.viewControllers?.count else { return }
        
        // 檢查 index 是否在 tabBarController 的範圍內
        guard index >= 0 && index < count else {
            print("Index out of range")
            return
        }
        
        // 切換到指定的 tabBarItem
        if animated {
            UIView.transition(with: tabBarController.view, duration: 0.3, options: .transitionCrossDissolve, animations: {
                tabBarController.selectedIndex = index
            }, completion: nil)
        } else {
            tabBarController.selectedIndex = index
        }
    }
}
