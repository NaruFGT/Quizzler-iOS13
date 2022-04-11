//
//  questionDB.swift
//  Quizzler-iOS13
//
//  Created by Parker Gibson on 4/10/22.
//

import Foundation
import UIKit

class questionDB {
    let json: Optional<Any>
    var Questions: Array<Question> = Array()
    let startCount: Int
    init() {
        // questions taken shamelessly from
        // https://www.cosmopolitan.com/uk/worklife/a32612392/best-true-false-quiz-questions/
        json = try? JSONSerialization.jsonObject(with: NSDataAsset(name:"questionDB")!.data, options: [])
        if let array = json as? [[String: Any]] {
            for object in array {
                let question = object["question"] as! String
                let answer = object["answer"] as! Bool
                let flavorText = object["flavorText"] as? String
                Questions.append(Question(q: question, a: answer, flavorText: flavorText))
            }
        }
        startCount = Questions.count
    }
    func popQuestion() -> Question {
        if let index = Questions.indices.randomElement() {
            return Questions.remove(at: index)
        } else {
            return Question(q: "End of quiz.", a: true, flavorText: nil)
        }
    }
    
    func count() -> Int {
        return Questions.count
    }
}
