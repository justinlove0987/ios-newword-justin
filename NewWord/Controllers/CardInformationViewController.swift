//
//  LearningRecordViewController.swift
//  NewWord
//
//  Created by justin on 2024/6/10.
//

import UIKit

class CardInformationViewController: UIViewController, StoryboardGenerated {

    static var storyboardName: String = K.Storyboard.main

    @IBOutlet weak var tableView: UITableView!

    var card: CDCard?
    
    var cellTypes: [CellType] = []

    enum CellType {
        case card(CardInformation)
        case learningRecord(FormattedLearningRecord)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }

    private func setup() {
        setupTableView()
        setupDataSource()
    }

    private func setupDataSource() {
        guard let card = card else { return }

        let factory = CardInformationFactory(card: card)
        cellTypes = factory.createCellTypes()
    }

    private func setupTableView() {
        tableView.register(UINib(nibName: "LearningRecordCell", bundle: nil), forCellReuseIdentifier: "LearningRecordCell")
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
    }
}

extension CardInformationViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cellTypes.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellType = cellTypes[indexPath.row]
        
        switch cellType {
            
        case .card(let information):
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
            var config = cell.defaultContentConfiguration()
            config.prefersSideBySideTextAndSecondaryText = true

            config.text = information.title
            config.secondaryText = information.content
            cell.contentConfiguration = config
            
            return cell
            
        case .learningRecord(let formattedLearningRecord):
            let cell = tableView.dequeueReusableCell(withIdentifier: "LearningRecordCell", for: indexPath) as! LearningRecordCell

            cell.updateUI(with: formattedLearningRecord)

            return cell
        }
        
    }

}

extension CardInformationViewController {
    
    struct FormattedLearningRecord {
        let learned: Date
        let dueDate: Date
        let ease: Double
        let type: CDLearningRecord.State
        let rate: CDLearningRecord.Status
        let interval: Double

        init(learningRecord: CDLearningRecord) {
            self.learned = learningRecord.learnedDate ?? Date()
            self.dueDate = learningRecord.dueDate ?? Date()
            self.ease = learningRecord.ease
            self.type = learningRecord.state
            self.rate = learningRecord.status
            self.interval = learningRecord.interval
        }

        var formattedlearnedDate: String {
            return formatDate(learned)
        }

        var formattedDueDate: String {
            return formatDate(dueDate)
        }

        var formattedEase: String {
            let percentage = ease * 100
            return String(format: "%.0f%%", percentage)
        }

        var formattedType: String {
            return String(describing: type)
        }

        var formattedRate: String {
            return String(describing: rate)
        }

        var formattedInterval: String {
            return formatInterval(interval)
        }


        func formatDate(_ date: Date) -> String {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            return dateFormatter.string(from: date)
        }

        func formatInterval(_ interval: Double) -> String {
            let secondsInMinute = 60.0
            // let secondsInHour = 3600.0
            let secondsInDay = 86400.0
            let secondsInMonth = 2592000.0 // Approximating 30 days per month
            let secondsInYear = 31536000.0 // Approximating 365 days per year

            var remainingInterval = interval

            let years = Int(remainingInterval / secondsInYear)
            remainingInterval -= Double(years) * secondsInYear

            let months = Int(remainingInterval / secondsInMonth)
            remainingInterval -= Double(months) * secondsInMonth

            let days = Int(remainingInterval / secondsInDay)
            remainingInterval -= Double(days) * secondsInDay

            let minutes = Int(remainingInterval / secondsInMinute)

            var result = ""

            if years > 0 {
                result += "\(years) years "
            }
            if months > 0 {
                result += "\(months) months "
            }
            if days > 0 {
                result += "\(days) days"
            } else if years == 0 && months == 0 {
                result += "\(minutes) minutes"
            }

            return result.trimmingCharacters(in: .whitespaces)
        }
    }
    
    struct CardInformation {
        let title: String
        let content: String
    }
    
    enum CardInformationCase: Int, CaseIterable {

        case addedDate
        case firstReviewDate
        case lastestReviewDate
        case dueDate
        case interval
        case ease
        case reviews
        case lapses
        case averageTime
        case totalTime
        case cardType
        case noteType
        case deck
        case cardId
        case noteId

        var title: String {
            switch self {
            case .addedDate:
                return "Added Date"
            case .firstReviewDate:
                return "First Review Date"
            case .lastestReviewDate:
                return "Latest Review Date"
            case .dueDate:
                return "Due Date"
            case .interval:
                return "Interval"
            case .ease:
                return "Ease"
            case .reviews:
                return "Review Number"
            case .lapses:
                return "Lapses"
            case .averageTime:
                return "Average Time"
            case .totalTime:
                return "Total Time"
            case .cardType:
                return "Card Type"
            case .noteType:
                return "Note Type"
            case .deck:
                return "Deck Name"
            case .cardId:
                return "Card Id"
            case .noteId:
                return "Note Id"
            }
        }
    }
    
    class CardInformationFactory {

        var addedDate: Date?
        var firstReviewDate: Date?
        var latestReviewDate: Date?
        var dueDate: Date?
        var interval: Double?
        var ease: Double?
        var reviews: Int
        var lapses: Int
        var averageTime: Double
        var totalTime: Double
        var noteType: NoteType?
        var cardId: String?
        var noteId: String?


        var formattedAddedDate: String {
            guard let addedDate = addedDate else { return "" }
            return formatDate(addedDate)
        }

