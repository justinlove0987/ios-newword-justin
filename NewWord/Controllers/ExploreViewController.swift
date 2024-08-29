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
        
//        let title = "UN Chief Urges Major Polluters to Act Now or Face Global Catastrophe"
//        
//        let content = """
//        UN Secretary-General António Guterres has emphatically stated that major polluters must take decisive action to cut emissions to avert a global disaster. Speaking at the Pacific Island Forum Leaders Meeting in Tonga, Guterres highlighted the Pacific as the most vulnerable region, stressing that while small island nations contribute minimally to climate change, they bear the brunt of its effects.
//
//        Guterres warned that rising sea levels are a pressing global issue, underscoring that "the surging seas are coming for us all." This warning coincides with the release of two critical reports by the UN on the threat posed by rising sea levels to Pacific island nations. The World Meteorological Organization’s report indicates that the South West Pacific faces a trifecta of challenges: accelerating sea level rise, ocean warming, and increased acidification due to carbon dioxide absorption.
//
//        "The sea is taking the heat – literally," Guterres stated, attributing these issues to greenhouse gas emissions from burning fossil fuels. The current forum theme, "transformative resilience," was put to the test as severe weather and an earthquake affected the event's first day. Joseph Sikulu from 350, a climate advocacy group, emphasized the importance of leaders witnessing both the challenges and the resilience of Pacific communities.
//
//        During the forum, a parade with banners reading "We are not drowning, we are fighting" and "Sea levels are rising – so are we" highlighted the region's resolve. The UN Climate Action Team’s report reveals that global sea levels are rising at unprecedented rates, with an average increase of 9.4 cm over the past 30 years, and up to 15 cm in the tropical Pacific.
//
//        Guterres, who has attended the forum before, noted that despite efforts to combat climate change, financial support mechanisms for vulnerable nations remain inadequate. He visited communities impacted by rising sea levels and criticized the slow response to funding requests for critical infrastructure, such as sea walls.
//
//        The Secretary-General also addressed the role of major emitters, including Australia, which has pledged to increase gas extraction despite calls for a fossil fuel phase-out. Guterres urged these nations and the G20, which represents 80% of global emissions, to significantly cut emissions to meet the targets set in the Paris Agreement. He stressed the urgency of reducing global emissions by 43% from 2019 levels by 2030 and 60% by 2035 to avoid catastrophic consequences.
//
//        In summary, Guterres called for immediate and substantial action from both governments and corporations to reverse current emission trends and support the most vulnerable nations facing climate change impacts.
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
//                let article = FSArticle(title: title, content: content, imageId: UUID().uuidString, uploadedDate: Date(), ttsSynthesisResult: result, cefrRawValue: 4)
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
            
            cell.configure(currentArticle)
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
