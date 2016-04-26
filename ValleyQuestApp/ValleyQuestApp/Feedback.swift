//
//  Feedback.swift
//  Valley Quest App
//
//  Created by John Kotz on 3/21/16.
//  Copyright © 2016 vitalCommunities. All rights reserved.
//

import Foundation
import Parse

extension String {
    func isValidEmail() -> Bool {
        // println("validate calendar: \(testStr)")
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluateWithObject(self)
    }
}

class Feedback: PFObject, PFSubclassing {
    
    @NSManaged var forQuest: Quest
    @NSManaged var submitterEmail: String // This is an email. Use it well
    @NSManaged var message: String
    // Box feedback
    @NSManaged var percentOfBookUsed: NSNumber?
    @NSManaged var boxQuality: String?
    @NSManaged var boxNeedsReposition: Bool
    @NSManaged var boxMissingItems: [String]?
    @NSManaged var boxMore: String?
    
    // Clues feedback
    @NSManaged var hasCluesFeedback: Bool
    @NSManaged var cluesAccuracy: String?
    @NSManaged var clarity: String?
    @NSManaged var cluesNeedUpdate: Bool
    @NSManaged var cluesMore: String?
    
    // The options for various multiple choice questions
    static let boxQualityOptions: [String] = ["Bad", "Okay", "Good"]
    static let boxMissingItemsOptions: [String] = ["Box", "Book", "Pen", "Stamp", "Ink pad (aka empty)"]
    static let cluesAccuracyOptions: [String] = ["Wrong", "Not great", "Good", "Great"]
    static let clarityOptions: [String] = [ "Good", "Confusing", "Too easy"]
    
    
    // Create a simple feedback object
    class func create(forQuest: Quest, submitterEmail: String, message: String) -> Feedback {
        let object = Feedback()
        object.forQuest = forQuest
        object.submitterEmail = submitterEmail
        object.message = message
        assert(submitterEmail.isValidEmail(), "submitterEmail must be a valid email")
        assert(object.isValid(), "Something is wrong with the given things")
        return object
    }
    
    func isValid() -> Bool {
        return submitterEmail.isValidEmail() && cluesFeedbackIsValid() && boxFeedbackIsValid()
    }
    
    func cluesFeedbackIsValid() -> Bool {
        return hasCluesFeedback ? cluesAccuracy != nil && clarity != nil && cluesMore != nil && Feedback.cluesAccuracyOptions.contains(self.cluesAccuracy!) && Feedback.clarityOptions.contains(self.clarity!) : true
    }
    
    func boxFeedbackIsValid() -> Bool {
        if let missingItems = self.boxMissingItems {
            for item in missingItems {
                if !Feedback.boxMissingItemsOptions.contains(item) {
                    return false
                }
            }
        }
        
        return boxQuality != nil ? Feedback.boxQualityOptions.contains(boxQuality!) : true
    }
    
    func settPercentOfBookUsed(percent: Float) {
        assert(percent >= 0 && percent <= 1, "Percent must be a value between 0 and 1")
        self.percentOfBookUsed = NSNumber(float: percent)
    }
    
    func settBoxQuality(quality: String) {
        assert(Feedback.boxQualityOptions.contains(quality), "Quality must be within options")
        self.boxQuality = quality
    }
    
    func settBoxNeedsReposition(bool: Bool) {
        self.boxNeedsReposition = bool
    }
    
    func settBoxMissingItems(items: [String]) {
        for item in items {
            if !Feedback.boxMissingItemsOptions.contains(item) {
                return
            }
        }
        
        self.boxMissingItems = items
    }
    
    func settBoxMore(more: String) {
        self.boxMore = more
    }
    
    func addCluesFeedback(accuracy: String, clarity: String, needUpdate: Bool, more: String) {
        hasCluesFeedback = true
        
        assert(Feedback.cluesAccuracyOptions.contains(accuracy), "Accuracy must be one of the accuracy options")
        assert(Feedback.clarityOptions.contains(clarity), "Understandable must be one of the understandable options")
        
        self.cluesAccuracy = accuracy
        self.clarity = clarity
        self.cluesNeedUpdate = needUpdate
        self.cluesMore = more
    }
    
    func removeCluesFeedback() {
        hasCluesFeedback = false
        self.cluesNeedUpdate = false
        self.cluesAccuracy = nil
        self.cluesMore = nil
        self.clarity = nil
    }
    
    static func parseClassName() -> String {
        return "Feedback"
    }
}