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

    enum CellType {
        case card(CardInformation)
        case learningRecord(FormattedLearningRecord)
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

    struct CardInformation {
        let title: String
        let content: String
    }

    struct CardInformations {
        var cases: [CardInformationCase] = CardInformationCase.allCases

//        let added:

//        init(
    }

    struct FormattedLearningRecord {
        let learned: Date
        let dueDate: Date
        let ease: Double
        let type: CDLearningRecord.State
        let rate: CDLearningRecord.Status
        let interval: Double
    }

    override func viewDidLoad() {
        super.viewDidLoad()



    }

    private func setup() {
        setupTableView()
        setupDataSource()
    }

    private func setupDataSource() {
        guard let card = card else { return }

        card.addedDate

        let dataForCells: [CellType] = []

//        CardInformationCase.allCases.forEach { infoCase in
//            CardInformation(title: infoCase.title, content: <#T##String#>)
//        }

    }

    private func setupTableView() {
        tableView.register(UINib(nibName: "LearningRecordCell", bundle: nil), forCellReuseIdentifier: "LearningRecordCell")
    }
}

extension CardInformationViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
    }

}

extension CardInformationViewController {
    class CardInformationFactory {

//        var addedDate: Date
//        var firstReviewDate: Date
//        var latestReviewDate: Date
//        var dueDate: Date
//        var interval: Double
//        var ease: Double
//        var reviews: Int
//        var lapses: Int
//        var averageTime: Double
//        var totalTime: Double
//        var noteType: CDNoteType.Content
//        var cardId: String
//        var noteId: String
//
//
//        var formattedAddedDate: String {
//            return formatDate(addedDate)
//        }
//
//        var formattedFirstReviewDate: String {
//            return formatDate(firstReviewDate)
//        }
//
//        var formattedLatestReviewDate: String {
//            return formatDate(latestReviewDate)
//        }
//
//        var formattedDueDate: String {
//            return formatDate(dueDate)
//        }
//
//        var formattedInterval: String {
//            return formatInterval(interval)
//        }
//
//        var formattedEase: String {
//            let percentage = ease * 100
//            return String(format: "%.0f%%", percentage)
//        }

        init(addedDate: Date, firstReviewDate: Date, latestReviewDate: Date, dueDate: Date, interval: Double, ease: Double, reviews: Int, lapses: Int, averageTime: Double, totalTime: Double, noteType: CDNoteType.Content, cardId: String, noteId: String, card: CDCard) {

            if let latestLearningRecord = card.latestLearningRecord {

            } else {
                // still show without learning record

                // addedDate
                // reviews
                // Lapses
                // averageTime
                // totalTime
                // NoteType
                // Deck
                // Card Id
                // Note Id
            }


//            self.addedDate = card.addedDate
//            self.firstReviewDate =
//            self.latestReviewDate = card.latestLearningRecord?.learnedDate
//            self.dueDate = card.latestLearningRecord?.dueDate
//            self.interval = card.latestLearningRecord?.interval
//            self.ease = card.latestLearningRecord?.ease
//            self.reviews = reviews
//            self.lapses = lapses
//            self.averageTime = averageTime
//            self.totalTime = totalTime
//            self.noteType = noteType
//            self.cardId = cardId
//            self.noteId = noteId
        }

        func createCellTypes() -> [CellType] {
            // Logic to create and return cell types based on the properties
            return []
        }

        func formatDate(_ date: Date) -> String {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            return dateFormatter.string(from: date)
        }

        func formatInterval(_ interval: Double) -> String {
            let secondsInMinute = 60.0
            let secondsInHour = 3600.0
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
}
