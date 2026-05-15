//
//  SubBudgetService.swift
//  FinanceApp
//
//  Created by Maeve Hogan on 5/13/26.
//

import Foundation
import SwiftData

struct SubBudgetService {
    
    // Create a new sub-budget
    static func createSubBudget(parentBudget: Budget, title: String, context: ModelContext) -> SubBudget {
        let newSubBudget = SubBudget(title: title)
        parentBudget.addSubBudget(subBudget: newSubBudget)
        
        context.insert(newSubBudget)
        
        return newSubBudget
    }
}
