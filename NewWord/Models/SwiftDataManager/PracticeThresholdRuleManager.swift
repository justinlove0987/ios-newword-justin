//
//  PracticeThresholdRuleManager.swift
//  NewWord
//
//  Created by 曾柏楊 on 2024/8/29.
//

import UIKit
import SwiftData
import SwiftUI

@MainActor
class PracticeThresholdRuleManager {
    
    static let shared = PracticeThresholdRuleManager()
    
    private var context: ModelContext
    
    private init() {
        self.context = ModelContainerProvider<PracticeThresholdRule>.persistantContainer()!.mainContext
    }
    
    // 創建新記錄
    func createRule(conditionType: Int, thresholdValue: Int, actionType: Int) {
        let rule = PracticeThresholdRule(conditionType: conditionType, thresholdValue: thresholdValue, actionType: actionType)
        
        // 將實例插入上下文
        context.insert(rule)
        
        do {
            // 保存上下文的更改
            try context.save()
        } catch {
            print("Failed to save rule: \(error)")
        }
    }
    
    // 讀取所有記錄
    func fetchAllRules() -> [PracticeThresholdRule] {
        
        do {
            let rules = try context.fetch(FetchDescriptor<PracticeThresholdRule>())
            
            return rules
        } catch {
            print("Failed to fetch rules: \(error)")
            return []
        }
    }
    
    // 根據 ID 讀取單個記錄
    func fetchRule(byId id: UUID) -> PracticeThresholdRule? {
        let descriptor = FetchDescriptor<PracticeThresholdRule>(
            predicate: #Predicate { $0.id == id }
        )
        
        do {
            let rules = try context.fetch(descriptor)
            
            return rules.first
            
        } catch {
            print("Failed to load Movie model.")
            
            return nil
        }
    }
    
    // 更新記錄
    func updateRule(id: UUID, conditionType: Int, thresholdValue: Int, actionType: Int) {
        if let rule = fetchRule(byId: id) {
            rule.conditionType = conditionType
            rule.thresholdValue = thresholdValue
            rule.actionType = actionType
            
            do {
                try context.save()
            } catch {
                print("Failed to update rule: \(error)")
            }
        } else {
            print("Rule with ID \(id) not found")
        }
    }
    
    // 刪除記錄
    func deleteRule(id: UUID) {
        if let rule = fetchRule(byId: id) {
            context.delete(rule)
            
            do {
                try context.save()
            } catch {
                print("Failed to delete rule: \(error)")
            }
        } else {
            print("Rule with ID \(id) not found")
        }
    }
}
