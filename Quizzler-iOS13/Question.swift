//
//  Question.swift
//  Quizzler-iOS13
//
//  Created by Parker Gibson on 4/10/22.
//

import Foundation

class Question {
    var q: String
    var a: Bool
    var flavorText: Optional<String>
    init( q: String, a: Bool, flavorText: Optional<String> ) {
        self.q = q
        self.a = a
        self.flavorText = flavorText
    }
}

// Needs Equatable to remove Question from array
//  actually depreciated since there's now a questionDB that manages removal from array
extension Question: Equatable {
    // When checking for equality, the flavorText does not matter, arguably the answer does not either.
    static func == (lhs: Question, rhs: Question) -> Bool {
        return lhs.q == rhs.q && lhs.a == rhs.a
    }
    static func != (lhs: Question, rhs: Question) -> Bool {
        return lhs.q != rhs.q || lhs.a != rhs.a
    }
}
