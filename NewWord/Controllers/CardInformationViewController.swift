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

    enum CardInformationCase: Int {
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

    struct FormattedLearningRecord {
        let learned: Date
        let dueDate: Date
        let ease: Double
        let type: CDLearningRecord.State
        let rate: CDLearningRecord.Status
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
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
