//
//  ViewController.swift
//  Quizzler-iOS13
//
//  Created by Angela Yu on 12/07/2019.
//  Copyright © 2019 The App Brewery. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet weak var progressBar: UIProgressView!
    @IBOutlet var answerButtons: [UIButton]!
    
    // https://www.cosmopolitan.com/uk/worklife/a32612392/best-true-false-quiz-questions/
    var qDB: questionDB = questionDB()
    var uiQueue: Optional<OperationQueue> = nil
    var currentQuestion: Optional<Question> = Question(q: "Ready to start?", a: true, flavorText: nil )
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        questionLabel.text = currentQuestion?.q
    }

    @IBAction func answerButtonTouchUpInside(_ sender: UIButton) {
        for answerButton in answerButtons {
            answerButton.isEnabled = false
        }
        var userAnswer: Optional<Bool>
        switch sender.currentTitle {
        case "True":
            userAnswer = true
        case "False":
            userAnswer = false
        default:
            userAnswer = nil
        }
        //uiQueue?.cancelAllOperations()
        if( uiQueue == nil ) { uiQueue = OperationQueue() }
        uiQueue?.addOperation( uiFeedback(
            questionLabel: questionLabel,
            answerButtons: answerButtons,
            progressView: progressBar,
            currentQuestion: &currentQuestion,
            qDB: &qDB,
            userAnswer: userAnswer))
    }
    
}

class uiFeedback: Operation {
    // UI IBOutlets
    let questionLabel: UILabel
    let answerButtons: Array<UIButton>
    let progressView: UIProgressView
    // QA Struct & question DB
    var currentQuestion: Optional<Question>
    var qDB: questionDB
    // User Input
    let userAnswer: Optional<Bool>
    
    init( questionLabel: UILabel,
          answerButtons: Array<UIButton>,
          progressView: UIProgressView,
          currentQuestion: inout Optional<Question>,
          qDB: inout questionDB,
          userAnswer: Optional<Bool> ) {
        self.questionLabel = questionLabel
        self.answerButtons = answerButtons
        self.progressView = progressView
        self.currentQuestion = currentQuestion
        print("currentQuestion: \(Unmanaged.passUnretained(currentQuestion!).toOpaque()) self.currentQuestion: \(Unmanaged.passUnretained(self.currentQuestion!).toOpaque())")
        self.qDB = qDB
        self.userAnswer = userAnswer
    }
    
    override func main() {
        if isCancelled { return }
        print("Question: \(String(describing: currentQuestion?.q)) \nAnswer: \(String(describing: currentQuestion?.a)) \nUser Answer: \(userAnswer!)")
        var delay: useconds_t = 0
        // Check if answer is correct
        if( userAnswer == currentQuestion?.a ) {
            print("You are correct!")
            DispatchQueue.main.async { [self] in
                if( currentQuestion?.a == true ) { answerButtons[0].backgroundColor = UIColor.green
                } else { answerButtons[1].backgroundColor = UIColor.green }
            }
        } else {
            print("Incorrect.")
            DispatchQueue.main.async { [self] in
                if( currentQuestion?.a == false ) { answerButtons[0].backgroundColor = UIColor.red
                } else { answerButtons[1].backgroundColor = UIColor.red }
            }
        }
        // If flavor text exists, display it!
        if( currentQuestion?.flavorText != nil ) {
            DispatchQueue.main.async { [self] in
                questionLabel.text = currentQuestion!.q + "\n\n" + currentQuestion!.flavorText!
            }
            delay = 3 * 1000000
        }
        
        usleep(1500000 + delay)
        if isCancelled { return }
        // Remaining Questions
        print("\(qDB.count()) questions left.")
        
        // select next Question
        let nextQuestion = qDB.popQuestion()
        currentQuestion?.a = nextQuestion.a
        currentQuestion?.q = nextQuestion.q
        currentQuestion?.flavorText = nextQuestion.flavorText
        if ( currentQuestion?.q != "End of quiz." ) {
            DispatchQueue.main.async { [self] in
                questionLabel.text = currentQuestion?.q
                // reset buttons
                for answerButton in answerButtons {
                    answerButton.isEnabled = true
                    answerButton.backgroundColor = UIColor.clear
                    answerButton.layer.opacity = 1
                }
                progressView.layer.opacity = 1
                progressView.progress = 1 - Float(qDB.count()) / Float(qDB.startCount)
            }
        } else {
            DispatchQueue.main.async { [self] in
                questionLabel.text = "End of quiz!"
            }
            for answerButton in answerButtons {
                DispatchQueue.main.async {
                    answerButton.layer.opacity = 0
                }
            }
            DispatchQueue.main.async { [self] in
                progressView.layer.opacity = 0
            }
        }
    }
}
