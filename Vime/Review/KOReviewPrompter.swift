//
//  KOReviewPrompter.swift
//  Vime
//
//  Created by SathishKumar on 13/06/21.
//  Copyright © 2021 Ghost. All rights reserved.
//

import Foundation
import StoreKit

class KOReviewPrompter {
    
    static func requestReview() {
        var count = UserDefaults.standard.integer(forKey: KOUserDefaultKeyConstants.successfulRecordingCount)
        count += 1
        UserDefaults.standard.set(count, forKey: KOUserDefaultKeyConstants.successfulRecordingCount)
        
        let infoDictionaryKey = kCFBundleVersionKey as String
        guard let currentVersion = Bundle.main.object(forInfoDictionaryKey: infoDictionaryKey) as? String
            else { fatalError("Expected to find a bundle version in the info dictionary") }
        
        let lastVersionPromptedForReview = UserDefaults.standard.string(forKey: KOUserDefaultKeyConstants.lastVersionPromptedForReviewKey)
        
        if lastVersionPromptedForReview != currentVersion, count >= 5 {
            SKStoreReviewController.requestReview()
            UserDefaults.standard.set(currentVersion, forKey: KOUserDefaultKeyConstants.lastVersionPromptedForReviewKey)
            UserDefaults.standard.set(0, forKey: KOUserDefaultKeyConstants.successfulRecordingCount)
        }
    }
}
