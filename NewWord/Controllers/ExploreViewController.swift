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
    
    private var dataSource: UICollectionViewDiffableDataSource<Int,Article>!

    private var articles: [Article] = [] {
        didSet {
            articles.sort { $0.uploadedDate! > $1.uploadedDate! }
            updateSnapshot()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()

        let localArticles = ArticleManager.shared.fetchAll()

        print("foo - \(localArticles.count) \(localArticles)")

        if !UserDefaultsManager.shared.hasFetchedDataToday() {
            self.fetchArticles { serverArticles in
                self.syncNewServerArticles(with: localArticles, from: serverArticles)
                self.articles = serverArticles

                UserDefaultsManager.shared.updateLastFetchedDate()
            }

        } else {
            self.articles = localArticles
        }
        
        let title = "South Korea’s Deepfake Porn Scandal: A Crisis of Digital Exploitation"

        let content = """
        Last Saturday, Heejin, a university student, received a chilling Telegram message from an anonymous sender. “Your photos and personal information have been leaked. Let’s discuss.” As she opened the message, she was confronted with a familiar photograph from her school days, now manipulated into explicit and fake content using sophisticated deepfake technology.

        Deepfakes, which typically superimpose a person’s face onto explicit images, are being increasingly generated through artificial intelligence. “I was petrified, I felt so alone,” Heejin recounted to the BBC. Yet, she was far from alone in her distress.

        Two days prior, South Korean journalist Ko Narin had exposed a scandal that would become the most significant of her career. Her investigation revealed that police were probing deepfake porn rings at two major universities, but Ko suspected the issue was more widespread. Her search through social media uncovered numerous Telegram chat groups where users were sharing personal photos and converting them into fake pornography with alarming speed.

        These groups weren’t limited to university students; they extended to high schools and even middle schools. Some groups, referred to as “humiliation rooms” or “friend of friend rooms,” were dedicated to targeting specific individuals. Membership often required posting multiple personal photos and details about the targeted person.

        Ko’s report in the Hankyoreh newspaper has stunned South Korea. The police have announced they are considering investigating Telegram, following France’s lead, where Telegram’s Russian founder faced charges related to app misuse. The South Korean government has pledged stricter penalties and called for better education for young men.

        Telegram has stated it "actively combats harmful content on its platform, including illegal pornography."

        Ko’s investigation revealed the systematic and organized nature of these groups. One group’s guidelines demanded more than four photos of individuals, along with their names, ages, and locations. “I was shocked at how systematic and organized the process was,” Ko said, particularly horrified by a group targeting underage students.

        Women’s rights activists have joined the effort to uncover and address this crisis. By the end of the week, over 500 educational institutions had been identified as targets. The true scale is still unclear, but many victims are believed to be underage, with a significant number of perpetrators being teenagers themselves.

        Heejin’s distress was exacerbated by learning the full extent of the crisis, which led her to question her own actions. “I couldn’t stop thinking did this happen because I uploaded my photos to social media?” She and many others have since removed their online photos or deactivated their accounts, fearing further exploitation.

        Ah-eun, a university student, expressed frustration at having to alter her social media behavior despite no wrongdoing. Some victims have been discouraged by police, who dismissed the cases as difficult and less serious due to the fake nature of the photos.

        The heart of this scandal lies with Telegram, a private, encrypted messaging app. Unlike public websites, Telegram’s private nature and anonymous user base make it a haven for criminal activity. Recent responses from politicians and law enforcement include a promise to investigate Telegram’s role and enforce harsher penalties for offenders.

        The app’s founder, Pavel Durov, was recently charged in France for crimes related to the platform, including facilitating the sharing of child pornography. Critics argue that South Korean authorities have been slow to address the issue, citing previous failures to act on similar crises.

        Park Jihyun, a political advocate for victims of digital sex crimes, has been inundated with calls from terrified parents and students. She and other activists are calling for stricter regulation or even a ban on Telegram in South Korea to protect citizens from digital exploitation.

        The Advocacy Centre for Online Sexual Abuse Victims (ACOSAV) has seen a dramatic increase in underage victims, from 86 in 2023 to 238 in the first eight months of 2024. Park Seonghye, a leader at the center, described the situation as an emergency, likening it to a wartime crisis.

        While Telegram has taken some action to remove harmful content, activists argue that this is insufficient. They believe the root of the issue is entrenched sexism, which manifests through digital platforms. Critics have pointed to President Yoon Suk Yeol’s denial of structural sexism and his reduction of support for victim advocacy groups as contributing factors.

        Lee Myung-hwa, a counselor working with young sex offenders, highlighted the need for education on sexual abuse to prevent reoffending. The government has promised to increase penalties for creators and viewers of deepfake pornography, addressing criticism that current measures are inadequate.

        Despite efforts to shut down the offending chatrooms, new ones are likely to emerge. The creation of a “humiliation room” targeting journalists like Ko has heightened concerns among those involved in the investigation. This anxiety is shared by many young women in South Korea, who now find themselves vigilant and fearful of being targeted.
        """
        
        let text = "\(title)\n\n\(content)"
        
        GoogleTTSService.shared.downloadSSML(text) { audioResource in
            guard let audioResource else {
                print("foo - download ssml failed")
                return
            }
            guard let audioData = audioResource.data else { return }

            FirestoreManager.shared.uploadAudio(audioId: audioResource.id, audioData: audioData) { isDownloadSuccessful, url in
                print("foo upload audio \(isDownloadSuccessful)")

                let article = Article(id: UUID().uuidString, title: title, content: content, uploadedDate: Date())
                article.audioResource = audioResource

                FirestoreManager.shared.uploadArticle(article) { isDownloadSuccessful in
                    print("foo - upload article \(isDownloadSuccessful)")
                    

                }
            }
        }
        
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
        FirestoreManager.shared.fetchAllArticles { articles in
            var newArticles: [Article] = []

            for article in articles {
                newArticles.append(article)
            }

            completion(newArticles)
        }
    }

    private func updateToLocal(artilce: [Article]) {

    }

//    private func uploadArticles() {
//        let articles: [FSArticle] = []
//        
//        FirestoreManager.shared.uploadArticles(articles) { uploaded in
//            if uploaded {
//                print("foo - uploaded")
//            }
//        }
//    }

    private func setupCollectionView() {
        collectionView.register(UINib(nibName: ExploreCell.reuseIdentifier, bundle: nil), forCellWithReuseIdentifier: ExploreCell.reuseIdentifier)
        dataSource = createDataSource()
        collectionView.dataSource = dataSource
        collectionView.collectionViewLayout = createCollectionViewLayout()
        collectionView.delegate = self
        updateSnapshot()
    }
    
    private func createDataSource() -> UICollectionViewDiffableDataSource<Int, Article> {
        let dataSource = UICollectionViewDiffableDataSource<Int, Article>(collectionView: collectionView,
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
        var snapshot = NSDiffableDataSourceSnapshot<Int, Article>()
        snapshot.appendSections([0])
        snapshot.appendItems(articles)

        DispatchQueue.main.async {
            self.dataSource.apply(snapshot, animatingDifferences: false)
        }

    }
    
    private func fetchImage(at indexPath: IndexPath) {
        guard let imageId = self.articles[indexPath.row].imageResource?.id else { return }

        FirestoreManager.shared.getImage(for: imageId) { result in
            switch result {
            case .success(let imageData):
                self.articles[indexPath.row].imageResource?.data = imageData

            case .failure(_):
                self.articles[indexPath.row].imageResource?.data = UIImage(named: "loading")?.pngData()
            }
            
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
        }
    }

    

    private func syncNewServerArticles(with localArticles: [Article], from serverArticles: [Article]) {
        let localArticleIDs = Set(localArticles.map { $0.id })

        let newArticles = serverArticles.filter { !localArticleIDs.contains($0.id) }

        DispatchQueue.main.async {
            newArticles.forEach { article in
                ArticleManager.shared.create(model: article)
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