        var formattedFirstReviewDate: String {
            guard let firstReviewDate = firstReviewDate else { return "" }
            return formatDate(firstReviewDate)
        }

        var formattedLatestReviewDate: String {
            guard let latestReviewDate = latestReviewDate else { return "" }
            return formatDate(latestReviewDate)
        }

        var formattedDueDate: String {
            guard let dueDate = dueDate else { return "" }
            return formatDate(dueDate)
        }

        var formattedInterval: String {
            guard let interval = interval else { return "" }
            
            return formatInterval(interval)
        }

        var formattedEase: String {
            guard let ease = ease else { return "" }
            
            let percentage = ease * 100
            return String(format: "%.0f%%", percentage)
        }

        var card: CDCard

        init(card: CDCard) {
            self.addedDate = card.addedDate
            self.firstReviewDate = card.firstLearningRecord?.learnedDate
            self.latestReviewDate = card.latestLearningRecord?.learnedDate
            self.dueDate = card.latestLearningRecord?.dueDate
            self.interval = card.latestLearningRecord?.interval
            self.ease = card.latestLearningRecord?.ease
            self.reviews = card.reviews
            self.lapses = card.lapses
            self.averageTime = card.averageTime
            self.totalTime = card.totalTime
            self.noteType = card.note?.type
            self.cardId = card.id
            self.noteId = card.note?.id
            self.card = card
        }

        func createCellTypes() -> [CellType] {
            var cellTypes: [CellType] = []
            let cardCases = CardInformationCase.allCases
            
            for cardCase in cardCases {
                switch cardCase {
                case .addedDate:
                    guard addedDate != nil else { break }

                    cellTypes.append(CellType.card(
                        CardInformation(title: cardCase.title, content: formattedAddedDate)
                    ))
                    
                case .firstReviewDate:
                    guard firstReviewDate != nil else { break }
                    
                    cellTypes.append(CellType.card(
                        CardInformation(title: cardCase.title, content: formattedFirstReviewDate)
                    ))
                    
                case .lastestReviewDate:
                    guard latestReviewDate != nil else { break }
                    
                    cellTypes.append(CellType.card(
                        CardInformation(title: cardCase.title, content: formattedLatestReviewDate)
                    ))
                    
                case .dueDate:
                    guard dueDate != nil else { break }
                    
                    cellTypes.append(CellType.card(
                        CardInformation(title: cardCase.title, content: formattedDueDate)
                    ))

                case .interval:
                    guard interval != nil else { break }

                    cellTypes.append(CellType.card(
                        CardInformation(title: cardCase.title, content: formattedInterval)
                    ))
                    
                case .ease:
                    guard ease != nil else { break }

                    cellTypes.append(CellType.card(
                        CardInformation(title: cardCase.title, content: formattedEase)
                    ))

                case .reviews:
                    cellTypes.append(CellType.card(
                        CardInformation(title: cardCase.title, content: "\(reviews)")
                    ))
                    
                case .lapses:
                    cellTypes.append(CellType.card(
                        CardInformation(title: cardCase.title, content: "\(lapses)")
                    ))
                    
                case .averageTime:
                    cellTypes.append(CellType.card(
                        CardInformation(title: cardCase.title, content: "\(averageTime)")
                    ))
                    
                case .totalTime:
                    cellTypes.append(CellType.card(
                        CardInformation(title: cardCase.title, content: "\(totalTime)")
                    ))
                    
                case .cardType:
                    break
                case .noteType:
                    guard let noteType = noteType else { break }
                    
                    cellTypes.append(CellType.card(
                        CardInformation(title: cardCase.title, content: String(describing: noteType))
                    ))
                    
                case .deck:
                    break
                    
                case .cardId:
                    guard let cardId = cardId else { break }
                    
                    cellTypes.append(CellType.card(
                        CardInformation(title: cardCase.title, content: cardId)
                    ))
                    
                case .noteId:
                    guard let noteId = noteId else { break }
                    
                    cellTypes.append(CellType.card(
                        CardInformation(title: cardCase.title, content: noteId)
                    ))
                }
            }

            let learningRecords = CoreDataManager.shared.learningRecords(from: card)

            learningRecords.forEach { record in
                let formattedRecord = FormattedLearningRecord(learningRecord: record)
                let cellType = CellType.learningRecord(formattedRecord)
                cellTypes.append(cellType)
            }

            
            return cellTypes
        }

        func formatInterval(_ interval: Double) -> String {
            let secondsInMinute = 60.0
            // let secondsInHour = 3600.0
            let secondsInDay = 86400.0
            let secondsInMonth = 2592000.0 // Approximating 30 days per month
            let secondsInYear = 31536000.0 // Approximating 365 days per year

            var remainingInterval = interval

            let years = Int(remainingInterval / secondsInYear)
            remainingInterval -= Double(years) * secondsInYear

            let months = Int(remainingInterval / secondsInMonth)
            remainingInterval -= Double(months) * secondsInMonth

            let days = Int(remainingInterval / secondsInDay)
            remainingInterval -= Double(days) * secondsInDay

            let minutes = Int(remainingInterval / secondsInMinute)

            var result = ""

            if years > 0 {
                result += "\(years) years "
            }
            if months > 0 {
                result += "\(months) months "
            }
            if days > 0 {
                result += "\(days) days"
            } else if years == 0 && months == 0 {
                result += "\(minutes) minutes"
            }

            return result.trimmingCharacters(in: .whitespaces)
        }

        func formatDate(_ date: Date) -> String {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            return dateFormatter.string(from: date)
        }
    }


}
