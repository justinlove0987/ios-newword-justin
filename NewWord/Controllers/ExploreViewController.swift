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
    
    private var dataSource: UICollectionViewDiffableDataSource<Int,Article.Copy>!

    private var articles: [Article.Copy] = [] {
        didSet {
            articles.sort { $0.uploadedDate! > $1.uploadedDate! }
            updateSnapshot()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()

//        PracticeManager.shared.deleteAllEntities()
//        UserDefaultsManager.shared.lastDataFetchedDate = getYesterdayDate()

        let localArticles = ArticleManager.shared.fetchAll()
        
        if shouldFetchArticles() {
            fetchAndSyncArticles(with: localArticles)
        } else {
            self.articles = Article.copyArticles(from: localArticles)
        }
        
//        uploadArticle()
    }

    func getYesterdayDate() -> Date {
        let calendar = Calendar.current
        let today = Date()

        // 使用dateComponents來減去一天
        let yesterday = calendar.date(byAdding: .day, value: -1, to: today)

        return yesterday!
    }

    private func setup() {
        setupCollectionView()
    }

    private func fetchArticles(completion: @escaping ([Article]) -> Void) {
        FirebaseManager.shared.fetchAllArticles { articles in
            var newArticles: [Article] = []

            for article in articles {
                newArticles.append(article)
            }

            completion(newArticles)
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
    
    private func createDataSource() -> UICollectionViewDiffableDataSource<Int, Article.Copy> {
        let dataSource = UICollectionViewDiffableDataSource<Int, Article.Copy>(collectionView: collectionView,
                                                                            cellProvider: { collectionView, indexPath, itemIdentifier in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ExploreCell.reuseIdentifier, for: indexPath) as! ExploreCell
            
            let currentArticle = self.articles[indexPath.row]
            
            cell.configure(currentArticle)
            cell.imageView.image = currentArticle.hasImage ? UIImage(data: currentArticle.imageResource!.data!) : UIImage(named: "loading")

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
        var snapshot = NSDiffableDataSourceSnapshot<Int, Article.Copy>()
        snapshot.appendSections([0])
        snapshot.appendItems(articles)

        DispatchQueue.main.async {
            self.dataSource.apply(snapshot, animatingDifferences: false)
        }
    }
    
    private func fetchImage(at indexPath: IndexPath) {
        guard let imageId = self.articles[indexPath.row].imageResource?.id else { return }

        FirebaseManager.shared.getImage(for: imageId) { result in
            switch result {
            case .success(let imageData):
                self.articles[indexPath.row].imageResource?.data = imageData

            case .failure(_):
                self.articles[indexPath.row].imageResource?.data = UIImage(named: "loading")?.pngData()
            }
            
            DispatchQueue.main.async {
                var snapshot = self.dataSource.snapshot()

                snapshot.reloadItems([self.articles[indexPath.row]])

                self.dataSource.apply(snapshot, animatingDifferences: true)
            }
        }
    }
    
    // MARK: - Helper Methods

    private func shouldFetchArticles() -> Bool {
        return !UserDefaultsManager.shared.hasFetchedDataToday()
    }

    private func fetchAndSyncArticles(with localArticles: [Article]) {
        fetchArticles { serverArticles in
            self.syncNewServerArticles(with: localArticles, from: serverArticles) {
                self.articles = Article.copyArticles(from: serverArticles)
            }
            UserDefaultsManager.shared.updateLastFetchedDate()
        }
    }

    private func syncNewServerArticles(with localArticles: [Article], from serverArticles: [Article], completion: @escaping () -> Void) {
        let localArticleIDs = Set(localArticles.map { $0.id })
        let newArticles = serverArticles.filter { !localArticleIDs.contains($0.id) }

        DispatchQueue.main.async {
            let dispatchGroup = DispatchGroup()

            newArticles.forEach { article in
                dispatchGroup.enter()
                ArticleManager.shared.create(model: article)
                dispatchGroup.leave()
            }

            dispatchGroup.notify(queue: .main) {
                completion()
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
        
        controller.copyArticle = articles[indexPath.row]
        
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
        let title = "Successful Polio Vaccination Campaign in Gaza Surpasses Expectations"
        
        let content =
                """
                The World Health Organization (WHO) has announced that the initial phase of a polio vaccination campaign in central Gaza has exceeded its goals, with over 161,000 children vaccinated within the first two days. Dr. Rik Peeperkorn, WHO's representative in the Palestinian territories, noted that this figure surpasses the projected target of 156,500, likely due to underestimations of the densely populated area.
                
                The vaccination drive became possible after Israel and Hamas agreed to localized ceasefires, allowing health workers to administer vaccines. This initiative was crucial following the first confirmed polio case in Gaza in 25 years, which left a 10-month-old partially paralyzed.
                
                The immunization campaign is being conducted in three stages, with temporary pauses in hostilities from 06:00 to 15:00 local time. The first phase began in Deir al-Balah and Khan Younis governorates, and will continue in Rafah, followed by North Gaza and Gaza City. While the campaign has progressed smoothly, Dr. Peeperkorn emphasized that there are at least 10 days remaining in the first round, with a second round scheduled in four weeks to ensure full immunization coverage.
                
                Efforts are ongoing to reach children in areas outside the ceasefire zones, particularly in the southern parts of Gaza. The overall goal is to vaccinate 640,000 children, with a minimum of 90% coverage needed to halt the transmission of poliovirus in Gaza and prevent its spread to neighboring regions.
                
                Polio is a highly contagious virus, often transmitted through contaminated water, that primarily affects children under five. It can lead to severe consequences such as paralysis or even death. Humanitarian organizations attribute the resurgence of polio in Gaza to disruptions in vaccination programs and significant damage to water and sanitation infrastructure due to the ongoing conflict.
                
                The mother of the affected child, Niveen, shared her feelings of guilt for being unable to vaccinate her son due to the conflict. She expressed a deep desire for her son to receive treatment outside Gaza, hoping he could live a life free from the debilitating effects of polio.
                """
        
                let text = "\(title)\n\n\(content)"
        
                GoogleTTSService.shared.downloadSSML(text) { audioResource in
                    guard let audioResource else {
                        print("foo - download ssml failed")
                        return
                    }
        
                    guard let id = audioResource.id, let audioData = audioResource.data else {
                        print("foo - download ssml failed, there is no audio data")
                        return
                    }
        
                    FirebaseManager.shared.uploadAudio(audioId: id, audioData: audioData) { isDownloadSuccessful, url in
                        print("foo upload audio \(isDownloadSuccessful)")
        
                        let imageResource = PracticeImage.Copy(id: UUID().uuidString)
        
                        let article = Article.Copy(id: UUID().uuidString,
                                                        title: title,
                                                        content: content,
                                                        uploadedDate: Date(),
                                                        audioResource: audioResource,
                                                        imageResource: imageResource)
        
                        FirebaseManager.shared.uploadArticle(article) { isDownloadSuccessful in
                            print("foo - upload article \(isDownloadSuccessful)")
        
        
                        }
                    }
                }
    }
}
