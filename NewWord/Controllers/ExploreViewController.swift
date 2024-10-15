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
    
    private var dataSource: UICollectionViewDiffableDataSource<Int, CDPracticeArticle>!
    
    private var resources: [CDPracticeArticle] = [] {
        didSet {
            resources.sort { $0.uploadedDate! > $1.uploadedDate! }
            
            updateSnapshot()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        resetData()
//        uploadArticle()
        setup()
    }
    
    func getYesterdayDate() -> Date {
        let calendar = Calendar.current
        let today = Date()
        
        // 使用dateComponents來減去一天
        let yesterday = calendar.date(byAdding: .day, value: -1, to: today)
        
        return yesterday!
    }
    
    private func resetData() {
        UserDefaultsManager.shared.lastDataFetchedDate = getYesterdayDate()
        //        CoreDataManager.shared.deleteAllEntities()
    }
    
    private func setup() {
        setupCollectionView()
        setupArticles()
    }
    
    private func setupCollectionView() {
        collectionView.register(UINib(nibName: ExploreCell.reuseIdentifier, bundle: nil), forCellWithReuseIdentifier: ExploreCell.reuseIdentifier)
        dataSource = createDataSource()
        collectionView.dataSource = dataSource
        collectionView.collectionViewLayout = createCollectionViewLayout()
        collectionView.delegate = self
        updateSnapshot()
    }
    
    private func createDataSource() -> UICollectionViewDiffableDataSource<Int, CDPracticeArticle> {
        let dataSource = UICollectionViewDiffableDataSource<Int, CDPracticeArticle>(collectionView: collectionView,
                                                                                    cellProvider: { collectionView, indexPath, itemIdentifier in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ExploreCell.reuseIdentifier, for: indexPath) as! ExploreCell
            
            cell.configure(itemIdentifier)
            
            cell.imageView.image = itemIdentifier.hasImage ? itemIdentifier.imageResource?.image : UIImage(named: "loading")
            
            if !itemIdentifier.hasImage {
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
        var snapshot = NSDiffableDataSourceSnapshot<Int, CDPracticeArticle>()
        snapshot.appendSections([0])
        snapshot.appendItems(resources)
        
        DispatchQueue.main.async {
            self.dataSource.apply(snapshot, animatingDifferences: false)
        }
    }
    
    private func fetchImage(at indexPath: IndexPath) {
        let article = self.resources[indexPath.row]
        guard let imageId = article.imageResource?.id else { return }
        guard article.id != nil else { return }
        
        FirebaseManager.shared.getImage(for: imageId) { result in
            switch result {
            case .success(let imageData):
                article.imageResource?.data = imageData
                CoreDataManager.shared.save()
                
            case .failure(_):
                article.imageResource?.data = UIImage(named: "loading")?.pngData()
            }
            
            DispatchQueue.main.async {
                var snapshot = self.dataSource.snapshot()
                
                snapshot.reloadItems([self.resources[indexPath.row]])
                
                self.dataSource.apply(snapshot, animatingDifferences: true)
            }
        }
    }
    
    // MARK: - Helper Methods
    
    func setupArticles() {
        let localArticles = CoreDataManager.shared.getAll(ofType: CDPracticeArticle.self)
        
        self.resources = localArticles
        
        if shouldFetchArticles() {
            fetchAndSyncArticles(with: localArticles)
        }
    }
    
    private func shouldFetchArticles() -> Bool {
        return !UserDefaultsManager.shared.hasFetchedDataToday()
    }
    
    private func fetchAndSyncArticles(with localArticles: [CDPracticeArticle]) {
        fetchArticles { serverArticles in
            self.syncNewServerArticles(with: localArticles, from: serverArticles) {
                self.resources = CoreDataManager.shared.getAll(ofType: CDPracticeArticle.self)
            }
            
            UserDefaultsManager.shared.updateLastFetchedDate()
        }
    }
    
    private func fetchArticles(completion: @escaping ([CDPracticeArticle]) -> Void) {
        FirebaseManager.shared.fetchAllArticles { articles in
            completion(articles)
        }
    }
    
    private func syncNewServerArticles(with localArticles: [CDPracticeArticle], from serverArticles: [CDPracticeArticle], completion: @escaping () -> Void) {
        let localArticleIDs = Set(localArticles.map { $0.id })
        
        serverArticles.forEach { serverArticle in
            let hasArticle = localArticleIDs.contains(serverArticle.id)
            
            if hasArticle {
                CoreDataManager.shared.discardEntity(serverArticle)
            }
        }
        
        CoreDataManager.shared.save()
        
        completion()
    }
}

extension ExploreViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let controller = ServerProvidedArticleViewController.instantiate()
        
        controller.waitCallback = { [weak self] in
            self?.navigationController?.popToRootViewController(animated: true)
            self?.collectionView.reloadData()
        }
        
        controller.confirmCallback = { [weak self] in
            guard let self else { return }
            
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
        
        controller.article = self.resources[indexPath.row]
        
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

extension ExploreViewController {
    func uploadArticle() {
        let title = "Africa's Growing Presence in Space"
        
        let content =
                """
                On August 16, a significant milestone was reached when 116 satellites, mostly from Western nations, were launched into space. Among them, Senegal’s GaindeSAT-1A stood out as the country’s first satellite, marking an important step for Africa’s technological growth.

                GaindeSAT-1A, a small CubeSat, will help with earth observation and telecommunications. Senegal’s president praised this achievement as a move toward technological sovereignty. Lower costs in space launches have opened new opportunities for African nations to engage in space activities, says Kwaku Sumah, founder of Spacehubs Africa.

                To date, 17 African countries have launched more than 60 satellites. In the last year, Djibouti and Zimbabwe joined Senegal in sending their first satellites into orbit. Despite these advances, Africa still lacks its own space launch facilities, relying on partnerships with other nations.

                African nations have used satellites to address urgent issues such as climate change. For example, Kenyan meteorologists have used satellite data to track severe weather and anticipate natural disasters. However, the continent remains dependent on foreign technology and expertise, a challenge that local governments hope to overcome.

                As African space programs continue to grow, experts see both opportunities and challenges. While global powers may use these programs for geopolitical influence, African nations aim to leverage their space achievements to address their unique needs, from agriculture to disaster management. With nearly 80 satellites in development, Africa’s future in space looks promising.
                """
        
        let text = "\(title)\n\n\(content)"
        
        GoogleTTSService.shared.downloadSSML(text) { audioResource, timepoints in
            guard let audioResource else {
                print("foo - download ssml failed")
                return
            }
            
            guard let id = audioResource.id else {
                print("foo - download ssml failed, there is no audio id")
                return
            }
            
            guard let audioData = audioResource.data else {
                print("foo - download ssml failed, there is no audio data")
                return
            }
            
            guard let timepoints else {
                print("foo - download ssml failed, there is no timepoints")
                return
            }
            
            FirebaseManager.shared.uploadAudio(audioId: id, audioData: audioData) { isDownloadSuccessful, url in
                
                print("foo - upload audio \(isDownloadSuccessful)")
                
                let imageResource = CoreDataManager.shared.createEntity(ofType: CDPracticeImage.self)
                imageResource.id = UUID().uuidString
                
                let article = CoreDataManager.shared.createEntity(ofType: CDPracticeArticle.self)
                
                article.id = UUID().uuidString
                article.title = title
                article.content = content
                article.text = article.text
                article.uploadedDate = Date()
                article.cefrRawValue = CEFR.c1.rawValue.toInt64
                article.audioResource = audioResource
                article.imageResource = imageResource
                article.timepointSet = NSSet(array: timepoints)
                
                FirebaseManager.shared.uploadArticle(article) { isDownloadSuccessful in
                    print("foo - upload article \(isDownloadSuccessful)")
                }
            }
        }
    }
}
